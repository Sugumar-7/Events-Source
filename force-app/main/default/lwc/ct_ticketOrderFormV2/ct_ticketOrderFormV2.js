import { LightningElement, api, track } from "lwc";
import formFactorPropertyName from '@salesforce/client/formFactor'; 
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import fetchEventProductDetails from "@salesforce/apex/CT_EventSearchController.fetchEventProductDetails";
import fetchEventOrderDetails from "@salesforce/apex/CT_EventSearchController.fetchEventOrderDetails";

//import getSessionAsPicklistValues from "@salesforce/apex/CT_EventSearchController.getSessionAsPicklists";

export default class Ct_ticketOrderFormV2 extends LightningElement {
    @api firstName;
    @api lastName;
    @api email;
    @api selectedEvent;
    //ticketDelivery = 'eTicket only';
    //receiveSMSnotification = false;
    mobile;
    street;
    city;
    state;
    country;
    postcode;
    
    //isAddressVisible = false;
    isRederedScrolledToTop = false;
    isAddressFieldChanged = false;
    isManualRegistration = false;
    @api eventId;
    @api selectedTickets;
    @api isInternalComponent = false;
    @api isCheckInManagerComponent;
    @api internalRegistrationFormData;
    @track selectedEvtProductId;
    @track eventRegId;
    @track campaignRefId;
    @track ordId;
    @track eventRegHasOrder = false;
    dynamicSessionData;
    @track canRenderTicketForm = false;
    displaySummary = false;
    // formTitle = "Event Order";
    formDescription = "<p>Please add details for the person ordering the tickets & each attendee below. You will receive an Order Confirmation Email along with your tickets following submission.</p><p class='slds-p-top--xx-small'>Each named attendee will also receive an email with a link to there own ticket.</p>"
    //formNote = "Please make sure to enter a unique email address for each attendee."
    @api orderedBy;
    orderedTickets;
    @api setBackValues;

    // get disableAddressField() {
    //     return (this.displaySummary && !this.isAddressFieldChanged);
    // }

    handleFirstName(event) {
        this.firstName = event.target.value;
    }

    handleLastName(event) {
        this.lastName = event.target.value;
    }

    handleEmail(event) {
        this.email = event.target.value;
    }

    // get options() {
    //     return [
    //         { label: 'eTicket only', value: 'eTicket only' , }
    //         // { label: 'eTicket & Printed Ticket', value: 'eTicket & Printed Ticket' },
    //     ];
    // }

    get formTitle() {
        return this.displaySummary ? 'Order Summary' : 'Event Order';
    }
    get subFormTitle(){
        return this.displaySummary ? 'Ordered By' : 'Contact Information';
    }
    
    // get isMobileVisible(){
    //     return this.receiveSMSnotification;
    // }
    
    get formNote(){
        return this.displaySummary ? 'Before placing the order please check the details shown below' : 'Please make sure to enter a unique email address for each attendee.';
    }

