public with sharing class CartItemHandler {
    @AuraEnabled
    public static void addToCart(Id userId, Id productId, Integer quantity) {
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
