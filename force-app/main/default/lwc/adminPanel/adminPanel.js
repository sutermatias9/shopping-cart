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
                activeCart: this.getActiveCartInfo(cartsByUser[userName]),
                totalSpent: this.getPurchasedCartsTotalAmount(cartsByUser[userName])
            };
        });
    }

    getActiveCartInfo(carts) {
        const activeCart = carts.find((cart) => cart.Status__c === 'Active');
        const info = { numberOfItems: 0, totalAmount: 0 };

        if (activeCart && activeCart.Cart_Items__r) {
            info.numberOfItems = activeCart.Cart_Items__r.reduce((total, item) => total + item.Quantity__c, 0);

            info.totalAmount = this.calculateCartTotal(activeCart.Cart_Items__r).toFixed(2);
        }

        return info;
    }

    getPurchasedCartsTotalAmount(carts) {
        const purchasedCarts = carts.filter((cart) => cart.Status__c === 'Purchased');

        return purchasedCarts
            .reduce((accumulator, cart) => {
                return accumulator + this.calculateCartTotal(cart.Cart_Items__r);
            }, 0)
            .toFixed(2);
    }

    calculateCartTotal(items) {
        return items.reduce((accumulator, item) => {
            return accumulator + item.Quantity__c * item.Unit_Price__c;
        }, 0);
    }
}
