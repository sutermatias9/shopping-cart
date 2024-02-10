import { LightningElement, api } from 'lwc';

/**
 * @constant {Array} COLUMNS - An array of columns configurations for the cart table.
 */
const COLUMNS = [
    { label: 'Product Name', fieldName: 'Name' },
    {
        label: 'Quantity',
        fieldName: 'Quantity',
        cellAttributes: { alignment: 'center' },
        fixedWidth: 80,
        hideDefaultActions: true
    },
    {
        label: 'Total Price',
        fieldName: 'TotalPrice',
        type: 'currency',
        cellAttributes: { alignment: 'center' },
        fixedWidth: 90,
        hideDefaultActions: true
    }
];

export default class Cart extends LightningElement {
    @api cartProducts = [];

    tableColumns = COLUMNS;

    get tableData() {
        return this.cartProducts.map((product) => {
            return {
                Name: product.Name,
                Quantity: product.Quantity,
                TotalPrice: product.Quantity * product.Price
            };
        });
    }

    get grandTotal() {
        return this.tableData
            .reduce((accumulator, currentValue) => accumulator + currentValue.TotalPrice, 0)
            .toFixed(2);
    }

    handleCancelClick() {
        this.fireCancelEvent();
    }

    fireCancelEvent() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}
