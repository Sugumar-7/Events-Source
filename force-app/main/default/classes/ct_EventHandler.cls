/**
 * @File Name          : ct_EventHandler.cls
 * @Description        : Update Event with Event Registration URL's
 * @Author             : Creation Admin
 * @Last Modified By   : Creation Admin
 * @Last Modified On   : 11-24-2020
 * @Modification Log   : 
 * Ver   Date         Author           Modification
* 1.0   24-11-2020   Creation Admin   Initial Version
**/
global without sharing class ct_EventHandler {
    
    /**
     * description: update affected Event record with Event Registration URL field.
     */
    global static void updateEventwithRegistrationURL(Map<Id,Event__c> mapOfEvents){
        //List of affected Events
        List<Event__c> events = [Select id,Event_Registration_URL__c from Event__c where Id =:mapOfEvents.keyset()];
        List<Event__c> lstOfEventstoUpdate = new List<Event__c>();
        
        for(Event__c evt : events){
            //evt.Event_Registration_URL__c = System.Label.Event_Site_Base_URL + '/s/event-ticket-selection?id='+evt.id;
            //evt.Public_Event_Registration_URL__c = System.Label.Event_Site_Base_URL + '/s/event-ticket-selection?id='+evt.id+'&publiclURL=true';
            lstOfEventstoUpdate.add(evt);
        }
        if(lstOfEventstoUpdate.size()>0){
            //update affected Events.
            update lstOfEventstoUpdate;
        }
    }
}