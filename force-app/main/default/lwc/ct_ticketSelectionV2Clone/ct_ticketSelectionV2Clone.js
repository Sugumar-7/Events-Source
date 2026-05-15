/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 01-16-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   01-08-2021   Umashankar Creation   Initial Version
**/
import { LightningElement, api, wire, track } from "lwc";
import sitBaseURL from '@salesforce/label/c.Site_Base_URL';
import { NavigationMixin } from 'lightning/navigation';
import saveEventTicketOrder from '@salesforce/apex/CT_EventSearchController.saveEventTicketOrder';
import invokedSaveQRCodeMethod from '@salesforce/apex/CT_EventSearchController.saveQRCode'; 
import fetchEventAndTickets from "@salesforce/apex/CT_EventSearchController.fetchEventAndTickets";
import getConsentCapture from '@salesforce/apex/CT_EventSearchController.getEventConsentCapture';
import getSuccessMessage from '@salesforce/apex/CT_EventSearchController.getEventRegistrationSuccessMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CHECK_IN_MANAGER_URL from '@salesforce/label/c.Site_Base_URL';


export default class Ct_ticketSelectionV2Clone extends NavigationMixin(LightningElement) {
    @api selectedEventId;
    @track eventTickets;
    @track selectedEvent;
    @api selectedTickets;
    @track storedticketCount = [];
    @track isTicketsavailable= false;
    @api isInternalComponent = false;
    @api isCheckInManagerComponent = false;
    @track showSearchForm = false;
    @track isHeaderShow = true;
    @track showTicketPanel = false;
    @track showTicketsClosed = false;
    @track showWaitingLisBtn = false;
    @track isWaitingList = false;
    @track isManualRegistration = false;
    @track isPublicURL  = false;
    @track showTicketCountMessage = false;
    @track hasAtleastOneticketSelected = false;
    @track hasScrolledToTop = false;
    @track eventRecord = {};

    @track isGroupBooking = true;
    salesforceDomainURL;
    _libLoaded = false;
    ticket_Order_Id;
    @track spinnerBoolean = false;

    totalSelectedTickets = 0;
    @api hasMinRequiredTickets = 0;

    hasAgreedToConsentCapture = 'No';
    @track showConsentError = false;
    consentErrorMessage = "Consent is required to register this event";

    // isRederedScrolledToTop = false;
    @track eventRegId;
    @track campaignRefId;
    
    eventId;
    error;
    ticketsCloseMessage = 'Registration for this event is closed';
    provideAttendeeDetails = false;
    //Internal reg Upgrade
    @api orderBy;
    //fieldsForRecordEditForm = ['Name', 'Registration_Type__c', 'Status__c', 'CurrencyIsoCode', 'Event__c', 'Event_Product__c', 'Enquirer__c', 'Contact__c', 'Account_Name__c', 'Event_Order__c', 'Session_Registration_URL__c'];
    @api setBackRedirectionValues;

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

    handleAgreerToConsent(event) {
        this.showConsentError = false;
        this.hasAgreedToConsentCapture = event.target.checked ? 'Yes' : 'No';
    }

