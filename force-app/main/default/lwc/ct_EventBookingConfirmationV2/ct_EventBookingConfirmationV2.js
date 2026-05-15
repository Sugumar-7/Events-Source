/**
 * @description       : 
 * @author            : Rajesh Creation
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : Javid Sherif
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   07-05-2021   Rajesh Creation   Initial Version
**/
import { LightningElement, track ,api} from 'lwc';
import getInitialWrapperData from '@salesforce/apex/ct_EventBookingConfirmationController.getInitialWrapper';
import BOOKING_CONFIRMATION_IMAGE from '@salesforce/resourceUrl/ct_EventResgistrationBookingConfirmation';
import uopBrandedSocialMediaIcons from '@salesforce/resourceUrl/User_Branding_Social_Icon';
import SITE_BASE_URL from '@salesforce/label/c.Site_Base_URL';

import getRecordTypeDevName from '@salesforce/apex/ct_EventBookingConfirmationController.getRecordTypeDevNameById';

//***Need to update***
// Need to import ShowToastEvent because it is used in the code (Line-133)

export default class Ct_EventBookingConfirmationV2 extends LightningElement {
  bookingConfirmationImage = BOOKING_CONFIRMATION_IMAGE;
  
  spinnerBoolean                = true;
  
  eventRegistrationsRecords     = [];
  isSessionRegistrationsAvailable = false;
  eventRecord= {};

  facebook = uopBrandedSocialMediaIcons + '/Images/uop-facebook.png';
  linkedin = uopBrandedSocialMediaIcons + '/Images/uop-linkedIn.png';
  twitter = uopBrandedSocialMediaIcons + '/Images/uop-twitter.png';
  @track selectedEvent;
  @track hasScrolledToTop = false;
  @api ticketOrderId;


  EventrecordtypeId;
  eventRecordTypeDevName;
  isSimpleEvent;



  get bookingConfirmationImageStyle(){
    //return 'max-height:100%; height: auto;width: 100%;';
    return 'height:40%;'
  }

  get bookingConfirmationTitle(){
    return 'Thanks for your booking';
  }
  
  get bookingConfirmationBody(){
    return 'We\'re looking forward to seeing you at this event. Take a minute to review your booking details below.';
  }
  get bookingConfirmationMessage(){
    return "<div class='BookingConfirmationMessage'>Before you go</div><br/><p>We run regular events throughout the year – from public lectures, performances and exhibitions, to conferences, seminars and open days. Take a look at <a href='https://www.google.com'>upcoming events</a> upcoming events and discover our <a href='https://www.google.com'>latest news and blogs</a>  for more insight into our research breakthroughs and student successes.</p>"
    //return this.eventRecord.Success_Message__c;
  }

  get sessionRegistrationTitle(){
    return 'Session Registration for this Event is Open';
  }

  get sessionRegistrationMessage(){
    return 'Please register for sessions in advance to avoid disappointment. To do this click the \'Session Registration\' button further to each Ticket & select the sessions that you wish to attend.';
  }
  
  get sessionRegistraionInfoStyle(){
    return 'background: #4A9E14;text-align: center;'
  }

  get shareOnSocialMediaMessage(){
    return 'Help us Spread the word. Please share this Event on social media';
  }

  get isSocialShareLinkEnabled(){
    return this.eventRecord.Social_App_Visibility__c === 'Visible';
  }

  get isFaceBookShareLinkAvailable(){
    return this.eventRecord.Visible_Social_App__c != undefined && (this.eventRecord.Visible_Social_App__c.indexOf('Facebook')>-1);
  }

  get isTwitterShareLinkAvailable(){
    return this.eventRecord.Visible_Social_App__c != undefined && (this.eventRecord.Visible_Social_App__c.indexOf('Twitter')>-1);
  }

  get isLinkedInShareLinkAvailable(){
    return this.eventRecord.Visible_Social_App__c != undefined && (this.eventRecord.Visible_Social_App__c.indexOf('Linkedin')>-1);
  }

