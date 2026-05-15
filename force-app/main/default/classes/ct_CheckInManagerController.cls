/**
 * @description       : Using this class to implemented the Check In Manager functionality
 * @author            : Creation Admin
 * @last modified on  : 01-08-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-31-2020   Creation Admin   Initial Version
**/
global without sharing class ct_CheckInManagerController {

	global static Map<String, String> checkInStatusMap = new Map<String, String>{
		ct_EventConstants.EVENT_REGISTRATION_REGISTERED 			=> ct_EventConstants.EVENT_CHECK_IN_STATUS_REGISTERED, 
		ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN  		  => ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_IN,
		ct_EventConstants.EVENT_REGISTRATION_CHECKED_OUT  		=> ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_OUT,
		ct_EventConstants.EVENT_REGISTRATION_DID_NOT_ATTEND   => ct_EventConstants.EVENT_CHECK_IN_STATUS_DID_NOT_ATTEND};
		
	global static Set<String> checkInStatusKeySet = checkInStatusMap.keySet();

	global static Map<String, String> sessionRegCheckInStatusMap = new Map<String, String>{
		ct_EventConstants.SESSION_REGISTRATION_REGISTERED 			=> ct_EventConstants.EVENT_CHECK_IN_STATUS_REGISTERED, 
		ct_EventConstants.SESSION_REGISTRATION_CHECKED_IN  		  => ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_IN,
		ct_EventConstants.SESSION_REGISTRATION_CHECKED_OUT  		=> ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_OUT,
		ct_EventConstants.SESSION_REGISTRATION_DID_NOT_ATTEND   => ct_EventConstants.EVENT_CHECK_IN_STATUS_DID_NOT_ATTEND};

	global static Set<String> sessionRegCheckInStatusKeySet = sessionRegCheckInStatusMap.keySet();

	@AuraEnabled
  global static initialWrapper getInitialWrapper(){	
		try{
			initialWrapper thisInitialWrapper 										= new initialWrapper();
			thisInitialWrapper.eventOptions   										= getEventOptions();
			thisInitialWrapper.sessionOptions 										= getSessionOptions();
			return thisInitialWrapper;
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event Registration Check In Manager');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
	}
	
	global static List<PicklistEntryWrapper> getEventOptions(){
		List<PicklistEntryWrapper> thisEventOptions = new List<PicklistEntryWrapper>();
		thisEventOptions.add(new PicklistEntryWrapper('NONE', ''));
		for(Event__c thisEvent : [SELECT Id, Name, Web_Event_Name__c, Web_Event_Location__c, Event_Start_Date__c, Event_Status__c,
															Event_End_Date__c, Registration_Status__c
															FROM Event__c
															WHERE Event_Status__c =:ct_EventConstants.EVENT_STATUS_CHECK_IN_MANAGEMENT
															ORDER BY Name]){
			thisEventOptions.add(new PicklistEntryWrapper(thisEvent.Name, thisEvent.Id));
		}
		return thisEventOptions;
	}
    
	global static Map<String, List<PicklistEntryWrapper>>  getSessionOptions(){
		String timesStamp;
		Map<String, List<PicklistEntryWrapper>>  thisSessionOptions = new Map<String, List<PicklistEntryWrapper>> ();
		for(Session__c thisSession : [SELECT Id, Event__c, Name, Event__r.Event_Status__c, Start_Time__c,End_Time__c, Session_End_Date__c,Session_Start_Date__c
																		FROM Session__c 
																		WHERE Event__c != null
																		AND Event__r.Event_Status__c =:ct_EventConstants.EVENT_STATUS_CHECK_IN_MANAGEMENT
																		ORDER BY Name]){
			if(!thisSessionOptions.containsKey(String.valueOf(thisSession.Event__c))){
				thisSessionOptions.put(String.valueOf(thisSession.Event__c), new List<PicklistEntryWrapper>());
			}

			if(thisSession.Session_Start_Date__c != null && thisSession.Start_Time__c != null){
				timesStamp = ' ('+DateTime.newInstance(thisSession.Session_Start_Date__c, thisSession.Start_Time__c).format('HH:mm');
				if(thisSession.Session_End_Date__c != null && thisSession.End_Time__c != null){
					timesStamp = timesStamp + +' - ' + DateTime.newInstance(thisSession.Session_End_Date__c, thisSession.End_Time__c).format('HH:mm') + ' )';
				}
				else {
					timesStamp = timesStamp + ' )';
				}
			}
			thisSessionOptions.get(String.valueOf(thisSession.Event__c)).add(new PicklistEntryWrapper(thisSession.Name + timesStamp, thisSession.Id));
		}
		return thisSessionOptions;
	}

	@AuraEnabled
	global static Map<String, Integer> getDashBoardAggregrate(String eventId, String sessionId, Boolean isMainEntrance){
		if(isMainEntrance){
			return getEventRegistrationAggregrate(eventId);
		}
		else{
			return getSessionRegistrationAggregrate(eventId, sessionId);
		}
	}

	@AuraEnabled
	global static Map<String, Integer> getEventRegistrationAggregrate(String eventId){

		String queryString = 'SELECT COUNT(ID) numberOfEventReg, Event_Registration_Status__c eventStatus FROM Event_Registration__c WHERE Event_Registration_Status__c != null AND Event_Registration_Status__c IN :checkInStatusKeySet';

		if(!String.isEmpty(eventId)){
			queryString = queryString +' AND Event__c =: eventId AND Event__r.Event_Status__c = '+'\''+ct_EventConstants.EVENT_STATUS_CHECK_IN_MANAGEMENT+'\'';
		}

		queryString = queryString + ' GROUP BY Event_Registration_Status__c';
		Map<String, Integer> eventRegistrationAggregrate = new Map<String, Integer>();
	  for (AggregateResult thisAggregateResult : Database.query(queryString)) {

			eventRegistrationAggregrate.put(checkInStatusMap.get(String.valueOf(thisAggregateResult.get('eventStatus'))), (Integer) thisAggregateResult.get('numberOfEventReg'));								
		}
		return eventRegistrationAggregrate;
	}

	@AuraEnabled
	global static Map<String, Integer> getSessionRegistrationAggregrate(String eventId, String sessionId){

		String queryString = 'SELECT COUNT(ID) numberOfSessionReg, Status__c sessionRegStatus FROM Session_Registration__c WHERE Status__c != null AND Status__c IN :checkInStatusKeySet';

		if(!String.isEmpty(eventId)){
			queryString = queryString +' AND Event_Registration__r.Event__c =: eventId AND Event_Registration__r.Event__r.Event_Status__c = '+'\''+ct_EventConstants.EVENT_STATUS_CHECK_IN_MANAGEMENT+'\'';
		}

		if(!String.isEmpty(sessionId)){
			queryString = queryString +' AND Session__c = :sessionId';
		}

		queryString = queryString + ' GROUP BY Status__c';
		Map<String, Integer> get = new Map<String, Integer>();
	  for (AggregateResult thisAggregateResult : Database.query(queryString)) {

			get.put(sessionRegCheckInStatusMap.get(String.valueOf(thisAggregateResult.get('sessionRegStatus'))), (Integer) thisAggregateResult.get('numberOfSessionReg'));								
		}
		return get;
	}

	@AuraEnabled
	global static List<SObject> getRegistrationRecords(String nameFilter, String orderRefNumber, String ticketRefNumber, String eventRegEmail, String eventId, String sessionId, Boolean isMainEntrance, String mobilenumber){
		if(isMainEntrance){
			return getEventRegistrations(nameFilter, orderRefNumber, ticketRefNumber, eventRegEmail, eventId, mobilenumber); 
		}
		else{
			return getSessionRegistrations(nameFilter, orderRefNumber, ticketRefNumber, eventRegEmail, eventId, sessionId, mobilenumber);
		}
	}

	@AuraEnabled
	global static List<Event_Registration__c> getEventRegistrations(String nameFilter, String orderRefNumber, String ticketRefNumber, String eventRegEmail, String eventId, String mobilenumber){
		Boolean hasNameFilter;
		Boolean hasOrderRefNumberFilter;
		Boolean hasTicketRefFilter;
		Boolean hasEventRegEmailFilter;
		Boolean hasEventIdFilter;
		Boolean hasMobileNumberFilter;

		hasNameFilter           = String.isEmpty(nameFilter) ? false : true;
		hasOrderRefNumberFilter = String.isEmpty(orderRefNumber) ? false : true;
		hasTicketRefFilter      = String.isEmpty(ticketRefNumber) ? false : true;
		hasEventRegEmailFilter  = String.isEmpty(eventRegEmail) ? false : true;
		hasEventIdFilter        = String.isEmpty(eventId) ? false : true;
		hasMobileNumberFilter   = String.isEmpty(mobilenumber) ? false : true;

		String queryString = 'SELECT Id, Name,Registration_Type__c, Event_Registration_Status__c, Name__c, Event__c, Session__c, Event_Email__c, Event_Mobile__c, First_Name__c, Last_Name__c, Event_Order__r.Name FROM Event_Registration__c WHERE Name != null AND Event_Registration_Status__c IN :checkInStatusKeySet';
		
		if(hasNameFilter || hasOrderRefNumberFilter || hasTicketRefFilter || hasEventRegEmailFilter ||  hasEventIdFilter || hasMobileNumberFilter){
			queryString = queryString +' AND';
		}

		if(hasNameFilter){
			nameFilter 			= '%' + nameFilter + '%';
			queryString = queryString + ' Name__c LIKE :nameFilter';
			if(hasOrderRefNumberFilter || hasTicketRefFilter || hasEventRegEmailFilter ||  hasEventIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasOrderRefNumberFilter){
			orderRefNumber 	= '%' + orderRefNumber + '%';
			queryString = queryString +' Event_Order__r.Name LIKE :orderRefNumber';
			if(hasTicketRefFilter || hasEventRegEmailFilter ||  hasEventIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasTicketRefFilter){
			ticketRefNumber 	= '%' + ticketRefNumber + '%';
			queryString = queryString +' Name LIKE :ticketRefNumber';
			if(hasEventRegEmailFilter ||  hasEventIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasEventRegEmailFilter){
			eventRegEmail 	= '%' + eventRegEmail + '%';
			queryString = queryString +' Event_Email__c LIKE :eventRegEmail';
			if(hasEventIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasMobileNumberFilter){
			mobilenumber 	= '%' + mobilenumber + '%';
			queryString = queryString +' Event_Mobile__c LIKE :mobilenumber';

			if(hasEventIdFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasEventIdFilter){
			queryString = queryString +' Event__c =: eventId AND Event__r.Event_Status__c ='+'\''+ct_EventConstants.EVENT_STATUS_CHECK_IN_MANAGEMENT+'\'';
		}	

		queryString = queryString +' ORDER BY Last_Name__c ASC NULLS LAST';

		return Database.query(queryString);
	}

	@AuraEnabled
	global static List<Session_Registration__c> getSessionRegistrations(String nameFilter, String orderRefNumber, String ticketRefNumber, String eventRegEmail, String eventId, String sessionId, String mobilenumber){
		Boolean hasNameFilter;
		Boolean hasOrderRefNumberFilter;
		Boolean hasTicketRefFilter;
		Boolean hasEventRegEmailFilter;
		Boolean hasEventIdFilter;
		Boolean hasSessionIdFilter;
		Boolean hasMobileNumberFilter;
		

		hasNameFilter 					= String.isEmpty(nameFilter) ? false : true;
		hasOrderRefNumberFilter = String.isEmpty(orderRefNumber) ? false : true;
		hasTicketRefFilter 			= String.isEmpty(ticketRefNumber) ? false : true;
		hasEventRegEmailFilter 	= String.isEmpty(eventRegEmail) ? false : true;
		hasEventIdFilter 				= String.isEmpty(eventId) ? false : true;
		hasSessionIdFilter 			= String.isEmpty(sessionId) ? false : true;
		hasMobileNumberFilter   = String.isEmpty(mobilenumber) ? false : true;


		String queryString = 'SELECT Id, Event_Registration__c,Event_Registration__r.Name,  Event_Registration__r.Last_Name__c, Event_Registration__r.Registration_Type__c, Status__c, Event_Registration__r.Name__c, Event_Registration__r.Event__c, Session__c, Event_Registration__r.Event_Email__c, Event_Registration__r.Event_Registration_Status__c, Event_Registration__r.Event_Order__r.Name FROM Session_Registration__c WHERE Name != null AND Status__c IN :sessionRegCheckInStatusKeySet';
		
		if(hasNameFilter || hasOrderRefNumberFilter || hasTicketRefFilter || hasEventRegEmailFilter ||  hasEventIdFilter || hasSessionIdFilter || hasMobileNumberFilter){
			queryString = queryString +' AND';
		}

		if(hasNameFilter){
			nameFilter 			= '%' + nameFilter + '%';
			queryString = queryString + ' Event_Registration__r.Name__c LIKE :nameFilter';
			if(hasOrderRefNumberFilter || hasTicketRefFilter || hasEventRegEmailFilter ||  hasEventIdFilter || hasSessionIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasOrderRefNumberFilter){
			orderRefNumber 	= '%' + orderRefNumber + '%';
			queryString = queryString +' Event_Registration__r.Event_Order__r.Name LIKE :orderRefNumber';
			if(hasTicketRefFilter || hasEventRegEmailFilter ||  hasEventIdFilter || hasSessionIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasTicketRefFilter){
			ticketRefNumber 	= '%' + ticketRefNumber + '%';
			queryString = queryString +' Event_Registration__r.Name LIKE :ticketRefNumber';
			if(hasEventRegEmailFilter ||  hasEventIdFilter || hasSessionIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasEventRegEmailFilter){
			eventRegEmail 	= '%' + eventRegEmail + '%';
			queryString = queryString +' Event_Registration__r.Event_Email__c LIKE :eventRegEmail';
			if(hasEventIdFilter || hasSessionIdFilter || hasMobileNumberFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasEventIdFilter){
			queryString = queryString +' Event_Registration__r.Event__c =: eventId AND Event_Registration__r.Event__r.Event_Status__c ='+'\''+ct_EventConstants.EVENT_STATUS_CHECK_IN_MANAGEMENT+'\'';
			if(hasSessionIdFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasMobileNumberFilter){
			mobilenumber 	= '%' + mobilenumber + '%';
			queryString = queryString +' Event_Registration__r.Event_Mobile__c LIKE :mobilenumber';

			if(hasSessionIdFilter){
				queryString = queryString +' AND';
			}
		}

		if(hasSessionIdFilter){
			queryString = queryString +' Session__c = :sessionId';
		}

		queryString = queryString +' ORDER BY Event_Registration__r.Last_Name__c ASC NULLS LAST';

		
		return Database.query(queryString);
	}

	@AuraEnabled
	global static void updateEventRegistrationStatus(String eventRegId, String checkInStatus){
		Map<String, String> checkInStatusMap = new Map<String, String>{
																																		ct_EventConstants.EVENT_CHECK_IN_STATUS_REGISTERED => ct_EventConstants.EVENT_REGISTRATION_REGISTERED,
																																		ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_IN => ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN,
																																		ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_OUT => ct_EventConstants.EVENT_REGISTRATION_CHECKED_OUT,
																																		ct_EventConstants.EVENT_CHECK_IN_STATUS_DID_NOT_ATTEND => ct_EventConstants.EVENT_REGISTRATION_DID_NOT_ATTEND};
		try{
			if(checkInStatusMap.containsKey(checkInStatus)){
				Event_Registration__c thisEventRegistrationToUpdate = [SELECT Id, Event_Registration_Status__c FROM Event_Registration__c
																															WHERE Id =: eventRegId LIMIT 1];
				thisEventRegistrationToUpdate.Event_Registration_Status__c = checkInStatusMap.get(checkInStatus);
				update thisEventRegistrationToUpdate;
			}
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Event Registration Check In Manager');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
	}

	@AuraEnabled
	global static void updateSessionRegistrationStatus(String sessRegId, String checkInStatus){
		Map<String, String> checkInStatusMap = new Map<String, String>{
																								ct_EventConstants.EVENT_CHECK_IN_STATUS_REGISTERED => ct_EventConstants.SESSION_REGISTRATION_REGISTERED,
																								ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_IN => ct_EventConstants.SESSION_REGISTRATION_CHECKED_IN,
																								ct_EventConstants.EVENT_CHECK_IN_STATUS_CHECKED_OUT => ct_EventConstants.SESSION_REGISTRATION_CHECKED_OUT,
																								ct_EventConstants.EVENT_CHECK_IN_STATUS_DID_NOT_ATTEND => ct_EventConstants.SESSION_REGISTRATION_DID_NOT_ATTEND};
		try{
			if(checkInStatusMap.containsKey(checkInStatus)){
				Session_Registration__c thisSessionRegistrationToUpdate = [SELECT Id, Status__c, Event_Registration__c, Event_Registration__r.Event_Registration_Status__c FROM Session_Registration__c
																															WHERE Id =: sessRegId LIMIT 1];

				if(thisSessionRegistrationToUpdate.Event_Registration__c != null
				&& thisSessionRegistrationToUpdate.Event_Registration__r.Event_Registration_Status__c != null
				&& thisSessionRegistrationToUpdate.Event_Registration__r.Event_Registration_Status__c != ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN){

					Event_Registration__c thisEventRegistrationToUpdate = [SELECT Id, Event_Registration_Status__c FROM Event_Registration__c
																															WHERE Id =: thisSessionRegistrationToUpdate.Event_Registration__c LIMIT 1];
					thisEventRegistrationToUpdate.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN;
					update thisEventRegistrationToUpdate;
				}

				thisSessionRegistrationToUpdate.Status__c = checkInStatusMap.get(checkInStatus);
				update thisSessionRegistrationToUpdate;
			}
		}
		catch(Exception e){
			//Exception mechanism to log any exceptions occured during the dml operation
			ct_Logger.logMessage(e, 'Session Registration Check In Manager');
			throw new AuraHandledException('Error '+ e.getMessage());    
		}
	}
	
	@AuraEnabled
	global static List<Session_Registration__c> getSessionRegistrationRecords(String eventId, String sessionId, Boolean isMainEntrance){
		List<Session_Registration__c> sessionRegistrationRecords = new 	List<Session_Registration__c>();

		String queryString = 'SELECT Id, Name, Event_Registration__c,Event_Registration__r.Name, Event_Registration__r.Event_Registration_Status__c,First_Name__c, Last_Name__c, Event_Registration__r.Event_Email__c,Event_Registration__r.Event_Mobile__c,Event_Registration__r.Registration_Type__c,Session__c,Status__c FROM Session_Registration__c	WHERE Event_Registration__r.Event__c =:eventId';
		if(!isMainEntrance){
			queryString = queryString + ' AND Session__c =:sessionId';
		}
		
		for(Session_Registration__c thisSessionRegisration : Database.query(queryString)){
			sessionRegistrationRecords.add(thisSessionRegisration);
		}
		return sessionRegistrationRecords;
	}

	global class initialWrapper{
		@AuraEnabled
		global List<PicklistEntryWrapper> eventOptions                	{get;set;}
		@AuraEnabled
		global Map<String, List<PicklistEntryWrapper>> sessionOptions		{get;set;}
		@AuraEnabled
		global Map<String, Integer> eventRegistrationAggregrateResult 	{get;set;}
	}

	/**
	* Wrapper that contains Picklist Values
	*/
  global class PicklistEntryWrapper{
    //get set string to store lable of picklist entry
    @AuraEnabled
    global String label                  {get;set;}
    //get set string to store value of picklist entry
    @AuraEnabled
    global string value                  {get;set;}
    
    global PicklistEntryWrapper(String entryLabel,String entryValue){
      this.label    = entryLabel;
      this.value    = entryValue;
		}
	}

}