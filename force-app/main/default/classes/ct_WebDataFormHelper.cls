/**
 * @File Name          : ct_WebDataFormHelper.cls
 * @Description        : Helper class for Web Form 
 * @Author             : Creation Admin  - Creation Technology Solutions
 * @Group              : 
 * @Last Modified By   : Rajeshkumar
 * @Last Modified On   : 15-09-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ************** Version history ***********************
* CT, Sadham : 29/07/2020 - Restricted duplicated donation records when user try to submit the donation again.
**/
global without sharing class ct_WebDataFormHelper {
  global static Map<String, Schema.SObjectType> objectSchemaMap = new Map<String, Schema.SObjectType>();

  /**
    * Method to get Picklist values for particular Field
    * @param objectName : Sobject Name
    * @param fieldName : Field API Name
    * @return List<Schema.PicklistEntry> : list of picklist Values
  */
  global static List<Schema.PicklistEntry> getPicklistValues(String objectName, String fieldName){
    if(objectSchemaMap.isEmpty()
    || !objectSchemaMap.containsKey(objectName)){
      objectSchemaMap.put(objectName, Schema.getGlobalDescribe().get(objectName));
    }
    Schema.SObjectType thisSobjectType                        = objectSchemaMap.get(objectName);
    Schema.DescribeSObjectResult thisSobjectDescribeResult    = thisSobjectType.getDescribe();
    Map<String,Schema.SObjectField> fields                    = thisSobjectDescribeResult.fields.getMap();
    Schema.DescribeFieldResult fieldResult                    = fields.get(fieldName).getDescribe();
    List<Schema.PicklistEntry> thisPicklistEntries            = fieldResult.getPicklistValues();
    return thisPicklistEntries;
  }

  /**
  * @description - Method to get all fields from Sobject
  * @param String objectName - Sobject Name
  * @return Map<String, Schema.SObjectField> - sobjectField Mapa
  **/
  global static Map<String,Schema.SObjectField> getSojectFields(String objectName){
    if(objectSchemaMap.isEmpty()
    || !objectSchemaMap.containsKey(objectName)){
      objectSchemaMap.put(objectName, Schema.getGlobalDescribe().get(objectName));
    }
    Schema.SObjectType thisSobjectType                        = objectSchemaMap.get(objectName);
    Schema.DescribeSObjectResult thisSobjectDescribeResult    = thisSobjectType.getDescribe();
    Map<String,Schema.SObjectField> fields                    = thisSobjectDescribeResult.fields.getMap();
    return fields;
  }

  /**
    * Method to get String value from Donation Object Map
    * @param objectKey : Object key Map 
    * @param donationOpportunityId : Donation Opportunity Id
    * Return Value : String value from Donation Object
  */
  global static String getValueFromObjectMap(Map<String, Object> donorObject, String objectKey){
    return String.isEmpty(String.valueOf(donorObject.get(objectKey))) ? null : String.valueOf(donorObject.get(objectKey));
  }

  /**
  * @description - Method to get Site Admin Id 
  * @return Id - Site Admin Id
  **/
  global static Id getSiteAdminId(){
    return [SELECT AdminId,MasterLabel , Name FROM Site WHERE MasterLabel =: Label.AAA_Site_MasterLabel LIMIT 1].AdminId;
  }
  
  /**
  * @description - Method to convert a string value to Title case string
  * @param stringValue : String that needs to be converted to tile case
  * @return Title Case String
  **/
  global static string getTitleCaseValue(string stringValue){
    try{
      if(!String.isEmpty(stringValue)){
        return stringValue.substring(0,1).toUpperCase()+stringValue.substring(1,stringValue.length()).toLowerCase();
      }
      return stringValue;
    }
    catch (Exception e) {
      ct_Logger.logMessage(e, '');
      throw new AuraHandledException('Error '+ e.getMessage());    
    }
  }

  /**
  * @description - Method to get Opportunity Payment based on Asperato Payment Id
  * @param opportunityPaymentMap : Asperato Id => Opportunity payment Map
  * @param asperatoIds : Asperato payment Ids whose Opportunity payment needs to be retrieved
  **/
  // global static void populateOpportunityPaymentMap(Map<Id, npe01__OppPayment__c> opportunityPaymentMap, Set<Id> asperatoIds){
  //   // for(npe01__OppPayment__c  thisPayment : [SELECT Id, npe01__Opportunity__c, npe01__Opportunity__r.IsWon, Asperato_Payment__c
  //   //                                           FROM npe01__OppPayment__c
  //   //                                           WHERE Asperato_Payment__c != null
  //   //                                           AND Asperato_Payment__c IN: asperatoIds]){
  //   //   opportunityPaymentMap.put(thisPayment.Asperato_Payment__c, thisPayment);             
  //   // }
  // }

  /**
  * @description - Method to create Asperato Payment and Return for processing 
  * @return asp04__Payment__c -Asperato Record
  **/
  // global static asp04__Payment__c createAsperatoPayment(String donarDetails, String paymentType, Integer amount, Id authorizationId, Date dueDate){
  //   system.debug('paymentType>>>>>'+paymentType);
  //   asp04__Payment__c asperatoPayment                       = new asp04__Payment__c();
  //   Map<String, Object> donorObject = (Map<String, Object>)JSON.deserializeUntyped(donarDetails);
  //   asperatoPayment.Id                                      = getValueFromObjectMap(donorObject, 'asperatoId');
  //   asperatoPayment.asp04__Amount__c                        = amount;
  //   asperatoPayment.asp04__Payment_Route_Options__c         = mapAsperatoPaymentMethod(paymentType);
  //   asperatoPayment.asp04__Payment_Route_Selected__c        = mapAsperatoPaymentMethod(paymentType);
  //   asperatoPayment.asp04__First_Name__c                    = getValueFromObjectMap(donorObject, 'FirstName');
  //   asperatoPayment.asp04__Last_Name__c                     = getValueFromObjectMap(donorObject, 'LastName');
  //   asperatoPayment.asp04__Email__c                         = getValueFromObjectMap(donorObject, 'Email');
   
  //   if(paymentType == ct_Constants.DIRECT_DEBIT_PAYMENT_METHOD){
  //     asperatoPayment.asp04__Authorisation__c                 = authorizationId;
  //     //asperatoPayment.asp04__Due_Date__c                      = dueDate - ct_MetadataService.getAsperatoDueDateDelay();
  //   }
  //   else{
  //     asperatoPayment.asp04__Due_Date__c                      = dueDate;
  //   }
  //   if(getValueFromObjectMap(donorObject, 'donationToProject') == null){
  //     asperatoPayment.asp04__Billing_Address_Street__c        = getValueFromObjectMap(donorObject, 'MailingStreet');
  //     asperatoPayment.asp04__Billing_Address_City__c          = getValueFromObjectMap(donorObject, 'MailingCity');
  //     asperatoPayment.asp04__Billing_Address_Country__c       = getValueFromObjectMap(donorObject, 'MailingCountry');
  //     asperatoPayment.asp04__Billing_Address_State__c         = getValueFromObjectMap(donorObject, 'MailingState');
  //     asperatoPayment.asp04__Billing_Address_PostalCode__c    = getValueFromObjectMap(donorObject, 'MailingPostalCode');
  //   }
  //   return asperatoPayment;
  // }

   /**
  * @description Get Asperto Reference from Apserato Payment
  * @author Creation Admin | 11/5/2020 
  * @param paymentRecordId 
  * @return String 
  **/
  // @AuraEnabled
  // global static String getAsperatoReference(Id paymentRecordId){

  //   return [SELECT Id, asp04__Asperato_Reference__c FROM asp04__Payment__c
  //                       WHERE Id = :paymentRecordId LIMIT 1].asp04__Asperato_Reference__c;
  // }

  /**
  * @description Get Authorisation DD Mandate Reference from Authorisation
  * @author Creation Admin | 11/5/2020 
  * @param paymentRecordId 
  * @return String 
  **/
  // global static String getAuthorisationReference(Id paymentRecordId){

  //   return [SELECT Id, asp04__Mandate_Reference__c FROM asp04__Authorisation__c
  //                       WHERE Id = :paymentRecordId LIMIT 1].asp04__Mandate_Reference__c;
  // }

  /**
  * @description - Method to create Authorization and Return for processing 
  * @return asp04__Authorisation__c - Authorization
  **/
  // global static asp04__Authorisation__c createAuthorizationRecord(String donationDetails, String paymentType, Id authorizationId){
  //   asp04__Authorisation__c thisAuthorization = new asp04__Authorisation__c();
  //   Map<String, Object> donorObject = (Map<String, Object>)JSON.deserializeUntyped(donationDetails);
  //   thisAuthorization.Id                                      = authorizationId;// donorObject.get('authorizationId') != null ? Id.valueOf(getValueFromObjectMap(donorObject, 'authorizationId')) : null;
  //   thisAuthorization.Account__c                              = getValueFromObjectMap(donorObject, 'AccountId');
  //   thisAuthorization.Contact__c                              = getValueFromObjectMap(donorObject, 'Id');
  //   thisAuthorization.asp04__Payment_Route_Options__c         = mapAsperatoPaymentMethod(paymentType);
  //   thisAuthorization.asp04__First_Name__c                    = getValueFromObjectMap(donorObject, 'FirstName');
  //   thisAuthorization.asp04__Last_Name__c                     = getValueFromObjectMap(donorObject, 'LastName');
  //   thisAuthorization.asp04__Email__c                         = getValueFromObjectMap(donorObject, 'Email');
  //   if(getValueFromObjectMap(donorObject, 'donationToProject') == null){
  //     thisAuthorization.asp04__Billing_Address_Street__c        = getValueFromObjectMap(donorObject, 'MailingStreet');
  //     thisAuthorization.asp04__Billing_Address_City__c          = getValueFromObjectMap(donorObject, 'MailingCity');
  //     thisAuthorization.asp04__Billing_Address_Country__c       = getValueFromObjectMap(donorObject, 'MailingCountry');
  //     thisAuthorization.asp04__Billing_Address_State__c         = getValueFromObjectMap(donorObject, 'MailingState');
  //     thisAuthorization.asp04__Billing_Address_PostalCode__c    = getValueFromObjectMap(donorObject, 'MailingPostalCode');
  //   }
  //   return thisAuthorization;
  // }

  /**
  * @description - Method to create Authorization and Return for processing 
  * @return asp04__Authorisation__c - Authorization
  **/
  // global static asp04__Authorisation__c createAuthorizationRecordForAccount(String donationDetails, String paymentType, Id authorizationId){
  //   asp04__Authorisation__c thisAuthorization = new asp04__Authorisation__c();
  //   Map<String, Object> donorObject = (Map<String, Object>)JSON.deserializeUntyped(donationDetails);
  //   thisAuthorization.Id                                      = authorizationId;
  //   thisAuthorization.asp04__Payment_Route_Options__c         = mapAsperatoPaymentMethod(paymentType);
  //   thisAuthorization.Account__c                              = getValueFromObjectMap(donorObject, 'Id');
  //   //thisAuthorization.Contact__c                              = getValueFromObjectMap(donorObject, 'Id');
  //   thisAuthorization.asp04__First_Name__c                    = getValueFromObjectMap(donorObject, 'Name');
  //   thisAuthorization.asp04__Billing_Address_Street__c        = getValueFromObjectMap(donorObject, 'BillingStreet');
  //   thisAuthorization.asp04__Billing_Address_City__c          = getValueFromObjectMap(donorObject, 'BillingCity');
  //   thisAuthorization.asp04__Billing_Address_Country__c       = getValueFromObjectMap(donorObject, 'BillingCountry');
  //   thisAuthorization.asp04__Billing_Address_State__c         = getValueFromObjectMap(donorObject, 'BillingState');
  //   thisAuthorization.asp04__Billing_Address_PostalCode__c    = getValueFromObjectMap(donorObject, 'BillingPostalCode');
    
  //   return thisAuthorization;
  // }
  
  global static String mapAsperatoPaymentMethod(String paymentMethod){
    string mappedPaymentMethod = '';
    Map<String, String> asperatoToGemPaymentMap = new Map<String, String>{ct_Constants.DIRECT_DEBIT_PAYMENT_METHOD  => ct_Constants.DIRECT_DEBIT_PAYMENT_METHOD,
                                                                          ct_Constants.CASH_PAYMENT_METHOD          => ct_Constants.CASH_PAYMENT_METHOD,
                                                                          ct_Constants.PAYPAL_PAYMENT_METHOD        => ct_Constants.PAYPAL_PAYMENT_METHOD,
                                                                          ct_Constants.ASPERATO_CARD_PAYMENT_METHOD => ct_Constants.ASPERATO_CARD_PAYMENT_METHOD,
                                                                          ct_Constants.GEM_CARD_PAYMENT_METHOD      => ct_Constants.ASPERATO_CARD_PAYMENT_METHOD};
    mappedPaymentMethod = asperatoToGemPaymentMap.containsKey(paymentMethod) ? asperatoToGemPaymentMap.get(paymentMethod) : paymentMethod; 
    return mappedPaymentMethod;
  }

  /**
  * @description - method to contruct Contact record which is used to populate the values for Asperato authorization record
  * @param npe01__OppPayment__c thisPayment 
  * @return Contact 
  **/
  // global static Contact constructContactRecord(npe01__OppPayment__c thisPayment){
  //   Contact thisContact             = new Contact();
  //   thisContact.Id                  = thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__c;
  //   thisContact.AccountId           = thisPayment.npe01__Opportunity__r.AccountId;
  //   thisContact.FirstName           = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ?thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__First_Name__c : thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.FirstName;
  //   thisContact.LastName            = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ?thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__Last_Name__c : thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.LastName;
  //   thisContact.Email               = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ?thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__Email__c : thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.Email;
  //   thisContact.MailingStreet       = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ?thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__Billing_Address_Street__c : thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.MailingStreet;
  //   thisContact.MailingCity         = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ?thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__Billing_Address_City__c : thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.MailingCity;
  //   thisContact.MailingCountry      = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ?thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__Billing_Address_Country__c : thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.MailingCountry;
  //   thisContact.MailingState        = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ? thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__Billing_Address_State__c : thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.MailingState;
  //   thisContact.MailingPostalCode   = thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__c != null ?thisPayment.npe01__Opportunity__r.npe03__Recurring_Donation__r.Asperato_Authorisation__r.asp04__Billing_Address_PostalCode__c: thisPayment.npe01__Opportunity__r.npsp__Primary_Contact__r.MailingPostalCode;
  //   return thisContact;
  // }

  /**
  * @description - method to contruct Account record which is used to populate the values for Asperato authorization record
  * @author Creation Admin | 3/13/2020 
  * @param npe01__OppPayment__c thisPayment 
  * @return Contact 
  **/
  // global static Account constructAccountRecord(npe01__OppPayment__c thisPayment){
  //   Account thisAccount             = new Account();
  //   thisAccount.Name                = thisPayment.npe01__Opportunity__r.Account.Name;
  //   thisAccount.BillingStreet       = thisPayment.npe01__Opportunity__r.Account.BillingStreet;
  //   thisAccount.BillingCity         = thisPayment.npe01__Opportunity__r.Account.BillingCity;
  //   thisAccount.BillingCountry      = thisPayment.npe01__Opportunity__r.Account.BillingCountry;
  //   thisAccount.BillingState        = thisPayment.npe01__Opportunity__r.Account.BillingState;
  //   thisAccount.BillingPostalCode   = thisPayment.npe01__Opportunity__r.Account.BillingPostalCode;
  //   return thisAccount;
  // }

  /**
  * @description Map gender field in Contact based on the salutation selected through the web forms
  * @author Creation Admin | 2/6/2020 
  * @return String 
  **/
  global static String mapGenderBasedOnSalutation(String salutation){
    //Map to hold gender values for respective salutations
    Map<String, String> salutationToGenderMap = new Map<String, String>{'Mr.' => 'Male', 'Ms.' => 'Female', 'Mrs.' => 'Female', 'Miss' => 'Female'};
    return salutationToGenderMap.containsKey(salutation) ? salutationToGenderMap.get(salutation) : '';
  }
}