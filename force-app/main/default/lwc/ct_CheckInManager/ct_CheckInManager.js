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
import { LightningElement, api ,track} from "lwc";
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInitialWrapperData from '@salesforce/apex/ct_CheckInManagerController.getInitialWrapper';
import fetchRegistrationRecords from '@salesforce/apex/ct_CheckInManagerController.getRegistrationRecords';
import getDashBoardResult from '@salesforce/apex/ct_CheckInManagerController.getDashBoardAggregrate';
import getSessionRegister from '@salesforce/apex/ct_CheckInManagerController.getSessionRegistrationRecords';
import formFactorPropertyName from '@salesforce/client/formFactor';



const DELAY             = 500;

export default class Ct_CheckInManager extends LightningElement {
  @track xlsHeader = []; // store all the headers of the the tables
  @track workSheetNameList = []; // store all the sheets name of the the tables
  @track xlsData = []; // store all tables data
  @track filename = "Printed Register (Events & Sessions).xlsx"; // Name of the file

  //FOR CUSTOM ERROR TOAST
  customToastTitle = 'Error';
  customToastMessage = 'Error';
  customMessageVariant = 'error';


  channelName                   = '/data/Event_Registration__ChangeEvent';
  sessionChannelName            = '/data/Session_Registration__ChangeEvent';
  
  @api eventIdParamater;
  @api sessionIdParamater;

  //TODO : to remove
  testURL                = 'true';

  spinnerBoolean                = true;
  showForm                      = false;
  expandSearchAccordion         = false;
  isEventRegRecordsBeingFetched = false;
  isSearchInvokedFirstTime      = false;
  showXlsxForm                  = false;
  isReconfigurationRequest      = false;
  showInternalRegistrationComponent = false;
  

  eventOptions                  = [];
  eventRegistrationRecords      = [];
  sessionOptions                = [];
  noneValueArray                = [{"label":"None","value":""}];
  registrationRecordNameKeys    = [];

  comboBoxValuesObject          = {};
  @ track eventRegistrationCountStatus  = {};
  searchFormData                = {};
  subscription                  = {};
  sessionOptionsMap             = {};
  registrationRecordsByFirstLetter = {};

  get checkInManagerTitleText(){
    return 'Update the status of Event & Session Attendees via QR Code Scan or manually using the Check in Manager below';
  }

  get noRecordsFoundMessage(){
    return this.isMainEntrance ? 'No Event Registration records found!' : 'No Session Registration records found!';
  }

  get isMainEntrance(){

    return (this.comboBoxValuesObject.selectedSessionId != null && this.comboBoxValuesObject.selectedSessionId != undefined && this.comboBoxValuesObject.selectedSessionId == 'Main_Entrance');
  }

  get registeredStyle(){
    return "font-size: 50px !important; color : black !important; font-weight: bold !important;";
  }
  
  get checkedInStyle(){
    return "font-size: 50px !important; color : green !important; font-weight: bold !important;";
  }

  get checkedOutStyle(){
    return "font-size: 50px !important; color : #351c75 !important; font-weight: bold !important;";
  }

  get didNotAttendStyle(){
    return "font-size: 50px !important; color : red !important; font-weight: bold !important;";
  }
  
  get perCheckedInStyle(){
    return "font-size: 50px !important; color : white !important; font-weight: bold !important;background: #9900FF;"; 
  }

  get perCheckedInMobileStyle(){
    return "text-align: center; color : white !important; font-weight: bold !important;background: #9900FF;"; 
  }

  get searchTitleStyle(){
    return 'font-weight: bold;color:white !important;';
  }

  get searchIconName(){
    return this.expandSearchAccordion ? 'utility:chevrondown' : 'utility:chevronright';
  } 

  get isEventRegistrationRecordsAvailable(){
    return (this.eventRegistrationRecords != null && this.eventRegistrationRecords != undefined && this.eventRegistrationRecords.length > 0);
  }

  get tableStatusHeadingStyle(){
    return 'width:90px !important';
  } 

