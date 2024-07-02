public with sharing class CartItemHandler {
    @AuraEnabled
    public static void addToCart(Id productId, Integer quantity, Id userId) {
        try {
            Cart__c cart = CartHandler.getCart(userId, 'Active');

            if (cart == null) {
                cart = CartHandler.createCart(userId);
            }

            createRecord(cart.Id, productId, quantity);
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + '-> Error adding to cart: ' + e.getMessage());
        }
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

    public static void handleAfterInsert(List<Cart_Item__c> triggerNew) {
        List<Id> cartIds = new List<Id>();

        for (Cart_Item__c item : triggerNew) {
            cartIds.add(item.Cart__c);
        }

        CartHandler.updateTotalPrices(cartIds);
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
}
