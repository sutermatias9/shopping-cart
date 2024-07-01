public with sharing class CartHandler {
    public static Cart__c getCart(Id userId, String status) {
        List<Cart__c> cart = [SELECT Id FROM Cart__c WHERE Status__c = :status];

        if (cart.isEmpty()) {
            return null;
        }

        return cart[0];
    }

    public static Cart__c createCart(Id userId) {
        Cart__c record = new Cart__c(User__c = userId, Status__c = 'Active');

        insert record;
    }
}
