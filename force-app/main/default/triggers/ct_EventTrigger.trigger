trigger ct_EventTrigger on Event__c (before insert,  before update, before delete, after insert, after update, after delete, after undelete) {

  if(Trigger.isBefore){
    if(Trigger.isInsert){
        ct_EventTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if(Trigger.isUpdate){
        ct_EventTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
  }

  if(Trigger.isAfter){
    if(Trigger.isInsert){
        ct_EventTriggerHandler.handleAfterInsert(Trigger.new);
        ct_EventHandler.updateEventwithRegistrationURL(Trigger.newMap);
    }
    if(Trigger.isUpdate){
        ct_EventTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isDelete){
        ct_EventTriggerHandler.handleAfterDelete(Trigger.old);
    }
  }
}