/**
 * @description       : Using this class to fetch Event and Event Registration records to show in the Order Confirmation page
 * @author            : Creation Admin
 * @last modified on  : 15-09-2021
 * @last modified by  : Rajeshkumar
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-27-2020   Creation Admin   Initial Version
**/
global without sharing class ct_EventBookingConfirmationController {

	@AuraEnabled
	global static String getRecordTypeDevNameById(String recordTypeId) {
		return [Select DeveloperName From RecordType Where Id =: recordTypeId limit 1].DeveloperName;
	}

	
	@AuraEnabled
  global static initialWrapper getInitialWrapper(String eventOrderId, String asperatoId){	
		try{
			if(!String.isEmpty(asperatoId)){
				Event_Order__c thisEventOrder = [SELECT Id /*, Asperato_Payment__c*/ FROM Event_Order__c /*WHERE Asperato_Payment__c =:asperatoId*/];
				eventOrderId = thisEventOrder.Id;
			}
			initialWrapper thisInitialWrapper 										= new initialWrapper();
			if(!String.isEmpty(eventOrderId)){
					thisInitialWrapper.eventRegistrations									= getEventRegistrationRecords(eventOrderId);
				thisInitialWrapper.isSessionRegistrationAvailable			= false;
				if(!thisInitialWrapper.eventRegistrations.isEmpty() && thisInitialWrapper.eventRegistrations.size() > 0){
					system.debug('thisInitialWrapper.eventRegistrations[0].Event__c>>>'+thisInitialWrapper.eventRegistrations[0].Id);
					system.debug('thisInitialWrapper.eventRegistrations[0].Event__c>>>'+thisInitialWrapper.eventRegistrations[0].Event__c);
					thisInitialWrapper.eventRecord										= getEventRecord(thisInitialWrapper.eventRegistrations[0].Event__c);
					system.debug('thisInitialWrapper.eventRecord>>>'+thisInitialWrapper.eventRecord);
					thisInitialWrapper.isSessionRegistrationAvailable = getSessionRegistrationEnabledProduct(thisInitialWrapper.eventRegistrations[0].Event__c, eventOrderId);
				}
			}
			
			return thisInitialWrapper;
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event Booking Confirmation Get Initial Wrapper');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
	}

	@AuraEnabled
  global static Boolean getSessionRegistrationEnabledProduct(String eventId, String eventOrderId){	
		List<Event_Registration__c> sessionRegEnabledRegistrations = new List<Event_Registration__c>();
		
			sessionRegEnabledRegistrations =[SELECT Id, Event__c, Event_Order__c, Event_Product__c, Event_Product__r.Enable_Session_Registrations__c
																				FROM Event_Registration__c
																				WHERE Event__c =:eventId
																				AND Event_Order__c=:eventOrderId
																				AND Event_Product__r.Enable_Session_Registrations__c = true];

		return (!sessionRegEnabledRegistrations.isEmpty() && sessionRegEnabledRegistrations.size() > 0 ) ? true : false;
	}


	@AuraEnabled
  global static Event__c getEventRecord(String eventId){	
		return [Select Id, Name, Success_Message__c, Event_Description__c,Social_App_Visibility__c,Visible_Social_App__c,Web_Event_Name__c, Web_Event_Location__c, Event_Start_Date__c,Event_End_Date__c, 
                                        FORMAT(Start_Time__c), FORMAT(End_Time__c), Web_Event_Pricing__c, RecordTypeId from Event__c where Id=: eventId];
	}

	@AuraEnabled
  global static List<Event_Registration__c> getEventRegistrationRecords(String eventOrderId){	
		try{
			List<Event_Registration__c> eventRegistrationList = new List<Event_Registration__c>();
			system.debug('eventOrderId>>>>>>>>>>>>>?>'+eventOrderId);
			eventRegistrationList = [SELECT 
																Id, 
																Name,
																Registration_Type__c, 
																Name__c, 
																QR_Code__c,
																Event__c, 
																Event_Product__c,
																Event_Product__r.Event_Product_Description__c,
																Event_Product__r.Enable_Session_Registrations__c,
																Event_Product__r.Name,
																First_Name__c, Last_Name__c, 
																Event_Order__c,
																QR_Code_URL__c,
																Event_Order__r.Name 
															FROM Event_Registration__c 
															WHERE Name != null
															AND Event_Order__c =: eventOrderId
															ORDER BY Name];
			
			return eventRegistrationList;
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event Booking Confirmation Get tickets');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
	}
	
	global class initialWrapper{
		@AuraEnabled
		global List<Event_Registration__c> eventRegistrations                	{get;set;}
		@AuraEnabled
		global Boolean isSessionRegistrationAvailable               				 	{get;set;}
		@AuraEnabled
		global Event__c eventRecord                                  				 	{get;set;}
		
	}
}