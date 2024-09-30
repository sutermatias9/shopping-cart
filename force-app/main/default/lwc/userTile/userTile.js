import { LightningElement, api } from 'lwc';

export default class UserTile extends LightningElement {
    @api userName;
    @api totalSpent;
    @api currentCart; // Current cart number of items and total amount

    get numberOfItems() {
        if (this.currentCart) {
            return this.currentCart.numberOfItems;
        }

        return 0;
    }

    get currentCartAmount() {
        if (this.currentCart) {
            return this.currentCart.totalAmount;
        }

        return 0;
    }
}
