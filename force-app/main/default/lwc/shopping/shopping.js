import { LightningElement, wire, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductHandler.getProducts';

const CATEGORIES = ["Women's Clothing", "Men's Clothing", 'Jewelery', 'Electronics'];

export default class Shopping extends LightningElement {
    allProducts;
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
            this.allProducts = data;
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

        return this.allProducts;
    }

    /**
     * @computed - Calculates the highest price among available products, to use in filters.
     * @returns {Number} - The rounded highest unit price.
     */
    get highestPrice() {
        if (this.allProducts) {
            const price = this.allProducts.reduce((maxPrice, product) => {
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

    handleCartIconClick() {
        this.showModal('cart');
    }

    handleTileClick(event) {
        this.selectedProduct = event.currentTarget.product;

        this.showModal('product');
    }

    handleModalClose(event) {
        const modalType = this.getModalType(event);

        this.closeModal(modalType);
    }

    handleAddToCart(event) {
        this.addProductToCart(event.detail);
    }

    handleRemoveFromCart(event) {
        this.removeProductFromCart(event.detail);
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

        return this.allProducts.filter((product) => {
            const meetsCategoryCriteria = this.meetsCategoryCriteria(product, category);
            const meetsPriceCriteria = this.meetsPriceCriteria(product, minPrice, maxPrice);

            return meetsCategoryCriteria && meetsPriceCriteria;
        });
    }

    getModalType(event) {
        return event.currentTarget.classList.contains('cart') ? 'cart' : 'product';
    }

    /**
     * @function meetsCategoryCriteria
     * @description Checks if Product meets the category filter.
     * @param {Object} product - The product to check.
     * @param {String} category - The selected category filter.
     * @returns {Boolean} - True if no category was selected or if it meets the category criteria, false otherwise.
     */
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

    addProductToCart(productData) {
        this.cartProducts.push(productData);
    }

    removeProductFromCart(productName) {
        this.cartProducts = this.cartProducts.filter((product) => product.Name !== productName);
    }
}
