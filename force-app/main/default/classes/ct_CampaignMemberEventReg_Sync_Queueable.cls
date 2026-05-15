/**
 * @description       : Queueable class for Creating Campaign member from Event Registration for Syncing and 
 * 						calculate and update the No of Campaign Member field in Event
 * @author            : Creation Admin
 * @last modified on  : 01-14-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-10-2020   Creation Admin   Initial Version
**/
global without sharing class ct_CampaignMemberEventReg_Sync_Queueable implements Queueable {
	private Set<String> eventRegistrationIds;
	private Set<String> contactIds;
	private Set<String> leadIds;
	private Set<String> accountIds;

	global ct_CampaignMemberEventReg_Sync_Queueable(Set<String> eventRegistrationIdSet, Set<String> contactIdSet, Set<String> leadIdsSet, Set<String> accountIdSet) {
		this.eventRegistrationIds = eventRegistrationIdSet;
		this.contactIds 					= contactIdSet;
		this.leadIds 						= leadIdsSet;
		this.accountIds 					= accountIdSet;
	}

	global void execute(QueueableContext context) {
		try{
			Map<Id, CampaignMember> eventRegistrationIdToCampaignPayloadMap = new Map<Id, CampaignMember>();
			for(Web_Site_Submission__c thisWebSiteSubmission : [SELECT Id,
																		Name,
																		Payload__c
																	FROM Web_Site_Submission__c
																	WHERE Name IN:eventRegistrationIds]){
				if(String.isNotBlank(thisWebSiteSubmission.Payload__c)){
					CampaignMember thisCampaignMemberPayload = (CampaignMember)JSON.deserialize(thisWebSiteSubmission.Payload__c, CampaignMember.class);
					eventRegistrationIdToCampaignPayloadMap.put(Id.valueOf(thisWebSiteSubmission.Name), thisCampaignMemberPayload);
				}					
			}
			//Fetch the Event Registrations
			List<Event_Registration__c> thisEventRegistrationList = [SELECT Id,
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
																			Primary_Subject_Area_Interest__c,
																			Event_Registration_Status__c
																	FROM Event_Registration__c 
																	WHERE Id IN:eventRegistrationIds];
			String uniqueKey;
			Map<String, CampaignMember> leadIdToCampaignMemberMap = new Map<String, CampaignMember>();
			//Map<String, CampaignMember> contactToCampaignMemberMap = new Map<String, CampaignMember>();
			Map<String, CampaignMember> accountToCampaignMemberMap = new Map<String, CampaignMember>();
		 	//Fetch the Campaign Member based on Lead and Contact Ids
			for(CampaignMember thisCampaignMember :[SELECT Id, 
																									LeadId, 
																									ContactId,
																									Account__c,
																									CampaignId,
																									Status
																							FROM CampaignMember
																							WHERE LeadId IN:LeadIds
																							OR ContactId IN:contactIds 
																							OR Account__c IN:accountIds]){
					if(thisCampaignMember.LeadId != null){
							leadIdToCampaignMemberMap.put(Id.valueOf(thisCampaignMember.LeadId)+'_'+Id.valueOf(thisCampaignMember.CampaignId), thisCampaignMember);
					}

					/*if(thisCampaignMember.ContactId != null){
							contactToCampaignMemberMap.put(Id.valueOf(thisCampaignMember.ContactId)+'_'+Id.valueOf(thisCampaignMember.CampaignId), thisCampaignMember);
					}*/
					
					if(thisCampaignMember.Account__c != null){
						accountToCampaignMemberMap.put(Id.valueOf(thisCampaignMember.Account__c)+'_'+Id.valueOf(thisCampaignMember.CampaignId), thisCampaignMember);
					}
			}

			List<CampaignMember> campaignMembersToInsert = new List<CampaignMember>();
			Set<Id> campaignIds =  new Set<Id>();
            Set<Id> eventRegistrationIds = new Set<Id>();
			for(Event_Registration__c thisEventRegistration : thisEventRegistrationList){
                if(thisEventRegistration.Event__r.CM_ER_Auto_Sync__c == ct_EventConstants.EVENT_CM_ER_AUTO_SYNC_YES
					&& (/*thisEventRegistration.Contact__c != null ||*/ thisEventRegistration.Enquirer__c != null || thisEventRegistration.Account_Name__c != null)
					&& thisEventRegistration.Event__r.Campaign__c != null){

						CampaignMember thisCampaignMember = new CampaignMember();
					
						if(!eventRegistrationIdToCampaignPayloadMap.isEmpty()
							&& eventRegistrationIdToCampaignPayloadMap.containsKey(Id.valueOf(thisEventRegistration.Id))){
								
							Map<String, Object> fieldsToValue = eventRegistrationIdToCampaignPayloadMap.get(Id.valueOf(thisEventRegistration.Id)).getPopulatedFieldsAsMap();
							for(String fieldAPIName : fieldsToValue.keyset()){
								thisCampaignMember.put(fieldAPIName, fieldsToValue.get(fieldAPIName));
							}
						}

						thisCampaignMember.Event_Registration__c = thisEventRegistration.Id;
						thisCampaignMember.CampaignId            = thisEventRegistration.Event__r.Campaign__c;
						campaignIds.add(thisEventRegistration.Event__r.Campaign__c);
						ct_Campaign_MemberTriggerHelper.processCampaignMemberStatusFromEventRegistrationStatus(thisEventRegistration, thisCampaignMember);
								
						/*if(thisEventRegistration.Contact__c != null){
							thisCampaignMember.ContactId = thisEventRegistration.Contact__c;
							uniqueKey = Id.valueOf(thisEventRegistration.Contact__c)+'_'+Id.valueOf(thisEventRegistration.Event__r.Campaign__c);

							if(contactToCampaignMemberMap.isEmpty()
								|| !contactToCampaignMemberMap.containsKey(uniqueKey)){
									campaignMembersToInsert.add(thisCampaignMember);
							}
						}*/
						if(thisEventRegistration.Enquirer__c != null){
							thisCampaignMember.LeadId = thisEventRegistration.Enquirer__c;
							uniqueKey = Id.valueOf(thisEventRegistration.Enquirer__c)+'_'+Id.valueOf(thisEventRegistration.Event__r.Campaign__c);

							if(leadIdToCampaignMemberMap.isEmpty()
								|| !leadIdToCampaignMemberMap.containsKey(uniqueKey)){
									campaignMembersToInsert.add(thisCampaignMember);
							}
						}
						else if(thisEventRegistration.Account_Name__c != null){
							thisCampaignMember.Account__c = thisEventRegistration.Account_Name__c;
							uniqueKey = Id.valueOf(thisEventRegistration.Account_Name__c)+'_'+Id.valueOf(thisEventRegistration.Event__r.Campaign__c);

							if(accountToCampaignMemberMap.isEmpty()
								|| !accountToCampaignMemberMap.containsKey(uniqueKey)){
									campaignMembersToInsert.add(thisCampaignMember);
							}
						}
			}
			
			if(!campaignMembersToInsert.isEmpty()){
				insert campaignMembersToInsert;
				// calculate event No of campaign member roll up field
				ct_Campaign_MemberTriggerHelper.processCampaignMemberCountOnEvent(campaignIds);
			}
		}
	}
		catch(Exception e){
			ct_Logger.logMessage(e, 'Event Registration Queueable- Campaign Member Sync');
			throw e;
		}
	}
}