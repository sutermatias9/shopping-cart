@isTest
public with sharing class CartHandlerTest {
    @isTest
    static void testGetActiveCartInfoInvalidUserId() {
        Cart__c actualResult = CartHandler.getActiveCartInfo('000000000000001');
        Assert.isNull(actualResult);
    }

    @isTest
    static void testGetActiveCartInfoNoActiveCart() {
        Id userId = TestDataFactory.createUser('test', true).Id;

        Test.startTest();
        Cart__c actualResult = CartHandler.getActiveCartInfo(userId);
        Test.stopTest();

        Assert.isNull(actualResult);
    }

    @isTest
    static void testGetActiveCartInfoHasActiveCart() {
        Id userId = TestDataFactory.createUser('test', true).Id;
        TestDataFactory.createCart(userId, 'Active', 3);

        Test.startTest();
        Cart__c actualResult = CartHandler.getActiveCartInfo(userId);
        Test.stopTest();

        Assert.isNotNull(actualResult);
        Assert.isTrue(actualResult.Cart_Items__r.size() > 0);
    }

    @isTest
    static void testSetAsPurchasedNoActiveCart() {
        Id userId = TestDataFactory.createUser('test', true).Id;

        try {
            CartHandler.setAsPurchased(userId);
            Assert.fail('An exception was expected.');
        } catch (Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName());
        }
    }

    @isTest
    static void testSetAsPurchasedHasActiveCart() {
        Id userId = TestDataFactory.createUser('test', true).Id;
        TestDataFactory.createCart(userId, 'Active', 3);

        Test.startTest();
        CartHandler.setAsPurchased(userId);
        Test.stopTest();

        Cart__c cart = [SELECT Status__c FROM Cart__c WHERE User__c = :userId];

        Assert.areEqual('Purchased', cart.Status__c);
    }

    @isTest
    static void testGetCartWithPurchasedStatus() {
        Id userId = TestDataFactory.createUser('test', true).Id;
        TestDataFactory.createCart(userId, 'Purchased', 3);

        Test.startTest();
        Cart__c actualResult = CartHandler.getCart(userId, 'Purchased');
        Test.stopTest();

        Assert.isNotNull(actualResult, 'A cart should be returned.');
    }

    @isTest
    static void testGetCartWhenUserHasNoActiveCart() {
        Id userId = TestDataFactory.createUser('test', true).Id;
        TestDataFactory.createCart(userId, 'Purchased', 3);

        Test.startTest();
        Cart__c actualResult = CartHandler.getCart(userId, 'Active');
        Test.stopTest();

        Assert.isNull(actualResult, 'Null should be returned.');
    }

    @isTest
    static void testCreateCart() {
        Id userId = TestDataFactory.createUser('test', true).Id;

        Test.startTest();
        Cart__c actualResult = CartHandler.createCart(userId);
        Test.stopTest();

        Assert.areEqual(userId, actualResult.User__c);
        Assert.areEqual('Active', actualResult.Status__c, 'The cart status should be active.');
        Assert.isTrue([SELECT Id FROM Cart__c WHERE User__c = :userId AND Status__c = 'Active'].size() > 0, 'The active cart should be inserted.');
    }

    @isTest
    static void testUpdateTotalPrices() {
        Id with3ItemsId = TestDataFactory.createUser('test', true).Id;
        Id noItemsId = TestDataFactory.createUser('test', true).Id;

        List<Id> cartIds = new List<Id>{
            TestDataFactory.createCart(with3ItemsId, 'Purchased', 3).Id,
            TestDataFactory.createCart(with3ItemsId, 'Active', 3).Id,
            TestDataFactory.createCart(noItemsId, 'Active', 0).Id
        };

        Test.startTest();
        CartHandler.updateTotalPrices(cartIds);
        Test.stopTest();

        List<Cart_Item__c> items = [SELECT Id, Cart__c, Quantity__c, Unit_Price__c FROM Cart_Item__c];

        for (Cart__c cart : [SELECT Id, Total_Price__c FROM Cart__c]) {
            Decimal expectedTotal = 0;

            for (Cart_Item__c item : items) {
                if (item.Cart__c == cart.Id) {
                    expectedTotal += item.Quantity__c * item.Unit_Price__c;
                }
            }

            Assert.areEqual(
                expectedTotal,
                cart.Total_Price__c,
                'The total price of the cart with Id ' + cart.Id + ' should be ' + expectedTotal + ' but was ' + cart.Total_Price__c
            );
        }
    }
}
