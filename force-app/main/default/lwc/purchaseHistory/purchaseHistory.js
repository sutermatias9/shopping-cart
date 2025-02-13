import { LightningElement, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import getUserPurchasedCarts from '@salesforce/apex/CartHandler.getUserPurchasedCarts';

export default class PurchaseHistory extends LightningElement {
    userCarts = null;
    selectedCartProducts = null;

    @wire(getUserPurchasedCarts, { userId })
    wiredGetUserPurchasedCarts({ data, error }) {
        if (data) {
            console.log(JSON.stringify(data));

            // Add number of items and format purchase date
            this.userCarts = data.map((cart) => {
                const Date_Purchased__c = this.formatDate(cart.Date_Purchased__c);
                const numberOfItems = cart.Cart_Items__r.reduce((accumulator, item) => accumulator + item.Quantity__c, 0);

                return { ...cart, numberOfItems, Date_Purchased__c };
            });
        }
        if (error) {
            console.log('ERROR ' + JSON.stringify(error));
            console.error(error);
        }
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
