/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 01-04-2021
 * @last modified by  : Umashankar Creation
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   01-04-2021   Umashankar Creation   Initial Version
**/
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import fetchEventAndTickets from "@salesforce/apex/CT_EventSearchController.fetchEventAndTicketsForInternalComponent";

export default class Ct_InternalEventRegistrationForm extends NavigationMixin(LightningElement) {
    @api eventRecordId;
    @api sobjectAPIName;
    @api isCheckInManagerComponent;
    @api selectedSessionId;
    @track eventTickets;
    @track showTicketOrderForm = false;
    @track selectedTickets = [];
    @track showSpinnerBoolean = true;
    @track showForm = false;
    @track internalRegistrationFormData = {};
    //Internal Registration Upgrade
    @track showTicketSelection = false;
    @track showEventOrderDetails = false;
    @track showTicketOrderSummary = false;

    @track hasScrolledToTop = false;

    @track ticket_Selection_selectedTickets;
    @track ticket_Selection_orderBy;

    @track event_Order_Details_ticket;
    @track event_Order_Details_OrderedTickets;
    @track selectedEventRec;
    @track isBackfromOrderSummary = false;
    

    


    get mainHeadingStyle() {
        return 'color: #3C023C;font-size: 15px !important; font-weight: bold !important;'
    }   

    get showForceCheckinStatusOption(){
        return (this.isCheckInManagerComponent && this.showTicketSelection)
    }


    @wire(fetchEventAndTickets, { recordId: "$eventRecordId"})
    wiredEvent({ error, data }) {
        if (data) {
            this.selectedEventRec = data;
            this.eventTickets = this.selectedEventRec.Tickets__r;

        } else if (error) {
            this.customToastNotification('Error', error.body.message, true);
        }
    }

    connectedCallback() {
        console.log('Enter connectedCallback in ct_InternalEventRegistrationForm');
        this.showForm = true;
        this.hideSpinner();
        this.internalRegistrationFormData = {"setEventRegCheckedIn" : true, "checkInManagerSelectedSessionId" : this.selectedSessionId};
        //Internal Registration Update
        this.showTicketSelection = true;
        
    }

    renderedCallback(){
        if(!this.hasScrolledToTop){
            this.hasScrolledToTop = true;
            this.customScrollToTop();
        }
    }

    //Internal Registration Update Start
    showOrderDetails(){
    

        
        this.showSpinner();
        let ticketSelectionObject = this.template.querySelector('c-ct_ticket-selection');
        

        let selectedTickets = ticketSelectionObject.handleNext();
        let ticketOrderObject = ticketSelectionObject.getOrderByDetails();

        if(ticketSelectionObject.validateForm() > 0 && ticketOrderObject && ticketSelectionObject.hasMinRequiredTickets < 1){
            
            this.ticket_Selection_selectedTickets = selectedTickets;
            this.ticket_Selection_orderBy         = ticketOrderObject;
            this.showTicketSelection = false;
            this.showEventOrderDetails = true;
            this.showTicketOrderSummary = false;
            this.customScrollToTop();
        }  
        this.hideSpinner();
    }

    customScrollToTop() {
        let target = this.template.querySelector(`[data-id="topElement"]`);
        target.scrollIntoView();
    }

    ticketOrderSummaryTop() {
        
        let target = this.template.querySelector(`[data-id="ticketordersummarylwc"]`);
        window.scrollTo(0, 0);

    }

    handleTicketSummaryBackButton(event){
        this.event_Order_Details_OrderedTickets = event.detail.orderedTickets;
        this.isBackfromOrderSummary = true;

        this.showEventOrderDetails = true;
        this.showTicketOrderSummary = false;
        this.showTicketSelection = false;
    }

    handleEventOrderDetailPreviousButton(event){
        this.isBackfromOrderSummary = false;
        this.showEventOrderDetails = false;
        this.showTicketOrderSummary = false;
        this.showTicketSelection = true;
    }

    handleEventOrderDetailNextButton(event){
        this.event_Order_Details_ticket = event.detail.tickets;
        this.event_Order_Details_OrderedTickets = event.detail.orderedTickets;
        this.showEventOrderDetails = false;
        this.showTicketSelection = false;
        this.showTicketOrderSummary = true;
       
    }
    //Internal Registration Update End


    handleTicketConfirm() {
        this.showSpinner();
    
        try {
            let requiredTickets = [];
            let ticketTiles = this.template.querySelectorAll("c-ct_ticket-tile");
            for (let i = 0; i < ticketTiles.length; i++) {
                let eachTicket = ticketTiles[i].eventTicket;

                if (ticketTiles[i].selectedTicketCount != null &&
                    ticketTiles[i].selectedTicketCount != undefined &&
                    ticketTiles[i].selectedTicketCount > 0) {
                    requiredTickets.push({
                       
                        eventId: this.selectedEventId,
                            ticketId: eachTicket.Id,
                            Name: eachTicket.Name,
                            Event_Product_Description__c: eachTicket.Event_Product_Description__c,
                            ticketCount: ticketTiles[i].selectedTicketCount,
                            ticketPrice: ticketTiles[i].eventTicket.Event_Product_Price__c,
                            totalPrice: parseInt(ticketTiles[i].selectedTicketCount) * parseInt(ticketTiles[i].eventTicket.Event_Product_Price__c)
                      
                    });
                }

            }
            this.selectedTickets = requiredTickets;
            if (requiredTickets.length == 0) {
                this.customToastNotification('Error', 'Please select required tickets from available tickets', true);
            } else {
                this.showTicketOrderForm = true;

            }
            this.hideSpinner();



        } catch (error) {
            this.customToastNotification('Error', error.body.message, true);
        }
    }

    showSpinner() {
        this.showSpinnerBoolean = true;
    }

    hideSpinner() {
        this.showSpinnerBoolean = false;
    }

    handleInternalRegFormData(event) {
        this.internalRegistrationFormData[event.target.name] = event.target.checked;
    }


    customToastNotification(toastTitle, toastMessage, isErrorMessage) {
        this.showSpinnerBoolean = false;
        var messageString = isErrorMessage ? 'Error' : 'Success';
        const showToastEvent = new ShowToastEvent({
            Title: toastTitle,
            message: toastMessage,
            variant: messageString
        });
        this.dispatchEvent(showToastEvent);
    }
    redirectToEventRecord() {
        this.showSpinner();

        if(this.isCheckInManagerComponent){
            this.hideSpinner();
            this.triggerEventregisteredCustomEvent();
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    "recordId": this.eventRecordId,
                    "actionName": "view"
                }
            });
        }
    }

    handleTicketOrderFormBack(){
        this.showTicketOrderForm = false;
    }

    triggerEventregisteredCustomEvent() {
        const cancelEvent = new CustomEvent('eventregistered', { detail: true });
        this.dispatchEvent(cancelEvent);
    }
}