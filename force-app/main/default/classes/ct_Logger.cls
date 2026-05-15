/**
 * @File Name          : ct_Logger.cls
 * @Description        : 
 * @Author             : Creation Admin
 * @Group              : 
 * @Last Modified By   : Creation Admin
 * @Last Modified On   : 28/4/2020, 7:39:20 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    26/4/2020   Creation Admin     Initial Version
**/
global without sharing class ct_Logger {
  /**
  * @description method used to log errors into Error Log object
  * @author Creation Admin | 26/4/2020 
  * @param e Exception Object 
  * @param objectName object name parameter 
  * @return void 
  **/
  global static void logMessage(Exception e, String objectName){
      
      //Publish the event trigger
      /*Error_Log_Event__e eventObject = new Error_Log_Event__e();
      if(e.getMessage().contains('caused by:')){
        eventObject.Short_Error__c = e.getMessage().split('caused by:')[1].split('Class')[0];
      }
      else if(e.getMessage().contains('first error:')){
        eventObject.Short_Error__c = e.getMessage().split('first error:')[1].split(',')[0];
      }
      else{
        eventObject.Short_Error__c = 'System.DmlException: Insert failed.';
      }
      eventObject.Object_Name__c = objectName;
      eventObject.Error_Detail__c = e.getMessage()+'-'+e.getStackTraceString();
      
      Database.SaveResult result = EventBus.publish(eventObject);
      if (result.isSuccess()) {
        System.debug('Successfully published event.');
      } else {
        for(Database.Error err : result.getErrors()) {
          System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
        }
      }
      */
      System.debug('Entered ct_logger cls.');
    }
  }