/**
 * @description       : 
 * @author            : Umashankar Creation
 * @group             : 
 * @last modified on  : 02-11-2021
 * @last modified by  : Creation Admin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-10-2020   Umashankar Creation   Initial Version
**/
import { LightningElement, track, api } from 'lwc';
import getEventProductQuestions from '@salesforce/apex/ct_EventQuestionsFormController.getQuestionsForEventProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ct_EventQuestionsFormV2 extends LightningElement {
@api recordId;
@api ticketName;
@api ticket;
@track eventQuestions;
@api eventRegistration = {};
@api campaignMember = {};
@api eventOrder = {};

@track eventQuestionAnswers = {};
@track questionObject = {};
@track previousValue;
@api isDisabled = false;
@api dynamicSessionData;
@track selectedSession;
@track renderComp = false;
@track isDependentRender = false;
@track renderPrimarySession = false;
@api primarySessionOptions;

get primaryInterestLabel(){
  return this.ticket.primarySessionInterestLabel ? this.ticket.primarySessionInterestLabel : 'Which session would you like to attend?';
}

  connectedCallback(){

    if(this.dynamicSessionData && this.dynamicSessionData.sessionValues.length>0){
      this.primarySessionOptions = this.dynamicSessionData.sessionValues;
      if(this.ticket.allowPrimaryRegistration){
        this.renderPrimarySession = true;
      }
    }
    if(this.ticket
      && this.ticket.primarySessionIds
      && this.ticket.primarySessionIds != undefined  
      && this.ticket.primarySessionIds != null){
        this.selectedSession = this.ticket.primarySessionIds;
        var selectedSessionObj = {'selectionSessionId':   this.selectedSession, 
        'primaryAreaInterest': this.dynamicSessionData.sessionMap[this.selectedSession].Primary_Subject_Area_Interest__c};
        if(selectedSessionObj){
          this.dispatchEvent(new CustomEvent('sessionselection', { detail: selectedSessionObj }));
        }
    }
    this.getEventQuestions();
  }

  getEventQuestions(){

    getEventProductQuestions({recordId: this.recordId, ticketName: this.ticketName})
      .then(result=>{
        this.eventQuestions = result;
       
        if(this.eventQuestions.length > 0){
          this.renderComp = true;
        }
        //Construct Field API & Values for Respective Objects
    
        try {

          if(this.campaignMember && typeof this.campaignMember == 'string'){
            this.campaignMember = JSON.parse(this.campaignMember);
          }
          if(this.renderComp && 
            (this.eventRegistration
            || this.campaignMember
            || this.eventOrder)){
            for(var i=0;i<this.eventQuestions.length; i++){
              if(this.eventRegistration && this.eventRegistration.hasOwnProperty(this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c)
                && this.eventRegistration[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] != null 
                && this.eventRegistration[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] != undefined){
                  this.eventQuestions[i].eventRegRecordValue = this.eventRegistration[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c];
              }
              else if(this.campaignMember && this.campaignMember.hasOwnProperty(this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c)
                && this.campaignMember[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] != null 
                && this.campaignMember[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] != undefined){
                  this.eventQuestions[i].eventRegRecordValue = this.campaignMember[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c];
              }
              if(this.eventOrder && this.eventOrder.hasOwnProperty(this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c) 
                && this.eventOrder[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] != null 
                && this.eventOrder[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] !== undefined){
                  this.eventQuestions[i].eventRegRecordValue = this.eventOrder[this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c];

                }
            }

          }
      
            this.questionObject = {};
            var questionAnswerObject = {};
           // this.questionObject['eventProductId'] = id;
            for(var i=0;i<this.eventQuestions.length; i++){
              questionAnswerObject['eventProductId'] = this.eventQuestions[i].eventProductId;
              if(questionAnswerObject.hasOwnProperty(this.eventQuestions[i].thisQuestion.Object__c)){
                questionAnswerObject[this.eventQuestions[i].thisQuestion.Object__c][this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] = this.eventQuestions[i].eventRegRecordValue != null ? this.eventQuestions[i].eventRegRecordValue : null;
              }
              else{
                questionAnswerObject[this.eventQuestions[i].thisQuestion.Object__c] = {};
                questionAnswerObject[this.eventQuestions[i].thisQuestion.Object__c][this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c] = this.eventQuestions[i].eventRegRecordValue != null ? this.eventQuestions[i].eventRegRecordValue : null;
              }
            }
            this.dispatchEvent(new CustomEvent('answergiven', { detail: questionAnswerObject}));
          this.spinnerBoolean = false;
        }
        catch(err) {
          this.spinnerBoolean = false;
          this.customToastNotification('Error', err.message, true);
        }

      }).catch(error => {
        
        this.customToastNotification('Error', error, true);
    });
    

  }

  renderedCallback(){
    try{
      for(var i in this.eventQuestions){
        
        if(!this.eventQuestions[i].thisQuestion.Show_Only_Text__c && this.eventQuestions[i].thisQuestion.Default_Text__c){
          this.inputCompleteHandler(this.eventQuestions[i].thisQuestion.Default_Text__c, this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c, this.eventQuestions[i].eventProductId);
          this.template.querySelectorAll('input').forEach(element => {
            if(element.title == 'Picklist_Field__c' && element.value == this.eventQuestions[i].eventRegRecordValue){
              element.checked = true;
            }
          });
          
          this.dispatchEvent(new CustomEvent('questionrendered', { detail: true}));
  
        }
      }
    }
    catch(er){
      console.log('Error '+er);
    }
  }
  @api
  populateAddressDetails(orderDetails){
    var tempQuestion = JSON.parse(JSON.stringify(this.eventQuestions));
    this.eventQuestions = [];
    for(var i=0;i<tempQuestion.length; i++){
      if(orderDetails.hasOwnProperty(tempQuestion[i].thisQuestion.Even_Registration_Field_API_Name__c) 
        && orderDetails[tempQuestion[i].thisQuestion.Even_Registration_Field_API_Name__c] !== undefined){

          tempQuestion[i].eventRegRecordValue = orderDetails[tempQuestion[i].thisQuestion.Even_Registration_Field_API_Name__c];
        }
    }
    this.questionObject = {};
    var questionAnswerObject = {};
    // this.questionObject['eventProductId'] = id;
    for(var i=0;i<tempQuestion.length; i++){
      questionAnswerObject['eventProductId'] = tempQuestion[i].eventProductId;
      if(questionAnswerObject.hasOwnProperty(tempQuestion[i].thisQuestion.Object__c)){
        questionAnswerObject[tempQuestion[i].thisQuestion.Object__c][tempQuestion[i].thisQuestion.Even_Registration_Field_API_Name__c] = tempQuestion[i].eventRegRecordValue != null ? tempQuestion[i].eventRegRecordValue : null;
      }
      else{
        questionAnswerObject[tempQuestion[i].thisQuestion.Object__c] = {};
        questionAnswerObject[tempQuestion[i].thisQuestion.Object__c][tempQuestion[i].thisQuestion.Even_Registration_Field_API_Name__c] = tempQuestion[i].eventRegRecordValue != null ? tempQuestion[i].eventRegRecordValue : null;
      }
    }
    this.eventQuestions = tempQuestion;
    this.dispatchEvent(new CustomEvent('answergiven', { detail: questionAnswerObject}));
  }
  @api
  validateForm(){
    const allValid = [...this.template.querySelectorAll('.saveRequiredClass')]
    .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);
    var allDependent = true; 
    if(this.isDependentRender){
      allDependent =[...this.template.querySelectorAll('c-ct_-event-dependent-question-v2')]
      .reduce((validSoFar, inputCmp) => {
        return validSoFar && inputCmp.validateDependentForm();
    }, true);
    }
    return allValid && allDependent;
    

  }

  customToastNotification(toastTitle, toastMessage, isErrorMessage) {
    var messageString = isErrorMessage ? 'Error' : 'Success';
    const showToastEvent = new ShowToastEvent({
      Title: toastTitle,
      message: toastMessage,
      variant: messageString
    });
    this.dispatchEvent(showToastEvent);
  }

  handleValueChange(event){
    this.questionObject[event.target.title] = event.target.value;
  }

  handleInputComplete(event){
    var target = event.target;
   
    this.inputCompleteHandler(target.value, target.title, target.dataset.id)
  }
  
  inputCompleteHandler(value, title, id){
    if(value && value != this.previousValue){
      this.createQuestionObject(value, title, id);  

      this.previousValue = value;
      console.log('this.questionObject >>>'+ JSON.stringify(this.questionObject ));
      this.dispatchEvent(new CustomEvent('answergiven', { detail: this.questionObject }));
    }
  }

  handlePrimarySession(event){
    if(event.target.value){
    
      var selectedSessionObj = {'selectionSessionId':  event.target.value, 
                                'primaryAreaInterest': this.dynamicSessionData.sessionMap[event.target.value].Primary_Subject_Area_Interest__c};
      if(selectedSessionObj){
      
        this.dispatchEvent(new CustomEvent('sessionselection', { detail: selectedSessionObj }));
      }
    }
  }

  @api
  removeExcessiveSessions(sessionOptions){
    this.primarySessionOptions = sessionOptions;
  }

  createQuestionObject(value, title, id){
    var questionAnswerObject = {};
    this.questionObject = {};
    questionAnswerObject[title] = value;
    this.questionObject['eventProductId'] = id;
    for(var i in this.eventQuestions){
      if(this.eventQuestions[i].thisQuestion.Even_Registration_Field_API_Name__c == title){
        this.questionObject[this.eventQuestions[i].thisQuestion.Object__c] = questionAnswerObject;
      }
    }
    
  }
  handleDependentAnswers(event){
    this.dispatchEvent(new CustomEvent('answergiven', { detail: event.detail}));
  }  
  handleRender(event){
    this.isDependentRender = true;

  }
  @api
  resetSelectedSession(){
    this.template.querySelectorAll('lightning-combobox').forEach(element=>{
      if(element.id.indexOf('selectOptions') > -1) {
        console.log('found');
        element.value = null;
        this.selectedSession = null;
        
      }
    });
  }
}