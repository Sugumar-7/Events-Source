/**
 * @File Name          : ct_Constants.cls
 * @Description        : Class which stores the global constants
 * @Author             : Creation Admin
 * @Last Modified By   : Rajeshkumar
 * @Last Modified On   : 15-09-2021
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    12/19/2019   Creation Admin     Initial Version
 * 2.0    31/07/2020  Creation Admin          Added 'processPreferredEmail' method for processing preferred email when two or more email fields
**/
global without sharing class ct_Constants {

  //--------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------   SOBJECT Constants    ------------------------------------------------------------------/


  /***************************************************   Lead Constants    ******************************************************************/
  //Lead  Picklist values Constants

  //Lead Source : LeadSource
  global static final string LEAD_SOURCE_APPLICATION   = 'Application';

  // NOT USED ANY WHERE
  //global static final Id LEAD_RECORDTYPE_BUSINESS   = ct_Util.getRecordTypeIdByDevName('Lead', 'B2B_R_I_Leads');




  /***************************************************   Account Constants    ******************************************************************/

  //Account RecordType Id Constants
  global static final Id ACCOUNT_RECORDTYPE_STUDENT_ORGANISATION    = ct_Util.getRecordTypeIdByDevName('Account', 'Sports_Organization');
  global static final Id ACCOUNT_RECORDTYPE_ADMINISTRATIVE          = ct_Util.getRecordTypeIdByDevName('Account', 'Administrative');
  global static final Id ACCOUNT_RECORDTYPE_ACADEMIC_PROGRAM        = ct_Util.getRecordTypeIdByDevName('Account', 'Academic_Program');
  global static final Id ACCOUNT_RECORDTYPE_EDUCATIONAL_INSTITUTION = ct_Util.getRecordTypeIdByDevName('Account', 'Educational_Institution');

  //Account Record Type Name Constants
  global static final string ACCOUNT_BUSINESS_ORGANISATION_RECORDTYPE_NAME       = 'Business_Organization';

  /***************************************************   Contact Constants   ******************************************************************/

  //Contact RecordType Id Constants
  global static final Id CONTACT_RECORDTYPE_UOPSTUDENT = ct_Util.getRecordTypeIdByDevName('Contact', 'LED_Contact');

  //Contact Picklist values Constants

  //Donor Type : Donor_Type__c
  global static final string CONTACT_DONOR_TYPE_COMMUNITY_DONOR   = 'Community Donor (Less than £1k)';
  global static final string CONTACT_DONOR_TYPE_LEADERSHIP_DONOR  = 'Leadership Donor (£1k to £5k)';
  global static final string CONTACT_DONOR_TYPE_MAJOR_DONOR       = 'Major Donor (£5k to £10k)';
  global static final string CONTACT_DONOR_TYPE_PRINCIPAL_DONOR   = 'Principal Donor (£10k+)';

  //Donor Status : Donor_Status__c
  global static final string CONTACT_DONOR_STATUS_PROSPECT    = 'Prospect (Open Opp)';
  global static final string CONTACT_DONOR_STATUS_PLEDGED     = 'Pledged (Pledged Opp)';
  global static final string CONTACT_DONOR_STATUS_CURRENT     = 'Current (CW Last 12 Months)';
  global static final string CONTACT_DONOR_STATUS_LAPSED      = 'Lapsed (CW 12 Months+)';

  //Volunteer Status : GW_Volunteers__Volunteer_Status__c
  global static final String VOLUNTEER_STATUS_ACTIVE        = 'Active';
  global static final String VOLUNTEER_STATUS_PROSPECTIVE   = 'Prospective';

  //Community Relationship : Community_Relationship__c
  global static final String COMMUNITY_RELATIONSHIP_STAFF   = 'Staff';

  //Lead Source : LeadSource
  global static final String ONLINE_DONATION_CONTACT_LEAD_SOURCE        = 'Online Donation';
  global static final String ALUMNI_REGISTRATION_CONTACT_LEAD_SOURCE    = 'Alumni Registration';
  global static final String VOLUNTEER_REGISTRATION_CONTACT_LEAD_SOURCE = 'Online Volunteer Registration';

  //Preferred Email Type : hed__Preferred_Email__c
  global static final String CONTACT_PREFERRED_EMAIL_TYPE_ALTERNATE     = 'Alternate';
  global static final String CONTACT_PREFERRED_EMAIL_TYPE_UNIVERSITY    = 'University';
  global static final String CONTACT_PREFERRED_EMAIL_TYPE_WORK          = 'Work';
  global static final String CONTACT_PREFERRED_EMAIL_TYPE_EVENT_EMAIL   = 'Event Email';

  // NOT USED ANY WHERE Contact Donor Type Constants
  // global static final string PRINCIPAL_DONOR_TYPE   = 'Principal Donor';
  // global static final string MAJOR_DONOR_TYPE       = 'Major Donor';
  // global static final string STANDARD_DONOR_TYPE    = 'Standard Donor';



  /***************************************************   Opportunity Constants   **************************************************************/

  //Opportunity RecordType Id Constants
  /*global static final Id OPPORTUNITY_RECORDTYPE_DONATION_PLEDGE        = ct_Util.getRecordTypeIdByDevName('Opportunity', 'Donation');
  global static final Id OPPORTUNITY_RECORDTYPE_LEGACY_DONATION_PLEDGE = ct_Util.getRecordTypeIdByDevName('Opportunity', 'Legacy_Donation');
  global static final Id OPPORTUNITY_RECORDTYPE_COURSE_ADMISSION       = ct_Util.getRecordTypeIdByDevName('Opportunity', 'Funding_Application');
  global static final Id OPPORTUNITY_RECORDTYPE_MAJOR_DONATION         = ct_Util.getRecordTypeIdByDevName('Opportunity', 'Major_Donation');
  global static final Id OPPORTUNITY_RECORDTYPE_IN_KIND_GIFT           = ct_Util.getRecordTypeIdByDevName('Opportunity', 'InKindGift');*/

  //Opportunity Picklist values Constants

  //Stage : StageName
  /*global static final string OPPORTUNITY_STAGE_CLOSED_STEWARDSHIP         = 'Closed / Stewardship';
  global static final string DONATION_OPPORTUNITY_STAGE_CLOSED_COMPLETE   = 'Complete';
  global static final string ACTIVE_OPPORTUNITY_STAGE                     = 'Active';
  global static final string NEW_PLEDGE_OPPORTUNITY_STAGE                 = 'New Pledge';
  global static final string PROSPECTING_OPPORTUNITY_STAGE                = 'Prospecting';
  global static final string PLEDGE_OPPORTUNITY_STAGE                     = 'Pledge';
  global static final string OPPORTUNITY_STAGE_ENQUIRER                   = 'Enquirer';
  global static final string OPPORTUNITY_STAGE_APPLIED                    = 'Applied';
  global static final string OPPORTUNITY_STAGE_DECLINED_OFFER             = 'Closed - Declined Offer';
  global static final string OPPORTUNITY_STAGE_NOT_OFFER                  = 'Closed - Not Offered';
  global static final string OPPORTUNITY_STAGE_WITHDRAWN                  = 'Closed - Withdrawn';
  global static final string OPPORTUNITY_STAGE_CLOSED_WON                 = 'Closed Won';
  global static final string OPPORTUNITY_STAGE_CLOSED_LOST                = 'Closed Lost';
  global static final string OPPORTUNITY_STAGE_NEW                        = 'New';
  global static final string OPPORTUNITY_STAGE_CLOSED_ENROLLED            = 'Closed - Enrolled';
  global static final string OPPORTUNITY_STAGE_OFFERED                    = 'Offered';
  global static final string OPPORTUNITY_STAGE_DEFERRED                   = 'Deferred';
  global static final string OPPORTUNITY_STAGE_OFFER_ACCEPTED             = 'Offer Accepted';*/

  //Closed Lost Reason  : Lost_Reason__c
  /*global static final string OPPORTUNITY_LOST_REASON_DIRECT_DEBIT_CANCELLED = 'Direct Debit Cancelled';
  global static final string OPPORTUNITY_LOST_REASON_PAUSED_DIRECT_DEBIT    = 'Paused Direct Debit';

  //Source : Source__c
  global static final string OPPORTUNITY_SOURCE_SELF_IDENTIFIED = 'Self Identified';*/

  //Donation Size   : Donation_Size__c
  global static final string SMALL_GIFT_SIZE      = 'Small Gift (Up to £999)';
  global static final string MEDIUM_GIFT_SIZE     = 'Medium Gift (£1k to £4,999)';
  global static final string LARGE_GIFT_SIZE      = 'Large Gift (£5k+)';

  //Type : Type
  global static final string OPPORTUNITY_SINGLE_DONATION_TYPE       = 'One-Off Donation';
  global static final string OPPORTUNITY_RECURRING_DONATION_TYPE    = 'Regular Donation';

  //Asperato Authorisation Status
  global static final string ASPERATO_AUTHORISATION_STATUS_CANCELLED = 'Cancelled';

  // Consent Source Values
  global static final String CONSENT_ONLINE_DONATION_VALUE  = 'Online Donation';
  global static final String CONSENT_VOLUNTEER_REGISTRATION_VALUE = 'Volunteer Registration';

  //Fundrasing Project Status
  global static final string FUNDRASING_PROJECT_IN_PROGRESS   = 'In Progress';

  //Fundrasing Project Task Status
  global static final string PROJECT_TASK_STATUS_ACTIVE   = 'Active';

  //Fundrasing Project Task Priority
  global static final string PROJECT_TASK_PRIORITY_LOW   = 'Low';

  //Asperato Payment Stage
  global static final string ASPERATO_PAYMENT_STAGE_COLLECTED = 'Collected from customer';

  //Email Template Unique Name
  global static final String THANK_DONOR_FOR_DONATION_EMAIL_TEMPLATE = 'Thank_Donor_Email_Template';
  global static final String DIRECT_DEBIT_EMAIL_TEMPLATE = 'Direct_Debit_Payment_Schedule_Notification';
  global static final String BUSINESS_LEAD_FORM_TEMPLATE = 'ct_Business_Lead_Form_Template';
  global static final String VOLUNTEER_WELCOME_EMAIL = 'Volunteer_Welcome_Email';
  global static final String CREDIT_DEBIT_CARD_PAYMENT_EMAIL = 'Credit_Debit_Card_Payment_Email';
  global static final String SEND_THANK_COMMS = 'Send_Thank_You_Comms';

  //OPPORTUNITY SEND TRANSACTIONAL EMAIL
  global static final String OPPORTUNITY_SEND_TRANSACTIONAL_EMAIL_YES = 'Yes';

  //Organization Wide Address
  global static final String UOP_BUSINESS_SUPPORT_ADDRESS = 'saravanan@creation.technology';
  global static final String UOP_ADVANCEMENT_TEAM_ADDRESS = 'saravanan@creation.technology';

  //Web Submission Source
  global static final String WEB_SUBMISSION_SOURCE_ALUMNI = 'Alumni';
  global static final String WEB_SUBMISSION_SOURCE_DONATION = 'Donation';
  global static final String WEB_SUBMISSION_SOURCE_VOLUNTEER = 'Volunteer';

  //Web Form Name
  global static final String WEB_FORMDATA_SOURCE_ALUMNI = 'Alumni Registration';
  // Direct Debit Form Name
  global static final String WEB_FORMDATA_SOURCE_DIRECT_DEBIT = 'Direct Debit';

  //Alumni Verififcation Status values
  global static final String ALUMNI_VERIFICATION_UNVERIFIED = 'Unverified';

  //Opportunity Email Acknowledgment Status
  global static final String EMAIL_ACKNOWLEDGMENT_STATUS_ACKNOWLEDGED = 'Acknowledged';

  //Advancement Setting MetaData
  global static final String HIGH_VALUE_ONLINE_DONATION_ADVANCEMENT_SETTING = 'High_Value_Online_Donation';
  global static final String WEB_DONATION_FORM_CARD_SUCCESS_MESSAGE = 'Web_Donation_Form_Card_Success_Message';
  global static final String WEB_DONATION_FORM_DD_SUCCESS_MESSAGE = 'Web_Donation_Form_DD_Success_Message';
  global static final String PAYPAL_THANK_YOU_REDIRECT_URL = 'Paypal_Thank_You_Redirect_URL';
  global static final String PAYPAL_BUTTON_VISIBILITY_CONFIG = 'Show_Paypal_Button';
  global static final String OPPORTUNITY_RECORD_TYPE_AAA_PRIVATE_EXCLUSION_SETTING = 'Opportunity_Type_AAA_Private_Exclusion';

  global static final String WEB_DONATION_PAYMENT_DETAILS = 'Web_Donation_Payment_Details';
  global static final String BOUNCE_ALERT_USER = 'Bounce_Alert_User';
  global static final String IFRAME_PAYMENT_BUTTON_VISIBILITY_CONFIG = 'Show_iFrame_Payment_Button';
  global static final String NON_IFRAME_PAYMENT_BUTTON_VISIBILITY_CONFIG = 'Show_Non_iFrame_Payment_Button';
  global static final String NON_IFRAME_PAYMENT_BUTTON_LABEL = 'Non_Iframe_Payment_Button_Label';
  global static final String NON_IFRAME_PAYMENT_PROMPT_LABEL = 'Non_Iframe_Payment_Prompt_Label';

  //Site Domain Setting MetaData
  global static final String PERSONAL_SITE_CONTACT_INFO_URL = 'PersonalSiteContactInfoURL';
  global static final String VOLUNTEER_REGISTRATION_SITE_URL = 'Volunteer_Registration_Site_URL';



  //Payment Frequency
  global static final String PAYMENT_FREQUENCY_SINGLE = 'Single';
  global static final String PAYMENT_FREQUENCY_MONTHLY = 'Monthly';

  //Payment Method Values
  global static final String DIRECT_DEBIT_PAYMENT_METHOD = 'Direct Debit';
  global static final String CASH_PAYMENT_METHOD = 'Cash';
  global static final String PAYPAL_PAYMENT_METHOD = 'Paypal';
  global static final String ASPERATO_CARD_PAYMENT_METHOD = 'Card';
  global static final String GEM_CARD_PAYMENT_METHOD = 'Credit / Debit Card';

  //Authorization Open Ended Status
  global static final String AUTHORIZATION_OPEN_ENDED_STATUS = 'Open';
  global static final String AUTHORIZATION_INFORCE_STATUS = 'In Force';
  global static final String INSTALLMENT_PERIOD = 'Monthly';

  //Recurring Donation ScheduleType Values
  global static final String SCHEDULE_TYPE_MULTIPLE_BY = 'Multiply By';

   //Recurring Donation Direct Debit Cancellation Reason
   global static final String DD_CANCELLATION_REASON_SYSTEM_CANCELLATION = 'System Cancellation';

  //Direct Debit Authorisation Status
  global static final String DIRECT_DEBIT_AUTHORISATION_STATUS_CANCELLED = 'Cancelled';
   //Direct Debit Cancellation
   global static final String DD_CANCELLATION_MANUAL_DD_CANCELLATION     = 'Manual DD Cancellation';
   global static final String DD_CANCELLATION_GOCARDLESS_DD_CANCELLATION = 'GoCardless DD Cancellation';
   //Direct Debit Open Ended Status
   global static final String DIRECT_DEBIT_OPEN_ENDED_CLOSED = 'Closed';

  //Enquiry Source
  global static final String ENQUIRY_SOURCE_WEB_FORM  = 'Web-Form';
 // Schema SobjectType
// global static final Schema.SObjectType  IS_RECURRING_DONATION   = npe03__Recurring_Donation__c.sObjectType.getDescribe().getSobjectType();

  //Recurring Donation Name Format
  global static final String RECURRING_DONATION_NAME = ' - Web Direct Debit - Open Term - ';

  //One-Off Donation Opportunity Name Format
  global static final String ONE_OFF_OPPORTUNITY_NAME = ' - Web Donation - ';

  //Volunteer Opportunity Name Format
  global static final String VOLUNTEER_OPPORTUNITY_NAME = ' - Volunteer - ';

   //Legacy Opportunity Name Format
   global static final String LEGACY_OPPORTUNITY_NAME = ' - Legacy - ';

  //Asperato Payment Stage
  global static final String PAYMENT_STAGE_NEW = 'New';

  //HED AFFILIATION Role
  global static final String AFFILIATION_ROLE_APPLICANT                 = 'Applicant';
  global static final String AFFILIATION_ROLE_STUDENT                   = 'Student';
  global static final String AFFILIATION_ROLE_PROSPECT                  = 'Prospect';
  global static final String AFFILIATION_ROLE_CAREERS_ADVISER           = 'Careers Adviser';
  global static final String AFFILIATION_ROLE_CAREER_ENRICHMENT_LEAD    = 'Careers & Enrichment Lead';
  global static final String AFFILIATION_ROLE_EPQ_COORDINATOR           = 'EPQ Coordinator';
  global static final String AFFILIATION_ROLE_HEAD_TEACHER_PRINCIPAL    = 'Head Teacher/Principal';
  global static final String AFFILIATION_ROLE_GOVERNOR                  = 'Governor';
  global static final String AFFILIATION_ROLE_HEAD_OF_SIXTH_FORM        = 'Head of sixth Form';
  global static final String AFFILIATION_ROLE_BUSINESS_MANAGER          = 'Business Manager';
  global static final String AFFILIATION_ROLE_PASTORAL_LEAD             = 'Pastoral Lead';
  global static final String AFFILIATION_ROLE_SUBJECT_TEACHER           = 'Subject teacher';

  //HED AFFILIATION Status
  global static final String AFFILIATION_STATUS_CURRENT = 'Current';
  global static final String AFFILIATION_STATUS_FORMER  = 'Former';
  global static final String AFFILIATION_STATUS_ALUMNI  = 'Alumni';

  //HED UOP Academic Affiliations
  global static final String UOP_ACADEMIC_AFFILIATIONS_CURRENT_PROSPECT  = 'Current Prospect';
  global static final String UOP_ACADEMIC_AFFILIATIONS_CURRENT_APPLICANT = 'Current Applicant';
  global static final String UOP_ACADEMIC_AFFILIATIONS_CURRENT_STUDENT   = 'Current Student';
  global static final String UOP_ACADEMIC_AFFILIATIONS_CURRENT_ALUMNI    = 'Current Alumni';
  global static final String UOP_ACADEMIC_AFFILIATIONS_REJECTED_APPLICATIONS = 'Rejected Applications';

  //Opportunity Payment Status
  global static final String OPPORTUNITY_PAYMENT_STATUS_INITIATED = 'Initiated';
  global static final String OPPORTUNITY_PAYMENT_STATUS_PAID = 'Paid';


  //Task fields values
  global static final String TASK_SUBJECT            = 'Contact Submitted from Alumni Form';
  global static final String TASK_PRIORITY_NORMAL    = 'Normal';
  global static final String TASK_STATUS_COMPLETED   = 'Completed';
  global static final String TASK_DESCRIPTION        = 'This contact is submitted from the alumni registration form';

  //Account Team Member role
  global static final String  ACCOUNT_TEAM_MEMBER_ROLE_CONTACT_MANAGER = 'Contact Manager';

  //Account Team Member Access
  global static final String  ACCOUNT_TEAM_MEMBER_READ_EDIT_ACCESS = 'Edit';

  // Volunteer Hours Status value
  global static final String VOLUNTEER_COMPLETED_STATUS = 'Completed';
  global static final String VOLUNTEER_PROSPECT_STATUS = 'Prospect';

  //Webform Records Default Users Metadata Developer Names
  global static final String ALUMNI_REGISTRATION_WEB_FORM       = 'Alumni_Registration';
  global static final String VOLUNTEER_REGISTRATION_WEB_FORM    = 'Volunteer_Registration';
  global static final String WEB_DONATION_WEB_FORM              = 'Web_Donation';
  global static final String LEGACY_DONATION_OPPORTUNITY        = 'Legacy_Donation';

  // GiftAid - Type of Declaration values
  global static final String ELECTRONIC_TYPE_DECLARATION = 'Electronic';

  //Alumni Willing To Gift To The University
  global static final String ALUMNI_WILLING_TO_GIFT = 'Leaving a gift to the University in my will';

  //Contact Alumni Verification Status
  global static final String CONTACT_ALUMNI_VERIFICATION_STATUS_UNVERIFIED = 'Unverified';

  //AFD Metadata Name
  global static final String PRODUCTION_AFD_ENDPOINT_URL = 'Production_AFD_EndPoint_URL';
  global static final String SANDBOX_AFD_ENDPOINT_URL    = 'Sandbox_AFD_EndPoint_URL';

}