    connectedCallback() {
      /*Get Id from the URL To Load A particular Event*/
      if(!this.isInternalComponent){
        var queryString = window.location.href;
        if(queryString.indexOf('eventRegId') > -1){
          this.eventRegId = urlVar.searchParams.get("eventRegId");
        }
        if(queryString.indexOf('campaignRefId') > -1){
          this.campaignRefId = urlVar.searchParams.get("campaignRefId");
        }
       
      }

      /*Get Id from the URL To Load A particular Event Product*/
      var urlParams = window.location.href;
      var thisURL = new URL(urlParams);
    
      if(urlParams.indexOf('waitInvitaion') > -1 && thisURL.searchParams.get("waitInvitaion") == 'true'){
        this.isWaitingList = true;
      }
     
      if(urlParams.indexOf('manualRegistration') > -1 && thisURL.searchParams.get("manualRegistration") == 'true'){
        this.isManualRegistration = true;
      }
     

      if(urlParams.indexOf('publicURL') > -1 && thisURL.searchParams.get("publicURL") == 'true'){
        this.isPublicURL  = true;
      }
      else{
        this.isPublicURL  = false;
      }
      
      try {
        getConsentCapture({
          eventId: this.selectedEventId              
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
      //this.showSearchForm = true;
   }

   renderedCallback(){
    if(!this.hasScrolledToTop){
            this.hasScrolledToTop = true;
            this.customScrollToTop();
        }
    
    }

    customScrollToTop() {
        const ordersummaryScroll = new CustomEvent('scrolltotop', { detail: true });
        this.dispatchEvent(ordersummaryScroll);
      }

    @wire(fetchEventAndTickets, { selectedEventId: "$selectedEventId" })
    wiredEvent({ error, data }) {
      console.log('data2: '+data);
      try{
        if (data) {
            console.log('data3: '+data);
            
             /*Get Id from the URL To Load A particular Event Product*/
            var urlParams = window.location.href;
            var thisURL = new URL(urlParams);
          
            if(urlParams.indexOf('waitInvitaion') > -1 && thisURL.searchParams.get("waitInvitaion") == 'true'){
              this.isWaitingList = true;
            }

            if(urlParams.indexOf('manualRegistration') > -1 && thisURL.searchParams.get("manualRegistration") == 'true'){
              this.isManualRegistration = true;
            }

            if(urlParams.indexOf('publicURL') > -1 && thisURL.searchParams.get("publicURL") == 'true'){
              this.isPublicURL  = true;
            }
            else{
              this.isPublicURL  = false;
            }
            
            this.selectedEvent = data;
            //
            this.selectedEvent = JSON.parse(JSON.stringify(this.selectedEvent));
            let imageURL = this.selectedEvent.Web_Event_Image__c;
            const srcStart = imageURL.indexOf('src="') + 5;
            const srcEnd = imageURL.indexOf('"', srcStart);
            imageURL = imageURL.substring(srcStart, srcEnd);
            imageURL = imageURL.replace(/&amp;/g, '&');
            const baseUrl = window.location.protocol + '//' + window.location.host;
            //imageURL = 'https://creationevents-dev-ed.develop.my.site.com/' + imageURL;
            if (!imageURL.startsWith('http')) {
              imageURL = `${baseUrl}/${imageURL}`;
            }
            this.selectedEvent.Web_Event_Image__c = imageURL;
            //
            


            this.eventTickets = this.selectedEvent.Tickets__r;
            console.log('eventTickets----------------> '+JSON.stringify(this.eventTickets));
            this.error = undefined;
            console.log('selectedEvent----------------> '+JSON.stringify(this.selectedEvent));
            if(this.selectedEvent.Registration_Status__c == 'Open' || this.isWaitingList || this.isManualRegistration){
                this.showTicketPanel = true;
                this.showTicketsClosed = false;
                this.showWaitingLisBtn = false;
            }
            else if(this.selectedEvent.Registration_Status__c == 'Closed'){
                this.showTicketPanel = false;
                this.showTicketsClosed = true;
                this.showWaitingLisBtn = false;
            }
            else if(this.selectedEvent.Registration_Status__c == 'Waiting List'){
                this.showTicketPanel = false;
                this.showTicketsClosed = false;
                this.showWaitingLisBtn = true;
            }
        } else if (error) {
            this.error = error;
            this.selectedEvent = undefined;
           

        }
      }
      catch(error){
        alert('ERROR'+ error.message);
      }
    }

    handleInternalRegistrationCancel(){
      const cancelinternalregistration = new CustomEvent('cancelcheckineventregistration', { detail: true});
      this.dispatchEvent(cancelinternalregistration);  
    }

    handleticketCounts(event){

        var detaildata = event.detail;
        this.storedticketCount.push(detaildata);
    }

    handleprovideAttendeeDetails(event){
      if(event.target.checked)
            this.isGroupBooking = false;
    }

    handleCheckOut(){
      if(this.provideAttendeeDetails)
        this.redirectToOrderDetails();
    }

    @api
    validateForm(){
      var hasValidTickets = 0;
      var isThisTicketValid = false;
      this.template.querySelectorAll("c-ct_ticket-tile-v2")
            .forEach(element => {
              isThisTicketValid = false;
            
              if(element.eventTicket.Minimum_Products_Per_Order__c && element.eventTicket.Minimum_Products_Per_Order__c > 0
                && (!element.selectedTicketCount || element.selectedTicketCount == '--None--'
                || element.selectedTicketCount < element.eventTicket.Minimum_Products_Per_Order__c)){
                  this.hasMinRequiredTickets = this.hasMinRequiredTickets + 1;
                 isThisTicketValid =  element.checkValidity();
              }
              else if(this.hasAtleastOneticketSelected && (element.selectedTicketCount > 0 || element.selectedTicketCount == 0 || element.selectedTicketCount == '--None--')){
                //element.checkValidity();
                isThisTicketValid = true;
              }
              
              if(isThisTicketValid){
                hasValidTickets = hasValidTickets +1;
              }
              else{
                element.checkValidity();
              }
            });
            return hasValidTickets;
    }

    @api
    handleNext() {
       try {
            var totalSelectedTickets = 0;
            let selectedTickets = [];
            let ticketTiles = this.template.querySelectorAll("c-ct_ticket-tile-v2");
            for (let i = 0; i < ticketTiles.length; i++) {
                let eachTicket = ticketTiles[i].eventTicket;
                this.totalSelectedTickets = this.totalSelectedTickets + parseInt(ticketTiles[i].selectedTicketCount);
                if (ticketTiles[i].selectedTicketCount != null &&
                    ticketTiles[i].selectedTicketCount != undefined &&
                    ticketTiles[i].selectedTicketCount > 0) {
                        selectedTickets.push({
                            eventId: this.selectedEventId,
                            ticketId: eachTicket.Id,
                            Name: eachTicket.Name,
                            Event_Product_Description__c: eachTicket.Event_Product_Description__c,
                            ticketCount: ticketTiles[i].selectedTicketCount,
                            ticketPrice: ticketTiles[i].eventTicket.Event_Product_Price__c,
                            anonymousOnly : ticketTiles[i].eventTicket.Anonymous_Only__c,
                            allowGuestRegistrations: ticketTiles[i].eventTicket.Allow_Guest_Registrations__c,
                            allowPrimaryRegistration: eachTicket.Allow_Primary_Session__c ? eachTicket.Allow_Primary_Session__c : false,
                            mandatePrimarySession: eachTicket.Is_Mandatory__c ? eachTicket.Is_Mandatory__c : false,
                            primarySessionInterestHeading: eachTicket.Primary_Session_Interest_Heading__c,
                            primarySessionInterestLabel :  eachTicket.Primary_Session_Interest_Label__c,
                            totalPrice: parseInt(ticketTiles[i].selectedTicketCount) * ticketTiles[i].eventTicket.Event_Product_Price__c
                        });
                
                }
             
            }
            
            this.selectedTickets = selectedTickets;
          
        } catch (error) {
            console.log(error);
        }
          return this.selectedTickets;
        
    }
    
    @api
    getOrderByDetails(){
      return this.template.querySelector('c-ct_ticket-order-form-v2-clone').handleDisplaySummary();
    }

    //existing code
    // buildPageUrl(pageRef) {
    //   const state = pageRef;      
    //   var strredirectionState  = JSON.stringify(state);
    //   console.log('strredirectionState >>>>> '+strredirectionState);

  
    //   const params = new URLSearchParams();
    //   Object.keys(strredirectionState).forEach(key => {
    //   params.append(key, strredirectionState[key]);
    //   });
      
    //         return `?${params.toString()}`;

    // }


    redirectToOrderDetails(){
      this.showTicketCountMessage = false;
      this.totalSelectedTickets = 0;
      this.hasMinRequiredTickets = 0;

      this.template.querySelectorAll("c-ct_ticket-tile-v2").forEach(element => {
        if(element.selectedTicketCount !=null && element.selectedTicketCount!= undefined && !isNaN(element.selectedTicketCount) && element.selectedTicketCount > 0){
          this.hasAtleastOneticketSelected = true;
        }
      });


        if(this.isInternalComponent){
            const ticketselectionNEXTEventCON = new CustomEvent('ticketselectionextevent', { detail: true , bubbles: true});
            this.dispatchEvent(ticketselectionNEXTEventCON);
          }
        else{
            var ticketSelectionObject = this.template.querySelector('c-ct_ticket-selection-v2-clone');
            this.totalSelectedTickets = 0;
            this.hasMinRequiredTickets = 0;

            var ticketSelectionObject = this.template.querySelector('c-ct_ticket-selection-v2-clone');

            var selectedTickets = this.handleNext();
            if(parseInt(this.totalSelectedTickets) > this.selectedEvent.Event_Registrations_Available__c){
              this.showTicketCountMessage = true;
            }
            else{
              var ticketOrderObject = this.getOrderByDetails();
            if(this.validateForm() > 0 && ticketOrderObject && this.hasMinRequiredTickets < 1){
            
              if (this.isGroupBooking) {
                  this.handleGroupBookingCreation(selectedTickets, ticketOrderObject);
              } else {
                  this.proceedToIndividualDetails(selectedTickets, ticketOrderObject);
              }
              } 
            }
            
        }
     
    }

    proceedToIndividualDetails(selectedTickets, ticketOrderObject) {
        var redirectionState = {};
        redirectionState['selectedTickets'] = JSON.stringify(selectedTickets);
        redirectionState['orderBy'] = JSON.stringify(ticketOrderObject);
        redirectionState['selectedEvent'] = JSON.stringify(this.selectedEvent);
        
        if (this.eventRegId && this.eventRegId.trim()) redirectionState['eventRegId'] = this.eventRegId;
        if (this.campaignRefId && this.campaignRefId.trim()) redirectionState['campaignRefId'] = this.campaignRefId;
        
        redirectionState['waitInvitaion'] = this.isWaitingList ? 'true' : 'false';
        redirectionState['manualRegistration'] = this.isManualRegistration ? 'true' : 'false';
        redirectionState['publicURL'] = this.isPublicURL ? 'true' : 'false';
        redirectionState['isOrderSummaryBack'] = 'false';

        this.redirectionState = JSON.stringify(redirectionState);

        const eventToParent = new CustomEvent('eventorderdisplay', {
            detail: { 
                eventsearchdisplay: true,
                selectedEventDisplay: false,
                eventOrderDisplay: true,
                setRedirectionState: this.redirectionState
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(eventToParent);
    }

    
    redirectToOrderDetails() {

        if (this.eventRecord.Consent_Required_to_Register__c && this.hasAgreedToConsentCapture !== 'Yes') {
          this.consentErrorMessage = "Consent is required to register this event, Please check the box to agree to the consent";
          this.showConsentError = true;
          
          setTimeout(() => {
              const errorElement = this.template.querySelector('#lastError');
              if(errorElement) errorElement.scrollIntoView({behavior: "smooth", block: "center"});
          }, 100);

          return; 
        }
        console.log('Step 0: Checkout Button Clicked');
        this.showTicketCountMessage = false;
        this.totalSelectedTickets = 0;
        this.hasMinRequiredTickets = 0;

        const ticketTiles = this.template.querySelectorAll("c-ct_ticket-tile-v2");
        ticketTiles.forEach(element => {
            if (element.selectedTicketCount > 0) {
                this.hasAtleastOneticketSelected = true;
            }
        });

        if (!this.hasAtleastOneticketSelected) {
            this.customToastNotification('Error', 'Please select at least one ticket', true);
            return;
        }

        if (this.eventRecord.Consent_Required_to_Register__c && this.hasAgreedToConsentCapture !== 'Yes') {
            this.showConsentError = true;
            return;
        }

        if (this.isInternalComponent) {
            this.dispatchEvent(new CustomEvent('ticketselectionextevent', { detail: true, bubbles: true }));
        } else {
            const selectedTickets = this.handleNext();
            const ticketOrderObject = this.getOrderByDetails();

            if (parseInt(this.totalSelectedTickets) > this.selectedEvent.Event_Registrations_Available__c) {
                this.showTicketCountMessage = true;
                return;
            }

            if (this.validateForm() > 0 && ticketOrderObject && this.hasMinRequiredTickets < 1) {
                if (this.isGroupBooking) {
                    console.log('Step 1: Routing to Group Save');
                    this.handleGroupBookingSave(selectedTickets, ticketOrderObject);
                } else {
                    console.log('Step 1: Routing to Individual Summary');
                    this.proceedToIndividualDetails(selectedTickets, ticketOrderObject);
                }
            }
        }
    }

    // OLD GROUP BOOKING LOGIC (1 EVENT ORDER AND 1 EVENT REGISTRATION)
    // handleGroupBookingSave(selectedTickets, ticketOrderObject) {
        
    //     ticketOrderObject.isGroupBooking = true;
    //     ticketOrderObject.numberOfAttendees = this.totalSelectedTickets;
    //     let groupRegistration = [{
    //         firstName: ticketOrderObject.firstName,
    //         lastName: ticketOrderObject.lastName,
    //         email: ticketOrderObject.email,
    //         mobile: ticketOrderObject.mobile,
    //         ticketId: selectedTickets[0].ticketId,
    //         attendeeType: 'Group',
    //         allowDuplicate: true,
    //         hasDuplicateEventRegistration: false,
    //         eventRegistration: {},
    //         primaryAreaInterest: ''
    //     }];

    //     saveEventTicketOrder({
    //         ticketOrderAsJson: JSON.stringify(ticketOrderObject),
    //         eventRegistrationAsJson: JSON.stringify(groupRegistration),
    //         urlParamId: this.selectedEventId,
    //         asperatoId: '',
    //         sendOrderEmail: true,
    //         totalPrice: ticketOrderObject.totalPrice || 0,
    //         isInternal: this.isInternalComponent,
    //         isCheckInManager: this.isCheckInManagerComponent,
    //         internalRegData: '',
    //         consentgiven: this.hasAgreedToConsentCapture
    //     })
    //     .then(result => {
    //         this.ticket_Order_Id = result.ticketOrderId;
    //         let insertedRegs = result.eventRegistrationRecords;
    //         const canvas = this.template.querySelector('[data-id="QRCode"]');

    //         const qrPromises = insertedRegs.map(reg => {
    //             const sData = `${CHECK_IN_MANAGER_URL}/lightning/n/Check_In_QR_Code_Scanner?c__eventregid=${reg.Id}`;
                
    //             return QRCode.toCanvas(canvas, sData).then(() => {
    //                 const dataURL = canvas.toDataURL("image/png");
    //                 const convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");

    //                 reg.QR_Code__c = `<img src="data:image/jpeg;base64,${convertedDataURI}">`;
    //                 reg.QR_Code_URL__c = sData;
    //                 reg.Event_Order__c = this.ticket_Order_Id;
    //             });
    //         });

    //         return Promise.all(qrPromises).then(() => {
    //             return { insertedRegs, result };
    //         });
    //     })
    //     .then(data => {
    //         return invokedSaveQRCodeMethod({
    //             eventRegistrationAsJson: JSON.stringify(data.insertedRegs),
    //             isCheckInManager: this.isCheckInManagerComponent,
    //             internalRegData: '',
    //             eventRegToSessionIdsMap: JSON.stringify({}),
    //             eventRegPrimarySessionMap: JSON.stringify({})
    //         }).then(() => data.result); 
    //     })
    //     .then(finalResult => {
    //         console.log('Step 5: Process Complete. Calling handleSuccess now.');
    //         this.handleSuccess(finalResult);
    //         this.hideSpinner();
    //     })
    //     .catch(error => {
    //         this.hideSpinner();
    //         console.error('Group Save Error:', error);
    //         let message = error.body ? error.body.message : error.message;
    //         this.customToastNotification('Error', message, true);
    //     });
    // }

    showSpinner() { this.spinnerBoolean = true; }
    hideSpinner() { this.spinnerBoolean = false; }

    customToastNotification(title, message, isError) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: isError ? 'error' : 'success'
        }));
    }

    // handleGroupBookingSave(selectedTickets, ticketOrderObject) {
    //     console.log('Step 2: Inside Group Save Logic');
    //     this.showSpinner();

    //     try {
    //         // 1. Update Order Object values
    //         ticketOrderObject.isGroupBooking = true;
    //         ticketOrderObject.numberOfAttendees = this.totalSelectedTickets;

    //         // 2. Build the array of Multiple Anonymous Registrations
    //         let anonymousRegistrations = [];

    //         selectedTickets.forEach(ticketType => {
    //             // Ensure ticketCount is treated as an integer
    //             const count = parseInt(ticketType.ticketCount);
    //             for (let i = 0; i < count; i++) {
    //                 anonymousRegistrations.push({
    //                     firstName: null, 
    //                     lastName: null,
    //                     email: null,
    //                     mobile: null,
    //                     ticketId: ticketType.ticketId,
    //                     attendeeType: 'Unknown Guest', 
    //                     allowDuplicate: true,
    //                     hasDuplicateEventRegistration: false,
    //                     primaryAreaInterest: '',
    //                     eventRegistration: {
    //                         'Street__c': null,
    //                         'State_County__c': null,
    //                         'Zip_Postal_Code__c': null,
    //                         'Country__c': null,
    //                         'City__c': null,
    //                         'Address_Line_2__c': null
    //                     }
    //                 });
    //             }
    //         });

    //         console.log('Step 3: Calling saveEventTicketOrder with ' + anonymousRegistrations.length + ' records');

    //         // 3. Call Apex
    //         saveEventTicketOrder({
    //             ticketOrderAsJson: JSON.stringify(ticketOrderObject),
    //             eventRegistrationAsJson: JSON.stringify(anonymousRegistrations),
    //             urlParamId: this.selectedEventId,
    //             asperatoId: '', 
    //             sendOrderEmail: true,
    //             totalPrice: ticketOrderObject.totalPrice || 0,
    //             isInternal: this.isInternalComponent,
    //             isCheckInManager: this.isCheckInManagerComponent,
    //             internalRegData: '',
    //             consentgiven: this.hasAgreedToConsentCapture
    //         })
    //         .then(result => {
    //             console.log('Step 4: Apex Save Success. Generating QRs.');
    //             this.ticket_Order_Id = result.ticketOrderId;
    //             return this.generateMultiQRCodes(result.eventRegistrationRecords);
    //         })
    //         .then(finalResult => {
    //             console.log('Step 5: Process Complete. Redirecting.');
    //             this.handleSuccess(finalResult);
    //         })
    //         .catch(error => {
    //             this.hideSpinner();
    //             console.error('Apex Error:', error);
    //             let message = error.body ? error.body.message : error.message;
    //             this.customToastNotification('Error', message, true);
    //         });

    //     } catch (err) {
    //         console.error('JS Processing Error:', err.stack);
    //         this.hideSpinner();
    //         this.customToastNotification('Error', 'Javascript Error: ' + err.message, true);
    //     }
    // }

    // generateMultiQRCodes(insertedRegs) {
    //     const canvas = this.template.querySelector('[data-id="QRCode"]');
        
    //     // Validation: If canvas is missing, the code will crash with "getContext of null"
    //     if (!canvas) {
    //         console.error('QR Canvas element not found in DOM');
    //         return Promise.resolve({ ticketOrderId: this.ticket_Order_Id });
    //     }

    //     const qrPromises = insertedRegs.map(reg => {
    //         const sData = `${CHECK_IN_MANAGER_URL}/lightning/n/Check_In_QR_Code_Scanner?c__eventregid=${reg.Id}`;
            
    //         // Note: Ensure the library is globally available via window.QRCode or imported
    //         // eslint-disable-next-line no-undef
    //         return QRCode.toCanvas(canvas, sData).then(() => {
    //             const dataURL = canvas.toDataURL("image/png");
    //             const convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");

    //             reg.QR_Code__c = `<img src="data:image/jpeg;base64,${convertedDataURI}">`;
    //             reg.QR_Code_URL__c = sData;
    //             reg.Event_Order__c = this.ticket_Order_Id;
    //         });
    //     });

    //     return Promise.all(qrPromises).then(() => {
    //         return invokedSaveQRCodeMethod({ 
    //             eventRegistrationAsJson: JSON.stringify(insertedRegs),
    //             isCheckInManager: this.isCheckInManagerComponent,
    //             internalRegData: '',
    //             eventRegToSessionIdsMap: JSON.stringify({}),
    //             eventRegPrimarySessionMap: JSON.stringify({})
    //         }).then(() => { return { ticketOrderId: this.ticket_Order_Id }; });
    //     });
    // }

    handleGroupBookingSave(selectedTickets, ticketOrderObject) {
    console.log('Step 2: Inside Group Save Logic');
    this.showSpinner();

    try {
        ticketOrderObject.isGroupBooking = true;
        ticketOrderObject.numberOfAttendees = this.totalSelectedTickets;

        let anonymousRegistrations = [];
        selectedTickets.forEach(ticketType => {
            const count = parseInt(ticketType.ticketCount);
            for (let i = 0; i < count; i++) {
                anonymousRegistrations.push({
                    firstName: null, 
                    lastName: null,
                    email: null,
                    mobile: null,
                    ticketId: ticketType.ticketId,
                    attendeeType: 'Unknown Guest', 
                    allowDuplicate: true,
                    hasDuplicateEventRegistration: false,
                    primaryAreaInterest: '',
                    eventRegistration: {
                        'Street__c': null,
                        'State_County__c': null,
                        'Zip_Postal_Code__c': null,
                        'Country__c': null,
                        'City__c': null,
                        'Address_Line_2__c': null
                    }
                });
            }
        });

        console.log('Step 3: Calling saveEventTicketOrder');

        saveEventTicketOrder({
            ticketOrderAsJson: JSON.stringify(ticketOrderObject),
            eventRegistrationAsJson: JSON.stringify(anonymousRegistrations),
            urlParamId: this.selectedEventId,
            asperatoId: '', 
            sendOrderEmail: true,
            totalPrice: ticketOrderObject.totalPrice || 0,
            isInternal: this.isInternalComponent,
            isCheckInManager: this.isCheckInManagerComponent,
            internalRegData: '',
            consentgiven: this.hasAgreedToConsentCapture
        })
        .then(result => {
            console.log('Step 4: Apex Save Success. Updating status and generating QRs.');
            this.ticket_Order_Id = result.ticketOrderId;
            
            // --- NEW: Set status to Registered for all returned records ---
            let registrationsToUpdate = result.eventRegistrationRecords.map(reg => {
                return {
                    ...reg,
                    Event_Registration_Status__c: 'Registered'
                };
            });
            // -------------------------------------------------------------

            return this.generateMultiQRCodes(registrationsToUpdate);
        })
        .then(finalResult => {
            console.log('Step 5: Process Complete. Redirecting.');
            this.handleSuccess(finalResult);
        })
        .catch(error => {
            this.hideSpinner();
            console.error('Apex Error:', error);
            let message = error.body ? error.body.message : error.message;
            this.customToastNotification('Error', message, true);
        });

    } catch (err) {
        console.error('JS Processing Error:', err.stack);
        this.hideSpinner();
        this.customToastNotification('Error', 'Javascript Error: ' + err.message, true);
    }
}

    generateMultiQRCodes(insertedRegs) {
    const canvas = this.template.querySelector('[data-id="QRCode"]');
    
    if (!canvas) {
        console.error('QR Canvas element not found in DOM');
        return Promise.resolve({ ticketOrderId: this.ticket_Order_Id });
    }

    const qrPromises = insertedRegs.map(reg => {
        const sData = `${CHECK_IN_MANAGER_URL}/lightning/n/Check_In_QR_Code_Scanner?c__eventregid=${reg.Id}`;
        
        // eslint-disable-next-line no-undef
        return QRCode.toCanvas(canvas, sData).then(() => {
            const dataURL = canvas.toDataURL("image/png");
            const convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");

            // Attach QR data to the record that already has the 'Registered' status set
            reg.QR_Code__c = `<img src="data:image/jpeg;base64,${convertedDataURI}">`;
            reg.QR_Code_URL__c = sData;
            reg.Event_Order__c = this.ticket_Order_Id;
        });
    });

    return Promise.all(qrPromises).then(() => {
        // This call saves the Status ('Registered') and the QR Code in one transaction
        return invokedSaveQRCodeMethod({ 
            eventRegistrationAsJson: JSON.stringify(insertedRegs),
            isCheckInManager: this.isCheckInManagerComponent,
            internalRegData: '',
            eventRegToSessionIdsMap: JSON.stringify({}),
            eventRegPrimarySessionMap: JSON.stringify({})
        }).then(() => { return { ticketOrderId: this.ticket_Order_Id }; });
    });
}

    handleSuccess(result) {
        console.log('handleSuccess started for Order ID:', result.ticketOrderId);
        this.ticket_Order_Id = result.ticketOrderId;

        if (this.isCheckInManagerComponent) {
            this.dispatchEvent(new CustomEvent('eventregistered', { detail: true }));
        } else {
            getSuccessMessage({
                recordId: this.selectedEventId,
                isEventRecordId: true,
                eventOrderId: this.ticket_Order_Id
            })
            .then(successData => {
                console.log('Success Message Data:', JSON.stringify(successData));
                
                if (successData.REDIRECT_URL) {
                    console.log('Dispatching eventorderconfirmationdisplay');
                    const eventToParent = new CustomEvent('eventorderconfirmationdisplay', {
                        detail: { 
                            eventsearchdisplay: true,
                            selectedEventDisplay: false, 
                            eventOrderDisplay: false,
                            eventSummaryDisplay: false,
                            eventOrderConfirmation: true, 
                            ticketOrderId: this.ticket_Order_Id
                        },
                        bubbles: true,
                        composed: true
                    });
                    this.dispatchEvent(eventToParent);
                } 
                else {
                    console.log('No redirect URL, refreshing page with mode');
                    let queryString = window.location.href;
                    queryString = queryString + '&mode=nonPaidSuccess';
                    window.open(queryString, '_self');
                }
            })
            .catch(error => {
                console.error('getSuccessMessage Error:', error);
                this.customToastNotification('Error', 'Order saved but redirect failed.', true);
            })
            .finally(() => {
                this.hideSpinner();
            });
        }
    }

    redirectToSearchEvents(){
      const eventToParent = new CustomEvent('backeventsearchisplay', {
        detail: { eventsearchdisplay: false,
          selectedEventDisplay : false
        },
        bubbles: true,
        composed: true
        });
        this.dispatchEvent(eventToParent);
    }
    
    

    
}