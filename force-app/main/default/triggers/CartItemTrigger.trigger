trigger CartItemTrigger on Cart_Item__c(after insert) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CartItemHandler.handleAfterInsert(Trigger.New);
        }
    }
}
