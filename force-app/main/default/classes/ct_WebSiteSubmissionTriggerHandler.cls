/**
 * @description       : 
 * @author            : Javid Sherif
 * @group             : 
 * @last modified on  : 09-27-2021
 * @last modified by  : Javid Sherif
**/
global without sharing class ct_WebSiteSubmissionTriggerHandler {
  /**
* @description - Method to process Event Registration Web form Data
* @param List<String> websiteSubmissionRecordList - List of web form data
* @return void 
**/
global static void manageEventSubmissionData(List<String> websiteSubmissionRecordList){
  system.debug('websiteSubmissionRecordList  '+websiteSubmissionRecordList);
  for(String thisWebsiteSubmissionRecord :  websiteSubmissionRecordList){ 
    //Map to store the Deserialed value
    Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(thisWebsiteSubmissionRecord);
    List<String> thisEventSubDetails = new List<String>();
    // used to store the Deserialzed values in list
    List<Map<String, Object>> data = new List<Map<String, Object>>();
    for (Object instance : (List<Object>)deserialized.get('data')){
      thisEventSubDetails.add(String.valueOf(instance));
    }
    // Method to check the duplicate lead or contact is existed
    ct_LeadContactAsRegistrantsAttendees.dupecheckforLeadOrContact(thisEventSubDetails);
    System.debug('ct_LeadContactAsRegistrantsAttendees'+thisEventSubDetails);
  }
}
}