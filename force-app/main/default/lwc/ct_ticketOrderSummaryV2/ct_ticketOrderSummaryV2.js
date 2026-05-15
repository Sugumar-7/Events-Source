/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : Javid Sherif
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-15-2020   Umashankar Creation   Initial Version
**/
import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
//import QRCodeLib from "@salesforce/resourceUrl/ct_QRCodeLibrary";
import QRCodeLib from './qrcode.min.js';
import { loadScript } from "lightning/platformResourceLoader";
import saveEventTicketOrder from '@salesforce/apex/CT_EventSearchController.saveEventTicketOrder';
import invokedSaveQRCodeMethod from '@salesforce/apex/CT_EventSearchController.saveQRCode'; 
import getDiscountDetails from '@salesforce/apex/CT_EventSearchController.getDiscountInformation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAsperatoPaymentInformation from '@salesforce/apex/CT_EventSearchController.createNewAsperatoPayment';
import getSuccessMessage from '@salesforce/apex/CT_EventSearchController.getEventRegistrationSuccessMessage';
import getConsentCapture from '@salesforce/apex/CT_EventSearchController.getEventConsentCapture';

import formFactorPropertyName from '@salesforce/client/formFactor';



import MASTER_CARD_LOGO from '@salesforce/resourceUrl/ct_Master_card_logo';
import VISA_LOGO from '@salesforce/resourceUrl/ct_Visa_logo';
import AMERICAN_EXPRESS_LOGO from '@salesforce/resourceUrl/ct_American_Express_logo';



import CHECK_IN_MANAGER_URL from '@salesforce/label/c.Site_Base_URL';


export default class Ct_ticketOrderSummaryV2 extends NavigationMixin(LightningElement, QRCodeLib) {
    @api tickets;
    @api orderedBy;
    @api orderedTickets;
    @api isInternalComponent;
    @api isCheckInManagerComponent;
    @api internalRegistrationFormData;

    @track asperatoPaymentId;
    @track asperatoPaymentURL;
    @track paymentSuccess;
    @track spinnerBoolean;
    @track orderConfirmed;
    @track totalPrice = 0;
    @track sendOrderEmail = false;
    @track discountCode;
    @track discountError = false;
    @track hasScrolledToTop = false;

    @track selectedEvent;
    @track eventRegId;
    @track isPublicURL = false;
    @track isManualRegistration = false;
    @track eventRecord = {};
    @track startTimeValue;
    @track endTimeValue;

    @track eventRegToSessionIdsMap;
    @track eventRegPrimarySessionMap;
    // @track currencyValue;

    hasAgreedToConsentCapture;
    @track showConsentError = false;
    @track consentErrorMessage;

    @api redirectionOrderState;

    salesforceDomainURL;
    _libLoaded = false;
    ticket_Order_Id;
    insertedEventRegistration = [];

    @track masterCardLOGO = MASTER_CARD_LOGO;
    @track visaLOGO = VISA_LOGO;
    @track americanExpressLOGO = AMERICAN_EXPRESS_LOGO;
    urlIdparam;

    columns = [
        { label: "Ticket Type", fieldName: "name", type: "text" },
        { label: "Price Per Ticket", fieldName: "ticketPrice", type: "currency" },
        { label: "Quantity", fieldName: "ticketCount", type: "number" },
        { label: "Total", fieldName: "totalPrice", type: "currency" }
    ];

    get getGridStyle(){
        let style = 'slds-grid slds-gutters slds-p-top--xx-small';
        if (formFactorPropertyName === 'Small') {
          style = 'slds-grid slds-gutters slds-grid_vertical slds-p-top--xx-small';
        }
        return style;
    }

    get orderSummaryTitle() {
        return 'Order Summary';
    }

    get buttonStyle() {
        return 'border-radius: 0px;width: 300px !important';
    }

    get paymentPromptMessage() {
        return 'You will be taken to new tab for making your payment';
    }

    get paymentButtonStyle() {
        return 'border-radius: 0px;width: 300px !important';
    }

    get showPaymentButton() {
        // return this.totalPrice > 0; commented based on the update to remove paid regs 
         return false; 
    }
    get orderSummaryMessage(){
        return 'Before placing your order please check the event details:';
    }

    get getStyleClass() {
        return formFactorPropertyName === 'Large' ? 'slds-grid slds-form-element__control' : 'slds-grid slds-grid_vertical slds-form-element__control';
    }
    
    get getStyleClass() {
        return formFactorPropertyName === 'Large' ? 'slds-grid slds-form-element__control' : 'slds-grid slds-grid_vertical slds-form-element__control';
    }
    
