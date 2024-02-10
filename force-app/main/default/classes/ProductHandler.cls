public with sharing class ProductHandler {
    private static final String URL = 'https://fakestoreapi.com/';

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

    private static void insertProductsFromApi() {
        HttpResponse response = sendHttpRequest();
        List<ProductWrapper> itemList = ProductWrapper.parse(response.getBody());

        createProducts(itemList);
    }

    private static HttpResponse sendHttpRequest() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setEndpoint(URL + 'products');
        return http.send(request);
    }

    private static List<Product2> createProducts(List<ProductWrapper> items) {
        List<String> existingProductsNames = getExistingProductsNames();
        List<Product2> newProducts = new List<Product2>();

        for (ProductWrapper item : items) {
            if (!doesProductExist(item.title, existingProductsNames)) {
                newProducts.add(createProduct(item));
            }
        }

        if (!newProducts.isEmpty()) {
            insert newProducts;
            setProductsPrices(newProducts, items);
        }

        System.debug('newProducts size: ' + newProducts.size());

        return newProducts;
    }

    private static List<String> getExistingProductsNames() {
        List<String> productsNames = new List<String>();

        for (Product2 p : [SELECT Name FROM Product2]) {
            productsNames.add(p.Name);
        }

        return productsNames;
    }

    private static Boolean doesProductExist(String itemName, List<String> orgProducts) {
        return orgProducts.contains(itemName.trim());
    }

    private static Product2 createProduct(ProductWrapper item) {
        Product2 product = new Product2();

        product.Name = item.title;
        product.Description = item.description;
        product.Family = item.category;
        product.Image__c = item.image;
        product.Rating__c = item.rating.rate;
        product.Rating_count__c = item.rating.count;
        product.IsActive = true;

        return product;
    }

    private static void setProductsPrices(List<Product2> newProducts, List<ProductWrapper> items) {
        Pricebook2 standardPb = getStandardPriceBook();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for (Product2 product : newProducts) {
            for (ProductWrapper item : items) {
                if (product.Name == item.title) {
                    pricebookEntries.add(createPricebookEntry(product.Id, standardPb.Id, item.price));
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
