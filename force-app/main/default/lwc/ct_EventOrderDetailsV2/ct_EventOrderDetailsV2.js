/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 01-17-2021
 * @last modified by  : Umashankar Creation
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-14-2020   Umashankar Creation   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import formFactorPropertyName from '@salesforce/client/formFactor';
import getSessionAsPicklistValues from "@salesforce/apex/CT_EventSearchController.getSessionAsPicklists";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ct_EventOrderDetailsV2 extends NavigationMixin(LightningElement) {
  
  @api selectedTickets;
  @api orderBy;
  ticketForms;
  dynamicSessionData;
  @track canRenderTicketForm = false;
  @api orderedTickets;
  @api isInternalComponent;
  @api internalRegistrationFormData;
  @api isCheckInManagerComponent;
  @api selectedEvent;
  @track startTimeValue;
  @track endTimeValue;
  @track eventRegId;
  @track campaignRefId;
  @track isWaitingList = false;
  @track isManualRegistration = false;
  @track isPublicURL = false;
  @track hasOnlyAnonymousTicket = true;
  @api isBackfromOrderSummary = false;
  @api availSess;
  @track raiseError = false;
  @api redirectionState;
  numberOfTickets;



  get allowDuplicateEventRegistration(){
    return (this.selectedEvent != undefined && this.selectedEvent != null && this.selectedEvent) ?  this.selectedEvent.Allow_Duplicate_Event_Registrations__c : false;
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


  connectedCallback(){

    /*Get Id from the URL To Load A particular Event*/
    var redirectionVar = JSON.parse(this.redirectionState);
    
    if(this.redirectionState){
      
      this.selectedTickets = JSON.parse(redirectionVar.selectedTickets);
      if(redirectionVar.orderedTickets)
      {
        this.orderedTickets = JSON.parse(redirectionVar.orderedTickets);
      }      
      this.orderBy = JSON.parse(redirectionVar.orderBy);
      this.selectedEvent = JSON.parse(redirectionVar.selectedEvent);
      this.isWaitingList = JSON.parse(redirectionVar.waitInvitaion);
      this.isManualRegistration = JSON.parse(redirectionVar.manualRegistration);
      this.isPublicURL = JSON.parse(redirectionVar.publicURL);
      this.isBackfromOrderSummary = JSON.parse(redirectionVar.isOrderSummaryBack);
    }

    this.getTicketForms();
   
    getSessionAsPicklistValues({eventId: this.orderBy.eventId})
      .then(result =>{
        this.dynamicSessionData = result;
        this.canRenderTicketForm = true;
      }).catch(error => {
            this.customToastNotification('Error', error, true);
      });

    
  }

   getTicketForms() {
    let thisTicketForms = [];
    let totalTickets = 0;
    for (let i = 0; i < this.selectedTickets.length; i++) {
      if(this.hasOnlyAnonymousTicket && !this.selectedTickets[i].anonymousOnly){
        this.hasOnlyAnonymousTicket = false;
      }
     try{
        for (let j = 0; j < parseInt(this.selectedTickets[i].ticketCount); j++) {

            ++totalTickets;
            thisTicketForms.push({
              ticketId                     : this.selectedTickets[i].ticketId,
              name                         : this.selectedTickets[i].Name,
              ticketNumber                 : totalTickets,
              ticketName                   : 'Ticket'+totalTickets,
              allowGuestRegistrations      : this.selectedTickets[i].allowGuestRegistrations,
              allowPrimaryRegistration     : this.selectedTickets[i].allowPrimaryRegistration,
              mandatePrimarySession        : this.selectedTickets[i].mandatePrimarySession,
              anonymousOnly                : this.selectedTickets[i].anonymousOnly,
              primarySessionInterestHeading: this.selectedTickets[i].primarySessionInterestHeading,
              primarySessionInterestLabel  : this.selectedTickets[i].primarySessionInterestLabel,
              eventRegistration            : this.orderedTickets ? this.orderedTickets[totalTickets-1].eventRegistration: null,
              campaignMember               : this.orderedTickets ? this.orderedTickets[totalTickets-1].campaignMember   : null,
              primarySessionIds            : this.orderedTickets ? this.orderedTickets[totalTickets-1].primarySessionIds: null
            });
        }
      }
      catch(error){
        console.log('Error '+error);
      }
    }

    
    this.numberOfTickets = totalTickets;
    this.ticketForms = thisTicketForms;


    if(this.hasOnlyAnonymousTicket){
      if(this.isBackfromOrderSummary){
        this.handlePrevPage();
      }
      else{
      this.handleAnonymousDisplaySummary();
      }
      
    }
  }

  handleDisplaySummary(){
  try {
        let tickets = [];
        let ticketForms = this.template.querySelectorAll("c-ct_ticket-form-v2");
        let validQuestionForms = 0;
        let validAttendee = 0;
        let hasFailedEmailVerification = 0;

        for (let i = 0; i < ticketForms.length; i++) {
            var eachTicketForm = ticketForms[i];
            console.log('eachTicketForm-----' + JSON.stringify(eachTicketForm));
            if(!eachTicketForm.isGuest && !eachTicketForm.validateQuestionComponent()){
              validQuestionForms = validQuestionForms + 1;
            }


            if(!eachTicketForm.isGuest && !eachTicketForm.reportValidation()){
              validAttendee = validAttendee + 1;
            }
            if(!eachTicketForm.hasPassedEmailVerification){
              hasFailedEmailVerification = hasFailedEmailVerification + 1;
            }
            console.log('campaignMember-----' + JSON.stringify(eachTicketForm.campaignMember));



            if(eachTicketForm.campaignMember && typeof eachTicketForm.campaignMember== 'string'){
              eachTicketForm.campaignMember = JSON.parse(eachTicketForm.campaignMember);
            }
            
             tickets.push({
                ticketId                        : eachTicketForm.ticket.ticketId,
                firstName                       : eachTicketForm.firstName,
                lastName                        : eachTicketForm.lastName,
                email                           : eachTicketForm.email,
                mobile                          : eachTicketForm.mobile,
                street                          : eachTicketForm.street,
                city                            : eachTicketForm.city,
                state                           : eachTicketForm.state,
                postcode                        : eachTicketForm.postcode,
                country                         : eachTicketForm.country,
                birthdate                       : eachTicketForm.birthdate,
                addressLine2                    : eachTicketForm.addressLine2,
                isGuest                         : eachTicketForm.isGuest,
                eventRegistration               : eachTicketForm.eventRegistration,
                campaignMember                  : JSON.stringify(eachTicketForm.campaignMember),
                eventRegId                      : this.eventRegId,
                campaignRefId                   : this.campaignRefId,
                primarySessionIds               : eachTicketForm.selectedSessions,
                primaryAreaInterest             : eachTicketForm.primaryAreaInterest,
                attendeeType                    : eachTicketForm.attendeeType,
                hasDuplicateEventRegistration   : eachTicketForm.hasDuplicate,
                duplicateEventRegistrationId    : eachTicketForm.duplicateEventRegistrationId,
                duplicateEventRegistrationStatus: eachTicketForm.duplicateEventRegistrationStatus,
                allowDuplicate                  :this.allowDuplicateEventRegistration,
                ticketNumber                    : eachTicketForm.ticket.ticketNumber
                });
            
        }
        if(this.raiseError){
          const evt = new ShowToastEvent({
            title: 'Error!!',
            message: 'Fix the registration error first before moving to next',
            variant: 'error',
            mode: 'dismissable'
          });
          this.dispatchEvent(evt);
          return false;
        }
     
        if(validQuestionForms == 0 && validAttendee == 0 && hasFailedEmailVerification == 0){
          this.orderedTickets = tickets;
          if(this.isInternalComponent){
            console.log('***');
            var eventParameter ={  
              'tickets' : this.selectedTickets,
              'orderedTickets' : this.orderedTickets,
              'orderedBy' : this.orderBy
             };
      
            const eventOrderNEXTEventCON = new CustomEvent('eventordernextevent', { detail: eventParameter , bubbles: true});
            this.dispatchEvent(eventOrderNEXTEventCON);
          }

          else{

              var redirectionOrderState = {};

              redirectionOrderState['internalRegistrationFormData'] = JSON.stringify(this.internalRegistrationFormData);
              redirectionOrderState['isCheckInManagerComponent'] = this.isCheckInManagerComponent;
              redirectionOrderState['isInternalComponent'] = this.isInternalComponent;
              console.log('Internal component val>>>>'+this.isInternalComponent);
              redirectionOrderState['tickets'] = JSON.stringify(this.selectedTickets);
              redirectionOrderState['orderedTickets'] = JSON.stringify(this.orderedTickets);
              redirectionOrderState['orderedBy'] = JSON.stringify(this.orderBy);
              redirectionOrderState['selectedEvent'] = JSON.stringify(this.selectedEvent);
              redirectionOrderState['eventRegId'] = this.eventRegId;
              redirectionOrderState['manualRegistration'] = this.isManualRegistration;
              redirectionOrderState['publicURL'] = this.isPublicURL;

              this.redirectionOrderState = JSON.stringify(redirectionOrderState);


              const eventToParent = new CustomEvent('eventordersummarydisplay', {
                detail: { eventsearchdisplay: true,
                  selectedEventDisplay : false, 
                  eventOrderDisplay : false,
                  eventSummaryDisplay : true,
                  setRedirectionOrderState : this.redirectionOrderState
                },
                bubbles: true,
                composed: true
                });
                this.dispatchEvent(eventToParent);
          }
        
        }
    } catch (error) {
        console.log('Handle Display Summary Error'+ error.message);
    }
  }

  handleAnonymousDisplaySummary(){
    try {
      let tickets = [];
      let ticketForms = this.ticketForms;
      let validQuestionForms = 0;
      let validAttendee = 0;
      let hasFailedEmailVerification = 0;
      for (let i = 0; i < ticketForms.length; i++) {
          var eachTicketForm = ticketForms[i];
          eachTicketForm.attendeeType = "Unknown Guest";
          eachTicketForm.eventRegistration ={};
          eachTicketForm.campaignMember = {};
        
           tickets.push({
              ticketId                        : eachTicketForm.ticketId,
              firstName                       : null,
              lastName                        : null,
              email                           : null,
              mobile                          : null,
              street                          : null,
              city                            : null,
              state                           : null,
              postcode                        : null,
              country                         : null,
              birthdate                       : null,
              addressLine2                    : null,
              isGuest                         : true,
              eventRegistration               : eachTicketForm.eventRegistration,
              campaignMember                  : JSON.stringify(eachTicketForm.campaignMember),
              eventRegId                      : this.eventRegId,
              campaignRefId                   : this.campaignRefId,
              primarySessionIds               : null,
              primaryAreaInterest             : null,
              attendeeType                    : eachTicketForm.attendeeType,
              hasDuplicateEventRegistration   : false,
              duplicateEventRegistrationId    : null,
              duplicateEventRegistrationStatus: null,
              allowDuplicate                  : this.allowDuplicateEventRegistration,
              ticketNumber                    : eachTicketForm.ticketNumber
              });
      }
     
      if(hasFailedEmailVerification == 0){
        this.orderedTickets = tickets;
        if(this.isInternalComponent){
          
          var eventParameter ={  
            'tickets' : this.selectedTickets,
            'orderedTickets' : this.orderedTickets,
            'orderedBy' : this.orderBy
           };
    
          const eventOrderNEXTEventCON = new CustomEvent('eventordernextevent', { detail: eventParameter , bubbles: true});
          this.dispatchEvent(eventOrderNEXTEventCON);
        }

        else{
        
          this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'order-summary'
            },
            state: {
                'internalRegistrationFormData': JSON.stringify(this.internalRegistrationFormData),
                'isCheckInManagerComponent' : this.isCheckInManagerComponemanualRegistrationnt,
                'isInternalComponent': this.isInternalComponent,
                'tickets' : JSON.stringify(this.selectedTickets),
                'orderedTickets' : JSON.stringify(this.orderedTickets),
                'orderedBy' : JSON.stringify(this.orderBy),
                'eventRegId': this.eventRegId,
                'selectedEvent' : JSON.stringify(this.selectedEvent),
                'manualRegistration': this.isManualRegistration,
                'publicURL': this.isPublicURL
              }
            });
        }
      
        }
    } 
    catch (error) {
        console.log('Handle Display Summary Error'+ error.message);
    }
  }

  handlePrevPage(event){
    if(this.isInternalComponent){
      var eventParameter ={  
        'id' : this.orderBy.eventId,
        'selectedTickets' : JSON.stringify(this.selectedTickets),
        'orderedBy' : JSON.stringify(this.orderBy)
       };

      const eventOrderBackEvent = new CustomEvent('eventorderpreviousevent', { detail: eventParameter , bubbles: true});
      this.dispatchEvent(eventOrderBackEvent);

       
    }
    else{

      var redirectionState = {};
      redirectionState['selectedTickets'] = JSON.stringify(this.selectedTickets);
      redirectionState['orderBy'] = JSON.stringify(this.orderBy);
              

      this.redirectionState = JSON.stringify(redirectionState);

      const eventToParent = new CustomEvent('eventbackticketselectiondisplay', {
        detail: { 
          selectedEventDisplay: true,
          eventOrderDisplay : false,
          setBackRedirectionState : this.redirectionState
          
        },
        bubbles: true,
        composed: true
        });
        this.dispatchEvent(eventToParent);
    }
  }

  handleattendeereset(event){
    this.template.querySelectorAll("c-ct_ticket-form-v2").forEach(element => {
      if(event.detail !== element.ticket.ticketNumber){
        element.resetAttendeeOptions();
      }
    });
  }
  

  handleattendeerevert(event){
    this.template.querySelectorAll("c-ct_ticket-form-v2").forEach(element => {
      if(event.detail !== element.ticket.ticketNumber){
        element.revertAttendeeOptions();
      }
    });
  }

  handleManageSessions(event){
    var allSelectedSessions = [];
    var sessionId = event.detail.sessionId;
    var ticketNumber = event.detail.ticketNumber;
    this.raiseError = false;
    this.template.querySelectorAll("c-ct_ticket-form-v2").forEach(element=>{
     
        var questonForm = element.getPrimarySessionData();
        if(questonForm != null && questonForm != undefined){
          var sessionMapValues = JSON.parse(JSON.stringify(questonForm.dynamicSessionData));
          var sessionOptions = JSON.parse(JSON.stringify(questonForm.primarySessionOptions));
          allSelectedSessions.push(element.selectedSessions);
          this.availSess = sessionMapValues.sessionMap[sessionId].Registrations_Available__c;
          if(ticketNumber != element.ticket.ticketNumber){
          try{
                const countOccurrences = (arr, val) => arr.reduce((a, v) => (v === val ? a + 1 : a), 0);
                for(var j in sessionMapValues.sessionValues){
                  this.raiseError = false;
                  var counOcc = countOccurrences(allSelectedSessions, sessionId);
                  console.log('>>countOccurrences'+counOcc);
                  if((counOcc + 1) > sessionMapValues.sessionMap[sessionId].Registrations_Available__c
                    && sessionMapValues.sessionValues[j].value == sessionId){
                      this.raiseError = true;
                   }
                  if(this.raiseError){
                    const evt = new ShowToastEvent({
                      title: 'Error!!',
                      message: 'Only ' + this.availSess + ' registrations are available for this session',
                      variant: 'error',
                      mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    console.log('>>>sel:'+element.selectedSessions);
                    
                    element.resetSelectedSession();
                    return;
                  }
                  if(counOcc == sessionMapValues.sessionMap[sessionId].Registrations_Available__c
                    && sessionMapValues.sessionValues[j].value == sessionId){
                      console.log('>>IfLoop');
                    var sessionOptionIndex = sessionMapValues.sessionValues.indexOf(sessionMapValues.sessionValues[j]);
                    sessionOptions.splice(sessionOptionIndex, 1); 
                    element.removeExcessiveSessions(sessionOptions);
                  }
                  else{

                    if(sessionOptions.filter( val => JSON.stringify(val) == JSON.stringify(sessionMapValues.sessionValues[j])).length == 0){
                      console.log('>>ElseLooop');
                      sessionOptions.push(sessionMapValues.sessionValues[j]);
                      element.removeExcessiveSessions(sessionOptions);
                    }
                  }
                }
                this.raiseError = false;
          }
        
          catch(err){
            console.log('Error ',err);
          }
        }
      }
    });
    
  }


  //For Checking Duplicate Event Registration Email Check on sibiling
  validateForDuplicateEventRegistrations(event){
      var allEmailAddresses = [];
      var thisTicketNumber = event.detail;
      var emailCounterMap = {};

      this.template.querySelectorAll("c-ct_ticket-form-v2")
      .forEach(element => { 
         var eventRegEmail = element.email;

         if(eventRegEmail){
          eventRegEmail = eventRegEmail.trim();
          
          if(emailCounterMap.hasOwnProperty(eventRegEmail)){
            emailCounterMap[eventRegEmail] = emailCounterMap[eventRegEmail] + 1;
          }
          else{
              emailCounterMap[eventRegEmail] =  1;
          }
         }
        
      });

      this.template.querySelectorAll("c-ct_ticket-form-v2")
      .forEach(element => { 
        var eventRegEmail = element.email;

        if(eventRegEmail){
          eventRegEmail = eventRegEmail.trim();
          if(eventRegEmail && emailCounterMap.hasOwnProperty(eventRegEmail) && emailCounterMap[eventRegEmail] > 1){
            element.setSibilingEventRegEmailError();
          }
          else{
            element.resetSibilingEventRegEmailError();
           
            if(thisTicketNumber == element.ticket.ticketNumber){
               element.invokeServerSideEventRegistrationValidation();
            }
           
          }
        }
        
      });

  }
}