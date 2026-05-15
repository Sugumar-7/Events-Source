/**
* @File Name          : ct_WaitingListController.cls
* @Description        : Test class for CT_AddToCalendarController
* @Author             : Creation Admin
* @Last Modified By   : Creation Admin
* @Last Modified On   : 10/12/2020, 12:40:58 PM
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   09-18-2020   Creation Admin   Initial Version
**/
global without sharing class ct_WaitingListController {
    /*
	* Description: Method to store the Event Order with the status as Waiting List when user submit it from Waiting List form
	* */
    @AuraEnabled
    global static Event_Order__c saveWaitingListEvtOrd(String evtOrderAsJson){
        String response;
        EventOrder evtOrder = (EventOrder) Json.deserialize(evtOrderAsJson, EventOrder.class);
        Event_Order__c eventOrd = new Event_Order__c();
        eventOrd.Event__c                = evtOrder.eventId;
        eventOrd.First_Name__c           = evtOrder.firstName;
        eventOrd.Last_Name__c            = evtOrder.lastName;
        eventOrd.Email__c                = evtOrder.email;
        eventOrd.Receive_SMS_notification__c = evtOrder.receiveSMSnotification != null ? Boolean.valueOf(evtOrder.receiveSMSnotification) : false;
        eventOrd.Mobile__c                   = evtOrder.mobile;
        eventOrd.Total_number_of_ticket_requested__c         = Integer.valueOf(evtOrder.numberOfTicketsRequested);
        eventOrd.Order_Status__c                             = 'Waiting List';
        eventOrd.Order_Source__c                             = ct_EventConstants.ORDER_SOURCE_WEB_ORDER;
        eventOrd.Consent_Given__c                    = evtOrder.consentGiven;
        try{
            insert eventOrd;
        }
        catch(Exception e){
            ct_Logger.logMessage(e, 'Event Order');
            throw e;
        }
        return eventOrd;
        
    }
	 /*
		* Description: Method to fetch the Consent Capture information to show it in the waiting list form
	* */
    @AuraEnabled
    global static Event__c getEventGDPRdetails(String eventId){
        return  [Select Id, GDPR_Statement_Used__c, Statement_Text_above_dec__c, Statement_Text_below_dec__c, Statement_Title__c, Declaration_Text__c,Consent_Required_to_Register__c 
        FROM Event__c WHERE Id =: eventId];
       
    }
    
    global class EventOrder{
        global String firstName;
        global String lastName;
        global String email;
        global String eventId;
        global String receiveSMSnotification;
        global String mobile;
        global String numberOfTicketsRequested;
        global String consentGiven;
        
    }
}