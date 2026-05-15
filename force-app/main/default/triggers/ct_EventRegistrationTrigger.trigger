trigger ct_EventRegistrationTrigger on Event_Registration__c (before insert,  before update, before delete, after insert, after update, after delete, after undelete) {

  if(Trigger.isBefore){
    if(Trigger.isInsert){
      // if (ct_TDTM_ProcessControl.getRecursionFlag(ct_TDTM_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_Before_Insert)) {
              ct_Event_RegistrationTriggerHandler.handleBeforeInsert(Trigger.new);
      // }
    }
  }
  if(Trigger.isAfter){
    if(Trigger.isInsert){
      // if (ct_TDTM_ProcessControl.getRecursionFlag(ct_TDTM_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Insert)) {
            ct_Event_RegistrationTriggerHandler.handleAfterInsert(Trigger.new);
        // }
    }
  }
  if(Trigger.isAfter){
    if(Trigger.isUpdate){
        // if (ct_TDTM_ProcessControl.getRecursionFlag(ct_TDTM_ProcessControl.registeredTrigger.ct_Event_RegistrationTriggerHandler_After_Update)) {
            ct_Event_RegistrationTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.old);
        // }
    }
  }
  if(Trigger.isDelete){
    if(Trigger.isAfter){
    // ct_Event_RegistrationTriggerHandler.handleAfterDelete(Trigger.new);
    }
  }
  
}