/**
 * @description       : 
 * @author            : Rajeshkumar
 * @company           : Creation Technology Solutions
 * @last modified on  : 09-28-2021
 * @last modified by  : Javid Sherif
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   15-09-2021   Rajeshkumar   Initial Version
**/
import { LightningElement, api, track } from "lwc";
import socialMediaIcons from '@salesforce/resourceUrl/SocialMediaIcons';
import uopBrandedSocialMediaIcons from '@salesforce/resourceUrl/User_Branding_Social_Icon';
import sitBaseURL from '@salesforce/label/c.Site_Base_URL';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import {
  loadScript,
  loadStyle
} from 'lightning/platformResourceLoader';
import customSR from '@salesforce/resourceUrl/jQueryLibrary';

export default class Ct_eventTileV2 extends NavigationMixin(LightningElement) {
  @api eventDetail;
  @api isEventClicked = false;
  @api singleEvent = false;
  @api selectedEventId;
  @track formattedTime;
  @track fbUrl;
  @track LnUrl;
  @track twitterUrl;
  @track isVisible;
  @track isVisibleFB;
  @track isVisibleLn;
  @track isVisibleTw;
  @track appselected;
  @track isPublicURL;
  startTimeValue;
  endTimeValue;

  facebookIcon = uopBrandedSocialMediaIcons + '/Images/uop-facebook.png';
  linkedinIcon =  uopBrandedSocialMediaIcons + '/Images/uop-linkedIn.png';
  twitterIcon = uopBrandedSocialMediaIcons + '/Images/uop-twitter.png';

  get getGridStyle(){
    let style = 'slds-grid slds-gutters slds-p-top--small';
    if (formFactorPropertyName === 'Small') {
      style = 'slds-grid slds-gutters slds-grid_vertical slds-p-top--small';
    }
    return style;
  }

  convert24To12Hour(timeValue) {
    if (timeValue === null || timeValue === undefined || timeValue === '') return '';
    
    let hours = 0;
    let minutes = 0;

    if (typeof timeValue === 'number') {
        const totalMinutes = Math.floor(timeValue / (1000 * 60));
        hours = Math.floor(totalMinutes / 60) % 24; 
        minutes = totalMinutes % 60;
    } else {
        const strValue = String(timeValue);
        
        const match = strValue.match(/(\d{1,2}):(\d{2})/);
        if (match) {
            hours = parseInt(match[1], 10);
            minutes = parseInt(match[2], 10);
            
            if (strValue.toLowerCase().includes('pm') && hours < 12) {
                hours += 12;
            }
        }
    }

    const period = hours >= 12 ? 'pm' : 'am';
    
    let displayHours = hours % 12;
    displayHours = displayHours === 0 ? 12 : displayHours;
    
    const displayMinutes = String(minutes).padStart(2, '0');

    return `${displayHours}:${displayMinutes} ${period}`;
}

  connectedCallback(){

    console.log('Web_Event_Image__c ============= '+this.eventDetail.Web_Event_Image__c);
    var urlParams = window.location.href;
    var thisURL = new URL(urlParams);
    console.log('Entering Test 1');
    if(urlParams.indexOf('publicURL') > -1 && thisURL.searchParams.get("publicURL") == 'true'){
      this.isPublicURL = true;
    }
    else{
      this.isPublicURL = false;
    }
    
    console.log('Entering Test 2');
    this.startTimeValue = this.convert24To12Hour(this.eventDetail.Start_Time__c);
    this.endTimeValue = this.convert24To12Hour(this.eventDetail.End_Time__c);
    console.log('Entering Test 3');
    //let isVisible;
    if(this.eventDetail.Social_App_Visibility__c === 'Visible'){
      this.isVisible = true;
    }
    console.log('isVisible ============= '+this.isVisible);
    if(this.eventDetail.Visible_Social_App__c != undefined && (this.eventDetail.Visible_Social_App__c.indexOf('Facebook')>-1)){
      this.isVisibleFB =true;
    }
    if(this.eventDetail.Visible_Social_App__c != undefined && (this.eventDetail.Visible_Social_App__c.indexOf('Linkedin')>-1)){
      this.isVisibleLn =true;
    }
    if(this.eventDetail.Visible_Social_App__c != undefined && (this.eventDetail.Visible_Social_App__c.indexOf('Twitter')>-1)){
      this.isVisibleTw =true;
    }
   
  }

