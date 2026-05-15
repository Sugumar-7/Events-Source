/**
 * @description       : Using to this controller class for Add the Event / Session in the user Calendar
 * @author            : Creation Admin
 * @last modified on  : 02-02-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   09-08-2020   Creation Admin   Initial Version
 * 2.0   2/2/2021     Creation Admin   updated the class to populate location with Street, City, state, country and Address 2
**/
global without sharing class CT_AddToCalendarController {
      /*
		* Description: Method to show the AddToCalendar functionality in the record if the record supports calendar functionality
	* */
    @AuraEnabled(cacheable=true)
    global static CT_Calendar getCalendar(String recordId) {
        if (String.isBlank(recordId)) {
            throw new CT_CalendarException('Add To Calendar - recordId is missing');
        }
        return getCalendarById(Id.valueOf(recordId));
    }    
    
    @TestVisible
    private static CT_Calendar getCalendarById(Id recordId) {
        CT_Calendar calendar;
        switch on recordId.getSobjectType().newSObject() {
            when Event__c event {
                event = fetchEventById(recordId);
                calendar = new CT_Calendar(event);
            } when Session__c session {
                session = fetchSessionById(recordId);
                calendar = new CT_Calendar(session);
            } when else {
                throw new CT_CalendarException('Add To Calendar - This object is not supported');
            }
        }
        return calendar;
    }
    /*
		* Description: Method to fetch the Event record details to add this as event in calendar
	* */
    @TestVisible
    private static Event__c fetchEventById(Id id) {
        return [SELECT Id, Name, Event_Description__c, Venue_City__c, Time_Zone__c,
        Event_Start_Date__c, Start_Time__c, Event_End_Date__c, End_Time__c,
        Venue_Street_Address_1__c, Venue_Street_Address_2__c , Venue_State__c,Venue_Postal_Code__c,Venue_Country__c
        FROM Event__c WHERE Id =: id];
    } 
     /*
		* Description: Method to fetch the Session record details to add this as event in calendar
	* */
    @TestVisible
    private static Session__c fetchSessionById(Id id) {
        return [SELECT Id, Name, Event__r.Event_Description__c, Event__r.Venue_City__c,
        Session_Start_Date__c, Session_End_Date__c, Start_Time__c, End_Time__c, Event__r.Time_Zone__c , Venue_City__c,Venue_Street_Address_1__c, Venue_Street_Address_2__c , Venue_State__c,Venue_Postal_Code__c,Venue_Country__c                
        FROM Session__c WHERE Id =: id];
    }

    global class CT_CalendarException extends Exception{}
    
    global class CT_Calendar {
        @AuraEnabled global String subject;
        @AuraEnabled global Datetime startDateTime;
        @AuraEnabled global Datetime endDateTime;
        @AuraEnabled global String description;
        @AuraEnabled global String location;
        @AuraEnabled global String timeZone;
        @AuraEnabled global String eventDuration;
        
        global CT_Calendar(Event__c event) {
           
            this.subject = event.Name;   
            if(event.Event_Start_Date__c != null && event.Start_Time__c != null){
                this.startDateTime = Datetime.newInstanceGMT(event.Event_Start_Date__c, event.Start_Time__c);
            }
            if(event.Event_End_Date__c != null && event.End_Time__c != null){
                this.endDateTime = Datetime.newInstanceGMT(event.Event_End_Date__c, event.End_Time__c);
            }
            this.timeZone = event.Time_Zone__c;
            this.description = event.Event_Description__c;
            // populate the location with Street, City, state, country and Address 2
            this.location ='';
            if(!String.isBlank(event.Venue_Street_Address_1__c)){this.location = this.location + event.Venue_Street_Address_1__c +',';}
            if(!String.isBlank(event.Venue_Street_Address_2__c)){this.location = this.location + event.Venue_Street_Address_2__c +',';}
            if(!String.isBlank(event.Venue_City__c)){this.location = this.location + event.Venue_City__c +',';}
            if(!String.isBlank(event.Venue_State__c)){this.location = this.location + event.Venue_State__c +',';}
            if(!String.isBlank(event.Venue_Postal_Code__c)){this.location = this.location + event.Venue_Postal_Code__c +',';}
            if(!String.isBlank(event.Venue_Country__c)){this.location = this.location + event.Venue_Country__c +',';}
            this.location = this.location.removeEnd(',');            
            this.eventDuration = getEventDuration(event.Start_Time__c, event.End_Time__c);
        }
         /*
		* Description: Method to assign the Event record details to the calendar
		* */
        global CT_Calendar(Session__c session) {
            this.subject = session.Name;
            if(session.Session_Start_Date__c != null && session.Start_Time__c != null){
              this.startDateTime = Datetime.newInstance(session.Session_Start_Date__c, session.Start_Time__c);
            }
            if(session.Session_Start_Date__c != null && session.End_Time__c != null){
              this.endDateTime = Datetime.newInstance(session.Session_Start_Date__c, session.End_Time__c);
            }
            this.timeZone = session.Event__r.Time_Zone__c;
            this.description = session.Event__r.Event_Description__c;
            this.location ='';
            if(!String.isBlank(session.Venue_Street_Address_1__c)){this.location = this.location + session.Venue_Street_Address_1__c +',';}
            if(!String.isBlank(session.Venue_Street_Address_2__c)){this.location = this.location + session.Venue_Street_Address_2__c +',';}
            if(!String.isBlank(session.Venue_City__c)){this.location = this.location + session.Venue_City__c +',';}
            if(!String.isBlank(session.Venue_State__c)){this.location = this.location + session.Venue_State__c +',';}
            if(!String.isBlank(session.Venue_Postal_Code__c)){this.location = this.location + session.Venue_Postal_Code__c +',';}
            if(!String.isBlank(session.Venue_Country__c)){this.location = this.location + session.Venue_Country__c +',';}
            this.location = this.location.removeEnd(',');
            this.eventDuration = getEventDuration(session.Start_Time__c, session.End_Time__c);
        }
		 /*
		* Description: Method to calulate the duration of the event /session
		* */
        global String getEventDuration(Time startTime, Time endTime){
          String totalDuration = '0000';
          if(startTime != null && endTime != null){
            String eventHours = String.valueOf(Math.abs(startTime.hour() - endTime.hour()));
            String totalHours = eventHours.length() == 1 ? '0'+eventHours : eventHours;
            String eventMinutes = String.valueOf(Math.abs(startTime.minute() - endTime.minute()));
            String totalMinutes = eventMinutes.length() == 1 ? '0'+eventMinutes : eventMinutes;
            totalDuration = totalHours+totalMinutes;
          }

          return totalDuration;
        }
    }
}