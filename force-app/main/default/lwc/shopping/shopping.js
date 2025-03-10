import { LightningElement, wire } from 'lwc';
import getProducts from '@salesforce/apex/ProductHandler.getProducts';
import getActiveCartInfo from '@salesforce/apex/CartHandler.getActiveCartInfo';
import addToCart from '@salesforce/apex/CartItemHandler.addToCart';
import removeFromCart from '@salesforce/apex/CartItemHandler.removeFromCart';
import userId from '@salesforce/user/Id';

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
    isMyPurchasesOpen = false;

    cartInfo = null;
    isCartUpdating = false;

    error;

    /**
     * @wire - Gets all the products in the org using the getProducts wire adapter.
     * @param {Object} param0- Data and error properties returned by the adapter.
     */
    @wire(getProducts, { fields: 'Name, Description, Family, Image__c, Rating__c' })
    wiredProducts({ data, error }) {
        if (data) {
            this.products = data;
        } else {
            this.error = error;
        }
    }

    /**
     * @getter - Computes the list of products based on the applied filters.
     * @returns {Array} - List of products to display.
     */
    get productsToShow() {
        if (this.filters !== null) {
            return this.getFilteredProducts();
        }

        return this.products;
    }

    /**
     * @getter - Calculates the highest price among available products, to use in filters.
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

    get cartProducts() {
        if (this.cartInfo) {
            return this.cartInfo.Cart_Items__r;
        }

        return [];
    }

    get isProductInCart() {
        if (this.isProductDetailOpen) {
            return this.cartProducts.some((item) => item.Product__c === this.selectedProduct.Id);
        }

        return false;
    }

    connectedCallback() {
        this.refreshCart();
    }

    handleApplyFiltersClick(event) {
        this.filters = event.detail;
    }

    handleModalClose(event) {
        const type = event.currentTarget.dataset.type;

        if (type === 'cart') this.isCartOpen = false;
        else if (type === 'product-detail') this.isProductDetailOpen = false;
        else if (type === 'my-purchases') this.isMyPurchasesOpen = false;
    }

    handleProductSelect(event) {
        this.selectedProduct = event.detail;
        this.isProductDetailOpen = true;
    }

    handleViewPurchases() {
        this.isMyPurchasesOpen = true;
    }

    handleViewCart() {
        this.isCartOpen = true;
    }

    async handleAddToCart(event) {
        const { productId, quantity } = event.detail;
        this.isCartUpdating = true;

        try {
            await addToCart({ userId, productId, quantity });
            this.refreshCart();
            this.isCartUpdating = false;
        } catch (e) {
            console.log(e);
        }
    }

    async handleRemoveFromCart(event) {
        const productId = event.detail;
        this.isCartUpdating = true;

        try {
            await removeFromCart({ productId, userId });
            this.refreshCart();
            this.isCartUpdating = false;
        } catch (e) {
            console.log(e);
        }
    }

    handleCartUpdate() {
        this.refreshCart();
    }

    handleCartPurchase() {
        this.cartInfo = null;
    }

    handleCartCancel() {
        this.isCartOpen = false;
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

    async refreshCart() {
        try {
            const result = await getActiveCartInfo({ userId });
            this.cartInfo = result;

            this.cartInfo.Cart_Items__r = this.cartInfo.Cart_Items__r ?? [];
        } catch (e) {
            console.log(e);
        }
    }
}
