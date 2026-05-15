/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 09-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-17-2020   Umashankar Creation   Initial Version
**/
import { LightningElement, track,api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";

import QRCodeLib from "@salesforce/resourceUrl/ct_QRCodeLibrary";
import invokedSaveQRCodeMethod from '@salesforce/apex/CT_EventSearchController.saveQRCode'; 


import getEventRegistration from '@salesforce/apex/ct_TicketManagementController.getEventRegistration';
// import QRCodeLib from './qrcode.min.js';
import CHECK_IN_MANAGER_URL from '@salesforce/label/c.Site_Base_URL';
import updateEventRegistration from '@salesforce/apex/ct_TicketManagementController.updateEventRegistration';
import getSessionAsPicklistValues from "@salesforce/apex/CT_EventSearchController.getSessionAsPicklists";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
//import UOP_LOGO from '@salesforce/resourceUrl/ct_UOP_Logo';
import formFactorPropertyName from '@salesforce/client/formFactor';
import validateEventRegistration from "@salesforce/apex/CT_EventSearchController.validateDuplicateEventRegistration";

export default class Ct_TicketManagementFormV2 extends LightningElement {


  // @track eventRegistration;
  // _libLoaded  = false;
  // @api eventRegistrationId;
  // @api sessionReg;

  // constructor() {
  //       super();
       
  //   }
    

    // connectedCallback(){
    //   console.log('Entered TicketManagementForm connected callback');

     
     
    // }

  //   async renderedCallback(){
  //     // Promise.all([
  //     //       loadScript(this, QRCodeLib + "/qrcode.min.js")
  //     //   ])
  //       await loadScript(this, QRCodeLib + "/qrcode.min.js")
  //           .then(() => {
  //               this._libLoaded = true;

  //           })
  //           .catch(error => {
  //               console.log(error.body.message);
  //           });

  //            console.log('this._libLoaded '+this._libLoaded);
  //            if(this._libLoaded){
  //             this.loadEventRegistration();
  //            }
              
  //   }


  //   loadEventRegistration(){
  //     console.log('Entered loadEventRegistration');
  //   getEventRegistration({eventRegistrationId: this.eventRegistrationId})
  //     .then(result=>{
  //       this.eventRegistration = result.eventRegistration;
  //     }).catch(error => {
  //       this.spinnerBoolean = false;
  //       this.customToastNotification('Error', error.body.message, true);
  //   });
                    
  //   this.generateQRCode();
                

  // }

 

//     generateQRCode() {
//       console.log('Entered generateQRCode');
//       const canvas = this.template.querySelector('.QRSelector');
//       var sData = 'www.google.com';//CHECK_IN_MANAGER_URL + '/' + `UoPQRScanner/s/scanqrcode?eventid=${this.eventRegistration.Event__c}&eventregid=${this.eventRegistration.Id}`;
//       console.log('canvas: ' + canvas);
//       if(canvas){
//         QRCode.toCanvas(canvas, sData)
//       .then(() => {
//          this._libLoaded = false;
//           // eslint-disable-next-line no-console
         
//       })
//       .catch(err => {
//         this._libLoaded = false;
//           this.customToastNotification('Error', JSON.stringify(err), true);
//       });
//       }
      
// }


  _libLoaded  = false;
  

  @track eventRegistration;
  @track campaignMember = {};
  @track updatedEventRegistraton = {};
  @track isNamedAttendee;
  @track eventCancelReason;
  @track eventCancellationDescription;
  @track showMenu = false;
  @track showMenuLinks    = 'color: grey;cursor: not-allowed;opacity: 0.5;text-decoration: none; pointer-events: none;';
  @track showSessionLinks;
  @track spinnerBoolean = false;
  @track showSessionRegistration = false;
  @track showEventQRCode = false;
  @track showTicketManagement = true;
  @track isCancelled = false;
  @track showSaveEdit;
  @track questionAnswerObject;
  @track logoStyle;
  @track hasScrolledToTop = false;
  //selectedSessions;
  //dynamicSessionData;
  //@track canRenderQuestionForm = false;
  @api eventRegistrationId;
  @api sessionReg;
  registrationType;
  //uopLOGO = UOP_LOGO;

  allowDuplicateEventRegistration = false;


  @api showBackButton;

  @api isSimpleEvent;

  get eventCancelOptions(){
    return [{label: 'Event no longer relevant', value: 'Event no longer relevant'},{label: 'Cannot make the date', value: 'Cannot make the date'},{label: 'Too far to travel', value: 'Too far to travel'},{label: 'Do not want to say', value: 'Do not want to say'},{label: 'Other', value: 'Other'}];
  }

  get getFormFactor(){
    let isMobile;
    if (formFactorPropertyName === 'Small' || formFactorPropertyName === 'Medium') {
      isMobile = true;
    }
    return isMobile;
  }

  get mobileAlignmentStyle(){
    let gridStyle;
    if (formFactorPropertyName === 'Large') {
        gridStyle = 'slds-grid slds-gutters';
    } else if (formFactorPropertyName === 'Medium') {
        gridStyle = 'slds-grid slds-gutters';
    } else {
        gridStyle = 'slds-grid slds-gutters slds-grid_vertical';
    }
    return gridStyle;
  }

  get sessionStyle(){
    return this.showSessionLinks;
  }

  get showSessionRegistrationLink(){
    return (this.eventRegistration 
      && this.eventRegistration.hasOwnProperty('Event_Email__c')
      && this.eventRegistration.Event_Email__c
      && this.eventRegistration.hasOwnProperty('First_Name__c')
      && this.eventRegistration.First_Name__c
      && this.eventRegistration.hasOwnProperty('Last_Name__c')
      && this.eventRegistration.Last_Name__c
      && this.eventRegistration.hasOwnProperty('Event_Product__r')
      && this.eventRegistration.Event_Product__r.Enable_Session_Registrations__c
      && !this.isSimpleEvent);
  }

  getUopLogoStyle = () => {
    if (window.outerWidth>768) {
      this.logoStyle = 'width: 15%; height:20%;';
    }  
    else {
      this.logoStyle = 'width: 200px !important;';
    }
  };

   constructor() {
    super();
    
  }
  

  connectedCallback(){
    var queryString = window.location.href;
    var urlVar = new URL(queryString);
    //this.eventRegistrationId = urlVar.searchParams.get("eventRegId");
    if(this.sessionReg){
      this.showSessionRegistration = true;
      this.showTicketManagement = false;
    }

    this.loadEventRegistration();
    this.getUopLogoStyle();
    window.addEventListener('resize', this.getUopLogoStyle);
    
  }

  async renderedCallback(){
    if (this._libLoaded) {
        return;
    }
    await loadScript(this, QRCodeLib + "/qrcode.min.js")
            .then(() => {
                this._libLoaded = true;

            })
            .catch(error => {
                console.log(error.body.message);
            });

             console.log('this._libLoaded '+this._libLoaded);
             if(this._libLoaded){
              this.loadEventRegistration();
             }
    if(this._libLoaded){
      this.generateQRCode();
    }
    if(!this.hasScrolledToTop){
            this.hasScrolledToTop = true;
            this.customScrollToTop();
        }
  }

  // generateQRCode(){
  //   if (this._libLoaded) {
  //     const canvas = this.template.querySelector('[data-id="QRCode"]');
  //     var sData = CHECK_IN_MANAGER_URL + '/' + `UoPQRScanner/s/scanqrcode?eventid=${this.eventRegistration.Event__c}&eventregid=${this.eventRegistration.Id}`;
  //     QRCode.toCanvas(canvas, sData)
  //     .then(() => {
  //         // eslint-disable-next-line no-console
  //     })
  //     .catch(err => {
  //         this.customToastNotification('Error', JSON.stringify(err), true);
  //     });
      
  //   }
  // }
  generateQRCode() {
      console.log('Entered generateQRCode');
        const canvas = this.template.querySelector('.QRSelector');
        //var sData = CHECK_IN_MANAGER_URL + '/' + `UoPQRScanner/s/scanqrcode?eventid=${this.eventRegistration.Event__c}&eventregid=${this.eventRegistration.Id}`;
        //var sData = CHECK_IN_MANAGER_URL + '/' + `lightning/n/Check_In_QR_Code_Scanner?eventid=${this.eventRegistration.Event__c}&eventregid=${this.eventRegistration.Id}`;
        //var sData = CHECK_IN_MANAGER_URL + '/' + `/lightning/cmp/c__ct_CheckInManagerQRCodeScanner?c__eventid=${this.eventRegistration.Event__c}&c__eventregid=${this.eventRegistration.Id}`;
        var sData = CHECK_IN_MANAGER_URL +'/lightning/n/Check_In_QR_Code_Scanner' +`?c__eventregid=${this.eventRegistration.Id}`;
        // Get current base URL
        // let baseUrl = window.location.origin;

        // // Convert Experience Cloud domain → Lightning domain
        // if (baseUrl.includes('.my.site.com')) {
        //     baseUrl = baseUrl.replace('.my.site.com', '.lightning.force.com');
        // }

        // // Build final URL
        // const sData =
        //     `${baseUrl}/lightning/n/Check_In_QR_Code_Scanner` +
        //     `?c__eventregid=${this.eventRegistration.Id}`;

        console.log('sData: ' + sData);
        console.log('canvas: ' + canvas);
        if(canvas){
          QRCode.toCanvas(canvas, sData)
        .then(() => {
          this._libLoaded = false;
            // eslint-disable-next-line no-console
          
        })
        .catch(err => {
          this._libLoaded = false;
            this.customToastNotification('Error', JSON.stringify(err), true);
        });
      }
  }

  customScrollToTop() {
        const ordersummaryScroll = new CustomEvent('scrolltotop', { detail: true });
        this.dispatchEvent(ordersummaryScroll);
      }


  loadEventRegistration(){
    getEventRegistration({eventRegistrationId: this.eventRegistrationId})
      .then(result=>{
        this.spinnerBoolean = true;
        this.eventRegistration = result.eventRegistration;
        console.log("First Name: " + result.eventRegistration.First_Name__c);
        console.log("Last Name: " + result.eventRegistration.Last_Name__c);
        //
        // this.eventRegistration = JSON.parse(JSON.stringify(this.eventRegistration));
        // let imageURL = this.eventRegistration.QR_Code__c;
        // const srcStart = imageURL.indexOf('src="') + 5;
        // const srcEnd = imageURL.indexOf('"', srcStart);
        // imageURL = imageURL.substring(srcStart, srcEnd);
        // imageURL = imageURL.replace(/&amp;/g, '&');
        // imageURL = 'https://launchedv2-dev-ed.my.site.com' + imageURL;
        // this.eventRegistration.QR_Code__c = imageURL;
        //
        this.allowDuplicateEventRegistration = this.eventRegistration.Event__r.Allow_Duplicate_Event_Registrations__c;
        this.updatedEventRegistraton = result;
       
        if(result.eventRegistration.Event_Email__c){
          this.isNamedAttendee = true;
          this.registrationType = result.eventRegistration.Registration_Type__c == "Someone Else"? "Someone Else (with details)" : result.eventRegistration.Registration_Type__c;
          
        }
        else{
          this.isNamedAttendee = false;
          this.registrationType = result.eventRegistration.Registration_Type__c;
        }
        if(result.eventRegistration.Event_Email__c && result.eventRegistration.First_Name__c && result.eventRegistration.Last_Name__c){
          this.showMenuLinks = '';
          this.showSessionLinks = '';
          this.showSaveEdit = false;
        }
        else{
          this.showMenuLinks = 'color: grey;cursor: not-allowed;opacity: 0.5;text-decoration: none; pointer-events: none;';
          this.showSessionLinks = 'color: grey;cursor: not-allowed;opacity: 0.5;text-decoration: none; pointer-events: none;';

          this.showSaveEdit = true;
        }

        if(result.eventRegistration.Event_Product__r.Enable_Session_Registrations__c && this.showSessionLinks != 'color: grey;cursor: not-allowed;opacity: 0.5;text-decoration: none; pointer-events: none;'){
          this.showSessionLinks = '';
        }
        else{
          this.showSessionLinks = 'color: grey;cursor: not-allowed;opacity: 0.5;text-decoration: none; pointer-events: none;';
        }

        
        if(result.eventRegistration.Event__r){
          var today = new Date();
          today.setHours(0,0,0,0);
          var eventDate = new Date(result.eventRegistration.Event__r.Event_End_Date__c);
          eventDate.setHours(0,0,0,0);
        }
        var compare_dates = function(eventDate,today){
          if (eventDate>=today) return true;
        else if (eventDate<today) return false;
       }


        if(result.eventRegistration && result.eventRegistration.Event_Registration_Status__c == 'Cancelled'){
          this.isCancelled = true;
        }
        else if(!compare_dates(eventDate,today)){
          this.isCancelled = true;
        }

        this.spinnerBoolean = false;
      }).catch(error => {
        this.spinnerBoolean = false;
        this.customToastNotification('Error', error.body.message, true);
    });

  }

  invokeServerSideEventRegistrationValidation(){
    try {
      validateEventRegistration({
        eventId: this.eventRegistration.Event__r.Id,
        emailAddress : this.updatedEventRegistraton.eventRegistration["Event_Email__c"],
        attendeeType : null
      })
        .then(result => {

          if(result.hasDuplicate){
           
            var emailInput = this.template.querySelector(`[data-id="emailaddressinput"]`);
            
            if(!this.allowDuplicateEventRegistration && result.hasCustomError){
              emailInput.setCustomValidity('This email address is already entered for this event order');
              emailInput.reportValidity();
            }

          }

        })
        .catch(error => {
          this.customToastNotification('Error', JSON.stringify(error), true);
        });
    }
    catch(err) {
      this.customToastNotification('Error', err.message, true);
    }
  }

  customToastNotification(toastTitle, toastMessage, isErrorMessage) {
    var messageString = isErrorMessage ? 'Error' : 'Success';
    const showToastEvent = new ShowToastEvent({
      title: toastTitle,
      message: toastMessage,
      variant: messageString
    });
    this.dispatchEvent(showToastEvent);
  }

  handleTicketManagement(){
    this.showMenu = false;
    this.showSessionRegistration = false;
    this.showEventQRCode = false;
    this.showTicketManagement = true;
    this._libLoaded = false;
  }

  handleEventQRCode(){
    this.showMenu = false;
    this.showSessionRegistration = false;
    this.showEventQRCode = true;
    this.showTicketManagement = false;
    this._libLoaded = true;

  }

  handleSessionRegistration(){
    this.showMenu = false;
   this.showSessionRegistration = true;
   this.showEventQRCode = false;
   this.showTicketManagement = false;
   this._libLoaded = false;
  }

  handleBackNavigation()
  {
    const eventToParent = new CustomEvent('backeventorderconfirmationdisplay', {
        detail: { eventsearchdisplay: true,
          selectedEventDisplay : false,
          eventOrderDisplay : false,
          eventSummaryDisplay : false,
          eventOrderConfirmation : true,
          eventTicketmanagement : false,
          eventSessionManagement : false
        },
        bubbles: true,
        composed: true
        });
        this.dispatchEvent(eventToParent);
  }

  handleValueChange(event){
    this.updatedEventRegistraton.eventRegistration[event.target.name] = event.target.value;
    if(event.target.name == "Event_Email__c"){
      this.resetSibilingEventRegEmailError();
    }
  }

  handleCancelReason(event){
    
  }

  validateDuplicateEmail(){
    this.invokeServerSideEventRegistrationValidation();
  }

  resetSibilingEventRegEmailError(){
    var emailInput = this.template.querySelector(`[data-id="emailaddressinput"]`);
    emailInput.setCustomValidity("");
    emailInput.reportValidity(); 
  }

  handleSave(){
    var campaigndata = null;
    if(Object.keys(this.campaignMember).length >0){
      campaigndata = JSON.stringify(this.campaignMember);
    }
    if(this.validateForm('.saveRequiredClass')){
      
      this.updateEventRegRecord(JSON.stringify(this.updatedEventRegistraton),campaigndata, false);
      console.log('this.updatedEventRegistraton',JSON.stringify(this.updatedEventRegistraton));
    }
    else{
      this.customToastNotification('Error', 'Please fill in the required field', true);
    }
  }

  handleEventCancellation(){
    var campaigndata = null;
    if(Object.keys(this.campaignMember).length >0){
      campaigndata = JSON.stringify(this.campaignMember);
    }
    if(this.validateForm('.cancelRequiredClass')){
      this.updateEventRegRecord(JSON.stringify(this.updatedEventRegistraton),campaigndata, true);
    }
    else{
      this.customToastNotification('Error', 'Please fill in the required field', true);
    }
  }

  validateForm(validateType){
    const allValid = [...this.template.querySelectorAll(validateType)]
    .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);

    const eventQuestionsForm = this.template.querySelector('c-ct_-event-questions-form-v2');
    if(!allValid && !this.isNamedAttendee){
      return false;
    }
    else if(eventQuestionsForm && !eventQuestionsForm.validateForm()){
      return false;
    }
    else if(!allValid){
      return false;
    }
    else{
      return true;
    }
  }

  updateEventRegRecord(jsonData, campaignJsonData, isCancelling){
    this.spinnerBoolean = true;

    updateEventRegistration({jsonData: jsonData,campaignData: campaignJsonData, isCancelling: isCancelling})
    .then(result=>{
      this.spinnerBoolean = false;
      if(result == 'success'){
        this.customToastNotification('Success', 'Record updated successfully!', false);
        this.loadEventRegistration();
      }
    })
    .catch(error => {
      this.spinnerBoolean = false;
      this.customToastNotification('Error', error.body.message, true);
    });
  }

  handleQuestionsAnswers(event){
    try{

    if(event.detail.CampaignMember){
      var camfieldArray = Object.keys(event.detail.CampaignMember);
      for(var i =0; i<camfieldArray.length; i++){
        this.campaignMember[camfieldArray[i]] = event.detail.CampaignMember[camfieldArray[i]];
      }

    }
    else if(event.detail.Event_Registration__c){
      var fieldArray = Object.keys(event.detail.Event_Registration__c);
      for(var i=0 ; i<fieldArray.length; i++){
        this.updatedEventRegistraton.eventRegistration[fieldArray[i]] = event.detail.Event_Registration__c[fieldArray[i]];
      }
    }
  }
  catch(err){
    console.log('Error '+ err.message);
  }
  }


  show_Menu(){
    this.showMenu = true;
  }

  hide_Menu(){
    this.showMenu = false;
  }
}