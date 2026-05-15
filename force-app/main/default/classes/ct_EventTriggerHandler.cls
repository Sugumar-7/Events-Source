/**
 * @File Name          : ct_EventTriggerHandler.cls
 * @Description        : Trigger Handler class for Event Trigger
**/
//global class ct_EventTriggerHandler {
   
  //global static final Id EVENT_RECORDTYPE_FACULTY_RECRUITMENT_OUTREACH_EVENTS = CT_Util.getRecordTypeIdByDevName('Event__c', 'Faculty_Recruitment_and_Outreach_Event');

  /**
    * createCampaignFromEvent - Method to create Campaign records for events
    * @param eventNewMap  Event Trigger New Map 
  **/
  // global static void createCampaignFromEvent(Map<Id, Event__c> eventNewMap) {
  //   List<Campaign> campaignListToInsert = new List<Campaign>();
  //   for(Event__c thisEvent : eventNewMap.values()){
  //     if(thisEvent.RecordTypeId == EVENT_RECORDTYPE_FACULTY_RECRUITMENT_OUTREACH_EVENTS){
  //       campaignListToInsert.add(createCampaignObject(thisEvent));
  //     }
  //   }
  //   if(!campaignListToInsert.isEmpty()){
  //     insert campaignListToInsert;
  //   }
  // }

  /**
    * createCampaignObject - Method to create Campaign from an event
    * @param thisEvent  - Event record for which Campaign to be created
  **/
  // global static Campaign createCampaignObject(Event__c thisEvent) {
  //   Campaign thisCampaign               = new Campaign();
  //   thisCampaign.IsActive               = true;
  //   thisCampaign.Name                   = thisEvent.Name;
  //   //Populate RAO Team Email address for sending Notification configured in Custom Label values
  //   thisCampaign.Rao_team_email__c      = 'saravanan@creation.technology';
  //   thisCampaign.Description            = thisEvent.Event_Description__c;
  //   thisCampaign.EndDate                = thisEvent.Event_End_Date__c;
  //   thisCampaign.Event__c               = thisEvent.Id;
  //   thisCampaign.StartDate              = thisEvent.Event_Start_Date__c;
  //   thisCampaign.Year_of_Entry__c       = thisEvent.Year_of_Entry__c;
  //   return thisCampaign;
  // }
//}

