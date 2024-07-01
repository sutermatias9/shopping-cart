public with sharing class PricebookEntryHandler {
    public static PricebookEntry createRecord(Id productId, Id pricebookId, Decimal price) {
        PricebookEntry record = new PricebookEntry();

        record.UnitPrice = price;
        record.Pricebook2Id = pricebookId;
        record.Product2Id = productId;
        record.IsActive = true;

        return record;
    }
}
