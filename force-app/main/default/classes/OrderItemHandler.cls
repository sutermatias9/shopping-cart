public with sharing class OrderItemHandler {
    public static Order_Item__c createRecord(Id orderId, Cart_Item__c cartItem) {
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = orderId;
        orderItem.Name = cartItem.Name;
        orderItem.Product__c = cartItem.Product__c;
        orderItem.Unit_Price__c = cartItem.Unit_Price__c;
        orderItem.Quantity__c = cartItem.Quantity__c;

        return orderItem;
    }
}
