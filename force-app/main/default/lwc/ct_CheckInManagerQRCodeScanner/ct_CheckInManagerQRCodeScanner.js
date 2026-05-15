/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 09-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   01-08-2021   Umashankar Creation   Initial Version
**/
import { LightningElement, api ,track, wire} from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkinURL from '@salesforce/label/c.ct_CheckinManager';
//import getEventAndSessionDetails from '@salesforce/apex/ct_CheckInManagerController.getInitialWrapper';
import getEventAndSessionDetails from '@salesforce/apex/ct_CheckInManagerQRCodeScannerController.getEventSessionDetailsWrapper';
//import getExistingSessionId from '@salesforce/apex/ct_CheckInManagerQRCodeScannerController.getSessionParID';
import updateSessionIdConfig from '@salesforce/apex/ct_CheckInManagerQRCodeScannerController.updateSessionId';
import formFactorPropertyName from '@salesforce/client/formFactor';
import updateEventRegStatus from '@salesforce/apex/ct_CheckInManagerQRCodeScannerController.updateEventRegistartionStatus';
import getEventRecordValues from '@salesforce/apex/ct_CheckInManagerQRCodeScannerController.getEventRecord';
//Update
import fetchInitialWrapper from '@salesforce/apex/ct_CheckInManagerQRCodeScannerController.getInitialWrapper';
import USER_ID from '@salesforce/user/Id';



export default class Ct_CheckInManagerQRCodeScanner extends NavigationMixin(LightningElement) {
  @api eventIdParamater;
  @api eventRegId;
  @api sessionId;
  @api isCheckInManager = false;

  // Current Page Reference code added to get parameter values from the ticket management LWC QR
  @wire(CurrentPageReference)
  currentPageRef;

  //FOR CUSTOM ERROR TOAST
  customToastTitle = 'Error';
  customToastMessage = 'Error';
  customMessageVariant = 'error';

  spinnerBoolean                = true;
  showReconfigurationForm       = false;
  isCancelConfig                = false;

  @track existingSessionId;
  

  eventOptions                  = [];
  sessionOptions                = [];
  noneValueArray                = [{"label":"NONE","value":"","isCurrentSession":false,"isSelected":false}]; 

  comboBoxValuesObject          = {};
  sessionOptionsMap             = {};

  //update 
  configuredSession             = [];
  configuredSessionValues       = [];
  configuredSessionName         = 'No Configured Session Found';
  configuredEventName           = 'No Configured Event Found';
  configuredSessionValues       = [];
  hasExistingConfiguration;
  existingConfigurationRecordId = null;
  IS_MAIN_ENTRANCE_SCAN;


  get checkInQRCodeURL(){
    return checkinURL+`?eventid=${this.comboBoxValuesObject.selectedEventId}`;
  }

  get checkSetupTitleText(){
    return 'The QR Setup functionality allows you to configure the location at which you are scanning an attendees QR Code';
  }

  get showTitleText(){
    return (!this.isCheckInManager || (this.isCheckInManager && this.showReconfigurationForm));
  }

  get topPaddingaround(){
    return this.isMobileDevice ? 'slds-p-around_x-small' : 'slds-p-around_small';
  }

  get defaultBackgroundStyle(){
    return 'background-color: #fff;'
  }

  get topPaddingVertical(){
    return this.isMobileDevice ? 'slds-p-vertical_none' : 'slds-p-vertical_small';
  }

  get isSldsBoxNeeded(){
    return this.isMobileDevice ? '' : 'slds-box';
  }
  get isMobileDevice(){
      return (formFactorPropertyName === 'Large') ? false : true;
  }

  get configButtonLabel(){
    return this.hasExistingConfiguration ? 'Re-Configure Location' : 'Configure Session';
  }

  get configSessionId(){
    return (this.existingSessionId == null || this.existingSessionId == undefined) ? 'No Configuration Found' : this.existingSessionId;
  }

  get configSessionName(){
    var conName ='No Configuration Found';
    var tmpses 
    if(this.existingSessionId){
      tmpses =  this.existingSessionId.substring(0, 15);
      this.sessionOptions.forEach((element) => {
        
        if(element.value.includes(tmpses)){
          conName   = element.label};          });
    }
    return conName;
  }

  get gridDivClass(){
    if (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') {
      return 'slds-p-vertical_small slds-grid slds-grid--pull-padded slds-wrap';
    }
    else {
      return 'slds-grid slds-grid_vertical';
    }
  }

  get gridSizeTwoDivClass(){
    if (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') {
      return 'fieldLabelStyle slds-col--padded slds-size--2-of-12';
    }
    else {
      return 'fieldLabelStyle slds-col slds-p-vertical_small';
    }
  }

