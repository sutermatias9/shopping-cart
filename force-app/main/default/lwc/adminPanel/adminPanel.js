import { LightningElement } from 'lwc';
import getAllCarts from '@salesforce/apex/CartHandler.getAllCarts';

export default class AdminPanel extends LightningElement {
    userCarts;

    connectedCallback() {
        this.loadCarts();
    }

    async loadCarts() {
        const cartsByUser = await getAllCarts();

        this.userCarts = Object.keys(cartsByUser).map((userName) => {
            return {
                userName,
                currentCart: this.getCurrentCartInfo(cartsByUser[userName].find((cart) => cart.Status__c === 'Active')),
                totalSpent: this.getPurchasedCartsTotalAmount(cartsByUser[userName].filter((cart) => cart.Status__c === 'Purchased'))
            };
        });
    }

    getCurrentCartInfo(cart) {
        const info = { numberOfItems: 0, totalAmount: 0 };

        if (cart) {
            info.numberOfItems = cart.Cart_Items__r.length;
            info.totalAmount = this.getCartTotal(cart);
        }

        return info;
    }

    getPurchasedCartsTotalAmount(purchasedCarts) {
        return purchasedCarts.reduce((accumulator, cart) => {
            return accumulator + parseFloat(this.getCartTotal(cart));
        }, 0);
    }

    getCartTotal(cart) {
        const sum = cart.Cart_Items__r.reduce((accumulator, item) => {
            return accumulator + item.Unit_Price__c;
        }, 0);
        return sum.toFixed(2);
    }
}
