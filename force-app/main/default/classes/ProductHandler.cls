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

    private static void synchronizeProductsFromApi() {
        HttpResponse response = sendHttpRequest();
        List<ProductWrapper> apiProducts = ProductWrapper.parse(response.getBody());

        createProducts(apiProducts);
    }

    private static HttpResponse sendHttpRequest() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setEndpoint(API_URL + 'products');
        return http.send(request);
    }

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

    private static void setProductsPrices(List<Product2> newProducts, List<ProductWrapper> apiProducts) {
        Pricebook2 standardPb = getStandardPriceBook();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for (Product2 product : newProducts) {
            for (ProductWrapper apiProduct : apiProducts) {
                if (product.Name == apiProduct.title) {
                    pricebookEntries.add(createPricebookEntry(product.Id, standardPb.Id, apiProduct.price));
                }
            }
        }

        insert pricebookEntries;
    }

    private static Pricebook2 getStandardPricebook() {
        return [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
    }

    private static PricebookEntry createPriceBookEntry(Id productId, Id spbId, Decimal price) {
        PricebookEntry pbe = new PricebookEntry();

        pbe.UnitPrice = price;
        pbe.Pricebook2Id = spbId;
        pbe.Product2Id = productId;
        pbe.IsActive = true;

        return pbe;
    }
}