  get tableHeadingStyle(){
    return (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') ? 'text-align:center !important; color: white;background: grey;' : 'text-align:left !important; color: white;background: grey;';
  } 

  get tableMainHeadingStyle(){
    return 'text-align:center !important; color: white;background: grey;';
  }

  get widthTwentyPerStyle(){
    return 'max-width : 20% !important';
  }

  get widthFifteenPerStyle(){
    return 'max-width : 15% !important';
  }

  get borderStyle(){
    return "width: 95%;border-top: 2px solid #808080;";
  }

  get searchBtnClass(){
    return (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') ? 'searchButtonStyle slds-button slds-button_success' : 'searchMobileButtonStyle slds-button slds-button_success;';
  }

  get gridDivClass(){
    if (formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium') {
      return 'slds-p-vertical_small slds-grid slds-grid--pull-padded slds-wrap';
    }
    else {
      return 'slds-grid slds-grid_vertical';
    }
  }

  get isMobileDevice(){
    return (formFactorPropertyName === 'Large') ? false : true;
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
      return 'slds-col--padded slds-size--4-of-12';
    }
    else {
      return 'slds-col slds-p-vertical_small';
    }
  }


  get perRegisteredBar(){
    var perReg = 0;

    if(this.eventRegistrationCountStatus.totalRegistered > 0){
      var totalEventRegistration = this.eventRegistrationCountStatus.totalRegistered + this.eventRegistrationCountStatus.totalCheckedIn + this.eventRegistrationCountStatus.totalCheckedOut + this.eventRegistrationCountStatus.totalDidNotAttend;
      perReg = Math.round( (this.eventRegistrationCountStatus.totalRegistered / totalEventRegistration) * 100 );
    }
    return perReg;
  }

  get perRegisteredBarAssist(){
    return `Registered: ${this.perRegisteredBar}%`;
  }
  
  get perRegisteredBarWidth(){
    return `width:${this.perRegisteredBar}%; background: black !important;`;
  }

  get perCheckedInBar(){
    var perCheckIn = 0;

    if(this.eventRegistrationCountStatus.totalCheckedIn > 0){
      var totalEventRegistration = this.eventRegistrationCountStatus.totalRegistered + this.eventRegistrationCountStatus.totalCheckedIn + this.eventRegistrationCountStatus.totalCheckedOut + this.eventRegistrationCountStatus.totalDidNotAttend;
      perCheckIn = Math.round( (this.eventRegistrationCountStatus.totalCheckedIn / totalEventRegistration) * 100 );
    }
    return perCheckIn;
  }

  get perCheckedInBarAssist(){
    return `Checked In: ${this.perCheckedInBar}%`;
  }

  get perCheckedInBarWidth(){
    return `width:${this.perCheckedInBar}%; background: #3B7E47 !important;`;
  }

  get perCheckedOutBar(){
    var perCheckOut = 0;

    if(this.eventRegistrationCountStatus.totalCheckedOut > 0){
      var totalEventRegistration = this.eventRegistrationCountStatus.totalRegistered + this.eventRegistrationCountStatus.totalCheckedIn + this.eventRegistrationCountStatus.totalCheckedOut + this.eventRegistrationCountStatus.totalDidNotAttend;
      perCheckOut = Math.round( (this.eventRegistrationCountStatus.totalCheckedOut / totalEventRegistration) * 100 );
    }
    return perCheckOut;
  }

  get perCheckOutBarAssist(){
    return `Checked Out: ${this.perCheckedOutBar}%`;
  }

  get perCheckedOutBarWidth(){
    return `width:${this.perCheckedOutBar}%; background: #351c75 !important;`;
  }

  get perDidNotAttendBar(){
    var perDidNotAttend = 0;

    if(this.eventRegistrationCountStatus.totalDidNotAttend > 0){
      var totalEventRegistration = this.eventRegistrationCountStatus.totalRegistered + this.eventRegistrationCountStatus.totalCheckedIn + this.eventRegistrationCountStatus.totalCheckedOut + this.eventRegistrationCountStatus.totalDidNotAttend;
      perDidNotAttend = Math.round( (this.eventRegistrationCountStatus.totalDidNotAttend / totalEventRegistration) * 100 );
    }
    return perDidNotAttend;
  }

  get perDidNotAttendBarWidth(){
    return `width:${this.perDidNotAttendBar}%; background: #C23934 !important;`;
  }

  connectedCallback() {
    console.log('CheckIn manger loaded')
    //Change Data Capture Event
    this.registerErrorListener();   

    this.handleSubscribe();

    this.comboBoxValuesObject         = {"selectedEventId" : "", "selectedSessionId": ""};
    this.eventRegistrationCountStatus = {"totalRegistered" : 0, "totalCheckedIn" : 0, "totalCheckedOut" : 0, "totalDidNotAttend": 0, "perCheckedIn" : 0};
    this.searchFormData               = {"eventRegNameFilter" : "", "orderRefNumberFilter": "", "ticketRefNumberFilter": "", "eventRegistrationEmailFilter": "", "eventRegMobileFilter" : ""};
    this.sessionOptions               = this.noneValueArray;
  
    this.hideSpinner();
    this.showForm = true;
  }


  setDashboardCountValues(dashBoardResponse){
    this.eventRegistrationCountStatus = {"totalRegistered" : 0, "totalCheckedIn" : 0, "totalCheckedOut" : 0, "totalDidNotAttend": 0, "perCheckedIn" : 0};
    if(dashBoardResponse.hasOwnProperty('REGISTERED'))
    { this.eventRegistrationCountStatus.totalRegistered      = dashBoardResponse["REGISTERED"]};

    if(dashBoardResponse.hasOwnProperty('CHECKED_IN'))
    { this.eventRegistrationCountStatus.totalCheckedIn       = dashBoardResponse["CHECKED_IN"]};

    if(dashBoardResponse.hasOwnProperty('CHECKED_OUT'))
    { this.eventRegistrationCountStatus.totalCheckedOut       = dashBoardResponse["CHECKED_OUT"]};

    if(dashBoardResponse.hasOwnProperty('DID_NOT_ATTEND'))
    { this.eventRegistrationCountStatus.totalDidNotAttend    = dashBoardResponse["DID_NOT_ATTEND"]};

    if(this.eventRegistrationCountStatus.totalCheckedIn > 0){
        var totalEventRegistration = this.eventRegistrationCountStatus.totalRegistered + this.eventRegistrationCountStatus.totalCheckedIn + this.eventRegistrationCountStatus.totalCheckedOut + this.eventRegistrationCountStatus.totalDidNotAttend;
        this.eventRegistrationCountStatus.perCheckedIn = Math.round( (this.eventRegistrationCountStatus.totalCheckedIn / totalEventRegistration) * 100 );
      }
  }
  testURLhandle(event){
    this.testURL = event.target.value;
  }
  handleClick(){
    window.location.assign(this.testURL);
  }

  handleQRSetupChange(event){
    console.log('INN');
    var selectedOptions = event.detail;
    console.log('selectedOptions '+JSON.stringify(selectedOptions));
    this.comboBoxValuesObject.selectedEventId = selectedOptions.event_ID;
    this.comboBoxValuesObject.selectedSessionId = selectedOptions.session_ID;
    this.refreshDashBoardValues();
    this.fetchEventRegRecords();
  }

  handleReconfigurationRequest(event){
    this.isReconfigurationRequest = event.detail;
  }

  handleComboxValueChange(event){
    this.comboBoxValuesObject[event.target.name] = event.target.value;
    if(event.target.name == 'selectedEventId'){
      this.comboBoxValuesObject.selectedSessionId = 'Main_Entrance';
    }

    this.eventRegistrationRecords = [];
    this.updateSessionOption();
    this.refreshDashBoardValues();
    this.fetchEventRegRecords();
  }

  updateSessionOption(){

    if(this.comboBoxValuesObject.selectedEventId
        && this.sessionOptionsMap[this.comboBoxValuesObject.selectedEventId]){
        this.sessionOptions =  this.sessionOptionsMap[this.comboBoxValuesObject.selectedEventId];
        if(this.sessionOptions[0].value !='Main_Entrance'){
          this.sessionOptions.unshift({"label":"Main Entrance","value":"Main_Entrance"});
        }
    }
    else{
      this.sessionOptions = this.noneValueArray;
      this.comboBoxValuesObject.selectedSessionId = null;
    }
  }

  handleSubscribe() {

    const that = this; 

    // Callback invoked whenever a new event message is received
    const messageCallback = function(response) {
      // Response contains the payload of the new message received
      if(response.data.payload.ChangeEventHeader.changedFields != undefined
        && response.data.payload.ChangeEventHeader.changedFields != null
        && (response.data.payload.ChangeEventHeader.changedFields.includes('Event_Registration_Status__c')
          || response.data.payload.ChangeEventHeader.changedFields.includes('Status__c'))){
        try {
          that.refreshDashBoardValues();
        }
        catch(err) {
          that.customToastNotification('Error', err.message, true);
          that.hideSpinner();
        }
      } 
    };

    isEmpEnabled(this.channelName, -1, messageCallback).then(response => {
      // Response contains the subscription information on subscribe call
  });

  

    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback).then(response => {
        // Response contains the subscription information on subscribe call
        this.subscription = response;
    });

    subscribe(this.sessionChannelName, -1, messageCallback).then(response => {
      // Response contains the subscription information on subscribe call
      this.subscription = response;
    });

  }

