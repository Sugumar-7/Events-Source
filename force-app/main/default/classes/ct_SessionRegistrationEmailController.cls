/**
 * @description: Class to send Email when Registered from waiting List for Session.
 * Created By: Creation Admin
 * Created Date : 14/12/2020
 **/
global without sharing class ct_SessionRegistrationEmailController {
    @InvocableMethod
    global static void sendEmailofSessionRegistrationConfimation(List<String> sessRegIds){
        Session_Registration__c sessReg = [Select Id, Session__c, Session__r.Name, Session__r.Session_Start_Date__c,Session__r.Session_End_Date__c,
                                           Session__r.Start_Time__c,Session__r.End_Time__c,Event_Registration__c,Event_Registration__r.Event_Email__c,
                                           Event_Registration__r.Enquirer__c,Event_Registration__r.Contact__c,Event_Registration__r.Account_Name__c,Event_Registration__r.Event__r.Name,Session_Reg_Email_Sent__c
                                           From Session_Registration__c Where Id =: sessRegIds];
        
        EmailTemplate et = [Select Id, Name,Subject,HtmlValue,Body,Markup From EmailTemplate Where Name =: 'Session Registration Confirmation Email'];
       
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTemplateId(et.Id);
        message.setToAddresses(new list<String>{String.valueOf(sessReg.Event_Registration__r.Event_Email__c)});
        message.setWhatId(sessReg.Id);
        if(sessReg.Event_Registration__r.Enquirer__c != null){
            message.setTargetObjectId(sessReg.Event_Registration__r.Enquirer__c);
        }
        /*if(sessReg.Event_Registration__r.Contact__c != null){
            message.setTargetObjectId(sessReg.Event_Registration__r.Contact__c);
        }*/
        if(sessReg.Event_Registration__r.Account_Name__c != null){
            message.setTargetObjectId(sessReg.Event_Registration__r.Account_Name__c);
        }
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        
        Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
        if(!emailResult[0].isSuccess()){
            System.debug('Error :' +emailResult[0].getErrors());
        } else{
            System.debug('Success>>');
            sessReg.Session_Reg_Email_Sent__c = true;
            try{
                update sessReg;
            }
            catch(Exception e){
                ct_Logger.logMessage(e, 'Session Registration');
                throw e;
            }
        }
    }

}