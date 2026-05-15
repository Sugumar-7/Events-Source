import { LightningElement, api, track} from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';

const DELAY = 300;
const recordsPerPage = [10,25,50,100];
/*** Need to update ***/
// pageNumber is declared inside the class on line - 23, So we can remove the pageNumber that is declared globally.
const pageNumber = 1;
const showIt = 'visibility:visible';
const hideIt = 'display: none;'; //visibility keeps the component space, but display:none doesn't

export default class Ct_lightningPaginatorV2 extends LightningElement {
    //@api showSearchBox = false; //Show/hide search box; valid values are true/false
    @api showPagination; //Show/hide pagination; valid values are true/false
    @api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array 
    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pagesCutOff = 5;
    @track ceiling;
    @track floor;
    @track pageNumber = pageNumber; //Page number
    @track pageList=[];
    //@track searchKey; //Search Input
    @track controlPagination = showIt;
    @track controlPrevious = hideIt; //Controls the visibility of Previous page button
    @track controlNext = showIt; //Controls the visibility of Next page button
    @track gridStyle = 'slds-grid slds-p-around--small';
    @track resultPerPageStyle;
    @track paginationButtonStyle;
    recordsToDisplay = []; //Records to be displayed on the page


    get getPaginationBtnAlignment(){
      let gridStyle;
      if (formFactorPropertyName === 'Large') {
          gridStyle = 'slds-float_left';
      } else if (formFactorPropertyName === 'Medium') {
          gridStyle = 'slds-float_left';
      } else {
          gridStyle = 'slds-float_right';
      }
      return gridStyle;
    }

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        if(this.pageSizeOptions && this.pageSizeOptions.length > 0) 
            this.pageSize = this.pageSizeOptions[0];
        else{
            this.pageSize = this.totalRecords;
            this.showPagination = false;
        }
        this.controlPagination = this.showPagination === false ? hideIt : showIt;
        this.setRecordsToDisplay();
        if(this.totalPages <= this.pagesCutOff){
          for(var i = 1; i <= this.totalPages; i++) {
            this.pageList.push(i);
          }
        }
        else if(this.totalPages >= this.pagesCutOff){
          for(var i = 1; i <= this.pagesCutOff; i++) {
            this.pageList.push(i);
          }
        }
        
        
    }
    
    renderedCallback(){
      window.addEventListener('resize', this.handleWindowResize);
      this.handleWindowResize();
      //this.template.querySelector('[id^='+JSON.stringify(String(this.pageNumber))+']').classList.add('class1');
    }

    handleWindowResize = () =>{
      var windowWidth = window.innerWidth;
      
      if(parseInt(windowWidth) <=768){
        this.gridStyle = 'slds-grid slds-p-top--small slds-p-bottom--small slds-grid_vertical';
        this.resultPerPageStyle = 'slds-col slds-p-top--small slds-align_absolute-center';
        this.paginationButtonStyle='slds-col slds-align_absolute-center';
      }
      else if(parseInt(windowWidth) > 768){
        this.gridStyle = 'slds-grid slds-p-top--small slds-p-bottom--small';    
        this.resultPerPageStyle = 'slds-col slds-grid slds-grid_align-end';
        this.paginationButtonStyle='slds-col';
      }
      
    };

    handleRecordsPerPage(event){
        window.scrollTo(0, 0);
        this.pageSize = event.target.value;
        this.pageNumber = 1;
        this.setRecordsToDisplay();
        this.pageList=[];
        if(this.totalPages <= this.pagesCutOff){
          for(var i = 1; i <= this.totalPages; i++) {
            this.pageList.push(i);
          }
        }
        else if(this.totalPages >= this.pagesCutOff){
          for(var i = 1; i <= this.pagesCutOff; i++) {
            this.pageList.push(i);
          }
        }
        this.template.querySelectorAll('.activebutton').forEach(element => {
          element.classList.remove('class1');
        });  
        this.template.querySelector('[id^='+JSON.stringify(String(this.pageNumber))+']').classList.add('class1');
    }
    
    handlePageNumberChange(event){
      window.scrollTo(0, 0);
      this.pageNumber = event.target.value;
      this.setRecordsToDisplay();
      var eventIdVal = event.target.id;

      if(parseInt(this.pageNumber)>3 && parseInt(this.pageNumber)+2 < this.totalPages){
        this.pageList=[];
        for(var i = parseInt(this.pageNumber)-2; i <= parseInt(this.pageNumber)+2; i++) {
          this.pageList.push(i);
        }
      }
      else if(parseInt(this.pageNumber)>3 && parseInt(this.pageNumber)+1 <= this.totalPages){
        this.pageList=[];
        for(var i = parseInt(this.pageNumber)-2; i <= this.totalPages; i++) {
          this.pageList.push(i);
        }
      }
      this.template.querySelectorAll('.activebutton').forEach(element => {
        element.classList.remove('class1');
      });
      // this.template.querySelector('[id='+JSON.stringify(eventIdVal)+']').classList.add('class1');
      this.template.querySelector('[id^='+JSON.stringify(String(this.pageNumber))+']').classList.add('class1');
    }
    previousPage(){
        window.scrollTo(0, 0);
        this.pageNumber = parseInt(this.pageNumber)-1;
        this.setRecordsToDisplay();
        if(parseInt(this.pageNumber)>3 && parseInt(this.pageNumber) < this.totalPages){
          this.pageList=[];
          for(var i = parseInt(this.pageNumber)-2; i <= parseInt(this.pageNumber)+2; i++) {
            this.pageList.push(i);
          }
        }
        else if(parseInt(this.pageNumber)<=3 && parseInt(this.pageNumber) < this.totalPages){
          if(parseInt(this.pageNumber)==3){
            this.pageList=[];
            for(var i = parseInt(this.pageNumber)-2; i <= parseInt(this.pageNumber)+2; i++) {
              this.pageList.push(i);
            }
          }
        }
        
        this.template.querySelectorAll('.activebutton').forEach(element => {
          element.classList.remove('class1');
        });
        this.template.querySelector('[id^='+JSON.stringify(String(this.pageNumber))+']').classList.add('class1');
    }
    nextPage(){
        window.scrollTo(0, 0);
        this.pageNumber = parseInt(this.pageNumber)+1;
        this.setRecordsToDisplay();
        if(parseInt(this.pageNumber)>3 && parseInt(this.pageNumber)+2 < this.totalPages){
          this.pageList=[];
          for(var i = parseInt(this.pageNumber)-2; i <= parseInt(this.pageNumber)+2; i++) {
            this.pageList.push(i);
          }
        }
        else if(parseInt(this.pageNumber)>3 && parseInt(this.pageNumber) == parseInt(this.totalPages)-2){
          this.pageList=[];
          for(var i = parseInt(this.pageNumber)-2; i <= this.totalPages; i++) {
            this.pageList.push(i);
          }
        }
        this.template.querySelectorAll('.activebutton').forEach(element => {
          element.classList.remove('class1');
        });
        this.template.querySelector('[id^='+JSON.stringify(String(this.pageNumber))+']').classList.add('class1');
    }
    
    setRecordsToDisplay(){

        this.recordsToDisplay = [];
        if(!this.pageSize)
            this.pageSize = this.totalRecords;
        this.totalPages = Math.ceil(this.totalRecords/this.pageSize);
        
        this.setPaginationControls();
        for(let i=(this.pageNumber-1)*this.pageSize; i < this.pageNumber*this.pageSize; i++){
            if(i === this.totalRecords) break;
            this.recordsToDisplay.push(this.records[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay})); //Send records to display on table to the parent component
      }
    setPaginationControls(){
        //Control Pre/Next buttons visibility by Total pages
        if(this.totalPages === 1){
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }else if(this.totalPages > 1){
           this.controlPrevious = showIt;
           this.controlNext = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNumber <= 1){
            this.pageNumber = 1;
            this.controlPrevious = hideIt;
        }else if(this.pageNumber >= this.totalPages){
            this.pageNumber = this.totalPages;
            this.controlNext = hideIt;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        if(this.controlPagination === hideIt){
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }
    }

    //Method to search sessions in pagination for Session Registration Component
    @api
    handleSessionSearch(value, searchType) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = value;
        if(searchKey && (searchKey != 'allSessions' && searchKey != 'mySessions')){
            this.delayTimeout = setTimeout(() => {
                this.controlPagination = hideIt;
                this.setPaginationControls();
                this.searchKey = searchKey;
                
                if(searchType == 'titleSearch'){
                  this.recordsToDisplay = this.records.filter(rec => rec.session.Name.toLowerCase().includes(searchKey.toLowerCase()));
                }
                else if(searchType == 'trackSearch'){
                  this.recordsToDisplay = this.records.filter(rec => rec.session.Track__c == searchKey);
                }

                if(Array.isArray(this.recordsToDisplay) && this.recordsToDisplay.length > 0){
                  this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay})); //Send records to display on table to the parent component
                }
                else{
                  // this.controlPagination = showIt;
                  // this.setRecordsToDisplay();
                  console.log('Lightning dispatch');
                  this.dispatchEvent(new CustomEvent('paginatorchange', {detail: 'No Records'})); //Send records to display on table to the parent component
                }
            }, DELAY);
        }
        else if(searchKey && searchKey == 'mySessions'){ 
          this.delayTimeout = setTimeout(() => {
            this.controlPagination = hideIt;
            this.setPaginationControls();
            this.searchKey = searchKey;

            this.recordsToDisplay = this.records.filter(rec => rec.isRegistered || rec.isOnWaitingList);

            if(Array.isArray(this.recordsToDisplay) && this.recordsToDisplay.length > 0){
              this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay})); //Send records to display on table to the parent component
            }
            else{
              
              this.dispatchEvent(new CustomEvent('paginatorchange', {detail: 'No Records'})); //Send records to display on table to the parent component
            }
          }, DELAY);
        }
        else{
            this.controlPagination = showIt;
            this.setRecordsToDisplay();
        }        
    }
}