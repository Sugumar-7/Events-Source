/**
 * @description       : Handler class for Platform Event Trigger on for populating contact or Lead in Event Order / Event registration record
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 07-05-2021
 * @last modified by  : Rajesh Creation
 * @modified date     : 10-06-2020
**/


global without sharing class ct_LeadContactAsRegistrantsAttendees
{
    global static String objName;
    /*@TestVisible
    global static Map<String, List<dupcheck.dc3SearchResult>> searchResult;*/
    @TestVisible
    global static Lead duplicateLead;
    @TestVisible
    global static Contact duplicateContact;
    global static Account duplicateAccount;
    global static Map<Id, Set<String>> questionSetToAddressQuestionMap = new Map<Id, Set<String>>();

    global static void dupecheckforLeadOrContact(List<String> eventDetailsDataList){
        system.debug('hellowwwwdupecheckforLeadOrContact');
        //Variable to store Map of fields description for Contact object
        Map<String,Schema.SObjectField> contactFieldsMap                  = ct_WebDataFormHelper.getSojectFields('Contact');
        //Variable to store Map of fields description for Lead object
        Map<String,Schema.SObjectField> leadFieldsMap                     = ct_WebDataFormHelper.getSojectFields('Lead');
        //Lead duplicateLead = new Lead();
        //Contact duplicateContact = new Contact();
        List<Event_Registration__c> lstEvtRegToUpsert = new List<Event_Registration__c>();
        List<Event_Order__c> lstEvtOrderToUpsert = new List<Event_Order__c>();
        List<Contact> contactListToUpdate = new List<Contact>();
        List<Account> accountListToUpdate = new List<Account>();
        List<Lead> leadListToUpdate = new List<Lead>();
        String searchResult=null;
        Set<String> eventRegIdAndEventOrderId = new Set<String>();
        Set<Id> eventQuestionSet = new Set<Id>();


        //For loop to get Event Registration record Id's
        for(String thisObject : eventDetailsDataList){
            Map<String, Object> thisDeserializeObject    = (Map<String, Object>)JSON.deserializeUntyped(thisObject);
            Id recId = String.valueOf(thisDeserializeObject.get('recId'));
            eventRegIdAndEventOrderId.add(recId);
        }

        Map<Id, Event_Registration__c> eventRegistrationMap = new Map<Id, Event_Registration__c>([SELECT Id, 
                                                                    First_Name__c, 
                                                                    Last_Name__c, 
                                                                    Event_Email__c, 
                                                                    Street__c,
                                                                    City__c,
                                                                    State_County__c,
                                                                    Zip_Postal_Code__c,
                                                                    Country__c,
                                                                    Address_Line_2__c,
                                                                    Country_of_Residence__c,
                                                                    Object_for_New_Attendees__c, 
                                                                    Event__r.Campaign__c, 
                                                                    Record_Type_for_New_Attendees__c,
                                                                    Event_Mobile__c,
                                                                    Event_order__c, 
                                                                    Event_Order__r.Street__c,
                                                                    Event_Order__r.Consent_Given__c,
                                                                    Event_Order__r.Statement_Used__c,
                                                                    Event_Order__r.City__c,
                                                                    Event_Order__r.State__c,
                                                                    Event_Order__r.Country__c,
                                                                    Event_Order__r.Post_code__c,
                                                                    Registration_Type__c,
                                                                    Event_Product__c,
                                                                    Event_Product__r.Event_Question_Set__c
                                                                FROM Event_Registration__c 
                                                                WHERE id =:eventRegIdAndEventOrderId]);

        for(Event_Registration__c thisEventRegistration : eventRegistrationMap.values()){
            if(thisEventRegistration.Event_Product__c != null
            && thisEventRegistration.Event_Product__r.Event_Question_Set__c != null){
                eventQuestionSet.add(thisEventRegistration.Event_Product__r.Event_Question_Set__c);
            }
        }
        
        if(!eventQuestionSet.isEmpty()){
            questionSetToAddressQuestionMap = ct_Event_RegistrationTriggerHelper.getAddressQuestionFromQuestionSet(eventQuestionSet);
        }

        Map<Id, Event_Order__c> eventOrderMap = new Map<Id, Event_Order__c>([SELECT Id,
                                                        First_Name__c, 
                                                        Last_Name__c,
                                                        Email__c, 
                                                        Event__r.Object_for_New_Attendees__c, 
                                                        Street__c,
                                                        City__c,
                                                        Mobile__c,
                                                        Consent_Given__c,
                                                        Statement_Used__c,
                                                        State__c,
                                                        Country__c,
                                                        Post_code__c,
                                                        Event__r.Campaign__c, 
                                                        Event__r.Record_Type_for_New_Attendees__c 
                                                        FROM Event_Order__c 
                                                        WHERE id =:eventRegIdAndEventOrderId]);

        Set<String> evtRegIds = new Set<String>();
        system.debug('hello');
        for(String thisObject : eventDetailsDataList){
            //Deserialize the JSON string to map object & string get object values      
            Map<String, Object> evtRegObject                             = (Map<String, Object>)JSON.deserializeUntyped(thisObject);
            //Initialise dupcheck API Object to invoke the API methods
            //dupcheck.dc3Api api                                         = new dupcheck.dc3Api();
            //Create a sample lead data from the search wrapper passed from the Flow
            Lead searchLead                                             = constructLead(evtRegObject, leadFieldsMap);
            //Duplicate Check API to get Duplicated Records with the sample lead data
            if (!Test.isRunningTest()) {
              //searchResult = api.doSearch(searchLead); 
            }
            /*if(searchResult != null){
              duplicateLead                                          = dupecheckForLead(searchResult, searchLead);
              duplicateContact                                    = dupecheckForContact(searchResult, searchLead);
              }*/
            Id recId = Id.valueOf(String.valueOf(evtRegObject.get('recId')));
            Schema.SObjectType obj = recId.getsobjecttype();
            system.debug('hello0');
            if(duplicateLead != null){
                if(String.valueOf(obj) == 'Event_Registration__c'
                && eventRegistrationMap.containsKey(recId)){
                    objName                      = 'Event Registration';
                    Event_Registration__c evtReg = eventRegistrationMap.get(recId);
                    evtReg.Enquirer__c           = duplicateLead.Id;
                    lstEvtRegToUpsert.add(evtReg);
                    //Process Consent
                    duplicateLead.Event_Email__c     = evtReg.Event_Email__c;
                    duplicateLead.Event_Mobile__c    = evtReg.Event_Mobile__c;

                    ct_Event_RegistrationTriggerHelper.processLeadContactConsentAndAddress(evtReg, duplicateLead, questionSetToAddressQuestionMap);
                    
                    if(evtReg.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
                        duplicateLead.Latest_Consent_Change_Campaign__c = evtReg.Event__r.Campaign__c;
                        if(evtReg.Event_Order__r.Consent_Given__c != null){
                            //populateLeadConsentChange(duplicateLead, evtReg.Event_Order__r.Consent_Given__c, evtReg.Event_Order__r.Statement_Used__c);
                        }
                    }
                    
                    
                }
                else if(String.valueOf(obj) == 'Event_Order__c'
                && eventOrderMap.containsKey(recId)){
                    system.debug('hello1');
                    objName = 'Event Order';
                    Event_Order__c evtOrd = eventOrderMap.get(recId);
                    evtOrd.Lead__c = duplicateLead.Id;
                    lstEvtOrderToUpsert.add(evtOrd);
                    //Process Consent
                    duplicateLead.Event_Email__c     = evtOrd.Email__c;
                    duplicateLead.Event_Mobile__c    = evtOrd.Mobile__c;
                    duplicateLead.Street                  = evtOrd.Street__c;
                    duplicateLead.City                    = evtOrd.City__c;
                    duplicateLead.State                   = evtOrd.State__c;
                    duplicateLead.PostalCode              = evtOrd.Post_code__c;
                    duplicateLead.Country                 = evtOrd.Country__c;
                    //duplicateLead.Country_of_Residence__c = evtOrd.Country__c;
                
                    duplicateLead.Latest_Consent_Change_Campaign__c = evtOrd.Event__r.Campaign__c;
                    if(evtOrd.Consent_Given__c != null){
                        //populateLeadConsentChange(duplicateLead, evtOrd.Consent_Given__c, evtOrd.Statement_Used__c);
                    }
                }

                leadListToUpdate.add(duplicateLead);

                 
            }else if(duplicateAccount != null){ 
                if(String.valueOf(obj) == 'Event_Registration__c'
                && eventRegistrationMap.containsKey(recId)){
                    system.debug('hello2');
                    Event_Registration__c evtReg = eventRegistrationMap.get(recId);
                    //evtReg.Id = String.valueOf(evtRegObject.get('recId'));
                    evtReg.Account_Name__c = duplicateAccount.Id;
                    //Process Consent fields
                    duplicateAccount.Event_Email__pc                 = evtReg.Event_Email__c;
                    duplicateAccount.Event_Mobile__pc                = evtReg.Event_Mobile__c;
                    ct_Event_RegistrationTriggerHelper.processLeadContactConsentAndAddress(evtReg, duplicateAccount, questionSetToAddressQuestionMap);
                    if(evtReg.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
                        duplicateAccount.Latest_Consent_Change_Campaign__pc = evtReg.Event__r.Campaign__c;
                        if(evtReg.Event_Order__r.Consent_Given__c != null){
                            populateContactConsentChange(duplicateContact, evtReg.Event_Order__r.Consent_Given__c, evtReg.Event_Order__r.Statement_Used__c);
                        }
                    }
                    
                    lstEvtRegToUpsert.add(evtReg);
                }
                else if(String.valueOf(obj) == 'Event_Order__c'
                    && eventOrderMap.containsKey(recId)){
                    system.debug('hello3');
                    Event_Order__c evtOrd = eventOrderMap.get(recId);
                    evtOrd.Account__c = duplicateAccount.Id;
                    //Process Consent Fields
                    duplicateAccount.Event_Email__pc    = evtOrd.Email__c;
                    duplicateAccount.Event_Mobile__pc   = evtOrd.Mobile__c;
                    duplicateAccount.PersonMailingStreet     = evtOrd.Street__c;
                    duplicateAccount.PersonMailingCity       = evtOrd.City__c;
                    duplicateAccount.PersonMailingState      = evtOrd.State__c;
                    duplicateAccount.PersonMailingPostalCode = evtOrd.Post_code__c;
                    duplicateAccount.PersonMailingCountry    = evtOrd.Country__c;

                    //duplicateContact.Latest_Consent_Change_Campaign__c = evtOrd.Event__r.Campaign__c;
                    if(evtOrd.Consent_Given__c != null){
                        //populateContactConsentChange(duplicateContact, evtOrd.Consent_Given__c, evtOrd.Statement_Used__c);
                    }

                    lstEvtOrderToUpsert.add(evtOrd);
                }
                //contactListToUpdate.add(duplicateContact);
                accountListToUpdate.add(duplicateAccount);
            }else{
                evtRegIds.add(String.valueOf(evtRegObject.get('recId')));
                System.debug('evtRegIds>>>'+evtRegIds);
            }
        }
        try{
            if(!lstEvtRegToUpsert.isEmpty()){
                //  ct_Event_RegistrationTriggerHandler_TDTM.turnOn();
                System.debug('upserting lstEvtRegToUpsert');
                upsert lstEvtRegToUpsert;
                        List<Event_Registration__c> evtRegRecs = new List<Event_Registration__c>();
                        evtRegRecs = [SELECT Id, 
                            First_Name__c, 
                            Last_Name__c, 
                            Account_Name__c
                           
                        FROM Event_Registration__c 
                        WHERE id =:evtRegIds];
                System.debug(evtRegRecs);
            }
            if(!lstEvtOrderToUpsert.isEmpty()){
                upsert lstEvtOrderToUpsert;
            }
            // if(!contactListToUpdate.isEmpty()){
            //     update contactListToUpdate;
            // }
            if(!accountListToUpdate.isEmpty()){
                update accountListToUpdate;
            }
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
            if(!evtRegIds.isEmpty()){
                createRelatedLeadOrContact(evtRegIds);
            }
        }
        catch(Exception e){
            ct_Logger.logMessage(e, objName);
            throw e;
        }
        
    }
    global static Lead constructLead(Map<String, Object> jsonObject, Map<String,Schema.SObjectField> leadFieldsMap){
        //Create instance of Lead object to pass it for Dupecheck processing
        Lead thisLead   = new Lead();
        //loop through the JSON object and Map available field values from JSON object to Lead object
        for(String thisFieldName : jsonObject.keySet()){
            if(leadFieldsMap.containsKey(thisFieldName)
               && !String.isEmpty(String.valueOf(jsonObject.get(thisFieldName)))){
                   thisLead.put(thisFieldName, String.valueOf(jsonObject.get(thisFieldName)));
               }
        }
        return thisLead;
    }
    
    /*global static Lead dupecheckForLead(Map<String, List<dupcheck.dc3SearchResult>> duplicateSearchResult, Lead searchLead){
        Lead duplicateLead;
        
        //Retrive the Lead duplicates from the Dupe API Result map using the Lead Object Record Key 00Q
        if(duplicateSearchResult.containskey('00Q')){
            
            for (dupcheck.dc3SearchResult thisDuplicate : duplicateSearchResult.get('00Q')) {
                if((searchLead.Email).equalsIgnoreCase(String.valueOf(thisDuplicate.getDisplayField().get('Email')))
                   && (searchLead.FirstName).equalsIgnoreCase(String.valueOf(thisDuplicate.getDisplayField().get('FirstName'))) 
                   && (searchLead.LastName).equalsIgnoreCase(String.valueOf(thisDuplicate.getDisplayField().get('LastName')))){
                       duplicateLead         = new Lead();
                       duplicateLead.Id      = String.valueOf(thisDuplicate.getDisplayField().get('Id'));
                       break;
                   }
            } 
        }
        return duplicateLead;
    }*/
    
    /*global static Contact dupecheckForContact(Map<String, List<dupcheck.dc3SearchResult>> duplicateSearchResult,Lead searchLead){
        Contact duplicateContact;
        //Retrive the Lead duplicates from the Dupe API Result map using the Lead Object Record Key 003
        if(duplicateSearchResult.containskey('003')){
            for (dupcheck.dc3SearchResult thisDuplicate : duplicateSearchResult.get('003')) {
                if((searchLead.Email).equalsIgnoreCase(String.valueOf(thisDuplicate.getDisplayField().get('Email')))
                   && (searchLead.FirstName).equalsIgnoreCase(String.valueOf(thisDuplicate.getDisplayField().get('FirstName')))
                   && (searchLead.LastName).equalsIgnoreCase(String.valueOf(thisDuplicate.getDisplayField().get('LastName')))){
                       duplicat
                       
                       eContact      = new Contact();
                       duplicateContact.Id   = String.valueOf(thisDuplicate.getDisplayField().get('Id'));
                       break;
                   }
            } 
        }
        return duplicateContact;
    }   */
    
    global static void createRelatedLeadOrContact(Set<String> recIds){
        System.debug('Record Ids '+recIds);
        Id first = new List<String> (recIds).get(0);
        Schema.SObjectType obj = first.getsobjecttype();
        System.debug('Obj '+obj);
        List<Event_Registration__c> evtRegRecs = new List<Event_Registration__c>();
        List<Event_Order__c> evtOrdRecs = new List<Event_Order__c>();
        if(String.valueOf(obj) == 'Event_Registration__c'){
            System.debug('If condition inside Event Registration');
            objName = 'Event Registration';
            evtRegRecs = [SELECT Id, 
                            First_Name__c, 
                            Last_Name__c, 
                            Account_Name__c,
                            Event_Email__c,
                            Street__c,
                            City__c,
                            State_County__c,
                            Zip_Postal_Code__c,
                            Country__c,
                            Address_Line_2__c,
                            Country_of_Residence__c,
                            Birthdate__c,
                            Object_for_New_Attendees__c, 
                            Event__r.Campaign__c, 
                            Record_Type_for_New_Attendees__c,
                            Event_Mobile__c,
                            Event_order__c, 
                            Event_Order__r.Street__c,
                            Event_Order__r.Consent_Given__c,
                            Event_Order__r.Statement_Used__c,
                            Event_Order__r.City__c,
                            Event_Order__r.State__c,
                            Event_Order__r.Country__c,
                            Event_Order__r.Post_code__c,
                            Registration_Type__c,
                            Event__c,
                            Event__r.Name,
                            Event_Product__c,
                            Event_Product__r.Event_Question_Set__c,
                            Account_Name__r.FirstName,
                            Account_Name__r.LastName, 
                            Account_Name__r.Event_Email__pc
                        FROM Event_Registration__c 
                        WHERE id =:recIds];
        }
        else if(String.valueOf(obj) == 'Event_Order__c'){
            System.debug('If condition inside Event Order');
            objName = 'Event Order';
            evtOrdRecs = [SELECT Id,
                            First_Name__c, 
                            Last_Name__c,
                            Email__c, 
                            Event__r.Object_for_New_Attendees__c, 
                            Street__c,
                            City__c,
                            Consent_Given__c,
                            Statement_Used__c,
                            State__c,
                            Mobile__c,
                            Country__c,
                            Post_code__c,
                            Event__r.Campaign__c, 
                            Event__r.Record_Type_for_New_Attendees__c,
                            Event__r.Name
                            FROM Event_Order__c 
                            WHERE id =:recIds];
        }
        System.debug('EventTegistration List ' +evtRegRecs);
        System.debug('EventOrder List ' +evtOrdRecs);
        List<Lead> lstOfLdtoInsert = new List<Lead>();
        List<Contact> lstOfContactToInsert = new List<Contact>();
        List<Account> lstOfAccountToInsert = new List<Account>();
        if(!evtRegRecs.isEmpty()){
             System.debug('If condition inside Event Registration is available');
            for(Event_Registration__c evtReg : evtRegRecs){
                if(evtReg.Object_for_New_Attendees__c != null && evtReg.Object_for_New_Attendees__c == ct_EventConstants.CREATE_NEW_LEADS){
                     System.debug('Create New Lead in EventRegistration'); 
                    Lead ld               = new Lead();
                    ld.FirstName          = evtReg.First_Name__c;
                    ld.LastName           = evtReg.Last_Name__c;
                    ld.Event_Email__c     = evtReg.Event_Email__c;
                    ld.Event_Mobile__c    = evtReg.Event_Mobile__c;
                    //ld.CurrencyIsoCode    = 'GBP';
                    ld.Status             = 'New - Unverified';
                    ld.Company            = evtReg.First_Name__c +' '+evtReg.Last_Name__c;
                    ld.Enquiry_Channel__c = 'Event';
                    ld.Birthdate__c = evtReg.Birthdate__c;
                    //below line commented by sugumar
                    //ct_Event_RegistrationTriggerHelper.processLeadContactConsentAndAddress(evtReg, ld, questionSetToAddressQuestionMap);
                    ld.LeadSource              = 'University Website';
                    //ld.Enquirer_Source_Other__c = evtReg.Event__r.Name;
                    //Below lines are added to store the address of attendees
                    ld.Street     = evtReg.Event_Order__r.Street__c;
                    ld.City       = evtReg.Event_Order__r.City__c;
                    ld.State      = evtReg.Event_Order__r.State__c;
                    ld.Country    = evtReg.Event_Order__r.Country__c;
                    ld.PostalCode = evtReg.Event_Order__r.Post_code__c;

                    if(evtReg.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
                        ld.Latest_Consent_Change_Campaign__c = evtReg.Event__r.Campaign__c;
                        if(evtReg.Event_Order__r.Consent_Given__c != null){
                           // populateLeadConsentChange(ld, evtReg.Event_Order__r.Consent_Given__c, evtReg.Event_Order__r.Statement_Used__c);
                        }
                    }

                    if(evtReg.Record_Type_for_New_Attendees__c != null){
                        //ld.RecordTypeId = ct_Util.getRecordTypeIdByDevName('Lead', evtReg.Record_Type_for_New_Attendees__c);
                        Id rtId = ct_Util.getRecordTypeIdByDevName('Lead', evtReg.Record_Type_for_New_Attendees__c);
                        if (rtId != null) {
                            ld.put('RecordTypeId', rtId);
                        }
                    }
                    lstOfLdtoInsert.add(ld);
                } 
                else if(evtReg.Object_for_New_Attendees__c != null && evtReg.Object_for_New_Attendees__c == ct_EventConstants.CREATE_NEW_PERSON_ACCOUNTS){
                    // System.debug('Create New Contact in EventRegistration');
                    // Contact con         = new Contact();
                    // con.FirstName       = evtReg.First_Name__c;
                    // con.LastName        = evtReg.Last_Name__c;
                    // con.Event_Email__c  = evtReg.Event_Email__c;
                    // con.Event_Mobile__c = evtReg.Event_Mobile__c;

                    // /*Saren - To populate the Address filed - 07/10/2025*/
                    // if(evtReg.Registration_Type__c == 'Myself'){
                    //     con.MailingStreet     = evtReg.Event_Order__r.Street__c;
                    //     con.MailingCity       = evtReg.Event_Order__r.City__c;
                    //     con.MailingState      = evtReg.Event_Order__r.State__c;
                    //     con.MailingCountry    = evtReg.Event_Order__r.Country__c;
                    //     con.MailingPostalCode = evtReg.Event_Order__r.Post_code__c;
                    // }

                    // con.Birthdate = evtReg.Birthdate__c;
                    // // Saren ct_Event_RegistrationTriggerHelper.processLeadContactConsentAndAddress(evtReg, con, questionSetToAddressQuestionMap);
                    // con.LeadSource              = 'University Website';
                    // //con.Enquirer_Source_Other__c = evtReg.Event__r.Name;

                    // if(evtReg.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
                    //     con.Latest_Consent_Change_Campaign__c = evtReg.Event__r.Campaign__c;
                    //     if(evtReg.Event_Order__r.Consent_Given__c != null){
                    //         //populateContactConsentChange(con, evtReg.Event_Order__r.Consent_Given__c, evtReg.Event_Order__r.Statement_Used__c);
                    //     }
                    // }
                    
                    // if(evtReg.Record_Type_for_New_Attendees__c != null){
                    //     con.RecordTypeId = ct_Util.getRecordTypeIdByDevName('Contact', evtReg.Record_Type_for_New_Attendees__c);
                    // }
                    // lstOfContactToInsert.add(con);
                    // system.debug('lstOfContactToInsert 1 '+lstOfContactToInsert);
                    System.debug('Create New Person Account in Event Registration');
                    Account acc = new Account();
                    acc.FirstName = evtReg.First_Name__c;
                    acc.LastName        = evtReg.Last_Name__c;
                    acc.Event_Email__pc  = evtReg.Event_Email__c;
                    acc.Event_Mobile__pc = evtReg.Event_Mobile__c;

                    /*Saren - To populate the Address filed - 07/10/2025*/
                    if(evtReg.Registration_Type__c == 'Myself'){
                        acc.PersonMailingStreet     = evtReg.Event_Order__r.Street__c;
                        acc.PersonMailingCity       = evtReg.Event_Order__r.City__c;
                        acc.PersonMailingState      = evtReg.Event_Order__r.State__c;
                        acc.PersonMailingCountry    = evtReg.Event_Order__r.Country__c;
                        acc.PersonMailingPostalCode = evtReg.Event_Order__r.Post_code__c;
                    }

                    acc.PersonBirthdate = evtReg.Birthdate__c;
                    acc.PersonLeadSource = 'University Website';

                    if(evtReg.Registration_Type__c == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
                        acc.Latest_Consent_Change_Campaign__pc = evtReg.Event__r.Campaign__c;
                        if(evtReg.Event_Order__r.Consent_Given__c != null){
                            //populateContactConsentChange(con, evtReg.Event_Order__r.Consent_Given__c, evtReg.Event_Order__r.Statement_Used__c);
                        }
                    }
                    acc.RecordTypeId = ct_Util.getRecordTypeIdByDevName('Account', evtReg.Record_Type_for_New_Attendees__c);
                    lstOfAccountToInsert.add(acc);
                }
            } 
        }
        else if(!evtOrdRecs.isEmpty()){
              System.debug('If condition inside Event Order is available');
            for(Event_Order__c evtOrdRec : evtOrdRecs){
                if(evtOrdRec.Event__r.Object_for_New_Attendees__c != null && evtOrdRec.Event__r.Object_for_New_Attendees__c == ct_EventConstants.CREATE_NEW_LEADS){
                    System.debug('Create New Lead in Event Order');
                    Lead ld                    = new Lead();
                    ld.FirstName               = evtOrdRec.First_Name__c;
                    ld.LastName                = evtOrdRec.Last_Name__c;
                    ld.Event_Email__c          = evtOrdRec.Email__c;
                    ld.Event_Mobile__c         = evtOrdRec.Mobile__c;
                    //ld.CurrencyIsoCode         = 'GBP';
                    ld.Status                  = 'New - Unverified';
                    ld.Company                 = evtOrdRec.First_Name__c+' '+evtOrdRec.Last_Name__c;
                    ld.Enquiry_Channel__c      = 'Event';
                    ld.Street                  = evtOrdRec.Street__c;
                    ld.City                    = evtOrdRec.City__c;
                    ld.State                   = evtOrdRec.State__c;
                    ld.PostalCode              = evtOrdRec.Post_code__c;
                    ld.Country                 = evtOrdRec.Country__c;
                   // ld.Country_of_Residence__c = evtOrdRec.Country__c;
                    ld.LeadSource              = 'University Website';
                   // ld.Enquirer_Source_Other__c = evtOrdRec.Event__r.Name;

                    if(evtOrdRec.Event__r.Record_Type_for_New_Attendees__c != null){
                        //ld.RecordTypeId = ct_Util.getRecordTypeIdByDevName('Lead', evtOrdRec.Event__r.Record_Type_for_New_Attendees__c);
                        Id rtId = ct_Util.getRecordTypeIdByDevName('Lead', evtOrdRec.Event__r.Record_Type_for_New_Attendees__c);
                        if (rtId != null) {
                            ld.put('RecordTypeId', rtId);
                        }
                    }

                    ld.Latest_Consent_Change_Campaign__c = evtOrdRec.Event__r.Campaign__c;
                    if(evtOrdRec.Consent_Given__c != null){
                        //populateLeadConsentChange(ld, evtOrdRec.Consent_Given__c, evtOrdRec.Statement_Used__c);
                    }
                    lstOfLdtoInsert.add(ld);
                }
                else if(evtOrdRec.Event__r.Object_for_New_Attendees__c != null && evtOrdRec.Event__r.Object_for_New_Attendees__c == ct_EventConstants.CREATE_NEW_PERSON_ACCOUNTS){
                    // System.debug('Create New Contact in Event Order');
                    // Contact con           = new Contact();
                    // con.FirstName         = evtOrdRec.First_Name__c;
                    // con.LastName          = evtOrdRec.Last_Name__c;
                    // con.Event_Email__c    = evtOrdRec.Email__c;
                    // con.Event_Mobile__c   = evtOrdRec.Mobile__c;
                    // con.MailingStreet     = evtOrdRec.Street__c;
                    // con.MailingCity       = evtOrdRec.City__c;
                    // con.MailingState      = evtOrdRec.State__c;
                    // con.MailingPostalCode = evtOrdRec.Post_code__c;
                    // con.MailingCountry    = evtOrdRec.Country__c;
                    // con.LeadSource        = 'University Website';
                    // //con.Enquirer_Source_Other__c = evtOrdRec.Event__r.Name;
                    // // SAREN - con.Latest_Consent_Change_Campaign__c = evtOrdRec.Event__r.Campaign__c;
                    // if(evtOrdRec.Consent_Given__c != null){
                    //     //populateContactConsentChange(con, evtOrdRec.Consent_Given__c, evtOrdRec.Statement_Used__c);
                    // }

                    // if(evtOrdRec.Event__r.Record_Type_for_New_Attendees__c != null){
                    //     con.RecordTypeId = ct_Util.getRecordTypeIdByDevName('Contact', evtOrdRec.Event__r.Record_Type_for_New_Attendees__c);
                    // }
                    // lstOfContactToInsert.add(con);
                    //system.debug('lstOfContactToInsert '+lstOfContactToInsert);

                    Account acc           = new Account();
                    acc.FirstName         = evtOrdRec.First_Name__c;
                    acc.LastName          = evtOrdRec.Last_Name__c;
                    
                    acc.Event_Email__pc    = evtOrdRec.Email__c;
                    acc.Event_Mobile__pc   = evtOrdRec.Mobile__c;
                    acc.PersonMailingStreet     = evtOrdRec.Street__c;
                    acc.PersonMailingCity       = evtOrdRec.City__c;
                    acc.PersonMailingState      = evtOrdRec.State__c;
                    acc.PersonMailingPostalCode = evtOrdRec.Post_code__c;
                    acc.PersonMailingCountry    = evtOrdRec.Country__c;
                    acc.PersonLeadSource        = 'University Website';
                    //con.Enquirer_Source_Other__c = evtOrdRec.Event__r.Name;
                    // SAREN - con.Latest_Consent_Change_Campaign__c = evtOrdRec.Event__r.Campaign__c;
                    if(evtOrdRec.Consent_Given__c != null){
                        //populateContactConsentChange(con, evtOrdRec.Consent_Given__c, evtOrdRec.Statement_Used__c);
                    }
                    acc.RecordTypeId = ct_Util.getRecordTypeIdByDevName('Account', evtOrdRec.Event__r.Record_Type_for_New_Attendees__c);
                    lstOfAccountToInsert.add(acc);

                } 
                
            }
        }
        //Remove duplicate Leads based on the exact match of FirstName, LastName and Email
        Map<String, Lead> deDupedLeadsMap = dedupeLeadsFromList(lstOfLdtoInsert);
        try{
          insert deDupedLeadsMap.values();
        }
        catch(Exception e){
          ct_Logger.logMessage(e, 'Lead');
          throw e;
        }

        //Remove duplicate Contacts based on the exact match of FirstName, LastName and Email
        Map<String, Account> accountMapToInsert = new Map<String, Account>();
        List<AccountShare> accountShareToInsert = new List<AccountShare>();
        //Map<String, Contact> deDupedContactssMap = dedupeContactsFromList(lstOfContactToInsert);
        Map<String, Account> deDupedAccountsMap = dedupeAccountsFromList(lstOfAccountToInsert);
        //Id groupId = [select Id,relatedid,Name from Group WHERE Name =: ct_EventConstants.B2B_PUBLIC_GROUP_NAME LIMIT 1].Id;
        //createAccountRecords(deDupedContactssMap, accountMapToInsert); -suhaib
        try{
            //insert accountMapToInsert.values(); -suhaib
            // for(String thisString : accountMapToInsert.keySet()){
            //     AccountShare accountShare = new AccountShare();
            //     accountShare.AccountId = accountMapToInsert.get(thisString).Id;
            //     //accountShare.UserOrGroupId = groupId;
            //     accountShare.AccountAccessLevel = 'Edit';
            //     //accountShare.ContactAccessLevel = 'Edit';
            //     accountShare.CaseAccessLevel = 'None';
            //     accountShare.OpportunityAccessLevel = 'None';
            //     accountShareToInsert.add(accountShare);
                
            //     if(!deDupedContactssMap.isEmpty()
            //     && deDupedContactssMap.containsKey(thisString)){
            //         deDupedContactssMap.get(thisString).AccountId = accountMapToInsert.get(thisString).Id;
            //     }
            // }
            // insert accountShareToInsert;
            system.debug('deDupedAccountsMap.values() '+deDupedAccountsMap.values());
            insert deDupedAccountsMap.values();

        }
        catch(Exception e){
          ct_Logger.logMessage(e, 'Contact');
          throw e;
        }

        String recordId; 
        try{
            List<Event_Registration__c> lstEvtRegToUpdate = new List<Event_Registration__c>();
            List<Event_Order__c> lstEvtOrdToUpdate = new List<Event_Order__c>();

            for(Event_Registration__c thisEventReg : evtRegRecs){
              //added by Anshul
              System.debug('Event_Registration__c Before>>>>>>>'+thisEventReg);
              thisEventReg.Event_Registration_Status__c = 'Registered';
              System.debug('Event_Registration__c After>>>>>>>'+thisEventReg);

              if(deDupedLeadsMap.containsKey(thisEventReg.First_Name__c+thisEventReg.Last_Name__c+thisEventReg.Event_Email__c)){
                thisEventReg.Enquirer__c = deDupedLeadsMap.get(thisEventReg.First_Name__c+thisEventReg.Last_Name__c+thisEventReg.Event_Email__c).Id;
                lstEvtRegToUpdate.add(thisEventReg);
              }
              else if(deDupedAccountsMap.containsKey(thisEventReg.First_Name__c+thisEventReg.Last_Name__c+thisEventReg.Event_Email__c)){
                thisEventReg.Account_Name__c = deDupedAccountsMap.get(thisEventReg.First_Name__c+thisEventReg.Last_Name__c+thisEventReg.Event_Email__c).Id;
                lstEvtRegToUpdate.add(thisEventReg);
              }
                
            }

            for(Event_Order__c thisEventOrder : evtOrdRecs){
              if(deDupedLeadsMap.containsKey(thisEventOrder.First_Name__c+thisEventOrder.Last_Name__c+thisEventOrder.Email__c)){
                thisEventOrder.Lead__c = deDupedLeadsMap.get(thisEventOrder.First_Name__c+thisEventOrder.Last_Name__c+thisEventOrder.Email__c).Id;
                lstEvtOrdToUpdate.add(thisEventOrder);
              }
              else if(deDupedAccountsMap.containsKey(thisEventOrder.First_Name__c+thisEventOrder.Last_Name__c+thisEventOrder.Email__c)){
                thisEventOrder.Account__c = deDupedAccountsMap.get(thisEventOrder.First_Name__c+thisEventOrder.Last_Name__c+thisEventOrder.Email__c).Id;
                lstEvtOrdToUpdate.add(thisEventOrder);
                system.debug('thisEventOrder.Account__c>>>>>'+thisEventOrder.Account__c);
                System.debug('lstEvtOrdToUpdate>>>>>'+lstEvtOrdToUpdate);
              }
            }
            
            if(!lstEvtRegToUpdate.isEmpty()){
                update lstEvtRegToUpdate;
            }
            if(!lstEvtOrdToUpdate.isEmpty()){
                update lstEvtOrdToUpdate;
            }
        }
        catch(Exception e){
            ct_Logger.logMessage(e, objName);
            throw e;
        }
    }

    global static Map<String, Account> createAccountRecords(Map<String, Contact> contactMap, Map<String, Account> accountMap){
        if(!contactMap.isEmpty()){
            for(String thisString : contactMap.keySet()){
                accountMap.put(thisString, constructAccountRecord(contactMap.get(thisString)));
            }
        }
       return accountMap;
    }

    global static Account constructAccountRecord (Contact thisContact){
        Account thisAccount = new Account();
        thisAccount.Name = thisContact.FirstName+' '+thisContact.LastName;
        thisAccount.RecordTypeId = ct_Constants.ACCOUNT_RECORDTYPE_ADMINISTRATIVE;
        if(String.isNotBlank(thisContact.MailingStreet)){
            thisAccount.BillingStreet= thisContact.MailingStreet;
        }
        if(String.isNotBlank(thisContact.MailingState)){
            thisAccount.BillingState = thisContact.MailingState;
        }
        if(String.isNotBlank(thisContact.MailingCity)){
            thisAccount.BillingCity= thisContact.MailingCity;
        }
        if(String.isNotBlank(thisContact.MailingPostalCode)){
            thisAccount.BillingPostalCode= thisContact.MailingPostalCode;
        }
        if(String.isNotBlank(thisContact.MailingCountry)){
            thisAccount.BillingCountry= thisContact.MailingCountry;
        }
        return thisAccount;
    }
    global static Map<String, Lead> dedupeLeadsFromList(List<Lead> leadListToCheck){
      Map<String, Lead> deDupedMap = new Map<String, Lead>();
      for(Lead thisObject : leadListToCheck){
        deDupedMap.put(thisObject.FirstName+thisObject.LastName+thisObject.Event_Email__c, thisObject);
      }
      return deDupedMap;
    }

    global static Map<String, Contact> dedupeContactsFromList(List<Contact> contactListToCheck){
      Map<String, Contact> deDupedMap = new Map<String, Contact>();
      for(Contact thisObject : contactListToCheck){
        deDupedMap.put(thisObject.FirstName+thisObject.LastName+thisObject.Event_Email__c, thisObject);
      }
      return deDupedMap;
    }

    //suhaib 
    global static Map<String, Account> dedupeAccountsFromList(List<Account> AccountListToCheck){
      Map<String, Account> deDupedMap = new Map<String, Account>();
      for(Account thisObject : AccountListToCheck){
        deDupedMap.put(thisObject.FirstName+thisObject.LastName+thisObject.Event_Email__pc, thisObject);
      }
      return deDupedMap;
    }

    global static void populateLeadConsentChange(Lead thisLead, String consentGiven, String consentStatement){
        String consentMappingKey;
        Map<String, String> leadConsentFieldsMap = new  Map<String, String>{
            'EMAIL_CONSENT'                => 'Email_Consent__c',
            'SMS_CONSENT'                  => 'SMS_Consent__c',
            'DIRECT_MAIL_CONSENT'          => 'Directmail_Consent__c',
            //'WHATSAPP_CONSENT'             => 'WhatsApp_Consent__c',
            'PHONE_CONSENT'                => 'Phone_Consent__c',
            'WEB_FORM_CONSENT'             => 'Web_Form_Consent__c',
            'LATEST_CONSENT_CHANGE_SOURCE' => 'Latest_Consent_Change_Source__c'};

            Map<String, String> leadConsentValuesMap = new  Map<String, String>{
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WEB_FORM_CONSENT'              => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_LATEST_CONSENT_CHANGE_SOURCE' => ct_EventConstants.LATEST_CONSENT_CHANGE_SOURCE_EVENT,

                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WEB_FORM_CONSENT'              => ct_EventConstants.CONSENT_VALUE_NO,
               
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WEB_FORM_CONSENT'              => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_LATEST_CONSENT_CHANGE_SOURCE' => ct_EventConstants.LATEST_CONSENT_CHANGE_SOURCE_EVENT,

                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WEB_FORM_CONSENT'              => ct_EventConstants.CONSENT_VALUE_NO,
               
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WEB_FORM_CONSENT'              => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_LATEST_CONSENT_CHANGE_SOURCE' => ct_EventConstants.LATEST_CONSENT_CHANGE_SOURCE_EVENT,

                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WEB_FORM_CONSENT'              => ct_EventConstants.CONSENT_VALUE_NO
            };

        for(String thisConsentField : leadConsentFieldsMap.keySet()){
            consentMappingKey = consentStatement+'_'+consentGiven+'_'+thisConsentField;
            if(leadConsentValuesMap.containsKey(consentMappingKey)){
                thisLead.put(leadConsentFieldsMap.get(thisConsentField), leadConsentValuesMap.get(consentMappingKey));
            }
        }
    }

    global static void populateContactConsentChange(Contact thisContact, String consentGiven, String consentStatement){
        String consentMappingKey;
        Map<String, String> contactConsentFieldsMap = new  Map<String, String>{
            'EMAIL_CONSENT'                => 'Email_Consent__c',
            'SMS_CONSENT'                  => 'SMS_Consent__c',
            'DIRECT_MAIL_CONSENT'          => 'Directmail_Consent__c',
           // 'WHATSAPP_CONSENT'             => 'WhatsApp_Consent__c',
            'PHONE_CONSENT'                => 'Phone_Consent__c',
            'LATEST_CONSENT_CHANGE_SOURCE' => 'Latest_Consent_Change_Source__c'};

            Map<String, String> contactConsentValuesMap = new  Map<String, String>{
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_LATEST_CONSENT_CHANGE_SOURCE' => ct_EventConstants.LATEST_CONSENT_CHANGE_SOURCE_EVENT,

                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
               
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_LATEST_CONSENT_CHANGE_SOURCE' => ct_EventConstants.LATEST_CONSENT_CHANGE_SOURCE_EVENT,

                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.R_AND_I_B2B_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
               
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_YES,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_YES+'_LATEST_CONSENT_CHANGE_SOURCE' => ct_EventConstants.LATEST_CONSENT_CHANGE_SOURCE_EVENT,

                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_EMAIL_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_SMS_CONSENT'                  => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_DIRECT_MAIL_CONSENT'          => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_WHATSAPP_CONSENT'             => ct_EventConstants.CONSENT_VALUE_NO,
                ct_EventConstants.ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT+'_'+ct_EventConstants.CONSENT_GIVEN_NO+'_PHONE_CONSENT'                => ct_EventConstants.CONSENT_VALUE_NO
            };

        for(String thisConsentField : contactConsentFieldsMap.keySet()){
            consentMappingKey = consentStatement+'_'+consentGiven+'_'+thisConsentField;
            if(contactConsentValuesMap.containsKey(consentMappingKey)){
                thisContact.put(contactConsentFieldsMap.get(thisConsentField), contactConsentValuesMap.get(consentMappingKey));
            }
        }
    }
    global static void populateAccountConsentChange(Account thisAccount, String consentGiven, String consentStatement){}
}