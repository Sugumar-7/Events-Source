import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';


export default class Ct_EventListingParentV2 extends LightningElement {

    @api showSearch = false;
    @api showSelectedEvent = false;
    @api showEventOrder = false;
    @api showEventOrderSummaryDisplay = false;
    @api showOrderConfirmation = false;
    @api showTicketManagement = false;
    @api showSessionManagement = false;
    @api redirectionState;
    @api redirectionOrderState;
    @api selectedeventId;
    @api ticketConfirmationOrderId;
    @api eventRegistrationRecordId;
    @api sessionRegister = false;
    @api setBackValues;


    @api showBackButton = false;

    @api isSimpleEvent;

    eventregId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
      
       if (currentPageReference) {
          this.eventregId = currentPageReference.state?.regId;
          console.log('eventregId: ' + this.eventregId);
       }
       if(this.eventregId){
          this.eventRegistrationRecordId = this.eventregId;
          this.showTicketManagement = true;
          this.showSearch = true;
          this.showBackButton = true;
          console.log('eventRegistrationRecordId: ' + this.eventRegistrationRecordId);
          console.log('this.showTicketManagement: ' + this.showTicketManagement);
          console.log('this.showSearch: ' + this.showSearch);
       }
       
    }


    
    //To show the selected event page
    handleSelectedEventDisplay(event) {
        this.showSearch = event.detail.eventsearchdisplay; 
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.selectedeventId = event.detail.eventId;
    }

    //to show the event order details page
    handleEventOrderDisplay(event) {
        this.showSearch = event.detail.eventsearchdisplay; 
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.redirectionState = event.detail.setRedirectionState;
        this.showEventOrder = event.detail.eventOrderDisplay;
    }

    //to show the event order summary page
    handleEventOrderSummaryDisplay(event) {
        this.showSearch = event.detail.eventsearchdisplay; 
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.redirectionOrderState = event.detail.setRedirectionOrderState;
        this.showEventOrder = event.detail.eventOrderDisplay;
        this.showEventOrderSummaryDisplay = event.detail.eventSummaryDisplay;
    }

    //to show the event order confirmation page
    handleEventOrderConfirmationDisplay(event) {
        this.showSearch = event.detail.eventsearchdisplay; 
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.showEventOrder = event.detail.eventOrderDisplay;
        this.showEventOrderSummaryDisplay = event.detail.eventSummaryDisplay;
        this.showOrderConfirmation = event.detail.eventOrderConfirmation;
        this.ticketConfirmationOrderId = event.detail.ticketOrderId;
    }

    //to show the ticket management page
    handleTicketManagementDisplay(event) {
        this.showSearch = event.detail.eventsearchdisplay; 
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.showEventOrder = event.detail.eventOrderDisplay;
        this.showEventOrderSummaryDisplay = event.detail.eventSummaryDisplay;
        this.showOrderConfirmation = event.detail.eventOrderConfirmation;
        this.showTicketManagement = event.detail.eventTicketmanagement;
        this.eventRegistrationRecordId = event.detail.eventRegisteredRecordId;
        this.isSimpleEvent = event.detail.isSimpleEvent;
    }

    //to show the session management page
    handleSessionManagementDisplay(event) {
        this.showSearch = event.detail.eventsearchdisplay; 
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.showEventOrder = event.detail.eventOrderDisplay;
        this.showEventOrderSummaryDisplay = event.detail.eventSummaryDisplay;
        this.showOrderConfirmation = event.detail.eventOrderConfirmation;
        this.showTicketManagement = event.detail.eventTicketmanagement;
        this.eventRegistrationRecordId = event.detail.eventRegisteredRecordId;
        this.sessionRegister = event.detail.sessionReg;
        this.showSessionManagement = event.detail.eventSessionManagement;
    }

    //to navigate from selected tickct page to event search page
    handleClickBackEventSearchDisplay(event) {
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.showSearch = event.detail.eventsearchdisplay;        

    }

    //to navigate from event order details page to selected event page
    handleClickBackTicketSelectionDisplay(event) {
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.showEventOrder = event.detail.eventOrderDisplay;
        this.setBackValues = event.detail.setBackRedirectionState;        

    }

    //to navigate from event order summary page to event order details page
    handleClickBackOrderDetailsDisplay(event){
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.showEventOrder = event.detail.eventOrderDisplay;  
        this.showEventOrderSummaryDisplay = event.detail.eventSummaryDisplay;
        this.redirectionState = event.detail.setRedirectionState;
    }

    //to navigate from ticket management page to event order confirmation page
    handleClickBackEventOrderConfirmationDisplay(event)

    {
        this.showSearch = event.detail.eventsearchdisplay; 
        this.showSelectedEvent = event.detail.selectedEventDisplay;
        this.showEventOrder = event.detail.eventOrderDisplay;
        this.showEventOrderSummaryDisplay = event.detail.eventSummaryDisplay;
        this.showOrderConfirmation = event.detail.eventOrderConfirmation;
        this.showTicketManagement = event.detail.eventTicketmanagement;   
        this.showSessionManagement = event.detail.eventSessionManagement;
    }

    //logic to scroll to top
     customScrollToTop() {
        let target = this.template.querySelector(`[data-id="topElement"]`);
        target.scrollIntoView();
    }

    connectedCallback() {
        console.log('Entered connected callback 2');
        window.history.pushState(null, '', window.location.href);
        window.addEventListener('beforeunload', this.handleBeforeUnload);
    }

    //prevent user from naviating to prev page using browser navigation
    handleBeforeUnload = (event) => {
        event.preventDefault();
    };

}