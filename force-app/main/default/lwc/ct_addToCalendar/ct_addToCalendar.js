import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import TIME_ZONE from "@salesforce/i18n/timeZone";
import getCalendar from "@salesforce/apex/CT_AddToCalendarController.getCalendar";

const LINE_SEPARATOR = "\n";
const GOOGLE_CALENDAR_URL = "https://calendar.google.com/calendar/r/eventedit";
const YAHOO_CALENDAR_URL = "https://calendar.yahoo.com/?v=60";

export default class Ct_addToCalendar extends NavigationMixin(
  LightningElement
) {
  clientName;
  subject;
  startDateTime;
  endDateTime;
  description;
  location;
  timeZone;
  eventDuration;
  @api recordId;
  @track enddate = true;

  connectedCallback() {
    try{
      getCalendar({ recordId: this.recordId })
      .then((result) => {
        this.subject = result.subject;
        this.description = result.description;
        this.location = result.location;
        this.timeZone = result.timeZone;
        this.eventDuration = result.eventDuration;
        if(result.startDateTime && result.endDateTime){
          this.startDateTime = result.startDateTime;
          this.endDateTime = result.endDateTime;
        }
        else{
          this.enddate = false;
        }
        //this.endDateTime = result.endDateTime;
      })
      .catch((error) => {
        this.displayErrorMessage(error);
      });
    }
    catch(err) {
      this.displayErrorMessage('Error connectedCallback', err.message, true);
    }
   
  }
  addToCalendar(event) {
    this.clientName = event.target.value;
    switch (this.clientName) {
      case "google":
        this.navigateToWebPage(this.getGoogleCalendarUrl());
        break;
      case "yahoo":
        this.navigateToWebPage(this.getYahooCalendarUrl());
        break;
      default:
        this.downloadCalendar(this.getInternetCalendar());
        break;
    }
  }

  downloadCalendar(calendarToDownload) {
    let downloadElement = document.createElement("a");
    downloadElement.href =
      "data:text/calendar;charset=utf-8," + encodeURI(calendarToDownload);
    downloadElement.target = "_blank";
    downloadElement.download = "download";
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  getGoogleCalendarUrl() {
    let googleCalendar = GOOGLE_CALENDAR_URL;
    googleCalendar += "?text=" + encodeURIComponent(this.subject);
    googleCalendar +=
      "&dates=" +
      this.removeSpecialCharacters(this.startDateTime) +
      "/" +
      this.removeSpecialCharacters(this.endDateTime);
    //googleCalendar += "&ctx=" + TIME_ZONE; this.timeZone
    googleCalendar += "&ctz=" + this.timeZone;
    googleCalendar += "&details=" + encodeURIComponent(this.description);
    googleCalendar += "&location=" + this.location;
    return googleCalendar;
  }

  getYahooCalendarUrl() {
    let yahooCalendar = YAHOO_CALENDAR_URL;
    yahooCalendar += "&title=" + encodeURIComponent(this.subject);
    yahooCalendar += "&st=" + this.removeSpecialCharacters(this.startDateTime);
    //yahooCalendar += "&et=" + this.removeSpecialCharacters(this.endDateTime);
    yahooCalendar += "&dur=" +this.eventDuration;
    yahooCalendar += "&desc=" + encodeURIComponent(this.description);
    yahooCalendar += "&in_loc=" + this.location;
    return yahooCalendar;
  }

  getInternetCalendar() {
    let icalendar = "";
    icalendar += "BEGIN:VCALENDAR" + LINE_SEPARATOR;
    icalendar += "VERSION:2.0" + LINE_SEPARATOR;
    icalendar += "PRODID:-//LED//Launch ED//EN" + LINE_SEPARATOR;
    icalendar += "BEGIN:VEVENT" + LINE_SEPARATOR;
    icalendar +=
      "DTSTART:" +
      this.removeSpecialCharacters(this.startDateTime) +
      LINE_SEPARATOR;
    icalendar +=
      "DTEND:" +
      this.removeSpecialCharacters(this.endDateTime) +
      LINE_SEPARATOR;
    icalendar += "SUMMARY:" + this.subject + LINE_SEPARATOR;
    icalendar += "DESCRIPTION:" + this.description + LINE_SEPARATOR;
    icalendar += "LOCATION:" + this.location + LINE_SEPARATOR;
    icalendar += "END:VEVENT" + LINE_SEPARATOR;
    icalendar += "END:VCALENDAR";
    return icalendar;
  }

  navigateToWebPage(urlToNavigate) {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: urlToNavigate
        }
      },
      false
    );
  }

  removeSpecialCharacters(dateToFormat) {
    dateToFormat = dateToFormat.replace(/-/g, "");
    dateToFormat = dateToFormat.replace(/:/g, "");
    dateToFormat = dateToFormat.replace(/.000Z/g, "Z");
    return dateToFormat;
  }

  displayErrorMessage(error) {
    let message = "Unknown error";
    if (Array.isArray(error.body)) {
      message = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      message = error.body.message;
    }
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error loading event",
        message,
        variant: "error"
      })
    );
  }

  showWarningToast() {
    const evt = new ShowToastEvent({
        title: 'Toast Warning',
        message: 'Make Sure Event Has a Start Data and End Date Information',
        variant: 'warning',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}
}