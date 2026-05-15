import { LightningElement, api } from 'lwc';

export default class Ct_CustomToast extends LightningElement {
    @api title = 'Title';
    @api message = 'Message';
    @api variant = 'error';
    @api autoCloseTime = 3000;
    @api autoClose = false;
    @api autoCloseErrorWarning = false;

    @api
    showCustomNotice() {
      const toastModel = this.template.querySelector('[data-id="toastModel"]');
      toastModel.className = 'slds-show';
      
      if(this.autoClose)
          if( (this.autoCloseErrorWarning && this.variant !== 'success') || this.variant === 'success') {
              this.delayTimeout = setTimeout(() => {
                  const toastModel = this.template.querySelector('[data-id="toastModel"]');
                  toastModel.className = 'slds-hide';
              }, this.autoCloseTime);
              
      }
    }

    closeModel() {
        const toastModel = this.template.querySelector('[data-id="toastModel"]');
        toastModel.className = 'slds-hide';
    }

    get mainDivClass() { 
        return  'slds-notify slds-notify--toast customMinWidth slds-theme--'+this.variant;
      }

    get messageDivClass() { 
        return 'slds-icon_container slds-icon-utility-'+this.variant+' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
    get iconName() {
        return 'utility:'+this.variant;
    }
}