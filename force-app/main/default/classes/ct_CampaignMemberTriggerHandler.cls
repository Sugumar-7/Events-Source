/**
 * @description       : Create an Event Registrations once campaign member added into the If the campaign synced with the event
 * @author            : Creation Admin
**/
global without sharing class ct_CampaignMemberTriggerHandler /*extends hed.TDTM_Runnable*/ {

    /*******************************************************************************************************
    * @description Turns class off.
    * @return void
    ********************************************************************************************************/
    global static void turnOff() {
        ct_ProcessControl.turnOffRecursionFlag(ct_ProcessControl.registeredTrigger.ct_CampaignMemberTriggerHandler_After_Insert);
        ct_ProcessControl.turnOffRecursionFlag(ct_ProcessControl.registeredTrigger.ct_CampaignMemberTriggerHandler_After_Update);
    }
    
    /*******************************************************************************************************
    * @description Turns class on.
    * @return void
    ********************************************************************************************************/
    global static void turnOn() {
        ct_ProcessControl.resetRecursionFlag(ct_ProcessControl.registeredTrigger.ct_CampaignMemberTriggerHandler_After_Insert);
        ct_ProcessControl.resetRecursionFlag(ct_ProcessControl.registeredTrigger.ct_CampaignMemberTriggerHandler_After_Update);
    }
    

    // global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    // hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

    // System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>CT CAMPAIGN MEMBER TDTM TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

    // hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
    
    //Set of Campaign Id for creating Event Registration

    global static void HandleAfterInsert(list<CampaignMember> newlist){
      System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>CAMPAIGN MEMBER AFTER INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      Set<Id> campaignIds                         = new Set<Id>();
      Set<Id> campaignMemberIds                   = new Set<Id>();
      Map<Id, Set<Id>> leadIdToCampaignIdMap      = new Map<Id, Set<Id>>();
      Map<Id, Set<Id>> contactToCampaignIdMap     = new Map<Id, Set<Id>>();
      Map<Id, Set<Id>> accountToCampaignIdMap     = new Map<Id, Set<Id>>();

      //Loop to get The required Ids 
      for(CampaignMember thisCampaignMember : (list<CampaignMember>)newlist){
        campaignIds.add(thisCampaignMember.CampaignId);
        campaignMemberIds.add(thisCampaignMember.Id);

        if(thisCampaignMember.LeadId != null){
          if(leadIdToCampaignIdMap.isEmpty() 
            || !leadIdToCampaignIdMap.containsKey(thisCampaignMember.LeadId)){
              leadIdToCampaignIdMap.put(thisCampaignMember.LeadId, new Set<Id>());
          }
          leadIdToCampaignIdMap.get(thisCampaignMember.LeadId).add(thisCampaignMember.CampaignId);
        }

        /*if(thisCampaignMember.ContactId != null){
          if(contactToCampaignIdMap.isEmpty() 
            || !contactToCampaignIdMap.containsKey(thisCampaignMember.ContactId)){
              contactToCampaignIdMap.put(thisCampaignMember.ContactId, new Set<Id>());
          }
          contactToCampaignIdMap.get(thisCampaignMember.ContactId).add(thisCampaignMember.CampaignId);
        }*/

        if(thisCampaignMember.Account__c != null){
          if(accountToCampaignIdMap.isEmpty() 
            || !accountToCampaignIdMap.containsKey(thisCampaignMember.Account__c)){
              accountToCampaignIdMap.put(thisCampaignMember.Account__c, new Set<Id>());
          }
          accountToCampaignIdMap.get(thisCampaignMember.Account__c).add(thisCampaignMember.CampaignId);
        }
          
      }
      //Set the recursion flag for ct_CampaignMemberTriggerHandler_TDTM Trigger handler After Insert using ct_ProcessControl which
      //is based in TDTM_ProcessControl frame work of EDA package
      ct_ProcessControl.setRecursionFlag(ct_ProcessControl.registeredTrigger.ct_CampaignMemberTriggerHandler_After_Insert, true);

      if(!campaignIds.isEmpty() && !System.isBatch() && !System.isFuture() && !System.isQueueable()){
        ct_Campaign_MemberTriggerHelper.createEventRegistration(campaignIds, campaignMemberIds, leadIdToCampaignIdMap, contactToCampaignIdMap, accountToCampaignIdMap);
        ct_Campaign_MemberTriggerHelper.campaignMemberRollupCalculation(campaignIds);
      }
    }
    
    global static void HandleAfterUpdate(list<CampaignMember> newlist, list<CampaignMember> oldlist){
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>CAMPAIGN MEMBER AFTER UPDATE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    Map<Id, CampaignMember> triggerOldMap = new Map<Id, CampaignMember>((list<CampaignMember>)oldlist);
    Map<Id, CampaignMember> triggerNewMap = new Map<Id, CampaignMember>((list<CampaignMember>)newlist);
    Set<Id> campaignIds                  = new Set<Id>();
    Set<Id> eventRegistrationIdsToSync   = new Set<Id>();       
    List<CampaignMember> campaignMembersToSync   = new List<CampaignMember>();

    
        //Loop to get The required Ids 
        for(CampaignMember thisCampaignMember : (list<CampaignMember>)newlist){
           campaignIds.add(thisCampaignMember.CampaignId);
            
          if(thisCampaignMember.Event_Registration__c != null 
            && (thisCampaignMember.Status != triggerOldMap.get(thisCampaignMember.Id).Status
            || thisCampaignMember.Primary_Subject_Area_Interest__c != triggerOldMap.get(thisCampaignMember.Id).Primary_Subject_Area_Interest__c)){
              eventRegistrationIdsToSync.add(thisCampaignMember.Event_Registration__c);
              campaignMembersToSync.add(thisCampaignMember);
          }
        }
		 //Set the recursion flag for ct_CampaignMemberTriggerHandler_TDTM Trigger handler After Insert using ct_ProcessControl which
      	//is based in TDTM_ProcessControl frame work of EDA package
        ct_ProcessControl.setRecursionFlag(ct_ProcessControl.registeredTrigger.ct_CampaignMemberTriggerHandler_After_Update, true);

        if(!eventRegistrationIdsToSync.isEmpty()){
          ct_Campaign_MemberTriggerHelper.syncEventRegistrationWithCampaignMember(campaignMembersToSync, eventRegistrationIdsToSync);
        }
         if(!campaignIds.isEmpty() && !System.isFuture() && !System.isBatch()){
              ct_Campaign_MemberTriggerHelper.campaignMemberRollupCalculation(campaignIds);  
            } 
      }
      
  global static void HandleAfterDelete(list<CampaignMember> oldlist){{
        Set<Id> campaignIds                         = new Set<Id>();
        Set<Id> eventRegistrationIdsToCancel        = new Set<Id>();
        
    List<CampaignMember> campaignMembersToSync          = new List<CampaignMember>();
            for(CampaignMember thisCampaignMember : (list<CampaignMember>)oldlist){
                campaignIds.add(thisCampaignMember.CampaignId);  
                if(thisCampaignMember.Event_Registration__c != null){
                  eventRegistrationIdsToCancel.add(thisCampaignMember.Event_Registration__c);
                }
            } 
            if(!campaignIds.isEmpty() && !System.isFuture() && !System.isBatch()){
              ct_Campaign_MemberTriggerHelper.campaignMemberRollupCalculation(campaignIds);  
            }
            if(!eventRegistrationIdsToCancel.isEmpty() && !System.isFuture() && !System.isBatch()){
              ct_Campaign_MemberTriggerHelper.cancelEventRegistration(eventRegistrationIdsToCancel);  
            }
        }  
  //   return dmlWrapper;
  // }
}
}