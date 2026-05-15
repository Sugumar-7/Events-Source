/**
 * @description       : Trigger Handler class for Event Registration
 * @author            : Creation Admin
**/
global without sharing class ct_Event_RegistrationTriggerHandler {

  //Set to store Event Order Ids for which roll-up needs to be calculated 
  global static Set<Id> eventOrderIds                 = new Set<Id>();
  //Set to store Event Product Order Ids for which Quantity Allocated roll-up needs to be calculated 
  global static Set<Id> eventProductIds               = new Set<Id>();
  global static List<Event_Registration__c> eventReg  = new List<Event_Registration__c>();
  global static List<String> eventDetailsDataList     = new List<String>();
  global static Set<Id> eventIdsForRollUpcalculation  = new Set<Id>();
  global static Set<String> eventRegistrationIdsToSync    = new Set<String>();
  global static Set<Id> processEventOrderRollUp       = new Set<Id>();
  global static Set<Id> enquirerIds                   = new Set<Id>();
  global static Set<Id> contactIds                    = new Set<Id>();
  global static Set<Id> accountIds                    = new Set<Id>();
  global static Set<Id> eventIds                      = new Set<Id>();
  global static Set<String> eventRegistrationForCampaignMemberSync  = new Set<String>();
  global static Set<String> leadIdForCampaignMember             = new Set<String>();
  global static Set<String> contactIdForCampaignMember          = new Set<String>();
  global static Set<String> accountIdForCampaignMember          = new Set<String>();

  global static Map<Id, Contact> contactMap = new Map<Id, Contact>();
  global static Map<Id, Lead> enquirerMap   = new Map<Id, Lead>();
  global static Map<Id, Account> accountMap   = new Map<Id, Account>();

  global static Map<Id, Set<Id>> existingContactEventRegistrationMap = new  Map<Id, Set<Id>>();
  global static Map<Id, Set<Id>> existingLeadEventRegistrationMap    = new  Map<Id, Set<Id>>();
  global static Map<Id, Set<Id>> existingAccountEventRegistrationMap = new  Map<Id, Set<Id>>();

  /* SAREN 
  06/10/2025
  To control recursion for Event Registration Trigger*/
  //  private static Boolean isActive = true;

  //   global static void turnOff() {
  //       isActive = false;
  //   }

  //   global static void turnOn() {
  //       isActive = true;
  //   }

  //   global static Boolean isActive() {
  //       return isActive;
  //   }

  global static void turnOff() {
    ct_ProcessControl.turnOffRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Insert);
    ct_ProcessControl.turnOffRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Update);
  }

  /*******************************************************************************************************
  * @description Turns class on.
  * @return void
  ********************************************************************************************************/
  global static void turnOn() {
      ct_ProcessControl.resetRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Insert);
      ct_ProcessControl.resetRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Update);
  }




    global static void handleBeforeInsert(list<Event_Registration__c> newlist){
        

      if (!ct_ProcessControl.getRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_Before_Insert)){

        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT REGISTRATION BEFORE INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        //Loop to get The required Ids 
        for(Event_Registration__c thisEventRegistration : newlist){
          if(thisEventRegistration.Event__c != null){
            eventIds.add(thisEventRegistration.Event__c);
          }
          
          /*if(thisEventRegistration.Contact__c != null){
            contactIds.add(thisEventRegistration.Contact__c);
          }*/
          if(thisEventRegistration.Enquirer__c != null){
            enquirerIds.add(thisEventRegistration.Enquirer__c);
          }
          if(thisEventRegistration.Account_Name__c != null){
            accountIds.add(thisEventRegistration.Account_Name__c);
          }
        }

        /*if(!contactIds.isEmpty()){
          contactMap = ct_Event_RegistrationTriggerHelper.getContactMap(contactIds);
        }*/

        if(!enquirerIds.isEmpty()){
          enquirerMap = ct_Event_RegistrationTriggerHelper.getEnquirerMap(enquirerIds);
        }
        
        if(!accountIds.isEmpty()){
          accountMap = ct_Event_RegistrationTriggerHelper.getAccountMap(accountIds);
        }

        if(!contactIds.isEmpty() || !enquirerIds.isEmpty() || !accountIds.isEmpty()){
          //Method to get exisiting Lead or Contact
          //Method to get exisiting Lead or Contact or Account(30/10/2025)
          ct_Event_RegistrationTriggerHelper.getExistingLeadContactRegistration(enquirerIds, contactIds, accountIds, eventIds, existingContactEventRegistrationMap, existingLeadEventRegistrationMap, existingAccountEventRegistrationMap);
        }

        for(Event_Registration__c thisEventRegistration : (list<Event_Registration__c>)newlist){
          // method to get validate duplicate event registration records(Last Modified: 30/10/2025 with Person Account)
          ct_Event_RegistrationTriggerHelper.validateDuplicateEventRegistartion(existingContactEventRegistrationMap, existingLeadEventRegistrationMap, existingAccountEventRegistrationMap, thisEventRegistration);


          /*if(thisEventRegistration.Contact__c != null
            && !contactMap.isEmpty()
            && contactMap.containsKey(thisEventRegistration.Contact__c)){
              ct_Event_RegistrationTriggerHelper.processRegistrationDataFromContact(contactMap.get(thisEventRegistration.Contact__c), thisEventRegistration);
          }*/
          if(thisEventRegistration.Enquirer__c != null
          && !enquirerMap.isEmpty()
          && enquirerMap.containsKey(thisEventRegistration.Enquirer__c)){
            ct_Event_RegistrationTriggerHelper.processRegistrationDataFromLead(enquirerMap.get(thisEventRegistration.Enquirer__c), thisEventRegistration);
          }
          if(thisEventRegistration.Account_Name__c != null
          && !accountMap.isEmpty()
          && accountMap.containsKey(thisEventRegistration.Account_Name__c)){
            ct_Event_RegistrationTriggerHelper.processRegistrationDataFromAccount(accountMap.get(thisEventRegistration.Account_Name__c), thisEventRegistration);
          }
        }
              
        ct_ProcessControl.setRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_Before_Insert, true);

      }
    }

    global static void handleAfterInsert(list<Event_Registration__c> newlist){

      if (!ct_ProcessControl.getRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Insert)){
      
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT REGISTRATION AFTER INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        
        Set<Id> eventRegistrationIds = new Set<Id>();
        
        //Loop to get The required Ids 
        for(Event_Registration__c thisEventRegistration : newlist){
          if(thisEventRegistration.Registration_Type__c != ct_EventConstants.EVENT_REGISTRATION_TYPE_UNKNOWN_GUEST
            && ((thisEventRegistration.Enquirer__c == null && /*thisEventRegistration.Contact__c == null &&*/ thisEventRegistration.Account_Name__c == null))){
              Map<String,String> orderMap = new Map<String,String>();
              orderMap.put('recId', thisEventRegistration.Id);
              orderMap.put('firstName', thisEventRegistration.First_Name__c);
              orderMap.put('lastName', thisEventRegistration.Last_Name__c);
              orderMap.put('email', thisEventRegistration.Event_Email__c);
              String jsonStr = JSON.serialize(orderMap);
              eventDetailsDataList.add(jsonStr); 
          }

          //For Campaign Member Sync
          if(thisEventRegistration.Enquirer__c != null 
              /*|| thisEventRegistration.Contact__c != null*/
              || thisEventRegistration.Account_Name__c != null){
              eventRegistrationForCampaignMemberSync.add( String.valueOf(Id.valueOf(thisEventRegistration.Id)).substring(0, 15));
              if(thisEventRegistration.Enquirer__c != null){
                leadIdForCampaignMember.add(thisEventRegistration.Enquirer__c);
              }
              /*if(thisEventRegistration.Contact__c != null){
                contactIdForCampaignMember.add(thisEventRegistration.Contact__c);
              }*/
              if(thisEventRegistration.Account_Name__c != null){
                accountIdForCampaignMember.add(thisEventRegistration.Account_Name__c);
              }
            }

          if(thisEventRegistration.Event_Product__c != null){
            eventProductIds.add(thisEventRegistration.Event_Product__c);
          }
          if(thisEventRegistration.Event__c != null){
            eventIdsForRollUpcalculation.add(thisEventRegistration.Event__c);
          }
          if(thisEventRegistration.Event_Order__c != null
            && thisEventRegistration.QR_Code_URL__c != null){
            processEventOrderRollUp.add(thisEventRegistration.Event_Order__c);
          }
          
          eventRegistrationIds.add(thisEventRegistration.Id);
        }
        ct_ProcessControl.setRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Insert, true);
        
        //queueable job to update the event status
        //System.enqueueJob(new updateEventRegistrationStatusQueueable(eventRegistrationIds));
            /*String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 2); 
            String ss = String.valueOf(Datetime.now().second());
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            scheduleRegisteredStatus s = new scheduleRegisteredStatus(eventRegistrationIds); 
            System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);*/
            
        
        if(!eventDetailsDataList.isEmpty()){
          //Trigger the Web site submission platform event
          ct_Event_RegistrationTriggerHelper.triggerWebSiteSubmissionPlatformEvent(eventDetailsDataList);
        }
        
        handleAyncProcesses(eventProductIds,eventIdsForRollUpcalculation,processEventOrderRollUp,eventRegistrationForCampaignMemberSync); // saren
      }
    }

    global static void handleAfterUpdate(list<Event_Registration__c> newlist,  list<Event_Registration__c> oldlist){
    
      if(!ct_ProcessControl.getRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Update)){

        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT REGISTRATION AFTER UPDATE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
        Set<Id> leadIdConsentSync = new Set<Id>();
        Set<Id> contactIdConsentSync = new Set<Id>();
        Set<Id> accountIdConsentSync = new Set<Id>();

        Map<Id, Event_Registration__c> triggerOldMap = new Map<Id, Event_Registration__c>(oldlist);
        Map<Id, Event_Registration__c> triggerNewMap = new Map<Id, Event_Registration__c>(newlist);
      
        //Loop to get The required Ids 
        for(Event_Registration__c thisEventRegistration : newlist){
          if((thisEventRegistration.Registration_Type__c != ct_EventConstants.EVENT_REGISTRATION_TYPE_UNKNOWN_GUEST
          || thisEventRegistration.Registration_Type__c != triggerOldMap.get(thisEventRegistration.Id).Registration_Type__c)
            && (/*thisEventRegistration.Contact__c == null &&*/ thisEventRegistration.Enquirer__c == null && thisEventRegistration.Account_Name__c == null) 
            && (thisEventRegistration.First_Name__c != null && thisEventRegistration.Last_Name__c != null && thisEventRegistration.Event_Email__c != null)){
              Map<String,String> orderMap = new Map<String,String>();
              orderMap.put('recId', thisEventRegistration.Id);
              orderMap.put('firstName', thisEventRegistration.First_Name__c);
              orderMap.put('lastName', thisEventRegistration.Last_Name__c);
              orderMap.put('email', thisEventRegistration.Event_Email__c);
              
              String jsonStr = JSON.serialize(orderMap);
              eventDetailsDataList.add(jsonStr); 
            }
            
            if((thisEventRegistration.Enquirer__c != null && thisEventRegistration.Enquirer__c != triggerOldMap.get(thisEventRegistration.Id).Enquirer__c) 
              /*|| (thisEventRegistration.Contact__c != null && thisEventRegistration.Contact__c != triggerOldMap.get(thisEventRegistration.Id).Contact__c)*/
              || (thisEventRegistration.Account_Name__c != null && thisEventRegistration.Account_Name__c != triggerOldMap.get(thisEventRegistration.Id).Account_Name__c)){
                eventOrderIds.add(thisEventRegistration.Event_Order__c);
            }
            
            if((thisEventRegistration.Event_Product__c != triggerOldMap.get(thisEventRegistration.Id).Event_Product__c)
              ||
              (thisEventRegistration.Event_Registration_Status__c != triggerOldMap.get(thisEventRegistration.Id).Event_Registration_Status__c)){

              if(thisEventRegistration.Event_Product__c != null){
                eventProductIds.add(thisEventRegistration.Event_Product__c);
              }
              if(triggerOldMap.get(thisEventRegistration.Id).Event_Product__c != null){
                eventProductIds.add(triggerOldMap.get(thisEventRegistration.Id).Event_Product__c);
              }
            }

          //For Campaign Member Sync
          if((thisEventRegistration.Enquirer__c != null 
              && thisEventRegistration.Enquirer__c != triggerOldMap.get(thisEventRegistration.Id).Enquirer__c) 
              /*|| (thisEventRegistration.Contact__c != null 
                  && thisEventRegistration.Contact__c != triggerOldMap.get(thisEventRegistration.Id).Contact__c)*/
              || (thisEventRegistration.Account_Name__c != null
                  && thisEventRegistration.Account_Name__c != triggerOldMap.get(thisEventRegistration.Id).Account_Name__c)){
              
            eventRegistrationForCampaignMemberSync.add( String.valueOf(Id.valueOf(thisEventRegistration.Id)).substring(0, 15));

            if(thisEventRegistration.Enquirer__c != null){
              leadIdForCampaignMember.add(thisEventRegistration.Enquirer__c);
            }
            /*if(thisEventRegistration.Contact__c != null){
              contactIdForCampaignMember.add(thisEventRegistration.Contact__c);
            }*/
            if(thisEventRegistration.Account_Name__c != null){
              accountIdForCampaignMember.add(thisEventRegistration.Account_Name__c);
            }
          }

          if(thisEventRegistration.Event_Registration_Status__c != triggerOldMap.get(thisEventRegistration.Id).Event_Registration_Status__c
          || thisEventRegistration.Primary_Subject_Area_Interest__c != triggerOldMap.get(thisEventRegistration.Id).Primary_Subject_Area_Interest__c
          ){
            eventRegistrationIdsToSync.add( String.valueOf(Id.valueOf(thisEventRegistration.Id)).substring(0, 15));
            if(thisEventRegistration.Enquirer__c != null){
              leadIdConsentSync.add(thisEventRegistration.Enquirer__c);
            }
            /*if(thisEventRegistration.Contact__c != null){
              contactIdConsentSync.add(thisEventRegistration.Contact__c);
            }*/
            if(thisEventRegistration.Account_Name__c != null){
              accountIdConsentSync.add(thisEventRegistration.Account_Name__c);
            }
          }

          if(thisEventRegistration.Event_Order__c != null
            && thisEventRegistration.QR_Code_URL__c != null){
            processEventOrderRollUp.add(thisEventRegistration.Event_Order__c);
          }
        }

        for(Event_Registration__c thisEventRegistration : triggerNewMap.values()){
          if((thisEventRegistration.Event_Registration_Status__c != null 
            && thisEventRegistration.Event__c != null 
            && thisEventRegistration.Event_Registration_Status__c != triggerOldMap.get(thisEventRegistration.Id).Event_Registration_Status__c)
            || (thisEventRegistration.Event__c != triggerOldMap.get(thisEventRegistration.Id).Event__c)){
              //eventReg.add(thisEventRegistration);
              eventIdsForRollUpcalculation.add(thisEventRegistration.Event__c);
              if(thisEventRegistration.Event__c != triggerOldMap.get(thisEventRegistration.Id).Event__c){
                eventIdsForRollUpcalculation.add(triggerOldMap.get(thisEventRegistration.Id).Event__c);
              }
          }
        }


        ct_ProcessControl.setRecursionFlag(ct_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Update, true);

        if(!eventDetailsDataList.isEmpty()){
          ct_Event_RegistrationTriggerHelper.triggerWebSiteSubmissionPlatformEvent(eventDetailsDataList);
        }

        if(!eventOrderIds.isEmpty()){
          ct_Event_RegistrationTriggerHelper.updateOrderWithLeadOrContact(eventOrderIds);
        }
        if(!eventRegistrationIdsToSync.isEmpty()){
          ct_Event_RegistrationTriggerHelper.syncCampaignMemberWithEventRegistration(eventRegistrationIdsToSync, leadIdConsentSync, /*contactIdConsentSync,*/ accountIdConsentSync);
        }
      
        handleAyncProcesses(eventProductIds,eventIdsForRollUpcalculation,processEventOrderRollUp,eventRegistrationForCampaignMemberSync); // saren
      } 
    }

    global static void handleAfterDelete(list<Event_Registration__c> oldlist){
      System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT REGISTRATION AFTER DELETE TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

      //Loop to get The required Ids 
      for(Event_Registration__c thisEventRegistration : oldlist){
        if(thisEventRegistration.Event_Product__c != null){
          eventProductIds.add(thisEventRegistration.Event_Product__c);
        }

        if(thisEventRegistration.Event__c != null){
          eventIdsForRollUpcalculation.add(thisEventRegistration.Event__c);
        }
      }
    
      handleAyncProcesses(eventProductIds,eventIdsForRollUpcalculation,processEventOrderRollUp,eventRegistrationForCampaignMemberSync); // saren
    }


    global static void handleAyncProcesses(Set<Id> eventProductIds,Set<Id> eventIdsForRollUpcalculation,Set<Id> processEventOrderRollUp,Set<String> eventRegistrationForCampaignMemberSync){
    
      if(!eventProductIds.isEmpty() && !System.isFuture() && !System.isBatch()){
        //Used to update the Quantity allocated rollup
        ct_Event_RegistrationTriggerHelper.updateQuantityAllocated(eventProductIds);
      }
      if(!eventIdsForRollUpcalculation.isEmpty() && !System.isFuture() && !System.isBatch()){
        //
        ct_Event_RegistrationTriggerHelper.processEventRegistartionCountOnEvent(eventIdsForRollUpcalculation);
      }

      if(!processEventOrderRollUp.isEmpty() && !System.isFuture() && !System.isBatch()){
        ct_Event_RegistrationTriggerHelper.processEventRegistrationRollUp(processEventOrderRollUp);
      }
      
      if(!eventRegistrationForCampaignMemberSync.isEmpty()){
        ct_CampaignMemberEventReg_Sync_Queueable campaignMemberSyncQueueableJob = new ct_CampaignMemberEventReg_Sync_Queueable(eventRegistrationForCampaignMemberSync, contactIdForCampaignMember, leadIdForCampaignMember, accountIdForCampaignMember);
        ID jobID = System.enqueueJob(campaignMemberSyncQueueableJob);
      }
    }

}