/*global without sharing class ct_EventTriggerHandler_TDTM {

	global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
		hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>CT EVENT TDTM TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

		hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
            Set<Id> postEventApprovedIds          = new Set<Id>();
            List<Event__c> lstEvent               = new List<Event__c>();
            Set<Id> setOfEvtGrpIds                = new Set<Id>();
            //Campaign Ids for populating Event look up
            Map<Id, Id> campaignIdToEventIdMap    = new Map<Id, Id>();
            Set<Id> eventIdsForCampaignMemberSync = new Set<Id>();
            // Before Insert Logic
            if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert){
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT BEFORE INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
                for(Event__c evt : (list<Event__c>)newlist){
                    if(evt.GDPR_Statement_Used__c != null){
                        //Method to update GDPR statement text on Event.
                        ct_EventTriggerHelper.updateGDPRStatements(evt);
                    }
                    if(evt.Success_Message__c == null){
                        ct_EventTriggerHelper.updateSuccessMessage(evt);
                    }
                }

            }
            //After Insert Logic
            if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert){
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT AFTER INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
                //Loop to get The required Ids 
                for(Event__c thisEvent : (list<Event__c>)newlist){
                  if(thisEvent.Campaign__c != null){
                    //Collect Campaign Ids for populating Event Look up in Campaign records
                        campaignIdToEventIdMap.put(thisEvent.Campaign__c, thisEvent.Id);
                    }
                }
            }
            // Before Update Logic
            if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate){
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT BEFORE UPDATE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
                Map<Id, Event__c> triggerOldMap = new Map<Id, Event__c>((list<Event__c>)oldlist);
                Map<Id, Event__c> triggerNewMap = new Map<Id, Event__c>((list<Event__c>)newlist);
                System.debug('Calling before update -- Anshul');
                for(Event__c evt : triggerNewMap.values()){
                    System.debug('Anshul - in Loop');
                    if(evt.GDPR_Statement_Used__c != null && evt.GDPR_Statement_Used__c != triggerOldMap.get(evt.Id).GDPR_Statement_Used__c){
                        System.debug('Anshul - in GDPR Used');
                        //Method to update GDPR statement text on Event.
                        ct_EventTriggerHelper.updateGDPRStatements(evt);
                    }
                    if(evt.Success_Message__c == null){
                        ct_EventTriggerHelper.updateSuccessMessage(evt);
                    }
                    ct_EventTriggerHelper.checkEvtProdAvailable(evt, triggerOldMap.get(evt.Id));
                        
                }
            } 
            // After Update Logic
		    if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate){
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT AFTER UPDATE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

                Map<Id, Event__c> triggerOldMap = new Map<Id, Event__c>((list<Event__c>)oldlist);
                Map<Id, Event__c> triggerNewMap = new Map<Id, Event__c>((list<Event__c>)newlist);

                for(Event__c thisEvent : triggerNewMap.values()){
                    if(thisEvent.Request_Move_to_Post_Event__c 
                    && thisEvent.Event_Status__c != triggerOldMap.get(thisEvent.Id).Event_Status__c
                    && thisEvent.Event_Status__c == ct_EventConstants.EVENT_STATUS_POST_EVENT){
                        postEventApprovedIds.add(thisEvent.Id);
                    }
                                    
                    if(thisEvent.Active__c != triggerOldMap.get(thisEvent.Id).Active__c 
                        || thisEvent.Event_Group__c != triggerOldMap.get(thisEvent.Id).Event_Group__c){
                        if(thisEvent.Event_Group__c != null){
                            setOfEvtGrpIds.add(thisEvent.Event_Group__c);
                        }
                        if(thisEvent.Event_Group__c != triggerOldMap.get(thisEvent.Id).Event_Group__c
                            && triggerOldMap.get(thisEvent.Id).Event_Group__c != null){
                            setOfEvtGrpIds.add(triggerOldMap.get(thisEvent.Id).Event_Group__c);
                        }
                    }
                    
                    if(thisEvent.Campaign__c != null
                        && thisEvent.Campaign__c != triggerOldMap.get(thisEvent.Id).Campaign__c){
                        campaignIdToEventIdMap.put(thisEvent.Campaign__c, thisEvent.Id);

                        if(triggerOldMap.get(thisEvent.Id).Campaign__c != null){
                            campaignIdToEventIdMap.put(triggerOldMap.get(thisEvent.Id).Campaign__c, null);
                        }
                    }

                    if(thisEvent.CM_ER_Auto_Sync__c != null
                        && thisEvent.CM_ER_Auto_Sync__c != triggerOldMap.get(thisEvent.Id).CM_ER_Auto_Sync__c
                        && thisEvent.CM_ER_Auto_Sync__c == ct_EventConstants.EVENT_CM_ER_AUTO_SYNC_YES){
                            eventIdsForCampaignMemberSync.add(thisEvent.Id);
                    }
			    }
            
			if(!postEventApprovedIds.isEmpty()){
				dmlWrapper.objectsToUpdate.addAll(ct_EventTriggerHelper.processApprovedPostEvents(postEventApprovedIds));
			}
            if(!setOfEvtGrpIds.isEmpty() && !System.isFuture() && !System.isBatch()){
                //Calculate number of events under the event group
                ct_EventTriggerHelper.updateNumberOfEvtOnEVtGrp(setOfEvtGrpIds);
            }
            if(!eventIdsForCampaignMemberSync.isEmpty()){
                // Logic of Campaign member Event Registration Sync
                ct_EventTriggerHelper.syncEventRegistrationToCampaignMember(eventIdsForCampaignMemberSync);
            }
		}
        // After Delete Logic 
        if (triggerAction == hed.TDTM_Runnable.Action.AfterDelete){
            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT AFTER DELETE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            for(Event__c evt : (list<Event__c>)oldlist){
                if(evt.Event_Group__c != null){
                    setOfEvtGrpIds.add(evt.Event_Group__c);
                }
            }
            if(!setOfEvtGrpIds.isEmpty() && !System.isFuture() && !System.isBatch()){
                //Calculate number of events under the event group
                ct_EventTriggerHelper.updateNumberOfEvtOnEVtGrp(setOfEvtGrpIds);
            }
        }

        if(!campaignIdToEventIdMap.isEmpty()){
            ct_EventTriggerHelper.processEventIdOnCampaign(campaignIdToEventIdMap);
        }
		return dmlWrapper;
	}
} */