    connectedCallback(){
      console.log('Entered connectedCallback in ticketOrderFormV2');
      /*Get Id from the URL To Load A particular Event Product*/
      var urlParams = window.location.href;
      var thisURL = new URL(urlParams);
        var orderBy;

    if(this.isInternalComponent){
        orderBy = this.orderedBy;
    }
    else{
        if(this.setBackValues)
        {
          var dummy = JSON.parse(this.setBackValues);
          var orderBy = JSON.parse(dummy.orderBy);
        }
        //orderBy = JSON.parse(thisURL.searchParams.get("orderedBy"));
    }

    if(orderBy){
      this.firstName = orderBy.firstName;
      this.lastName = orderBy.lastName;
      this.email = orderBy.email;
      this.mobile = orderBy.mobile;
      this.eventId = orderBy.eventId;
      this.mobile = orderBy.mobile;
      this.street = orderBy.street;
      this.city = orderBy.city;
      this.state = orderBy.state;
      this.country = orderBy.country;
      this.postcode = orderBy.postcode;
      this.eventRegHasOrder = orderBy.eventRegHasOrder;
     // this.receiveSMSnotification = orderBy.receiveSMSnotification;
      //this.ticketDelivery = orderBy.ticketDelivery;
    }

    if(urlParams.indexOf('eventRegId') > -1){
      this.eventRegId = thisURL.searchParams.get("eventRegId");
    }
    if(urlParams.indexOf('manualRegistration') > -1){
      if(thisURL.searchParams.get("manualRegistration")
      && thisURL.searchParams.get("manualRegistration") != null
      && thisURL.searchParams.get("manualRegistration") != undefined
      && thisURL.searchParams.get("manualRegistration").trim()){
        this.isManualRegistration = thisURL.searchParams.get("manualRegistration");
      }
     
      
    }
    if(urlParams.indexOf('campaignRefId') > -1){
      this.campaignRefId = thisURL.searchParams.get("campaignRefId");
    }

    var eventRegIdToFetch = this.eventRegId ? this.eventRegId : this.campaignRefId;

      if(urlParams.indexOf('evtProdId') > -1){
        this.selectedEvtProductId =  thisURL.searchParams.get("evtProdId");
      }
      if(eventRegIdToFetch){
        fetchEventProductDetails({
          eventRegistrationId: eventRegIdToFetch
        }
        ).then(result => {
          if(result.Event_Order__c){
            this.firstName = result.Event_Order__r.First_Name__c;
            this.lastName = result.Event_Order__r.Last_Name__c;
            this.email = result.Event_Order__r.Email__c;
            this.mobile = result.Event_Order__r.Mobile__c;
            this.street = result.Event_Order__r.Street__c;
            this.city = result.Event_Order__r.City__c;
            this.state = result.Event_Order__r.State__c;
            this.postcode = result.Event_Order__r.Post_code__c;
            this.country = result.Event_Order__r.Country__c;
            this.eventRegHasOrder = true;
          }
          else{
            if(result){
              this.firstName = result.First_Name__c;
              this.lastName = result.Last_Name__c;
              this.email = result.Event_Email__c;
              this.mobile = result.Event_Mobile__c;
              this.street = result.Street__c;
              this.city = result.City__c;
              this.state = result.State_County__c;
              this.postcode = result.Zip_Postal_Code__c;
              this.country = result.Country__c;
              this.eventRegHasOrder = false;
            }
          }

        }).catch(error => {
          console.log('Error @ ticketOrderForm: ' + error);
          this.customToastNotification('Error', error, true);
        });
      }

      if(urlParams.indexOf('ordId') > -1){
        this.ordId = thisURL.searchParams.get("ordId");
        fetchEventOrderDetails({ordId: this.ordId})
        .then(result => {
            if(result != undefined && result != null){
               
              this.firstName = result.First_Name__c;
              this.lastName = result.Last_Name__c;
              this.email = result.Email__c;
              this.eventRegHasOrder = true;
            }
            else{
              this.eventRegHasOrder = false;
            }
  
          }).catch(error => {
            this.customToastNotification('Error', error, true);
          });
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

    
    handleMobile(event){
        this.mobile = event.detail.value;
    }
    handleStreet(event){
        this.street = event.detail.value;
    }
    handleCity(event){
        this.city = event.detail.value;
    }
    handleState(event){
        this.state = event.detail.value;
    }
    handleCountry(event){
        this.country = event.detail.value;
    }
    handleCountrySelect(event){
        this.country = event.detail;
    }
    handlePostCode(event){
        this.postcode = event.detail.value;
    }
    countryValue;
    stateValue;

    handleCountryChange(event) {
        this.country = event.detail;
        console.log('countryValue>>>'+this.country);
    }

    handleStateChange(event) {
        this.state = event.detail;
        console.log('stateValue>>>'+this.state);
    }

    

    get getFormFactor(){
        let isMobile;
        if (formFactorPropertyName === 'Small') {
          isMobile = true;
        }
        return isMobile;
      }
    get ticketForms() {

        let data = this.template.querySelector("c-ct_event-search-v2");
        let ticketForms = [];
        let totalTickets = 0;
        for (let i = 0; i < this.selectedTickets.length; i++) {
            for (let j = 0; j < parseInt(this.selectedTickets[i].ticketCount); j++) {
               
                ++totalTickets;
                ticketForms.push({
                    ticketId: this.selectedTickets[i].ticketId,
                    name: this.selectedTickets[i].Name,
                    ticketNumber: totalTickets,
                    ticketName: 'Ticket'+totalTickets,
                    allGuestRegistrations: this.selectedTickets[i].allowGuestRegistrations

                });
            }
        }
        return ticketForms;
    }

    renderedCallback(){
      
      var countryElement =  this.template.querySelector('c-ct_-country-picklist-v2');
      if(countryElement){
        countryElement.selectedCountryString = this.country;
      }

        
    }

    handlePrevPage(event){
        if(this.isCheckInManagerComponent){
            const backEvent = new CustomEvent('ticketorderformback', { detail: true });
            this.dispatchEvent(backEvent);
        }
        else{
            var queryString = window.location.href;
            queryString = queryString.split('?')[0];
            var urlVar = new URL(queryString);
            var openREcDetailpageURL = urlVar+'?id='+this.eventId;
            window.open(openREcDetailpageURL, '_self');
            console.log('ticketorderformcopyopen');
        }
    }

    handleOrderSummaryBack(event){
        //this.customScrollToTop();
        var seletedAddress = event.detail;
        this.isAddressFieldChanged = false;
        this.displaySummary = false;
    }

    

    @api
    handleDisplaySummary() {
        //this.customScrollToTop();
        const allValid = [...this.template.querySelectorAll('.ticketOrderField')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (!allValid) {
            const inputComponents = [...this.template.querySelectorAll('.ticketOrderField')].find(cmps => cmps.required && !cmps.value || !cmps.reportValidity());
            var ios = navigator.platform && /iPad|iPhone|iPod/.test(navigator.platform);
            if(!ios){
                inputComponents.focus();
            }
          }
         else if (this.selectedEvent.Order_Address_Fields_Mandatory__c && !this.country) {
            var inputComponents = this.template.querySelector(`[data-id="countryElement"]`);
            var ios = navigator.platform && /iPad|iPhone|iPod/.test(navigator.platform);
            if(!ios){
                inputComponents.focus();
            }
            this.template.querySelector('c-ct_-country-picklist-v2').isCountrySelected();
        }
        if (allValid) {
            //this.formTitle = "Order Summary";
            this.orderedBy = {
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                eventId: this.eventId,
                mobile: this.mobile,
                street: this.street,
                city: this.city,
                state: this.state,
                country: this.country,
                postcode: this.postcode,
                eventRegHasOrder: this.eventRegHasOrder,
                ordId: this.ordId,
                isDiscountedOrder: false
            };
            
        }

        return this.orderedBy;
    }

    

    customScrollToTop() {
        let target = this.template.querySelector(`[data-id="topElement"]`);
        target.scrollIntoView();
    }

    handleConfirmOrder(event) {
    }

    triggerEventregisteredCustomEvent() {
        const cancelEvent = new CustomEvent('eventregistered', { detail: true });
        this.dispatchEvent(cancelEvent);
    }
}