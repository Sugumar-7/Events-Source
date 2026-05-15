trigger ct_EventOrderTrigger on Event_Order__c (before insert,  before update, before delete, after insert, after update, after delete, after undelete) {

  if(Trigger.isBefore){
    
    if(Trigger.isUpdate){
      ct_Event_OrderTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isDelete){
      ct_Event_OrderTriggerHandler.handleBeforeDelete(Trigger.old);
    }

  }

  if(Trigger.isAfter){

    if(Trigger.isInsert){
      ct_Event_OrderTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if(Trigger.isUpdate){
      ct_Event_OrderTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }

  }

}