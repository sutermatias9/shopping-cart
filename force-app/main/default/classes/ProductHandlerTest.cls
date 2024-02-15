@isTest
public with sharing class ProductHandlerTest {
    @isTest
    static void testGetProducts() {
        insertProducts(20);

        Test.startTest();
        List<Product2> products = ProductHandler.getProducts();
        Test.stopTest();

        Assert.areEqual(20, products.size(), 'Number of products retrieved should match the expected count');
    }

    @isTest
    static void testProductsCreationWithApiCallout() {
        Test.setMock(HttpCalloutMock.class, new StoreCalloutMock());

        ProductHandler.synchronizeProductsFromApi();

        List<Product2> productsCreated = ProductHandler.getProducts();
        List<PricebookEntry> pbeCreated = [SELECT Id FROM PricebookEntry];

        Assert.isTrue(productsCreated.size() > 0, 'Products should be created after callout.');
        Assert.areEqual(productsCreated.size(), pbeCreated.size(), 'All products should have a standard price');
    }

    private static void insertProducts(Integer numberOfProducts) {
        List<Product2> productsToInsert = new List<Product2>();

        for (Integer i = 0; i < numberOfProducts; i++) {
            Product2 product = new Product2(Name = 'Test product ' + i);
            productsToInsert.add(product);
        }

        insert productsToInsert;
    }
}