  resethDashBoardValues(){
    this.eventRegistrationCountStatus = {"totalRegistered" : 0, "totalCheckedIn" : 0, "totalCheckedOut" : 0, "totalDidNotAttend": 0, "perCheckedIn" : 0};
  }

  refreshDashBoardValues(){
    if(this.comboBoxValuesObject.selectedEventId){
      try {
        getDashBoardResult({
          eventId: this.comboBoxValuesObject.selectedEventId,
          sessionId : this.comboBoxValuesObject.selectedSessionId,
          isMainEntrance : this.isMainEntrance
        })
          .then(result => {
            this.setDashboardCountValues(result);
            this.hideSpinner();
          })
          .catch(error => {
            this.customToastNotification('Error', JSON.stringify(error), true);
            this.hideSpinner();
          });
        }
        catch(err) {
          this.customToastNotification('Error', err.message, true);
          this.hideSpinner();
        }
      }
      else{
       this.resethDashBoardValues();
        this.hideSpinner();
      } 
  }

  handleSearchFormChange(event){
    this.searchFormData[event.target.name] = event.target.value;
  }

  handleSearch(){
    if(this.searchFormData.eventRegNameFilter && this.searchFormData.eventRegNameFilter.trim()
      || (this.searchFormData.orderRefNumberFilter && this.searchFormData.orderRefNumberFilter.trim())
      || (this.searchFormData.ticketRefNumberFilter && this.searchFormData.ticketRefNumberFilter.trim())
      || (this.searchFormData.eventRegistrationEmailFilter && this.searchFormData.eventRegistrationEmailFilter.trim())
      || (this.searchFormData.eventRegMobileFilter && this.searchFormData.eventRegMobileFilter.trim())){
        this.fetchEventRegRecords();
      }
      else{
        this.customToastNotification('Error', 'Please enter Event Registration Name or Order Reference Number or Ticket Reference Number or Event Registration Email before searching', true);
      }
  }

