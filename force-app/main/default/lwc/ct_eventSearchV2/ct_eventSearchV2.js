import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formFactorPropertyName from '@salesforce/client/formFactor';
//import UOP_LOGO from '@salesforce/resourceUrl/ct_UOP_Logo';
import getSuccessMessage from '@salesforce/apex/CT_EventSearchController.getEventRegistrationSuccessMessage';

export default class Ct_eventSearchV2 extends LightningElement {
    eventSelected = false;
    selectedEventId;
    eventId;
    grpId;
    @track successMessage;
    @track redirectURL;
    @track showSuccessMsg = false;
    @track showSearchForm = false;
    @track paymentSuccess = false;
   // @track uopLOGO = UOP_LOGO;
    @track spinnerBoolean;
    @track isHeaderShow = true;

    get getUopLogoStyle() {
        let logoStyle;
        if (formFactorPropertyName === 'Large') {
            logoStyle = 'width: 25%; height:20%;';
        } else {
            logoStyle = 'width: 200px !important;';
        }
        return logoStyle;
    }

    get thankYouFontStyle() {
        let fontStyle;
        if (formFactorPropertyName === 'Large') {
            fontStyle = 'font-size: 5rem;color: #621360;font-weight:700;';
        } else if (formFactorPropertyName === 'Medium') {
            fontStyle = 'font-size: 5rem;color: #621360;font-weight:700;';
        } else {
            fontStyle = 'font-size: 3rem;color: #621360;font-weight:700;';
        }
        return fontStyle;
    }

    connectedCallback() {
        console.log('ENTERED EVENT SEARCH V2')
        /*Get Id from the URL To Load A particular Event*/
        var queryString = window.location.href;
        var urlVar = new URL(queryString);
        this.eventId = urlVar.searchParams.get("id");
        var asperatoPaymentId = urlVar.searchParams.get("asperatoId");
        this.grpId = urlVar.searchParams.get("searchByGroup");
        if (queryString.includes('eventregistrationconfirmed')) {            
            this.showEventRegSuccessMessage(asperatoPaymentId, false);
        }
        else if(queryString.includes('nonPaidSuccess')){
            this.showEventRegSuccessMessage(this.eventId, true);
        } 
        else {
            if (this.eventId) {
                console.log('event id: '+this.eventId);
                this.showSearchForm = false;
                this.isHeaderShow = false;
            } else {
                this.showSearchForm = true;
            }
        }
    }

    showEventRegSuccessMessage(recId, isEventRecId){
        getSuccessMessage({recordId : recId , isEventRecordId : isEventRecId})
        .then(result => {
            if(result.SUCCESS_MESSAGE != undefined || result.SUCCESS_MESSAGE != null){
                this.successMessage = result.SUCCESS_MESSAGE;
                this.paymentSuccess = true;
            
            }else if(result.REDIRECT_URL != undefined && result.REDIRECT_URL != null){
                this.successMessage = '';
                window.open(result.REDIRECT_URL, '_self');
                console.log('eventsearchcopyopen');
                this.paymentSuccess = false;
            }
            else if(result.SUCCESS_MESSAGE == undefined && result.SUCCESS_MESSAGE == null && result.REDIRECT_URL == undefined && result.REDIRECT_URL == null){
                this.successMessage = result.CUSTOM_MESSAGE;
                this.paymentSuccess = true;
            }
            
        })
        .catch(error => {
            this.customToastNotification('Error', error.body.message, true);
        });
        //this.paymentSuccess = true;
    }

    handleSearch(event) {
        let eventName = event.detail.eventName;
        let eventType = event.detail.eventType;
        let eventGroup = event.detail.eventGroup;

        try {
            this.template.querySelector("c-ct_event-search-results-v2").searchEventRecords(eventName, eventType, eventGroup, '');
        } catch (error) {
            this.customToastNotification('Error', error, true);
        }
    }

    customToastNotification(toastTitle, toastMessage, isErrorMessage) {
        var messageString = isErrorMessage ? 'Error' : 'Success';
        const showToastEvent = new ShowToastEvent({
            Title: toastTitle,
            message: toastMessage,
            variant: messageString
        });
        this.dispatchEvent(showToastEvent);
    }

    handleEventSelection(event) {
        this.selectedEventId = event.detail.selectedEventId;
        this.eventSelected = true;
        this.isHeaderShow = false;
    }

    showSpinner() {
        this.spinnerBoolean = true;
    }

    hideSpinner() {
        this.spinnerBoolean = false;
    }


}