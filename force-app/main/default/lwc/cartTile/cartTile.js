import { LightningElement, api } from 'lwc';

export default class CartTile extends LightningElement {
    @api item;
    quantity;

    get price() {
        return (this.quantity * this.item.Unit_Price__c).toFixed(2);
    }

    connectedCallback() {
        this.quantity = this.item.Quantity__c;
    }

    handleCounterChange(event) {
        this.quantity = event.detail;
    }
}