  handleResetSearch(){
    this.searchFormData               = {"eventRegNameFilter" : "", "orderRefNumberFilter": "", "ticketRefNumberFilter": "", "eventRegistrationEmailFilter": ""};
    this.fetchEventRegRecords();
  } 

  invokefetchEventRegRecords(event){
    this.fetchEventRegRecords();
  }
  
  //Initially Method was written to retrieve Event Registration but later updated code to get Session  Registrations
  fetchEventRegRecords(){
    if(!this.isSearchInvokedFirstTime){this.isSearchInvokedFirstTime = true;}
    if(!this.isEventRegistrationRecordsAvailable){this.showSpinner()};

    if(this.comboBoxValuesObject.selectedEventId 
      || this.comboBoxValuesObject.selectedSessionId){
        this.isEventRegRecordsBeingFetched = true;
    fetchRegistrationRecords({
      nameFilter     : this.searchFormData.eventRegNameFilter,
      orderRefNumber : this.searchFormData.orderRefNumberFilter,
      ticketRefNumber: this.searchFormData.ticketRefNumberFilter,
      eventRegEmail  : this.searchFormData.eventRegistrationEmailFilter,
      eventId        : this.comboBoxValuesObject.selectedEventId,
      sessionId      : this.comboBoxValuesObject.selectedSessionId,
      isMainEntrance : this.isMainEntrance,
      mobilenumber   : this.searchFormData.eventRegMobileFilter
    })
    .then(result => {
      try {
        this.eventRegistrationRecords = result;
        console.log('eventRegistrationRecords '+this.eventRegistrationRecords);
        if(this.isMobileDevice
          && this.isEventRegistrationRecordsAvailable){this.processRegistrationRecordsForMobile()};
      }
      catch(err) {
        this.customToastNotification('Error', err.message, true);
      }
      this.isEventRegRecordsBeingFetched = false;
      this.hideSpinner();
    })
    .catch(error => {
      this.isEventRegRecordsBeingFetched = false;
      this.hideSpinner();
      this.customToastNotification('Error', error.body.message, true);
    });
    }
    else{
      this.hideSpinner();
    }
  }

  toggleSearchExpandCollapse(){
    this.expandSearchAccordion = !this.expandSearchAccordion;
  }

