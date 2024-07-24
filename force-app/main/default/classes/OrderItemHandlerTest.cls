@isTest
public with sharing class OrderItemHandlerTest {
    @TestSetup
    static void makeData() {
        Id userId = TestDataFactory.createUser('test user', true).Id;
        TestDataFactory.createCart(userId, 'Purchased', 3);
        Cart__c cart = TestDataFactory.createCart(userId, 'Active', 5);
        TestDataFactory.createOrder(cart, userId, true);
    }

    @isTest
    static void testCreateRecord() {
        Id userId = [SELECT Id FROM User WHERE LastName = 'test user'].Id;
        Id orderId = [SELECT Id FROM Order__c WHERE User__c = :userId].Id;
        Cart__c cart = [
            SELECT Id, (SELECT Name, Product__c, Unit_Price__c, Quantity__c FROM Cart_Items__r)
            FROM Cart__c
            WHERE Status__c = :'Active' AND User__c = :userId
        ];

        Test.startTest();
        List<Order_Item__c> actualResult = new List<Order_Item__c>();

        for (Cart_Item__c item : cart.Cart_Items__r) {
            actualResult.add(OrderItemHandler.createRecord(orderId, item));
        }
        Test.stopTest();

        Integer expectedSize = cart.Cart_Items__r.size();
        Integer actualSize = actualResult.size();

        Assert.isTrue(actualSize > 0, 'Order Items should be created.');
        Assert.areEqual(expectedSize, actualSize, 'Expected number of order items: ' + expectedSize + ', but was: ' + actualSize);
    }
}
