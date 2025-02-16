import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import userId from '@salesforce/user/Id';
import getUserPurchasedCarts from '@salesforce/apex/CartHandler.getUserPurchasedCarts';

export default class PurchaseHistory extends LightningElement {
    userCarts = null;
    selectedCartProducts = null;

    userPurchasedCartsResult = null; // used to refresh

    @wire(getUserPurchasedCarts, { userId })
    wiredGetUserPurchasedCarts(result) {
        this.userPurchasedCartsResult = result;

        if (result.data) {
            // Add number of items and format purchase date
            this.userCarts = result.data.map((cart) => {
                const Date_Purchased__c = this.formatDate(cart.Date_Purchased__c);
                const numberOfItems = cart.Cart_Items__r.reduce((accumulator, item) => accumulator + item.Quantity__c, 0);

                return { ...cart, numberOfItems, Date_Purchased__c };
            });
        }
        if (result.error) {
            console.log('ERROR ' + JSON.stringify(result.error));
            console.error(result.error);
        }
    }

    connectedCallback() {
        refreshApex(this.userPurchasedCartsResult);
    }

    handleRowClick(event) {
        this.clearPreviousSelectedRow();

        const row = event.currentTarget;
        const cartId = row.dataset.id;

        row.classList.add('selected');
        this.selectedCartProducts = this.userCarts.find((c) => c.Id === cartId).Cart_Items__r;

        // Show cart products
        this.template.querySelector('.selected + tr').classList.remove('hide');
    }

    clearPreviousSelectedRow() {
        this.template.querySelector('.selected + tr')?.classList.add('hide');
        this.template.querySelector('.selected')?.classList.remove('selected');
    }

    formatDate(date) {
        const options = { month: 'short', day: 'numeric', year: 'numeric' };
        const d = new Date(date);

        return d.toLocaleDateString('en-US', options);
    }
}
