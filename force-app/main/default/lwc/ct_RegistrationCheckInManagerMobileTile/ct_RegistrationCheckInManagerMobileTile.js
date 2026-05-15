/**
 * @description       : 
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 01-22-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   01-22-2021   Creation Admin   Initial Version
**/
import { LightningElement , api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateEventRegistration from '@salesforce/apex/ct_CheckInManagerController.updateEventRegistrationStatus';
import updateSessionRegCheckInStatus from '@salesforce/apex/ct_CheckInManagerController.updateSessionRegistrationStatus';
import formFactorPropertyName from '@salesforce/client/formFactor';

import EVENT_REGISTRATION_FIRST_NAME from '@salesforce/schema/Event_Registration__c.First_Name__c';
import EVENT_REGISTRATION_LAST_NAME from '@salesforce/schema/Event_Registration__c.Last_Name__c';
import EVENT_REGISTRATION_EVENT_EMAIL from '@salesforce/schema/Event_Registration__c.Event_Email__c';

export default class Ct_RegistrationCheckInManagerMobileTile extends NavigationMixin(LightningElement) {
  @api isMainEntrance;
  @api eventRegistration;
  //FOR CUSTOM ERROR TOAST
  customToastTitle = 'Error';
  customToastMessage = 'Error';
  customMessageVariant = 'error';

  recordEditFormRecordId      = '';
  recordEditFormObjectApiName = 'Event_Registration__c';

  recordEditFormFields = [EVENT_REGISTRATION_FIRST_NAME, EVENT_REGISTRATION_LAST_NAME, EVENT_REGISTRATION_EVENT_EMAIL];

  showRecordForm   = false;
  isRegistered    = false;
  isCheckedIn     = false;
  isCheckedOut    = false;
  isdidNotAttend  = false;
  isUpdating      = false;

  isEventRegRegistered    = false;
  isEventRegCheckedIn     = false;
  isEventRegCheckedOut    = false;
  isEventRegDidNotAttend  = false;
  showConfirmationPanel   = false;

  statusToConstantMap ={}

  get eventRegId(){
    return this.isMainEntrance ? this.eventRegistration.Id : this.eventRegistration.Event_Registration__r.Id;
  }

  get isMobileDevice(){
    return (formFactorPropertyName === 'Large') ? false : true;
  }

  get databooleanname(){
    var registrationStatus = this.isMainEntrance ? this.eventRegistration.Event_Registration_Status__c : this.eventRegistration.Status__c;
    var dataBooleanNameVar ='';
      switch (registrationStatus) {
        case 'Registered':
          dataBooleanNameVar = 'isCheckedIn';
          break;
        case 'Attended / Checked In':
          dataBooleanNameVar = 'isCheckedOut';
          break;
        case 'Attended / Checked Out':
          dataBooleanNameVar = 'isdidNotAttend';
          break;
        case 'Did Not Attend':
            dataBooleanNameVar = 'isdidNotAttend';
      }
    return dataBooleanNameVar;
  }
  
  get confirmationButtonStyle(){
    return  'color: white !important; width:100% !important; text-align :center !important ;border-radius: 0px;background: #4585F4 !important;border-color: #4585F4 !important;';
  }

  get nextStatusName(){

    var registrationStatus = this.isMainEntrance ? this.eventRegistration.Event_Registration_Status__c : this.eventRegistration.Status__c;

    var nextStatusNameVar ='';
      switch (registrationStatus) {
        case 'Registered':
          nextStatusNameVar = 'Check In';
          break;
        case 'Attended / Checked In':
          nextStatusNameVar = 'Check Out';
          break;
        case 'Attended / Checked Out':
          nextStatusNameVar = 'Did Not Attend';
          break;
        case 'Did Not Attend':
            nextStatusNameVar = 'Did Not Attend';
      }
    return nextStatusNameVar;
  }
  
  get eventOrderId(){
    var eventOrdId =''
    if(this.isMainEntrance
      && this.eventRegistration.Event_Order__c != null && this.eventRegistration.Event_Order__c != undefined){
        eventOrdId = this.eventRegistration.Event_Order__r.Id;
    }
    else if(!this.isMainEntrance
      && this.eventRegistration.Event_Registration__r.Event_Order__c != null 
      && this.eventRegistration.Event_Registration__r.Event_Order__c != undefined){
        eventOrdId = this.eventRegistration.Event_Registration__r.Event_Order__c;
      }
    return eventOrdId;
  }

  get eventRegname(){
    var regName ='Guest';
    if(this.isMainEntrance
      && this.eventRegistration.Name__c != null && this.eventRegistration.Name__c != undefined){
        regName = this.eventRegistration.Name__c;
    }
    else if(!this.isMainEntrance
      && this.eventRegistration.Event_Registration__r.Name__c != null 
      && this.eventRegistration.Event_Registration__r.Name__c != undefined){
        regName = this.eventRegistration.Event_Registration__r.Name__c;
    }
    return regName;
  }

  get orderRefNumber(){

    var ordRefNumb = null;

    if(this.isMainEntrance
      && this.eventRegistration.Event_Order__r.Name != null && this.eventRegistration.Event_Order__r.Name != undefined){
        ordRefNumb = this.eventRegistration.Event_Order__r.Name;
    }
    else if(!this.isMainEntrance
      && this.eventRegistration.Event_Registration__r.Event_Order__r.Name != null 
      && this.eventRegistration.Event_Registration__r.Event_Order__r.Name != undefined){
        ordRefNumb = this.eventRegistration.Event_Registration__r.Event_Order__r.Name;
    }
    return ordRefNumb;
  }

  get tableCellStyle(){
    return 'text-align:center !important;';
  } 

  get registeredButtonStyle(){
    return this.isRegistered ? 'border-radius: 0px;background: gray !important;border-color: gray !important;' : 'background: white !important;border-color: gray !important;';  
  }

  get registeredIconStyle(){
    return this.isRegistered ? 'inverse' : '';      
  } 

  get eventRegisteredIconStyle(){
    return this.isEventRegRegistered ? 'inverse' : '';      
  } 

  get checkedInButtonStyle(){
    return this.isCheckedIn ? 'border-radius: 0px;background: #3B7E47 !important;border-color: #3B7E47 !important;' : 'background: white !important;border-color: #3B7E47 !important;';  
  }
  
  get checkedInIconStyle(){
    return this.isCheckedIn ? 'inverse' : 'success';      
  } 

  get eventRegCheckedInIconStyle(){
    return this.isEventRegCheckedIn ? 'inverse' : 'success';      
  } 

  get checkedOutButtonStyle(){
    return this.isCheckedOut ? 'border-radius: 0px;background: #351c75 !important;border-color: #351c75 !important;' : 'background: white !important;border-color: #351c75 !important;';  
  }
  
  get checkedOutIconStyle(){
    return this.isCheckedOut ? 'inverse' : '';          
  } 

  get eventRegCheckedOutIconStyle(){
    return this.isEventRegCheckedOut ? 'inverse' : '';          
  } 

  get didNotAttendButtonStyle(){
    return this.isdidNotAttend ? 'border-radius: 0px;background: #C23934 !important;border-color: #C23934  !important;' : 'background: white !important;border-color: #C23934 !important;';  
  }
  
  get didNotAttendIconStyle(){
    return this.isdidNotAttend ? 'inverse' : 'error';          
  } 

  get eventRegDidNotAttendIconStyle(){
    return this.isEventRegDidNotAttend ? 'inverse' : 'error';          
  } 

  get customButtonStyle(){
    return (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') ? ' ' : 'width: 60%;float: right;border-radius: 0px';
  }

  get statusDivStyle(){
    var style;
    if(this.isEventRegRegistered){
      style = 'text-align:center !important; background: #808080 !important';
    }
    else if(this.isEventRegCheckedIn){
      style = 'text-align:center !important; background: #3B7E47 !important';
    }
    else if(this.isEventRegCheckedOut){
      style = 'text-align:center !important; background: #351c75 !important';
    }
    else if(this.isEventRegDidNotAttend){
      style = 'text-align:center !important; background: #C23934 !important';
    }
    return style; 
  }

  get statusIconStyle(){
    var iconStyle;
    if(this.isEventRegRegistered){
      iconStyle = 'utility:user';
    }
    else if(this.isEventRegCheckedIn){
      iconStyle = 'utility:check';
    }
    else if(this.isEventRegCheckedOut){
      iconStyle = 'utility:logout';
    }
    else if(this.isEventRegDidNotAttend){
      iconStyle = 'utility:close';
    }
    return iconStyle; 
  }

  get statusIconVariant(){
    var iconVariant;
    if(this.isEventRegRegistered){
      iconVariant = this.eventRegisteredIconStyle;
    }
    else if(this.isEventRegCheckedIn){
      iconVariant = this.eventRegCheckedInIconStyle;
    }
    else if(this.isEventRegCheckedOut){
      iconVariant = this.eventRegCheckedOutIconStyle;
    }
    else if(this.isEventRegDidNotAttend){
      iconVariant = this.eventRegDidNotAttendIconStyle;
    }
    return iconVariant; 
  }
  
  get statusButtonStyle(){
    var style;
  
      if(this.isRegistered){
        style = 'font-size: smaller;width:100% !important; color:white; border-radius: 0px !important; text-align:center !important; background: #3B7E47 !important';
      }
      else if(this.isCheckedIn){
        style = 'font-size: smaller;width:100% !important; color:white; border-radius: 0px !important; text-align:center !important; background: #351c75 !important';
      }
      else if(this.isCheckedOut){
        style = 'font-size: smaller;width:100% !important; color:white; border-radius: 0px !important; text-align:center !important; background: #C23934 !important';
      }
      else if(this.isdidNotAttend){
        style = 'font-size: smaller;width:100% !important; color:white; border-radius: 0px !important; text-align:center !important; background: #C23934 !important';
      }
  
    return style; 
  }
  

  connectedCallback() {
    this.setRegistrationStatus();
    if(!this.isMainEntrance){this.setEventRegistrationStatus()};
    this.statusToConstantMap = {"isRegistered":"REGISTERED", "isCheckedIn":"CHECKED_IN", "isCheckedOut":"CHECKED_OUT", "isdidNotAttend":"DID_NOT_ATTEND"};
  }

  setEventRegistrationStatus(){
    if(this.eventRegistration.Event_Registration__r.Event_Registration_Status__c != null 
      && this.eventRegistration.Event_Registration__r.Event_Registration_Status__c != undefined){
      switch (this.eventRegistration.Event_Registration__r.Event_Registration_Status__c) {
        case 'Registered':
          this.isEventRegRegistered = true;
          break;
        case 'Attended / Checked In':
          this.isEventRegCheckedIn = true;
          break;
        case 'Attended / Checked Out':
          this.isEventRegCheckedOut = true;
          break;
        case 'Did Not Attend':
          this.isEventRegDidNotAttend = true;
      }
    }
  }

  setRegistrationStatus(){
    if((this.isMainEntrance
        && this.eventRegistration.Event_Registration_Status__c != null 
        && this.eventRegistration.Event_Registration_Status__c != undefined)
      ||
        (!this.isMainEntrance
          && this.eventRegistration.Status__c != null
          && this.eventRegistration.Status__c != undefined
        )){
        var registrationStatus = this.isMainEntrance ? this.eventRegistration.Event_Registration_Status__c : this.eventRegistration.Status__c;
          
        switch (registrationStatus) {
            case 'Registered':
              this.isRegistered = true;
              break;
            case 'Attended / Checked In':
              this.isCheckedIn = true;
              break;
            case 'Attended / Checked Out':
              this.isCheckedOut = true;
              break;
            case 'Did Not Attend':
              this.isdidNotAttend = true;
          }
        }
    }

  handleShowConfirmationPanel(){
    this.showConfirmationPanel = true;
  }

  hideConfirmationPanel(){
    this.showConfirmationPanel = false;
  }

  handleStatusChanged(event){

    if(!this[event.target.dataset.booleanname]){
      this.isUpdating = true;
      this.resetAllStatus();
      this[event.target.dataset.booleanname] = !this[event.target.dataset.booleanname]; 
      if(this.isMainEntrance){
        this.updateEventCheckInStatus(this.statusToConstantMap[event.target.dataset.booleanname], event.target.dataset.booleanname);
      }
      else{
        this.updateSessionRegCheckInStatus(this.statusToConstantMap[event.target.dataset.booleanname], event.target.dataset.booleanname);
      }
    }
  }

  resetAllStatus(){
    this.isRegistered   = false;
    this.isCheckedIn    = false;
    this.isCheckedOut   = false;
    this.isdidNotAttend = false;
  }

  updateEventCheckInStatus(status, booleanName){
    
    updateEventRegistration({
      eventRegId : this.eventRegistration.Id,
      checkInStatus : status
    })
    .then(result => {
      try {
        this.customToastNotification('Success', 'Successfully updated the status', false);
        const dispatchSessionRegUpdatedEvent = new CustomEvent('sessionregupdatedevent', { detail: true });
        this.dispatchEvent(dispatchSessionRegUpdatedEvent);
        this.hideConfirmationPanel();
      }
      catch(err) {
        this[booleanName] = !this[booleanName]; 
        this.setRegistrationStatus();
        this.customToastNotification('Error', err.message, true);
      }
    })
    .catch(error => {
      this[booleanName] = !this[booleanName]; 
      this.setRegistrationStatus();
      this.customToastNotification('Error', error.body.message, true)
    });

  }

  updateSessionRegCheckInStatus(status, booleanName){
      
    updateSessionRegCheckInStatus({
        sessRegId : this.eventRegistration.Id,
        checkInStatus : status
      })
      .then(result => {
        try {
          this.hideConfirmationPanel();
          this.customToastNotification('Success', 'Successfully updated the status', false);
          const dispatchSessionRegUpdatedEvent = new CustomEvent('sessionregupdatedevent', { detail: true });
          this.dispatchEvent(dispatchSessionRegUpdatedEvent);
        }
        catch(err) {
          this[booleanName] = !this[booleanName]; 
          this.setRegistrationStatus();
          this.customToastNotification('Error', err.message, true);
        }
      })
      .catch(error => {
        this[booleanName] = !this[booleanName]; 
        this.setRegistrationStatus();
        this.customToastNotification('Error', error.body.message, true)
      });
  
    }

  handleRedirectToSobjectRequest(event){
    this.redirectToEventRecord(event.target.dataset.recordid);
  }

  customToastNotification(toastTitle, toastMessage, isErrorMessage) {
    this.isUpdating = false;
    if(this.isMobileDevice){
      this.customToastTitle = toastTitle;
      this.customToastMessage = toastMessage;
      this.customMessageVariant = isErrorMessage ? 'error' : 'success';
      this.template.querySelector('c-ct_-custom-toast').showCustomNotice();
    }
    else{
      var messageString = isErrorMessage ? 'Error' : 'Success';
      const showToastEvent = new ShowToastEvent({
          Title: toastTitle,
          message: toastMessage,
          variant: messageString
      });
      this.dispatchEvent(showToastEvent);
    }
  }

  redirectToEventRecord(recordId) {
    this.showRecordForm = true;
    this.recordEditFormRecordId = recordId;
  }

  handleSuccess(event) {
    const fetchrecordEvent = new CustomEvent('invokefetchrecordsmethod', { detail: true , bubbles: true});
    
    this.dispatchEvent(fetchrecordEvent);
    this.showRecordForm = false;
  }

   

  closeShowRecordEditForm(event) {
    this.showRecordForm = false;
  }

}