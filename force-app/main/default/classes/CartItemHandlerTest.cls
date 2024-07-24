@isTest
public with sharing class CartItemHandlerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.createUser('No Carts', true);

        List<Product2> products = TestDataFactory.createProducts(4, true);
        List<PricebookEntry> pbes = new List<PricebookEntry>();

        for (Product2 p : products) {
            pbes.add(TestDataFactory.createPricebookEntry(p.Id, Test.getStandardPricebookId(), false));
        }

        insert pbes;

        User userWithCart = TestDataFactory.createUser('Active Cart 3 item', true);

        TestDataFactory.createCart(userWithCart.Id, 'Active', 3);
    }

    @isTest
    static void testAddToCartUserCreatesCart() {
        Id userId = [SELECT Id FROM User WHERE LastName = 'No Carts'].Id;
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Integer quantity = 20;

        Test.startTest();
        CartItemHandler.addToCart(productId, quantity, userId);
        Test.stopTest();

        Cart__c cart = [SELECT Id, Status__c FROM Cart__c WHERE Status__c = 'Active' AND User__c = :userId];
        Cart_Item__c cartItem = [SELECT Id, Unit_Price__c, Quantity__c, Product__c FROM Cart_Item__c WHERE Cart__c = :cart.Id];
        PricebookEntry pbe = [SELECT UnitPrice FROM PricebookEntry WHERE Product2Id = :productId];

        Assert.areEqual('Active', cart.Status__c, 'An active cart should be created.');
        Assert.areEqual(
            pbe.UnitPrice,
            cartItem.Unit_Price__c,
            'The cart item price should be $' + pbe.UnitPrice + ' but was $' + cartItem.Unit_Price__c
        );
        Assert.areEqual(quantity, cartItem.Quantity__c, 'Expected cart item quantity: ' + quantity + ', but was: ' + cartItem.Quantity__c);
    }

    @isTest
    static void testAddToCartUserHasActiveCart() {
        Id userId = [SELECT Id FROM User WHERE LastName = 'Active Cart 3 item'].Id;
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Integer quantity = 20;

        Test.startTest();
        CartItemHandler.addToCart(productId, quantity, userId);
        Test.stopTest();

        Cart__c cart = [SELECT Id, Status__c FROM Cart__c WHERE Status__c = 'Active' AND User__c = :userId];
        List<Cart_Item__c> cartItems = [SELECT Id, Unit_Price__c, Quantity__c, Product__c FROM Cart_Item__c WHERE Cart__c = :cart.Id];
        PricebookEntry pbe = [SELECT UnitPrice FROM PricebookEntry WHERE Product2Id = :productId];

        Assert.isTrue(cartItems.size() == 4, 'The cart should have 4 items.');

        for (Cart_Item__c item : cartItems) {
            if (item.Product__c == productId) {
                Assert.areEqual(
                    pbe.UnitPrice,
                    item.Unit_Price__c,
                    'The cart item price should be $' + pbe.UnitPrice + ' but was $' + item.Unit_Price__c
                );
                Assert.areEqual(quantity, item.Quantity__c, 'Expected cart item quantity: ' + quantity + ', but was: ' + item.Quantity__c);
            }
        }
    }

    @isTest
    static void testRemoveFromCart() {
        Id userId = [SELECT Id FROM User WHERE LastName = 'Active Cart 3 item'].Id;
        Id cartId = [SELECT Id FROM Cart__c WHERE User__c = :userId AND Status__c = 'Active'].Id;
        Id productId = [SELECT Product__c FROM Cart_Item__c WHERE Cart__c = :cartId LIMIT 1].Product__c;

        Test.startTest();
        CartItemHandler.removeFromCart(productId, userId);
        Test.stopTest();

        Cart__c cart = [SELECT Id, (SELECT Id, Product__c FROM Cart_Items__r) FROM Cart__c WHERE Status__c = 'Active' AND User__c = :userId];

        for (Cart_Item__c item : cart.Cart_Items__r) {
            Assert.areNotEqual(productId, item.Product__c);
        }
    }
}
