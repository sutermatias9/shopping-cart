import { LightningElement, wire, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductHandler.getProducts';

const CATEGORIES = ["Women's Clothing", "Men's Clothing", 'Jewelery', 'Electronics'];

export default class Shopping extends LightningElement {
    products;
    selectedProduct;

    /**
     * @type {Object} filters - Holds the filter criteria applied by the user
     */
    filters = null;
    productCategories = CATEGORIES;

    // Flags to control modals
    isProductDetailOpen = false;
    isCartOpen = false;

    @track cartProducts = [];

    error;

    /**
     * @wire - Gets all the products in the org using the getProducts wire adapter.
     * @param {Object} param0- Data and error properties returned by the adapter.
     */
    @wire(getProducts)
    wiredProducts({ data, error }) {
        if (data) {
            this.products = data;
        } else {
            this.error = error;
        }
    }

    /**
     * @computed - Computes the list of products based on the applied filters.
     * @returns {Array} - List of products to display.
     */
    get productsToShow() {
        if (this.filters !== null) {
            return this.getFilteredProducts();
        }

        return this.products;
    }

    /**
     * @computed - Calculates the highest price among available products, to use in filters.
     * @returns {Number} - The rounded highest unit price.
     */
    get highestPrice() {
        if (this.products) {
            const price = this.products.reduce((maxPrice, product) => {
                const unitPrice = this.getPrice(product);
                return Math.max(maxPrice, unitPrice);
            }, 0);

            return Math.round(price);
        }

        return 0;
    }

    get isProductInCart() {
        if (this.isProductDetailOpen) {
            return this.cartProducts.some((cartProduct) => cartProduct.Name === this.selectedProduct.Name);
        }

        return false;
    }

    handleApplyFiltersClick(event) {
        this.filters = event.detail;
    }

    handleModalClose(event) {
        const modalType = event.currentTarget.classList.contains('cart') ? 'cart' : 'product';

        this.closeModal(modalType);
    }

    handleProductSelect(event) {
        this.selectedProduct = event.detail;
        console.log('SELECTED: ', JSON.stringify(this.selectedProduct));
        this.showModal('product');
    }

    handleViewCart() {
        this.showModal('cart');
    }

    handleAddToCart(event) {
        const productData = event.detail;

        this.cartProducts.push(productData);
    }

    handleRemoveFromCart(event) {
        const productName = event.detail;

        this.cartProducts = this.cartProducts.filter((product) => product.Name !== productName);
    }

    handleCartCancel() {
        this.closeModal('cart');
    }

    getPrice(product) {
        return product.PricebookEntries[0].UnitPrice;
    }

    /**
     * @function getFilteredProducts
     * @description Filters the products based on the applied filters
     * @returns {Array} - Products that meet the filter criteria
     */
    getFilteredProducts() {
        const { maxPrice, minPrice, category } = this.filters;

        return this.products.filter((product) => {
            const meetsCategoryCriteria = this.meetsCategoryCriteria(product, category);
            const meetsPriceCriteria = this.meetsPriceCriteria(product, minPrice, maxPrice);

            return meetsCategoryCriteria && meetsPriceCriteria;
        });
    }

    meetsCategoryCriteria(product, category) {
        return category === null || product.Family === category;
    }

    meetsPriceCriteria(product, minPrice, maxPrice) {
        const price = this.getPrice(product);

        return price >= minPrice && price < maxPrice;
    }

    showModal(modal) {
        if (modal === 'cart') {
            this.isCartOpen = true;
        } else {
            this.isProductDetailOpen = true;
        }
    }

    closeModal(modalType) {
        if (modalType === 'cart') {
            this.isCartOpen = false;
        } else {
            this.isProductDetailOpen = false;
        }
    }
}
