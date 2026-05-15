/**
 * @description       : Controller class for Share Event in Social Media component for sharing the Event details in Social media platform
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 02-03-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   02-03-2021   Creation Admin   Initial Version
**/
global without sharing class ShareEventWithSocialMedia {
	/**
	* @description Method to retrieve details about event record
	* @param recordId Event record ID
	* @return Event__c 
	**/
	@AuraEnabled(cacheable=true)
	global static Event__c getEventRec(String recordId){
		Event__c evt = [Select Id, Name, Event_Description__c,Social_App_Visibility__c,Visible_Social_App__c from Event__c where Id=: recordId];
		return evt;
	}
}