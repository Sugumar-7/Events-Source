import { LightningElement, track, api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
export default class Ct_eventSummaryBoxV2 extends LightningElement {
    @api selectedEvent;
    @track startTimeValue;
    @track endTimeValue;

    get getGridStyle(){
        let style = 'slds-grid slds-gutters slds-p-top--xx-small';
        if (formFactorPropertyName === 'Small') {
          style = 'slds-grid slds-gutters slds-grid_vertical slds-p-top--xx-small';
        }
        return style;
    }
    connectedCallback() {
        if(this.selectedEvent){     
          console.log('this.selectedEvent' +this.selectedEvent);       
            this.startTimeValue = this.convertMilliSecondsToHHMM(this.selectedEvent.Start_Time__c);
            this.endTimeValue = this.convertMilliSecondsToHHMM(this.selectedEvent.End_Time__c);
        }
    }
    convertMilliSecondsToHHMM(durationInMs) {
        if(durationInMs.toString().includes(':')){
            var hours = durationInMs.toString().slice(0,2);
            var mins = durationInMs.toString().slice(3,5);
          
            var AMORPM = hours >= 12 ? 'pm': 'am';
      
            if(hours > 12){
              hours = hours % 12;      
            }
            return Math.round(hours) + "." + mins + AMORPM;
            //return durationInMs;
        }
        else{
          let milliseconds = parseInt((durationInMs % 1000) / 100),
          seconds = parseInt((durationInMs / 1000) % 60),
          minutes = parseInt((durationInMs / (1000 * 60)) % 60),
          hours = parseInt((durationInMs / (1000 * 60 * 60)) % 24);
          var AMORPM = hours >= 12 ? 'pm': 'am';
          if(hours > 12){
            hours = hours % 12;      
          }          
          //hours = hours < 10 ? "0" + hours : hours;
          minutes = minutes < 10 ? "0" + minutes : minutes;
          seconds = seconds < 10 ? "0" + seconds : seconds;
          return Math.round(hours) + "." + minutes + AMORPM;
          //return hours + ":" + minutes;
        }
        
      }
    
}