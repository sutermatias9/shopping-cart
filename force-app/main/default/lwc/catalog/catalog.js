import { LightningElement, api } from 'lwc';

export default class Catalog extends LightningElement {
    @api products;
    @api cartProducts;

    handleTileClick(event) {
        const productSelected = event.currentTarget.product;

        this.fireEvent('productselect', productSelected);
    }

    handleCartIconClick() {
        this.fireEvent('viewcart');
    }

    fireEvent(eventName, detail) {
        const event = new CustomEvent(eventName, { detail });

        this.dispatchEvent(event);
    }
}
