import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';
import createOrder from '@salesforce/apex/OrderHandler.createOrder';
import setCartAsPurchased from '@salesforce/apex/CartHandler.setAsPurchased';

export default class Cart extends LightningElement {
    @api cart;
    isCreating = false;

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
