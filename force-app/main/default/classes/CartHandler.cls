public with sharing class CartHandler {
    @AuraEnabled
    public static Cart__c getActiveCartInfo(Id userId) {
        try {
            List<Cart__c> cart = [
                SELECT Id, Total_Price__c, (SELECT Quantity__c, Unit_Price__c, Name, Product__c, Product__r.Image__c FROM Cart_Items__r)
                FROM Cart__c
                WHERE User__c = :userId AND Status__c = 'Active'
            ];

            if (cart.isEmpty()) {
                return null;
            }

            return cart[0];
        } catch (Exception e) {
            throw new AuraHandledException('Error getting cart products' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void setAsPurchased(Id userId) {
        try {
            Cart__c cart = [SELECT Status__c FROM Cart__c WHERE Status__c = 'Active' AND User__c = :userId];
            cart.Status__c = 'Purchased';
            update cart;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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

    public static void updateTotalPrices(List<Id> cartIds) {
        List<Cart__c> cartsToUpdate = new List<Cart__c>();

        for (Cart__c cart : [SELECT Id, Total_Price__c, (SELECT Unit_Price__c, Quantity__c FROM Cart_Items__r) FROM Cart__c WHERE Id IN :cartIds]) {
            Decimal total = 0;

            for (Cart_Item__c item : cart.Cart_Items__r) {
                total += item.Unit_Price__c * item.Quantity__c;
            }

            cart.Total_Price__c = total;
            cartsToUpdate.add(cart);
        }

        update cartsToUpdate;
    }
}
