public with sharing class CartItemHandler {
    @AuraEnabled
    public static void addToCart(Id productId, Integer quantity, Id userId) {
        Cart__c cart = CartHandler.getCart(userId, 'Active');

        if (cart == null) {
            cart = CartHandler.createCart(userId);
        }

        createRecord(cart.Id, productId, quantity);
    }

    @AuraEnabled
    public static void removeFromCart(Id productId, Id userId) {
        try {
            Cart_Item__c item = [
                SELECT Id
                FROM Cart_Item__c
                WHERE Product__c = :productId AND Cart__r.User__c = :userId AND Cart__r.Status__c = 'Active'
                LIMIT 1
            ];

            delete item;
        } catch (Exception e) {
            throw new AuraHandledException('Error removing from cart: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateQuantity(Id itemId, Integer quantity) {
        try {
            Cart_Item__c item = [SELECT Quantity__c FROM Cart_Item__c WHERE Id = :itemId];
            item.Quantity__c = quantity;

            update item;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void handleAfterInsert(List<Cart_Item__c> triggerNew) {
        updateCartTotalPrice(triggerNew);
    }

    public static void handleAfterUpdate(List<Cart_Item__c> triggerNew) {
        updateCartTotalPrice(triggerNew);
    }

    public static void handleAfterDelete(List<Cart_Item__c> triggerOld) {
        updateCartTotalPrice(triggerOld);
    }

    private static Cart_Item__c createRecord(Id cartId, Id productId, Integer quantity) {
        Product2 product = ProductHandler.getProducts('Name', 'Id = \'' + productId + '\'')[0];

        Cart_Item__c record = new Cart_Item__c();
        record.Cart__c = cartId;
        record.Name = product.Name;
        record.Product__c = productId;
        record.Unit_Price__c = product.PricebookEntries[0].UnitPrice;
        record.Quantity__c = quantity;

        insert record;
        return record;
    }

    private static void updateCartTotalPrice(List<Cart_Item__c> items) {
        List<Id> cartIds = new List<Id>();

        for (Cart_Item__c item : items) {
            cartIds.add(item.Cart__c);
        }

        CartHandler.updateTotalPrices(cartIds);
    }
}
