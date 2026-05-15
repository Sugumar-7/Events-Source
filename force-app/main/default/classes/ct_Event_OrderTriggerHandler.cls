/**
 * @description       : EVENT ORDER Trigger Handler
 * @author            : Creation Admin
**/
global without sharing class ct_Event_OrderTriggerHandler  {

    // global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    // hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

    // System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>CT EVENT ORDER TDTM TRIGGER HANDLER<<<<<<<<<<<<<<<<<<<<<<<<<<<');

    // hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

	  global static List<String> eventDetailsDataList = new List<String>();
    global static Set<Id> setIds = new Set<Id>();
    global static Set<Id> eventIds = new Set<Id>();

        // if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert){
          //Loop to get The required Ids 
        
    global static void handleAfterInsert(list<Event_Order__c> newlist){
      for(Event_Order__c thisEventOrder : newlist){
        if(thisEventOrder.Order_Status__c == ct_EventConstants.EVENT_ORDER_WAITING_LIST){
          Map<String,String> orderMap = new Map<String,String>();
          orderMap.put('recId', thisEventOrder.Id);
          orderMap.put('firstName', thisEventOrder.First_Name__c);
          orderMap.put('lastName', thisEventOrder.Last_Name__c);
          orderMap.put('email', thisEventOrder.Email__c);
          
          String jsonStr = JSON.serialize(orderMap);
          System.debug('jsonStr'+jsonStr);
          eventDetailsDataList.add(jsonStr); 
        }
        if(thisEventOrder.Event__c != null 
            && (thisEventOrder.Order_Status__c == 'Waiting List' || thisEventOrder.Order_Status__c == 'Waiting List Invitation')
            ){
              eventIds.add(thisEventOrder.Event__c);
        }
      }
      if(!eventDetailsDataList.isEmpty()){
        //Triggers the Web site submission platform event
        System.debug('triggerwebsite--1');
        ct_EventOrderTriggerHandlerHelper.triggerWebSiteSubmissionPlatformEvent(eventDetailsDataList);
      }
      if(!eventIds.isEmpty()){
        //calculate the number of event order
        ct_EventOrderTriggerHandlerHelper.updateEventswithEvtOrdCount(eventIds);
      }
    }
    
        // Before Update Logic
        // if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate){
    global static void handleBeforeUpdate(Map<Id,Event_Order__c> triggerOldMap, Map<Id,Event_Order__c> triggerNewMap){
    //  Map<Id, Event_Order__c> triggerOldMap = new Map<Id, Event_Order__c>((list<Event_Order__c>)oldlist);
    //  Map<Id, Event_Order__c> triggerNewMap = new Map<Id, Event_Order__c>((list<Event_Order__c>)newlist);

      for(Event_Order__c thisEventOrder : triggerNewMap.values()){
        //Check If Event Order Is Paid & Set To Cancelled
        if(thisEventOrder.Paid_Order__c && thisEventOrder.Order_Status__c == ct_EventConstants.EVENT_ORDER_STATUS_CANCELLED
        && !thisEventOrder.Event_Manager_Refund_Warning__c
        && triggerOldMap.get(thisEventOrder.Id).Order_Status__c != thisEventOrder.Order_Status__c){
          thisEventOrder.Event_Manager_Refund_Warning__c = true;
        }
      }  
    }
        // After Update logic
        // if (triggerAction == hed.TDTM_Runnable.Action.AfterUpdate){
    global static void handleAfterUpdate(Map<Id,Event_Order__c> triggerOldMap, Map<Id,Event_Order__c> triggerNewMap){
      // Map<Id, Event_Order__c> triggerOldMap = new Map<Id, Event_Order__c>((list<Event_Order__c>)oldlist);
      // Map<Id, Event_Order__c> triggerNewMap = new Map<Id, Event_Order__c>((list<Event_Order__c>)newlist);
      List<Event_Order__c> refundAlertEventOrderList = new List<Event_Order__c>();
      for(Event_Order__c thisEventOrder : [SELECT Id, Paid_Order__c, Order_Status__c, Event__r.Event_Manager__r.Email,
                                                  Event__r.Event_Manager_Refund_Notification_Email__c, Event_Manager_Refund_Warning__c
                                                  FROM Event_Order__c
                                                  WHERE Id IN: triggerNewMap.keySet()
                                                  AND Event_Manager_Refund_Warning__c = true]){
          //Check If It Is Paid Order & Event Status Is Set To Cancelled
          if(triggerOldMap.get(thisEventOrder.Id).Event_Manager_Refund_Warning__c != thisEventOrder.Event_Manager_Refund_Warning__c
            && thisEventOrder.Event__r.Event_Manager_Refund_Notification_Email__c == 'On'){
            refundAlertEventOrderList.add(thisEventOrder);
          }
      }
        // update event Order status
      for(Event_Order__c thisEventOrder : [SELECT Id, Paid_Order__c, Order_Status__c, Event__r.Event_Manager__r.Email,
                                                  Event_Manager_Refund_Warning__c
                                                  FROM Event_Order__c
                                                  WHERE Id IN: triggerNewMap.keySet()]){
          if(thisEventOrder.Event__c != null 
              && ((triggerOldMap.get(thisEventOrder.Id).Order_Status__c != 'Waiting List' 
                  && thisEventOrder.Order_Status__c == 'Waiting List')
              || (triggerOldMap.get(thisEventOrder.Id).Order_Status__c != 'Waiting List Invitation' 
                  && thisEventOrder.Order_Status__c =='Waiting List Invitation'))
          ){
              eventIds.add(thisEventOrder.Event__c);
          }
        }

      if(!refundAlertEventOrderList.isEmpty()){
        ct_EventOrderTriggerHandlerHelper.sendEventManagerRefundAlert(refundAlertEventOrderList);
      }
      if(!eventIds.isEmpty()){
        ct_EventOrderTriggerHandlerHelper.updateEventswithEvtOrdCount(eventIds);
      }
            
    }
        //Before Delete logic
        // if (triggerAction == hed.TDTM_Runnable.Action.BeforeDelete){
    global static void handleBeforeDelete(list<Event_Order__c> oldlist){
      System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>EVENT ORDER AFTER INSERT TRIGGER<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      for(Event_Order__c thisEventOrder : oldlist){
        if(thisEventOrder.Event__c != null 
          && (thisEventOrder.Order_Status__c == 'Waiting List' || thisEventOrder.Order_Status__c == 'Waiting List Invitation')
          ){
          eventIds.add(thisEventOrder.Event__c);
        }
      }
      if(!eventIds.isEmpty()){
        ct_EventOrderTriggerHandlerHelper.updateEventswithEvtOrdCount(eventIds);
      }
    }

  }