/**
 * @description       : Helper class for Campaign Member TDTM Trigger Handler. Using this class to process the
 *                       Event Registrations if new campaign member is added to the campaign
 * @author            : Creation Admin
 * @last modified on  : 01-19-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-10-2020   Creation Admin   Initial Version
**/
global without sharing class ct_Campaign_MemberTriggerHelper {


    /**
    * @description Method to create event registration if new campaign member is added to campaign
    * @param campaignIds : Set of campaign Ids where campaign members were added
    * @param campaignMemberIds : Set of new campaign member Ids added to the campaign
    * @param leadIdToCampaignIdMap : Map of lead Id added to campaign
    * @param contactToCampaignIdMap : Map contact Id added to campaign
    * @param accountToCampaignIdMap : Map account Id added to campaign
    * @return void                                                                                                                                                                                                          
    **/
    global static void createEventRegistration(Set<Id> campaignIds, Set<Id> campaignMemberIds, Map<Id, Set<Id>> leadIdToCampaignIdMap, Map<Id, Set<Id>> contactToCampaignIdMap, Map<Id,Set<Id>> accountToCampaignIdMap){
        try{
            Boolean hasExistingEventRegistration = false;
            Map<Id, List<CampaignMember>> campaignToCampaignMemberMap = new Map<Id, List<CampaignMember>>();
            //Campaign Member Id To Event Registration
            Map<Id, Event_Registration__c> eventRegistrationToUpsert = new Map<Id, Event_Registration__c>();
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            //Get all campaign members of the Campaigns 
            campaignMemberList = [SELECT 
                                                                Id,
                                                                FirstName,
                                                                LastName,
                                                                Email,
                                                                LeadId,
                                                                ContactId,
                                                                Account__c,
                                                                CampaignId,
                                                                Phone,
                                                                MobilePhone,
                                                                Status,
                                                                Primary_Subject_Area_Interest__c
                                                        FROM CampaignMember
                                                        WHERE ID IN:campaignMemberIds];

            for(CampaignMember thisCampaignMember: campaignMemberList){
                if(campaignToCampaignMemberMap.isEmpty() 
                || !campaignToCampaignMemberMap.containsKey(thisCampaignMember.CampaignId)){
                    campaignToCampaignMemberMap.put(thisCampaignMember.CampaignId, new List<CampaignMember>());
                }
                campaignToCampaignMemberMap.get(thisCampaignMember.CampaignId).add(thisCampaignMember);
            }
            //Map of Lead Id and campaign Id to Existing Event Registrations (Lead Id +'_'+Campaign Id+'_' => Event Registration)
            Map<String, Event_Registration__c> leadIdToCampaignIdEventRegistrationMap = new Map<String, Event_Registration__c>();
            //Map of Contact Id and campaign Id to Existing Event Registrations (Contact Id +'_'+Campaign Id+'_' => Event Registration)
            Map<String, Event_Registration__c> contactToCampaignIdEventRegistrationMap = new Map<String, Event_Registration__c>();
            //Map of Account Id and campaign Id to Existing Event Registrations (Account Id +'_'+Campaign Id+'_' => Event Registration)
            Map<String, Event_Registration__c> accountToCampaignIdEventRegistrationMap = new Map<String, Event_Registration__c>();

            /*Use leadIdToCampaignIdEventRegistrationMap, contactToCampaignIdEventRegistrationMap, accountToCampaignIdEventRegistrationMap to validate whether
                lead or contact or account added as campaign member in campaign also added as event registration in respective event record
                based on Campaign configuration in Event
            */
            for(Event_Registration__c thisExistingEventRegistration : [SELECT Id,
                                                                                                                                    First_Name__c, 
                                                                                                                                    Last_Name__c,
                                                                                                                                    Event__c, 
                                                                                                                                    Event__r.Campaign__c, 
                                                                                                                                    Event__r.CM_ER_Auto_Sync__c,  
                                                                                                                                    Event__r.Event_Reg_New_Status__c,
                                                                                                                                    Event__r.Event_Reg_Invited_Status__c,
                                                                                                                                    Event__r.Event_Reg_Registered_Status__c,
                                                                                                                                    Event__r.Event_Reg_Did_Not_Attend_Status__c,
                                                                                                                                    Event__r.Event_Reg_Declined_Status__c,
                                                                                                                                    Event__r.Event_Reg_Checked_Out_Status__c,
                                                                                                                                    Event__r.Event_Reg_Checked_In_Status__c,
                                                                                                                                    Event__r.Event_Reg_Cancelled_Status__c,
                                                                                                                                    Event_Email__c, 
                                                                                                                                    Contact__c,
                                                                                                                                    Enquirer__c,
                                                                                                                                    Account_Name__c,
                                                                                                                                    Object_for_New_Attendees__c, 
                                                                                                                                    Record_Type_for_New_Attendees__c,
                                                                                                                                    Event_Registration_Status__c,
                                                                                                                                    Primary_Subject_Area_Interest__c
                                                                                                                                FROM Event_Registration__c 
                                                                                                                                WHERE Event__r.Campaign__c IN:campaignIds
                                                                                                                                AND Event__r.CM_ER_Auto_Sync__c =:ct_EventConstants.EVENT_CM_ER_AUTO_SYNC_YES]) {

                if(thisExistingEventRegistration.Enquirer__c != null){
                    leadIdToCampaignIdEventRegistrationMap.put(Id.valueOf(thisExistingEventRegistration.Enquirer__c)+'_'+Id.valueOf(thisExistingEventRegistration.Event__r.Campaign__c), thisExistingEventRegistration);
                }
                /*if(thisExistingEventRegistration.Contact__c != null){
                    contactToCampaignIdEventRegistrationMap.put(Id.valueOf(thisExistingEventRegistration.Contact__c)+'_'+Id.valueOf(thisExistingEventRegistration.Event__r.Campaign__c), thisExistingEventRegistration);
                }*/
                if(thisExistingEventRegistration.Account_Name__c != null){
                    accountToCampaignIdEventRegistrationMap.put(Id.valueOf(thisExistingEventRegistration.Account_Name__c)+'_'+Id.valueOf(thisExistingEventRegistration.Event__r.Campaign__c), thisExistingEventRegistration);
                }
            }

            for(Event__c thisEvent : [SELECT
                                                                    Id,
                                                                    Campaign__c, 
                                                                    CM_ER_Auto_Sync__c,  
                                                                    Event_Reg_New_Status__c,
                                                                    Event_Reg_Invited_Status__c,
                                                                    Event_Reg_Registered_Status__c,
                                                                    Event_Reg_Did_Not_Attend_Status__c,
                                                                    Event_Reg_Declined_Status__c,
                                                                    Event_Reg_Checked_Out_Status__c,
                                                                    Event_Reg_Checked_In_Status__c,
                                                                    Event_Reg_Cancelled_Status__c
                                                                FROM Event__c
                                                                WHERE Campaign__c IN: campaignIds
                                                                AND CM_ER_Auto_Sync__c =:ct_EventConstants.EVENT_CM_ER_AUTO_SYNC_YES]){
            
            if(!campaignToCampaignMemberMap.isEmpty()
                && campaignToCampaignMemberMap.containsKey(thisEvent.Campaign__c)){
                    for(CampaignMember thisCampaignMember : campaignToCampaignMemberMap.get(thisEvent.Campaign__c)){
                        //Validate whether the Lead has been already added as event registration in respective Event
                        if(thisCampaignMember.LeadId != null
                            && !leadIdToCampaignIdEventRegistrationMap.isEmpty()
                            && leadIdToCampaignIdEventRegistrationMap.containsKey(Id.valueOf(thisCampaignMember.LeadId)+'_'+Id.valueOf(thisCampaignMember.CampaignId))
                            && leadIdToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.LeadId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)).Event__c == thisEvent.Id){
                                hasExistingEventRegistration = true;
                                //Sync the Event Registration status from Campaign member based on Campaign Member / Event Registration Sync configuration in respective event
                                processEventRegistrationStatusFromCampaignMember(leadIdToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.LeadId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)).Event__r, leadIdToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.LeadId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)), thisCampaignMember);
                                eventRegistrationToUpsert.put(thisCampaignMember.Id, leadIdToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.LeadId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)));
                        }

                        //Validate whether the Contact has been already added as event registration in respective Event
                        /*else if(thisCampaignMember.ContactId != null
                            && !contactToCampaignIdEventRegistrationMap.isEmpty()
                            && contactToCampaignIdEventRegistrationMap.containsKey(Id.valueOf(thisCampaignMember.ContactId)+'_'+Id.valueOf(thisCampaignMember.CampaignId))
                            && contactToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.ContactId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)).Event__c == thisEvent.Id){
                                hasExistingEventRegistration = true;
                                //Sync the Event Registration status from Campaign member based on Campaign Member / Event Registration Sync configuration in respective event
                                processEventRegistrationStatusFromCampaignMember(contactToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.ContactId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)).Event__r, contactToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.ContactId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)), thisCampaignMember);
                                eventRegistrationToUpsert.put(thisCampaignMember.Id, contactToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.ContactId)+'_'+Id.valueOf(thisCampaignMember.CampaignId)));
                        }*/

                        //Validate whether the Account has been already added as event registration in respective Event
                        else if(thisCampaignMember.Account__c != null
                            && !accountToCampaignIdEventRegistrationMap.isEmpty()
                            && accountToCampaignIdEventRegistrationMap.containsKey(Id.valueOf(thisCampaignMember.Account__c)+'_'+Id.valueOf(thisCampaignMember.CampaignId))
                            && accountToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.Account__c)+'_'+Id.valueOf(thisCampaignMember.CampaignId)).Event__c == thisEvent.Id){
                                hasExistingEventRegistration = true;
                                //Sync the Event Registration status from Campaign member based on Campaign Member / Event Registration Sync configuration in respective event
                                processEventRegistrationStatusFromCampaignMember(accountToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.Account__c)+'_'+Id.valueOf(thisCampaignMember.CampaignId)).Event__r, accountToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.Account__c)+'_'+Id.valueOf(thisCampaignMember.campaignId)), thisCampaignMember);
                                eventRegistrationToUpsert.put(thisCampaignMember.Id, accountToCampaignIdEventRegistrationMap.get(Id.valueOf(thisCampaignMember.Account__c)+'_'+Id.valueOf(thisCampaignMember.CampaignId)));
                            }

                        if(hasExistingEventRegistration){
                            hasExistingEventRegistration = false;
                        }
                        else {
                            //If there is no Event registration with the Lead / Contact / Account added as Campaign member in respective Event then create new Event registration
                            Event_Registration__c thisNewEventRegistration = new Event_Registration__c();
                            thisNewEventRegistration.Event__c                       = thisEvent.Id;
                            thisNewEventRegistration.First_Name__c              = thisCampaignMember.FirstName;
                            thisNewEventRegistration.Last_Name__c               = thisCampaignMember.LastName;
                            thisNewEventRegistration.Event_Email__c         = thisCampaignMember.Email;
                            thisNewEventRegistration.Event_Mobile__c            = thisCampaignMember.MobilePhone;
                            thisNewEventRegistration.Registration_Type__c = ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF;
                            thisNewEventRegistration.RecordTypeId         = ct_EventConstants.EVENT_REGISTRATION_MASTER_EVENT_RECORD_TYPE_ID;

                            if(thisCampaignMember.LeadId != null){
                                thisNewEventRegistration.Enquirer__c = thisCampaignMember.LeadId;
                            }

                            /*if(thisCampaignMember.ContactId != null){
                                thisNewEventRegistration.Contact__c = thisCampaignMember.ContactId;
                            }*/

                            if(thisCampaignMember.Account__c != null){
                                thisNewEventRegistration.Account_Name__c = thisCampaignMember.Account__c;
                            }
                            //Sync the Event Registration status from Campaign member based on Campaign Member / Event Registration Sync configuration in respective event
                            processEventRegistrationStatusFromCampaignMember(thisEvent, thisNewEventRegistration, thisCampaignMember);
                            //eventRegistrationToUpsert.add(thisNewEventRegistration);
                            eventRegistrationToUpsert.put(thisCampaignMember.Id, thisNewEventRegistration);
                        }
                    }
                }
            }
            
            if(!eventRegistrationToUpsert.isEmpty()){
                //Upsert Event Registration records
                upsert eventRegistrationToUpsert.values();
                //Populate Event Registration Id on respective new campaign member record
                processEventRegistrationIdInCampaignMember(campaignMemberList, eventRegistrationToUpsert);
                //Update campaign member record after populating the event registration Id
                update campaignMemberList;
            }
        }
        catch(Exception e){
            ct_Logger.logMessage(e, 'Campaign Member - Event Registration');
            throw e;
        }
    }
    
    /**
    * @description Method to populate Event registration Id in campaign member record
    * @param campaignMemberList : Campaign member list for which event registration needs to be populated
    * @param eventRegistrationMap : Campaign Id to event registration map
    **/
    global static void processEventRegistrationIdInCampaignMember(List<CampaignMember> campaignMemberList, Map<Id, Event_Registration__c> eventRegistrationMap){
        for(CampaignMember thisCampaignMember : campaignMemberList){
            if(!eventRegistrationMap.isEmpty()
            && eventRegistrationMap.containsKey(thisCampaignMember.Id)){
                thisCampaignMember.Event_Registration__c = eventRegistrationMap.get(thisCampaignMember.Id).Id;
            }
        }
    }

    global static void syncEventRegistrationWithCampaignMember(List<CampaignMember> campaignMemberList, Set<Id> eventRegistrationIds){
        try{
            List<Event_Registration__c> eventRegistrationsToUpdate = new List<Event_Registration__c>();
            Map<Id, Event_Registration__c> eventRegistrationMap = new Map<Id, Event_Registration__c>(
                                                                [SELECT Id,
                                                                First_Name__c, 
                                                                Last_Name__c,
                                                                Event__c, 
                                                                Event__r.Campaign__c, 
                                                                Event__r.CM_ER_Auto_Sync__c,  
                                                                Event__r.Event_Reg_New_Status__c,
                                                                Event__r.Event_Reg_Invited_Status__c,
                                                                Event__r.Event_Reg_Registered_Status__c,
                                                                Event__r.Event_Reg_Did_Not_Attend_Status__c,
                                                                Event__r.Event_Reg_Declined_Status__c,
                                                                Event__r.Event_Reg_Checked_Out_Status__c,
                                                                Event__r.Event_Reg_Checked_In_Status__c,
                                                                Event__r.Event_Reg_Cancelled_Status__c,
                                                                Event_Email__c, 
                                                                Contact__c,
                                                                Enquirer__c,
                                                                Primary_Subject_Area_Interest__c,
                                                                Object_for_New_Attendees__c, 
                                                                Record_Type_for_New_Attendees__c,
                                                                Event_Registration_Status__c
                                                            FROM Event_Registration__c 
                                                            WHERE Id IN:eventRegistrationIds]);

            for(CampaignMember thisCampaignMember : campaignMemberList){
                if(!eventRegistrationMap.isEmpty()
                    && eventRegistrationMap.containsKey(thisCampaignMember.Event_Registration__c)){
                        processEventRegistrationStatusFromCampaignMember(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Event__r, eventRegistrationMap.get(thisCampaignMember.Event_Registration__c), thisCampaignMember);
                        eventRegistrationsToUpdate.add(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c));
                }
            }

            if(!eventRegistrationsToUpdate.isEmpty()){
                ct_Event_RegistrationTriggerHandler.turnOff();
                update eventRegistrationsToUpdate;
            }
        }
        catch(Exception e){
            ct_Logger.logMessage(e, 'Event Registration Status Sync From Campaign Member');
            throw e;
        }
    }

    global static void processEventRegistrationStatusFromCampaignMember(Event__c thisEvent, Event_Registration__c thisEventRegistration, CampaignMember thisCampaignMember){
        Map<String, String> eventRegistrationStatusMap = new Map<String,String>{
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_NEW            => thisEvent.Event_Reg_New_Status__c,                       
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_INVITED        => thisEvent.Event_Reg_Invited_Status__c,
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_REGISTERED     => thisEvent.Event_Reg_Registered_Status__c,
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_CHECKED_IN     => thisEvent.Event_Reg_Checked_In_Status__c,
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_CHECKED_OUT    => thisEvent.Event_Reg_Checked_Out_Status__c,
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_DID_NOT_ATTEND => thisEvent.Event_Reg_Did_Not_Attend_Status__c,
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_DECLINED       => thisEvent.Event_Reg_Declined_Status__c,
            ct_EventConstants.CAMPAIGN_MEMBER_STATUS_CANCELLED      => thisEvent.Event_Reg_Cancelled_Status__c};

            if(eventRegistrationStatusMap.containsKey(thisCampaignMember.Status)
                && eventRegistrationStatusMap.get(thisCampaignMember.Status) != null){
                    thisEventRegistration.Event_Registration_Status__c     = eventRegistrationStatusMap.get(thisCampaignMember.Status);
                    thisEventRegistration.Primary_Subject_Area_Interest__c = thisCampaignMember.Primary_Subject_Area_Interest__c;
        }
    }

    global static void processCampaignMemberStatusFromEventRegistrationStatus(Event_Registration__c thisEventRegistration, CampaignMember thisCampaignMember){
            
        Map<String, String> campaignMemberStatusMap = new Map<String,String>{
            ct_EventConstants.EVENT_REGISTRATION_NEW            => thisEventRegistration.Event__r.Event_Reg_New_Status__c,
            ct_EventConstants.EVENT_REGISTRATION_INVITED        => thisEventRegistration.Event__r.Event_Reg_Invited_Status__c,
            ct_EventConstants.EVENT_REGISTRATION_REGISTERED     => thisEventRegistration.Event__r.Event_Reg_Registered_Status__c,
            ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN     => thisEventRegistration.Event__r.Event_Reg_Checked_In_Status__c,
            ct_EventConstants.EVENT_REGISTRATION_CHECKED_OUT    => thisEventRegistration.Event__r.Event_Reg_Checked_Out_Status__c,
            ct_EventConstants.EVENT_REGISTRATION_DID_NOT_ATTEND => thisEventRegistration.Event__r.Event_Reg_Did_Not_Attend_Status__c,
            ct_EventConstants.EVENT_REGISTRATION_DECLINED       => thisEventRegistration.Event__r.Event_Reg_Declined_Status__c,
            ct_EventConstants.EVENT_REGISTRATION_CANCELLED      => thisEventRegistration.Event__r.Event_Reg_Cancelled_Status__c};

            if(campaignMemberStatusMap.containsKey(thisEventRegistration.Event_Registration_Status__c)
                    && campaignMemberStatusMap.get(thisEventRegistration.Event_Registration_Status__c) != null){
                        thisCampaignMember.Status                           = campaignMemberStatusMap.get(thisEventRegistration.Event_Registration_Status__c);
                        thisCampaignMember.Primary_Subject_Area_Interest__c = thisEventRegistration.Primary_Subject_Area_Interest__c;
            }
        }

        @future
        global static void campaignMemberRollupCalculation(Set<Id> campaignIds){
            processCampaignMemberCountOnEvent(campaignIds);
        }
    
    global static void processCampaignMemberCountOnEvent(Set<Id> campaignIds){
        Set<Id> campaignEventIds = new Set<Id>();
        Map<Id, Event__c> mapOfCampaignEventsToUpdate = new Map<Id, Event__c>();
        Map<Id, Campaign> mapOfCampaign = new Map<Id, Campaign>();
        String campaignId;
        try{
            for(Campaign camp : [Select Id, Event__c From Campaign Where Id IN : campaignIds]){
                if(camp.Event__c != null){
                    campaignEventIds.add(camp.Event__c);
                    mapOfCampaign.put(camp.Id, camp);
                }
            }
            for(Event__c evt : [Select Id, Name, No_Campaign_Members__c From Event__c Where Id IN : campaignEventIds]){
                evt.No_Campaign_Members__c = 0;
                mapOfCampaignEventsToUpdate.put(evt.Id, evt);
            }
        
        for(AggregateResult thisAggregrateResult : [Select COUNT(Id) totalRecords, CampaignId FROM CampaignMember
                                                    WHERE CampaignId IN : campaignIds
                                                    GROUP BY CampaignId]){
            
           campaignId               = (Id)thisAggregrateResult.get('CampaignId');
           if(!mapOfCampaign.isEmpty() && mapOfCampaign.containsKey(campaignId)){
                mapOfCampaignEventsToUpdate.get(mapOfCampaign.get(campaignId).Event__c).put('No_Campaign_Members__c',(Integer)thisAggregrateResult.get('totalRecords'));                                          
           }                                             
         }
        
        if(!mapOfCampaignEventsToUpdate.isEmpty()){
            update mapOfCampaignEventsToUpdate.values();
        }
       }
       catch(Exception e){
            //Exception mechanism to log any exceptions occured during the dml operation
            ct_Logger.logMessage(e, 'Event - Campaign Member Custom Rollup field Calculation');
        }        
        }
        
        global static void cancelEventRegistration(Set<Id> eventRegistationIds){
            List<Event_Registration__c> eventRegistrationToUpdate = new List<Event_Registration__c>();
            try{
            for(Event_Registration__c thisEventRegistration : [SELECT Id, Event_Registration_Status__c
                                                                                                                    FROM Event_Registration__c
                                                                                                                    WHERE Id IN: eventRegistationIds]){
                thisEventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_CANCELLED;                                                    
              eventRegistrationToUpdate.add(thisEventRegistration);                                                                                 
            }
            update eventRegistrationToUpdate;
        }
        catch(Exception e){
            //Exception mechanism to log any exceptions occured during the dml operation
            ct_Logger.logMessage(e, 'Event Registration Cancellation - Campaign member Removal');
        }
    }
}