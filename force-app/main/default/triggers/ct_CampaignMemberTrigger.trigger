trigger ct_CampaignMemberTrigger on CampaignMember (after insert, after update, after delete) {
  if(Trigger.isAfter){
    if(Trigger.isInsert){
       ct_CampaignMemberTriggerHandler.HandleAfterInsert(Trigger.new);
        
    }
  }
  if(Trigger.isAfter){
    if(Trigger.isUpdate){
            ct_CampaignMemberTriggerHandler.HandleAfterUpdate(Trigger.new, Trigger.old);
    }
  }
  if(Trigger.isDelete){
    if(Trigger.isAfter){
     ct_CampaignMemberTriggerHandler.HandleAfterDelete(Trigger.old);
    }
  }
}