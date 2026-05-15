/**
 * @description       : Trigger Handler for Session Registration
 * @author            : Creation Admin
**/
global without sharing class ct_SessionRegistrationHandler /*extends hed.TDTM_Runnable*/{
	// global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    // hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        
		// System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>CT SESSION REGISTRATION TDTM TRIGGER HANDLER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

		// hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        
        // if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert)
        global static void handleBeforeInsert(List<Session_Registration__c>newlist){

            Set<Id> eventRegistrationIds = new Set<Id>();
            Map<Id, Event_Registration__c> eventRegistrationMap = new Map<Id, Event_Registration__c>();

            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>SESSION REGISTRATION BEFORE INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            for (Session_Registration__c thisSessionRegistration : (list<Session_Registration__c>)newlist){
                if(thisSessionRegistration.Event_Registration__c != null){
                    eventRegistrationIds.add(thisSessionRegistration.Event_Registration__c);
                }
            }

            if(!eventRegistrationIds.isEmpty()){
                eventRegistrationMap = ct_SessionRegistrationTriggerHelper.getEventRegistrationMap(eventRegistrationIds);
            }

            for (Session_Registration__c thisSessionRegistration : (list<Session_Registration__c>)newlist){
                if(thisSessionRegistration.Event_Registration__c != null
                    && thisSessionRegistration.QR_Code__c == null
                    && !eventRegistrationMap.isEmpty()
                    && eventRegistrationMap.containsKey(thisSessionRegistration.Event_Registration__c)){
                    ct_SessionRegistrationTriggerHelper.populateQRCodeFromEventRegistration(thisSessionRegistration, eventRegistrationMap.get(thisSessionRegistration.Event_Registration__c));
                }
            }
        }
        // return dmlWrapper;                                            
    // }
}