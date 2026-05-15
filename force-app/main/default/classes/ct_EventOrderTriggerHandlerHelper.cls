/**
 * @description       : Handler class for Platform Event Trigger on Web_Event_Registration__e.
 * @author            : Creation Admin
 * @last modified on  : 12-28-2020
 * @last modified by  : Creation Admin
* @Modification Log   : 
 * Ver   Date         Author           Modification
 * 1.0   16/09/2020   Creation Admin   Initial Version
**/
global without sharing class ct_EventOrderTriggerHandlerHelper {

    global static void triggerWebSiteSubmissionPlatformEvent(List<String> eventDetailsDataList){
        //Create instance of Web Site Submission Event to fire the Platform Event
        Web_Site_Submission_Event__e eventObject 	= new Web_Site_Submission_Event__e();
        eventObject.Web_Site_Submission_Record__c = '{"data": '+JSON.serialize(eventDetailsDataList)+'}';
        eventObject.Source__c                     = ct_EventConstants.WEB_SUBMISSION_SOURCE_EVENT;

        //Publish the event after adding web form details
        Database.SaveResult result = EventBus.publish(eventObject);
        system.debug('result '+JSON.serialize(result));
        if (result.isSuccess()) {
        System.debug('Successfully published event.');
        } else {
        for(Database.Error err : result.getErrors()) {
            System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
        }
        }      
    }

    global static void sendEventManagerRefundAlert(List<Event_Order__c> eventOrderList){

       //List of SingleEmailMessage to be Sent
       List<Messaging.SingleEmailMessage> mailListToSend = new List<Messaging.SingleEmailMessage>();

       Id orgWideEmailId;
        OrgWideEmailAddress[] orgWideAddress = ct_Util.getOrgWideEmail(System.Label.ct_Events_Team_Address); 
        if (orgWideAddress.size() > 0) {
          orgWideEmailId = orgWideAddress.get(0).Id; 
        }

       //Query Email Alert To Send
       EmailTemplate emailTemplate = [SELECT Id, Subject, Description, 
                                              HtmlValue, DeveloperName, Body 
                                              FROM EmailTemplate 
                                              WHERE DeveloperName =: ct_EventConstants.EVENT_MANAGER_REFUND_TEMPLATE
                                              AND IsActive = true];
        for(Event_Order__c thisOrder: eventOrderList){

          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setOrgWideEmailAddressId(orgwideEmailId); 
          mail.setToAddresses(new String[]{thisOrder.Event__r.Event_Manager__r.Email});
          mail.setTargetObjectId(thisOrder.Event__r.Event_Manager__c);
          mail.setTemplateId(emailTemplate.ID);
          mail.setWhatId(thisOrder.Id);
          mail.setSaveAsActivity(false);
          mailListToSend.add(mail);
        }

        try{
          if(!mailListToSend.isEmpty() && !Test.isRunningTest()){
            //Send Single Email Messages to respective recipients 
            Messaging.sendEmail(mailListToSend);         
          }
        }
        catch(Exception e){
          ct_Logger.logMessage(e, 'Event Order : Event Manager Refund Email Alert');
          throw e;
        }
    }

    @future
    global static void updateEventswithEvtOrdCount(Set<Id> eventOrdIds){
        Map<Id,Event__c> mapOfEventToUpdate = new Map<Id,Event__c>();
        AggregateResult[] groupedResultsforRegistered = [SELECT COUNT(Id)cont, Order_Status__c value, Event__c 
                                                         FROM Event_Order__c 
                                                         where Event__c IN :eventOrdIds AND (Order_Status__c = 'Waiting List' OR Order_Status__c = 'Waiting List Invitation' OR Order_Status__c = 'Active')
                                                         GROUP BY Order_Status__c, Event__c];
        try{                                                 
        for(AggregateResult ar:groupedResultsforRegistered){
            Event__c evt = new Event__c();
            Id evtID = (ID)ar.get('Event__c');
            
			Event__c event = mapOfEventToUpdate.get(evtID);
            if(event != null){
                evt = event;
            }else{
                evt.Id = evtID;
            }
            if((STRING)ar.get('value') == 'Waiting List'){
                evt.Waiting_List_Number__c = (INTEGER)ar.get('cont');
            }            
            else if((STRING)ar.get('value') == 'Waiting List Invitation'){
                evt.Waiting_List_Invitations__c = (INTEGER)ar.get('cont');
            }
            
            mapOfEventToUpdate.put(evt.Id, evt);
        }
        if(!mapOfEventToUpdate.values().isEmpty()){
            update mapOfEventToUpdate.values();
        }
        }
        catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Update Number of Event Order for Waiting List and Waiting List Invitation Count');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
    }  
    }