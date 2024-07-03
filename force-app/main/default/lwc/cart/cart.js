import { LightningElement, api } from 'lwc';

export default class Cart extends LightningElement {
    @api cart = [];

    handleCancelClick() {
        this.fireCancelEvent();
    }

    fireCancelEvent() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}
