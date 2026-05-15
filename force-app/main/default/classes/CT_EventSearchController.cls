/**
 * @description       : Controller class for both Web and Internal Event registration form
 * @author            : Creation Admin
 * @group             : 
 * @last modified on  : 15-09-2021
 * @last modified by  : Rajeshkumar
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-29-2020   Creation Admin   Initial Version
**/
global without sharing class CT_EventSearchController {
  //Set class for retrieving event record with only specific publishing status 
  global static Set<String> EVENT_PUBLISHING_TO_INCLUDE = new Set<String>{ct_EventConstants.EVENT_PUBLISHING_WEBSITE_AND_REGISTRATION_PAGE};
  global static Set<String> EVENT_TO_DETAIL = new Set<String>{ct_EventConstants.EVENT_PUBLISHING_REGISTRATION_PAGE, ct_EventConstants.EVENT_PUBLISHING_WEBSITE_AND_REGISTRATION_PAGE};

  global static Map<String,  Event_Type__mdt> EventMetaDatatypeMap = ct_MetadataService.eventTypeMetaData;

  global  static String EventRecordTypeId = setRecordTypeId();
  global static String setRecordTypeId(){

    if(EventMetaDatatypeMap.get('Simple_Event').is_Complex_Event__c){
      return ct_EventConstants.COMPLEX_EVENT_RECORD_TYPE_ID;
    }
  
      return ct_EventConstants.SIMPLE_EVENT_RECORD_TYPE_ID;
    
  }
  /**
  * @description Method to retrieve event record based on Event name
  * @param eventName Event Name filter value
  * @return List<Event__c> 
  **/
	@AuraEnabled(cacheable=true)
  global static List<Event__c> searchEventsByName(String eventName) {
    // String EventRecordTypeId = setRecordTypeId();
    eventName = '%' + eventName + '%';
    return [SELECT Id, Web_Event_Name__c, Web_Event_Location__c, Event_Start_Date__c,Event_End_Date__c, Discount_Code__c, Discount_Code__r.Valid_From__c, Discount_Code__r.Valid_To__c, 
    FORMAT(Start_Time__c), FORMAT(End_Time__c), Web_Event_Short_Description__c, Web_Event_Pricing__c,Social_App_Visibility__c,
    Visible_Social_App__c,Web_Event_Image__c, Registration_Status__c, RecordTypeId FROM Event__c WHERE Web_Event_Name__c LIKE :eventName AND Active__c = true AND Event_Publishing__c IN :EVENT_PUBLISHING_TO_INCLUDE AND RecordTypeId =: EventRecordTypeId];
  }

  /**
  * @description Method to retrieve Event records bases on various filter criteria entered Search filter 
  * @param byName retrieve event record filtered by name
  * @param byType retrieve event record filtered by event type
  * @param byGroup retrieve event record filtered by event group
  * @param byEventId retrieve event record filtered by event Id
  * @return List<Event__c> 
  **/
  @AuraEnabled
  global static List<Event__c> getEventsBySearch(String byName, String byType, String byGroup, String byEventId){
    // String EventRecordTypeId = setRecordTypeId();

    String quertString = 'SELECT Id, Web_Event_Name__c, Web_Event_Location__c, Event_Start_Date__c,Event_End_Date__c, Discount_Code__c, Discount_Code__r.Valid_From__c, Discount_Code__r.Valid_To__c,'+ 
                          'FORMAT(Start_Time__c), FORMAT(End_Time__c), Web_Event_Short_Description__c, Web_Event_Pricing__c,'+
                          'Web_Event_Image__c,Social_App_Visibility__c,Visible_Social_App__c, Registration_Status__c, RecordTypeId FROM Event__c WHERE Id != null AND Event_Publishing__c IN:EVENT_PUBLISHING_TO_INCLUDE AND RecordTypeId =: EventRecordTypeId AND 	Event_End_Date__c>=Today';

    if(String.isNotBlank(byEventId)){
      if(String.valueOf(Id.valueOf(byEventId).getsobjecttype()) == 'Event_Registration__c'){
        quertString = quertString + ' AND Id IN (SELECT Event__c FROM Event_Registration__c WHERE Id = :byEventId)';
      }
      else if(String.valueOf(Id.valueOf(byEventId).getsobjecttype()) == 'Event__c')
      quertString = quertString + ' AND Id = :byEventId';
    }
    else {
      if(String.isNotBlank(byName)){
        byName = '%'+byName+'%';
        quertString = quertString + ' AND Web_Event_Name__c LIKE :byName';
      }
      if(String.isNotBlank(byType)){
        byType = '%'+byType+'%';
        quertString = quertString + ' AND Event_Type__c LIKE :byType';
      }
      if(String.isNotBlank(byGroup)){
        quertString = quertString + ' AND Event_Group__c = :byGroup AND Event_Group__r.Active__c = true AND Registration_Status__c !=\'Closed\'';
      } 
    }
    quertString = quertString + ' AND Active__c = true ORDER BY Web_Event_Name__c ASC';
    return Database.query(quertString);
  }

  /**
  * @description Method to retrieve event record by event or event registration Id
  * @param byEventId Event or Event registration Id
  * @return List<Event__c> 
  **/
  @AuraEnabled
  global static List<Event__c> getEventById(String byEventId){
    // String EventRecordTypeId = setRecordTypeId();

    String quertString = 'SELECT Id, Web_Event_Name__c, Web_Event_Location__c, Event_Start_Date__c,Event_End_Date__c, Discount_Code__c, Discount_Code__r.Valid_From__c, Discount_Code__r.Valid_To__c,'+ 
                          'FORMAT(Start_Time__c), FORMAT(End_Time__c), Web_Event_Short_Description__c, Web_Event_Pricing__c,'+
                          'Web_Event_Image__c,Social_App_Visibility__c,Visible_Social_App__c,Event_Publishing__c, Registration_Status__c, RecordTypeId FROM Event__c WHERE Id != null AND Event_Publishing__c IN:EVENT_TO_DETAIL AND RecordTypeId =: EventRecordTypeId';
    if(String.isNotBlank(byEventId)){
      if(String.valueOf(Id.valueOf(byEventId).getsobjecttype()) == 'Event_Registration__c'){
        quertString = quertString + ' AND Id IN (SELECT Event__c FROM Event_Registration__c WHERE Id = :byEventId)';
      }else if(String.valueOf(Id.valueOf(byEventId).getsobjecttype()) == 'Event__c')
        quertString = quertString + ' AND Id = :byEventId';
      } 
    return Database.query(quertString);
  }

  /**
  * @description Method to retrieve Event and its Event products for Web event Registration 
  * @param selectedEventId Event Id
  * @return Event__c 
  **/
  @AuraEnabled(cacheable=true)  
  global static Event__c fetchEventAndTickets(String selectedEventId) {
      // String EventRecordTypeId = setRecordTypeId();

      Event__c selectedEvent = [SELECT Id, Web_Event_Name__c, Web_Event_Location__c,Allow_Duplicate_Event_Registrations__c, Event_Start_Date__c,Event_End_Date__c, Discount_Code__c, Discount_Code__r.Valid_From__c, Discount_Code__r.Valid_To__c, Maximum_Registration__c, Event_Registrations_Available__c,
      FORMAT(Start_Time__c), FORMAT(End_Time__c), Web_Event_Short_Description__c, Web_Event_Long_Description__c, Web_Event_Pricing__c, Display_Order_Address_Fields__c, Order_Address_Fields_Mandatory__c,
      Web_Event_Image__c, Registration_Status__c,Social_App_Visibility__c,Visible_Social_App__c, RecordTypeId, (SELECT Id, Name, Event__r.Web_Event_Pricing__c, Minimum_Products_Per_Order__c, Allow_Guest_Registrations__c, Event_Product_Description__c, Event__r.Name, Total_Quantity_Available__c, Event_Product_Price__c, Quantity_Remaining__c,Max_Product_per_Order__c, Allow_Primary_Session__c, Is_Mandatory__c,Primary_Session_Interest_Heading__c, Primary_Session_Interest_Label__c, Anonymous_Only__c FROM Tickets__r) 
      FROM Event__c WHERE Active__c = true AND Id =:selectedEventId AND RecordTypeId =: EventRecordTypeId];
      return selectedEvent;
  }
    
  /**
  * @description Method to retrieve Event and its Event products for Internal event Registration 
  * @param selectedEventId Event Id
  * @return Event__c 
  **/
  @AuraEnabled(cacheable=true)    
  global static Event__c fetchEventAndTicketsForInternalComponent(String recordId) {

    // String EventRecordTypeId = setRecordTypeId();

    Event__c selectedEvent = [SELECT Id, Web_Event_Name__c, Web_Event_Location__c,Allow_Duplicate_Event_Registrations__c, Event_Start_Date__c,Event_End_Date__c, Discount_Code__c, Discount_Code__r.Valid_From__c, Discount_Code__r.Valid_To__c,Maximum_Registration__c, Event_Registrations_Available__c,
    FORMAT(Start_Time__c), FORMAT(End_Time__c), Web_Event_Short_Description__c, Web_Event_Long_Description__c, Web_Event_Pricing__c, Display_Order_Address_Fields__c, Order_Address_Fields_Mandatory__c,
    Web_Event_Image__c, Registration_Status__c,Social_App_Visibility__c,Visible_Social_App__c, RecordTypeId, (SELECT Id, Name, Event__r.Web_Event_Pricing__c, Minimum_Products_Per_Order__c, Allow_Guest_Registrations__c, Event_Product_Description__c, Event__r.Name, Total_Quantity_Available__c, Event_Product_Price__c, Quantity_Remaining__c, Max_Product_per_Order__c, Allow_Primary_Session__c, Is_Mandatory__c,Primary_Session_Interest_Heading__c, Primary_Session_Interest_Label__c, Anonymous_Only__c FROM Tickets__r) 
    FROM Event__c WHERE Active__c = true AND Id =:recordId AND RecordTypeId =: EventRecordTypeId];
    return selectedEvent;
  }

  /**
  * @description Method to retrieve Event Event product details of specific event Registration 
  * @param selectedEventId Event registration Id
  * @return Event_Registration__c 
  **/
  @AuraEnabled
  global static Event_Registration__c fetchEventProductDetails(String eventRegistrationId){
    return [SELECT Id, First_Name__c, Last_Name__c, Event_Email__c,Event_Mobile__c,Street__c,City__c,State_County__c,Zip_Postal_Code__c,Country__c,
              Event_Order__c, Event_Order__r.First_Name__c, Event_Order__r.Last_Name__c, Event_Order__r.Email__c,Event_Order__r.Mobile__c,Event_Order__r.Street__c,Event_Order__r.City__c,Event_Order__r.State__c,Event_Order__r.Post_code__c,Event_Order__r.Country__c
                    FROM Event_Registration__c 
                    WHERE Id =: eventRegistrationId];  
  }

  /**
  * @description Method to Save Event order and Event registration from registration forms
  * @param ticketOrderAsJson Event Order Details as JSON string
  * @param eventRegistrationAsJson Event registration Details as JSON string
  * @param urlParamId Event Id or existing Event Order Id
  * @param asperatoId Asperato payement Id
  * @param sendOrderEmail Boolean variable based on which Event Order email is managed for Internal event registration
  * @param totalPrice Total price of the event order if paid order
  * @param isInternal Boolean variable to specify the submission type i.e Internal event registration and web event registration
  * @param isCheckInManager Boolean variable to specify whether the submission is made from check in manager
  * @param internalRegData Internal Submission data As JSON String
  * @param consentgiven Boolean variable to denote whether the user has give communication consent
  * @return EventRegistrationWrapper 
  **/
  @AuraEnabled
  global static EventRegistrationWrapper saveEventTicketOrder(String ticketOrderAsJson, String eventRegistrationAsJson, String urlParamId, String asperatoId, Boolean sendOrderEmail, Decimal totalPrice, Boolean isInternal, Boolean isCheckInManager, String internalRegData, String consentgiven) {
    Map<String, Object> internalRegistrationData = new Map<String, Object>();
    Map<String, String> webSiteSubmissionMapToUpdate = new Map<String, String>();
    if(!String.isEmpty(internalRegData)){
      internalRegistrationData = (Map<String, Object>)JSON.deserializeUntyped(internalRegData);
    }
    TicketOrder ticketOrderData = (TicketOrder) Json.deserialize(ticketOrderAsJson, TicketOrder.class);
    List<EventRegistration> registrations = (List<EventRegistration>) Json.deserialize(eventRegistrationAsJson, List<EventRegistration>.class);
    Event_Order__c ticketOrder = new Event_Order__c();
    if((String.isBlank(urlParamId) && urlParamId == null) ||  String.valueOf(Id.valueOf(urlParamId).getsobjecttype()) == 'Event__c' 
        && ((!ticketOrderData.eventRegHasOrder && ticketOrderData.ordId == null && String.isBlank(ticketOrderData.ordId)) || (ticketOrderData.eventRegHasOrder && ticketOrderData.ordId != null && !String.isBlank(ticketOrderData.ordId)))){
    ticketOrder.Id                                     = ticketOrderData.ordId;
    ticketOrder.Event__c                               = ticketOrderData.eventId;
    ticketOrder.First_Name__c                          = ticketOrderData.firstName;
    ticketOrder.Last_Name__c                           = ticketOrderData.lastName;
    ticketOrder.Email__c                               = ticketOrderData.email;
    //ticketOrder.Asperato_Payment__c                    = asperatoId;
    ticketOrder.Consent_Given__c                       = consentgiven;
    ticketOrder.Mobile__c                              = ticketOrderData.mobile;
    ticketOrder.Street__c                              = ticketOrderData.street;
    ticketOrder.City__c                                = ticketOrderData.city;
    ticketOrder.State__c                               = ticketOrderData.state;
    ticketOrder.Country__c                             = ticketOrderData.country;
    ticketOrder.Post_code__c                           = ticketOrderData.postcode;
    ticketOrder.Order_Source__c                        = (isInternal == null || !isInternal) ?  ct_EventConstants.ORDER_SOURCE_WEB_ORDER : ct_EventConstants.ORDER_SOURCE_INTERNAL_ORDER;
    ticketOrder.Total_number_of_ticket_requested__c    = registrations.size();
    ticketOrder.Send_Payment_Email_to_Order_Contact__c = sendOrderEmail;
    ticketOrder.Order_Status__c                        = totalPrice > 0 ? 'Awaiting Payment' : 'Active';
    // Group booking
    ticketOrder.Is_Group_Booking__c = ticketOrderData.isGroupBooking != null ? ticketOrderData.isGroupBooking : false;
    ticketOrder.Number_of_Attendees__c = ticketOrderData.numberOfAttendees != null ? ticketOrderData.numberOfAttendees : registrations.size();
    //Add Discount Details
    Event__c thisEvent = getEvent(ticketOrderData.eventId);
    if(ticketOrderData.isDiscountedOrder){
      ticketOrder.Discount_Code_Applied__c = true;
      ticketOrder.Discount_Code_Used__c    = thisEvent.Discount_Code__c;
    }
    try{
      upsert ticketOrder;
      Boolean hasOnlyAnonymous = true;
      for (eventRegistration eachRegistration : registrations) {
        if(hasOnlyAnonymous && eachRegistration.attendeeType != ct_EventConstants.EVENT_REGISTRATION_TYPE_UNKNOWN_GUEST){
          hasOnlyAnonymous = false;
        }
      }
      //If the Event order has only Event registrations with only Anonymous ticket, then manually invoke platform event for populating
      //Contact or Lead in Event order
      if(hasOnlyAnonymous){
        List<String> eventDetailsDataList = new List<String>();
        Map<String,String> orderMap = new Map<String,String>();
        orderMap.put('recId', ticketOrder.Id);
        orderMap.put('firstName', ticketOrder.First_Name__c);
        orderMap.put('lastName', ticketOrder.Last_Name__c);
        orderMap.put('email', ticketOrder.Email__c);

        String jsonStr = JSON.serialize(orderMap);
        eventDetailsDataList.add(jsonStr);
        ct_Event_RegistrationTriggerHelper.triggerWebSiteSubmissionPlatformEvent(eventDetailsDataList);
      }

    }
    catch(Exception e){
      //Exception mechanism to log any exceptions occured during the dml operation
      ct_Logger.logMessage(e, 'Event Registration');
      throw new AuraHandledException('Error '+ e.getMessage());
    }
  }
    List<Event_Registration__c> eventRegistrations = new List<Event_Registration__c>();
    Map<Integer, String> eventRegToCampaignMemberMap = new Map<Integer, String>();

    Map<String, Event_Registration__c> eventRegPrimarySessionMap = new Map<String, Event_Registration__c>();
    Map<String, String> eventRegToSessionIdsMap = new Map<String, String>();
    Integer eventRegCount = 0;
    
    //Process Event registration record from Event Registration JSON String
    for (eventRegistration eachRegistration : registrations) {
      Event_Registration__c eventRegistration = new Event_Registration__c();
      eventRegistration                   =  eachRegistration.eventRegistration;
      System.debug('eachRegistration.eventRegId'+eachRegistration.eventRegId);
      if(eventRegCount>0){
        eachRegistration.eventRegId       = null; 
        eachRegistration.campaignRefId    = null;
      }

      if(String.isNotBlank(eachRegistration.eventRegId)){
        eventRegistration.Id   = eachRegistration.eventRegId;
      }
      else if(String.isNotBlank(eachRegistration.campaignRefId)){
        eventRegistration.Id   = eachRegistration.campaignRefId;
      }

      if(String.isBlank(eachRegistration.eventRegId) && String.isBlank(eachRegistration.campaignRefId)){
        eventRegistration.Event__c          = ticketOrderData.eventId;
      }
      if(/*String.isBlank(eachRegistration.eventRegId) || */String.isBlank(eachRegistration.campaignRefId)){
        eventRegistration.Event_Product__c  = eachRegistration.ticketId;
      }
      if((!ticketOrderData.eventRegHasOrder && ticketOrderData.ordId == null && String.isBlank(ticketOrderData.ordId)) 
        || (ticketOrderData.eventRegHasOrder && ticketOrderData.ordId != null && !String.isBlank(ticketOrderData.ordId))){
        eventRegistration.Event_Order__c = ticketOrder.Id;
      }
      eventRegistration.First_Name__c                    = eachRegistration.firstName;
      eventRegistration.Last_Name__c                     = eachRegistration.lastName;
      eventRegistration.Event_Email__c                   = eachRegistration.email;
      eventRegistration.Event_Mobile__c                  = eachRegistration.mobile;
      eventRegistration.Event_Registration_Status__c     = ct_EventConstants.EVENT_REGISTRATION_NEW;
      eventRegistration.Event_Registration_Source__c     = (isInternal == null || !isInternal) ?  ct_EventConstants.EVENT_REGISTRATION_SOURCE_WEB_ORDER : ct_EventConstants.EVENT_REGISTRATION_SOURCE_INTERNAL_ORDER;
      eventRegistration.RecordTypeId                     = ct_EventConstants.EVENT_REGISTRATION_MASTER_EVENT_RECORD_TYPE_ID;
      eventRegistration.Registration_Type__c             = eachRegistration.attendeeType;                                                                                                                              //eachRegistration.isGuest ? ct_EventConstants.EVENT_REGISTRATION_TYPE_GUEST : ct_EventConstants.EVENT_REGISTRATION_TYPE_NAMED_ATTENDEE;
      eventRegistration.Primary_Subject_Area_Interest__c = eachRegistration.primaryAreaInterest;
      System.debug('eachRegistration.eventRegId>>>>>>>>>>>>>>>>>>>>>> '+eachRegistration.eventRegId);
      // if(String.isNotBlank(eachRegistration.eventRegId)){
      //   eventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_REGISTERED;
      // }

      if (eachRegistration.attendeeType == 'Myself' || 
        eachRegistration.attendeeType == 'Someone Else' || 
        eachRegistration.attendeeType == 'Unknown Guest' || 
        String.isNotBlank(eachRegistration.eventRegId)) {
            
            eventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_REGISTERED;
      }

      //If submitted from Check in manager and Set Event registration to Checked Is is True, then update the status as Checked IN 
      if(isCheckInManager != null
        && isCheckInManager
        && !internalRegistrationData.isEmpty()
        && internalRegistrationData.containsKey('setEventRegCheckedIn')
        && Boolean.valueOf(internalRegistrationData.get('setEventRegCheckedIn'))){
        eventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN;
      }  
      
      eventRegistrations.add(eventRegistration);
      processDuplicateEventRegistration(eventRegistration, eachRegistration);
      
      if(eventRegistration.Id != null && eachRegistration.campaignMember != null){
        webSiteSubmissionMapToUpdate.put(String.valueOf(Id.valueOf(eventRegistration.Id)).substring(0, 15), eachRegistration.campaignMember);
      }
      else if(eachRegistration.campaignMember != null){
      eventRegToCampaignMemberMap.put(eventRegCount, eachRegistration.campaignMember);
      }

      if(String.isNotBlank(eachRegistration.primarySessionIds)){
        eventRegToSessionIdsMap.put('EVENT_REG_'+eventRegCount, eachRegistration.primarySessionIds);
        eventRegPrimarySessionMap.put('EVENT_REG_'+eventRegCount, eventRegistration);
      }
      eventRegCount = eventRegCount +1;
    }
    try{
      if(!webSiteSubmissionMapToUpdate.isEmpty()){
        Map<String, Web_Site_Submission__c> eventRegIdToWebsubMap = new Map<String, Web_Site_Submission__c>();

        for(Web_Site_Submission__c thisSubmission : [SELECT Name,Payload__c FROM Web_Site_Submission__c WHERE Name IN: webSiteSubmissionMapToUpdate.keySet()]){
          eventRegIdToWebsubMap.put(thisSubmission.Name, thisSubmission);
        }

        List<Web_Site_Submission__c> websiteSubmissionList = new List<Web_Site_Submission__c>();

        for(String thisSubmissionName : webSiteSubmissionMapToUpdate.keySet()){
          if(eventRegIdToWebsubMap.isEmpty()
            || !eventRegIdToWebsubMap.containsKey(thisSubmissionName)){
              //create a instance for Web Site Submission with web form information 
              Web_Site_Submission__c webSubmissionObject = new Web_Site_Submission__c();
              webSubmissionObject.Name                   = thisSubmissionName;
              webSubmissionObject.Source__c				       = ct_EventConstants.WEB_SUBMISSION_SOURCE_EVENT;
              webSubmissionObject.Payload__c             = webSiteSubmissionMapToUpdate.get(thisSubmissionName);
              websiteSubmissionList.add(webSubmissionObject);    
            }
            else if(eventRegIdToWebsubMap.containsKey(thisSubmissionName)){
              eventRegIdToWebsubMap.get(thisSubmissionName).Payload__c = webSiteSubmissionMapToUpdate.get(thisSubmissionName);
              websiteSubmissionList.add(eventRegIdToWebsubMap.get(thisSubmissionName));
            }
        }
        upsert websiteSubmissionList;
      }
      System.debug('eventRegistrations-Size>>>>>>>> '+eventRegistrations.size());
      System.debug('eventRegistrations-List>>>>>>>> '+eventRegistrations);

      upsert eventRegistrations;

      if(!eventRegToCampaignMemberMap.isEmpty()){
        try{
          system.debug('eventsubmission');
          insert constructWebSubmissionEvent(eventRegistrations, eventRegToCampaignMemberMap);
        }
        catch(Exception e){
          //Exception mechanism to log any exceptions occured during the dml operation
          ct_Logger.logMessage(e, 'Web Site Submission');
          throw new AuraHandledException('Error '+ e.getMessage());
        }
      }

      EventRegistrationWrapper thisEventRegistrationWrapper  = new EventRegistrationWrapper();
      thisEventRegistrationWrapper.salesforceDomainURL       = ct_EventConstants.SITE_BASE_URL;
      thisEventRegistrationWrapper.eventRegistrationRecords  = eventRegistrations;
      thisEventRegistrationWrapper.ticketOrderId             = ticketOrder.Id;
      thisEventRegistrationWrapper.eventRegToSessionIdsMap   = eventRegToSessionIdsMap;
      thisEventRegistrationWrapper.eventRegPrimarySessionMap = eventRegPrimarySessionMap;
      return thisEventRegistrationWrapper;
    }
    catch(Exception e){
      //Exception mechanism to log any exceptions occured during the dml operation
      ct_Logger.logMessage(e, 'Event Registration');
      throw new AuraHandledException('Error '+ e.getMessage());
    }
  }

  /**
  * @description Method to retrieve Event Question for Event Product question
  * @param productIds Event product Id
  * @return Map<Id, Set<String>> 
  **/
  global static Map<Id, Set<String>>  getEventProductQuestionAPIName(Set<Id> productIds){
    Map<Id, Set<String>> questionSetQuestionsAPI = new Map<Id, Set<String>>();
    Map<Id, Set<String>> productQuestionsAPI = new Map<Id, Set<String>>();

    for(Questions__c thisQuestion : [SELECT Id, Name, Data_Type__c, Even_Registration_Field_API_Name__c, Event_Question_Set__c, Question__c
                                      FROM Questions__c
                                      WHERE Event_Question_Set__c IN (SELECT Event_Question_Set__c FROM Event_Product__c WHERE Id =:productIds)
                                      ORDER BY Question_Order__c ASC]){
      thisQuestion.Question__c = thisQuestion.Question__c.replaceAll('<p><br></p>', '');
      thisQuestion.Question__c = thisQuestion.Question__c.trim();
      if(questionSetQuestionsAPI.isEmpty()
        || !questionSetQuestionsAPI.containsKey(thisQuestion.Event_Question_Set__c)){
          questionSetQuestionsAPI.put(thisQuestion.Event_Question_Set__c, new Set<String>());
      }
      
      questionSetQuestionsAPI.get(thisQuestion.Event_Question_Set__c).add(thisQuestion.Question__c);
      if( thisQuestion.Data_Type__c == ct_EventConstants.QUESTION_DATA_TYPE_TEXT_DEPENDENT_PICKLIST
          && thisQuestion.Dependent_Question_Setup__c != null){
          for(String thisKey: thisQuestion.Dependent_Question_Setup__c.split('\n')){
            String fieldName;
            String objectName;
            String picklistKey;
            String value = null;

            if(String.isNotBlank(thisKey)){
              if(thisKey.contains('Field=')){
                fieldName = thisKey.substringAfter('Field=').trim();
              }
              if(thisKey.contains('Object=')){
                objectName = thisKey.substringBetween('Object=','Field=');
              }
            } 

            if(!String.isBlank(fieldName) 
              && !String.isBlank(objectName)
              && objectName == ct_EventConstants.QUESTION_OBJECT_TYPE_EVENT_REGISTRATION){
                questionSetQuestionsAPI.get(thisQuestion.Event_Question_Set__c).add(fieldName);
            }
          }
      }
    }

    for(Event_Product__c thisEventProduct : [SELECT Id, Event_Question_Set__c 
                                              FROM Event_Product__c
                                              WHERE Id =:productIds
                                              AND Event_Question_Set__c != null]){
      if(!questionSetQuestionsAPI.isEmpty()
        && questionSetQuestionsAPI.containsKey(thisEventProduct.Event_Question_Set__c)){
        productQuestionsAPI.put(thisEventProduct.Id, questionSetQuestionsAPI.get(thisEventProduct.Event_Question_Set__c));
      }                           
    }
    return productQuestionsAPI;
  }
  
  /**
  * @description Method to generate Web submission for storing Event Registration's Campaign member details
  * @param registeredEventRegistrations Event registration record
  * @param eventRegToCampaignMembers Campaign member details
  * @return List<Web_Site_Submission__c> 
  **/
  global static List<Web_Site_Submission__c>  constructWebSubmissionEvent(List<Event_Registration__c> registeredEventRegistrations, Map<Integer, String> eventRegToCampaignMembers){
    List<Web_Site_Submission__c> webSiteSubmissionToInsert = new List<Web_Site_Submission__c>();
    System.debug('Map ========================'+eventRegToCampaignMembers);

    for(Integer i=0 ; i<registeredEventRegistrations.size(); i++){
      if(eventRegToCampaignMembers.containsKey(i)){
        //create a instance for Web Site Submission with web form information 
        Web_Site_Submission__c webSubmissionObject = new Web_Site_Submission__c();
        webSubmissionObject.Name                   = String.valueOf(Id.valueOf(registeredEventRegistrations[i].Id)).substring(0, 15);
        webSubmissionObject.Source__c				       = ct_EventConstants.WEB_SUBMISSION_SOURCE_EVENT;
        webSubmissionObject.Email__c               = registeredEventRegistrations[i].Event_Email__c;
        webSubmissionObject.Payload__c             = eventRegToCampaignMembers.get(i);
        webSiteSubmissionToInsert.add(webSubmissionObject);    
      }
    }

    return webSiteSubmissionToInsert;
  }

  /**
  * @description Method to create primary session registration if selected in registration form
  * @param registeredEventRegistrations New Event Registration record 
  * @param eventRegToSessionIds Event Registration to primary session ID
  * @return List<Session_Registration__c> 
  **/
  global static List<Session_Registration__c> createPrimarySessionRegistrations(Map<String, Event_Registration__c> registeredEventRegistrations, Map<String, String> eventRegToSessionIds){
    Map<String, String> eventRegToSessionIdsMapVar;
    Map<String, Event_Registration__c> eventRegPrimarySessionMapVar;

    List<Session_Registration__c> sessionRegToInsert = new List<Session_Registration__c>();

    for(String uniqueKey : eventRegToSessionIds.keySet()){
      if(registeredEventRegistrations.containsKey(uniqueKey)){
        Session_Registration__c thisSessionReg = new Session_Registration__c();
        thisSessionReg.Event_Registration__c		= registeredEventRegistrations.get(uniqueKey).Id;
        thisSessionReg.QR_Code__c								= registeredEventRegistrations.get(uniqueKey).QR_Code__c;
        thisSessionReg.Session__c								= eventRegToSessionIds.get(uniqueKey);
        thisSessionReg.Status__c								= ct_EventConstants.SESSION_REGISTRATION_REGISTERED;
        sessionRegToInsert.add(thisSessionReg);
      }
    }
    return sessionRegToInsert;
  }

    
  /**
  * @description Method to process the Duplicate registration if found
  * @param thisEventRegistration This Duplicate Event registration instance 
  * @param eventRegistrationWrapper New Event registration Data from form
  **/
  global static void processDuplicateEventRegistration(Event_Registration__c thisEventRegistration , eventRegistration eventRegistrationWrapper){
    Set<String> eventRegistrationFieldToReset = new Set<String>{'Cancellation_Description__c', 
                                                                'Cancellation_Reason__c',
                                                                'City__c',
                                                                'Country__c',
                                                                'Zip_Postal_Code__c',
                                                                'Street__c',
                                                                'State_County__c'};

    Set<String> deduplicateEventRegistrationStatus = new Set<String>{ct_EventConstants.EVENT_REGISTRATION_NEW, 
                                                                      ct_EventConstants.EVENT_REGISTRATION_INVITED, 
                                                                      ct_EventConstants.EVENT_REGISTRATION_DECLINED,
                                                                      ct_EventConstants.EVENT_REGISTRATION_CANCELLED};
    if(!eventRegistrationWrapper.allowDuplicate
    && eventRegistrationWrapper.hasDuplicateEventRegistration 
    && !String.isEmpty(eventRegistrationWrapper.duplicateEventRegistrationId)
    && !String.isEmpty(eventRegistrationWrapper.duplicateEventRegistrationStatus)){
      if(deduplicateEventRegistrationStatus.contains(eventRegistrationWrapper.duplicateEventRegistrationStatus)){
        thisEventRegistration.Id                           = eventRegistrationWrapper.duplicateEventRegistrationId;
        thisEventRegistration.Event_Registration_Status__c = ct_EventConstants.EVENT_REGISTRATION_REGISTERED;
      }

      if(eventRegistrationWrapper.duplicateEventRegistrationStatus == ct_EventConstants.EVENT_REGISTRATION_CANCELLED){
        for(String thisField : eventRegistrationFieldToReset){
          thisEventRegistration.put(thisField, null);
        }
      }
      processDuplicateEventRegistrationLeadContact(eventRegistrationWrapper.duplicateEventRegistrationId, eventRegistrationWrapper);
    }
  }

  /**
  * @description Method to Process Duplicate event registration's Lead / Contact
  * @param eventRegId Duplicate event registration Id
  * @param eventRegistrationWrapper New Event registration Data from form
  **/
  global static void processDuplicateEventRegistrationLeadContact(String eventRegId, eventRegistration eventRegistrationWrapper){
    try{
      List<Event_Registration__c> thisEventRegistrationToUpdate =[SELECT Id, Contact__c, Enquirer__c, Account_Name__c
                                                                    FROM Event_Registration__c
                                                                    WHERE Id =:eventRegId];
      List<SObject> sobjectListToUpdate = new List<SObject>();

      if(!thisEventRegistrationToUpdate.isEmpty()){
        if(thisEventRegistrationToUpdate[0].Enquirer__c != null){
          Lead thisEnquirerToUpdate      = new Lead();
          thisEnquirerToUpdate.Id        = thisEventRegistrationToUpdate[0].Enquirer__c;
          thisEnquirerToUpdate.FirstName = eventRegistrationWrapper.firstName;
          thisEnquirerToUpdate.LastName  = eventRegistrationWrapper.LastName;
          sobjectListToUpdate.add(thisEnquirerToUpdate);
        }

        /*if(thisEventRegistrationToUpdate[0].Contact__c != null){
          Contact thisContactToUpdate   = new Contact();
          thisContactToUpdate.Id        = thisEventRegistrationToUpdate[0].Contact__c;
          thisContactToUpdate.FirstName = eventRegistrationWrapper.firstName;
          thisContactToUpdate.LastName  = eventRegistrationWrapper.LastName;
          sobjectListToUpdate.add(thisContactToUpdate);
        }*/

        if(thisEventRegistrationToUpdate[0].Account_Name__c != null){
          Account thisAccountToUpdate = new Account();
          thisAccountToUpdate.Id        = thisEventRegistrationToUpdate[0].Account_Name__c;
          thisAccountToUpdate.FirstName = eventRegistrationWrapper.firstName;
          thisAccountToUpdate.LastName  = eventRegistrationWrapper.LastName;
          sobjectListToUpdate.add(thisAccountToUpdate);
        }
      }

      if(!sobjectListToUpdate.isEmpty()){
        update sobjectListToUpdate;
      }
    }
    catch(Exception e){
      //Exception mechanism to log any exceptions occured during the dml operation
      ct_Logger.logMessage(e, 'Process Duplicate Event Registration Lead Account');
      throw new AuraHandledException('Error '+ e.getMessage());
    }
  }

  /*global static void processDuplicateEventRegistrationLeadContact(String eventRegId, eventRegistration eventRegistrationWrapper){
    try{
      List<Event_Registration__c> thisEventRegistrationToUpdate =[SELECT Id, 	Account_Name__c, Enquirer__c
                                                                    FROM Event_Registration__c
                                                                    WHERE Id =:eventRegId];
      List<SObject> sobjectListToUpdate = new List<SObject>();

      if(!thisEventRegistrationToUpdate.isEmpty()){
        if(thisEventRegistrationToUpdate[0].Enquirer__c != null){
          Lead thisEnquirerToUpdate      = new Lead();
          thisEnquirerToUpdate.Id        = thisEventRegistrationToUpdate[0].Enquirer__c;
          thisEnquirerToUpdate.FirstName = eventRegistrationWrapper.firstName;
          thisEnquirerToUpdate.LastName  = eventRegistrationWrapper.LastName;
          sobjectListToUpdate.add(thisEnquirerToUpdate);
        }

        if(thisEventRegistrationToUpdate[0].Account_Name__c != null){
          Account thisAccountToUpdate   = new Account();
          thisAccountToUpdate.Id        = thisEventRegistrationToUpdate[0].Account_Name__c;
          thisAccountToUpdate.FirstName = eventRegistrationWrapper.firstName;
          thisAccountToUpdate.LastName  = eventRegistrationWrapper.LastName;
          sobjectListToUpdate.add(thisAccountToUpdate);
        }
      }

      if(!sobjectListToUpdate.isEmpty()){
        update sobjectListToUpdate;
      }
    }
    catch(Exception e){
      //Exception mechanism to log any exceptions occured during the dml operation
      ct_Logger.logMessage(e, 'Process Duplicate Event Registration Lead Contact');
      throw new AuraHandledException('Error '+ e.getMessage());
    }
  }*/

  /**
  * @description Method to retrieve Event Order
  * @param ordId Event order Id
  * @return Event_Order__c 
  **/
  @AuraEnabled
  global static Event_Order__c fetchEventOrderDetails(String ordId){
    return [Select Id, First_Name__c, Last_Name__c, Email__c from Event_Order__c Where id =: ordId];
  }

  /**
  * @description Method to retrieve consent details from event record
  * @param eventId Event Record Id
  * @return Event__c 
  **/
  @AuraEnabled(cacheable=true)
  global static Event__c getEventConsentCapture(String eventId){
    
    // String EventRecordTypeId = setRecordTypeId();

    return [Select Id, Statement_Title__c, Discount_Code_In_Force__c, Discount_Code__c, Statement_Text_above_dec__c, Declaration_Text__c,Statement_Text_below_dec__c, Consent_Required_to_Register__c, RecordTypeId FROM Event__c WHERE Id =: eventId AND RecordTypeId =: EventRecordTypeId LIMIT 1];
  }

  /**
  * @description Method to create Asperato payment for Paid event order
  * @param ticketOrderAsJson Event order detail for which Asperato payment needs to be created
  * @param TotalPrice Total price for Event order
  * @return Map<String, String> 
  **/
  @AuraEnabled
  global static  Map<String, String> createNewAsperatoPayment(String ticketOrderAsJson, Decimal TotalPrice){
    Map<String, String> asperatoPaymentDetails = new Map<String, String>();
    system.debug('hi>>');
    try {
      TicketOrder ticketOrderData = (TicketOrder) Json.deserialize(ticketOrderAsJson, TicketOrder.class);
      // asp04__Payment__c asperatoPayment                       = new asp04__Payment__c();
      // asperatoPayment.asp04__Amount__c                        = TotalPrice;
      // asperatoPayment.asp04__Payment_Route_Options__c         = ct_Constants.ASPERATO_CARD_PAYMENT_METHOD;
      // asperatoPayment.asp04__Payment_Route_Selected__c        = ct_Constants.ASPERATO_CARD_PAYMENT_METHOD;
      // asperatoPayment.asp04__First_Name__c                    = ticketOrderData.firstName;
      // asperatoPayment.asp04__Last_Name__c                     = ticketOrderData.lastName;
      // asperatoPayment.asp04__Email__c                         = ticketOrderData.email;
      // asperatoPayment.asp04__Due_Date__c                      = System.today();
      // system.debug('asperatoPayment>>'+asperatoPayment);
      // insert asperatoPayment;
      // system.debug('asperatoPayment>>'+asperatoPayment);
      // asperatoPayment.asp04__Success_Endpoint_Long__c = ct_EventConstants.SITE_BASE_URL+'/ledevents/s/order-confirmation?asperatoId='+asperatoPayment.Id;
      // update asperatoPayment;
      // asperatoPaymentDetails.put('ASPERATO_ID', asperatoPayment.Id);
      // asperatoPaymentDetails.put('AMOUNT', String.valueOf(asperatoPayment.asp04__Amount__c ));
      // asperatoPaymentDetails.put('ASPERATO_PAYMENT_URL', getAsperatoPaymentURL(asperatoPayment.Id));
    }
    catch (Exception e) {
      //Exception mechanism to log any exceptions occurred during the dml operation
      ct_Logger.logMessage(e, 'Asperato Payment');
      throw new AuraHandledException('Error '+ e.getMessage());
    }
    return asperatoPaymentDetails;
  }

  /**
  * @description Method to construct Asperato payment URL
  * @param asperatoPaymentId Asperato Payment ID
  * @return string 
  **/
  global static string getAsperatoPaymentURL(Id asperatoPaymentId){
    String payementURL = 'https://';
    //asp04__AsperatoOneSettings__c thisAsperatoSetting      = ct_CustomSettingService.getCurrentUserAsperatoSetting();
    //payementURL = payementURL + thisAsperatoSetting.asp04__Server_URL__c + '/PMWeb1?pmRef=' + thisAsperatoSetting.asp04__Customer_ID__c+'&pid='+asperatoPaymentId; 
    return payementURL;
  }

  /**
  * @description Method to construct picklist wrapper for lightning combo box dropdown 
  * @param objectName Object API Name
  * @param fieldName Picklist field API Name
  * @return List<PicklistEntryWrapper> 
  **/
  @AuraEnabled
  global static  List<PicklistEntryWrapper> getPicklistValues(String objectName, String fieldName){
    return constructPicklistEntryWrapper(ct_WebDataFormHelper.getPicklistValues(objectName, fieldName));
  }

  /**
  * @description Method to construct picklist wrapper for lightning combo box dropdown
  * @param picklistEntryList Schema picklist entry
  * @return List<PicklistEntryWrapper> 
  **/
  private static List<PicklistEntryWrapper> constructPicklistEntryWrapper(List<Schema.PicklistEntry> picklistEntryList){
    List<PicklistEntryWrapper> thisPickListWrapperList        = new List<PicklistEntryWrapper>();
    //Loop through the picklist entries to construct picklist options
    for( Schema.PicklistEntry thisPicklistEntry : picklistEntryList){
      thisPickListWrapperList.add(new PicklistEntryWrapper(thisPicklistEntry.getLabel(), thisPicklistEntry.getValue()));
    }
    return thisPickListWrapperList;
  }

  /**
  * @description Method to retrieve Event group record
  * @return List<Wrapper>  
  **/
  @AuraEnabled
  global static List<Wrapper> getEventGroups(){
    List<Wrapper> eventGroupWrapperList = new List<Wrapper>();
    try{
      for(Event_Group__c thisEventGroup : [SELECT Id, Name FROM Event_Group__c 
                                          WHERE Active__c = true 
                                          ORDER BY Name asc
                                          LIMIT 50000]){
        eventGroupWrapperList.add(new Wrapper(thisEventGroup));
      }
    }
    catch (Exception ex){
      ct_Logger.logMessage(ex, 'Event Group Lookup Component');
      throw new AuraHandledException('Error '+ ex.getMessage() + ex.getLineNUmber());

    }
    //return list of course records
    return eventGroupWrapperList;
  }

  /**
  * @description Method to save the QR code and QR code URL in event registration
  * @param eventRegistrationAsJson Event registration with QR code and QR code URL
  * @param isCheckInManager Boolean variable to specify whether the submission is made from check in manager
  * @param internalRegData Internal Submission data As JSON String
  * @param eventRegToSessionIdsMap Event registration with its Session Map
  * @param eventRegPrimarySessionMap Event registration with its corresponding primary area of interest map
  **/
  @AuraEnabled
  global static void saveQRCode(String eventRegistrationAsJson, Boolean isCheckInManager, String internalRegData, String eventRegToSessionIdsMap, String eventRegPrimarySessionMap) {
    try{

      Map<String, String> eventRegToSessionIdsMapVar = new  Map<String, String>();
      Map<String, Event_Registration__c> eventRegPrimarySessionMapVar = new Map<String, Event_Registration__c>();
      if(!String.isEmpty(eventRegToSessionIdsMap)){
        eventRegToSessionIdsMapVar = (Map<String, String>) Json.deserialize(eventRegToSessionIdsMap, Map<String, String>.class);
      }

      if(!String.isEmpty(eventRegPrimarySessionMap)){
        eventRegPrimarySessionMapVar = (Map<String, Event_Registration__c>) Json.deserialize(eventRegPrimarySessionMap,  Map<String, Event_Registration__c>.class);
      }
      
      List<Event_Registration__c> registrations = (List<Event_Registration__c>) Json.deserialize(eventRegistrationAsJson, List<Event_Registration__c>.class);
      ct_Event_RegistrationTriggerHandler.turnOff();
      
      //added by Anshul to keep the Event Registration Status as Registered
      /*Set<Id> eventRegistrationIds = new Set<Id>();
      for (Event_Registration__c eachReg : registrations) {
          if (eachReg.Event_Registration_Status__c == 'New') {
              eachReg.Event_Registration_Status__c = 'Registered';
          }
          eventRegistrationIds.add(eachReg.Id);
      }*/
        
      update registrations;
      
      // GROUP BOOKING
      if (!registrations.isEmpty()) {
          Id orderId = registrations[0].Event_Order__c;
          
          Event_Order__c parentOrder = [SELECT Id, Is_Group_Booking__c 
                                                      FROM Event_Order__c 
                                                      WHERE Id = :orderId LIMIT 1];
          
          if (parentOrder.Is_Group_Booking__c == true) {
              parentOrder.QR_Code__c = registrations[0].QR_Code__c;
              parentOrder.QR_Code_URL__c = registrations[0].QR_Code_URL__c;
              update parentOrder;
          }
      }
      Map<String, Object> internalRegistrationData = new Map<String, Object>();
      if(!String.isEmpty(internalRegData)){
        internalRegistrationData = (Map<String, Object>)JSON.deserializeUntyped(internalRegData);
      }

      if(!eventRegToSessionIdsMapVar.isEmpty() && eventRegToSessionIdsMapVar.values().size()>0){
        insert createPrimarySessionRegistrations(eventRegPrimarySessionMapVar, eventRegToSessionIdsMapVar);
      }

      ct_Event_RegistrationTriggerHelper.processEventRegistrationRollUp(new set<Id>{registrations.get(0).Event_Order__c});
        
      //queueable job to update the event status
      //System.enqueueJob(new updateEventRegistrationStatusQueueable(eventRegistrationIds));
    }
    catch(Exception e){
      //Exception mechanism to log any exceptions occured during the dml operation
      ct_Logger.logMessage(e, 'Event Registration QR Code');
      throw new AuraHandledException('Error '+ e.getMessage());
    }
  }

  /**
  * @description Method to retrieve Event registration success message and post order confirmation details
  * @param recordId Event registration record ID
  * @param isEventRecordId Boolean variable to specify whether to process Event order or Event record
  * @param eventOrderId event order Id
  * @return Map<String, String> 
  **/
  @AuraEnabled
  global static Map<String, String> getEventRegistrationSuccessMessage(String recordId, Boolean isEventRecordId, String eventOrderId) {

    Map<String, String> mapOfSuccMsg = new Map<String, String>();
    //String quertString = 'SELECT Id, Event__c,Event__r.Redirect_URL__c,Event__r.Post_Web_Order_Action__c, Asperato_Payment__c FROM Event_Order__c';
    String quertString = 'SELECT Id, Event__c,Event__r.Redirect_URL__c,Event__r.Post_Web_Order_Action__c FROM Event_Order__c';

    //quertString = isEventRecordId ? quertString +' WHERE  Id =: eventOrderId' : quertString +' WHERE Asperato_Payment__c =: recordId';
    quertString = isEventRecordId ? quertString +' WHERE  Id =: eventOrderId' : quertString;

    quertString = quertString + ' LIMIT 1';
    Event_Order__c thisEventOrder = Database.query(quertString);
    if(thisEventOrder.Event__r.Post_Web_Order_Action__c == ct_EventConstants.EVENT_POST_WEB_ORDER_ACTION_CONFIRMATION_SCREEN){
      //mapOfSuccMsg.put('REDIRECT_URL',ct_EventConstants.SITE_BASE_URL+'/ledevents/s/order-confirmation?eventOrderId='+thisEventOrder.Id);
    	mapOfSuccMsg.put('REDIRECT_URL','/launchEDEvents/s/order-confirmation?eventOrderId='+thisEventOrder.Id); //DJ, Creation, 10/11/2021, Fixed URL.
    }else{
      mapOfSuccMsg.put('REDIRECT_URL',thisEventOrder.Event__r.Redirect_URL__c);
    }
    mapOfSuccMsg.put('CUSTOM_MESSAGE','Event Registered Successfully!!');
    return mapOfSuccMsg;
  }

  /**
  * @description Method to retrieve Event record
  * @param eventId Event Record Id
  * @return Event__c 
  **/
  global static Event__c getEvent(Id eventId){
        
    // String EventRecordTypeId = setRecordTypeId();

    Event__c thisEventObj = new Event__c();
    for(Event__c thisEvent :[SELECT Id, Discount_Code__c, Discount_Code__r.Name, Discount_Code__r.Discount_Code_Amount__c, 
                                      Discount_Code__r.Discount_Code__c, Discount_Code__r.Discount_Code_Type__c, RecordTypeId
                                      FROM Event__c
                                      WHERE Id =:eventId
                                      AND Discount_Code__c != null AND RecordTypeId =: EventRecordTypeId
                                      ]){
                                        thisEventObj = thisEvent;
    }
    return thisEventObj;
  }

  /**
  * @description Method to validate the event registration information entered in registration for has duplicate 
  * @param eventId Event record Id
  * @param emailAddress Event registration email address
  * @param attendeeType Event registration attendee type
  * @return DuplicateEventRegistrationValidationWrapper 
  **/
  @AuraEnabled
  global static DuplicateEventRegistrationValidationWrapper validateDuplicateEventRegistration(String eventId, string emailAddress, string attendeeType){
    Set<String> duplicateEventRegistrationStatus = new Set<String>{ct_EventConstants.EVENT_REGISTRATION_REGISTERED, 
                                                                  ct_EventConstants.EVENT_REGISTRATION_CHECKED_IN, 
                                                                  ct_EventConstants.EVENT_REGISTRATION_CHECKED_OUT, 
                                                                  ct_EventConstants.EVENT_REGISTRATION_DID_NOT_ATTEND};
    
  Set<String> deduplicateEventRegistrationStatus = new Set<String>{ct_EventConstants.EVENT_REGISTRATION_NEW, 
                                                                    ct_EventConstants.EVENT_REGISTRATION_INVITED, 
                                                                    ct_EventConstants.EVENT_REGISTRATION_DECLINED,
                                                                    ct_EventConstants.EVENT_REGISTRATION_CANCELLED};



    List<Event_Registration__c> duplicateEventRegistration = new List<Event_Registration__c>();
    duplicateEventRegistration = [SELECT Id, Event__c, Event_Email__c, Event_Registration_Status__c
                                  FROM Event_Registration__c
                                  WHERE Event__c =:eventId
                                  AND Event_Email__c != null
                                  AND Event_Email__c =:emailAddress
                                  LIMIT 1];
  
    DuplicateEventRegistrationValidationWrapper thisValidationResult = new DuplicateEventRegistrationValidationWrapper();
    if(!duplicateEventRegistration.isEmpty() 
      && duplicateEventRegistration.size() > 0
      && duplicateEventRegistration[0].Event_Registration_Status__c != null){

      if(duplicateEventRegistrationStatus.contains(duplicateEventRegistration[0].Event_Registration_Status__c)){
        thisValidationResult.hasDuplicate                     = true;
        thisValidationResult.hasCustomError                   = true;
        thisValidationResult.duplicateEventRegistrationStatus = duplicateEventRegistration[0].Event_Registration_Status__c;
        thisValidationResult.errorMessage                     = 'This email address is already registered for the event. To change details please return to the Event Registration Page.';
        if(attendeeType == ct_EventConstants.EVENT_REGISTRATION_TYPE_MY_SELF){
          thisValidationResult.errorMessage = 'This email address is already registered for the event. To change details please return to the Event Registration Page.';
        }
      }
      else if(deduplicateEventRegistrationStatus.contains(duplicateEventRegistration[0].Event_Registration_Status__c)){
        thisValidationResult.hasDuplicate                     = true;
        thisValidationResult.hasCustomError                   = false;
        thisValidationResult.duplicateEventRegistrationId     = duplicateEventRegistration[0].Id;
        thisValidationResult.duplicateEventRegistrationStatus = duplicateEventRegistration[0].Event_Registration_Status__c;
      }
    }
    
    return thisValidationResult;
  }

  /**
  * @description Method to retrieve Discount Code information for Event
  * @param eventId Event id
  * @param orderAmount Event Order Amount
  * @param discountCode Discount Code entered in registration form
  * @return Map<String, String> 
  **/
  @AuraEnabled
  global static Map<String, String> getDiscountInformation(String eventId, Decimal orderAmount, String discountCode){
    
    // String EventRecordTypeId = setRecordTypeId();

    Event__c thisEventObj;
    Map<String, String> discountMap = new Map<String, String>();

    for(Event__c thisEvent :[SELECT Id, Discount_Code__c, Discount_Code__r.Name, Discount_Code__r.Discount_Code_Amount__c, 
                                      Discount_Code__r.Discount_Code__c, Discount_Code__r.Discount_Code_Type__c, RecordTypeId
                                      FROM Event__c
                                      WHERE Id =:eventId
                                      AND Discount_Code__c != null
                                      AND Discount_Code_In_Force__c = true
                                      AND Discount_Code__r.Discount_Coupon__c = :discountCode
                                      AND RecordTypeId =: EventRecordTypeId]){
      thisEventObj = thisEvent;
    }
    
    if(thisEventObj != null && thisEventObj.Discount_Code__c != null && thisEventObj.Discount_Code__r.Discount_Code_Type__c != null
    && (thisEventObj.Discount_Code__r.Discount_Code__c != null || thisEventObj.Discount_Code__r.Discount_Code_Amount__c != null)){
      if(thisEventObj.Discount_Code__r.Discount_Code_Type__c == ct_EventConstants.DISCOUNT_TYPE_AMOUNT){
        Decimal discountedAmount = orderAmount - thisEventObj.Discount_Code__r.Discount_Code_Amount__c;
        discountedAmount = String.valueOf(discountedAmount).contains('-') ? 0 : discountedAmount;
        discountMap.put('DISCOUNT_AMOUNT', String.valueOf(discountedAmount));
      }
      else if(thisEventObj.Discount_Code__r.Discount_Code_Type__c == ct_EventConstants.DISCOUNT_TYPE_PERCENTAGE){
        Decimal discountedAmount = orderAmount - ((orderAmount * thisEventObj.Discount_Code__r.Discount_Code__c) / 100);
        discountedAmount = String.valueOf(discountedAmount).contains('-') ? 0 : discountedAmount;

        discountMap.put('DISCOUNT_AMOUNT', String.valueOf(discountedAmount));
      }
    }
    else{
      discountMap.put('DISCOUNT_AMOUNT', 'NOT_APPLICABLE');
    }
    return discountMap;
  }

  /**
  * @description Method to retrieve Session of Event as picklist for primary subject area of interest
  * @param eventId Event Id
  * @return SessionToQuestionsWrapper 
  **/
  @AuraEnabled
  global static SessionToQuestionsWrapper getSessionAsPicklists(String eventId){
    SessionToQuestionsWrapper thisWrapperObj = new SessionToQuestionsWrapper();

    for(Session__c thisSession : [SELECT Id, Name, Include_in_Dynamic_Session_Field__c, Primary_Subject_Area_Interest__c, Dynamic_Pick_List_Title__c, 
                                          Registered_Session__c, Registrations_Available__c, Session_Display_Name__c
                                          FROM Session__c
                                          WHERE Capacity_Session_Full__c < 100
                                          AND Include_in_Dynamic_Session_Field__c = true
                                          AND Event__c =: eventId
                                          ORDER BY Session_Display_Name__c ASC
                                          ]){
      thisWrapperObj.sessionMap.put(thisSession.Id, thisSession);
      thisWrapperObj.sessionValues.add(new PicklistEntryWrapper(thisSession.Session_Display_Name__c, thisSession.Id));
    }
    return thisWrapperObj;
  }
    
  //Event Order Wrapper
  global class TicketOrder{
    global String firstName;
    global String lastName;
    global String email;
    global String eventId;
    global String ticketDelivery;
    global String receiveSMSnotification;
    global String mobile;
    global String street;
    global String city;
    global String state;
    global String country;
    global String postcode;
    global Boolean sendOrderEmail;
    global Boolean eventRegHasOrder;
    global Boolean isDiscountedOrder;
    global Boolean isGroupBooking;
    global Integer numberOfAttendees;
    global String ordId;
  }
  
  //Event Registration Wrapper
  global class EventRegistration{
    global String firstName;
    global String lastName;
    global String email;
    global String mobile;
    global String street;
    global String city;
    global String addressLine2;
    global String country;
    global String postcode;
    global String birthdate;
    global String state;
    global String ticketId;
    global String eventRegId;
    global String campaignRefId;
    global Boolean isGuest;
    global Event_Registration__c eventRegistration;
    global String campaignMember;
    global String primarySessionIds;
    global String primaryAreaInterest;
    global String attendeeType;
    global Boolean hasDuplicateEventRegistration;
    global String duplicateEventRegistrationId;
    global String duplicateEventRegistrationStatus;
    global Boolean allowDuplicate;

  }
  
  //Primary Subject area of interest wrapper
  global class SessionToQuestionsWrapper{
    @AuraEnabled
    global List<PicklistEntryWrapper> sessionValues {get;set;}
    @AuraEnabled
    global  Map<Id, Session__c> sessionMap {get;set;}

    global SessionToQuestionsWrapper(){
      sessionValues = new List<PicklistEntryWrapper>();
      sessionMap = new Map<Id, Session__c>();
    }

  }

  //Event registration wrapper which is returned to LWC on successfully saving Event order and Event registration
  global class EventRegistrationWrapper{
    @AuraEnabled
    global String salesforceDomainURL                            {get;set;}
    @AuraEnabled
    global String ticketOrderId                                  {get;set;}
    @AuraEnabled
    global List<Event_Registration__c> eventRegistrationRecords  {get;set;}
    @AuraEnabled
    global Map<String, String> eventRegToSessionIdsMap          {get;set;}
    @AuraEnabled
    global Map<String, Event_Registration__c> eventRegPrimarySessionMap          {get;set;}
    
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

  /**
    * Wrapper that contains Event Group data as Picklist Values
  */
  global class Wrapper{    
    @AuraEnabled
    global String label {get;set;} 
    @AuraEnabled
    global String value {get;set;}
    Wrapper(Event_Group__c thisEventGroup){
      label = thisEventGroup.Name;
      value = thisEventGroup.Name+'UNIQUE_ID'+thisEventGroup.Id;
    }
  }

  //Duplicate Event registration Wrapper which is returned on invoking Validation of duplication Event registration
  global class DuplicateEventRegistrationValidationWrapper{
    @AuraEnabled
    global Boolean hasDuplicate {get;set;} 
    @AuraEnabled
    global Boolean hasCustomError {get;set;} 
    @AuraEnabled
    global String duplicateEventRegistrationId {get;set;} 
    @AuraEnabled
    global String duplicateEventRegistrationStatus {get;set;} 
    @AuraEnabled
    global String errorMessage {get;set;} 
    DuplicateEventRegistrationValidationWrapper(){
      hasDuplicate = false;
      hasDuplicate = false;
    }
  }

}