  connectedCallback() {
    var queryString = window.location.href;
    var urlVar = new URL(queryString);
    var eventOrderIdVar = this.ticketOrderId;
    var asperatoIdVar = urlVar.searchParams.get("asperatoId");
    getInitialWrapperData({
      eventOrderId : eventOrderIdVar,
      asperatoId: asperatoIdVar
    })
    .then(result => {
      try {
        this.eventRegistrationsRecords = result.eventRegistrations;
        this.isSessionRegistrationsAvailable = result.isSessionRegistrationAvailable;
        this.eventRecord = result.eventRecord;
        this.selectedEvent = result.eventRecord;

        console.log('eventRecord>>>>'+JSON.stringify(this.eventRecord));

        this.eventRecordType = this.selectedEvent.RecordTypeId;
        console.log('eventRecordType>>>>'+JSON.stringify(this.eventRecordType));

        getRecordTypeDevName({
          recordTypeId: this.eventRecordType
        })
        .then(result => {
          this.eventRecordTypeDevName = result;
          if(this.eventRecordTypeDevName === 'Simple_Events'){
            this.isSimpleEvent = true;
          }
          else if (this.eventRecordTypeDevName === 'Complex_Events'){
            this.isSimpleEvent = false;
          }
          console.log('eventRecordTypeDevName>>>>'+JSON.stringify(this.eventRecordTypeDevName));
          console.log('isSimpleEvent>>>>'+JSON.stringify(this.isSimpleEvent));
          if(this.isSimpleEvent){
            this.isSessionRegistrationsAvailable = false;
          }

        })
        .catch(error => {
          console.log('error>>>>'+JSON.stringify(error));
        })

      }
      catch(err) {
        this.customToastNotification('Error', err.message, true);
      }
      this.hideSpinner();
    })
    .catch(error => {
      this.hideSpinner();
      this.customToastNotification('Error', error.body.message, true);
    });
  }

  renderedCallback(){
    if(!this.hasScrolledToTop){
            this.hasScrolledToTop = true;
            this.customScrollToTop();
        }
    
}

customScrollToTop() {
        const ordersummaryScroll = new CustomEvent('scrolltotop', { detail: true });
        this.dispatchEvent(ordersummaryScroll);
      }

  showSpinner() {
    this.spinnerBoolean = true;
  }

  hideSpinner() {
      this.spinnerBoolean = false;
  }

  customToastNotification(toastTitle, toastMessage, isErrorMessage) {
    var messageString = isErrorMessage ? 'Error' : 'Success';
    const showToastEvent = new ShowToastEvent({
        Title: toastTitle,  // Need to Update => Title instead of title
        message: toastMessage,
        variant: messageString
    });
    this.dispatchEvent(showToastEvent);
  }

  handleClickFb(event){
    var decodedURI = decodeURI(SITE_BASE_URL+`/ledevents/s/event-ticket-selection?id=${this.eventRecord.Id}`);
    this.faceBookURL = `https://www.facebook.com/dialog/share?app_id=87741124305&href=${decodedURI}&display=page&redirect_uri=https://www.facebook.com/`;
    window.open(this.faceBookURL);
  }
  handleClickTw(event){
    var decodedURI = decodeURI(SITE_BASE_URL+`/ledevents/s/event-ticket-selection?id=${this.eventRecord.Id}`);
      this.twitterUrl = `https://twitter.com/intent/tweet?url=${decodedURI}`;
      window.open(this.twitterUrl);
  }
  handleClickLn(event){
    var decodedURI = decodeURI(SITE_BASE_URL+`/ledevents/s/event-ticket-selection?id=${this.eventRecord.Id}`);
    this.linkedInURL= `https://www.linkedin.com/sharing/share-offsite/?url=${decodedURI}`;
    window.open(this.linkedInURL);    
  }
}