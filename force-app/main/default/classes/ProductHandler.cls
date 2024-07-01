public with sharing class ProductHandler {
    private static final String API_URL = 'https://fakestoreapi.com/';

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return [
            SELECT
                Id,
                Name,
                Description,
                Family,
                Image__c,
                Rating__c,
                Rating_Count__c,
                (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.isStandard = TRUE LIMIT 1)
            FROM Product2
        ];
    }

    /**
     * Fetches product data from the API, creates new products if the don't exist in the org,
     * and sets prices for the standard price book.
     */
    @TestVisible
    private static void synchronizeProductsFromApi() {
        HttpResponse response = sendHttpRequest();
        List<ProductWrapper> apiProducts = ProductWrapper.parse(response.getBody());

        createProducts(apiProducts);
    }

    /**
     * @return HttpResponse object containing the API response.
     */
    private static HttpResponse sendHttpRequest() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setEndpoint(API_URL + 'products');

        return http.send(request);
    }

    /**
     * Creates new Product2 records and set prices based on the API response.
     *
     * @param apiProducts - List of ProductWrapper objects containing API product data.
     * @return List of newly created Product2 records.
     */
    private static List<Product2> createProducts(List<ProductWrapper> apiProducts) {
        List<String> existingProductsNames = getExistingProductsNames();
        List<Product2> newProducts = new List<Product2>();

        for (ProductWrapper apiProduct : apiProducts) {
            String productName = apiProduct.title.trim();
            if (!existingProductsNames.contains(productName)) {
                newProducts.add(createProduct(apiProduct));
            }
        }

        if (!newProducts.isEmpty()) {
            insert newProducts;
            setProductsPrices(newProducts, apiProducts);
        }

        return newProducts;
    }

    private static List<String> getExistingProductsNames() {
        List<String> productsNames = new List<String>();

        for (Product2 p : [SELECT Name FROM Product2]) {
            productsNames.add(p.Name);
        }

        return productsNames;
    }

    private static Product2 createProduct(ProductWrapper apiProduct) {
        Product2 product = new Product2();

        product.Name = apiProduct.title;
        product.Description = apiProduct.description;
        product.Family = apiProduct.category;
        product.Image__c = apiProduct.image;
        product.Rating__c = apiProduct.rating.rate;
        product.Rating_count__c = apiProduct.rating.count;
        product.IsActive = true;

        return product;
    }

    /**
     * Set prices for the standard pricebook base on the provided API product data.
     *
     * @param newProducts - List of newly created Product2 records.
     * @param apiProducts - List of ProductWrapper objects containing API product data.
     */
    private static void setProductsPrices(List<Product2> newProducts, List<ProductWrapper> apiProducts) {
        Id standardPbId = PricebookHandler.getStandardPriceBookId();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for (Product2 product : newProducts) {
            for (ProductWrapper apiProduct : apiProducts) {
                if (product.Name == apiProduct.title) {
                    PricebookEntry pbe = PricebookEntryHandler.createRecord(product.Id, standardPbId, apiProduct.price);
                    pricebookEntries.add(pbe);
                }
            }
        }

        insert pricebookEntries;
    }
}
