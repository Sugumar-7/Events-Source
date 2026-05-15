import { LightningElement, api, track } from "lwc";
import formFactorPropertyName from '@salesforce/client/formFactor';
export default class Ct_ticketTileV2 extends LightningElement {
    @api eventTicket;
    @api selectedEvent;
    @api selectedTicketCount = 0;
    @api isOrderSummary = false;
    @api isInternalComponent = false;
    @api selectedTicketsFromTicketSelection;
    @api isTicketsAvailable;
    @track placeHolderText;
    @track comboBoxStyle;
    @track notAvailableStyle;
    @track currencyValue;
    @api setBackValues;
    get getDivBoxStyle(){
      return 'border: 2px solid black;'
   }

   get availableTickets() {
    let availableTickets = [];
    if(this.isOrderSummary){
      availableTickets.push( { label: "" + this.eventTicket.ticketCount, value: "" + this.eventTicket.ticketCount });
    }
    else{
      availableTickets.push({ label: "--None--", value: "--None--"});
      let count = this.eventTicket.Quantity_Remaining__c > this.eventTicket.Max_Product_per_Order__c ? this.eventTicket.Max_Product_per_Order__c :this.eventTicket.Quantity_Remaining__c;
      
      // if(this.selectedEvent && this.selectedEvent.Event_Registrations_Available__c){
      //   count = count >= this.selectedEvent.Event_Registrations_Available__c ? this.selectedEvent.Event_Registrations_Available__c : count;
      // } 

      let initialTicketCount =  this.eventTicket.Minimum_Products_Per_Order__c ? this.eventTicket.Minimum_Products_Per_Order__c : 1;
      for (let i = initialTicketCount; i <= count; i++) {
        availableTickets.push({ label: "" + i, value: "" + i });
      }
    }
    return availableTickets;
}

   connectedCallback(){
    
    console.log('Entered connectedCallback in ticketTileV2');
    this.isTicketsAvailable = this.eventTicket.Quantity_Remaining__c != null && this.eventTicket.Quantity_Remaining__c != undefined && this.eventTicket.Quantity_Remaining__c > 0;
    var queryString = window.location.href;
    var urlVar = new URL(queryString);
    this.eventId = urlVar.searchParams.get("id");
    if(this.setBackValues)
      {
        var dummy = JSON.parse(this.setBackValues);
        var selectedTickets = JSON.parse(dummy.selectedTickets);
      }
    //var selectedTickets = JSON.parse(urlVar.searchParams.get("selectedTickets"));
    if(this.isInternalComponent){
      selectedTickets =  this.selectedTicketsFromTicketSelection;
    }

    if(selectedTickets){
        selectedTickets.forEach(ticketVal =>{
          
          if(this.eventTicket.Id == ticketVal.ticketId){
            this.selectedTicketCount = ticketVal.ticketCount;
          }
        }); 
      }

      //This is to get the placeholder based on window width
      this.getPlaceHolder();
      window.addEventListener('resize', this.getPlaceHolder);
      if(this.eventTicket.Event_Product_Price__c != undefined){
         if((this.eventTicket.Event_Product_Price__c - Math.floor(this.eventTicket.Event_Product_Price__c)) == 0){
            this.currencyValue = parseInt(this.eventTicket.Event_Product_Price__c); 
         }
         else{
            this.currencyValue = parseFloat(this.eventTicket.Event_Product_Price__c).toFixed(2);
         }
      }
      else if(this.eventTicket.ticketPrice != undefined){
        if((this.eventTicket.ticketPrice - Math.floor(this.eventTicket.ticketPrice)) == 0){
           this.currencyValue = parseInt(this.eventTicket.ticketPrice); 
        }
        else{
           this.currencyValue = parseFloat(this.eventTicket.ticketPrice).toFixed(2);
        }
      }
      
    }
    getPlaceHolder = () => {
      if (window.outerWidth>750) {
        this.placeHolderText= 'Select an Option';
        this.comboBoxStyle='slds-col slds-size--2-of-6 slds-p-around--x-small slds-p-left_none fieldLabelStyle';
        this.notAvailableStyle='slds-col slds-size--2-of-6 slds-p-around--x-small fieldLabelStyle';
      }
      else {  
        this.placeHolderText= 'Select';
        this.comboBoxStyle='slds-col slds-size--3-of-6 slds-p-around--x-small slds-p-left_none fieldLabelStyle';
        this.notAvailableStyle='slds-col slds-size--2-of-6 slds-p-around--x-small slds-p-left_none fieldLabelStyle';
      }
    };

    @api 
    checkValidity() {
      if(this.isTicketsAvailable){


        var inputCmp = this.template.querySelector(".ticketFields");
        var value = inputCmp.value;
        if(this.eventTicket.Minimum_Products_Per_Order__c){

        

          if(!this.selectedTicketCount || this.eventTicket.Minimum_Products_Per_Order__c > this.selectedTicketCount
            || !value || value == '--None--' || value == '0'){
   
            inputCmp.setCustomValidity('Please choose the minimum quantity '+this.eventTicket.Minimum_Products_Per_Order__c+' for this ticket');
            inputCmp.reportValidity(); 
            return false;
          }
          else{
            
            inputCmp.setCustomValidity("");
            inputCmp.reportValidity(); 
            return true;
          }
        }
        else if (!value || value == '--None--' || value == '0') {
          inputCmp.value = null;
          inputCmp.setCustomValidity("");
          inputCmp.reportValidity(); 
          return false;
        } 
        else {
          return true;
        }
    } 
  }

    
    

    handleTicketCountChange(event) {
        this.selectedTicketCount = event.detail.value;
    }
    
}