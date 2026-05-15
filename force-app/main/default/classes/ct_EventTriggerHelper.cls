/**
 * @description       : Helper class for Event Trigger
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 12-22-2020
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-15-2020   Creation Admin   Initial Version
**/
global without sharing class ct_EventTriggerHelper {
	
	/**
	* @description Method to process Event registration and Session registration after Event status is moved to Post Event
	* @param approvedPostEventIds Post Event Ids
	* @return List<SObject> 
	**/
	global static List<SObject> processApprovedPostEvents(Set<Id> approvedPostEventIds){
		List<SObject> thisSobjectListToUpdate = new List<SObject>();

		Map<String, String> eventRegistrationStatusMap = new Map<String, String>{ct_EventConstants.EVENT_REGISTRATION_REGISTERED => ct_EventConstants.EVENT_REGISTRATION_DID_NOT_ATTEND};

		Map<String, String> sessionRegistrationStatusMap = new Map<String, String>{ct_EventConstants.SESSION_REGISTRATION_REGISTERED => ct_EventConstants.SESSION_REGISTRATION_DID_NOT_ATTEND};
		//Update the Event registration records with status Registered to Did not attend
		for(Event_Registration__c thisEventRegistration : [SELECT Id, Event__c, Event_Registration_Status__c
                                                            FROM Event_Registration__c
                                                            WHERE Event__c IN: approvedPostEventIds]){
			if(thisEventRegistration.Event_Registration_Status__c != null
				&& eventRegistrationStatusMap.containsKey(thisEventRegistration.Event_Registration_Status__c)){
					thisEventRegistration.Event_Registration_Status__c = eventRegistrationStatusMap.get(thisEventRegistration.Event_Registration_Status__c);
					thisSobjectListToUpdate.add(thisEventRegistration);
			}												
		}

		//Update the Session registration records with status Registered to Did not attend
		for(Session_Registration__c thisSessioRegistration : [SELECT Id, Status__c, Event_Registration__c, Event_Registration__r.Event__c
                                                                FROM Session_Registration__c
                                                                WHERE Event_Registration__c != null
                                                                AND Event_Registration__r.Event__c IN: approvedPostEventIds]){
			if(thisSessioRegistration.Status__c != null
				&& sessionRegistrationStatusMap.containsKey(thisSessioRegistration.Status__c)){
					thisSessioRegistration.Status__c = sessionRegistrationStatusMap.get(thisSessioRegistration.Status__c);
					thisSobjectListToUpdate.add(thisSessioRegistration);
			}												
		}
		System.debug('thisSobjectListToUpdate: '+thisSobjectListToUpdate);
		return thisSobjectListToUpdate;
	}
    
	/**
	* @description Method to populate the Event Id in respective Campaign based on Campaign Id on Event record
	* @param campaignToEventIdMap Campaign Id To Event Map
	**/
	global static void processEventIdOnCampaign(Map <Id, Id> campaignToEventIdMap){
		List<Campaign> campaignListToUpdate = new List<Campaign>();
		try{
			for(Campaign thisCampaign : [SELECT Id, Event__c 
																			FROM Campaign
																			WHERE Id IN :campaignToEventIdMap.keySet()]){
					if(campaignToEventIdMap.containsKey(thisCampaign.Id)){
							thisCampaign.Event__c = campaignToEventIdMap.get(thisCampaign.Id);
							campaignListToUpdate.add(thisCampaign);
					}
			}
			update campaignListToUpdate;
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Processing Event Id On Campaign');
		}
	}

	/**
	* @description Method to sync the Event Registration status and other details with its respective Campaign member
	* @param eventIds Event Record Id whose Event registration needs to be in sync with its respective Campaign member
	**/
	global static void syncEventRegistrationToCampaignMember(Set<Id> eventIds){
		Set<String> eventRegistrationForCampaignMemberSync  = new Set<String>();
		Set<String> leadIdForCampaignMember       		      = new Set<String>();
		Set<String> contactIdForCampaignMember        		  = new Set<String>();
		Set<String> accountIdForCampaignMember        	  = new Set<String>();

		for(Event_Registration__c thisEventRegistration : [SELECT Id, Event__c, Enquirer__c, Contact__c, Account_Name__c
																												FROM Event_Registration__c
																												WHERE Event__c IN:eventIds]){
			eventRegistrationForCampaignMemberSync.add( String.valueOf(Id.valueOf(thisEventRegistration.Id)).substring(0, 15));
			if(thisEventRegistration.Enquirer__c != null){
					leadIdForCampaignMember.add(thisEventRegistration.Enquirer__c);
			}

			/*if(thisEventRegistration.Contact__c != null){
					contactIdForCampaignMember.add(thisEventRegistration.Contact__c);
			}*/
			
			if(thisEventRegistration.Account_Name__c != null){
					accountIdForCampaignMember.add(thisEventRegistration.Account_Name__c);
			}                                             
		}

		if(!eventRegistrationForCampaignMemberSync.isEmpty()){
			//Invoke the Queueable class to sync event registration with campaign member
			ct_CampaignMemberEventReg_Sync_Queueable campaignMemberSyncQueueableJob = new ct_CampaignMemberEventReg_Sync_Queueable(eventRegistrationForCampaignMemberSync, contactIdForCampaignMember, leadIdForCampaignMember, accountIdForCampaignMember);
			ID jobID = System.enqueueJob(campaignMemberSyncQueueableJob);
		}
	}
    
	/**
		* @description Method to update GDPR statement text.
		* @param event: Affected event.
		**/
	global static void updateGDPRStatements(Event__c event){
        System.debug('Calling Update GDPR Statement');
		//Inintialise the map to hold GDPR text against the picklist value from metadata.
		Map<String, Event_GDPR__mdt> mdtMap = ct_MetadataService.eventGDPRStatementMetadata;
		System.debug('mdtMap'+mdtMap);
        System.debug('event.GDPR_Statement_Used__c'+event.GDPR_Statement_Used__c);
        System.debug('mdtMap.containsKey(event.GDPR_Statement_Used__c)'+mdtMap.containsKey(event.GDPR_Statement_Used__c));
		//Update GDPR text field on Event through metadata.
		if(!mdtMap.isEmpty()
				&& mdtMap.containsKey(event.GDPR_Statement_Used__c)){
				event.Statement_Title__c = mdtMap.get(event.GDPR_Statement_Used__c).Statement_Title__c;
				event.Statement_Text_above_dec__c = mdtMap.get(event.GDPR_Statement_Used__c).Statement_Text_above_dec__c;
				event.Declaration_Text__c = mdtMap.get(event.GDPR_Statement_Used__c).Declaration_Text__c;
				event.Statement_Text_below_dec__c = mdtMap.get(event.GDPR_Statement_Used__c).Statement_Text_below_dec__c;
				event.Consent_Required_to_Register__c = mdtMap.get(event.GDPR_Statement_Used__c).Consent_Required_to_Register__c;
		}
	}

	/**
		* @description Method to Success Message configured in Event Setting Metadata
		* @param event: Event__c record to for which Success Message needs to be updated
		**/
	global static void updateSuccessMessage(Event__c thisEvent){
		if(ct_MetadataService.getEventSettingByDeveloperName(ct_EventConstants.EVENT_SUCCESS_MESSAGE_EVENT_SETTING) != null
				&& ct_MetadataService.getEventSettingByDeveloperName(ct_EventConstants.EVENT_SUCCESS_MESSAGE_EVENT_SETTING).Value__c != null){
						thisEvent.Success_Message__c = ct_MetadataService.getEventSettingByDeveloperName(ct_EventConstants.EVENT_SUCCESS_MESSAGE_EVENT_SETTING).Value__c;
		}
	}
	
    
	/**
	* @description Method to process the event roll up on Event group
	* @param evtGrpIds Event group Ids
	**/
	@future
	global static void updateNumberOfEvtOnEVtGrp(Set<Id> evtGrpIds){
		Map<Id,Event_Group__c> mapOfEventGRpToUpdate = new Map<Id,Event_Group__c>();

		for(Event_Group__c thisEventGroup : [SELECT Id, Number_of_Active_Events__c
																						FROM Event_Group__c
																						WHERE Id IN :evtGrpIds]){

			thisEventGroup.Number_of_Active_Events__c = 0;
			mapOfEventGRpToUpdate.put(thisEventGroup.Id, thisEventGroup);
		}
		
		AggregateResult[] groupedResultsforRegistered = [SELECT COUNT(Id)cont, Active__c value, Event_Group__c 
																											FROM Event__c where Event_Group__c IN :evtGrpIds AND Active__c = true
																											GROUP BY Active__c, Event_Group__c];
		
		for(AggregateResult ar:groupedResultsforRegistered){
			Id evtgrpID = (ID)ar.get('Event_Group__c');
			Integer count = (INTEGER)ar.get('cont');
			
			if(mapOfEventGRpToUpdate.containsKey(evtgrpID)){
					mapOfEventGRpToUpdate.get(evtgrpID).Number_of_Active_Events__c = count;
			}
		}
		if(!mapOfEventGRpToUpdate.values().isEmpty()){
			try{
				update mapOfEventGRpToUpdate.values();
			}
			catch(Exception e){
				//Exception mechanism to log any exceptions occured during the dml operation
				ct_Logger.logMessage(e, 'Event Group - Active Events Calculation');
			}
		}
  }
    
	/**
		* @description Method to avoid Event activation without Event Product.
		* @param evt: Affected Event Record.
	**/
	global static void checkEvtProdAvailable(Event__c Newevt, Event__c oldEvt){
			
		Event__c event = [Select Id, Name, (Select Id, Name From Tickets__r) From Event__c Where Id =: Newevt.Id];
		
		if(Newevt.Active__c != oldEvt.Active__c && Newevt.Active__c && Newevt.Registration_Status__c == 'Open' 
				&& (Newevt.Manual_or_Scheduled_Publishing__c == 'Manual Publishing' 
						|| (Newevt.Manual_or_Scheduled_Publishing__c == 'Scheduled Publishing' && Newevt.Event_Publishing_Date_Time__c != null))){
								if(event.Tickets__r.size() == 0){
										Newevt.addError('You can not activate the Event without an Event Product.');
								}
						}
		if(Newevt.Event_Status__c != oldEvt.Event_Status__c && oldEvt.Event_Status__c == 'Planning'
				&& Newevt.Event_Status__c != 'Cancelled'){
						if(event.Tickets__r.size() == 0){
								Newevt.addError('You cannot move this Event to ‘Activation’ without at least 1 Event Product related to this event.');
						}
				}
  }
}