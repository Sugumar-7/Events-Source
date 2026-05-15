/**
 * @description       : 
 * @author            : Rajesh Creation
 * @group             : 
 * @last modified on  : 07-05-2021
 * @last modified by  : Rajesh Creation
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   07-05-2021   Rajesh Creation   Initial Version
**/
trigger webSiteSubmissionTrigger on Web_Site_Submission_Event__e (after insert) {
    system.debug('<<<<<<<<<<<<<<<<<<<<Web_Site_Submission_Event__e>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    system.debug('<<<<<<<<<<<<<<<<<<<<Web_Site_Submission_Event__e>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+trigger.new);
  // Variable to store the event submission data
  List<String> eventSubmissionRecordDataList  = new List<String>(); 
    
  if(Trigger.isAfter && Trigger.isInsert){
      
      List<String> webDonationRecordsList = new List<String>();
      for(Web_Site_Submission_Event__e thisEvent : trigger.new){
        system.debug('thisEvent.Source__c--'+thisEvent);
          if(thisEvent.Source__c == 'Web Donation'){
              webDonationRecordsList.add(thisEvent.Web_Site_Submission_Record__c);
          }
          if(thisEvent.Source__c == ct_EventConstants.WEB_SUBMISSION_SOURCE_EVENT ){
              system.debug('thisEvent.Source__c'+thisEvent.Source__c);
              eventSubmissionRecordDataList.add(thisEvent.Web_Site_Submission_Record__c);
          }
      }
      
      /*if(!webDonationRecordsList.isEmpty()){
          ct_WebSiteSubmissionTriggerHandler.createDonationRecords(webDonationRecordsList);
      }*/
      if(!eventSubmissionRecordDataList.isEmpty()){
        System.debug('eventSubmissionRecordDataList'+eventSubmissionRecordDataList);
          ct_WebSiteSubmissionTriggerHandler.manageEventSubmissionData(eventSubmissionRecordDataList);
      }
  }
}