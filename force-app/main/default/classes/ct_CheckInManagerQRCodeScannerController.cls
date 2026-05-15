/**
 * @description       : Check In Manager QRCode Scanner LWC Controller
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 01-21-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   09-14-2020   Creation Admin   Initial Version
**/
global without sharing class ct_CheckInManagerQRCodeScannerController {
	
	/**
	* @description Method to get Event and Session configurations wrapper for check in Manager component
	* @param selectedEventId Event Id
	* @param currentSessionId Current location of configured by check in user
	* @param configuredSession Configured session by check in user
	* @return EventSessionDetailsWrapperInitialWrapper 
	**/
	@AuraEnabled
	global static EventSessionDetailsWrapperInitialWrapper getEventSessionDetailsWrapper(String selectedEventId, String currentSessionId, String configuredSession){
		try {
			Boolean isSelectedVar;
			List<String> configuredSessionIds = new List<String>();
			if(!String.isEmpty(configuredSession)){configuredSessionIds = configuredSession.split(',');}

			EventSessionDetailsWrapperInitialWrapper thisConfigWrapper = new EventSessionDetailsWrapperInitialWrapper();
			ct_CheckInManagerController.initialWrapper thisCheckInInitialWrapper = ct_CheckInManagerController.getInitialWrapper();

			List<EventSessionDetailsWrapper> thisEventOptions = new List<EventSessionDetailsWrapper>();
			for(ct_CheckInManagerController.PicklistEntryWrapper thiseventWrapper : thisCheckInInitialWrapper.eventOptions){
				isSelectedVar = (!String.isEmpty(selectedEventId) && thiseventWrapper.value == selectedEventId) ?  true : false;
				thisEventOptions.add(new EventSessionDetailsWrapper(thiseventWrapper.label, thiseventWrapper.value, isSelectedVar));
			}
			thisConfigWrapper.eventOptions = thisEventOptions;

			Map<String, List<EventSessionDetailsWrapper>>  thisSessionOptions = new Map<String, List<EventSessionDetailsWrapper>> ();

			for(String thisSessionOptionKey : thisCheckInInitialWrapper.sessionOptions.keySet()){

				thisSessionOptions.put(thisSessionOptionKey, new List<EventSessionDetailsWrapper>());

				for(ct_CheckInManagerController.PicklistEntryWrapper thisSessionWrapper : thisCheckInInitialWrapper.sessionOptions.get(thisSessionOptionKey)){
					EventSessionDetailsWrapper thisSessionOption = new EventSessionDetailsWrapper();
					thisSessionOption.label  										 = thisSessionWrapper.label;
					thisSessionOption.value  										 = thisSessionWrapper.value;
					thisSessionOption.isSelected								 = (!configuredSessionIds.isEmpty() && configuredSession.contains(thisSessionWrapper.value)) ?  true : false;
					thisSessionOption.isCurrentSession   				 = (!String.isEmpty(currentSessionId) && thisSessionWrapper.value == currentSessionId) ?  true : false;
					thisSessionOptions.get(thisSessionOptionKey).add(thisSessionOption);
				}
			}

			thisConfigWrapper.sessionOptions = thisSessionOptions;
			return thisConfigWrapper;
		} 
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event QR Scanner Desktop get User Configuration');
			throw new AuraHandledException('Error '+ e.getMessage());
		}	
	}

	/**
	* @description Method to get Event and Session configurations wrapper for check in Manager component
	* @param selectedEventId Event Id
	* @param currentSessionId Current location of configured by check in user
	* @param configuredSession Configured session by check in user
	* @return EventSessionDetailsWrapperInitialWrapper 
	**/
	@AuraEnabled
	global static EventSessionDetailsWrapperInitialWrapper getQRCodeScannerInitialWrapper(String selectedEventId, String currentSessionId, String configuredSession){
		try {
			Boolean isSelectedVar;
			List<String> configuredSessionIds = new List<String>();
			if(!String.isEmpty(configuredSession)){configuredSessionIds = configuredSession.split(',');}

			EventSessionDetailsWrapperInitialWrapper thisConfigWrapper = new EventSessionDetailsWrapperInitialWrapper();
			ct_CheckInManagerController.initialWrapper thisCheckInInitialWrapper = ct_CheckInManagerController.getInitialWrapper();

			List<EventSessionDetailsWrapper> thisEventOptions = new List<EventSessionDetailsWrapper>();
			for(ct_CheckInManagerController.PicklistEntryWrapper thiseventWrapper : thisCheckInInitialWrapper.eventOptions){
				isSelectedVar = (!String.isEmpty(selectedEventId) && thiseventWrapper.value == selectedEventId) ?  true : false;
				thisEventOptions.add(new EventSessionDetailsWrapper(thiseventWrapper.label, thiseventWrapper.value, isSelectedVar));
			}
			thisConfigWrapper.eventOptions = thisEventOptions;

			Map<String, List<EventSessionDetailsWrapper>>  thisSessionOptions = new Map<String, List<EventSessionDetailsWrapper>> ();

			for(String thisSessionOptionKey : thisCheckInInitialWrapper.sessionOptions.keySet()){

				thisSessionOptions.put(thisSessionOptionKey, new List<EventSessionDetailsWrapper>());

				for(ct_CheckInManagerController.PicklistEntryWrapper thisSessionWrapper : thisCheckInInitialWrapper.sessionOptions.get(thisSessionOptionKey)){
					EventSessionDetailsWrapper thisSessionOption = new EventSessionDetailsWrapper();
					thisSessionOption.label  										 = thisSessionWrapper.label;
					thisSessionOption.value  										 = thisSessionWrapper.value;
					thisSessionOption.isSelected								 = (!configuredSessionIds.isEmpty() && configuredSession.contains(thisSessionWrapper.value)) ?  true : false;
					thisSessionOption.isCurrentSession   				 = (!String.isEmpty(currentSessionId) && thisSessionWrapper.value == currentSessionId) ?  true : false;
					thisSessionOptions.get(thisSessionOptionKey).add(thisSessionOption);
				}
			}

			thisConfigWrapper.sessionOptions = thisSessionOptions;
			return thisConfigWrapper;
		} 
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event QR Scanner Get Event Session Options');
			throw new AuraHandledException('Error '+ e.getMessage());
		}	
	}

	/**
	* @description Method to get Event, Sessions details for Check In Manager / QR code scanner from user configurations for that user
	* @return InitialWrapper 
	**/
  @AuraEnabled
	global static InitialWrapper getInitialWrapper(){
		try {
			String timesStamp;
			InitialWrapper thisInitialWrapper = new InitialWrapper();
			//Get user configuration record based on current user
			List<QR_Scanner_User_Configuration__c> thisUserConfiguration = [SELECT Id, Name, User__c, Is_Main_Entrance__c, Configured_Sessions__c, Event__c, 
																																			Current_Session__c, Event__r.Name, Current_Session__r.Name,
																																			Current_Session__r.Start_Time__c,
																																			Current_Session__r.End_Time__c, 
																																			Current_Session__r.Session_End_Date__c,
																																			Current_Session__r.Session_Start_Date__c
																																			FROM QR_Scanner_User_Configuration__c
																																			WHERE User__c =: UserInfo.getUserId()
																																			LIMIT 1];

			thisInitialWrapper.hasExistingConfiguration = !thisUserConfiguration.isEmpty() ? true : false;
			//if has existing configuration, process the Initial Wrapper
			if(thisInitialWrapper.hasExistingConfiguration){
				thisInitialWrapper.userConfigRecordId         = thisUserConfiguration[0].Id;
				thisInitialWrapper.configuredEventId          = thisUserConfiguration[0].Event__c;
				thisInitialWrapper.currentSession 						= thisUserConfiguration[0].Current_Session__c;
				thisInitialWrapper.configuredEventName				= thisUserConfiguration[0].Event__r.Name;
				thisInitialWrapper.isMainEntrance							= thisUserConfiguration[0].Is_Main_Entrance__c;
				//Update the Session label with its Time for displaying in LWC Component
				if(thisUserConfiguration[0].Current_Session__r.Session_Start_Date__c != null && thisUserConfiguration[0].Current_Session__r.Start_Time__c != null){
					timesStamp = ' ('+DateTime.newInstance(thisUserConfiguration[0].Current_Session__r.Session_Start_Date__c, thisUserConfiguration[0].Current_Session__r.Start_Time__c).format('HH:mm');
					if(thisUserConfiguration[0].Current_Session__r.Session_End_Date__c != null && thisUserConfiguration[0].Current_Session__r.End_Time__c != null){
						timesStamp = timesStamp + +' - ' + DateTime.newInstance(thisUserConfiguration[0].Current_Session__r.Session_End_Date__c, thisUserConfiguration[0].Current_Session__r.End_Time__c).format('HH:mm') + ' )';
					}
					else {
						timesStamp = timesStamp + ' )';
					}
				}

				thisInitialWrapper.configuredSessionName = thisUserConfiguration[0].Current_Session__r.Name + timesStamp;
				if(!String.isEmpty(thisUserConfiguration[0].Configured_Sessions__c)){
					thisInitialWrapper.configuredSessions 			= thisUserConfiguration[0].Configured_Sessions__c.split(',');
				}
			}
			return thisInitialWrapper;
		} catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event QR Scanner Desktop get User Configuration');
			throw new AuraHandledException('Error '+ e.getMessage());
		}	
  }

	/**
	* @description Method to update the check in manager user configuration if changed by the user
	* @param userConfiguration 
	**/
  @AuraEnabled
	global static void updateSessionId(String userConfiguration){
		try{
			QR_Scanner_User_Configuration__c thisUserConfig = (QR_Scanner_User_Configuration__c)JSON.deserialize(userConfiguration, QR_Scanner_User_Configuration__c.class);
			thisUserConfig.Name = thisUserConfig.Name +' - '+ UserInfo.getName();
			upsert thisUserConfig;
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event Registration Session Configuration Update');
			throw new AuraHandledException('Error '+ e.getMessage());
		}	
  }

	/**
	* @description Method to update the Event registration / Session registration status from Check in manager
	* @param eventRegistrationId Event registration record Id
	* @param sessionId Session record ID
	* @param isMainEntrance Boolean to denote whether to update the Event registration or session registration
	* @return QRScannedResultWrapper 
	**/
  @AuraEnabled
	global static QRScannedResultWrapper updateEventRegistartionStatus(String eventRegistrationId, String sessionId, Boolean isMainEntrance){
		List<sObject> sobjectListToUpdate = new List<sObject>();
		QRScannedResultWrapper thisQRScannedResultWrapper = new QRScannedResultWrapper();
		Map<String, String> eventRegistartionStatusToUdpate = new Map<String, String>{
																													ct_EventConstants.EVENT_REGISTRATION_REGISTERED => ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN};

		Map<String, String> sessionRegistartionStatusToUdpate = new Map<String, String>{
																														ct_EventConstants.SESSION_REGISTRATION_REGISTERED => ct_EventConstants.SESSION_REGISTRATION_CHECKED_IN};
	try{
		List<Event_Registration__c> thisEventRegistration = [SELECT Id, Name, Event_Registration_Status__c, Event__c, Registration_Type__c, First_Name__c,
																												Last_Name__c, Event_Email__c,Event_Mobile__c, QR_Code__c
																												FROM Event_Registration__c
																												WHERE Id =:eventRegistrationId LIMIT 1];

		List<Session_Registration__c> thisSessionRegistration = [SELECT Id, Name, Status__c, First_Name__c, Last_Name__c, Event_Registration__c, Registration_Type__c
																															FROM Session_Registration__c
																															WHERE Event_Registration__c =:eventRegistrationId 
																															AND Session__c = :sessionId LIMIT 1];

		//If is Main Entrance update Event registration
		if(isMainEntrance){
			if(thisEventRegistration.isEmpty()){
				thisQRScannedResultWrapper.isCustomError = true;
				thisQRScannedResultWrapper.customErrorMessage = 'ERROR : No Event Registration Found';
			}
			else{
				thisQRScannedResultWrapper.eventRegistration = thisEventRegistration[0];
				//If Registration type is Unknown guest, then process the wrapper result to get the registration details
				if(thisEventRegistration[0].Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_GUEST
				&& (thisEventRegistration[0].First_Name__c == null || thisEventRegistration[0].Last_Name__c == null || thisEventRegistration[0].Event_Email__c == null)){
					thisQRScannedResultWrapper.recordIdToRedirect 	= thisEventRegistration[0].Id;
					thisQRScannedResultWrapper.recordActionName 		=  'edit';
					thisQRScannedResultWrapper.customSuccessMessage = 'Event Registration Status Updated Successfully';
				}
				else{
					thisQRScannedResultWrapper.recordIdToRedirect 	= thisEventRegistration[0].Id;
					thisQRScannedResultWrapper.recordActionName 		=  'view';
					thisQRScannedResultWrapper.customSuccessMessage = 'Event Registration Status Updated Successfully';
				}

				if(thisEventRegistration[0].Event_Registration_Status__c != null
						&& !eventRegistartionStatusToUdpate.isEmpty()
						&& eventRegistartionStatusToUdpate.containsKey(thisEventRegistration[0].Event_Registration_Status__c)){
							thisEventRegistration[0].Event_Registration_Status__c = eventRegistartionStatusToUdpate.get(thisEventRegistration[0].Event_Registration_Status__c);
							sobjectListToUpdate.add(thisEventRegistration[0]);
				}
				else if(thisEventRegistration[0].Event_Registration_Status__c == ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN){
					thisQRScannedResultWrapper.isCustomError = true;
					//If already check In throw error message
					thisQRScannedResultWrapper.customErrorMessage = 'ERROR : Event Registration already set to Checked / In';
				}
			}
		}
		else{
			if(!thisEventRegistration.isEmpty()
				&& thisEventRegistration[0].Event_Registration_Status__c != null
				&& thisEventRegistration[0].Event_Registration_Status__c != ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN){
					thisEventRegistration[0].Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN;
					sobjectListToUpdate.add(thisEventRegistration[0]);
			}
			
			thisQRScannedResultWrapper.eventRegistration = thisEventRegistration[0];
			if(thisSessionRegistration.isEmpty()
				&& !thisEventRegistration.isEmpty()){

				thisQRScannedResultWrapper.recordIdToRedirect 	= createSessionRegistration(sessionId, thisEventRegistration[0]);
				thisQRScannedResultWrapper.recordActionName 		=  'view';
				thisQRScannedResultWrapper.customSuccessMessage = 'Session Registration Created Successfully';
				
				List<Session_Registration__c> thisNewSessionRegistration = [SELECT Id, Name, Status__c, First_Name__c, Last_Name__c, Event_Registration__c, Registration_Type__c
																																	FROM Session_Registration__c
																																	WHERE Id = :thisQRScannedResultWrapper.recordIdToRedirect LIMIT 1];
				if(thisNewSessionRegistration != null && !thisNewSessionRegistration.isEmpty())		{
					thisQRScannedResultWrapper.sessionRegistration = thisNewSessionRegistration[0];
				}										
			}
			else{
				thisQRScannedResultWrapper.recordIdToRedirect 	= thisSessionRegistration[0].Id;
				thisQRScannedResultWrapper.recordActionName 		=  'view';
				thisQRScannedResultWrapper.customSuccessMessage = 'Session Registration Status Updated Successfully';

				if(thisSessionRegistration[0].Status__c != null
					&& !sessionRegistartionStatusToUdpate.isEmpty()
					&& sessionRegistartionStatusToUdpate.containsKey(thisSessionRegistration[0].Status__c)){
						thisSessionRegistration[0].Status__c = sessionRegistartionStatusToUdpate.get(thisSessionRegistration[0].Status__c);
						thisQRScannedResultWrapper.sessionRegistration = thisSessionRegistration[0];
						sobjectListToUpdate.add(thisSessionRegistration[0]);
				}
				else if(thisSessionRegistration[0].Status__c == ct_EventConstants.SESSION_REGISTRATION_CHECKED_IN){
					thisQRScannedResultWrapper.isCustomError = true;
					thisQRScannedResultWrapper.sessionRegistration = thisSessionRegistration[0];
					thisQRScannedResultWrapper.customErrorMessage = 'ERROR : Session Registration already set to Checked / In';
				}
			}
		}
			update sobjectListToUpdate;
			return thisQRScannedResultWrapper;
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event Registration Check In / Check Out');
			throw new AuraHandledException('Error '+ e.getMessage());
		}
	}


	/**
	* @description If the user enters the Unregistered Session then create new Session registration
	* @param sessionId Session record Id
	* @param thisEventReg Event Registration Id
	* @return String 
	**/
	global static String createSessionRegistration(String sessionId, Event_Registration__c thisEventReg){
		Session_Registration__c thisWalkInSessionReg 	= new Session_Registration__c();
		thisWalkInSessionReg.Event_Registration__c		= thisEventReg.Id;
		thisWalkInSessionReg.QR_Code__c								= thisEventReg.QR_Code__c;
		thisWalkInSessionReg.Session__c								= sessionId;
		//Update the Session walk in true, since the user entered the session without registering by them
		thisWalkInSessionReg.Session_Walk_In__c				= true;
		thisWalkInSessionReg.Status__c								= ct_EventConstants.SESSION_REGISTRATION_CHECKED_IN;
		insert thisWalkInSessionReg;
		return thisWalkInSessionReg.Id;
	}

	/**
	* @description Method to update the event registration record details if it is the registration type was Unknown guest and have provide the details
	* @param thisEventReg Event registration Details in JSON string
	* @return Event_Registration__c 
	**/
	@AuraEnabled
	global static Event_Registration__c updateEventResgistration(String thisEventReg){
		try{
			Event_Registration__c thisEventRegistration = (Event_Registration__c)JSON.deserialize(thisEventReg, Event_Registration__c.class);
			thisEventRegistration.Registration_Type__c = ct_EventConstants.EVENT_REGISTRATION_TYPE_SOMEONE_ELSE;
			update thisEventRegistration;
			return thisEventRegistration;
		}
			catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event Registration Update as Named Attendee');
			throw new AuraHandledException('Error '+ e.getMessage());
		}
	}

	/**
	* @description Method to get event and session record 
	* @param eventId Event record Id	
	* @param sessionId Session record Id
	* @return RecordWrapper 
	**/
	@AuraEnabled
	global static RecordWrapper  getEventRecord(String eventId, String sessionId){
		Event__c thisEvent = [SELECT Id, Name FROM Event__c WHERE Id =: eventId LIMIT 1];
		Session__c thisSession = new Session__c();
		if(String.isNotBlank(sessionId)){
			thisSession = [SELECT Id, Name FROM Session__c WHERE Id =: sessionId LIMIT 1];
		}
		RecordWrapper thisRecordWrapper = new RecordWrapper();
		thisRecordWrapper.eventRecord = thisEvent;
		thisRecordWrapper.sessionRecord = thisSession;
		return thisRecordWrapper;
	}

	//Wrapper class for storing Event / Session record 
	global class RecordWrapper{
		@AuraEnabled
		global Event__c eventRecord {get;set;}
    @AuraEnabled
		global Session__c sessionRecord {get;set;}
		RecordWrapper(){
			eventRecord 	= new Event__c();
			sessionRecord = new Session__c();
		}
	}

	//Initial wrapper for Check in Manager
	global class InitialWrapper{
		@AuraEnabled
		global Boolean hasExistingConfiguration {get;set;}
    @AuraEnabled
		global String currentSession {get;set;}
		@AuraEnabled
		global List<String> configuredSessions {get;set;}
		@AuraEnabled
		global Id userConfigRecordId {get;set;}
		@AuraEnabled
		global Id configuredEventId {get;set;}
		@AuraEnabled
		global String configuredEventName {get;set;}
		@AuraEnabled
		global String configuredSessionName {get;set;}
		@AuraEnabled
		global Boolean isMainEntrance {get;set;}
		InitialWrapper(){
			hasExistingConfiguration = false;
			configuredSessions = new List<String>();
		}
	}

	//Wrapper class for storing  Event and Session configuration 
	global class EventSessionDetailsWrapperInitialWrapper{
		@AuraEnabled
		global List<EventSessionDetailsWrapper> eventOptions                	{get;set;}
		@AuraEnabled
		global Map<String, List<EventSessionDetailsWrapper>> sessionOptions		{get;set;}
	}

	//Wrapper class returned after QR scan is done
	global class QRScannedResultWrapper{
		@AuraEnabled
		global String recordIdToRedirect		               	{get;set;}
		@AuraEnabled
		global String recordActionName		                	{get;set;}
		@AuraEnabled
		global String customErrorMessage     	             	{get;set;}
		@AuraEnabled
		global String customSuccessMessage     	           	{get;set;}
		@AuraEnabled
		global Boolean isCustomError        		           	{get;set;}
		@AuraEnabled
		global Event_Registration__c eventRegistration      {get;set;}
		@AuraEnabled
		global Session_Registration__c sessionRegistration  {get;set;}
	}

	/**
	* Wrapper that contains Picklist Values
	*/
  global class EventSessionDetailsWrapper{
    @AuraEnabled
    global String label                  {get;set;}
    @AuraEnabled
		global string value                  {get;set;}
		@AuraEnabled
		global Boolean isSelected             {get;set;}
		@AuraEnabled
    global Boolean isCurrentSession       {get;set;}
		
		global EventSessionDetailsWrapper(){
      
		}
    global EventSessionDetailsWrapper(String entryLabel, String entryValue, Boolean isSelect){
      this.label    	= entryLabel;
			this.value   	 	= entryValue;
			this.isSelected = isSelect;
		}
	}
}