/**
 * @description       : 
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 01-22-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   01-21-2021   Creation Admin   Initial Version
**/
import { LightningElement ,track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sessionsRelatedToEvent from '@salesforce/apex/ct_SessionRegistrationController.getSessions';
import createSessionReg from '@salesforce/apex/ct_SessionRegistrationController.createSessionReg';
import formFactorPropertyName from '@salesforce/client/formFactor';

export default class Ct_SessionRegistrationFormV2 extends LightningElement {

  //Variables used for paginator
  @track recordsToDisplay = []; //Records to be displayed on the page
  @track rowNumberOffset; //Row number
  //Variables used for paginator

  @track SessionData = [];
  @track mySessions = [];
  @track SessionDataSelected = [];
  @track SessionIds = [];
  @track trackRecords = [];
  @track tabState;
  @track showError = false;
  @track showMenus   = false;
  @track allSessionData = [];
  @track spinnerBoolean = false;
  @track eventId;
  @track sessionTitle = '';
  @track selectedTrackName = 'Tracks';
  @track isRegistering;
  @track isSessions = true;
  @track isChecked;
  @track showTabSpecificRecs = false;
  @track trackId;
  @api recordId; 
  @track isCreated;
  @track mobileTabs = false;
  @track totalTabsWidth;
  @track rendered = false;
  @track runOnce = true;
  @track showAllSesssion = false;
  @track isWaitingListEnabled = false;
  @track isOnWaitingList = false;
  @track displayNameStyle;
  @track buttonStyle;
  @track buttonPosition;
  @track timeStyle;
  @track contentStyle;
  @api eventRegisterId;

  get getFormFactor(){
    let isMobile;
    if (formFactorPropertyName === 'Small') {
      isMobile = true;
      this.mobileTabs = true;
    }
    return isMobile;
  }

  get mobileAlignmentStyle(){
    let gridStyle;
    if (formFactorPropertyName === 'Large') {
        gridStyle = 'slds-grid slds-gutters slds-wrap';
    } else if (formFactorPropertyName === 'Medium') {
        gridStyle = 'slds-grid slds-gutters slds-grid_vertical slds-wrap';
    } else {
        gridStyle = 'slds-grid slds-gutters slds-grid_vertical slds-wrap';
    }
    return gridStyle;
  }

  get mobileDLStyle(){
    let gridStyle;
    if (formFactorPropertyName === 'Large') {
        gridStyle = 'slds-dl_inline__detail slds-p-around--xx-small';
    } else if (formFactorPropertyName === 'Medium') {
        gridStyle = 'slds-dl_inline__detail slds-p-around--xx-small';
    } else {
        gridStyle = 'slds-p-around--xx-small';
    }
    return gridStyle;
  }
  
   get getRegisterButtonAlignment(){
    let alignStyle;
    if (formFactorPropertyName === 'Large') {
        alignStyle = 'slds-float_right';
        //alignStyle = 'slds-float_left';
    } else if (formFactorPropertyName === 'Medium') {
        alignStyle = 'slds-float_left';
    } else {
        alignStyle = 'slds-float_left';
    }
    return alignStyle;
  }

  connectedCallback(){
    var queryString = window.location.href;
    var urlVar = new URL(queryString);
    //var urlRecId = urlVar.searchParams.get("eventRegId");
    var urlRecId = this.eventRegisterId;
    this.recordId = urlRecId;

    if(queryString.indexOf('sessionReg') > -1 && urlVar.searchParams.get("sessionReg") == 'true'){
      this.showAllSesssion = true;
    }

    if (formFactorPropertyName === 'Small') {
      this.mobileTabs = true;
    }
    this.getSessionRecords(this.recordId, '');
    window.addEventListener('resize', this.handleWindowResize);
    this.handleViews();
    window.addEventListener('resize', this.handleViews);
  }

  handleViews = () =>{
    if(window.outerWidth>768){
      this.displayNameStyle = "slds-col slds-size_9-of-12 slds-p-left_x-small";
      this.buttonStyle = "slds-col slds-size_3-of-12";
      this.buttonPosition = "slds-grid slds-grid_align-end";
      this.timeStyle ="slds-col slds-size_1-of-12";
      this.contentStyle ="slds-col slds-size_11-of-12";
    }
    else if(window.outerWidth>385 && window.outerWidth<785){
      this.displayNameStyle = "slds-col slds-size_11-of-12 slds-p-left_x-small";
      this.buttonStyle = "slds-col slds-size_11-of-12";
      this.buttonPosition = "slds-grid";
      this.timeStyle ="slds-col slds-size_2-of-12";
      this.contentStyle ="slds-col slds-size_10-of-12";
    }
    else{
      this.displayNameStyle = "slds-col slds-size_11-of-12 slds-p-left_x-small";
      this.buttonStyle = "slds-col slds-size_11-of-12";
      this.buttonPosition = "slds-grid";
      this.timeStyle ="slds-col slds-size_3-of-12";
      this.contentStyle ="slds-col slds-size_9-of-12";
    }
  };

  handleWindowResize = () =>{
    var calculatedTabWidth = 0;
    var tabContainerWidth = this.template.querySelector('ul').getBoundingClientRect().width;
    this.template.querySelectorAll('.slds-tabs_scoped__item').forEach(
      tabs => {
        calculatedTabWidth = calculatedTabWidth + tabs.getBoundingClientRect().width;
      }
    );
    
    if(parseInt(calculatedTabWidth) > parseInt(tabContainerWidth)){
      this.mobileTabs = true;
    }
    else if(parseInt(tabContainerWidth) >= this.totalTabsWidth){
      this.mobileTabs = false;
    }
    
  };

  handleSessionTitle(event){
    this.sessionTitle = event.target.value;

    [...this.template.querySelectorAll('.slds-tabs_scoped__item')].forEach(
      tabs => {
        if(tabs.dataset.id == 'allSessions'){
          tabs.className = 'slds-tabs_scoped__item slds-is-active';
        }
        else{
          tabs.className = 'slds-tabs_scoped__item';
        }
      }
    );
    this.handleSearch();
  }



  handleSearch(){
    this.showDataRelatedToTrack(this.sessionTitle, 'titleSearch');    
  }



  getSessionRecords(recordId, sessionTitle){
    this.spinnerBoolean = true;
    this.rendered = false;
    sessionsRelatedToEvent({recordId: recordId, bySessionName: sessionTitle})
    .then(result => {
        this.SessionData = result.lstSessions;
        this.eventId = result.eventId;
        this.trackRecords = result.listTracks;
        this.rendered = true;

        this.totalTabsWidth = this.template.querySelector('ul').getBoundingClientRect().width;
        this.spinnerBoolean = false;
    })
    .catch(error => {
        this.error = error;
        this.spinnerBoolean = false;
    })
  }

  renderedCallback(){
    if(this.runOnce){
      try{
        if(!this.showAllSesssion){
          this.showDataRelatedToTrack('mySessions', '');
        }
        else{
          [...this.template.querySelectorAll('.slds-tabs_scoped__item')].forEach(
            tabs => {
              if(tabs.dataset.id == 'allSessions'){
                tabs.className = 'slds-tabs_scoped__item slds-is-active';
              }
              else{
                tabs.className = 'slds-tabs_scoped__item';
              }
            }
          );
          
          this.showDataRelatedToTrack('allSessions', '');
          
        }
        
      }
      catch(err){
        this.runOnce = false;
      }
    }
    
  }

  getMySessions(sessionList){
    var mySession = [];
    for(var i=0;i<sessionList.length;i++){
      if(sessionList[i].isRegistered){
        mySession.push(sessionList[i]);
      }
    }
    //return sessionList.filter(rec => rec.isRegistered);
    return mySession;
  }

  setAbstractVisibility(selectedDataId){
    for(var i=0; i< this.recordsToDisplay.length; i++){
      if(selectedDataId == this.recordsToDisplay[i].session.Id){
        if(this.recordsToDisplay[i].selected){
          this.recordsToDisplay[i].selected = false;
        }
        else if(!this.recordsToDisplay[i].selected){
          this.recordsToDisplay[i].selected = true;
        }
      }
    }
  }

  createUpdateSessionRegistration(selectedSession){
    createSessionReg({jsonData:JSON.stringify(selectedSession), evtRegId: this.recordId, isRegistering: this.isRegistering, isWaitingListEnabled: this.isWaitingListEnabled})
      .then(result => {

        this.isCreated = result;
        if(this.isCreated.includes('true')){
          this.customToastNotification('Sucess', 'Session registration successful', false); // Need to update, Success instead of Sucess
        }
        else if(this.isCreated.includes('false')){
          this.customToastNotification('Sucess', 'Session un-registration successful', false); // Need to update, Success instead of Sucess
        }
        this.getSessionRecords(this.recordId, '');
      }).catch(error => {
        this.customToastNotification('Error', error, true);
    });
  }

  customToastNotification(toastTitle, toastMessage, isErrorMessage) {
    var messageString = isErrorMessage ? 'Error' : 'Success';
    const showToastEvent = new ShowToastEvent({
      Title: toastTitle, // Need to update, title instead of Title
      message: toastMessage,
      variant: messageString
    });
    this.dispatchEvent(showToastEvent);
  }

  handleSessionRegister(event){
    this.isRegistering = true;
    var selectedSession;

    for(var i=0; i< this.SessionData.length; i++){
      if(event.target.dataset.id == this.SessionData[i].session.Id){
        selectedSession = this.SessionData[i];
      }
    }

    if(this.checkConflictingSession(selectedSession)){
      this.createUpdateSessionRegistration(selectedSession);
    }
  }

  handleWaitingListRegistration(event){
    this.isRegistering = true;
    this.isWaitingListEnabled = true;
    
    var selectedSession;
    for(var i=0; i< this.SessionData.length; i++){
      if(event.target.dataset.id == this.SessionData[i].session.Id){
        selectedSession = this.SessionData[i];
      }
    }
      this.createUpdateSessionRegistration(selectedSession);
  }

  checkConflictingSession(selectedSession){
    for(var i=0 ; i<this.SessionData.length ; i++){
      if(this.SessionData[i].isRegistered){
        var registeredSessionStartTime = (this.SessionData[i].session.Start_Time__c / 6000) / 60 / 10;
        var selectedSessionStartTime = (selectedSession.session.Start_Time__c / 6000) / 60 / 10;
        var selectedStartDate = new Date(selectedSession.session.Session_Start_Date__c);
        var thisDateStartDate = new Date(this.SessionData[i].session.Session_Start_Date__c);
        var timeDifference = Math.abs(registeredSessionStartTime - selectedSessionStartTime);
        var duration;

        if(selectedSessionStartTime > registeredSessionStartTime){
          duration = parseInt(this.SessionData[i].sessionDuration.split(" ")[0])/60;
        }
        else{
          duration = parseInt(selectedSession.sessionDuration.split(" ")[0])/60;
        }
         //duration =  parseInt(this.SessionData[i].sessionDuration.split(" ")[0])/60;

        if(timeDifference < duration
          && selectedStartDate.getDate() === thisDateStartDate.getDate()
          && selectedStartDate.getMonth() === thisDateStartDate.getMonth()
          && selectedStartDate.getFullYear() === thisDateStartDate.getFullYear()){
          this.customToastNotification('Conflict', 'This Session is conflicting with "'+(this.SessionData[i].session.Session_Display_Name__c)+'" timing', true);
          return false;
        }
      }
    }
    return true;
  }

  confirmSessionUnregister(event){
    if(event.target.value == 'true'){
         this.handleSessionUnRegister(event.target.dataset.id);
     
    }
    else{
      this.handleSessionUnRegister(event.target.dataset.id);
    }
  }

  handleSessionUnRegister(id){
    this.isRegistering = false;
    var selectedSession;

    for(var i=0; i< this.SessionData.length; i++){
      if(id == this.SessionData[i].session.Id){
        selectedSession = this.SessionData[i];
      }
    }
    this.createUpdateSessionRegistration(selectedSession);
  }

  handleTabState(event){
    this.showMenus = false;
    var classNameVar;
    var classForActive;
    var classForINActive;
    if(this.getFormFactor){
      classNameVar = '.slds-dropdown__item';
      classForActive = 'slds-dropdown__item';
      classForINActive = 'slds-dropdown__item';
      const allTab = this.template.querySelector('.allTab');
      const myTab = this.template.querySelector('.myTab');
      
      if(myTab && event.target.dataset.id == 'mySessions'){
        
        myTab.className = 'slds-tabs_scoped__item slds-is-active myTab';
        classNameVar = '.slds-tabs_scoped__item';
        classForActive = 'slds-tabs_scoped__item slds-is-active myTab';
      } 
      else if(myTab){
        myTab.className = 'slds-tabs_scoped__item myTab';
      }

      if(allTab && event.target.dataset.id == 'allSessions'){
        
        allTab.className = 'slds-tabs_scoped__item slds-is-active allTab';
        classNameVar = '.slds-tabs_scoped__item';
        classForActive = 'slds-tabs_scoped__item slds-is-active allTab';
      } 
      else if(allTab){
        allTab.className = 'slds-tabs_scoped__item allTab';
      }
    }
    else{
      classNameVar = '.slds-tabs_scoped__item';
      classForActive = 'slds-tabs_scoped__item slds-active';
      classForINActive = 'slds-tabs_scoped__item';
    }
    
    [...this.template.querySelectorAll(classNameVar)].forEach(
      tabs => {
        if(tabs.dataset.id == event.target.dataset.id){
          this.selectedTrackName = event.target.title;
          this.trackId = event.target.dataset.id;
          if( this.trackId == 'allSessions'){
            this.selectedTrackName = 'Tracks';
            this.showTabSpecificRecs = false;
          }
          else if( this.trackId == 'mySessions'){            
            this.selectedTrackName = 'Tracks';
            this.showTabSpecificRecs = false;
          }
          else{
            this.showTabSpecificRecs = true;
          }
          this.showDataRelatedToTrack(this.trackId, 'trackSearch');
          tabs.className = classForActive;
        }
        else{
          tabs.className = classForINActive;
        }
      }
    );
  }

  showDataRelatedToTrack(searchValue, searchType){
    const paginator = this.template.querySelector('c-ct_lightning-paginator-v2');
    if(paginator){
      paginator.handleSessionSearch(searchValue, searchType);
      this.runOnce = false;
    }
  }
  
  //Capture the event fired from the paginator component
  handlePaginatorChange(event){
    if(event.detail == 'No Records'){
      this.showError = true;
    }
    else{
      this.showError = false;
      this.recordsToDisplay = this.createObject(event.detail);
      if(this.isCreated && this.showTabSpecificRecs){
        var trackId = this.isCreated.split('-')[1];
        this.showDataRelatedToTrack(trackId, 'trackSearch');
        this.isCreated = ''; 
      }
    }
  }

  createObject(result){
    let recs = [];
    for(let i=0; i<result.length; i++){
        let record = {};
        record.rowNumber = ''+(i+1);
        record = Object.assign(record, result[i]);
        recs.push(record);
    }
    return recs;
  }

  show_Abstract(event){
    this.setAbstractVisibility(event.target.dataset.id);
  }
  hide_Abstract(event){
    this.setAbstractVisibility(event.target.dataset.id);
  }

  showMenu(event){
    this.showMenus = true;
  }
  hideMenu(event){
    this.showMenus = false;
  }

}