import { LightningElement, track, wire, api } from 'lwc';
import getPickListValues from '@salesforce/apex/CT_EventSearchController.getPicklistValues';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Ct_eventSearchFormV2 extends LightningElement {
    eventName;
    eventType;
    eventGroup;
    eventTypeValues;
    showSearch = true;
    @api evtgroup;
    @track buttonStyle;
    connectedCallback(){
      console.log('Eventsearchform connected callback -----')
      getPickListValues({
        objectName: 'Event__c',
        fieldName: 'Event_Type__c'
      }).then(result => {
        console.log('Entered eventsearchform connected callback')
        this.eventTypeValues = result;
      }).catch(error => {
        console.log('Entered eventsearchform connected callback - Error');
        console.log(error.message)
        this.customToastNotification('Error', error, true);
      });
      if(this.evtgroup != undefined && this.evtgroup != null){
        console.log('evtgroup is ' + this.evtgroup);
        var searchObject = { eventName:this.eventName, eventType:this.eventType, eventGroup:this.evtgroup};

      this.dispatchEvent(new CustomEvent('search', { detail: searchObject }));
      }

      this.getButtonStyle();
      window.addEventListener('resize', this.getButtonStyle);
    }

    getButtonStyle = () => {
      if (window.outerWidth>=768) {
        this.buttonStyle='slds-grid slds-col slds-size_1-of-2 slds-grid_align-end';
      }  
      else {
        this.buttonStyle='slds-col slds-size_1-of-2';
      }
    };

    customToastNotification(toastTitle, toastMessage, isErrorMessage) {
      var messageString = isErrorMessage ? 'Error' : 'Success';
      const showToastEvent = new ShowToastEvent({
        Title: toastTitle,
        message: toastMessage,
        variant: messageString
      });
      this.dispatchEvent(showToastEvent);
    }

    handleEventName(event) {
      this.eventName = event.target.value;
    }

    handleEventType(event) {
      this.eventType = event.target.value;
    }

    handleGroupEvent(event) {
      this.eventGroup = event.detail;
    }

    handleSearch(event) {
      if(this.eventGroup != undefined){
        var stringurl = window.location.href;
        var newUrl = new URL(stringurl);
        var grpid = this.eventGroup ? this.eventGroup : ''; 
      }
      
      var searchObject = { eventName:this.eventName, eventType:this.eventType, eventGroup:this.eventGroup};

      this.dispatchEvent(new CustomEvent('search', { detail: searchObject }));
    }

    clearSearchTerms(event){
      this.eventName = '';
      this.eventType = '';
      this.eventGroup = '';
      this.template.querySelector('c-ct_event-group-lookup-v2').nullSearchValues();
    }
}