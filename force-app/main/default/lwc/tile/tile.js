import { LightningElement, api } from 'lwc';

export default class Tile extends LightningElement {
    @api product;

    get productPrice() {
        return this.product.PricebookEntries[0].UnitPrice;
    }
}
