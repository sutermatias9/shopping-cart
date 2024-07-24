@isTest
public with sharing class ProductHandlerTest {
    @TestSetup
    static void makeData() {
        Integer numberOfProducts = 100;

        List<Product2> products = TestDataFactory.createProducts(numberOfProducts, true);
        List<PricebookEntry> entries = new List<PricebookEntry>();

        for (Product2 p : products) {
            entries.add(TestDataFactory.createPricebookEntry(p.Id, Test.getStandardPricebookId(), false));
        }

        insert entries;
    }

    @isTest
    static void testGetProductsWithNoCondition() {
        Test.startTest();
        List<Product2> result = ProductHandler.getProducts('Name, Description', null);
        Test.stopTest();

        Assert.areEqual(100, result.size(), 'The method should return 100 products.');

        for (Product2 product : result) {
            Assert.isTrue(product.PricebookEntries.size() > 0, 'A PricebookEntry record should be associated with the product.');
        }
    }

    @isTest
    static void testGetProductsWithCondition() {
        Test.startTest();
        List<Product2> result = ProductHandler.getProducts('Name, Description, Family', 'Family = \'electronics\'');
        Test.stopTest();

        for (Product2 product : result) {
            Assert.isTrue(product.PricebookEntries.size() > 0, 'A PricebookEntry record should be associated with the product.');
            Assert.areEqual('electronics', product.Family, 'Expected product family to be "electronics"');
        }
    }

    @isTest
    static void testProductsCreationWithApiCallout() {
        delete [SELECT Id FROM Product2];
        delete [SELECT Id FROM PricebookEntry];

        Test.setMock(HttpCalloutMock.class, new StoreCalloutMock());

        Test.startTest();
        ProductHandler.synchronizeProductsFromApi();
        Test.stopTest();

        List<Product2> productsCreated = ProductHandler.getProducts('Id', null);
        List<PricebookEntry> pbeCreated = [SELECT Id FROM PricebookEntry];

        Assert.isTrue(productsCreated.size() > 0, 'Products should be created after callout.');
        Assert.areEqual(productsCreated.size(), pbeCreated.size(), 'All products should have a standard price');
    }
}