  get gridSizeFourDivClass(){
    if (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') {
      return 'slds-col--padded slds-size--4-of-12 blackFontColor';
    }
    else {
      return 'slds-col slds-p-vertical_small blackFontColor';
    }
  }

  get updateButtonDiv(){
    if (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') {
      return 'slds-p-bottom_x-small slds-grid slds-grid--align-end';
    }
    else {
      return 'slds-p-vertical_small slds-grid slds-align_absolute-center';
    }
  }
  

  @api
  invokeConnectedCallBack(){
    this.customConnectedCallBack();
  }


  connectedCallback() {
    this.customConnectedCallBack();
  }

  customConnectedCallBack(){
    this.comboBoxValuesObject                   = {"selectedEventId" : "", "selectedSessionId": ""};
    this.configuredSession                      = [{"label":"None","value":"","isCurrentSession":false,"isSelected":false},{"label":"Main Entrance","value":"Main_Entrance","isCurrentSession":false,"isSelected":false}]; 
    
    // updated if else logic to support fetching values from current page ref parameters 
    if(this.eventIdParamater){
      this.eventIdParamater = this.eventIdParamater.substring(0, 15);
    }
    else if(this.currentPageRef){
     // this.eventIdParamater = this.currentPageRef.state.c__eventid;
    }
    
    if(this.eventRegId && this.sessionId){
      this.eventRegId = this.eventRegId.substring(0, 15);
    }
    else if(this.currentPageRef){
      this.eventRegId = this.currentPageRef.state.c__eventregid;
    }
    
    console.log('this.eventIdParamater '+this.eventIdParamater);
    
    if(this.eventIdParamater){
      console.log('Inside this.eventIdParamater IF');
    getEventRecordValues({eventId : this.eventIdParamater, sessionId : this.sessionId})
    .then(result => {
      if(this.sessionId){
        this.configuredEventName                    = result.eventRecord.Name;
        this.comboBoxValuesObject.selectedEventId   = this.eventIdParamater;
        this.comboBoxValuesObject.selectedSessionId = result.sessionRecord.Id;
        this.configuredSessionName                  = result.sessionRecord.Name;
        this.IS_MAIN_ENTRANCE_SCAN                  = false;
        this.hasExistingConfiguration               = true;
      }
      else{
        this.configuredEventName                    = result.eventRecord.Name;
        this.comboBoxValuesObject.selectedEventId   = this.eventIdParamater;
        this.comboBoxValuesObject.selectedSessionId = 'Main_Entrance';
        this.configuredSessionName                  = 'Main Entrance';
        this.IS_MAIN_ENTRANCE_SCAN                  = true;
      }
      
      this.sendSelectedOptionEvent();
    })
    .catch(error => {
      this.customToastNotification('Error', error.body.message, true);
      this.hideSpinner();
    });
     
      this.hideSpinner();

    }
    else{
      console.log('Inside Else Block');
      this.getInitialWrapperCOnfigurations();

    }
  }


  getInitialWrapperCOnfigurations(){
    console.log('INN ');    
    fetchInitialWrapper()
    .then(result => {
      try{
        this.hasExistingConfiguration = result.hasExistingConfiguration;
        console.log('this.hasExistingConfiguration '+this.hasExistingConfiguration);
        if(result.hasExistingConfiguration){
          this.existingSessionId                      = result.currentSession;
          this.configuredSessionValues                = result.configuredSessions;
          this.comboBoxValuesObject.selectedEventId   = result.configuredEventId;
          this.existingConfigurationRecordId          = result.userConfigRecordId;
          if(result.isMainEntrance){
            this.comboBoxValuesObject.selectedSessionId = 'Main_Entrance';
            this.existingSessionId                      = 'Main_Entrance'
          }
          else{
            this.comboBoxValuesObject.selectedSessionId = result.currentSession;
          }
          this.configuredEventName                    = result.configuredEventName;
          if(result.isMainEntrance){
            this.configuredSessionName                = 'Main Entrance';
            this.IS_MAIN_ENTRANCE_SCAN                = true;
          }
          else{
            this.IS_MAIN_ENTRANCE_SCAN                  = false;
            this.configuredSessionName                  = result.configuredSessionName;
          }
          if(this.isCheckInManager){this.sendSelectedOptionEvent();}
          this.hideSpinner();
           console.log('this.existingSessionId '+this.existingSessionId);
            console.log('this.eventRegId '+this.eventRegId);
          if(this.existingSessionId != null && this.existingSessionId != undefined
              && this.eventRegId != null && this.eventRegId != undefined){this.handleCheckInOut()};
          
        }
        else{
          this.hideSpinner();
        }
      }
      catch(err) {
        this.customToastNotification('Error', err.message, true);
        this.hideSpinner();
        }
    })
    .catch(error => {
        this.customToastNotification('Error', error.body.message, true);
        this.hideSpinner();
      });
  }

