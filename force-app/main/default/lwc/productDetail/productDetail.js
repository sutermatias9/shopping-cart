import { LightningElement, api } from 'lwc';

export default class ProductDetail extends LightningElement {
    /**
     * @type {Object} product - The product details to be displayed.
     */
    @api product;
    @api isInCart;
    @api disabled;

    quantity = 1;

    get productPrice() {
        if (this.product) {
            return this.product.PricebookEntries[0].UnitPrice;
        }

        return 0;
    }

    handleCounterChange(event) {
        this.quantity = event.detail;
    }

    handleAddToCartClick() {
        this.fireCustomEvent('addtocart', {
            productId: this.product.Id,
            quantity: this.quantity
        });
    }

    handleCartRemoveClick() {
        this.fireCustomEvent('removefromcart', this.product.Id);
    }

    fireCustomEvent(eventName, detail) {
        this.dispatchEvent(new CustomEvent(eventName, { detail }));
    }
}