  renderedCallback(){
    Promise.all([
      loadScript(this, customSR),
      ])
      .then(() => {
          // $(document).ready(function() {
          //   $("head").append('<meta property="og:image" content="https://i.imgur.com/PsASSr8.jpg" />');
          // });
      })
      .catch(error => {
          console.log(error.body.message);
    });
  }

  get getFormFactor(){
    let isMobile;
    if (formFactorPropertyName === 'Small') {
      isMobile = true;
    }
    return isMobile;
  }

  get formattedTimeValue() {
    return (
      this.convertMilliSecondsToHHMM(this.eventDetail.Start_Time__c) +
      " - " +
      this.convertMilliSecondsToHHMM(this.eventDetail.End_Time__c)
    );
  }

  @api
  set formattedTimeValue(value) {
    this.setAttribute("formattedTimeValue", value);
    this.formattedTimeValue = value;
  }

  handleEventClick(event){
    
    //event.stopPropagation();
    const eventToParent = new CustomEvent('selectedeventdisplay', {
      detail: { eventsearchdisplay: true,
        selectedEventDisplay : true, 
        eventId : this.eventDetail.Id
      },
      bubbles: true,
      composed: true
  });
  this.dispatchEvent(eventToParent);

  }

  handleClickFb(event){
    this.fbUrl = 'https://www.facebook.com/dialog/share?app_id=87741124305&href='+sitBaseURL+'%2Fevent%2Fs%2Fevent-ticket-selection?id='+this.eventDetail.Id+'&display=page&redirect_uri=https://www.facebook.com/';
    window.open(this.fbUrl);
  }
  handleClickTw(event){
    this.twitterUrl = 'https://twitter.com/intent/tweet?url='+sitBaseURL+'/ledevents/s/event-ticket-selection?id='+this.eventDetail.Id;
    window.open(this.twitterUrl);
  }
  handleClickLn(event){
    this.LnUrl= 'https://www.linkedin.com/sharing/share-offsite/?url='+sitBaseURL+'/ledevents/s/event-ticket-selection?id='+this.eventDetail.Id+'%3Fv%3Dpr-4GbR4DpQ%26feature%3Dshare';
    window.open(this.LnUrl);
  }

  convertMilliSecondsToHHMM(durationInMs) {   
    if(durationInMs.toString().includes(':')){ 
      var hours = durationInMs.toString().slice(0,2);
      var mins = durationInMs.toString().slice(3,5);
    
      var AMORPM = hours >= 12 ? 'pm': 'am';

      if(hours > 12){
        hours = hours % 12;      
      }
      return Math.round(hours) + "." + mins + AMORPM;
      //return durationInMs;
    }
    else{
      let milliseconds = parseInt((durationInMs % 1000) / 100),
      seconds = parseInt((durationInMs / 1000) % 60),
      minutes = parseInt((durationInMs / (1000 * 60)) % 60),
      hours = parseInt((durationInMs / (1000 * 60 * 60)) % 24);
      var AMORPM = hours >= 12 ? 'pm': 'am';
      if(hours > 12){
        hours = hours % 12;      
      }
      hours = hours < 10 ? "0" + hours : hours;
      minutes = minutes < 10 ? "0" + minutes : minutes;
      seconds = seconds < 10 ? "0" + seconds : seconds;
      return Math.round(hours) + "." + minutes + AMORPM;
      //return hours + ":" + minutes;
    }
    
  }
}