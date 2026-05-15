/**
 * @description       : 
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 02-04-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-14-2020   Creation Admin   Initial Version
 * Helper class for Session Trigger Handler
**/
global without sharing class ct_SessionTriggerHandlerHelper {

	/**
	* @description - Used to update the Number of related sessions under the Track
	* @param Set<Id> setOfTrackIds - Track record Ids
	**/
	@future
	global static void updateSessionCountOnTrack(Set<Id> setOfTrackIds){
		Map<Id, AggregateResult> thisAggResultMap = new Map<Id, AggregateResult>([SELECT Track__c Id, COUNT(Id) thisCount FROM Session__c WHERE Track__c IN :setOfTrackIds GROUP BY Track__c]);
		Map<Id, Track__c> trackMapToUpdate = new Map<Id, Track__c>([SELECT Id, Number_of_Related_Sessions__c FROM Track__c WHERE Id =:setOfTrackIds]);
		try{
			if(!trackMapToUpdate.isEmpty()){
				for(Track__c thisTrack : trackMapToUpdate.values()){
					thisTrack.Number_of_Related_Sessions__c = 0;
					if( !thisAggResultMap.isEmpty()
						&& thisAggResultMap.containsKey(thisTrack.Id)){
						thisTrack.Number_of_Related_Sessions__c = (Integer)thisAggResultMap.get(thisTrack.Id).get('thisCount');
					}
				}
				update trackMapToUpdate.values();
			}
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Update Number of Session field on Track');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
	}
	/**
	* @description used to update the Session record with Booking date
	* @param list<Session__c> sessionList 
	**/
	global static void updateSession(list<Session__c> sessionList){
			for(Session__c thisSession : sessionList){
		if(!thisSession.Waiting_List_Enabled__c
								&& thisSession.Registration_Closed__c && thisSession.Enable_Waiting_List_on_Closed__c && thisSession.Final_Booking_Date__c>System.today()){
									thisSession.Waiting_List_Enabled__c = true;
		}
		if(thisSession.Final_Booking_Date__c == null && thisSession.Session_End_Date__c != null){
			thisSession.Final_Booking_Date__c = thisSession.Session_End_Date__c;
		}
			}
	}
}