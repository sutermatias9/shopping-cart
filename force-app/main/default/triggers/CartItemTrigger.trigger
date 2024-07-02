trigger CartItemTrigger on Cart_Item__c(after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CartItemHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isDelete) {
            CartItemHandler.handleAfterDelete(Trigger.old);
        }
    }
}