  getUserConfigurations(){
    this.showSpinner();
    this.getDesktopUserConfigurations();
  }

  getDesktopUserConfigurations(){
      getEventAndSessionDetails({
        selectedEventId   : this.comboBoxValuesObject.selectedEventId,
        currentSessionId  : this.comboBoxValuesObject.selectedSessionId,
        configuredSession : this.configuredSessionValues.toString()
      })
      .then(result => {
        try {
          this.eventOptions       = result.eventOptions;
          this.sessionOptionsMap  = result.sessionOptions;
          
          this.eventOptions.forEach((element) => {
            if(element.value.includes(this.eventIdParamater)){
              this.comboBoxValuesObject.selectedEventId   = element.value};          });
          this.updateSessionOption();
          this.hideSpinner();
          if(!this.isCancelConfig){
            this.showReconfigurationForm = true;
          }
          else{
            this.showReconfigurationForm = false;
            this.isCancelConfig = false;
          }
          
          this.sendReconfigureRequestEvent();
        }
        catch(err) {
          this.customToastNotification('Error', err.message, true);
          this.hideSpinner();
        }
      })
      .catch(error => {
        this.customToastNotification('Error', error.body.message, true);
        this.hideSpinner();
      });
    
  }

  handleUpdateConfigurationRequest() {
    try{

      if(!this.comboBoxValuesObject['selectedSessionId']){
        this.customToastNotification('Error', 'You have not selected a current location. Please select an option below then update', true);
      }else{
        this.showSpinner();
        let userCongigRecordToUpsert = {};
        userCongigRecordToUpsert['Id']                      = this.existingConfigurationRecordId;
        userCongigRecordToUpsert['Current_Session__c']      = this.comboBoxValuesObject.selectedSessionId;
        userCongigRecordToUpsert['User__c']                 = USER_ID;
        userCongigRecordToUpsert['Event__c']                = this.comboBoxValuesObject.selectedEventId;
        userCongigRecordToUpsert['Name']                    = this.eventOptions.find(events => events.value === this.comboBoxValuesObject.selectedEventId).label;

        userCongigRecordToUpsert['Configured_Sessions__c']  = this.configuredSessionValues.toString();

        if(this.comboBoxValuesObject.selectedSessionId =='Main_Entrance'){
          userCongigRecordToUpsert['Is_Main_Entrance__c']     =  true; 
          userCongigRecordToUpsert['Current_Session__c']      = null;

        }
        else{
          userCongigRecordToUpsert['Current_Session__c']      = this.comboBoxValuesObject.selectedSessionId;
          userCongigRecordToUpsert['Is_Main_Entrance__c']     =  false; 
        }
  
        updateSessionIdConfig({userConfiguration : JSON.stringify(userCongigRecordToUpsert)})
        .then(result => {
          this.hideSpinner();
          this.customToastNotification('Success', 'Session Id Configuration Update successfully', false);
          if(this.existingSessionId != null && this.existingSessionId != undefined
            && this.eventRegId != null && this.eventRegId != undefined){this.handleCheckInOut()};
          this.getInitialWrapperCOnfigurations();
          this.hasExistingConfiguration = true;
          this.showReconfigurationForm = false;
          this.sendReconfigureRequestEvent();
        })
        .catch(error => {
          this.customToastNotification('Error', error.body.message, true);
          this.hideSpinner();
        });
      }
    }
    catch(err) {
      this.customToastNotification('Error', err.message, true);
      this.hideSpinner();
    }
  }

  handleCheckInOut(){
    console.log('this.isCheckInManager '+this.isCheckInManager);
    if(!this.isCheckInManager && this.eventRegId && this.existingSessionId){
      this.showSpinner();
      try{
        updateEventRegStatus({eventRegistrationId : this.eventRegId, sessionId: this.existingSessionId , isMainEntrance : this.IS_MAIN_ENTRANCE_SCAN})
        .then(result => {
        this.hideSpinner();
        this.comboBoxValuesObject                   = {"selectedEventId" : "", "selectedSessionId": ""};
        this.eventRegId = null;
        this.existingSessionId  = null;
        console.log('SUCCESS IN ');
        if(result.isCustomError){
          console.log('ERROR 1 '+result.customErrorMessage);
          this.customToastNotification('Error', result.customErrorMessage, true);
         
          this.hideSpinner();
          
        }
        
        else{
         console.log('ERROR 2 '+result.customErrorMessage);
          this.customToastNotification('Success', result.customSuccessMessage, false);
            this[NavigationMixin.Navigate]({
              type: 'standard__recordPage',
              attributes: {
                  "recordId": result.recordIdToRedirect,
                  "actionName": result.recordActionName
              }
          });
        } 
        
      })
      .catch(error => {
        this.customToastNotification('Error', error.body.message, true);
        this.hideSpinner();
      });

      }
      catch(err) {
        this.customToastNotification('Error', err.message, true);
        this.hideSpinner();
      }
    }
    
  }

