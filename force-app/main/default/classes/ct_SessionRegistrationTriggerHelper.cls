/**
 * @description       : Helper class for Session Registration TDTM trigger Handler
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 12-07-2020
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-07-2020   Creation Admin   Initial Version
**/
global without sharing class ct_SessionRegistrationTriggerHelper {
  
    /**
    * @description Method to get Event registration record
    * @param eventRegistrationIds Event registration record IDS
    * @return Map<Id, Event_Registration__c> 
    **/
    global static Map<Id, Event_Registration__c> getEventRegistrationMap(Set<Id> eventRegistrationIds){
        Map<Id, Event_Registration__c> eventRegistrationMap = new Map<Id, Event_Registration__c>([SELECT Id, 
                                                                                                        Name, 
                                                                                                        QR_Code__c 
                                                                                                    FROM Event_Registration__c 
                                                                                                    WHERE Id =: eventRegistrationIds]);
        return eventRegistrationMap;
    }

    /**
    * @description Method to update the QR code from event registration
    * @param thisSessionRegistration Session registration
    * @param eventRegistration Event registration from which QR need to populated from
    **/
    global static void populateQRCodeFromEventRegistration(Session_Registration__c thisSessionRegistration, Event_Registration__c eventRegistration){
        if(eventRegistration != null){
            thisSessionRegistration.QR_Code__c = eventRegistration.QR_Code__c;
        }
    }
}