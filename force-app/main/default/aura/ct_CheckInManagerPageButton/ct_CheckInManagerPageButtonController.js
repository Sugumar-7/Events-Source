({
    reInit : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    }, 

    doInit : function(component, event, helper) {
        var thisPageReference = component.get("v.pageReference");
        if(thisPageReference.state.c__eventid){
            component.set("v.eventRecordId", thisPageReference.state.c__eventid);
        }

        if(thisPageReference.state.c__sessionId){
            component.set("v.sessionRecordId", thisPageReference.state.c__sessionId);
        }
    }
})