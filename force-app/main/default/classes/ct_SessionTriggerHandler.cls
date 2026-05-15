/**
 * @description       : Trigger Handler for Session Trigger
 * @author            : Creation Admin
**/
global without sharing class ct_SessionTriggerHandler {
	// global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    // hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult){
        
	// 	System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>CT SESSION TDTM TRIGGER HANDLER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

	// 	hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        global static Set<Id> setOfTrackIdsToUpdate = new Set<Id>();
        
        // if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert){

        global static void handleBeforeInsert(List<Session__c> newlist){
            ct_SessionTriggerHandlerHelper.updateSession(newlist);      
        }
        
        // if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert){

        global static void handleAfterInsert(List<Session__c> newlist){
            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>SESSION AFTER INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            for (Session__c thisSession : newlist){
                if(thisSession.Track__c != null){
                    setOfTrackIdsToUpdate.add(thisSession.Track__c);
                }
            }
            updateSessionCountOnTrack(setOfTrackIdsToUpdate);
        }

        // if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate){

        global static void handleBeforeUpdate(List<Session__c> newlist){
            ct_SessionTriggerHandlerHelper.updateSession(newlist);
        }
        
        // if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate){

        global static void handleAfterUpdate(Map<Id, Session__c> triggerOldMap, Map<Id, Session__c> triggerNewMap){
            // System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>SESSION AFTER UPDATE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            // Map<Id, Session__c> triggerOldMap = new Map<Id, Session__c>((list<Session__c>)oldlist);
            // Map<Id, Session__c> triggerNewMap = new Map<Id, Session__c>((list<Session__c>)newlist);

            for (Session__c thisSession : triggerNewMap.values()){
                if(thisSession.Track__c != triggerOldMap.get(thisSession.Id).Track__c){
                    if(thisSession.Track__c != null){
                        setOfTrackIdsToUpdate.add(thisSession.Track__c);
                    }
                    if(triggerOldMap.get(thisSession.Id).Track__c != null){
                        setOfTrackIdsToUpdate.add(triggerOldMap.get(thisSession.Id).Track__c);
                    }
                }
            }
            updateSessionCountOnTrack(setOfTrackIdsToUpdate);
        }

        // if (triggerAction == hed.TDTM_Runnable.Action.BeforeDelete) {

        global static void handleBeforeDelete(List<Session__c> oldlist){
            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>SESSION BEFORE DELETE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            for (Session__c thisSession : (oldlist)){
                if(thisSession.Track__c != null){
                    setOfTrackIdsToUpdate.add(thisSession.Track__c);
                }
            }
            
            updateSessionCountOnTrack(setOfTrackIdsToUpdate);
        }

        global static void updateSessionCountOnTrack(Set<Id> setOfTrackIdsToUpdate){
        if(!setOfTrackIdsToUpdate.isEmpty() && !System.isFuture() && !System.isBatch()){
            ct_SessionTriggerHandlerHelper.updateSessionCountOnTrack(setOfTrackIdsToUpdate);
        }

    }
}