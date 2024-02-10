import { LightningElement, api } from 'lwc';

export default class FiltersPanel extends LightningElement {
    maxSliderValue;
    minSliderValue = 0;
    selectedCategory = null;

    _maxPrice;

    @api categories;

    /**
     * @property {number} maxPrice - Sets the maximum price for sliders and initializes maxSliderValue.
     */
    @api
    set maxPrice(value) {
        this._maxPrice = value;
        this.maxSliderValue = value;
    }

    get maxPrice() {
        return this._maxPrice;
    }

    get comboboxOptions() {
        return this.categories.map((category) => ({
            label: category,
            value: category.toLowerCase()
        }));
    }

    /**
     * @function handleSliderChange
     * @description Handles the change event on sliders.
     * Sets the value of 'maxSliderValue' and 'minSliderValue' based on the slider changed.
     * @param {Object} event - The slider change event.
     */
    handleSliderChange(event) {
        const { value } = event.detail;
        const isMaxSlider = event.currentTarget.dataset.type === 'max';

        this.maxSliderValue = isMaxSlider ? value : this.maxSliderValue;
        this.minSliderValue = isMaxSlider ? this.minSliderValue : value;
    }

    handleComboboxChange(event) {
        this.selectedCategory = event.detail.value;
    }

    handleApplyClick() {
        const appliedFilters = this.getAppliedFilters();

        this.fireApplyFiltersEvent(appliedFilters);
    }

    handleReset() {
        this.resetSliders();
        this.resetCombobox();
        this.fireApplyFiltersEvent(null);
    }

    resetSliders() {
        this.maxSliderValue = this.maxPrice;
        this.minSliderValue = 0;
    }

    resetCombobox() {
        this.selectedCategory = null;
    }

    getAppliedFilters() {
        return {
            maxPrice: this.maxSliderValue,
            minPrice: this.minSliderValue,
            category: this.selectedCategory
        };
    }

    fireApplyFiltersEvent(appliedFilters) {
        this.dispatchEvent(new CustomEvent('apply', { detail: appliedFilters }));
    }
}
