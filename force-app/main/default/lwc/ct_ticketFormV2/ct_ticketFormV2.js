/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 01-21-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-14-2020   Umashankar Creation   Initial Version
**/
import { LightningElement, api, track } from "lwc";
import { ShowToastEvent} from 'lightning/platformShowToastEvent';

import validateEventRegistration from "@salesforce/apex/CT_EventSearchController.validateDuplicateEventRegistration";



export default class Ct_ticketFormV2 extends LightningElement {
  @api ticket;
  @api firstName;
  @api lastName;
  @api email;
  @api mobile;
  @api allValid;
  @api isGuest = false;
  @track showForm = false;
  @api allOrderedTickets = [];
  @api eventRegistration = {};
  @api campaignMember = {};
  @api selectedSessions;
  @api primaryAreaInterest;
  @api dynamicSessionData;
  @api orderBy;
  @api numberOfTickets;
  //For Duplicate Event Registration Check
  @api hasPassedEmailVerification = false;
  @api eventId;
  @api allowDuplicateEventRegistration = false;
  @api duplicateEventRegistrationStatus;
  @api hasDuplicate = false;
  @api duplicateEventRegistrationId;
  @api customEmailErrorMessage;

  @track registeringMyself = false;
  @api attendeeType = '--None--';
  @track isAttendeeReset = false;
  @track attendees = [];
  @track orderValues = {};
  @track isQuestionRendered = false;

  get renderForm(){
    return this.attendeeType != '--None--';
  }
  
  get isAnonymousOnlyTicket(){
    return this.ticket.anonymousOnly;
  }

  get showCustomEmailErrorMessage(){
    return (this.attendeeType == "Myself" && !this.hasPassedEmailVerification && !this.allowDuplicateEventRegistration);
  }

  handleFirstName(event) {
    this.firstName = event.detail.value;
  }

  handleLastName(event) {
    this.lastName = event.detail.value;
  }

  handleEmail(event) {
    this.email = event.detail.value;
  }

  handleMobile(event) {
    this.mobile = event.detail.value;
  }
  connectedCallback(){

    if(this.ticket.anonymousOnly){
      this.attendeeType = "Unknown Guest";
      this.isGuest = this.attendeeType === "Unknown Guest" ? true : false;
      this.hasPassedEmailVerification = true;

      this.eventRegistration = this.ticket.eventRegistration;
      if(this.eventRegistration == undefined){
        this.eventRegistration ={};
      }
      this.campaignMember = this.ticket.campaignMember;
      if(this.campaignMember == undefined){
        this.campaignMember ={};
      }
      
    }
    else{
      this.hasPassedEmailVerification = true;

      if(this.numberOfTickets == 1){
        this.attendeeType = "Myself";
      }
  
      this.attendees.push({ label: "--None--", value: "--None--" }, { label: "Myself", value: "Myself" }, { label: "Someone Else (with details)", value: "Someone Else" });
      
      if(this.ticket.allowGuestRegistrations){
        this.attendees.push({ label: "Someone Else (anonymous)", value: "Unknown Guest" });
      }
  
      this.eventRegistration = this.ticket.eventRegistration;
      if(this.eventRegistration == undefined){
        this.eventRegistration ={};
      }
      this.campaignMember = this.ticket.campaignMember;
      if(this.campaignMember == undefined){
        this.campaignMember ={};
      }
      if(this.orderBy && this.attendeeType == "Myself"){
        this.registeringMyself = true;
        this.firstName = this.orderBy.firstName;
        this.lastName = this.orderBy.lastName;
        this.email = this.orderBy.email;
        this.mobile = this.orderBy.mobile;
        if(this.orderBy && this.orderBy.hasOwnProperty('street')){
          this.orderValues['Street__c'] = this.orderBy.street;
        }
        if(this.orderBy && this.orderBy.hasOwnProperty('state')){
          this.orderValues['State_County__c'] = this.orderBy.state;
  
        }
        if(this.orderBy && this.orderBy.hasOwnProperty('postcode')){
          this.orderValues['Zip_Postal_Code__c'] = this.orderBy.postcode;
  
        }
        if(this.orderBy && this.orderBy.hasOwnProperty('country')){
          this.orderValues['Country__c'] = this.orderBy.country;
  
        }
        if(this.orderBy && this.orderBy.hasOwnProperty('city')){
          this.orderValues['City__c']  = this.orderBy.city;
        }
        //this.template.querySelector('c-ct_-event-questions-form').populateAddressDetails(this.orderValues);
      }
  
      if(this.ticket.ticketNumber > 1){
        this.attendeeType = "--None--";
        this.firstName = null;
        this.lastName = null;
        this.email = null;
        this.mobile = null;
      }

      var hasMyselfTicket = false;
      
      if(this.allOrderedTickets != null 
        && this.allOrderedTickets != undefined
        && this.allOrderedTickets.length > 0){
          this.allOrderedTickets.forEach(function(thisTicket){
            if(!hasMyselfTicket && thisTicket.attendeeType == 'Myself'){
              hasMyselfTicket = true;
            }
          });
        }
     
      if(this.allOrderedTickets != null 
        && this.allOrderedTickets != undefined
        && this.allOrderedTickets.length > 0){
        const thisTicket = this.allOrderedTickets.find( ({ ticketNumber }) => ticketNumber === this.ticket.ticketNumber );
        this.firstName    = thisTicket.firstName;
        this.lastName     = thisTicket.lastName;
        this.email        = thisTicket.email;
        this.mobile       = thisTicket.mobile;
        this.isGuest      = thisTicket.isGuest;
        this.attendeeType = thisTicket.attendeeType;
        if(hasMyselfTicket && this.attendeeType != "Myself"){
          var newAttendee = [{ label: "--None--", value: "--None--" }, { label: "Someone Else (with details)", value: "Someone Else" }];
          if(this.ticket.allowGuestRegistrations){
            newAttendee = [{ label: "--None--", value: "--None--" }, { label: "Someone Else (with details)", value: "Someone Else" }, { label: "Someone Else (anonymous)", value: "Unknown Guest" }];
          }          
          this.attendees = newAttendee;
              
  
        }
      }
      if(this.numberOfTickets == 1){
        this.invokeServerSideEventRegistrationValidation();
      }
    }
   
  }

