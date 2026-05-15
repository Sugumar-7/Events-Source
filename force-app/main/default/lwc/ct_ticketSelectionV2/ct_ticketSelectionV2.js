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

import fetchEventAndTickets from "@salesforce/apex/CT_EventSearchController.fetchEventAndTickets";

export default class Ct_ticketSelectionV2 extends NavigationMixin(LightningElement) {
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

    totalSelectedTickets = 0;
    @api hasMinRequiredTickets = 0;

    // isRederedScrolledToTop = false;
    @track eventRegId;
    @track campaignRefId;
    
    eventId;
    error;
    ticketsCloseMessage = 'Registration for this event is closed';
    //Internal reg Upgrade
    @api orderBy;
    //fieldsForRecordEditForm = ['Name', 'Registration_Type__c', 'Status__c', 'CurrencyIsoCode', 'Event__c', 'Event_Product__c', 'Enquirer__c', 'Contact__c', 'Account_Name__c', 'Event_Order__c', 'Session_Registration_URL__c'];
    @api setBackRedirectionValues;
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
      return this.template.querySelector('c-ct_ticket-order-form-v2').handleDisplaySummary();
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
            var ticketSelectionObject = this.template.querySelector('c-ct_ticket-selection-v2');
            this.totalSelectedTickets = 0;
            this.hasMinRequiredTickets = 0;

            var ticketSelectionObject = this.template.querySelector('c-ct_ticket-selection-v2');

            var selectedTickets = this.handleNext();
            if(parseInt(this.totalSelectedTickets) > this.selectedEvent.Event_Registrations_Available__c){
              this.showTicketCountMessage = true;
            }
            else{
              var ticketOrderObject = this.getOrderByDetails();
            if(this.validateForm() > 0 && ticketOrderObject && this.hasMinRequiredTickets < 1){
            
              var redirectionState = {};
              redirectionState['selectedTickets'] = JSON.stringify(selectedTickets);
              redirectionState['orderBy'] = JSON.stringify(ticketOrderObject);
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

              const eventToParent = new CustomEvent('eventorderdisplay', {
                detail: { eventsearchdisplay: true,
                  selectedEventDisplay : false, 
                  eventOrderDisplay : true,
                  setRedirectionState : this.redirectionState
                },
                bubbles: true,
                composed: true
                });
                this.dispatchEvent(eventToParent);
              } 
            }
            
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