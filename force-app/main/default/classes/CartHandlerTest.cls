@isTest
public with sharing class CartHandlerTest {
    @isTest
    static void testGetActiveCartInfoInvalidUserId() {
        Cart__c actualResult = CartHandler.getActiveCartInfo('000000000000001');
        Assert.isNull(actualResult);
    }

    @isTest
    static void testGetActiveCartInfoNoActiveCart() {
        Id userId = TestDataFactory.createUser(true).Id;

        Test.startTest();
        Cart__c actualResult = CartHandler.getActiveCartInfo(userId);
        Test.stopTest();

        Assert.isNull(actualResult);
    }

    @isTest
    static void testGetActiveCartInfoHasActiveCart() {
        Id userId = TestDataFactory.createUser(true).Id;
        TestDataFactory.createCart(userId, 'Active', 3);

        Test.startTest();
        Cart__c actualResult = CartHandler.getActiveCartInfo(userId);
        Test.stopTest();

        Assert.isNotNull(actualResult);
        Assert.isTrue(actualResult.Cart_Items__r.size() > 0);
    }

    @isTest
    static void testSetAsPurchasedNoActiveCart() {
        Id userId = TestDataFactory.createUser(true).Id;

        try {
            CartHandler.setAsPurchased(userId);
            Assert.fail('An exception was expected.');
        } catch (Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName());
        }
    }

    @isTest
    static void testSetAsPurchasedHasActiveCart() {
        Id userId = TestDataFactory.createUser(true).Id;
        TestDataFactory.createCart(userId, 'Active', 3);

        Test.startTest();
        CartHandler.setAsPurchased(userId);
        Test.stopTest();

        Cart__c cart = [SELECT Status__c FROM Cart__c WHERE User__c = :userId];

        Assert.areEqual('Purchased', cart.Status__c);
    }
}
