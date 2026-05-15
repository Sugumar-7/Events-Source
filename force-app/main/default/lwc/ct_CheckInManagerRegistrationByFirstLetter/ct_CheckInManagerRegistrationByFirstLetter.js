import { LightningElement , api} from 'lwc';

export default class Ct_CheckInManagerRegistrationByFirstLetter extends LightningElement {
  @api isMainEntrance;
  @api getBy;
  @api registrationRecordsByFirstLetter = {};
  registrationRecords = [];

  get registationRecordsByFirstAlphabet(){
    return this.registrationRecordsByFirstLetter[this.getBy];
  }

  handlesessionRegUpdatedEvent(event){
    const dispatchSessionRegUpdatedEvent = new CustomEvent('sessionregupdatedevent', { detail: true });
    this.dispatchEvent(dispatchSessionRegUpdatedEvent);
  }
}