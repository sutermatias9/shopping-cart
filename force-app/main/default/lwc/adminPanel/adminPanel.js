import { LightningElement } from 'lwc';
import getAllCarts from '@salesforce/apex/CartHandler.getAllCarts';

export default class AdminPanel extends LightningElement {
    filteredUserCarts;
    allUserCarts;

    isUserCartsModalOpen = false;
    userCartsTree;

    searchTimeout;

    connectedCallback() {
        this.loadCarts();
    }

    handleSearchChange(event) {
        const userInput = event.currentTarget.value.toLowerCase();

        clearTimeout(this.searchTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimeout = setTimeout(() => {
            this.filteredUserCarts = this.allUserCarts.filter((userCart) => userCart.userName.toLowerCase().includes(userInput));
        }, 300);
    }

    handleTileClick(event) {
        this.isUserCartsModalOpen = true;
        const user = event.currentTarget.userName;
        const carts = this.filteredUserCarts.find((userCart) => userCart.userName === user).carts;

        this.createTreeItems(carts);
    }

    handleModalClose() {
        this.isUserCartsModalOpen = false;
    }

    handleCloseClick() {
        this.isUserCartsModalOpen = false;
    }

    async loadCarts() {
        const cartsByUser = await getAllCarts();

        this.allUserCarts = Object.keys(cartsByUser).map((userName) => {
            return {
                userName,
                activeCart: this.getActiveCartInfo(cartsByUser[userName]),
                totalSpent: this.getPurchasedCartsTotalAmount(cartsByUser[userName]),
                carts: cartsByUser[userName]
            };
        });

        this.filteredUserCarts = this.allUserCarts;
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

    createTreeItems(carts) {
        this.userCartsTree = carts.map((cart, index) => {
            const label =
                cart.Status__c === 'Active'
                    ? `Current Cart | Total: $${cart.Total_Price__c}`
                    : `Cart ${index} | Total: $${cart.Total_Price__c} | Purchase date: ${cart.Date_Purchased__c}`;

            const items = cart.Cart_Items__r.map((item) => {
                return {
                    label: `${item.Quantity__c}x ${item.Name}`,
                    name: item.Name,
                    metatext: `$${item.Quantity__c * item.Unit_Price__c}`
                };
            });

            return { label, items };
        });
    }
}
