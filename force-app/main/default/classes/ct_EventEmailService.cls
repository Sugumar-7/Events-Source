/**
 * @description       : Apex class for sending Event Order confirmation / Event Registration confirmation emails
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 02-04-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-18-2020   Umashankar Creation   Initial Version
**/
global without sharing class  ct_EventEmailService {

    /**
    * @description Method to send sending Event Order confirmation / Event Registration confirmation email invoked from process builder
    * @param emailWrapperList Wrapper class whose values are passed from process builder
    **/
    @InvocableMethod
    global static void sendEventOrderConfirmationEmail(List<EmailWrapper> emailWrapperList){
        try{
            system.debug('emailWrapperList ----' + emailWrapperList);
            Map<String, String> metadataMap                     = ct_MetadataService.eventFromAddressMap;
            Map<String,OrgWideEmailAddress> orgWideAddressMap   = ct_MetadataService.getOrgwireAddress();

            system.debug('metadataMap ----' + metadataMap);
            system.debug('orgWideAddressMap ----' + orgWideAddressMap);



            List<Messaging.SingleEmailMessage> emailListToSend  = new List<Messaging.SingleEmailMessage>();
            EmailTemplate thisEmailTemplate;
            Map<Id, EmailMessage> emailMessageRecordMap         = new Map<Id, EmailMessage>();
            List<EmailMessageRelation> emailMessageRelationList = new List<EmailMessageRelation>();

            if(!emailWrapperList.isEmpty() && emailWrapperList.size()>0 && String.isNotBlank(emailWrapperList[0].emailTemplateAPIName)){
                thisEmailTemplate = getEmailTemplate(emailWrapperList[0].emailTemplateAPIName.trim());
                 System.debug('thisEmailTemplate'+  thisEmailTemplate);
            }

            for( EmailWrapper thisWrapper :emailWrapperList){
                System.debug('Inside EmailWrapper For'+  thisWrapper);
                Messaging.SingleEmailMessage thisEmail = constructEmailMessageRecord(metadataMap,orgWideAddressMap, thisWrapper, thisEmailTemplate);
                System.debug('thisEmail'+  thisEmail);
                //mail.setTreatBodiesAsTemplate(true);
                //mail.setTreatBodiesAsTemplate(true);)
                if(String.isNotBlank(thisWrapper.leadId) && thisEmail.getHtmlBody() != null){
                   
                    emailMessageRecordMap.put(Id.valueOf(thisWrapper.leadId), constructEmailMessageRecord(thisEmail, thisWrapper, metadataMap, orgwideAddressMap));
                 System.debug('emailMessageRecordMap'+  emailMessageRecordMap);
                }
                emailListToSend.add(thisEmail);
                //mail.setTreatBodiesAsTemplate(true);
            }
            System.debug('emailListToSend'+ emailListToSend);
            if(!emailListToSend.isEmpty()){
                if(!Test.isRunningTest()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailListToSend);
                }
            }
            if(!emailMessageRecordMap.isEmpty()){
                insert emailMessageRecordMap.values();
                System.debug('emailMessageRecordMap'+  emailMessageRecordMap);
                for(Id thisLeadId : emailMessageRecordMap.keySet()){
                    System.debug('Inside thisLead Loop');
                    EmailMessageRelation thisRelation = new EmailMessageRelation();
                    thisRelation.EmailMessageId     = emailMessageRecordMap.get(thisLeadId).Id;
                    thisRelation.RelationAddress    = emailMessageRecordMap.get(thisLeadId).ToAddress;
                    thisRelation.RelationId         = thisLeadId;
                    thisRelation.RelationType       = 'ToAddress';
                    emailMessageRelationList.add(thisRelation);
                }
                system.debug('emailMessageRelationList ----' + emailMessageRelationList);

                insert emailMessageRelationList;
            }
        }
        catch (Exception ex) {
            System.debug('Inside Catch');
            ct_Logger.logMessage(ex, 'Event Email Error');
            throw new InvocableActionException('Email Service Error: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }    
    }
    global static EmailTemplate getEmailTemplate(String developerName){
        System.debug('Iniside getEmailTemplate'+developerName);
       return([SELECT Id, DeveloperName, HTMLValue, Subject 
        FROM EmailTemplate 
        WHERE DeveloperName =: developerName 
        AND IsActive = true LIMIT 1]);
    }

    global static Messaging.SingleEmailMessage constructEmailMessageRecord(Map<String, String> metadataMap,Map<String, OrgWideEmailAddress> orgWideAddressMap, EmailWrapper thisWrapper, EmailTemplate thisEmailTemplate){
        System.debug('Inisde first constructEmailMessageRecord');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailAddress = new List<String>();
        List<String> additionalEmailAddress = new List<String>();
        if(String.isNotBlank(thiswrapper.leadId)){
            system.debug('thiswrapper.leadId '+thiswrapper.leadId);
            mail = Messaging.renderStoredEmailTemplate(thisEmailTemplate.Id, thiswrapper.leadId, String.valueOf(thisWrapper.recordId));
            mail.setTargetObjectId(Id.valueOf(thisWrapper.leadId));
            mail.setSaveAsActivity(false);
            mail.setWhatId(thisWrapper.recordId);
        }
        /*else if(String.isNotBlank(thiswrapper.contactId)){
            system.debug('thiswrapper.leadId '+thiswrapper.contactId);
            mail.setTargetObjectId(Id.valueOf(thisWrapper.contactId));
            mail.setWhatId(thisWrapper.recordId);
            mail.setSaveAsActivity(true);
        }*/
        else if(String.isNotBlank(thiswrapper.personContactId)){
            system.debug('thiswrapper.leadId '+thiswrapper.personContactId);
            mail.setTargetObjectId(Id.valueOf(thisWrapper.personContactId));
            mail.setWhatId(thisWrapper.recordId);
            mail.setSaveAsActivity(true);
        }
        else if(thisWrapper.targetObjectId != null){
            mail.setTargetObjectId(thisWrapper.targetObjectId);
            mail.setWhatId(thisWrapper.recordId);
            mail.setSaveAsActivity(false);
        }
        if(String.isNotBlank(thisWrapper.eventType) 
        && metadataMap.containskey(thisWrapper.eventType) 
        && orgWideAddressMap.containskey(metadataMap.get(thisWrapper.eventType))){
            mail.setOrgWideEmailAddressId(orgWideAddressMap.get(metadataMap.get(thisWrapper.eventType)).Id); 
        }
        if(String.isNotBlank(thisWrapper.eventEmail)
        && thisWrapper.eventEmail.contains(';')){
            emailAddress = thisWrapper.eventEmail.split(';');
        }
        else{
            emailAddress.add(thisWrapper.eventEmail);
        }
        if(String.isNotBlank(thisWrapper.additionalAddress)
        && thisWrapper.additionalAddress.contains(';')){
            mail.setCcAddresses(thisWrapper.additionalAddress.split(';'));

        }
        else if(String.isNotBlank(thisWrapper.additionalAddress)){
            mail.setCcAddresses(new String[]{thisWrapper.additionalAddress});
        }
        mail.setToAddresses(emailAddress);
        mail.setTreatTargetObjectAsRecipient(false);       
        mail.setTemplateId(thisEmailTemplate.Id);
        System.debug('Mail 1'+mail);
        return mail;
    }

    global static EmailMessage constructEmailMessageRecord(Messaging.SingleEmailMessage thisEmail, EmailWrapper thisWrapper,   Map<String, String> metadataMap,  Map<String,OrgWideEmailAddress> orgWideAddressMap ){
        System.debug('Inisde Second constructEmailMessageRecord');
        EmailMessage thisMessage    = new EmailMessage();
        //thisMessage.RelatedToId     = thisWrapper.recordId;
        thisMessage.put('RelatedToId', thisWrapper.recordId);
        thisMessage.htmlBody        = thisEmail.getHtmlbody();
        thisMessage.Status          = '3';
        thisMessage.MessageDate     = System.now();
        thisMessage.EmailTemplateId = Id.valueOf(thisEmail.getTemplateId());
        thisMessage.ToAddress       = thisEmail.getToAddresses()[0];
        thisMessage.Subject         = thisEmail.getTemplateName();
        if(String.isNotBlank(thisWrapper.eventType) 
        && metadataMap.containskey(thisWrapper.eventType) 
        && orgWideAddressMap.containskey(metadataMap.get(thisWrapper.eventType))){
            thisMessage.FromAddress = orgWideAddressMap.get(metadataMap.get(thisWrapper.eventType)).Address;
            thisMessage.FromName    = orgWideAddressMap.get(metadataMap.get(thisWrapper.eventType)).DisplayName;
        }
        else{
            thisMessage.FromAddress = UserInfo.getUserEmail();
            thisMessage.FromName    = UserInfo.getUserName();
        }
        System.debug('thisMessage'+thisMessage);
        return thisMessage;
    }
    global class EmailWrapper{
        @InvocableVariable 
        global Id recordId;
        @InvocableVariable 
        global String eventEmail;
        @InvocableVariable
        global string eventType;
        @InvocableVariable
        global Id targetObjectId;
        @InvocableVariable
        global string emailTemplateAPIName;
        @InvocableVariable
        global String leadId;
        @InvocableVariable
        global String contactId;
        @InvocableVariable
        global String personContactId;
        @InvocableVariable
        global String additionalAddress;
    }  
}