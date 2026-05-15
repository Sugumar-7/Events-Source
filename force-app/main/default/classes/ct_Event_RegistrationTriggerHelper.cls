/**
* @description       : Use this class to process Lead, Contact, update quantity allocated and 
						sync the Event registration to Campaign when Event Registration upon creation and updation.
* @author            : Creation Admin
* @last modified on  : 07-05-2021
* @last modified by  : Rajesh Creation
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   08-21-2020   Creation Admin   Initial Version
**/
global without sharing class ct_Event_RegistrationTriggerHelper {
    
    /*global static Map<Id, Contact> getContactMap(Set<Id> contactIds){
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, 
                                                            FirstName,
                                                            LastName,
                                                            Event_Email__c,
                                                            Email,
                                                            Event_Mobile__c,
                                                            MobilePhone
                                                            FROM Contact 
                                                            WHERE Id IN: contactIds]);
        return contactMap;
    }*/
    
    global static Map<Id, Lead> getEnquirerMap(Set<Id> leadIds){
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, 
                                                   FirstName,
                                                   LastName,
                                                   Event_Email__c,
                                                   Email,
                                                   Event_Mobile__c,
                                                   MobilePhone
                                                   FROM Lead 
                                                   WHERE Id IN: leadIds]);
        return leadMap;
    }

   global static Map<Id, Account> getAccountMap(Set<Id> accountIds){
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, 
                                                   FirstName,
                                                   LastName,
                                                   Event_Email__pc,
                                                   PersonEmail,
                                                   Event_Mobile__pc,
                                                   PersonMobilePhone
                                                   FROM Account
                                                   WHERE Id IN: accountIds]);
        return accountMap;
    }
    
    //In below methos contactIds is queried so that is not commented but in all other functions it's commented
    global static void getExistingLeadContactRegistration(Set<Id> enquirerIds, Set<Id> contactIds, Set<Id> accountIds, Set<Id> eventIds, Map<Id, Set<Id>> contactEventRegistrationMap, 	Map<Id, Set<Id>> leadEventRegistrationMap, Map<Id, Set<Id>> AccountEventRegistrationMap){
        for(Event_Registration__c thisExistingRegistration : [SELECT Id, Event__c, Enquirer__c, Contact__c, Account_Name__c
                                                              FROM Event_Registration__c
                                                              WHERE (Enquirer__c != null OR Contact__c != null OR Account_Name__c != null)
                                                              AND (Enquirer__c IN :enquirerIds OR Contact__c IN :contactIds OR Account_Name__c IN :accountIds)
                                                              AND Event__c IN :eventIds]){
                                                                  if(thisExistingRegistration.Enquirer__c != null){
                                                                      if(leadEventRegistrationMap.isEmpty()
                                                                         || !leadEventRegistrationMap.containsKey(thisExistingRegistration.Enquirer__c)){
                                                                             leadEventRegistrationMap.put(thisExistingRegistration.Enquirer__c, new Set<Id>());
                                                                         }
                                                                      leadEventRegistrationMap.get(thisExistingRegistration.Enquirer__c).add(thisExistingRegistration.Event__c);		
                                                                  }					
                                                                  
                                                                  /*if(thisExistingRegistration.Contact__c != null){
                                                                      if(contactEventRegistrationMap.isEmpty()
                                                                         || !contactEventRegistrationMap.containsKey(thisExistingRegistration.Contact__c)){
                                                                             contactEventRegistrationMap.put(thisExistingRegistration.Contact__c, new Set<Id>());
                                                                         }
                                                                      contactEventRegistrationMap.get(thisExistingRegistration.Contact__c).add(thisExistingRegistration.Event__c);
                                                                  }*/

                                                                  if(thisExistingRegistration.Account_Name__c != null){
                                                                      if(AccountEventRegistrationMap.isEmpty()
                                                                         || !AccountEventRegistrationMap.containsKey(thisExistingRegistration.Account_Name__c)){
                                                                             AccountEventRegistrationMap.put(thisExistingRegistration.Account_Name__c, new Set<Id>());
                                                                         }
                                                                      AccountEventRegistrationMap.get(thisExistingRegistration.Account_Name__c).add(thisExistingRegistration.Event__c);
                                                                  }
                                                              }
    }
    
    global static void validateDuplicateEventRegistartion(Map<Id, Set<Id>> contactEventRegistrationMap, Map<Id, Set<Id>> leadEventRegistrationMap, Map<Id, Set<Id>> AccountEventRegistrationMap, Event_Registration__c thisEventRegistration){
        if(thisEventRegistration.Enquirer__c != null
           && !leadEventRegistrationMap.isEmpty()
           && leadEventRegistrationMap.containsKey(thisEventRegistration.Enquirer__c)
           && leadEventRegistrationMap.get(thisEventRegistration.Enquirer__c).contains(thisEventRegistration.Event__c)){
               thisEventRegistration.addError('There is already an Event Registration with same Lead for this Event');
           }
        
        /*else if(thisEventRegistration.Contact__c != null
                && !contactEventRegistrationMap.isEmpty()
                && contactEventRegistrationMap.containsKey(thisEventRegistration.Contact__c)
                && contactEventRegistrationMap.get(thisEventRegistration.Contact__c).contains(thisEventRegistration.Event__c)){
                    thisEventRegistration.addError('There is already an Event Registration with same Contact for this Event');
                }*/
        else if(thisEventRegistration.Account_Name__c != null
                && !AccountEventRegistrationMap.isEmpty()
                && AccountEventRegistrationMap.containsKey(thisEventRegistration.Account_Name__c)
                && AccountEventRegistrationMap.get(thisEventRegistration.Account_Name__c).contains(thisEventRegistration.Event__c)){
                    thisEventRegistration.addError('There is already an Event Registration with same Account for this Event');
        }
        
    }
    
    /*global static void processRegistrationDataFromContact(Contact thisContact, Event_Registration__c thisEventRegistration){
        thisEventRegistration.First_Name__c                = thisContact.FirstName;
        thisEventRegistration.Last_Name__c                 = thisContact.LastName;
        thisEventRegistration.Event_Email__c               = thisContact.Event_Email__c 	== null ? thisContact.Email : thisContact.Event_Email__c;
        thisEventRegistration.Event_Mobile__c              = thisContact.Event_Mobile__c == null ? thisContact.Event_Mobile__c : thisContact.MobilePhone;
        thisEventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_NEW;
        thisEventRegistration.Event_Registration_Source__c = ct_EventConstants.EVENT_REGISTRATION_SOURCE_MANUAL_CREATION;
    }*/
    
    global static void processRegistrationDataFromLead(Lead thisEnquirer, Event_Registration__c thisEventRegistration){
        thisEventRegistration.First_Name__c                = thisEnquirer.FirstName;
        thisEventRegistration.Last_Name__c                 = thisEnquirer.LastName;
        thisEventRegistration.Event_Email__c               = thisEnquirer.Event_Email__c 	== null ? thisEnquirer.Email : thisEnquirer.Event_Email__c;
        thisEventRegistration.Event_Mobile__c              = thisEnquirer.Event_Mobile__c == null ? thisEnquirer.Event_Mobile__c : thisEnquirer.MobilePhone;
        thisEventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_NEW;
        thisEventRegistration.Event_Registration_Source__c = ct_EventConstants.EVENT_REGISTRATION_SOURCE_MANUAL_CREATION;
    }

    global static void processRegistrationDataFromAccount(Account thisAccount, Event_Registration__c thisEventRegistration){
        thisEventRegistration.First_Name__c                = thisAccount.FirstName;
        thisEventRegistration.Last_Name__c                 = thisAccount.LastName;
        thisEventRegistration.Event_Email__c               = thisAccount.Event_Email__pc 	== null ? thisAccount.PersonEmail : thisAccount.Event_Email__pc;
        thisEventRegistration.Event_Mobile__c              = thisAccount.Event_Mobile__pc == null ? thisAccount.PersonMobilePhone : thisAccount.Event_Mobile__pc;
        thisEventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_NEW;
        thisEventRegistration.Event_Registration_Source__c = ct_EventConstants.EVENT_REGISTRATION_SOURCE_MANUAL_CREATION;
    }
    
    global static void triggerWebSiteSubmissionPlatformEvent(List<String> eventDetailsDataList){
        //Create instance of Web Site Submission Event to fire the Platform Event
        Web_Site_Submission_Event__e eventObject 	= new Web_Site_Submission_Event__e();
        eventObject.Web_Site_Submission_Record__c = '{"data": '+JSON.serialize(eventDetailsDataList)+'}';
        eventObject.Source__c                     = ct_EventConstants.WEB_SUBMISSION_SOURCE_EVENT;
        
        //Publish the event after adding web form details
        Database.SaveResult result = EventBus.publish(eventObject);
        if (result.isSuccess()) {
            System.debug('Successfully published event.');
        } 
        else {
            for(Database.Error err : result.getErrors()) {
                System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
            }
        }      
    }
    
    global static void updateOrderWithLeadOrContact(Set<Id> ordIds){
        List<String> eventDetailsDataList = new List<String>();
        List<Event_Order__c> lstOrdtoUpdate = new List<Event_Order__c>();
        List<Event_Registration__c> lstofChildRegistrations = new List<Event_Registration__c>();
        Boolean hasMyselfRegistration = false;
        
        Map<Id, Event_Order__c> mapOfEvtOrders = new Map<Id, Event_Order__c>([Select Id, First_Name__c,Last_Name__c,Email__c, Event__r.Object_for_New_Attendees__c, Event__r.Record_Type_for_New_Attendees__c, (Select Id,Name__c,Event_Order__c, Registration_Type__c, Enquirer__c,Contact__c, Account_Name__c From Event_Registrations__r)  From Event_Order__c Where Id =: ordIds AND (Lead__c = null OR Contact__c = null OR Account__c = null) ]);
        for(Event_Order__c evtOrd : mapOfEvtOrders.values()){
            hasMyselfRegistration = false;
            if(!evtOrd.Event_Registrations__r.isEmpty()){
                for(Event_Registration__c evtReg : evtOrd.Event_Registrations__r){
                    if(evtReg.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
                        if(evtReg.Enquirer__c != null){
                            evtOrd.Lead__c =  evtReg.Enquirer__c;
                        }
                        /*else if(evtReg.Contact__c != null){
                            evtOrd.Contact__c = evtReg.Contact__c;
                        }*/

                        else if(evtReg.Account_Name__c != null){
                            evtOrd.Account__c = evtReg.Account_Name__c;
                        }
                        
                        lstOrdtoUpdate.add(evtOrd);
                        hasMyselfRegistration = true;
                        break;
                    }
                }
            }
            if(!hasMyselfRegistration){
                Map<String,String> orderMap = new Map<String,String>();
                orderMap.put('recId', evtOrd.Id);
                orderMap.put('firstName', evtOrd.First_Name__c);
                orderMap.put('lastName', evtOrd.Last_Name__c);
                orderMap.put('email', evtOrd.Email__c);
                
                String jsonStr = JSON.serialize(orderMap);
                eventDetailsDataList.add(jsonStr);
            }
        }
               
        if(!lstOrdtoUpdate.isEmpty()){
            try{
                update lstOrdtoUpdate;
            }
            catch(Exception e){
                ct_Logger.logMessage(e, 'Update Order With Lead Or Contact');
                throw e;
            }
        }
        
        if(!eventDetailsDataList.isEmpty()){
            ct_Event_RegistrationTriggerHelper.triggerWebSiteSubmissionPlatformEvent(eventDetailsDataList);
        }
    }
    
    @future
    global static void updateQuantityAllocated(Set<Id> eventProductIds){
        Map<Id, Event_Product__c> eventProductToUpdate = new Map<Id, Event_Product__c>();
        
        for(Event_Product__c thisEventProduct : [SELECT Id, Quantity_Allocated__c
                                                    FROM Event_Product__c
                                                    WHERE Id IN :eventProductIds]){
            thisEventProduct.Quantity_Allocated__c = 0;
            eventProductToUpdate.put(thisEventProduct.Id, thisEventProduct);
        }
        
        AggregateResult[] groupedResultsforRegistered = [SELECT COUNT(Id)numberofRegistration, Event_Product__c 
                                                         FROM Event_Registration__c 
                                                         WHERE Event_Product__c IN :eventProductIds 
                                                         AND Event_Registration_Status__c != null
                                                         AND Event_Registration_Status__c NOT IN (:ct_EventConstants.EVENT_REGISTRATION_CANCELLED, :ct_EventConstants.EVENT_REGISTRATION_DECLINED) 
                                                         GROUP BY Event_Product__c];
        
        for(AggregateResult thisAggregateResult:[SELECT COUNT(Id)numberofRegistration, Event_Product__c 
                                                 FROM Event_Registration__c 
                                                 WHERE Event_Product__c IN :eventProductIds 
                                                 AND Event_Registration_Status__c != null
                                                 AND Event_Registration_Status__c NOT IN (:ct_EventConstants.EVENT_REGISTRATION_CANCELLED, :ct_EventConstants.EVENT_REGISTRATION_DECLINED) 
                                                 GROUP BY Event_Product__c]){
                                                     if(eventProductToUpdate.containsKey((ID)thisAggregateResult.get('Event_Product__c'))){
                                                         eventProductToUpdate.get((ID)thisAggregateResult.get('Event_Product__c')).Quantity_Allocated__c = (INTEGER)thisAggregateResult.get('numberofRegistration');
                                                         system.debug('eventProductToUpdate>>> '+eventProductToUpdate);
                                                         system.debug('Quantity>>> '+(INTEGER)thisAggregateResult.get('numberofRegistration'));
                                                     }
                                                 }
        
        if(!eventProductToUpdate.values().isEmpty()){
            try{
                update eventProductToUpdate.values();
            }
            catch(Exception e){
                ct_Logger.logMessage(e, 'Event Product - Quantity Allocated Calculation (Group + Individual)');
            }
        }
    }
    
    global static void syncCampaignMemberWithEventRegistration(Set<String> eventRegistrationIds, Set<Id> enquirerIds, /*Set<Id> contactIds,*/ Set<Id> accountIds){
        try{
            List<SObject> sobjectListToUpdate = new List<SObject>();
            Map<Id, Lead> leadMap       = new Map<Id, Lead>();
            //Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Map<Id, Account> accountMap = new Map<Id, Account>();

            Set<Id> eventQuestionSet = new Set<Id>();
            Map<Id, Set<String>> questionSetToAddressQuestionMap = new Map<Id, Set<String>>();
            
            if(!enquirerIds.isEmpty()){
                leadMap = getEnquirerMap(enquirerIds);
            }
            
            /*if(!contactIds.isEmpty()){
                contactMap = getContactMap(contactIds);
            }*/

            if(!accountIds.isEmpty()){
                accountMap = getAccountMap(accountIds);
            }
            
            
            Map<Id, CampaignMember> eventRegistrationIdToCampaignPayloadMap = new Map<Id, CampaignMember>();
            for(Web_Site_Submission__c thisWebSiteSubmission : [SELECT Id,
                                                                Name,
                                                                Payload__c
                                                                FROM Web_Site_Submission__c
                                                                WHERE Name IN:eventRegistrationIds]){
                                                                    if(String.isNotBlank(thisWebSiteSubmission.Payload__c) 
                                                                       && !eventRegistrationIdToCampaignPayloadMap.containsKey(Id.valueOf(thisWebSiteSubmission.Name))){
                                                                           CampaignMember thisCampaignMemberPayload = (CampaignMember)JSON.deserialize(thisWebSiteSubmission.Payload__c, CampaignMember.class);
                                                                           eventRegistrationIdToCampaignPayloadMap.put(Id.valueOf(thisWebSiteSubmission.Name), thisCampaignMemberPayload);
                                                                       }					
                                                                }
            
            Map<Id, Event_Registration__c> eventRegistrationMap = new Map<Id, Event_Registration__c>(
                [SELECT Id,
                 First_Name__c, 
                 Last_Name__c,
                 Event__c, 
                 Event__r.Campaign__c, 
                 Event__r.CM_ER_Auto_Sync__c,  
                 Event__r.Event_Reg_New_Status__c,
                 Event__r.Event_Reg_Invited_Status__c,
                 Event__r.Event_Reg_Registered_Status__c,
                 Event__r.Event_Reg_Did_Not_Attend_Status__c,
                 Event__r.Event_Reg_Declined_Status__c,
                 Event__r.Event_Reg_Checked_Out_Status__c,
                 Event__r.Event_Reg_Checked_In_Status__c,
                 Event__r.Event_Reg_Cancelled_Status__c,
                 Event_Email__c, 
                 Contact__c,
                 Enquirer__c,
                 Object_for_New_Attendees__c, 
                 Record_Type_for_New_Attendees__c,
                 Event_Registration_Status__c,
                 Primary_Subject_Area_Interest__c,
                 Street__c,
                 City__c,
                 State_County__c,
                 Zip_Postal_Code__c,
                 Country__c,
                 Country_of_Residence__c,
                 Address_Line_2__c,
                 Event_Order__c,
                 Event_Order__r.Consent_Given__c,
                 Event_Order__r.Statement_Used__c,
                 Event_Product__c,
                 Registration_Type__c,
                 Event_Product__r.Event_Question_Set__c
                 FROM Event_Registration__c 
                 WHERE Id IN:eventRegistrationIds]);
            
            for(Event_Registration__c thisEventRegistration : eventRegistrationMap.values()){
                if(thisEventRegistration.Event_Product__c != null
                   && thisEventRegistration.Event_Product__r.Event_Question_Set__c != null){
                       eventQuestionSet.add(thisEventRegistration.Event_Product__r.Event_Question_Set__c);
                   }
            }
            
            if(!eventQuestionSet.isEmpty()){
                questionSetToAddressQuestionMap = getAddressQuestionFromQuestionSet(eventQuestionSet);
            }
            
            List<CampaignMember> campaignMemberListToUpdate = new List<CampaignMember>();
            
            for(CampaignMember thisCampaignMember : [SELECT Id,
                                                     Event_Registration__c,
                                                     Status
                                                     FROM CampaignMember
                                                     WHERE Event_Registration__c IN:eventRegistrationMap.keySet()]){
                                                         
                                                         if(!eventRegistrationIdToCampaignPayloadMap.isEmpty()
                                                            && eventRegistrationIdToCampaignPayloadMap.containsKey(Id.valueOf(thisCampaignMember.Event_Registration__c))){
                                                                
                                                                Map<String, Object> fieldsToValue = eventRegistrationIdToCampaignPayloadMap.get(Id.valueOf(thisCampaignMember.Event_Registration__c)).getPopulatedFieldsAsMap();
                                                                for(String fieldAPIName : fieldsToValue.keyset()){
                                                                    thisCampaignMember.put(fieldAPIName, fieldsToValue.get(fieldAPIName));
                                                                }
                                                            }
                                                         
                                                         if(!eventRegistrationMap.isEmpty()
                                                            && eventRegistrationMap.containsKey(thisCampaignMember.Event_Registration__c)){
                                                                ct_Campaign_MemberTriggerHelper.processCampaignMemberStatusFromEventRegistrationStatus(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c), thisCampaignMember);
                                                                campaignMemberListToUpdate.add(thisCampaignMember);
                                                                
                                                                if(!leadMap.isEmpty()
                                                                   && eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Enquirer__c != null
                                                                   && leadMap.containsKey(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Enquirer__c)){
                                                                       processLeadConsentAndAddress(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c), leadMap.get(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Enquirer__c), questionSetToAddressQuestionMap);
                                                                       sobjectListToUpdate.add(leadMap.get(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Enquirer__c));
                                                                   }
                                                                
                                                                /*if(!contactMap.isEmpty()
                                                                   && eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Contact__c != null
                                                                   && contactMap.containsKey(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Contact__c)){
                                                                       processContactConsentAndAddress(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c), contactMap.get(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Contact__c), questionSetToAddressQuestionMap);
                                                                       sobjectListToUpdate.add(contactMap.get(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Contact__c));
                                                                }*/

                                                                if(!accountMap.isEmpty()
                                                                   && eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Account_Name__c != null
                                                                   && accountMap.containsKey(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Account_Name__c)){
                                                                       //processAccountConsentAndAddress(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c), accountMap.get(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Account_Name__c), questionSetToAddressQuestionMap);
                                                                       //sobjectListToUpdate.add(accountMap.get(eventRegistrationMap.get(thisCampaignMember.Event_Registration__c).Account_Name__c));
                                                                }
                                                            }
                                                         
                                                         
                                                     }
            if(!campaignMemberListToUpdate.isEmpty()){
                ct_CampaignMemberTriggerHandler.turnOff();
                update campaignMemberListToUpdate;
            }
            if(!sobjectListToUpdate.isEmpty()){
                update sobjectListToUpdate;
            }
        }
        catch(Exception e){
            //Exception mechanism to log any exceptions occured during the dml operation
            ct_Logger.logMessage(e, 'Campaign Member Status Sync From Event Registration');
        }
    }
    
    global static void processLeadConsentAndAddress(Event_Registration__c thisEventRegistration, Lead thisLead, Map<Id, Set<String>> questionSetToAddressQuestionMap){
               
        //ct_Event_RegistrationTriggerHelper.processLeadContactConsentAndAddress(thisEventRegistration, thisLead, questionSetToAddressQuestionMap);
        
        if(thisEventRegistration.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
            thisLead.Latest_Consent_Change_Campaign__c = thisEventRegistration.Event__r.Campaign__c;
            if(thisEventRegistration.Event_Order__r.Consent_Given__c != null){
                //ct_LeadContactAsRegistrantsAttendees.populateLeadConsentChange(thisLead, thisEventRegistration.Event_Order__r.Consent_Given__c, thisEventRegistration.Event_Order__r.Statement_Used__c);
            }
        }
        
    }
    
    /*global static void processContactConsentAndAddress(Event_Registration__c thisEventRegistration, Contact thisContact, Map<Id, Set<String>> questionSetToAddressQuestionMap){
       
        //ct_Event_RegistrationTriggerHelper.processLeadContactConsentAndAddress(thisEventRegistration, thisContact, questionSetToAddressQuestionMap);
        
        if(thisEventRegistration.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
            thisContact.Latest_Consent_Change_Campaign__c = thisEventRegistration.Event__r.Campaign__c;
            if(thisEventRegistration.Event_Order__r.Consent_Given__c != null){
                //ct_LeadContactAsRegistrantsAttendees.populateContactConsentChange(thisContact, thisEventRegistration.Event_Order__r.Consent_Given__c, thisEventRegistration.Event_Order__r.Statement_Used__c);
            }
        } 
    }*/ 

    global static void processAccountConsentAndAddress(Event_Registration__c thisEventRegistration, Account thisAccount, Map<Id, Set<String>> questionSetToAddressQuestionMap){
        //ct_Event_RegistrationTriggerHelper.processLeadContactConsentAndAddress(thisEventRegistration, thisAccount, questionSetToAddressQuestionMap);
         if(thisEventRegistration.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
            thisAccount.Latest_Consent_Change_Campaign__pc = thisEventRegistration.Event__r.Campaign__c;
            if(thisEventRegistration.Event_Order__r.Consent_Given__c != null){
                //ct_LeadContactAsRegistrantsAttendees.populateAccountConsentChange(thisAccount, thisEventRegistration.Event_Order__r.Consent_Given__c, thisEventRegistration.Event_Order__r.Statement_Used__c);
            }
        } 
    }
    
    @future
    global static void processEventRegistartionCountOnEvent(Set<Id> eventIds){
        Map<Id, Event__c> eventMapToUpdate = new Map<Id,Event__c>();
        Id eventId;
        String eventCustomRollupField;
        try{
            for(Event__c thisEvent : [SELECT Id,
                                      Invited__c,
                                      Attending_Checked_Out__c,
                                      Did_Not_Attend__c,
                                      Declined__c,
                                      Cancelled__c, 
                                      No_Event_Registrations_ex_Guest__c
                                      FROM Event__c
                                      WHERE Id IN:eventIds]){
                                          
                                          thisEvent.Invited__c								= 0;
                                          thisEvent.Attending_Checked_Out__c	= 0;
                                          thisEvent.Did_Not_Attend__c					= 0;
                                          thisEvent.Declined__c								= 0;
                                          thisEvent.Cancelled__c							= 0;
                                          thisEvent.No_Event_Registrations_ex_Guest__c    = 0;                                               
                                          eventMapToUpdate.put(thisEvent.Id, thisEvent);
                                      }
            
            Map<String, String> eventRegistrationStatusToEventFieldMap = new Map<String, String>{
                ct_EventConstants.EVENT_REGISTRATION_INVITED 				=> 'Invited__c',
                    ct_EventConstants.EVENT_REGISTRATION_CHECKED_OUT 		=> 'Attending_Checked_Out__c',
                    ct_EventConstants.EVENT_REGISTRATION_DID_NOT_ATTEND => 'Did_Not_Attend__c',
                    ct_EventConstants.EVENT_REGISTRATION_DECLINED 			=> 'Declined__c',
                    ct_EventConstants.EVENT_REGISTRATION_CANCELLED 			=> 'Cancelled__c'};
                        
                        for(AggregateResult thisAggregrateResult : [SELECT COUNT(Id) totalRecords, Event_Registration_Status__c eventRegistrationStatus, Event__c 
                                                                    FROM Event_Registration__c WHERE Event__c IN :eventIds 
                                                                    AND Event_Registration_Status__c IN :eventRegistrationStatusToEventFieldMap.keySet()
                                                                    GROUP BY Event_Registration_Status__c, Event__c]){
                                                                        
                                                                        eventId 								=	(Id)thisAggregrateResult.get('Event__c');	
                                                                        eventCustomRollupField 	= eventRegistrationStatusToEventFieldMap.get((String)thisAggregrateResult.get('eventRegistrationStatus'));
                                                                        if(!eventMapToUpdate.isEmpty()
                                                                           && eventMapToUpdate.containsKey(eventId)){
                                                                               eventMapToUpdate.get(eventId).put(eventCustomRollupField, (Integer)thisAggregrateResult.get('totalRecords'));
                                                                           }																					
                                                                    }
            for(AggregateResult thisAggregrateResult :[Select COUNT(Id) totalRecords, Event__c 
                                                       FROM Event_Registration__c WHERE Event__c IN :eventIds 
                                                       AND Registration_Type__c !=: ct_EventConstants.EVENT_REGISTRATION_TYPE_UNKNOWN_GUEST
                                                       GROUP BY Event__c]){
                                                           
                                                           eventId 								=	(Id)thisAggregrateResult.get('Event__c'); 
                                                           if(!eventMapToUpdate.isEmpty()
                                                              && eventMapToUpdate.containsKey(eventId)){
                                                                  eventMapToUpdate.get(eventId).put('No_Event_Registrations_ex_Guest__c', (Integer)thisAggregrateResult.get('totalRecords'));
                                                              }
                                                       }
            
            if(!eventMapToUpdate.isEmpty()){
                update eventMapToUpdate.values();
            }
        }
        catch(Exception e){
            //Exception mechanism to log any exceptions occured during the dml operation
            ct_Logger.logMessage(e, 'Event - Event Registration Custom Rollup field Calculation');
        }
    }
    
    /**
* @description Method to get Event Order Map 
* @author Creation Admin | 08-21-2020 
* @param eventOrderIDs Set of Event Orders which needs to be retrieved
* @return Map<Id, Event_Order__c> 
**/
    global static Map<Id, Event_Order__c> getEventOrderMap(Set<Id> eventOrderIDs){
        return new Map<Id,Event_Order__c>([SELECT Id, Number_of_Event_Registration__c FROM Event_Order__c WHERE Id IN:eventOrderIDs]);
    }
    
    /**
* @description Method to Process Event Registration Roll up in Event Orders
* @author Creation Admin | 08-21-2020 
* @param eventOrderIDs Set of Event Orders which needs to be processed
* @return List<Event_Order__c> 
**/
    @future
    global static void processEventRegistrationRollUp(Set<Id> eventOrderIDs){
        Map<Id, Event_Order__c> eventOrderToUpdate = getEventOrderMap(eventOrderIDs);
        try{
            for (AggregateResult thisAggregateResult : [SELECT COUNT(ID) numberOfEventReg, Event_Order__c eventOrderId 
                                                        FROM Event_Registration__c 
                                                        WHERE Event_Order__c IN :eventOrderIDs
                                                        GROUP BY Event_Order__c]) {
                                                            if(eventOrderToUpdate.containsKey((Id) thisAggregateResult.get('eventOrderId'))){
                                                                eventOrderToUpdate.get((Id) thisAggregateResult.get('eventOrderId')).Number_of_Event_Registration__c = (Integer) thisAggregateResult.get('numberOfEventReg');
                                                            }                                            
                                                        }
            update eventOrderToUpdate.values();
        }
        catch(Exception e){
            //Exception mechanism to log any exceptions occured during the dml operation
            ct_Logger.logMessage(e, 'Process Event Registration Roll up field on Event order');
        }
        
    }
    
    global static Map<Id, Set<String>> getAddressQuestionFromQuestionSet(Set<Id> eventQuestionSetIds){
        Set<String> addressFields = new Set<String>{'Street__c', 'City__c','State_County__c', 'Zip_Postal_Code__c','Country__c',
            'Country_of_Residence__c','Address_Line_2__c'};
                
                Map<Id, Set<String>> questionSetToAddressQuestionMap = new Map<Id, Set<String>>();
    
                
        try{
            for(Questions__c thisQuestion : [SELECT Id, Name, Data_Type__c, Even_Registration_Field_API_Name__c, Event_Question_Set__c
                                             FROM Questions__c
                                             WHERE Event_Question_Set__c =:eventQuestionSetIds
                                             AND Even_Registration_Field_API_Name__c != null]){
                                                 thisQuestion.Even_Registration_Field_API_Name__c = thisQuestion.Even_Registration_Field_API_Name__c.trim();
                                                 
                                                 if(addressFields.contains(thisQuestion.Even_Registration_Field_API_Name__c)){
                                                     if(!questionSetToAddressQuestionMap.containsKey(thisQuestion.Event_Question_Set__c)){
                                                         questionSetToAddressQuestionMap.put(thisQuestion.Event_Question_Set__c, new Set<String>());
                                                     }						
                                                     questionSetToAddressQuestionMap.get(thisQuestion.Event_Question_Set__c).add(thisQuestion.Even_Registration_Field_API_Name__c);
                                                 }
                                             }
        }
        catch(Exception e){
            //Exception mechanism to log any exceptions occured during the dml operation
            ct_Logger.logMessage(e, 'Get Address Question From Question Set Event Registration Helper');
        }
        
        return questionSetToAddressQuestionMap;
    }
    
    global static void processLeadContactConsentAndAddress(Event_Registration__c thisEventRegistration, SObject thisSobject, Map<Id, Set<String>> questionSetToAddressQuestionMap){
        try{
            
            Schema.SObjectType sobjectType = thisSobject.getSObjectType();
            
            Map<String, String> eventRegToLeadMapping = new Map<String, String>{
                'Street__c'               => 'Street',
                    'City__c'                 => 'City',
                    'State_County__c'         => 'State',
                    'Zip_Postal_Code__c'      => 'PostalCode',
                    'Country__c'              => 'Country',
                    'Country_of_Residence__c' => 'Country_of_Residence__c',
                    'Address_Line_2__c'       => 'Address_line_2__c'};
                        
                        Map<String, String> eventRegToAccountMapping = new Map<String, String>{
                            'Street__c'               => 'PersonMailingStreet',
                                'City__c'                 => 'PersonMailingCity',
                                'State_County__c'         => 'PersonMailingState',
                                'Zip_Postal_Code__c'      => 'PersonMailingPostalCode',
                                'Country__c'              => 'PersonMailingCountry'};
                                    
                                    if(thisEventRegistration.Event_Product__c != null
                                       && thisEventRegistration.Event_Product__r.Event_Question_Set__c != null
                                       && !questionSetToAddressQuestionMap.isEmpty()
                                       && questionSetToAddressQuestionMap.containsKey(thisEventRegistration.Event_Product__r.Event_Question_Set__c)
                                       && !questionSetToAddressQuestionMap.get(thisEventRegistration.Event_Product__r.Event_Question_Set__c).isEmpty()){
                                           
                                           for(String fieldAPIName : questionSetToAddressQuestionMap.get(thisEventRegistration.Event_Product__r.Event_Question_Set__c)){
                                               if(sobjectType == Schema.Lead.getSObjectType()
                                                  && eventRegToLeadMapping.containsKey(fieldAPIName)){
                                                      thisSobject.put(eventRegToLeadMapping.get(fieldAPIName), thisEventRegistration.get(fieldAPIName));
                                                  }
                                               else if(eventRegToAccountMapping.containsKey(fieldAPIName)){
                                                   thisSobject.put(eventRegToAccountMapping.get(fieldAPIName), thisEventRegistration.get(fieldAPIName));
                                               }
                                           }
                                       }
        }
        catch(Exception e){
            //Exception mechanism to log any exceptions occured during the dml operation
            ct_Logger.logMessage(e, 'Process Contact Consent And Address Field');
        }
    }
}