/**
 * @description       : Clone Event based on values configured in the Event Clone Setting metadata type
 * @author            : Creation Admin
 * @last modified on  : 01-17-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   09-22-2020   Creation Admin   Initial Version
**/
global without sharing class ct_EventStructureCloneController {
   /*
	* Description: Clone the Event and related records with the values configured in the Event Clone Setting metadata type
	* */
	@AuraEnabled
	global static String cloneEventWithEventStructure(String eventId, String newEventDetails){	
		try{
			Map<String, Object> eventDetails =  (Map<String, Object>)JSON.deserializeUntyped(newEventDetails);
			
			//Clone the event
			Event__c thisEventToBeCloned 						=  Database.query('SELECT ' + ct_Util.getAllFieldsQueryStringForSObject('Event__c')+' FROM Event__c WHERE Id =: eventId LIMIT 1');
			Event__c thisClonedEvent 							= thisEventToBeCloned.clone(false, true, false, false);
			
			thisClonedEvent.Event_Start_Date__c                = Date.valueOf(String.valueOf(eventDetails.get('Event_Start_Date__c')));
			thisClonedEvent.Event_End_Date__c                  = (eventDetails.containsKey('Event_End_Date__c') && eventDetails.get('Event_End_Date__c') != null)  ? Date.valueOf(String.valueOf(eventDetails.get('Event_End_Date__c'))) : null;
			thisClonedEvent.Final_Event_Registration_Date__c   = thisClonedEvent.Event_Start_Date__c;
			thisClonedEvent.Start_Time__c                      = Datetime.valueOf(String.valueOf(eventDetails.get('Event_Start_Date__c')) + ' ' +String.valueOf(eventDetails.get('Start_Time__c'))).time();
			thisClonedEvent.End_Time__c                        = (eventDetails.containsKey('Event_End_Date__c') && eventDetails.get('Event_End_Date__c') != null && eventDetails.containsKey('End_Time__c') && eventDetails.get('End_Time__c') != null) ?  Datetime.valueOf(String.valueOf(eventDetails.get('Event_End_Date__c')) + ' ' +String.valueOf(eventDetails.get('End_Time__c'))).time() : null;
			thisClonedEvent.Name                               = thisClonedEvent.Name + ' - Clone';
			thisClonedEvent.Web_Event_Name__c                  = thisClonedEvent.Name + ' - Clone';
			//Calling metaDataValues method to get fields and values for event
			prePopulateValueFromCloneMetadata(thisClonedEvent, ct_MetadataService.getEventCloneSettingByObjectName('Event__c'));

			insert thisClonedEvent;
			Map<String, Track__c> clonedTrackToBeInserted = new Map<String, Track__c>();
			List<SObject> sobjectListToInsert = new List<SObject>();
            
			for(Track__c thisTrackToBeCloned : Database.query('SELECT ' + ct_Util.getAllFieldsQueryStringForSObject('Track__c')+' FROM Track__c WHERE Event__c =: eventId')){
				Track__c thisClonedTrack = thisTrackToBeCloned.clone(false, true, false, false);
				thisClonedTrack.Event__c = thisClonedEvent.Id;
				//Calling metaDataValues method to get fields and values for track				
				prePopulateValueFromCloneMetadata(thisClonedTrack, ct_MetadataService.getEventCloneSettingByObjectName('Track__c'));

				clonedTrackToBeInserted.put(thisTrackToBeCloned.Id, thisClonedTrack);	
			}
			
			insert clonedTrackToBeInserted.values();

			for(Event_Product__c thisEventProductToClone : Database.query('SELECT ' + ct_Util.getAllFieldsQueryStringForSObject('Event_Product__c')+' FROM Event_Product__c WHERE Event__c =: eventId')){
				Event_Product__c thisEventProduct = thisEventProductToClone.clone(false, true, false, false);
				thisEventProduct.Event__c 				= thisClonedEvent.Id;
				//Calling metaDataValues method to get fields and values for event product
				prePopulateValueFromCloneMetadata(thisEventProduct, ct_MetadataService.getEventCloneSettingByObjectName('Event_Product__c'));
				sobjectListToInsert.add(thisEventProduct);
			}

			for(Session__c thisSessionToBeCloned : Database.query('SELECT ' + ct_Util.getAllFieldsQueryStringForSObject('Session__c')+' FROM Session__c WHERE Event__c =: eventId')){
				Session__c thisClonedSession = thisSessionToBeCloned.clone(false, true, false, false);
				if(!clonedTrackToBeInserted.isEmpty()
					&& clonedTrackToBeInserted.containsKey(thisSessionToBeCloned.Track__c)){
					thisClonedSession.Track__c                 = clonedTrackToBeInserted.get(thisSessionToBeCloned.Track__c).Id;
					}

					thisClonedSession.Event__c                 = thisClonedEvent.Id;
					thisClonedSession.Session_Start_Date__c    = thisClonedEvent.Event_Start_Date__c;
					thisClonedSession.Start_Time__c            = thisSessionToBeCloned.Start_Time__c;
					thisClonedSession.Session_End_Date__c      = thisClonedEvent.Event_End_Date__c;
					thisClonedSession.End_Time__c              = thisSessionToBeCloned.End_Time__c;
					//Calling metaDataValues method to get fields and values for session
					prePopulateValueFromCloneMetadata(thisClonedSession, ct_MetadataService.getEventCloneSettingByObjectName('Session__c'));

					sobjectListToInsert.add(thisClonedSession);
				
			}
	
            insert sobjectListToInsert;
			return thisClonedEvent.Id;
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event & Event Structure clone');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
	}

	
	global static void prePopulateValueFromCloneMetadata(SObject thisSobject, Map<String, Event_Clone_Setting__mdt> eventCloneSettings){
		if(eventCloneSettings != null
		&& !eventCloneSettings.isEmpty()){
			for(String thisFieldAPIName : eventCloneSettings.keyset()){
				String fieldType = eventCloneSettings.get(thisFieldAPIName).Fields__r.DataType;
				Object fieldDataTypeToSet = eventCloneSettings.get(thisFieldAPIName).Values__c;

				if(fieldDataTypeToSet != null){
					if(fieldType == 'Checkbox' && fieldDataTypeToSet != null){
						fieldDataTypeToSet = Boolean.valueOf(eventCloneSettings.get(thisFieldAPIName).Values__c);
					} else if(fieldType == 'Number(18, 0)' && fieldDataTypeToSet != null){
						fieldDataTypeToSet = Decimal.valueOf(eventCloneSettings.get(thisFieldAPIName).Values__c);
					} else if(fieldType == 'Date' && fieldDataTypeToSet != null){
						fieldDataTypeToSet = Date.valueOf(eventCloneSettings.get(thisFieldAPIName).Values__c);
					} else if(fieldType == 'Date/Time' && fieldDataTypeToSet != null){
						fieldDataTypeToSet = DateTime.valueOf(eventCloneSettings.get(thisFieldAPIName).Values__c);
					} 
				}
				thisSobject.put(thisFieldAPIName, fieldDataTypeToSet);
			}
		}
	}	
}