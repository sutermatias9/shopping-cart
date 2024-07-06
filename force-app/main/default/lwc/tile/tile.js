import { LightningElement, api } from 'lwc';

export default class Tile extends LightningElement {
    @api product;
    @api cartProducts;

    get isInCart() {
        if (this.cartProducts) {
            return this.cartProducts.some((cartProduct) => cartProduct.Product__c === this.product.Id);
        }

        return false;
    }

    get productPrice() {
        return this.product.PricebookEntries[0].UnitPrice;
    }
}
