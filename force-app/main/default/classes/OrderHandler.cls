public with sharing class OrderHandler {
    @AuraEnabled
    public static void createOrder(Id userId) {
        Cart__c cart = CartHandler.getActiveCartInfo(userId);

        Order__c order = new Order__c();
        order.Total_Price__c = cart.Total_Price__c;
        order.Order_Date__c = Datetime.now();
        order.User__c = userId;

        insert order;

        List<Order_Item__c> orderItems = new List<Order_Item__c>();

        for (Cart_Item__c item : cart.Cart_Items__r) {
            orderItems.add(OrderItemHandler.createRecord(order.Id, item));
        }

        insert orderItems;
    }
}
