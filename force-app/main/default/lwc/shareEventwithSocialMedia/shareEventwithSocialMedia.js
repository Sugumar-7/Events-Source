/**
 * @description       : 
 * @author            : Rajesh Creation
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : Javid Sherif
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   05-05-2021   Rajesh Creation   Initial Version
**/
import { LightningElement, wire, track, api } from 'lwc';
import socialMediaIcons from '@salesforce/resourceUrl/EventSocialMediaIcons';
import sitBaseURL from '@salesforce/label/c.Site_Base_URL';
import getEventRec from '@salesforce/apex/ShareEventWithSocialMedia.getEventRec';

export default class ShareEventwithSocialMedia extends LightningElement {
    @api recordId;
    @track correntrecordId;
    @track evt;
    @track error;
    @track facebookUrl;
    @track fbUrl;
    @track LnUrl;
    @track twitterUrl;
    @track isVisible;
    @track isVisibleFB;
    @track isVisibleLn;
    @track isVisibleTw;
    @track appselected;
    
    
    facebook = socialMediaIcons + '/images/facebook.png';
    linkedin = socialMediaIcons + '/images/linkedin.png';
    twitter = socialMediaIcons + '/images/twitter.png';
    
    
    connectedCallback(){
        
        this.correntrecordId = this.recordId;
        getEventRec({recordId: this.recordId})
        .then(result => {
            // alert(JSON.stringify(result));
            this.evt = result;
            if(this.evt.Social_App_Visibility__c === 'Visible'){
                this.isVisible = true;
              }
              if(this.evt.Visible_Social_App__c != undefined && (this.evt.Visible_Social_App__c.indexOf('Facebook')>-1)){
                this.isVisibleFB =true;
              }
              if(this.evt.Visible_Social_App__c != undefined && (this.evt.Visible_Social_App__c.indexOf('Linkedin')>-1)){
                this.isVisibleLn =true;
              }
              if(this.evt.Visible_Social_App__c != undefined && (this.evt.Visible_Social_App__c.indexOf('Twitter')>-1)){
                this.isVisibleTw =true;
              }
            //this.modalMessages = result;
        })
        .catch(error => {
            this.error = error;
        })
    }

   

    handleClickFb(event){
        this.fbUrl = 'https://www.facebook.com/dialog/share?app_id=87741124305&href='+sitBaseURL+'%2Fevent%2Fs%2Fevent-ticket-selection?id='+this.evt.Id+'&display=page&redirect_uri=https://www.facebook.com/';        
        window.open(this.fbUrl);
    }
    handleClickTw(event){
        this.twitterUrl = 'https://twitter.com/intent/tweet?url='+sitBaseURL+'/ledevents/s/event-ticket-selection?id='+this.evt.Id;
        window.open(this.twitterUrl);    }
    handleClickLn(event){
        this.LnUrl= 'https://www.linkedin.com/sharing/share-offsite/?url='+sitBaseURL+'/ledevents/s/event-ticket-selection?id='+this.evt.Id+'%3Fv%3Dpr-4GbR4DpQ%26feature%3Dshare';
        window.open(this.LnUrl);    }
}