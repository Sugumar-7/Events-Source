import { LightningElement, wire, api, track } from 'lwc';
import getCountryStateMap from '@salesforce/apex/ct_CountryPicklistController.getCountryStateMap';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

export default class Ct_CountryStatePicklistV2 extends LightningElement {

    @api isDisabled;
    @api isRequired;
    @api selectedCountry;
    @api selectedState;

    @track countryOptions = [];
    @track stateOptions = [];

    isPicklistEnabled = false;
    staticData;
    statePicklistData;
    recordTypeId;

    @wire(getCountryStateMap)
    wiredApex({ data }) {
        if (data) {
            this.isPicklistEnabled = data.isPicklistEnabled;

            if (!this.isPicklistEnabled) {
                this.staticData = data.staticData;

                this.countryOptions = Object.keys(this.staticData).map(country => ({
                    label: country,
                    value: country
                }));
            }
        }
    }

    //Get RecordType Dynamically
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo({ data }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: ACCOUNT_OBJECT,
        recordTypeId: '$recordTypeId'
    })
    wiredPicklists({ data }) {
        if (data && this.isPicklistEnabled) {

            const countryField = data.picklistFieldValues.ShippingCountryCode;
            const stateField = data.picklistFieldValues.ShippingStateCode;

            this.statePicklistData = stateField;

            this.countryOptions = countryField.values.map(c => ({
                label: c.label,   // India
                value: c.value    // IN
            }));
        }
    }

    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
        this.selectedState = null;

        const selectedCountryOption = this.countryOptions.find(
            opt => opt.value === this.selectedCountry
        );

        if (this.isPicklistEnabled && this.statePicklistData) {

            const controllerIndex =
                this.statePicklistData.controllerValues[this.selectedCountry];

            this.stateOptions = this.statePicklistData.values
                .filter(state => state.validFor.includes(controllerIndex))
                .map(state => ({
                    label: state.label,
                    value: state.value
                }));

        } else if (this.staticData) {

            if (this.staticData[this.selectedCountry]) {
                this.stateOptions =
                    this.staticData[this.selectedCountry].map(state => ({
                        label: state,
                        value: state
                    }));
            } else {
                this.stateOptions = [];
            }
        }

        this.dispatchEvent(
            new CustomEvent('countrychange', {
                detail: selectedCountryOption ? selectedCountryOption.label : null
            })
        );
    }

    handleStateChange(event) {
        this.selectedState = event.detail.value;

        const selectedStateOption = this.stateOptions.find(
            opt => opt.value === this.selectedState
        );

        this.dispatchEvent(
            new CustomEvent('statechange', {
                detail: selectedStateOption ? selectedStateOption.label : null
            })
        );
    }
}