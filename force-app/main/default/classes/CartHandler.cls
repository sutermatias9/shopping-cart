public with sharing class CartHandler {
    @AuraEnabled
    public static Map<String, List<Cart__c>> getAllCarts() {
        Map<String, List<Cart__c>> cartsByUser = new Map<String, List<Cart__c>>();

        // Group carts by user
        for(Cart__c cart : [SELECT Status__c, Total_Price__c, User__r.Name, Date_Purchased__c,
        (SELECT Quantity__c, Unit_Price__c, Name, Product__r.Image__c FROM Cart_Items__r)
         FROM Cart__c ORDER BY Date_Purchased__c]) {
            String user = cart.User__r.Name;

            if(!cartsByUser.containsKey(user)) {
                cartsByUser.put(user, new List<Cart__c>());
            } 

            cartsByUser.get(user).add(cart);
        }

        return cartsByUser;
    }
    
    @AuraEnabled
    public static Cart__c getActiveCartInfo(Id userId) {
        List<Cart__c> cart = [
            SELECT Id, Total_Price__c, (SELECT Quantity__c, Unit_Price__c, Name, Product__c, Product__r.Image__c FROM Cart_Items__r)
            FROM Cart__c
            WHERE User__c = :userId AND Status__c = 'Active'
        ];

        if (cart.isEmpty()) {
            return null;
        }

        return cart[0];
    }

    @AuraEnabled
    public static void setAsPurchased(Id userId) {
        try {
            Cart__c cart = [SELECT Status__c FROM Cart__c WHERE Status__c = 'Active' AND User__c = :userId];
            cart.Status__c = 'Purchased';
            update cart;
        } catch (QueryException e) {
            throw new AuraHandledException('The user with ID: ' + userId + ' does not have an active cart. ' + e.getMessage());
        }
    }

    public static Cart__c getCart(Id userId, String status) {
        List<Cart__c> cart = [SELECT Id FROM Cart__c WHERE Status__c = :status AND User__c = :userId];

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
