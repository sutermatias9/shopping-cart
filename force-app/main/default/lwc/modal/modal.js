import { LightningElement, api } from 'lwc';

const VALID_MODAL_SIZES = ['small', 'medium', 'large'];

export default class Modal extends LightningElement {
    @api product;
    @api size;

    /**
     * @computed modalSizeClass
     * @description Computes the CSS class for the modal base on the specified size.
     * @returns {String} - CSS class for the modal.
     */
    get modalSizeClass() {
        const baseClass = 'slds-modal slds-fade-in-open';

        return this.isValidSize() ? `slds-modal slds-fade-in-open slds-modal_${this.size}` : baseClass;
    }

    handleKeyDown(event) {
        if (event.code === 'Escape') {
            this.fireCloseModalEvent();
        }
    }

    handleCloseClick() {
        this.fireCloseModalEvent();
    }

    isValidSize() {
        return VALID_MODAL_SIZES.includes(this.size);
    }

    fireCloseModalEvent() {
        this.dispatchEvent(new CustomEvent('modalclose', { bubbles: true, composed: true }));
    }
}