  handleComboxValueChange(event){
    this.comboBoxValuesObject[event.target.name] = event.target.value;
    this.eventRegistrationRecords = [];
    
    if(event.target.name != 'selectedSessionId'){
      this.updateSessionOption();
    }
    if(this.isCheckInManager){this.sendSelectedOptionEvent();}
  }

  handleDualBoxValueChange(event){
    if(event.target.name == 'configuredSessionId'){
      this.showSpinner();
      this.configuredSessionValues = event.target.value;
      this.updateCurrentSessionOptions();
    }
  }

  updateSessionOption(){
    if(this.comboBoxValuesObject.selectedEventId
        && this.sessionOptionsMap[this.comboBoxValuesObject.selectedEventId]){
        this.sessionOptions =  this.sessionOptionsMap[this.comboBoxValuesObject.selectedEventId];
        this.updateCurrentSessionOptions();
    }
    else{
      this.sessionOptions    = this.noneValueArray;
      this.configuredSession = [{"label":"None","value":"","isCurrentSession":false,"isSelected":false},{"label":"Main Entrance","value":"Main_Entrance","isCurrentSession":false,"isSelected":false}]; ;
      this.comboBoxValuesObject.selectedSessionId = null;
    }
  } 

  updateCurrentSessionOptions(){
    try{
      if(this.configuredSessionValues.length > 0){
        let configSession = [];
        this.sessionOptions.forEach((element) => {
          if(this.configuredSessionValues.includes(element.value))
            configSession.push(element);
          });
          
          if(configSession.length > 0 ){
            configSession.unshift({"label":"None","value":"","isCurrentSession":false,"isSelected":false},{"label":"Main Entrance","value":"Main_Entrance","isCurrentSession":false,"isSelected":false});
            this.configuredSession = configSession;

            if(this.comboBoxValuesObject.selectedSessionId !='Main_Entrance' 
              && !this.configuredSessionValues.includes(this.comboBoxValuesObject.selectedSessionId)){ 
              this.comboBoxValuesObject.selectedSessionId = "";
            }
          }
          else{
            this.configuredSession =   [{"label":"None","value":"","isCurrentSession":false,"isSelected":false},{"label":"Main Entrance","value":"Main_Entrance","isCurrentSession":false,"isSelected":false}];
            this.comboBoxValuesObject.selectedSessionId = "";
          }
      }
      else{
        this.configuredSession =   [{"label":"None","value":"","isCurrentSession":false,"isSelected":false},{"label":"Main Entrance","value":"Main_Entrance","isCurrentSession":false,"isSelected":false}];
        this.comboBoxValuesObject.selectedSessionId = "";
      }
      this.hideSpinner();
    }
    catch(err){
      this.customToastNotification('Error', err.message, true);
      this.hideSpinner();
    }
  }


  showSpinner() {
    this.spinnerBoolean = true;
  }

  hideSpinner() {
      this.spinnerBoolean = false;
  }

  customToastNotification(toastTitle, toastMessage, isErrorMessage) {

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

  handleComboBoxMobile(event) {
    this.showSpinner();
    var configuredSessionMobile = this.template.querySelector(`[data-id="sessionMobileOptions"]`);
    var selected = [...configuredSessionMobile.selectedOptions].map(option => option.value);
    this.configuredSessionValues = selected;
    this.updateCurrentSessionOptions();
  } 

  handleCancelRecongif(){
    this.isCancelConfig = true;
    this.showSpinner();
    this.getUserConfigurations();
    this.showReconfigurationForm = false;
    
  }
  sendSelectedOptionEvent(){
    let selectedOptions = {'event_ID': this.comboBoxValuesObject.selectedEventId , 'session_ID' : this.comboBoxValuesObject.selectedSessionId};
    const selectedEventSession = new CustomEvent('selectedoptions', { detail: selectedOptions});
    this.dispatchEvent(selectedEventSession);
  }

  sendReconfigureRequestEvent(){
    const reconfigReq = new CustomEvent('reconfigurationrequest', { detail: this.showReconfigurationForm});
    this.dispatchEvent(reconfigReq);
  }
  
}