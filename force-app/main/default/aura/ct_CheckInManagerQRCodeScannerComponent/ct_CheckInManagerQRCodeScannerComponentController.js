({
    reInit : function(component, event, helper){
       // $A.get('e.force:refreshView').fire();
       console.log('NO REFRESH');
    },  
    doInit : function(component, event, helper) {
        var fullURL = window.location.href;
        console.log('Full URL:', fullURL);
        var thisPageReference = component.get("v.pageReference");
        console.log('c__eventid '+thisPageReference.state.c__eventid);
        console.log('c__eventregid '+thisPageReference.state.c__eventregid);
        if(thisPageReference.state.c__eventid){
            component.set("v.eventRecordId", thisPageReference.state.c__eventid);
        }
        if(thisPageReference.state.c__eventregid){
            component.set("v.eventRegistrationId", thisPageReference.state.c__eventregid);
        }
    }
})