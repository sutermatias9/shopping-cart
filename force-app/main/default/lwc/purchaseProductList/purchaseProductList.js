import { LightningElement, api } from 'lwc';

export default class PurchaseProductList extends LightningElement {
    _products;

    @api
    set products(value) {
        this._products = value.map((product) => {
            const total = product.Unit_Price__c * product.Quantity__c;
            return { ...product, total };
        });
    }

    get products() {
        return this._products;
    }
}
