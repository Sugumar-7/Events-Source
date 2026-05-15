import { LightningElement, api, track } from 'lwc';
import sitBaseURL from '@salesforce/label/c.Site_Base_URL';
//import UOP_LOGO from '@salesforce/resourceUrl/ct_UOP_Logo';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEventGDPRdetails from "@salesforce/apex/ct_WaitingListController.getEventGDPRdetails";
import saveWaitingListEvtOrd from "@salesforce/apex/ct_WaitingListController.saveWaitingListEvtOrd";

export default class Ct_waitingListPageV2 extends LightningElement {

    @api eventId;
    //@track uopLOGO = UOP_LOGO;
    @track successMessage;
    @track orderSuccess = false;
    formTitle = 'Join the waiting list';
    subFormTitle = 'Online booking for the event is currently closed. To join the waiting list please enter your details below.';
    
    firstName;
    lastName;
    email;
    receiveSMSnotification = false;
    agreeForGDPRTerms = false;
    mobile;
    numberofTicketsRequired;
    orderData;
    statementUsed;
    statementTitle;
    statementTextAboveDeclaration;
    statementTextBelowDeclaration;
    declarationText;
    consentRequired;
    orderdatasaved;
    hasAgreedToConsentCapture;


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

    get consentCaptureOptions(){
        return [
            { label: 'Yes', value: 'Yes'},
            { label: 'No', value: 'No' }  
        ];
    }

    get showPlaceOrderButton(){
        return this.consentRequired ? this.hasAgreedToConsentCapture =='Yes' :  this.hasAgreedToConsentCapture != undefined;
    }

    connectedCallback(){
        var urlParams = window.location.href;
        var thisURL = new URL(urlParams);
        
        getEventGDPRdetails({eventId: this.eventId})
        .then(result => {
            var evtData = result;
            this.statementTitle = evtData.Statement_Title__c;
            this.statementTextAboveDeclaration = evtData.Statement_Text_above_dec__c;
            this.statementTextBelowDeclaration = evtData.Statement_Text_below_dec__c;
            this.declarationText = evtData.Declaration_Text__c;
            this.consentRequired = evtData.Consent_Required_to_Register__c;
        })
        .catch(error => {
            this.customToastNotification('Error', error, true);
        });
    }

    handleFirstName(event) {
        this.firstName = event.target.value;
    }

    handleLastName(event) {
        this.lastName = event.target.value;
    }

    handleEmail(event) {
        this.email = event.target.value;
    }
    handleReceiveSMSnotification(event) {
        this.receiveSMSnotification = event.target.checked;
        //if(!this.receiveSMSnotification){this.mobile = null;}
    }
    handleMobile(event){
        this.mobile = event.detail.value;
    }
    handleNumberofTicketsRequired(event){
        this.numberofTicketsRequired = event.detail.value;
    }
    
    handlePrevPage(){
      var prevPageURL = sitBaseURL+'/ledevents/s/event-ticket-selection?id='+this.eventId;
      window.open(prevPageURL, '_self');
      console.log('waitinlistpageopen1');
    }

    handleAgreerToConsent(event) {
        this.hasAgreedToConsentCapture = event.target.value;
    }
    
    handleSubmit(event){
    const allValid = [...this.template.querySelectorAll('.ticketOrderField')]
    .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);
    
    if(allValid){
        this.orderData = {
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            eventId: this.eventId,
            receiveSMSnotification: this.receiveSMSnotification,
            mobile: this.mobile,
            numberOfTicketsRequested: this.numberofTicketsRequired,
            consentGiven: this.hasAgreedToConsentCapture
        }
    }
    const context = this;
    saveWaitingListEvtOrd({evtOrderAsJson: JSON.stringify(this.orderData)})
    .then(result => {
        context.orderdatasaved = result;
        
        if(context.orderdatasaved != undefined) {
            var thankYouURL = sitBaseURL+'/ledevents/s/thankyou-page';
            window.open(thankYouURL, '_self');
            console.log('waitinglistpageopen2');
         }
    })
    .catch(error => {
        this.customToastNotification('Error', error, true);
    });

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
}