    get getContainerClass() {
        return formFactorPropertyName === 'Large' ? 'slds-grid slds-size--5-of-7 slds-p-right_medium slds-combobox_container' : 'slds-grid slds-size--7-of-7 slds-p-bottom_medium slds-combobox_container';
    }

    //COnsent Capture Details
    get consentCaptureTitle(){
        return this.eventRecord.Statement_Title__c;
    }

    get consentCaptureStatementTextAboveDec(){
        return this.eventRecord.Statement_Text_above_dec__c;
    }
    
    get consentCaptureDeclarationtext(){
        return this.eventRecord.Declaration_Text__c;
    }

    get consentCaptureStatementTextBelowDec(){
        return this.eventRecord.Statement_Text_below_dec__c;
    }

    get consentCaptureOptions(){
        return [
            { label: 'Yes', value: 'Yes'},
            { label: 'No', value: 'No' }  
        ];
    }

    get showPlaceOrderButton(){
       // return this.eventRecord.Consent_Required_to_Register__c ? this.hasAgreedToConsentCapture =='Yes' :  this.hasAgreedToConsentCapture != undefined;
       return true;
    }

    get isDiscountCodeInForce(){
        return (this.eventRecord.Discount_Code_In_Force__c != undefined && this.eventRecord.Discount_Code_In_Force__c != null && this.eventRecord.Discount_Code__c != undefined && this.eventRecord.Discount_Code__c != null) ? this.eventRecord.Discount_Code_In_Force__c : false;
    }
    constructor() {
        
        super();
        this._libLoaded = true;

    }

    connectedCallback() {
       

        var queryString = window.location.href;
        var urlVar = new URL(queryString);

        var redirectionVar = JSON.parse(this.redirectionOrderState);

        if(this.redirectionOrderState){
            this.isInternalComponent = redirectionVar.isInternalComponent;
            if(!this.isInternalComponent)
            {
                var ticketsParameter = JSON.parse(redirectionVar.tickets);
                var orderedTicketsParameter =  JSON.parse(redirectionVar.orderedTickets);
                var orderedByParameter = JSON.parse(redirectionVar.orderedBy);
                this.selectedEvent = JSON.parse(redirectionVar.selectedEvent);
                this.tickets = ticketsParameter;
                this.orderedBy = orderedByParameter;
                this.orderedTickets = orderedTicketsParameter;
                
                this.isManualRegistration = JSON.parse(redirectionVar.manualRegistration);
                this.isPublicURL = JSON.parse(redirectionVar.publicURL);
                this.eventRegId = redirectionVar.eventRegId;

            }
        }
        try {
            getConsentCapture({
              eventId: this.orderedBy.eventId              
            })
            .then(result => {
            this.eventRecord = result;
            this.hideSpinner();
            })
            .catch(error => {
            this.customToastNotification('Error', JSON.stringify(error), true);
            this.hideSpinner();
            });
            }
            catch(err) {
              this.customToastNotification('Error', err.message, true);
              this.hideSpinner();
            }

        
        this.calculateTotalPrice();
    }

    renderedCallback(){
        if(!this.hasScrolledToTop){
            this.hasScrolledToTop = true;
            this.customScrollToTop();
        }
    }

    calculateTotalPrice(){
        this.tickets.forEach((element) => {
        if (element.totalPrice != null && element.totalPrice != undefined) {
            this.totalPrice = this.totalPrice + element.totalPrice;
        }
    })
    
        if((this.totalPrice - Math.floor(this.totalPrice)) == 0){
            this.totalPrice = parseInt(this.totalPrice); 
         }
         else{
            this.totalPrice = parseFloat(this.totalPrice).toFixed(2);
         }
    }

    handleInternalTicketConfirm() {
        this.showSpinner();
        if (this.totalPrice > 0) {
            this.handlePaidOrderConfirmation();
        } else {
            this.handleInternalConfirmOrder(0);
        }
    }

    handleSendEmail(event) {
        this.sendOrderEmail = event.target.checked;
    }

    customScrollToTop() {
        const ordersummaryScroll = new CustomEvent('scrolltotop', { detail: true });
        this.dispatchEvent(ordersummaryScroll);
      }

    handleAgreerToConsent(event) {
        this.showConsentError = false;
        if(event.target.checked)
            this.hasAgreedToConsentCapture = 'Yes';
        else
            this.hasAgreedToConsentCapture = 'No';
        console.log('this.hasAgreedToConsentCapture>>>'+this.hasAgreedToConsentCapture);
    }

