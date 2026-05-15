import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import cloneEvent from '@salesforce/apex/ct_EventStructureCloneController.cloneEventWithEventStructure';


export default class Ct_EventStructureClone extends NavigationMixin(LightningElement) {
  @api eventRecordId;
  @track showSpinnerBoolean = true;

  eventDetails = {};

  get mainHeadingStyle() {
    return 'color: #3C023C;font-size: 15px !important; font-weight: bold !important;'
  } 

  connectedCallback() {
    this.eventDetails = {"Event_Start_Date__c" : null, "Start_Time__c": null, "Event_End_Date__c" : null, "End_Time__c": null};
    this.hideSpinner();
  }

  
  handleEventDetailValueChange(event){
    if(!event.target.value){
      this.eventDetails[event.target.name] = null;
    }
    else{
      this.eventDetails[event.target.name] = event.target.value;
    }
  }

  handleCloneConfiramtion(event){
    this.showSpinner();
    if(this.validateForm('.cloneEventRequiredFields')){
      cloneEvent({
        eventId: this.eventRecordId,
        newEventDetails : JSON.stringify(this.eventDetails)
      })
      .then(result => {
        try {
          console.log('result>>>>>'+result);
          if(result){
            this.customToastNotification('Success', 'Event & Event Struture Cloned Successfully', false);
            this[NavigationMixin.Navigate]({
              type: 'standard__recordPage',
              attributes: {
                  "recordId": result,
                  "actionName": "view"
              }
          });
          }
        }
        catch(err) {
          this.customToastNotification('Error', err.message, true);
        }
      })
      .catch(error => {
        this.hideSpinner();
        this.customToastNotification('Error', error.body.message, true);
      });
    }
    else{
      this.hideSpinner();
    }
  }

  validateForm(validateType){
    const allValid = [...this.template.querySelectorAll(validateType)]
    .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    if(!allValid){
      return false;
    }
    else{
      return true;
    }
  }

  redirectToEventRecord() {
    this.showSpinner();
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            "recordId": this.eventRecordId,
            "actionName": "view"
        }
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
  
  showSpinner() {
    this.showSpinnerBoolean = true;
  }

  hideSpinner() {
    this.showSpinnerBoolean = false;
  }
}