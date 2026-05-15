import { LightningElement, track, api } from 'lwc';
import searchEventGroup from '@salesforce/apex/CT_EventSearchController.getEventGroups';

export default class Ct_eventGroupLookupV2 extends LightningElement {

  @track isGroup = false;
  @track showAddress = true;
  @track groupList = [];
  @track selectedGroup = {};
  @track searchString;
  @track isLoading;
  @track timeOut;
  
  connectedCallback(){
    console.log('connectedCallback');
    var stringurl = window.location.href;
    var newUrl = new URL(stringurl);
    var grpid = newUrl.searchParams.get("searchByGroup");
    this.onInputValueChange();
    console.log('grpid'+grpid);
    if(grpid != undefined && grpid != null){
      searchEventGroup().then( result => {
        this.isGroup = true;
        this.groupList = [];
        console.log('entered searchEventGroup');
        if(result.length > 0){
          this.groupList = result;
          for(var i=0; i < this.groupList.length; i++){
            var idx = this.groupList[i].value.split('UNIQUE_ID')[1];
            if(idx == grpid){
              this.selectedGroup = this.groupList[i].value;
            }
          }
        }
        else{
          this.groupList[0] = {'label': 'No Results Found', 'value': ''};
        }
       console.log('groupList'+JSON.stringify(this.groupList));
        this.isLoading = false;
        }).catch(error => {
          console.log('err in>>>' + error.message());
          this.groupList = [];
          var emptyAddressList = [];
          emptyAddressList[0] = {'label': 'No Results Found', 'value': ''};
          this.groupList = emptyAddressList;
        });
    }
    
  }

  onInputValueChange(){
    this.groupList = [];
    this.isGroup = false;
    // this.searchString = event.target.value;
    // if (event.keyCode == 27 || !this.searchString.trim()) {
    //   this.nullResultValues();
    //   const groupEvent = new CustomEvent('groupresults', { detail: '' });
    //   this.dispatchEvent(groupEvent);
    // }
    // else{
      this.isLoading = true;
     
      searchEventGroup().then( result => {
        this.isGroup = true;
        this.groupList = [];

        if(result.length > 0
          /*&& this.searchString.trim()*/){
          this.groupList = result;
        }
        // else if( !this.searchString.trim()){
        //   this.isGroup = false;
        //   this.groupList = [];
        // }
        else{
          this.groupList[0] = {'label': 'No Results Found', 'value': ''};
        }
               console.log('groupList'+JSON.stringify(this.groupList));

       
        this.isLoading = false;
        }).catch(error => {
          console.log('err in');
          this.groupList = [];
          var emptyAddressList = [];
          emptyAddressList[0] = {'label': 'No Results Found', 'value': ''};
          this.groupList = emptyAddressList;
        }); 
    //}
  }

  @api
  nullSearchValues(){
    this.isGroup = false;
    this.searchString = '';
    this.selectedGroup = '';
  }

  handleSelectedGroup(event){
    var target = event.target;
    console.log('target'+target.value.split('UNIQUE_ID')[1]);
    console.log('label>>> ',target.value);
    console.log('label123>>> ',JSON.stringify(target));
    if(target.value){
      var groupId = target.value.split('UNIQUE_ID')[1];
      const groupEvent = new CustomEvent('groupresults', { detail: groupId });
      this.dispatchEvent(groupEvent);
    }
    // if(event.currentTarget.value != 'No Results Found'){
    // var selectedSobjectIndex = this.getIndexFromParent(target, "data-selected-index");
    // selectedSobjectIndex = selectedSobjectIndex.split('UNIQUE_ID')[1];
    // this.searchString = event.currentTarget.title;
    // this.nullResultValues();
    // if(selectedSobjectIndex){
    //   console.log('selectedSobjectIndex'+selectedSobjectIndex);
    //   const groupEvent = new CustomEvent('groupresults', { detail: selectedSobjectIndex });
    //   this.dispatchEvent(groupEvent);
    // }
    // }else{
    //   this.searchString = null;
    //   this.nullResultValues();
    // }
  }

  // getIndexFromParent(target, attributeToFind){
	// 	var thisIndex = target.getAttribute(attributeToFind);
	// 	while (!thisIndex) {
	// 		target = target.parentNode;
	// 		thisIndex = this.getIndexFromParent(target, attributeToFind);
	// 	}
	// 	return thisIndex
	// }
}