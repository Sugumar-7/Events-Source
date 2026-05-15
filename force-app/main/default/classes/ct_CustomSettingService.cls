/**
 * @File Name          : ct_CustomSettingService.cls
 * @Description        : Service Class for Custom Settings
 * @Author             : Creation Admin
 * @Last Modified By   : Rajeshkumar
 * @Last Modified On   : 15-09-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/5/2020   Creation Admin     Initial Version
**/
global without sharing class ct_CustomSettingService {

  //global static Map<Id,  asp04__AsperatoOneSettings__c> asperatoSettingMapByUserId  = new  Map<Id,  asp04__AsperatoOneSettings__c>();

   /**
  * @description User's Asperato Setting Configurations custom setting Configuration by User ID
  * @return asp04__AsperatoOneSettings__c 
  **/
  // global static asp04__AsperatoOneSettings__c getAsperatoSetting(Id userId){
  //   if(asperatoSettingMapByUserId.isEmpty() 
  //      || asperatoSettingMapByUserId.containsKey(userId)){
  //       asperatoSettingMapByUserId.put(userId, asp04__AsperatoOneSettings__c.getInstance(userId));
  //     }
  //   return asperatoSettingMapByUserId.get(userId);
  // }

  /**
  * @description get User's  Asperato Setting Configurations custom setting Configuration
  * @return asp04__AsperatoOneSettings__c 
  **/
  // global static asp04__AsperatoOneSettings__c getCurrentUserAsperatoSetting(){
  //   return getAsperatoSetting(UserInfo.getUserId());
  // }
}