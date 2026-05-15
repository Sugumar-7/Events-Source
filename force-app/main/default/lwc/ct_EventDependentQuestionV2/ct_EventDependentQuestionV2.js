/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 01-16-2021
 * @last modified by  : Umashankar Creation
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-10-2020   Umashankar Creation   Initial Version
**/
import {  LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ct_EventDependentQuestionV2 extends LightningElement {
  @api questionWrapper;
  questionObject = {};
  sourcePicklistValue;
  picklistOptions =[];
  @track dependentWrapper = {};
  @api isDisabled;
  isDependentToShow;
  previousValue;
  @api eventRegistration = {};
  @api campaignMember = {};

  connectedCallback(){
    this.dependentWrapper['fieldAPIName'] = this.questionWrapper.thisQuestion.Even_Registration_Field_API_Name__c;
    this.dependentWrapper['eventRegRecordValue'] = null;

    var dependentArray = [];
    dependentArray = Object.values(this.questionWrapper.dependentPicklistFields);
    try{

    
      if((this.campaignMember && Object.keys(this.campaignMember).length > 0)
      || (this.eventRegistration && Object.keys(this.eventRegistration).length > 0)){
        for(var i=0; i < dependentArray.length; i++){
          if( this.eventRegistration[dependentArray[i].fieldAPIName] != null 
            && this.eventRegistration[dependentArray[i].fieldAPIName] != undefined){
            this.dependentWrapper.eventRegRecordValue = this.eventRegistration[dependentArray[i].fieldAPIName];
            this.dependentWrapper['fieldAPIName'] = [dependentArray[i].fieldAPIName];
            this.picklistOptions = dependentArray[i].picklistOptions;
            this.isDependentToShow = true;
          }
          else if( this.campaignMember[dependentArray[i].fieldAPIName] != null 
          && this.campaignMember[dependentArray[i].fieldAPIName] != undefined){
            this.dependentWrapper.eventRegRecordValue = this.campaignMember[dependentArray[i].fieldAPIName];
            this.dependentWrapper['fieldAPIName'] = [dependentArray[i].fieldAPIName];
            this.picklistOptions = dependentArray[i].picklistOptions;
            this.isDependentToShow = true;
          }
        }
      }
      else if(this.questionWrapper.eventRegRecordValue != null
      && this.questionWrapper.dependentPicklistFields.hasOwnProperty(this.questionWrapper.eventRegRecordValue)
      && this.questionWrapper.dependentPicklistFields[this.questionWrapper.eventRegRecordValue].eventRegRecordValue != null){
        this.dependentWrapper['fieldAPIName'] = this.questionWrapper.dependentPicklistFields[this.questionWrapper.eventRegRecordValue].fieldAPIName;
        this.picklistOptions = this.questionWrapper.dependentPicklistFields[this.questionWrapper.eventRegRecordValue].picklistOptions;
        this.dependentWrapper.eventRegRecordValue = this.questionWrapper.dependentPicklistFields[this.questionWrapper.eventRegRecordValue].eventRegRecordValue;
        this.isDependentToShow =  true;
      }
      else if(this.questionWrapper.eventRegRecordValue != null
      && this.questionWrapper.dependentPicklistFields.hasOwnProperty(this.questionWrapper.eventRegRecordValue)){
          this.dependentWrapper['fieldAPIName'] = this.questionWrapper.dependentPicklistFields[this.questionWrapper.eventRegRecordValue].fieldAPIName;
          this.picklistOptions = this.questionWrapper.dependentPicklistFields[this.questionWrapper.eventRegRecordValue].picklistOptions;
          this.isDependentToShow =  true;
      }
      else{
        this.questionObject = {};
        var questionAnswerObject = {};
        questionAnswerObject['eventProductId'] = this.questionWrapper.eventProductId;
        Object.keys(this.questionWrapper.dependentPicklistFields).forEach(key => {
          if(questionAnswerObject.hasOwnProperty(this.questionWrapper.dependentPicklistFields[key].objectName)){
            questionAnswerObject[this.questionWrapper.dependentPicklistFields[key].objectName][this.questionWrapper.dependentPicklistFields[key].fieldAPIName] = null;
          }
          else{
            questionAnswerObject[this.questionWrapper.dependentPicklistFields[key].objectName] = {};
            questionAnswerObject[this.questionWrapper.dependentPicklistFields[key].objectName][this.questionWrapper.dependentPicklistFields[key].fieldAPIName] = null;
          }          
        });
        this.dispatchEvent(new CustomEvent('answer', { detail: questionAnswerObject}));

      }
    }
    catch(err){
      console.log('Error '+ err.message);
    }
  }
  handleValueChange(event){
    try{
    var dependent = {};
    
    this.questionObject[event.target.title] = event.target.value;
    if(this.questionWrapper.dependentPicklistFields.hasOwnProperty(event.target.value)){
      this.picklistOptions = this.questionWrapper.dependentPicklistFields[event.target.value].picklistOptions;
      dependent = JSON.parse(JSON.stringify(this.questionWrapper.dependentPicklistFields[event.target.value]));
      dependent['eventRegRecordValue'] = null;
      this.dependentWrapper = dependent;
      this.isDependentToShow = true;
      Object.keys(this.questionWrapper.dependentPicklistFields).forEach(key => {
        if(key != event.target.value){
          this.dispatchDependentEvent(null, this.questionWrapper.dependentPicklistFields[key].fieldAPIName,event.target.dataset.id, this.questionWrapper.dependentPicklistFields[key].objectName);
        }
      });

      //this.sourcePicklistValue = event.target.value;
    }
    else if(this.questionWrapper.thisQuestion.Even_Registration_Field_API_Name__c == event.target.title){
      this.dependentWrapper = {};
      this.dependentWrapper['fieldAPIName'] = this.questionWrapper.thisQuestion.Even_Registration_Field_API_Name__c;
      this.dependentWrapper['eventRegRecordValue'] = null;
      this.picklistOptions = [];
      this.isDependentToShow = false;
    }
  }
  catch(error){
    console.log('Error '+error.message);
  }
  }

  handleDependentChange(event){
    if(this.dependentWrapper){
      this.dependentWrapper.eventRegRecordValue = event.target.value;
    }
  }

  handleInputComplete(event){
    var target = event.target;
    this.inputCompleteHandler(target.value, target.title, target.dataset.id)
  }
  
  inputCompleteHandler(value, title, id){
    if(value){
      this.createQuestionObject(value, title, id);  
    }
  }
  @api
  validateDependentForm(){
    const allValid = [...this.template.querySelectorAll('.saveRequiredClass')]
    .reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    if(!allValid){
      return false;
    }
    else{
      return true;
    }
  }
  createQuestionObject(value, title, id){
    var questionAnswerObject = {};
    this.questionObject = {};
    
    this.questionObject['eventProductId'] = id;
    if(this.questionWrapper.thisQuestion.Even_Registration_Field_API_Name__c == title){
      questionAnswerObject[title] = value;
      this.questionObject[this.questionWrapper.thisQuestion.Object__c] = questionAnswerObject;
      this.dispatchEvent(new CustomEvent('answer', { detail: this.questionObject}));
    }
    if(!this.questionWrapper.dependentPicklistFields.hasOwnProperty(value)){
      Object.keys(this.questionWrapper.dependentPicklistFields).forEach(key => {
        if(this.questionWrapper.dependentPicklistFields[key].fieldAPIName == title){
          this.dispatchDependentEvent(value, title, id, this.questionWrapper.dependentPicklistFields[key].objectName);
        }
        else{
          this.dispatchDependentEvent(null, this.questionWrapper.dependentPicklistFields[key].fieldAPIName, id, this.questionWrapper.dependentPicklistFields[key].objectName);
        }
      });
    }
  }
  
  dispatchDependentEvent(value, title, id, objname){
    var questionAnswerObject = {};
    this.questionObject  = {};
    this.questionObject['eventProductId'] = id;
    questionAnswerObject[title] = value;
    this.questionObject[objname] = questionAnswerObject;
    this.dispatchEvent(new CustomEvent('answer', { detail: this.questionObject}));
  }
  renderedCallback(){
    this.dispatchEvent(new CustomEvent('render', { detail: true}));
  }

}