/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : Javid Sherif
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   01-16-2021   Umashankar Creation   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import QRCodeLib from './qrcode.min.js';
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CHECK_IN_MANAGER_URL from '@salesforce/label/c.Site_Base_URL';

// *** Need to Update ***/
// We cannot extend QRCodeLib in NavigationMixin, QRCodeLib is already imported. So, QRCodeLib need to be removed in NavigationMixin.
// NavigationMixin(LightningElement) instead of NavigationMixin(LightningElement, QRCodeLib)
export default class Ct_EventBookingConfirmedTicketTileV2 extends NavigationMixin(LightningElement, QRCodeLib) {
  spinnerBoolean                = true;
  _libLoaded                    = false;
  @api eventRegistrationRecord;
  @track qrCodeStyle;
  @track contentStyle;
  @track mobileView = false;

  // get borderStyle(){
  //   return 'border: 1px solid black !important;';
  // }  

  @api isSimpleEvent;

  get productName(){
    return this.eventRegistrationRecord.Event_Product__r.Name;
  }  

  get attendeeName(){
    return this.eventRegistrationRecord.Registration_Type__c == 'Unknown Guest' ? 'Guest' : this.eventRegistrationRecord.Name__c;
  }  

  get productNameStyle(){
    return 'font-weight: bold;color: #505457;font-size:15px !important;'
  }

  get productDescription(){
    return this.eventRegistrationRecord.Event_Product__r.Event_Product_Description__c;
  }
  
  get qrCodeImageSrc(){
    return this.eventRegistrationRecord.QR_Code__c.replace("img", "img style=\"height:200px!important\"");
  }

  get eventRegistrationNumber(){
    return this.eventRegistrationRecord.Name;
  }

  get isSessionRegEnabled(){
    return this.eventRegistrationRecord.Event_Product__r.Enable_Session_Registrations__c && this.eventRegistrationRecord.Registration_Type__c != 'Unknown Guest' && !this.isSimpleEvent;
  }
    
  constructor() {
    super();
        
  }
  
  connectedCallback() {

    this._libLoaded = true;
    this.hideSpinner();
    this.getQRCodeStyle();
    window.addEventListener('resize', this.getQRCodeStyle);
  }

  renderedCallback(){
    this.generateQRCode();
  }
  
  getQRCodeStyle = () => {
    if (window.outerWidth>768) {
      this.qrCodeStyle='slds-grid slds-size_2-of-6 slds-grid_align-end qrCodeAlign';
      this.contentStyle ='slds-col slds-size_4-of-6 aroundPadding';
      this.mobileView = false;
    }  
    else {
      this.qrCodeStyle='slds-col slds-size_6-of-6 qrCodeAlign';
      this.contentStyle ='slds-col slds-size_6-of-6 aroundPadding';
      this.mobileView = true;
    }
  };

  generateQRCode(){
    if (this._libLoaded) {
      const canvas = this.template.querySelector('[data-id="QRCode"]');
      //var sData = CHECK_IN_MANAGER_URL + '/' + `UoPQRScanner/s/scanqrcode?eventid=${this.eventRegistrationRecord.Event__c}&eventregid=${this.eventRegistrationRecord.Id}`;
      //var sData = CHECK_IN_MANAGER_URL + '/' + `/lightning/cmp/c__ct_CheckInManagerQRCodeScanner?c__eventid=${this.eventRegistrationRecord.Event__c}&c__eventregid=${this.eventRegistrationRecord.Id}`;
      //var sData = 'https://creationevents-dev-ed.develop.lightning.force.com/lightning/n/Check_In_QR_Code_Scanner';
      
      //var sData = CHECK_IN_MANAGER_URL + '/' + `/lightning/n/Check_In_QR_Code_Scanner?c__eventid=${this.eventRegistrationRecord.Event__c}&c__eventregid=${this.eventRegistrationRecord.Id}`;
     // var sData = CHECK_IN_MANAGER_URL +'/lightning/n/Check_In_QR_Code_Scanner' +`?c__eventid=${this.eventRegistrationRecord.Event__c}` +`&c__eventregid=${this.eventRegistrationRecord.Id}`;
      var sData = CHECK_IN_MANAGER_URL +'/lightning/n/Check_In_QR_Code_Scanner' +`?c__eventregid=${this.eventRegistrationRecord.Id}`;
      // let baseUrl = window.location.origin;

      // // Convert Experience Cloud domain → Lightning domain
      // if (baseUrl.includes('.my.site.com')) {
      //     baseUrl = baseUrl.replace('.my.site.com', '.lightning.force.com');
      // }

      // // Build final URL
      // const sData =
      //     `${baseUrl}/lightning/n/Check_In_QR_Code_Scanner` +
      //     `?c__eventregid=${this.eventRegistrationRecord.Id}`;

      console.log('Check IN Manager ---> '+CHECK_IN_MANAGER_URL);
      console.log('sData-------------->'+sData);
      QRCode.toCanvas(canvas, sData)
      .then(() => {
          // eslint-disable-next-line no-console
      })
      .catch(err => {
          this.customToastNotification('Error', JSON.stringify(err), true);
      });
      
    }
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
        Title: toastTitle, // Need to Update => Title instead of title
        message: toastMessage,
        variant: messageString
    });
    this.dispatchEvent(showToastEvent);
  }

  navigateToTicketManagement(){

    const eventToParent = new CustomEvent('eventticketmanagementdisplay', {
      detail: { eventsearchdisplay: true,
        selectedEventDisplay : false, 
        eventOrderDisplay : false,
        eventSummaryDisplay : false,
        eventOrderConfirmation : false,
        eventTicketmanagement : true,
        eventRegisteredRecordId : this.eventRegistrationRecord.Id,
        isSimpleEvent : this.isSimpleEvent
      },
      bubbles: true,
      composed: true
      });
      this.dispatchEvent(eventToParent);
    
    }

    navigateToSessionRegistration(){

      const eventToParent = new CustomEvent('eventsessionmanagementdisplay', {
        detail: { eventsearchdisplay: true,
          selectedEventDisplay : false, 
          eventOrderDisplay : false,
          eventSummaryDisplay : false,
          eventOrderConfirmation : false,
          eventTicketmanagement : false,
          eventSessionManagement : true,
          eventRegisteredRecordId : this.eventRegistrationRecord.Id,
          sessionReg : true
        },
        bubbles: true,
        composed: true
        });
        this.dispatchEvent(eventToParent);
      }
}