global without sharing class ct_EventTriggerHandler{

    global static Set<Id> postEventApprovedIds          = new Set<Id>();
    global static List<Event__c> lstEvent               = new List<Event__c>();
    global static Set<Id> setOfEvtGrpIds                = new Set<Id>();
    //Campaign Ids for populating Event look up
    global static Map<Id, Id> campaignIdToEventIdMap    = new Map<Id, Id>();
    global static Set<Id> eventIdsForCampaignMemberSync = new Set<Id>();
    
    global static void handleBeforeInsert(list<Event__c> newlist){

        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT BEFORE INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        for(Event__c evt : newlist){
            if(evt.GDPR_Statement_Used__c != null){
                //Method to update GDPR statement text on Event.
                ct_EventTriggerHelper.updateGDPRStatements(evt);
            }
            if(evt.Success_Message__c == null){
                ct_EventTriggerHelper.updateSuccessMessage(evt);
            }
        }

    }

    global static void handleAfterInsert(list<Event__c> newlist){
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT AFTER INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        for(Event__c thisEvent : newlist){
            if(thisEvent.Campaign__c != null){
                //Collect Campaign Ids for populating Event Look up in Campaign records
                campaignIdToEventIdMap.put(thisEvent.Campaign__c, thisEvent.Id);
            }
        }
        if(!campaignIdToEventIdMap.isEmpty()){
            //ct_EventTriggerHelper.processEventIdOnCampaign(campaignIdToEventIdMap);
            ProcessingEventIdOnCampaign(campaignIdToEventIdMap);
        }
    }

    global static void handleBeforeUpdate(Map<Id,Event__c> oldMap, Map<Id,Event__c> newMap){

        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT BEFORE UPDATE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        Map<Id, Event__c> triggerOldMap = oldMap;
        Map<Id, Event__c> triggerNewMap = newMap;
        System.debug('Calling before update -- Anshul');
        for(Event__c evt : triggerNewMap.values()){
            System.debug('Anshul - in Loop');
            if(evt.GDPR_Statement_Used__c != null && evt.GDPR_Statement_Used__c != triggerOldMap.get(evt.Id).GDPR_Statement_Used__c){
                System.debug('Anshul - in GDPR Used');
                //Method to update GDPR statement text on Event.
                ct_EventTriggerHelper.updateGDPRStatements(evt);
            }
            if(evt.Success_Message__c == null){
                ct_EventTriggerHelper.updateSuccessMessage(evt);
            }
            ct_EventTriggerHelper.checkEvtProdAvailable(evt, triggerOldMap.get(evt.Id));
                        
        }
    }

    global static void handleAfterUpdate(Map<Id,Event__c> oldMap, Map<Id,Event__c> newMap){

        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT AFTER UPDATE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

        Map<Id, Event__c> triggerOldMap = oldMap;
        Map<Id, Event__c> triggerNewMap = newMap;

        for(Event__c thisEvent : triggerNewMap.values()){
            if(thisEvent.Request_Move_to_Post_Event__c 
                && thisEvent.Event_Status__c != triggerOldMap.get(thisEvent.Id).Event_Status__c
                    && thisEvent.Event_Status__c == ct_EventConstants.EVENT_STATUS_POST_EVENT){
                postEventApprovedIds.add(thisEvent.Id);
            }
                                    
            if(thisEvent.Active__c != triggerOldMap.get(thisEvent.Id).Active__c 
                    || thisEvent.Event_Group__c != triggerOldMap.get(thisEvent.Id).Event_Group__c){
                if(thisEvent.Event_Group__c != null){
                    setOfEvtGrpIds.add(thisEvent.Event_Group__c);
                }
                if(thisEvent.Event_Group__c != triggerOldMap.get(thisEvent.Id).Event_Group__c
                            && triggerOldMap.get(thisEvent.Id).Event_Group__c != null){
                    setOfEvtGrpIds.add(triggerOldMap.get(thisEvent.Id).Event_Group__c);
                }
            }
                    
            if(thisEvent.Campaign__c != null
                        && thisEvent.Campaign__c != triggerOldMap.get(thisEvent.Id).Campaign__c){
                campaignIdToEventIdMap.put(thisEvent.Campaign__c, thisEvent.Id);

                if(triggerOldMap.get(thisEvent.Id).Campaign__c != null){
                    campaignIdToEventIdMap.put(triggerOldMap.get(thisEvent.Id).Campaign__c, null);
                }
            }

            if(thisEvent.CM_ER_Auto_Sync__c != null
                        && thisEvent.CM_ER_Auto_Sync__c != triggerOldMap.get(thisEvent.Id).CM_ER_Auto_Sync__c
                        && thisEvent.CM_ER_Auto_Sync__c == ct_EventConstants.EVENT_CM_ER_AUTO_SYNC_YES){
                eventIdsForCampaignMemberSync.add(thisEvent.Id);
            }
		}
            
	    if(!postEventApprovedIds.isEmpty()){
                        System.debug('postEventApprovedIds'+postEventApprovedIds);

			// dmlWrapper.objectsToUpdate.addAll(
                List<SObject> sObjecttoUpdate = ct_EventTriggerHelper.processApprovedPostEvents(postEventApprovedIds);
                update sObjecttoUpdate;
                // );
		}
        if(!setOfEvtGrpIds.isEmpty() && !System.isFuture() && !System.isBatch()){
            //Calculate number of events under the event group
            ct_EventTriggerHelper.updateNumberOfEvtOnEVtGrp(setOfEvtGrpIds);
        }
        if(!eventIdsForCampaignMemberSync.isEmpty()){
            // Logic of Campaign member Event Registration Sync
            ct_EventTriggerHelper.syncEventRegistrationToCampaignMember(eventIdsForCampaignMemberSync);
        }
        if(!campaignIdToEventIdMap.isEmpty()){
            //ct_EventTriggerHelper.processEventIdOnCampaign(campaignIdToEventIdMap);
            ProcessingEventIdOnCampaign(campaignIdToEventIdMap);
        }
    }

    global static void handleAfterDelete(list<Event__c> oldlist){

        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT AFTER DELETE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        for(Event__c evt : oldlist){
            if(evt.Event_Group__c != null){
                setOfEvtGrpIds.add(evt.Event_Group__c);
            }
        }
        if(!setOfEvtGrpIds.isEmpty() && !System.isFuture() && !System.isBatch()){
            //Calculate number of events under the event group
            ct_EventTriggerHelper.updateNumberOfEvtOnEVtGrp(setOfEvtGrpIds);
        }
    }

    global static void ProcessingEventIdOnCampaign(Map<Id, Id> campaignToEventMap){
        
        if(!campaignToEventMap.isEmpty()){
            ct_EventTriggerHelper.processEventIdOnCampaign(campaignToEventMap);
        }

    }
}