/**
 * @File Name          : ct_Util.cls
 * @Description        : 
 * @Author             : Creation Admin  - Creation Technology Solutions
 * @Group              : 
 * @Last Modified By   : Javid Sherif
 * @Last Modified On   : 11-01-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/12/2020   Creation Admin     Initial Version
 * ************** Version history ***********************
* CT, Sadham : 29/07/2020 - Updated OrgWideEmailAddress query
**/
global without sharing class ct_Util {
  private static Map<Id, RecordType> reverseCache;

  private static Map<String, Map<String, RecordType>> recordTypeByNameCache;
  private static Map<String, Schema.SObjectType> gd;
  private static Map<String, Schema.DescribeSObjectResult> objectDescribes = new Map<String, Schema.DescribeSObjectResult>();
  private static Map<Schema.SObjectType, Schema.DescribeSObjectResult> objectDescribesByType = new Map<Schema.SObjectType, Schema.DescribeSObjectResult>();
  private static Map<String, Map<String, Schema.SObjectField>> fieldTokens = new Map<String,Map<String, Schema.SObjectField>>();
  private static Map<String, Map<String, Schema.DescribeFieldResult>> fieldDescribes = new Map<String,Map<String, Schema.DescribeFieldResult>>();
  private static ct_Util utilDescribeInstance;
  private static Map<Schema.SObjectField, Map<String, String>> picklistTranslations = new Map<Schema.SObjectField, Map<String, String>>();

  /**
  * @description getter method to query & map record type values
  * @author Creation Admin | 17/4/2020 
  * @return Map<String, Map<String, RecordType>> 
  **/
  private static Map<String, Map<String, RecordType>> recordTypeCache {
  get {
    if (recordTypeCache == null) {
      recordTypeCache         = new Map<String, Map<String, RecordType>>();
      recordTypeByNameCache   = new Map<String, Map<String, RecordType>>();
      reverseCache            = new Map<Id, RecordType>();
      List<RecordType> allRecTypes = [SELECT Id, DeveloperName, Name, SobjectType,
                                              IsActive, BusinessProcessId, Description,
                                              NamespacePrefix
                                      FROM RecordType];
        
      for (RecordType r : allRecTypes) {
        if(recordTypeCache.get(r.SobjectType) == null){
            
          recordTypeCache.put(r.SobjectType, new Map<String, RecordType>());
        }
		
        if(recordTypeByNameCache.get(r.SobjectType) == null){
            
          recordTypeByNameCache.put(r.SobjectType, new Map<String, RecordType>());
        }
          recordTypeCache.get(r.SobjectType).put(r.DeveloperName, r);
          recordTypeByNameCache.get(r.SobjectType).put(r.Name, r);
          reverseCache.put(r.Id, r);
        }
      }
    return recordTypeCache;
  }
  private set;
  }

  /**
  * @description get record type based on developer name
  * @author Creation Admin | 17/4/2020 
  * @param sObjectName 
  * @param developerName 
  * @return Id 
  **/
  global static Id getRecordTypeIdByDevName(String sObjectName, String developerName) {
      System.debug('sObjectName'+sObjectName);
      System.debug('developerName'+developerName);
      System.debug('recordTypeCache '+recordTypeCache);
    RecordType rt = recordTypeCache.get(sObjectName).get(developerName);
    
    System.debug('rt'+rt);
    if (rt == null)
        
      throw new RecordTypeCacheException('RecordType \'' + developerName + '\' for \''
                                            + sObjectName + '\' does not exist.');
      return rt.Id;
  }
   /**
  * @description - get recordtype Id based on Name 
  * @author Creation Admin| 08-28-2020 
  * @param String sObjectName 
  * @param String developerName 
  * @return Id 
  **/
  global static Id getRecordTypeIdByName(String sObjectName, String recTypeName) {
      
    RecordType rt = recordTypeByNameCache.get(sObjectName).get(recTypeName);
    if (rt == null)
        
      throw new RecordTypeCacheException('RecordType \'' + recTypeName + '\' for \''
                                            + sObjectName + '\' does not exist.');
      return rt.Id;
  }  

  /**
  * @description get record type developer name by Id
  * @author Creation Admin | 17/4/2020 
  * @param recTypeId 
  * @return String 
  **/
  global static String getRecordTypeDeveloperNameById(Id recTypeId) {

    Map<String, Map<String, RecordType>> unusedCache = recordTypeCache;

    RecordType rt = reverseCache.get(recTypeId);

    if (rt == null)
        throw new RecordTypeCacheException('RecordType with Id \'' + recTypeId + '\' does not exist.');

    return rt.DeveloperName;
}

  /**
  * @description  - method to form the query string from fieldsets
  * @param String objName - SObject Name
  * @param Set<String> fieldList - List of fields API Name
  * @return String - Query String
  **/
  global static String getQueryStringForSObject(String objName, Set<String> fieldList){
    SObjectType objectType = Schema.getGlobalDescribe().get(objName);
    DescribeSObjectResult objectDescribe = objectType.getDescribe();
    string query ='SELECT ';
    for(String thisField :fieldList) {
      query = query +thisField+',';
    }
    query   = query .removeEnd(',');
    query   = query  + ' FROM '+ objectDescribe.getName();
    return query;
  }

  /**
  * @description  - method to form the query string for object with all fields
  * @param String objName - SObject Name
  * @return String - Query String
  **/
  global static String getAllFieldsQueryStringForSObject(String objName){
    SObjectType objTokenFile = Schema.getGlobalDescribe().get(objName);
    DescribeSObjectResult objDeffile = objTokenFile.getDescribe();
    Map<String, SObjectField> fieldsFile = objDeffile.fields.getMap();
    string fieldLstFile='';
    Set<String> fieldSetFiles = fieldsFile.keySet();
    for(String s:fieldSetFiles) {
      SObjectField fieldToken = fieldsFile.get(s);
      DescribeFieldResult selectedField = fieldToken.getDescribe();
      fieldLstFile=fieldLstFile+selectedField.getName()+',';
    }
    fieldLstFile = fieldLstFile.removeEnd(',');
    return fieldLstFile;
  }
    
  /**
   * @description - common method to query org wide email address to be used in all places
   * @return OrgWideEmailAddress[] - array of addresses matching a Constant
   */
  global static OrgWideEmailAddress[] getOrgWideEmail(String addressDisplayName){
  	return [SELECT Id,IsAllowAllProfiles, Address FROM OrgWideEmailAddress WHERE DisplayName=: addressDisplayName];
  }

  /**
  * @description - Method to get profile Id based on profile name
  * @param String profileName 
  * @return Id 
  **/
  global static Id getProfileId(String profileName){
    return[SELECT Id, Name FROM Profile WHERE Name =: profileName LIMIT 1].Id;
  }
    
  global class RecordTypeCacheException extends Exception{}

   /**
  * @description  - method to form the query string from fieldsets
  * @param String objName - SObject Name
  * @return List<String> - array of field names
  **/
  global static List<String> getFieldList(String objName){
    List<String> listOfFields = new List<String>();
    Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
    for(Schema.SObjectField sfield : fieldMap.Values())
    {
        schema.describefieldresult dfield = sfield.getDescribe();
        listOfFields.add(dfield.getname());
    }
    return listOfFields;
  }

  // throw custom exceptions when a bogus object or field is provided.
  global class SchemaDescribeException extends Exception {}

   /*******************************************************************************************************
    * @description Returns object friendly name.
    * @param objectName the name of the object to lookup
    * @return the Label of the object
    */
    global static string getObjectLabel(String objectName) {
      objectName = objectName.toLowerCase();
      // make sure we have this object's schema mapped
      if (!objectDescribes.containsKey(objectName))
          fillMapsForObject(objectName);

      return objectDescribes.get(objectName).getLabel();
  }
  
  
  /*******************************************
  * Gets describe maps for a new object
  ********************************************/
  static void fillMapsForObject(string objectName) {
      objectName = objectName.toLowerCase();

      // get the object map the first time
      if (gd == null) {
          gd = Schema.getGlobalDescribe();
      }

      // get the object description
      if (gd.containsKey(objectName)) {
          if (!objectDescribes.containsKey(objectName)) {
              Schema.DescribeSObjectResult objDescribe = gd.get(objectName).getDescribe();
              objectDescribes.put(objectName, objDescribe);
              objectDescribesByType.put(objDescribe.getSObjectType(), objDescribe);
          }
      } else {
          throw new SchemaDescribeException('Invalid object name \'' + objectName + '\'');
      }
  }
  
  /*******************************************************************************************************
  * @description Returns object describe data.
  * @param objectName the name of the object to lookup
  * @return Schema.DescribeSObjectResult of the object
  */
  global static Schema.DescribeSObjectResult getObjectDescribe(String objectName) {
      objectName = objectName.toLowerCase();
      // make sure we have this object's schema mapped
      if (!objectDescribes.containsKey(objectName))
          fillMapsForObject(objectName);

      return objectDescribes.get(objectName);
  }
  
  /*******************************************************************************************************
  * @description Returns field describe data
  * @param objectName the name of the object to look up
  * @param fieldName the name of the field to look up
  * @return Schema.DescribeFieldResult the describe field result for the given field
  */
  global static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldName) {
      objectName = objectName.toLowerCase();
      fieldName = fieldName.toLowerCase();

      // make sure we have this field's schema mapped
      if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName)) {
          fillFieldMapsForObject(objectName, fieldName);
      }

      Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
      return dfr;
  }
  
   /*******************************************
  * Gets a field map for a new object/field pair
  ********************************************/
  private static void fillFieldMapsForObject(string objectName, string fieldName) {
      // get the object map the first time
      fillMapsForObject(objectName);

      // get the field description
      if (!fieldTokens.containsKey(objectName)) {
          fieldTokens.put(objectName, objectDescribes.get(objectName).fields.getMap());
          fieldDescribes.put(objectName, new Map<String, Schema.DescribeFieldResult>());
      }
      if (!fieldDescribes.get(objectName).containsKey(fieldName)) {
          if (fieldTokens.get(objectName).containsKey(fieldName)) {
              Schema.DescribeFieldResult dfr = fieldTokens.get(objectName).get(fieldName).getDescribe();
              fieldDescribes.get(objectName).put(fieldName, dfr);
          } else {
              throw new SchemaDescribeException('Invalid field name \'' + fieldName + '\'');
          }
      }
  }
}