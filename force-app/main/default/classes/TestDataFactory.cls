@isTest
public with sharing class TestDataFactory {
    public static User createUser(Boolean doInsert) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        User u = new user();
        u.LastName = 'Test User';
        u.Email = 'suter@gmail.com';
        u.Alias = 'Tuser';
        u.Username = 'suter' + System.currentTimeMillis() + '@gmail.com';
        u.CommunityNickname = 'test' + System.currentTimeMillis();
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = profileId;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';

        if (doInsert) {
            insert u;
        }

        return u;
    }

    public static Cart__c createCart(Id userId, String status, Integer numberOfItems) {
        Cart__c record = new Cart__c();
        record.Status__c = status;
        record.User__c = userId;

        insert record;

        if (numberOfItems > 0) {
            createCartItems(record.Id, numberOfItems, true);
        }

        return record;
    }

    public static List<Cart_Item__c> createCartItems(Id cartId, Integer numberOfItems, Boolean doInsert) {
        List<Cart_Item__c> cartItems = new List<Cart_Item__c>();

        List<Product2> products = createProducts(numberOfItems, true);

        for (Integer i = 0; i < numberOfItems; i++) {
            Cart_Item__c item = new Cart_Item__c();
            item.Cart__c = cartId;
            item.Quantity__c = 250;
            item.Unit_Price__c = 3499.99;
            item.Product__c = products[i].Id;

            cartItems.add(item);
        }

        if (doInsert) {
            insert cartItems;
        }

        return cartItems;
    }

    public static List<Product2> createProducts(Integer numberOfProducts, Boolean doInsert) {
        List<String> familyValues = new List<String>{ 'men\'s clothing', 'jewelery', 'electronics', 'women\'s clothing' };
        List<Product2> productRecords = new List<Product2>();

        for (Integer i = 0; i < numberOfProducts; i++) {
            Product2 product = new Product2(Name = 'Test product ' + i);
            product.Family = familyValues[Math.floor(Math.random() * familyValues.size())];
            productRecords.add(product);
        }

        if (doInsert) {
            insert productRecords;
        }

        return productRecords;
    }

    public static PricebookEntry createPricebookEntry(Id productId, Id pricebookId, Boolean doInsert) {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = productId;
        pbe.Pricebook2Id = pricebookId;
        pbe.UnitPrice = 100;

        if (doInsert) {
            insert pbe;
        }

        return pbe;
    }
}
