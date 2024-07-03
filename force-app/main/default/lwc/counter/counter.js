import { LightningElement, api } from 'lwc';

export default class Counter extends LightningElement {
    @api initialValue;
    currentValue = 1;

    connectedCallback() {
        if (this.initialValue) {
            this.currentValue = this.initialValue;
        }
    }

    handleDecrementClick() {
        this.updateNumber('decrement');
    }

    handleNumberInput(event) {
        this.updateNumber('input', Number(event.currentTarget.value));
    }

    handleIncrementClick() {
        this.updateNumber('increment');
    }

    /**
     * @function updateNumber
     * @description Updates the number based on the operation.
     * Triggers the CounterChange Event after the update.
     * @param {String} operation - The operation to perform ('increment', 'decrement', 'input')
     * @param {Number} inputValue - The value entered in case of 'input' operation.
     */
    updateNumber(operation, inputValue) {
        if (operation === 'increment' || (operation === 'decrement' && this.currentValue > 1)) {
            this.currentValue = operation === 'increment' ? this.currentValue + 1 : this.currentValue - 1;
        } else if (operation === 'input') {
            this.currentValue = inputValue;
        }

        this.fireCounterChangeEvent();
    }

    fireCounterChangeEvent() {
        this.dispatchEvent(new CustomEvent('counterchange', { detail: this.currentValue }));
    }
}
