trigger ct_SessionTrigger on Session__c (before insert,  before update, before delete, after insert, after update, after delete, after undelete) {

  if(Trigger.isBefore){

    if(Trigger.isInsert){
      ct_SessionTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if(Trigger.isUpdate){
      ct_SessionTriggerHandler.handleBeforeUpdate(Trigger.new);
    }
    if(Trigger.isDelete){
      ct_SessionTriggerHandler.handleBeforeDelete(Trigger.old);
    }

  }

  if(Trigger.isAfter){

    if(Trigger.isInsert){
      ct_SessionTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if(Trigger.isUpdate){
      ct_SessionTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }

  }

}