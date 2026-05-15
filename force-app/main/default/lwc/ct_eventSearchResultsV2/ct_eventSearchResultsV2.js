import { LightningElement, wire, track, api } from "lwc";
//import searchEventsByName from "@salesforce/apex/CT_EventSearchController.searchEventsByName";
import getEventsBySearch from "@salesforce/apex/CT_EventSearchController.getEventsBySearch";
import getEventById from "@salesforce/apex/CT_EventSearchController.getEventById";
import formFactorPropertyName from '@salesforce/client/formFactor';
//import UOP_LOGO from '@salesforce/resourceUrl/ct_UOP_Logo';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Ct_eventSearchResultsV2 extends LightningElement {

  //Variables used for paginator
  @track recordsToDisplay = []; //Records to be displayed on the page
  @track rowNumberOffset; //Row number
  //@track uopLOGO = UOP_LOGO;
  //Variables used for paginator

  @track eventSearchResults;
  @track existingEventRegistration = false;
  IdParam = false;
  eventName = "";
  eventType = "";
  eventGroup = "";
  sortvalue;
  selectedEventId;
  selectedEvent = false;
  noEventRegistrationPage = 'Event Registration Page not available. To publish this page please change the event publishing settings';

  get options() {
    return [
        { label: 'A - Z', value: 'a to z' },
        { label: 'Z - A', value: 'z to a' },
        { label: 'Upcoming Events', value: 'upcoming events' },
    ];
  }

  get getUopLogoStyle() {
    let logoStyle;
    if (formFactorPropertyName === 'Large') {
        logoStyle = 'width: 25%; height:20%;';
    } else {
        logoStyle = 'width: 200px !important;';
    }
    return logoStyle;
}


  connectedCallback(){
   console.log('INNNN')
    /*Get Id from the URL To Load A particular Event*/
    var queryString = window.location.href;
    var urlVar = new URL(queryString);
    var eventId = urlVar.searchParams.get("id");
    console.log('urlVar for click event >>>>>'+ queryString);
    
    if(eventId){
      this.existingEventRegistration = true;
      getEventById(
        {
          byEventId: eventId
        }
      ).then(result => {
        if(result[0] == undefined){
          this.IdParam = true;
        }
        else if(result != "undefined" && result != null && result.length > 0){
          this.eventSearchResults = this.createEventObject(result);
          this.recordsToDisplay = this.eventSearchResults;
          this.selectedEventId = JSON.stringify(this.eventSearchResults[0].Id);
          this.selectedEvent = true;
        } 
        console.log('Entered getEventbyId - Success');
      //logic for pagination
      }).catch(error => {
        console.log('Entered getEventbyId - Error');
        this.customToastNotification('Error', error, true);
      });
    }
    else{
      var querystrng = window.location.href;
      var grpUrl = new URL(querystrng);
      var evtgrpId = grpUrl.searchParams.get("searchByGroup");
      if(evtgrpId != undefined && evtgrpId != null){
        this.eventGroup = evtgrpId;
      }
      console.log('entered searchEventRecords');
      this.searchEventRecords(this.eventName, this.eventType, this.eventGroup, eventId);
    }
  }

  @api
  searchEventRecords(byName, byType, byGroup, byEventId){
    console.log('entered searchEventRecords');
    getEventsBySearch(
      {
        byName : byName,
        byType : byType,
        byGroup: byGroup,
        byEventId: byEventId,
      }
    ).then(result => {
      this.eventSearchResults = this.createEventObject(result);
     
      const baseUrl = window.location.protocol + '//' + window.location.host;
      for(let i=0; i<this.eventSearchResults.length; i++){
        var imageURL = this.eventSearchResults[i].Web_Event_Image__c;

        const srcStart = imageURL.indexOf('src="') + 5;
        const srcEnd = imageURL.indexOf('"', srcStart);
        imageURL = imageURL.substring(srcStart, srcEnd);
        imageURL = imageURL.replace(/&amp;/g, '&');
        //imageURL = 'https://creationevents-dev-ed.develop.my.site.com/'+imageURL
        if (!imageURL.startsWith('http')) {
          imageURL = `${baseUrl}/${imageURL}`;
        }
        this.eventSearchResults[i].Web_Event_Image__c = imageURL;
        
      }
      
      if(byName || byType || byGroup){
        this.recordsToDisplay = this.eventSearchResults;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
     }
     console.log('Entered getEventsBySearch - Success ');
    //logic for pagination
    }).catch(error => {
      console.log('Entered getEventsBySearch - Error');
      this.customToastNotification('Error', error, true);
    });
  }

  sortSearchResults(event){
    if(event.target.value == 'a to z'){
      this.recordsToDisplay.sort(this.compare);
     this.recordsToDisplay = this.createEventObject(this.recordsToDisplay);
    }
    else if(event.target.value == 'z to a'){
      this.recordsToDisplay.reverse();
     this.recordsToDisplay = this.createEventObject(this.recordsToDisplay);
    }
    else if(event.target.value == 'upcoming events'){
      this.recordsToDisplay.sort(this.comparebyDate);
      this.recordsToDisplay = this.createEventObject(this.recordsToDisplay);
    
  }
  }

  compare(a, b) {
    // Use toUpperCase() to ignore character casing
    
    const webNameA = a.Web_Event_Name__c.toUpperCase();
    const webNameB = b.Web_Event_Name__c.toUpperCase();
  
    let comparison = 0;
    if (webNameA > webNameB) {
      comparison = 1;
    } else if (webNameA < webNameB) {
      comparison = -1;
    }
    return comparison;
  }
  comparebyDate(a, b) {
    // Use toUpperCase() to ignore character casing
    
    const date1 = a.Event_Start_Date__c;
    const date2 = b.Event_Start_Date__c;
  
    let comparison = 0;
    if (date1 > date2) {
      comparison = 1;
    } else if (date1 < date2) {
      comparison = -1;
    }
    return comparison;
  }
  
  createEventObject(result){
     console.log('result '+JSON.stringify(result));
    let recs = [];
    for(let i=0; i<result.length; i++){
        let eventRecord = {};
        eventRecord.rowNumber = ''+(i+1);
        eventRecord.eventRecordLink = '/'+result[i].Id;
        eventRecord = Object.assign(eventRecord, result[i]);
        recs.push(eventRecord);
    }
    return recs;
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

  //Capture the event fired from the paginator component
  handlePaginatorChange(event){
    this.recordsToDisplay = event.detail;
    if(event.detail.length>0){
      this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }
    //this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
  }


}