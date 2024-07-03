import { LightningElement, api } from 'lwc';
import updateQuantity from '@salesforce/apex/CartItemHandler.updateQuantity';

export default class CartTile extends LightningElement {
    @api item;
    quantity;
    isUpdating;

    get price() {
        return (this.quantity * this.item.Unit_Price__c).toFixed(2);
    }

    connectedCallback() {
        this.quantity = this.item.Quantity__c;
    }

    async handleCounterChange(event) {
        this.isUpdating = true;
        this.quantity = event.detail;

        await updateQuantity({ itemId: this.item.Id, quantity: this.quantity });
        this.fireEvent('update');

        this.isUpdating = false;
    }

    handleRemoveClick() {
        this.fireEvent('remove', this.item.Product__c);
    }

    fireEvent(name, detail) {
        const event = new CustomEvent(name, { detail, bubbles: true, composed: true });
        this.dispatchEvent(event);
    }
}