  showSpinner() {
    this.spinnerBoolean = true;
  }

  hideSpinner() {
      this.spinnerBoolean = false;
  }


  handlesessionRegUpdatedEvent(event) {
    this.fetchEventRegRecords();
    this.refreshDashBoardValues();
  }

  handleEventRegistrationDone = () => {     
    this.showInternalRegistrationComponent = false;};

  registerErrorListener() {
    // Invoke onError empApi method
    onError(error => {
        // Error contains the server-side error
    });
  }

  customToastNotification(toastTitle, toastMessage, isErrorMessage) {
    if(this.isMobileDevice){
      this.customToastTitle = toastTitle;
      this.customToastMessage = toastMessage;
      this.customMessageVariant = isErrorMessage ? 'Error' : 'Success';
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

  // XLXS Function
  // formating the data to send as input to  xlsxMain component
  xlsFormatter(data, sheetName) {
    let Header = Object.keys(data[0]);
    this.xlsHeader.push(Header);
    this.workSheetNameList.push(sheetName);
    this.xlsData.push(data);
  }

  printRegister() {
    this.showSpinner();
    this.showXlsxForm = true;    
    if(!this.isMainEntrance){
      var sessionRegData = [];

      getSessionRegister({
        eventId: this.comboBoxValuesObject.selectedEventId,
        sessionId : this.comboBoxValuesObject.selectedSessionId,
        isMainEntrance : this.isMainEntrance
      })
      .then(result => {
        try {
          if(result && result.length > 0){
            result.forEach(item=>{
              sessionRegData.push(
                {
                "Registration Number": item.Event_Registration__r.Name, 
                "Event Registration Status": item.Event_Registration__r.Event_Registration_Status__c,
                "First Name": item.First_Name__c,
                "Last Name": item.Last_Name__c,
                "Event Email": item.Event_Registration__r.Event_Email__c,
                "Event Mobile": item.Event_Registration__r.Event_Mobile__c,
                "Registration Type": item.Event_Registration__r.Registration_Type__c,
                "Session Registration Reference": item.Name,
                "Status": item.Status__c
                });
            })
            this.xlsFormatter(sessionRegData, "Session Register");
            this.download();
          }
          else{
            this.customToastNotification('Error', 'No Event registrations found for the selected Session', true);
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
      var eventRegData = [];
    
      this.eventRegistrationRecords.forEach(item=>{
        eventRegData.push(
          {
          "Registration Number": item.Name, 
          "Event Registration Status": item.Event_Registration_Status__c,
          "First Name": item.First_Name__c,
          "Last Name": item.Last_Name__c,
          "Event Email": item.Event_Email__c,
          "Event Mobile": item.Event_Mobile__c,
          "Registration Type": item.Registration_Type__c
          });
      })
      this.xlsFormatter(eventRegData, "Event Register");
      this.download();
    }
    this.hideSpinner();
    
  }

  processRegistrationRecordsForMobile() {
    let array = this.eventRegistrationRecords;
    
    let registrationByFrstLetter = array.reduce((a, c) => {

      let k;
      if(this.isMainEntrance){
        k = (c.Last_Name__c != undefined && c.Last_Name__c != null) ?  c.Last_Name__c[0].toLocaleUpperCase() : 'G';
      } 
      else{
        k = (c.Event_Registration__r.Last_Name__c != undefined && c.Event_Registration__r.Last_Name__c != null) ?  c.Event_Registration__r.Last_Name__c[0].toLocaleUpperCase() : 'G';
      }

      if (a[k]) a[k].push(c)
      else a[k] = [c]
      return a
    }, {});

    this.registrationRecordsByFirstLetter = registrationByFrstLetter;
    this.registrationRecordNameKeys = Object.keys(this.registrationRecordsByFirstLetter).sort();
  }

  newEventOrderForm() {
    this.showInternalRegistrationComponent = true;
    console.log('showInternalRegistrationComponent>>>>>>>>> ' + this.showInternalRegistrationComponent);
  }
  
  closeInternalEventRegModal() {
    this.showInternalRegistrationComponent = false;
    this.fetchEventRegRecords();
    this.refreshDashBoardValues();
  }

  // calling the download function from xlsxMain.js 
  download() {
    this.template.querySelector("c-xlsx-main").download();
  }

  handleXlsxDownloadComplete(event) {
    this.showXlsxForm = false;
    window.location.reload();
  }

}