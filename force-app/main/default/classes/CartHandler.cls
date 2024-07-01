public with sharing class CartHandler {
    @AuraEnabled
    public static List<Id> getCartProductIds(Id userId) {
        try {
            List<Id> productsId = new List<Id>();
            List<Cart__c> cart = [
                SELECT Id, (SELECT Product__c FROM Cart_Items__r)
                FROM Cart__c
                WHERE User__c = :userId AND Status__c = 'Active'
            ];

            if (!cart.isEmpty()) {
                for (Cart_Item__c item : cart[0].Cart_Items__r) {
                    System.debug(item);
                    productsId.add(item.Product__c);
                }
            }

            return productsId;
        } catch (Exception e) {
            throw new AuraHandledException('Error getting cart products' + e.getMessage());
        }
    }

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
        return record;
    }
}
