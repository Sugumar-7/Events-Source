/**
 * @description       : 
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 02-04-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-18-2020   Creation Admin   Initial Version
 * Controller class Ticket Management Form
**/
global without sharing class ct_TicketManagementController {
    
  /**
  * @description - Used to return the Event reg records  
  * @param String eventRegistrationId - Event Registration Record Id
  * @return TicketWrapper - return the TicketWrapper class
  **/
  @AuraEnabled
  global static TicketWrapper getEventRegistration(String eventRegistrationId){
    // Query the Event Registration Record based on Id
    return new TicketWrapper([SELECT Id, Name, Event__c, QR_Code__c, Event__r.Web_Event_Name__c,Event__r.Allow_Duplicate_Event_Registrations__c, Event__r.Event_Start_Date__c, Event__r.Event_End_Date__c, Event_Registration_Status__c, Event_Order__r.Name, Event_Mobile__c, 
                    Event_Product__r.Name,Event_Product__r.Allow_Primary_Session__c,Event_Product__r.Is_Mandatory__c, Registration_Type__c, First_Name__c, Last_Name__c, Event_Email__c, Event_Product__r.Enable_Session_Registrations__c,
                    Cancellation_Reason__c, Cancellation_Description__c
                    FROM Event_Registration__c WHERE Id =: eventRegistrationId LIMIT 1]);
  }

  /**
  * @description - Method to update the Event Registration record
\  * @param String jsonData - Ticket Management Data
  * @param String campaignData - Campaign member data
  * @param Boolean isCancelling - indicate the order is cancelled or not
  * @return String - return success message 
  **/
  @AuraEnabled
  global static String updateEventRegistration(String jsonData, String campaignData, Boolean isCancelling){
    try {

    Event_Registration__c thisEventRegistration = new Event_Registration__c();
    TicketWrapper thisTicketWrapper = (TicketWrapper)JSON.deserialize(jsonData,TicketWrapper.class);
    thisEventRegistration = thisTicketWrapper.eventRegistration;
    System.debug('thisEventRegistration>>>>'+thisEventRegistration);
    if(String.isNotBlank(thisEventRegistration.Registration_Type__c) && thisEventRegistration.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_UNKNOWN_GUEST){
      thisEventRegistration.Registration_Type__c = ct_EventConstants.EVENT_REGISTRATION_TYPE_SOMEONE_ELSE;
    }
    if(isCancelling){
      thisEventRegistration.Event_Registration_Status__c = 'Cancelled';
      System.debug('thisEventRegistration.Event_Registration_Status__c>>>>'+thisEventRegistration.Event_Registration_Status__c);
  
    }
    if(campaignData != null){
      Web_Site_Submission__c thisSubmission = getWebSiteSubmission(campaignData, thisEventRegistration);
      upsert thisSubmission; 
    }
    
      update thisEventRegistration;
      System.debug('thisEventRegistration>>>>'+thisEventRegistration);
    } catch (Exception ex) {
      ct_Logger.logMessage(ex, 'Event Registration');
      throw new AuraHandledException('Error '+ ex.getMessage() + ex.getLineNUmber());
    }
    
    return 'success';
  }

  /**
  * @description - method to get the exisiting Web site submission record
  * @param String campaignData - Campaign member data
  * @param Event_Registration__c thisRegistration - event registration record
  * @return Web_Site_Submission__c 
  **/
  global static Web_Site_Submission__c getWebSiteSubmission(String campaignData, Event_Registration__c thisRegistration){
    List<Web_Site_Submission__c> thisSubmission = new List<Web_Site_Submission__c>();
    thisSubmission = [SELECT Id, Name, Source__c, Email__c, Payload__c FROM Web_Site_Submission__c WHERE Name =: thisRegistration.Id LIMIT 1];
    if(!thisSubmission.isEmpty()){
      thisSubmission[0].Payload__c = campaignData;
    }
    else{
      Web_Site_Submission__c thisnewSubmission = new Web_Site_Submission__c();
      thisnewSubmission.Name                   = String.valueOf(Id.valueOf(thisRegistration.Id)).substring(0, 15);
      thisnewSubmission.Source__c				      = ct_EventConstants.WEB_SUBMISSION_SOURCE_EVENT;
      thisnewSubmission.Email__c               = thisRegistration.Event_Email__c;
      thisnewSubmission.Payload__c             = campaignData;
      thisSubmission.add(thisnewSubmission);
    }
    return thisSubmission[0];
  }
  // Wrapper class for sending event registration records
  global class TicketWrapper{
    @AuraEnabled 
    global Event_Registration__c eventRegistration { get;set; }
    //global List<String> primarySessionIds;
    global TicketWrapper(Event_Registration__c thisEventReg){
      this.eventRegistration = thisEventReg;
      //this.primarySessionIds = new List<String>();
    }
  }
}