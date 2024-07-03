trigger CartItemTrigger on Cart_Item__c(after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CartItemHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            CartItemHandler.handleAfterUpdate(Trigger.new);
        } else if (Trigger.isDelete) {
            CartItemHandler.handleAfterDelete(Trigger.old);
        }
    }
}
