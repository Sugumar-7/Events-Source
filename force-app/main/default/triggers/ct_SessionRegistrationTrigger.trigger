trigger ct_SessionRegistrationTrigger on Session_Registration__c (before insert) {
if(Trigger.isBefore){
    if(Trigger.isInsert){
              ct_SessionRegistrationHandler.handleBeforeInsert(Trigger.new);
    }
  }
}