  @api
  reportValidation(){
     this.allValid = [...this.template.querySelectorAll('.ticketOrderField')]
    .reduce((validSoFar, inputCmp) => {        
        if(inputCmp.name == 'attendeeType' && inputCmp.value=='--None--'){
          //inputCmp.setCustomValidity('Please choose a valid booking type');
         // return false;
         inputCmp.value = null;
        }

        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    if(!this.allValid){
      return false;
    }
    else{
      return true;
    }
  }

  @api
  resetAttendeeOptions(){
    var newAttendee = [{ label: "--None--", value: "--None--" }, { label: "Someone Else (with details)", value: "Someone Else" }];
    if(this.ticket.allowGuestRegistrations){
      newAttendee = [{ label: "--None--", value: "--None--" }, { label: "Someone Else (with details)", value: "Someone Else" }, { label: "Someone Else (anonymous)", value: "Unknown Guest" }];
    }
    this.template.querySelector('.dropdown').options = newAttendee;
   

  }

  @api
  revertAttendeeOptions(){
    
    var newAttendee = [{ label: "--None--", value: "--None--" }, { label: "Myself", value: "Myself" }, { label: "Someone Else (with details)", value: "Someone Else" }];
    if(this.ticket.allowGuestRegistrations){
      newAttendee = [{ label: "--None--", value: "--None--" }, { label: "Myself", value: "Myself" }, { label: "Someone Else (with details)", value: "Someone Else" }, { label: "Someone Else (anonymous)", value: "Unknown Guest" }];
    }
    this.template.querySelector('.dropdown').options = newAttendee;

  }

  handleAttehndeeType(event) {
    this.renderQuestion = false;
    if(this.attendeeType == "Myself" && event.detail.value != "Myself"){
      this.isAttendeeReset = true;
    }
    this.attendeeType = event.detail.value;
    this.isGuest = this.attendeeType === "Unknown Guest" ? true : false;
    this.registeringMyself = this.attendeeType === "Myself" ? true : false;
    if(this.isGuest){
      this.firstName = null;
      this.lastName = null;
      this.email = null;
      this.mobile = null;
      this.orderValues['Street__c'] = null;
      this.orderValues['State_County__c'] = null;
      this.orderValues['Zip_Postal_Code__c'] = null;
      this.orderValues['Country__c'] = null;
      this.orderValues['City__c']  = null;
      this.orderValues['Address_Line_2__c'] = null;
      if(this.isQuestionRendered){
        this.template.querySelector('c-ct_-event-questions-form-v2').populateAddressDetails(this.orderValues);
      }

    }

    if(this.registeringMyself){
      this.firstName = this.orderBy.firstName;
      this.lastName = this.orderBy.lastName;
      this.email = this.orderBy.email;
      this.mobile = this.orderBy.mobile;
      if(this.orderBy && this.orderBy.hasOwnProperty('street')){
        this.orderValues['Street__c'] = this.orderBy.street;
      }
      if(this.orderBy && this.orderBy.hasOwnProperty('state')){
        this.orderValues['State_County__c'] = this.orderBy.state;
      }
      if(this.orderBy && this.orderBy.hasOwnProperty('postcode')){
        this.orderValues['Zip_Postal_Code__c'] = this.orderBy.postcode;
      }
      if(this.orderBy && this.orderBy.hasOwnProperty('country')){
        this.orderValues['Country__c'] = this.orderBy.country;
      }
      if(this.orderBy && this.orderBy.hasOwnProperty('city')){
        this.orderValues['City__c']  = this.orderBy.city;
      }

      if(this.isQuestionRendered){
        this.template.querySelector('c-ct_-event-questions-form-v2').populateAddressDetails(this.orderValues);
      }
      const resetAttendeeType = new CustomEvent('attendeechanged', { detail: this.ticket.ticketNumber });
      this.dispatchEvent(resetAttendeeType);
    }
    else{
      this.firstName = null;
      this.lastName = null;
      this.email = null;
      this.mobile = null;
      this.orderValues['Street__c'] = null;
      this.orderValues['State_County__c'] = null;
      this.orderValues['Zip_Postal_Code__c'] = null;
      this.orderValues['Country__c'] = null;
      this.orderValues['City__c']  = null;
      this.orderValues['Address_Line_2__c'] = null;
      if(this.isQuestionRendered){
        this.template.querySelector('c-ct_-event-questions-form-v2').populateAddressDetails(this.orderValues);
      }
      if(this.isAttendeeReset){
        const revertAttendeeType = new CustomEvent('attendeerevert', { detail: this.ticket.ticketNumber });
        this.dispatchEvent(revertAttendeeType);
      }
    }
    if(this.registeringMyself){
      this.invokeServerSideEventRegistrationValidation();
    }
    this.fireSibilingEventRegistrationEventEmailCheck();
  }

  @api
  validateQuestionComponent(){
    return this.template.querySelector('c-ct_-event-questions-form-v2').validateForm();
  }
  
  handleQuestionsAnswers(event){
    var eventRegFieldArray = 0;
    var campaignMemFieldArray = 0;
    if(event.detail.Event_Registration__c){
      eventRegFieldArray = Object.keys(event.detail.Event_Registration__c);
    }

    if(event.detail.CampaignMember){
     campaignMemFieldArray = Object.keys(event.detail.CampaignMember);
    } 
    if(eventRegFieldArray.length>0){
      var tempEventRegistration = JSON.parse(JSON.stringify(this.eventRegistration));
      for(var i=0 ; i<eventRegFieldArray.length; i++){
        //this.eventRegistration[eventRegFieldArray[i]] = event.detail.Event_Registration__c[eventRegFieldArray[i]];
        tempEventRegistration[eventRegFieldArray[i]] = event.detail.Event_Registration__c[eventRegFieldArray[i]];
      }
      this.eventRegistration = tempEventRegistration;
    }

    if(campaignMemFieldArray.length>0){

        var tempCampaignMember;
        if(this.campaignMember && typeof this.campaignMember == 'string'){
          tempCampaignMember = JSON.parse(this.campaignMember);
        }
        else if(this.campaignMember && typeof this.campaignMember == 'object'){          
          tempCampaignMember = JSON.parse(JSON.stringify(this.campaignMember));
        }

      for(var i=0 ; i<campaignMemFieldArray.length; i++){
        //this.campaignMember[campaignMemFieldArray[i]] = event.detail.CampaignMember[campaignMemFieldArray[i]];
        tempCampaignMember[campaignMemFieldArray[i]] = event.detail.CampaignMember[campaignMemFieldArray[i]];
      }
      this.campaignMember = tempCampaignMember;
    }
  }

  handleSessionSelection(event){
    this.selectedSessions = event.detail.selectionSessionId;
    this.primaryAreaInterest = event.detail.primaryAreaInterest;

    var sessionDetails = {'ticketNumber' : this.ticket.ticketNumber, 'sessionId' : this.selectedSessions};
    if(this.selectedSessions){
      this.dispatchEvent(new CustomEvent('manageavailablesessions', { detail: sessionDetails }));

    }
  }

  @api
  getPrimarySessionData(){
    return this.template.querySelector('c-ct_-event-questions-form-v2');
  }

  @api
  removeExcessiveSessions(sessionOptions){
    this.template.querySelector('c-ct_-event-questions-form-v2').removeExcessiveSessions(sessionOptions);
  }

  //For Checking Duplicate Event Registration Email Check on sibiling
  fireSibilingEventRegistrationEventEmailCheck(){
    
      this.resetSibilingEventRegEmailError();
    
    

    const eventEmailValidationEvent = new CustomEvent('eventemailvalidation', { detail: this.ticket.ticketNumber , bubbles: true});
      this.dispatchEvent(eventEmailValidationEvent);
  }

  

  @api
  invokeServerSideEventRegistrationValidation(){
    try {
      validateEventRegistration({
        eventId: this.eventId,
        emailAddress : this.email,
        attendeeType : this.attendeeType
      })
        .then(result => {
          // this.setDashboardCountValues(result);

          if(result.hasDuplicate){
            this.hasDuplicate = result.hasDuplicate;
            this.duplicateEventRegistrationStatus = result.duplicateEventRegistrationStatus;
            this.duplicateEventRegistrationId = result.duplicateEventRegistrationId;
            this.customEmailErrorMessage = result.errorMessage;
            var emailInput = this.template.querySelector(`[data-id="emailaddressinput"]`);
            
            if(!this.allowDuplicateEventRegistration && result.hasCustomError && result.hasDuplicate) {
              this.hasPassedEmailVerification = false;
            }
            
            if(!this.allowDuplicateEventRegistration && result.hasCustomError){
              emailInput.setCustomValidity(result.errorMessage);
              emailInput.reportValidity();
            }

          }

         // this.hideSpinner();
        })
        .catch(error => {
          this.customToastNotification('Error', JSON.stringify(error), true);
        });
    }
    catch(err) {
      this.customToastNotification('Error', err.message, true);
    }
  }

  @api
  setSibilingEventRegEmailError(){
    var emailInput = this.template.querySelector(`[data-id="emailaddressinput"]`);
    if(!this.allowDuplicateEventRegistration){
      this.hasPassedEmailVerification = false;

      if(!this.registeringMyself){
        emailInput.setCustomValidity('This email address is already entered for this event order');
        emailInput.reportValidity();
      }
      else{
        this.customEmailErrorMessage = 'This email address is already entered for this event order';
      }

    
    }
     
  }
  
  @api
  resetSibilingEventRegEmailError(){
    var emailInput = this.template.querySelector(`[data-id="emailaddressinput"]`);
      this.hasPassedEmailVerification = true;
      if(!this.registeringMyself && this.email){
        emailInput.setCustomValidity("");
        emailInput.reportValidity(); 
      }
      else{
        this.customEmailErrorMessage = null;
        this.invokeServerSideEventRegistrationValidation();
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

  handleRenderValue(event){
    this.isQuestionRendered = event.detail;
  }
  @api
  resetSelectedSession(){
    this.template.querySelectorAll("c-ct_-event-questions-form-v2").forEach(element=>{
      element.selectedSession = null;
      this.selectedSessions = null;
      element.resetSelectedSession();
    });
  }
}