import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';
import createOrder from '@salesforce/apex/OrderHandler.createOrder';
import setCartAsPurchased from '@salesforce/apex/CartHandler.setAsPurchased';

export default class Cart extends LightningElement {
    @api cart;
    isCreating = false;

    get cartItems() {
        if (this.cart) {
            return this.cart.Cart_Items__r;
        }

        return [];
    }

    get grandTotal() {
        if (this.cart) {
            return this.cart.Total_Price__c;
        }

        return 0;
    }

    handleCancelClick() {
        this.fireCancelEvent();
    }

    async handleCreateClick() {
        this.isCreating = true;
        await createOrder({ userId });
        await setCartAsPurchased({ userId });
        this.isCreating = false;
    }

    fireCancelEvent() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}
