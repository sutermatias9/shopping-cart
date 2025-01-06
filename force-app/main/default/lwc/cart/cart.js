import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';
import setCartAsPurchased from '@salesforce/apex/CartHandler.setAsPurchased';

export default class Cart extends LightningElement {
    @api cart;
    isPurchasing = false;

    get cartItems() {
        if (this.cart && this.cart.Cart_Items__r.length > 0) {
            return this.cart.Cart_Items__r;
        }

        return null;
    }

    get grandTotal() {
        if (this.cart) {
            return this.cart.Total_Price__c;
        }

        return 0;
    }

    handleCancelClick() {
        this.fireEvent('cancel');
    }

    async handlePurchaseClick() {
        this.isPurchasing = true;
        await setCartAsPurchased({ userId });
        this.isPurchasing = false;
        this.fireEvent('purchase');
    }

    fireEvent(eventName) {
        this.dispatchEvent(new CustomEvent(eventName));
    }
}
