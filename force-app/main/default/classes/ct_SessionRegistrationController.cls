/**
 * @description       : Use this controller to show Sessions data in the Session Registration UI
 * @author            : Creation Admin
 * @last modified on  : 01-13-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-11-2020   Creation Admin   Initial Version
**/
global without sharing class ct_SessionRegistrationController {
    global static PageData data;

    @auraEnabled
    global static PageData getSessions(String recordId, String bySessionName){

        Map<Id, Session_Registration__c> mapSessionToRegStatus = new Map<Id, Session_Registration__c>();

        for(Session_Registration__c thisSessionReg : [SELECT Id, Status__c, Session__c FROM Session_Registration__c WHERE Event_Registration__c =:recordId]){
            mapSessionToRegStatus.put(thisSessionReg.Session__c, thisSessionReg);
        }

        // get event registration record first
        Event_Registration__c evtReg = [Select Id, Event__c From Event_Registration__c Where Id=: recordId];
        
        // init target data structure
        data = new PageData();
        data.eventId = evtReg.Event__c;
        data.listTracks = [SELECT Id, Name, Event__c FROM Track__c WHERE Event__c =: evtReg.Event__c];
        Id parentEventId = evtReg.Event__c;
        data.lstSessions = new List<SessionWrapper>();

        String queryString = 'Select Id, Session_Display_Name__c,Session_Abstract__c,Name, Session_Start_Date__c,Final_Booking_Date__c,Waiting_List_Enabled__c,Enable_Waiting_List_on_Closed__c,Registration_Closed__c, Room__c, Room__r.Name, Venue__c, Venue__r.Name, Start_Time__c, Track__c, End_Time__c,Event__c, Capacity_Session_Full__c From Session__c WHERE Id !=null';

        if(String.isNotBlank(recordId)){
          queryString = queryString + ' AND  Event__c =:parentEventId';
        }
        if(String.isNotBlank(bySessionName)){
          String bySessName =  '%'+bySessionName+'%';
          queryString = queryString + ' AND Session_Display_Name__c LIKE :bySessName';
        }
       
        queryString = queryString + ' ORDER BY Session_Start_Date__c, Start_Time__c ASC NULLS LAST';
        for(Session__c session : Database.query(queryString)) {
            
            Boolean registrationStatus = false;
            Id sessionRegId = null;
            Boolean isWaitingListEnabled = false;
            String sessionRegistrationStatus;
            Boolean isOnWaitingList = false;
            if(mapSessionToRegStatus.containsKey(session.Id)){
              registrationStatus = mapSessionToRegStatus.get(session.Id).Status__c == 'Registered' ? true : false;
              sessionRegId = mapSessionToRegStatus.get(session.Id).Id;
              isWaitingListEnabled = session.Waiting_List_Enabled__c;
              isOnWaitingList = mapSessionToRegStatus.get(session.Id).Status__c == 'Waiting List' && session.Waiting_List_Enabled__c ? true : false;
            }
            data.lstSessions.add(new SessionWrapper(session, false, registrationStatus, sessionRegId,isWaitingListEnabled, isOnWaitingList ));			
        }
       
        return data;
    }

    @AuraEnabled
    global static String createSessionReg(String jsonData, String evtRegId,  Boolean isRegistering, Boolean isWaitingListEnabled){
      Session_Registration__c sessionReg = new Session_Registration__c();
      SessionWrapper sessionwrpr;
     try{
        Event_Registration__c thisEvent = getEventRegistration(Id.valueOf(evtRegId));
          sessionwrpr = (SessionWrapper)JSON.deserialize(jsonData, SessionWrapper.class);              
          sessionReg.Id = sessionwrpr.sessionRegId;
          sessionReg.Event_Registration__c = evtRegId;
          sessionReg.QR_Code__c = thisEvent.QR_Code__c;
          
         if(String.isBlank(sessionwrpr.sessionRegId)){
             sessionReg.Session__c = sessionwrpr.session.Id;
         }
         if(isRegistering && !isWaitingListEnabled){
             sessionReg.Status__c = 'Registered';
         }else if(isRegistering && isWaitingListEnabled){
             sessionReg.Status__c = 'Waiting List';
         }else{
             sessionReg.Status__c = 'Cancelled';
         }
         
        upsert sessionReg;
        }   
        catch(exception ex){
            return ex.getMessage();
        }
        return String.valueOf(isRegistering)+'-'+sessionwrpr.session.Track__c;
    }

    global static Event_Registration__c getEventRegistration(Id eventRegistrationId){
      return [SELECT Id, Name, QR_Code__c FROM Event_Registration__c WHERE Id =: eventRegistrationId];
    }

    global class PageData {
        @auraEnabled global List<SessionWrapper> lstSessions {get; set;} 
        @auraEnabled global List<Track__c> listTracks {get;set;}
        @auraEnabled global String eventId {get; set;}
    }
    
    global class SessionWrapper {
        @auraEnabled global Session__c session {get; set;} 
        @auraEnabled global boolean selected {get; set;}
        @auraEnabled global boolean isRegistered {get; set;}
        @auraEnabled global boolean isSessionEnded {get; set;}
        @auraEnabled global String sessionDuration {get;set;}
        @auraEnabled global String sessionStartTime {get;set;}
        @auraEnabled global String sessionStartDate {get;set;}
        @auraEnabled global Id sessionRegId {get;set;}
        @auraEnabled global boolean isWaitingListEnabled {get;set;}
        @auraEnabled global boolean isOnWaitingList {get;set;}

        global SessionWrapper(Session__c session, boolean selected, Boolean registered, Id sessionRegId, boolean isWaitingListEnabled, boolean isOnWaitingList) {
            this.session = session;
            this.selected = selected;
            this.isRegistered = registered;
            this.sessionRegId = sessionRegId;
            this.isOnWaitingList = isOnWaitingList; 
            if(session != null && session.Start_Time__c != null && session.End_Time__c != null){
              Integer startMinutes = (session.Start_Time__c.hour() * 60)+session.Start_Time__c.minute();
              Integer endMinutes = (session.End_Time__c.hour() * 60)+session.End_Time__c.minute();
              this.sessionDuration = (endMinutes - startMinutes)+' min';
              this.sessionStartTime = convertTimeFormat(session.Start_Time__c);  
            }
            sessionStartDate = session.Session_Start_Date__c != null ? String.valueOf(session.Session_Start_Date__c) : null;            
            this.isSessionEnded = session.Registration_Closed__c == true && session.Waiting_List_Enabled__c == false ? true : false;
            this.isWaitingListEnabled = !this.isRegistered && !this.isOnWaitingList && session.Registration_Closed__c == true && session.Enable_Waiting_List_on_Closed__c == true && session.Capacity_Session_Full__c == 100 && session.Waiting_List_Enabled__c ? true : false;       
        }
    }
    //description: Convering time from 24 hours to 12 hours format
    global static String convertTimeFormat(Time startTime){
        Integer hours= startTime.hour();
        Integer minutes= startTime.minute();
        String AMORPM = hours >= 12 ? 'pm': 'am';
        if(hours >12){
           hours = math.mod(hours, 12); 
        }
        String thisMinutes = minutes>=10 ? String.valueOf(minutes):'0'+minutes;
        return hours + '.' + thisMinutes + AMORPM;
    }
}