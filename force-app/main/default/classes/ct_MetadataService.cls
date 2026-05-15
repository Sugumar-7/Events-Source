/**
 * @File Name          : ct_MetadataService.cls
 * @Description        : Service class for Metadata Objects
 * @Author             : Creation Admin
 * @Last Modified By   : Umashankar Creation
 * @Last Modified On   : 12-23-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/27/2020   Creation Admin     Initial Version
**/
global without sharing class ct_MetadataService {



  global static Map<String,  Event_Type__mdt> eventTypeMetaData {
    get {
      if(eventTypeMetaData == null) {
        eventTypeMetaData = new Map<String,  Event_Type__mdt>();
        // run a for loop for fetching the Site Domain URL and stores in  eventTypeMetaData Map
        for(Event_Type__mdt thisSiteSetting : [SELECT DeveloperName, is_Complex_Event__c                                                              
                                                                  FROM Event_Type__mdt]){
          eventTypeMetaData.put(thisSiteSetting.DeveloperName, thisSiteSetting);
        }
      }
      return eventTypeMetaData;
    }
    set;
  }

  /**
  * @description Get Site Domain URL metadata records
  * @return Map<String, Site_Domain_URL__mdt> 
  **/
  global static Map<String,  Site_Domain_URL__mdt> siteDomainMetaData {
    get {
      if(siteDomainMetaData == null) {
        siteDomainMetaData = new Map<String,  Site_Domain_URL__mdt>();
        // run a for loop for fetching the Site Domain URL and stores in  siteDomainMetaData Map
        for(Site_Domain_URL__mdt thisSiteSetting : [SELECT DeveloperName, PersonalSiteContactInfoURL__c                                                              
                                                                  FROM Site_Domain_URL__mdt]){
          siteDomainMetaData.put(thisSiteSetting.DeveloperName, thisSiteSetting);
        }
      }
      return siteDomainMetaData;
    }
    set;
  }

 /**
  * @description get AFD Endpoint URL MetaData
  * @return Map<String, AFD_Validator_URL__mdt> 
  **/
  global static Map<String,  AFD_Validator_URL__mdt> AFDEndpointURLMetadataSetting {
    get {
      if(AFDEndpointURLMetadataSetting == null) {
        AFDEndpointURLMetadataSetting = new Map<String,  AFD_Validator_URL__mdt>();
        // run a for loop for fetching the Webform default record user metadata records
        for(AFD_Validator_URL__mdt thisAFDMetadata : [SELECT DeveloperName, 
                                                        Endpoint_URL__c
                                                        FROM AFD_Validator_URL__mdt]){
          AFDEndpointURLMetadataSetting.put(thisAFDMetadata.DeveloperName, thisAFDMetadata);
        }
      }
      return AFDEndpointURLMetadataSetting;
    }
    set;
  }

  /**
  * @description Boolean variable indicate whether apex is executed in Sandbox or Production Org
  * @return Boolean 
  **/
  global static Boolean isRunningInASandbox {
    get {
        if (isRunningInASandbox == null) {
            isRunningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        return isRunningInASandbox;
    }
    set;
  }

  /**
  * @description get EVent Settings Metadata
  * @return Map<String, Event_Setting__mdt> 
  **/
  global static Map<String,  Event_Setting__mdt> eventSettingsMetaData {
    get {
      if(eventSettingsMetaData == null) {
        eventSettingsMetaData = new Map<String,  Event_Setting__mdt>();
        // run a for loop for fetching the Webform default record user metadata records
        for(Event_Setting__mdt thisEventSetting : [SELECT DeveloperName, 
                                                    Value__c
                                                    FROM Event_Setting__mdt]){
          eventSettingsMetaData.put(thisEventSetting.DeveloperName, thisEventSetting);
        }
      }
      return eventSettingsMetaData;
    }
    set;
  }

  /**
  * @description get map of Personal Site Contact Info URL by Developer name
  * @param developerName 
  * @return String 
  **/
  global static String getSiteDomainMetaDataByDeveloperName(String developerName){
    if(!siteDomainMetaData.isEmpty()
    && siteDomainMetaData.containsKey(developerName)){
      return siteDomainMetaData.get(developerName).PersonalSiteContactInfoURL__c;
    }
    return null;
  }

  /**
  * @description get Event Setting By Developer Name
  * @param developerName 
  * @return Event_Setting__mdt 
  **/
  global static Event_Setting__mdt getEventSettingByDeveloperName(String developerName){
    if(!eventSettingsMetaData.isEmpty()
    && eventSettingsMetaData.containsKey(developerName)){
      return eventSettingsMetaData.get(developerName);
    }
    return null;
  }

    /**
  * @description get AFD Endpoint URL Based whether apex is executed in Sandbox or Production Org
  * @return AFD End Point URL based on Organisation Type
  **/
  global static String getAFDEndPointURL(){
    if(!AFDEndpointURLMetadataSetting.isEmpty()){
      if(isRunningInASandbox
       && AFDEndpointURLMetadataSetting.containsKey(ct_Constants.SANDBOX_AFD_ENDPOINT_URL)){
        return AFDEndpointURLMetadataSetting.get(ct_Constants.SANDBOX_AFD_ENDPOINT_URL).Endpoint_URL__c;
      }
      else if(AFDEndpointURLMetadataSetting.containsKey(ct_Constants.PRODUCTION_AFD_ENDPOINT_URL)){
        return AFDEndpointURLMetadataSetting.get(ct_Constants.PRODUCTION_AFD_ENDPOINT_URL).Endpoint_URL__c;
      }
    }
    return null;
  }

  /**
  * @description Get default mapping record from legacy donation opportunity mapping metadata
  * @author Creation Admin | 29/5/2020 
  * @return Legacy_Donation_Opportunity_Mapping__mdt 
  **/
  global static Legacy_Donation_Opportunity_Mapping__mdt getLegacyDonationOpportunityMapping(){
    Legacy_Donation_Opportunity_Mapping__mdt thislegacyDonationMapping = new Legacy_Donation_Opportunity_Mapping__mdt();

    for(Legacy_Donation_Opportunity_Mapping__mdt thisLegacyMDT : [SELECT Id, Opportunity_Close_Date__c, Opportunity_Currency__c,
                                                                          Opportunity_Stage__c, Opportunity_Amount__c
                                                                          FROM Legacy_Donation_Opportunity_Mapping__mdt
                                                                          LIMIT 1]){
      thislegacyDonationMapping = thisLegacyMDT;
    }

    return thislegacyDonationMapping;
  }
    
  /**
  * @description Event GDPR metadata records.
  * @return Map<String, Event_GDPR__mdt> 
  **/
  global static Map<String,  Event_GDPR__mdt> eventGDPRStatementMetadata {
    get {
      if(eventGDPRStatementMetadata == null) {
        eventGDPRStatementMetadata = new Map<String,  Event_GDPR__mdt>();
        //run a forloop for fetching the Advancement Setting Metadata records 
        for(Event_GDPR__mdt thisEventGDPR : [Select id, GDPR_Statement_Used__c, Declaration_Text__c,Statement_Text_above_dec__c,Statement_Text_below_dec__c, Statement_Title__c, Consent_Required_to_Register__c
                                                   from Event_GDPR__mdt]){
          eventGDPRStatementMetadata.put(thisEventGDPR.GDPR_Statement_Used__c, thisEventGDPR);
        }
      }
      return eventGDPRStatementMetadata;
    }
    set;
  }
  /**
  * @description Fetch Event Clone Setting metadata records to clone the Event.
  * @return Map<String,  Event_Clone_Setting__mdt> 
  **/
  global static Map<String, Map<String,  Event_Clone_Setting__mdt>> eventCloneSettingsMetadata {
    get {
      if(eventCloneSettingsMetadata == null) {
        eventCloneSettingsMetadata = new Map<String, Map<String,  Event_Clone_Setting__mdt>>();
        //run a forloop for fetching the Advancement Setting Metadata records 
        for(Event_Clone_Setting__mdt thisEventClone : [SELECT Id, MasterLabel, DeveloperName, Object__r.QualifiedApiName, Fields__r.QualifiedApiName, Fields__r.DataType, Values__c FROM Event_Clone_Setting__mdt]){
          if(!eventCloneSettingsMetadata.containskey(thisEventClone.Object__r.QualifiedApiName)){
            eventCloneSettingsMetadata.put(thisEventClone.Object__r.QualifiedApiName, new Map<String,  Event_Clone_Setting__mdt>());
          }
          eventCloneSettingsMetadata.get(thisEventClone.Object__r.QualifiedApiName).put(thisEventClone.Fields__r.QualifiedApiName, thisEventClone);
        }
      }
      return eventCloneSettingsMetadata;
    }
    set;
  }

  /**
  * @description get Event Clone Setting By Object API Name
  * @param objectAPIName 
  * @return Map<String,  Event_Clone_Setting__mdt> 
  **/
  global static Map<String,  Event_Clone_Setting__mdt> getEventCloneSettingByObjectName(String objectAPIName){
    if(!eventCloneSettingsMetadata.isEmpty()
    && eventCloneSettingsMetadata.containsKey(objectAPIName)){
      return eventCloneSettingsMetadata.get(objectAPIName);
    }
    return null;
  }
  /**
  * @description Fetch Event From Email Address metadata records.
  * @return Map<String,  String> 
  **/
  global static Map<String, String> eventFromAddressMap {
      get {
        if(eventFromAddressMap == null) {
          eventFromAddressMap = new Map<String, String>();
          //run a forloop for fetching the Metadata records 
          for(Event_From_Email_Address__mdt thisMetadata : [SELECT Id, MasterLabel, DeveloperName, Event_Type__c,From_Email_Address__c FROM Event_From_Email_Address__mdt]){
            if(String.isNotBlank(thisMetadata.From_Email_Address__c)){
              eventFromAddressMap.put(thisMetadata.Event_Type__c, thisMetadata.From_Email_Address__c);
            }
        }
      }
      return eventFromAddressMap;
    }
    set;
  }
   /**
  * @description Fetch OrgWideEmail Addresses
  * @return Map<String,  OrgWideEmailAddress> 
  **/	
  global static Map<String, OrgWideEmailAddress> getOrgwireAddress(){
    Map<String, OrgWideEmailAddress> orgwideAddressMap = new Map<String, OrgWideEmailAddress>();
    for(OrgWideEmailAddress thisEmailAddress : [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: eventFromAddressMap.values()]){
      orgwideAddressMap.put(thisEmailAddress.Address, thisEmailAddress);
    }
    return orgwideAddressMap;
  }
}