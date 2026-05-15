/**
 * @description       : Contruct the wrapper to show the Event product related question sets in Event Registration UI
 * @author            : Creation Admin
 * @last modified on  : 01-20-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-20-2020   Creation Admin   Initial Version
**/
global without sharing class ct_EventQuestionsFormController {
  
  /**
  * @description 
  * @param String recordId - Event registration record or Event product record Id
  * @param String ticketName - Name of the ticket from web form
  * @return List<QuestionWrapper> 
  **/
  @AuraEnabled
  global static List<QuestionWrapper> getQuestionsForEventProduct(String recordId, String ticketName){
    //Variables to store and return the Question records
    String eventProductId;
    List<QuestionWrapper> questionWrapperList = new List<QuestionWrapper>();
    Event_Registration__c thisEventRegistration = new Event_Registration__c();
    List<CampaignMember> thisCampaignMemberList = new List<CampaignMember>();
    Map<String, String> eventRegFieldToValueMap = new  Map<String, String>();
    Map<String, String> campaignFieldToValueMap = new  Map<String, String>();

    Map<String, Integer> eventRegFieldLengthMap = new Map<String, Integer>();
    Map<String, Integer> campaignMemberFieldLengthMap = new Map<String, Integer>();
    // Sobject Type for Event Registration
    SObjectType sobType = Event_Registration__c.SObjectType;
    // Get all the fields related to the Event Registration
    List<String> fields = new List<String>(sobType.getDescribe().fields.getMap().keySet());
    populateFieldLengthMap(sobType, eventRegFieldLengthMap);
    // Sobject Type for Campaign member
    SObjectType campaignMemberSobjectType = CampaignMember.SObjectType;
    // Get all the fields related to the Capaign member
    List<String> campaignMemberfields = new List<String>(campaignMemberSobjectType.getDescribe().fields.getMap().keySet());
    populateFieldLengthMap(campaignMemberSobjectType, campaignMemberFieldLengthMap);

    //Query the related campaign member record related to the Event Registration Id
    String campaignMemberQueryString = 'SELECT '+String.join(campaignMemberfields, ',')+' FROM  CampaignMember WHERE Event_Registration__c =: recordId LIMIT 1';
    campaignMemberQueryString = campaignMemberQueryString.replace('RecordTypeId,', '');
    thisCampaignMemberList = Database.query(campaignMemberQueryString);

    //Query the related Event Registration record with respect to Id
    if(String.valueOf(Id.valueOf(recordId).getsobjecttype()) == 'Event_Registration__c'){
      String queryString = 'SELECT '+String.join(fields, ',')+' FROM  Event_Registration__c WHERE Id =: recordId LIMIT 1';
      thisEventRegistration = Database.query(queryString);

      for(String field : fields) {
        Object value = thisEventRegistration.get(field);
        if (value != null) eventRegFieldToValueMap.put(field, String.valueOf(value));   
      }
      for(String field : campaignMemberfields) {
        if(!thisCampaignMemberList.isEmpty() && thisCampaignMemberList[0] != null){
          Object campaignMemberValue = thisCampaignMemberList[0].get(field);
          if (campaignMemberValue != null) {
            campaignFieldToValueMap.put(field, String.valueOf(campaignMemberValue));
          }
        }
      }
      eventProductId = thisEventRegistration.Event_Product__c;
    }
    else{
      eventProductId = recordId;
    }
    // Query the related question records with respect to the Event product Id
    for(Questions__c thisQuestion : [SELECT Id, Name, Data_Type__c, Even_Registration_Field_API_Name__c, Event_Question_Set__c, Hide_Question__c,
                                            Is_Mandatory__c, Question__c, Answer_Options__c, Object__c, Default_Text__c, Show_Only_Text__c, Text_To_Display__c,
                                            Dependent_Field_API_Name__c, Dependent_Field_Question__c, Dependent_Question_Setup__c, Dependent_Answer_is_Mandatory__c
                                            FROM Questions__c
                                            WHERE Event_Question_Set__c IN (SELECT Event_Question_Set__c FROM Event_Product__c WHERE Id =:eventProductId)
                                            ORDER BY Question_Order__c ASC]){
      thisQuestion.Question__c = thisQuestion.Question__c.replaceAll('<p><br></p>', '');
      thisQuestion.Question__c = thisQuestion.Question__c.trim();
      //Construct and add the question wrapper records to the list
      questionWrapperList.add(constructQuestionWrapper(thisQuestion, eventProductId, campaignFieldToValueMap, eventRegFieldToValueMap, ticketName, eventRegFieldLengthMap, campaignMemberFieldLengthMap));
    }
    return questionWrapperList;
  }

  /**
  * @description - Method to construct the picklist value options
  * @param String answerString - picklist values
  * @param String regex - regular expression to split
  * @return List<PicklistEntryWrapper> 
  **/
  private static List<PicklistEntryWrapper> getAnswerOptions(String answerString, String regex){
    List<PicklistEntryWrapper> thisPickListWrapperList        = new List<PicklistEntryWrapper>();
    //Loop through the picklist entries to construct picklist options
    if(answerString != null){
      //Split the picklist values with respect to the regex
      for(String thisOption : answerString.split(regex)){
        thisPickListWrapperList.add(new PicklistEntryWrapper(thisOption.trim(), thisOption.trim()));
      }
    }
    return thisPickListWrapperList;
  }

  /**
  * @description - Method to construct the field length and maximum digits per field
  * @param SObjectType thisSobjectType 
  * @param Map<String Integer> fieldLengthMap 
  **/
  private static void populateFieldLengthMap(SObjectType thisSobjectType, Map<String, Integer> fieldLengthMap){
    Schema.DescribeSObjectResult objectDescribe = thisSobjectType.getDescribe();

    List<String> fields = new List<String>(objectDescribe.fields.getMap().keySet());

    for(String field : fields) {
      Schema.DescribeFieldResult thisFieldDescribe = objectDescribe.Fields.getMap().get(field).getDescribe();
      if(thisFieldDescribe.getType() == Schema.DisplayType.STRING){
        fieldLengthMap.put(field, thisFieldDescribe.getLength());
      }
      if(thisFieldDescribe.getType() == Schema.DisplayType.INTEGER){
        fieldLengthMap.put(field, thisFieldDescribe.getDigits());
      }
    }
  }
  
  /**
  * @description 
  * @param Questions__c thisQuesionRecord  - Question record
  * @param Id eventProductId - Event product record Id
  * @param Map<String String> campaignFieldToValueMap 
  * @param Map<String String> eventRegFieldToValueMap 
  * @param String ticketName 
  * @param Map<String Integer> eventRegFieldLengthMap 
  * @param Map<String Integer> campaignMemberFieldLengthMap 
  * @return QuestionWrapper 
  **/
  private static QuestionWrapper constructQuestionWrapper(Questions__c thisQuesionRecord, Id eventProductId, Map<String,String> campaignFieldToValueMap, Map<String,String> eventRegFieldToValueMap, String ticketName, Map<String, Integer> eventRegFieldLengthMap, Map<String, Integer> campaignMemberFieldLengthMap){
    QuestionWrapper thisWrapper;
    //To store the dependent picklist type question
    Map<String, DependentPicklistWrapper> dependentPicklistValuesMap = new Map<String, DependentPicklistWrapper>();
    if( thisQuesionRecord.Data_Type__c == ct_EventConstants.QUESTION_DATA_TYPE_TEXT_DEPENDENT_PICKLIST
    && thisQuesionRecord.Dependent_Question_Setup__c != null){
      // logic to construct the Dependent picklist wrapper record
      for(String thisKey: thisQuesionRecord.Dependent_Question_Setup__c.split('\n')){
        String fieldName;
        String objectName;
        String picklistKey;
        String value = null;
        List<PicklistEntryWrapper> thisOptions = new List<PicklistEntryWrapper>();
        if(String.isNotBlank(thisKey)){
          if(thisKey.contains('Field=')){
            fieldName = thisKey.substringAfter('Field=').trim();
          }
          if(thisKey.contains('Object=')){
            objectName = thisKey.substringBetween('Object=','Field=');
            picklistKey = thisKey.substringBefore('Object=');
          }
          if(picklistKey != null){
            thisOptions = getAnswerOptions(picklistKey.split('=')[1].trim(), ';');
            if(campaignFieldToValueMap.containsKey(fieldName.toLowercase())){
              value = campaignFieldToValueMap.get(fieldName.toLowercase());
            }
            else if(eventRegFieldToValueMap.containsKey(fieldName.toLowercase())){
              value = eventRegFieldToValueMap.get(fieldName.toLowercase());
            }
            dependentPicklistValuesMap.put(picklistKey.split('=')[0].trim(), new DependentPicklistWrapper(objectName.trim(), fieldName.trim(), thisOptions, value));
          }
        } 
      }
      if(thisQuesionRecord.Object__c == 'Event_Registration__c'){
        thisWrapper = new QuestionWrapper(thisQuesionRecord, eventProductId, getAnswerOptions(thisQuesionRecord.Answer_Options__c, '\r\n'), eventRegFieldToValueMap, ticketName, dependentPicklistValuesMap, eventRegFieldLengthMap);
      }
      else if(thisQuesionRecord.Object__c == 'CampaignMember'){
        thisWrapper = new QuestionWrapper(thisQuesionRecord, eventProductId, getAnswerOptions(thisQuesionRecord.Answer_Options__c, '\r\n'), campaignFieldToValueMap, ticketName, dependentPicklistValuesMap, campaignMemberFieldLengthMap);

      }
    }
    else if(thisQuesionRecord.Object__c != null
    && thisQuesionRecord.Object__c =='CampaignMember'){
      thisWrapper = new QuestionWrapper(thisQuesionRecord, eventProductId, getAnswerOptions(thisQuesionRecord.Answer_Options__c, '\r\n'), campaignFieldToValueMap, ticketName, dependentPicklistValuesMap, campaignMemberFieldLengthMap);
    }         
    else{
      thisWrapper = new QuestionWrapper(thisQuesionRecord, eventProductId, getAnswerOptions(thisQuesionRecord.Answer_Options__c, '\r\n'), eventRegFieldToValueMap, ticketName, dependentPicklistValuesMap, eventRegFieldLengthMap);
    }
    return thisWrapper;
  }
  // Question Wrapper class
  global class QuestionWrapper{
    @AuraEnabled
    global Questions__c thisQuestion { get; set; }
    @AuraEnabled
    global String eventProductId { get; set; }
    @AuraEnabled
    global Boolean hasInput { get;set; }
    @AuraEnabled
    global Boolean hasNumber { get;set; } 
    @AuraEnabled
    global Boolean hasPhone { get;set; } 
    @AuraEnabled
    global Boolean hasCurrency { get;set; }
    @AuraEnabled
    global Boolean hasTextArea { get;set; }
    @AuraEnabled
    global Boolean hasTextAreaLong { get;set; }
    @AuraEnabled
    global Boolean hasRichTextArea { get;set; }
    @AuraEnabled
    global Boolean hasPicklist { get;set; }
    @AuraEnabled
    global Boolean hasDate { get;set; }
    @AuraEnabled
    global Boolean hasRadioOptions { get;set; }
    @AuraEnabled
    global String eventRegRecordValue { get;set; }
    @AuraEnabled
    global String radioOptionName { get;set; }
    @AuraEnabled
    global Integer maxLength { get;set; }
    @AuraEnabled
    global String defaultAnswer { get;set; }
    @AuraEnabled
    global List<PicklistEntryWrapper> picklistFields {get;set;}
    @AuraEnabled
    global Boolean hasDependent { get;set; }
    @AuraEnabled
    global Map<String, DependentPicklistWrapper> dependentPicklistFields {get;set;}
    //Constructor for the Question Wrapper class passing the question record and construct the Queation wrapper record
    global QuestionWrapper(Questions__c questionRecord, Id eventProductId, List<PicklistEntryWrapper> answerOptions, Map<String, String> valueMap, String ticketName, Map<String, DependentPicklistWrapper> dependentPicklistValuesMap, Map<String,Integer> fieldLengthMap){
      this.thisQuestion = questionRecord;
      
      this.eventProductId = eventProductId;
      if(String.isNotBlank(ticketName)){
        this.radioOptionName = questionRecord.Name+ticketName;
      }
      else{
        this.radioOptionName = questionRecord.Name+'Ticket';
      }
      
      String value = '';
      if(String.isNotBlank(questionRecord.Even_Registration_Field_API_Name__c)
      && valueMap.containsKey(questionRecord.Even_Registration_Field_API_Name__c.toLowercase())){
        value = valueMap.get(questionRecord.Even_Registration_Field_API_Name__c.toLowercase());
        if(value.contains('00:00:00')){
          value = value.remove('00:00:00').normalizeSpace();
        }
      }
      this.defaultAnswer =  String.isNotBlank(questionRecord.Default_Text__c) ? questionRecord.Default_Text__c.trim() : questionRecord.Default_Text__c;
      this.eventRegRecordValue = String.isNotBlank(value) ? value : this.defaultAnswer;

      if(questionRecord.Data_Type__c == 'Rich Text Area'){
        this.hasRichTextArea = true;
      }
      else if(questionRecord.Data_Type__c == 'Text Area'){
        this.hasTextArea = true;
      }
      else if(questionRecord.Data_Type__c == 'Long Text Area'){
        this.hasTextAreaLong = true;
      }
      else if(questionRecord.Data_Type__c == 'Picklist'){
        this.hasPicklist = true;
      }
      else if(questionRecord.Data_Type__c == 'Picklist with Radio Options'){
        this.hasRadioOptions = true;
      } 
      else if(questionRecord.Data_Type__c == 'Currency'){
        this.hasCurrency = true;
      }
      else if(questionRecord.Data_Type__c == 'Number'){
        this.hasNumber = true;
      }
      else if(questionRecord.Data_Type__c == 'Phone'){
        this.hasPhone = true;
      }
      else if(questionRecord.Data_Type__c == 'Dependent Picklist'){
        this.hasDependent = true;
      }
      else if(questionRecord.Data_Type__c == 'Date'){
        this.hasDate = true;
      }
      else{
        this.hasInput = true;
      }
      this.picklistFields = answerOptions;
      this.dependentPicklistFields = dependentPicklistValuesMap;

      if(fieldLengthMap != null 
        && !fieldLengthMap.isEmpty()
        && String.isNotBlank(questionRecord.Even_Registration_Field_API_Name__c)
        && fieldLengthMap.containsKey(questionRecord.Even_Registration_Field_API_Name__c.toLowercase())){
          this.maxLength = fieldLengthMap.get(questionRecord.Even_Registration_Field_API_Name__c.toLowercase());
        }
    }
  }

  /**
    * Wrapper that contains Donation Object wrapper and Picklist Values
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
    * Wrapper that contains Donation Object wrapper and Picklist Values
  */
  global class DependentPicklistWrapper{
    //get set string to store lable of picklist entry
    @AuraEnabled
    global String objectName                 {get;set;}
    //get set string to store value of picklist entry
    @AuraEnabled
    global string fieldAPIName                  {get;set;}
    @AuraEnabled
    global List<PicklistEntryWrapper> picklistOptions   {get;set;}
    @AuraEnabled
    global String eventRegRecordValue { get;set; }
    
    global DependentPicklistWrapper(String objectAPIName,String fieldname, List<PicklistEntryWrapper> options, String value){
      this.objectName       = objectAPIName;
      this.fieldAPIName     = Fieldname;
      this.picklistOptions  = options;
      this.eventRegRecordValue = value;
    }
  }
}