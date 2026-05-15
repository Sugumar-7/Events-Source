/**
 * @description       : Clone of TDTM_ProcessControl From EDA Package for recursion control
 * @author            : Creation Admin
**/
global without sharing class ct_ProcessControl {
    /*******************************************************************************************************
    * @description Enum to define the various recursion prevention types used by all the related TDTM classes
    */
  global enum registeredTrigger {
    ct_CampaignMemberTriggerHandler_After_Insert,
    ct_CampaignMemberTriggerHandler_After_Update,
    ct_Event_RegistrationTriggerHandler_Before_Insert,
    ct_Event_RegistrationTriggerHandler_After_Insert,
    ct_Event_RegistrationTriggerHandler_After_Update
  }

  /*******************************************************************************************************
  * @description Map to track the specific recursion type status
  */
  private static Map<registeredTrigger, Integer> recursionMap = new Map<registeredTrigger, Integer>();

  global static void setRecursionFlag(registeredTrigger f, boolean b){
     Integer recursionFlag = (recursionMap.containsKey(f) ? recursionMap.get(f) : 0);
     recursionFlag += (b ? 1 : -1);
     if (recursionFlag < 0){
         recursionFlag = 0;
     }
     recursionMap.put(f, recursionFlag);
  }

  /*******************************************************************************************************
  * @description Map to track the specific recursion type status
  */
  global static Boolean getRecursionFlag(registeredTrigger f) {
     return (recursionMap.containsKey(f) ? recursionMap.get(f) : 0) > 0;
  }

  /*******************************************************************************************************
  * @description turn off the recursion flag manually. Set as 1001 because the limit is 1000 dml per transaction
  */
  global static void turnOffRecursionFlag(registeredTrigger f){
     recursionMap.put(f, 1001);
  }

  /*******************************************************************************************************
  * @description reset the recursion flag
  */
  global static void resetRecursionFlag(registeredTrigger f){
     recursionMap.put(f, 0);
  }  








//   global enum eventRegisteredTrigger {
//         EventReg_AfterInsert,
//         EventReg_AfterUpdate,
//         EventReg_BeforeInsert,
//         EventReg_BeforeUpdate
//     }


//     private static Map<eventRegisteredTrigger, Boolean> recursionFlags = new Map<eventRegisteredTrigger, Boolean>{
//         eventRegisteredTrigger.EventReg_AfterInsert => true,
//         eventRegisteredTrigger.EventReg_AfterUpdate => true,
//         eventRegisteredTrigger.EventReg_BeforeInsert => true,
//         eventRegisteredTrigger.EventReg_BeforeUpdate => true
//     };

//     global static void turnOffRecursionFlagnew(eventRegisteredTrigger trig) {
//         recursionFlags.put(trig, false);
//     }

//     global static void resetRecursionFlagnew(eventRegisteredTrigger trig) {
//         recursionFlags.put(trig, true);
//     }

//     global static Boolean isActive(eventRegisteredTrigger trig) {
//         return recursionFlags.get(trig);
//     }
}