    handleInternalConfirmOrder(totalPrice) {       
        saveEventTicketOrder({ 
            ticketOrderAsJson: JSON.stringify(this.orderedBy), 
            eventRegistrationAsJson: JSON.stringify(this.orderedTickets), 
            urlParamId: this.urlIdparam, 
            asperatoId: this.asperatoPaymentId, 
            sendOrderEmail: this.sendOrderEmail, 
            totalPrice: totalPrice, 
            isInternal: this.isInternalComponent,
            isCheckInManager : this.isCheckInManagerComponent,
            internalRegData: JSON.stringify(this.internalRegistrationFormData),
            consentgiven: this.hasAgreedToConsentCapture})
            .then(result => {
                this.salesforceDomainURL = result.salesforceDomainURL;
                this.insertedEventRegistration = result.eventRegistrationRecords;
                this.ticket_Order_Id = result.ticketOrderId;
                this.eventRegToSessionIdsMap =result.eventRegToSessionIdsMap;
                this.eventRegPrimarySessionMap = result.eventRegPrimarySessionMap;

                this.orderConfirmed = true;
                if (this._libLoaded) {
                    console.log('LIB LOADED 1');
                    this.generateQRCode();
                }

            })
            .catch(error => {
                this.customToastNotification('Error', error.body.message, true);
                this.hideSpinner();
            });
             
    }

    handlePaidOrderConfirmation() {
        this.showSpinner();
        if(this.validateConsentField()){
            createAsperatoPaymentInformation({ ticketOrderAsJson: JSON.stringify(this.orderedBy), TotalPrice: this.totalPrice })
                .then(result => {
                    console.log('JSON.stringify(this.result)>>>'+JSON.stringify(result));
                    this.asperatoPaymentId = result.ASPERATO_ID;
                    this.asperatoPaymentURL = result.ASPERATO_PAYMENT_URL;
                    if (this.isInternalComponent) {
                        this.handleInternalConfirmOrder(result.AMOUNT);
                    } else {
                        this.handleConfirmOrder(result.AMOUNT);
                    }
                })
                .catch(error => {
                    this.customToastNotification('Error', error.body.message, true);
                });
        }

    }

    handleConfirmUnPaidFromWeb() {
        // if(this.validateConsentField()){
            this.handleConfirmOrder(0);
        // }
    }

    handleConfirmOrder(totalPrice) {
        if (!this.orderConfirmed) {
            this.showSpinner();

            var queryString = window.location.href;
            var urlVar = new URL(queryString);
            this.urlIdparam = urlVar.searchParams.get("id");
            console.log('EveREG JSON  '+JSON.stringify(this.orderedTickets));
            saveEventTicketOrder({ ticketOrderAsJson: JSON.stringify(this.orderedBy), eventRegistrationAsJson: JSON.stringify(this.orderedTickets), urlParamId: this.urlIdparam, asperatoId: this.asperatoPaymentId, sendOrderEmail: false, totalPrice: totalPrice, isInternal: this.isInternalComponent ,consentgiven: this.hasAgreedToConsentCapture})
                .then(result => {
                    console.log('this.resultgggg>>>>>>'+JSON.stringify(result)); 
                    this.salesforceDomainURL = result.salesforceDomainURL;
                    this.insertedEventRegistration = result.eventRegistrationRecords;
                    this.ticket_Order_Id = result.ticketOrderId;
                    this.eventRegToSessionIdsMap =result.eventRegToSessionIdsMap;

                    this.eventRegPrimarySessionMap = result.eventRegPrimarySessionMap;
    
                    this.orderConfirmed = true;
                    console.log('LIB LOADED 2 '+ this._libLoaded);
                    if (this._libLoaded) {
                        console.log('LIB LOADED 3');
                        this.generateQRCode();
                    }
                    console.log('this.asperatoPaymentId>>>'+this.asperatoPaymentId);
                    if (this.asperatoPaymentId != null && this.asperatoPaymentId != undefined) {
                        console.log('IT works');
                        window.open(this.asperatoPaymentURL, '_self');
                    } else {
                        this.handleSuccess();
                   
                }
                    this.hideSpinner();
        })
                .catch (error => {
            if(error.body.message){
                this.customToastNotification('Error', error.body.message, true);
            }
            else if(error.body.pageErrors[0].message){
                this.customToastNotification('Error', error.body.pageErrors[0].message, true);
            }
            else{
                this.customToastNotification('Error', 'Error', true);
            }
            
            this.hideSpinner();
        });
        
    }
}

handleSuccess(){
    if(this.isCheckInManagerComponent){
        this.triggerEventregisteredCustomEvent();
    }
    else{
        getSuccessMessage({
            recordId       : this.orderedBy.eventId,
            isEventRecordId: true,
            eventOrderId   : this.ticket_Order_Id})
        .then(result => {
            if(result.REDIRECT_URL != undefined && result.REDIRECT_URL != null){
                //window.open(result.REDIRECT_URL, '_self');
                const eventToParent = new CustomEvent('eventorderconfirmationdisplay', {
                    detail: { eventsearchdisplay: true,
                      selectedEventDisplay : false, 
                      eventOrderDisplay : false,
                      eventSummaryDisplay : false,
                      eventOrderConfirmation : true,
                      ticketOrderId : this.ticket_Order_Id
                    },
                    bubbles: true,
                    composed: true
                    });
                    this.dispatchEvent(eventToParent);
            }else{
                var queryString = window.location.href;
                    queryString = queryString + '&mode=nonPaidSuccess';
                    window.open(queryString, '_self');
            }
        })
        .catch(error => {
            this.customToastNotification('Error', error.body.message, true);
        });
    }

    }

generateQRCode() {
    const card = this.template.querySelector('[data-id="QRCard"]');
    const canvas = this.template.querySelector('[data-id="QRCode"]');
    // const baseUrl = window.location.origin;
    // // Convert Experience Cloud domain → Lightning domain
    // if (baseUrl.includes('.my.site.com')) {
    //     baseUrl = baseUrl.replace('.my.site.com', '.lightning.force.com');
    // }
    try{
        for (var i = 0; i < this.insertedEventRegistration.length; i++) {
            // const baseUrl = window.location.protocol + '//' + window.location.host;
            // baseUrl = baseUrl.replace('.my.site.com', '.lightning.force.com');
            // console.log("Base URL ->>>>>" + baseUrl);
            // console.log('Base URL ->>>>> ' + baseUrl);
            // var sData =
            //     `${baseUrl}/lightning/n/Check_In_QR_Code_Scanner` +
            //     `?c__eventregid=${this.insertedEventRegistration[i].Id}`;
                
           // var sData = this.salesforceDomainURL + '/' + `UoPQRScanner/s/scanqrcode?eventid=${this.insertedEventRegistration[i].Event__c}&eventregid=${this.insertedEventRegistration[i].Id}`;
            var sData = CHECK_IN_MANAGER_URL +'/lightning/n/Check_In_QR_Code_Scanner' +`?c__eventregid=${this.insertedEventRegistration[i].Id}`;
        //    var sData='https://creationevents-dev-ed.develop.my.salesforce.com/home/home.jsp' 
            
            // eslint-disable-next-line no-undef
            QRCode.toCanvas(canvas, sData)
                .then(() => {
                    console.log("Generated QR! ");
                })
                .catch(error => {
                    console.log('QR ERROR '+JSON.stringify(error));
                    //this.customToastNotification('Error', error.body.message, true);
                });
    
            var canvasElement = this.template.querySelector('[data-id="QRCode"]');
            var dataURL = canvasElement.toDataURL("image/png");
            var convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
    
            this.insertedEventRegistration[i].QR_Code__c = '<img src="data:image/jpeg;base64,' + convertedDataURI + '">';
            this.insertedEventRegistration[i].QR_Code_URL__c = sData;
            this.insertedEventRegistration[i].Event_Order__c = this.ticket_Order_Id;
    
        }
        
    }

    catch(err) {
        console.log('QR ERROR '+JSON.stringify(err));
        this.customToastNotification('Error', err.message, true);
        this.hideSpinner();
    }


    invokedSaveQRCodeMethod({ 
        eventRegistrationAsJson  : JSON.stringify(this.insertedEventRegistration),
        isCheckInManager         : this.isCheckInManagerComponent,
        internalRegData          : JSON.stringify(this.internalRegistrationFormData),
        eventRegToSessionIdsMap  : JSON.stringify(this.eventRegToSessionIdsMap),
        eventRegPrimarySessionMap: JSON.stringify(this.eventRegPrimarySessionMap)
    })
        .then(() => {


            if (this.isInternalComponent) {
                this.customToastNotification('Success', 'Event registered successfully', false);
                this.hideSpinner();
                this.redirectToEventRecord();
            }
        })
        .catch(error => {
            this.customToastNotification('Error', error.body.message, true);
            this.hideSpinner();
        });

}

showSpinner() {
    this.spinnerBoolean = true;
}

hideSpinner() {
    this.spinnerBoolean = false;
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

handleCancelOrder(event) {
}

handleBack(){
    const backEvent = new CustomEvent('ordersummaryback', { detail: true });
    this.dispatchEvent(backEvent);
}


handleTicketOrderSummaryInternalRegBack(){
    var eventParameter ={  
        'orderedTickets':this.orderedTickets,
        'selectedTickets': this.tickets,
        'orderBy' : this.orderedBy,
        'isBackfromOrderSummary' : true
    };

    const backEvent = new CustomEvent('ordersummarybackevent', { detail: eventParameter , bubbles: true});
    this.dispatchEvent(backEvent);   
}

redirectToOrderDetails(){


    var redirectionState = {};
              redirectionState['selectedTickets'] = JSON.stringify(this.tickets);
              redirectionState['orderedTickets'] = JSON.stringify(this.orderedTickets);

              redirectionState['orderBy'] = JSON.stringify(this.orderedBy);
              redirectionState['selectedEvent'] = JSON.stringify(this.selectedEvent);
              if(this.eventRegId && this.eventRegId.trim()){
                redirectionState['eventRegId'] = this.eventRegId;
              }
              if(this.campaignRefId && this.campaignRefId.trim()){
                redirectionState['campaignRefId'] = this.campaignRefId;
              }
              redirectionState['waitInvitaion'] = this.isWaitingList ? 'true' : 'false';
              redirectionState['manualRegistration'] = this.isManualRegistration ? 'true' : 'false';
              redirectionState['publicURL'] = this.isPublicURL ? 'true' : 'false';
              redirectionState['isOrderSummaryBack'] = 'false';



              

    this.redirectionState = JSON.stringify(redirectionState);
    console.log('BackRedirectionState>>>'+this.redirectionState);
    const eventToParent = new CustomEvent('eventbackorderdetailsdisplay', {
        detail: { 
          selectedEventDisplay: false,
          eventOrderDisplay : true,
          eventSummaryDisplay : false,
          setRedirectionState : this.redirectionState
          
        },
        bubbles: true,
        composed: true
        });
        this.dispatchEvent(eventToParent);
    }

    redirectToEventRecord() {

        if(this.isCheckInManagerComponent){
            this.triggerEventregisteredCustomEvent();
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    "recordId": this.orderedBy.eventId,
                    "actionName": "view"
                }
            });
        }
    }

    triggerEventregisteredCustomEvent() {
        const cancelEvent = new CustomEvent('eventregistered', { detail: true });
        this.dispatchEvent(cancelEvent);
    }

    handleDiscountChange(event){
      this.discountCode = event.target.value;
    }

    handleClear(){
      this.showSpinner();
      this.totalPrice = 0;
      this.calculateTotalPrice();

      try{
        let tempOrder = JSON.parse(JSON.stringify(this.orderedBy));
        tempOrder.isDiscountedOrder = false;
        this.orderedBy = tempOrder;
      }
      catch(err){
        console.log('Error '+err);
      }
      this.discountError = false;
      this.discountCode = '';
      this.hideSpinner();
    }

    handleApply(){
      this.showSpinner();
      var eventId = this.orderedBy.eventId;
      this.discountCode = this.discountCode.trim();
      if(this.discountCode){
        this.discountError = false;
        getDiscountDetails({eventId : eventId, orderAmount: this.totalPrice, discountCode : this.discountCode})
          .then(result =>{
            
            if(result.DISCOUNT_AMOUNT == 'NOT_APPLICABLE'){
              this.customToastNotification('Error', 'Discount code incorrect or expired', true);
              this.hideSpinner();
            }
            else{
              //Set Event Order Created as discount applied

              try{
                let tempOrder = JSON.parse(JSON.stringify(this.orderedBy));
                tempOrder.isDiscountedOrder = true;
                this.orderedBy = tempOrder;
              }
              catch(err){
                console.log('Error  '+err);
              }

              this.totalPrice = parseFloat(result.DISCOUNT_AMOUNT);
              this.customToastNotification('Success', 'Discount applied successfully!', false);
              this.hideSpinner();
            }
          })
          .catch(error => {
            this.customToastNotification('Error', error, true);
            this.hideSpinner();
        });
      }
      else{
        this.discountError = true;
        this.hideSpinner();
      }

    }

    validateConsentField(){
        // if(this.hasAgreedToConsentCapture == undefined){
        //     this.consentErrorMessage = "Please provide the consent";
        //     this.showConsentError = true;
        //     this.hideSpinner();
        // }
        if(this.eventRecord.Consent_Required_to_Register__c && this.hasAgreedToConsentCapture !='Yes'){
            this.consentErrorMessage = "Consent is required to register this event, Please check the box to agree to the consent";
            this.showConsentError = true;
            this.hideSpinner();
        }
        return !this.showConsentError;
    }
}