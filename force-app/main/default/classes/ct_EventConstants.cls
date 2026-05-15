/**
* @description       : Class which stores the global constants which are used for Events 
* @author            : Creation Admin
* @last modified on  : 02-04-2021
* @last modified by  : Creation Admin
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   09-25-2020   Creation Admin   Initial Version
**/
global without sharing class ct_EventConstants {
    //Event Question Set
    global static final String EVENT_QUESTION_SET_STATUS_ACTIVE = 'Active';
    
    //EVENT QUESTION 
    global static final String QUESTION_DATA_TYPE_TEXT                    = 'Text';
    global static final String QUESTION_DATA_TYPE_CURRENCY                = 'Currency';
    global static final String QUESTION_DATA_TYPE_LONG_TEXT               = 'Long Text Area';
    global static final String QUESTION_DATA_TYPE_PICKLIST                = 'Picklist';
    global static final String QUESTION_DATA_TYPE_RICH_TEXT               = 'Rich Text Area';
    global static final String QUESTION_DATA_TYPE_TEXT_AREA               = 'Text Area';
    global static final String QUESTION_DATA_TYPE_TEXT_DEPENDENT_PICKLIST = 'Dependent Picklist';
    
    global static final String QUESTION_OBJECT_TYPE_CAMPAIGN_MEMBER    = 'CampaignMember';
    global static final String QUESTION_OBJECT_TYPE_EVENT_REGISTRATION = 'Event_Registration__c';
    global static final String WEB_SUBMISSION_SOURCE_EVENT             = 'Event';
    
    //Event
    global static final String EVENT_PUBLISHING_WEBSITE_AND_REGISTRATION_PAGE = 'Event Website & Registration Page';
    global static final String EVENT_PUBLISHING_REGISTRATION_PAGE             = 'Event Registration Page Only';
    global static final String NO_EVENT_PUBLISH                               = 'No Event Registration Page';
    
    // Event Post_Web_Order_Action__c
    global static final String EVENT_POST_WEB_ORDER_ACTION_CONFIRMATION_SCREEN = 'Order Confirmation Screen';
    
    // Event Business_Area__c
    global static final String EVENT_BUSINESS_AREA_STUDENT_RECRUITMENT = 'Marketing (Student Recruitment)';
    
    //Event Event_Type__c
    global static final String EVENT_TYPE_OPEN_DAY = 'Open Day';
    //Event CM_ER_Auto_Sync__c  
    global static final String EVENT_CM_ER_AUTO_SYNC_YES = 'Yes';
    global static final String EVENT_CM_ER_AUTO_SYNC_NO = 'NO';
    
    
    //Event Post_Event_Approval_Status__c
    global static final String EVENT_POST_EVENT_APPROVAL_STATUS = 'Approval Required';
    
    
    //Event Event_Status__c
    global static final String EVENT_STATUS_PLANNING = 'Planning';
    global static final String EVENT_STATUS_POST_EVENT = 'Post Event';
    global static final String EVENT_STATUS_NEW = 'New';
    global static final String EVENT_STATUS_CHECK_IN_MANAGEMENT = 'Check In / Management';
    
    //Event Product 
    
    //Event Product  Event_Product_Type__c
    global static final String EVENT_PRODUCT_TYPE_EVENT_TICKET = 'Event Ticket';
    
    
    
    //Event Order
    global static final String ORDER_SOURCE_INTERNAL_ORDER = 'Internal Order';
    global static final String ORDER_SOURCE_WEB_ORDER      = 'Web Order';
    global static final String ORDER_STATUS_ACTIVE         = 'Active';
    global static final String CREATE_NEW_LEADS             = 'Create New Leads';
    global static final String CREATE_NEW_CONTACTS          = 'Create New Contacts';
    global static final String CREATE_NEW_PERSON_ACCOUNTS   = 'Create New Person Accounts';
    
    
    //Event Registration

    global static final String SIMPLE_EVENT_RECORD_TYPE_DEVELOPER_NAME = 'Simple_Events';
    global static final Id SIMPLE_EVENT_RECORD_TYPE_ID           = ct_Util.getRecordTypeIdByDevName('Event__c', SIMPLE_EVENT_RECORD_TYPE_DEVELOPER_NAME);

    global static final String COMPLEX_EVENT_RECORD_TYPE_DEVELOPER_NAME = 'Complex_Events';
    global static final Id COMPLEX_EVENT_RECORD_TYPE_ID           = ct_Util.getRecordTypeIdByDevName('Event__c', COMPLEX_EVENT_RECORD_TYPE_DEVELOPER_NAME);

    global static final String MASTER_EVENT_REGISTRATION_RECORD_TYPE_DEVELOPER_NAME = 'Master_Event_Registration';
    global static final Id EVENT_REGISTRATION_MASTER_EVENT_RECORD_TYPE_ID           = ct_Util.getRecordTypeIdByDevName('Event_Registration__c', MASTER_EVENT_REGISTRATION_RECORD_TYPE_DEVELOPER_NAME);
    global static final String EVENT_REGISTRATION_CHECKED_IN                        = 'Attended / Checked In';
    global static final String EVENT_REGISTRATION_CHECKED_OUT                       = 'Attended / Checked Out';
    global static final String EVENT_REGISTRATION_REGISTERED                        = 'Registered';
    global static final String EVENT_REGISTRATION_ATTENDING                         = 'Attending';
    global static final String EVENT_REGISTRATION_CANCELLED                         = 'Cancelled';
    global static final String EVENT_REGISTRATION_NEW                               = 'New';
    global static final String EVENT_REGISTRATION_INVITED                           = 'Invited';
    global static final String EVENT_REGISTRATION_DECLINED                          = 'Declined';
    global static final String EVENT_REGISTRATION_DID_NOT_ATTEND                    = 'Did Not Attend';
    
    global static final String EVENT_REGISTRATION_SOURCE_INTERNAL_ORDER  = 'Internal Order';
    global static final String EVENT_REGISTRATION_SOURCE_WEB_ORDER       = 'Web Order';
    global static final String EVENT_REGISTRATION_SOURCE_MANUAL_CREATION = 'Manual Creation';
    global static final String EVENT_REGISTRATION_TYPE_GUEST             = 'Guest';
    global static final String EVENT_REGISTRATION_TYPE_NAMED_ATTENDEE    = 'Named Attendee';
    global static final String EVENT_REGISTRATION_TYPE_MY_SELF           = 'Myself';
    global static final String EVENT_REGISTRATION_TYPE_SOMEONE_ELSE      = 'Someone Else';
    global static final String EVENT_REGISTRATION_TYPE_UNKNOWN_GUEST     = 'Unknown Guest';
    
    //Event Order
    global static final String EVENT_ORDER_CANCELLED     = 'Cancelled';
    global static final String EVENT_ORDER_ACTIVE        = 'Active';
    global static final String EVENT_ORDER_WAITING_LIST  = 'Waiting List';
        
    //Event Order Cancellation_Reason__c
    global static final String EVENT_CANCEL_REASON_DATE_CONFLICT  = 'Date Conflict';
        
    //Session Registration
    global static final String SESSION_REGISTRATION_CANCELLED      = 'Cancelled';
    global static final String SESSION_REGISTRATION_REGISTERED     = 'Registered';
    global static final String SESSION_REGISTRATION_DID_NOT_ATTEND = 'Did Not Attend';
    global static final String SESSION_REGISTRATION_CHECKED_IN     = 'Attended / Checked In';
    global static final String SESSION_REGISTRATION_CHECKED_OUT    = 'Attended / Checked Out';
    
    //Event Check In Manager Constants
    global static final String EVENT_CHECK_IN_STATUS_REGISTERED     = 'REGISTERED';
    global static final String EVENT_CHECK_IN_STATUS_CHECKED_IN     = 'CHECKED_IN';
    global static final String EVENT_CHECK_IN_STATUS_CHECKED_OUT    = 'CHECKED_OUT';
    global static final String EVENT_CHECK_IN_STATUS_DID_NOT_ATTEND = 'DID_NOT_ATTEND';
    
    //Custom Label
    global static final String CHECK_IN_MANAGER_URL = System.Label.Check_In_Manager_URL;
    global static final String SITE_BASE_URL = System.Label.Site_Base_URL;
    
    //Base URL
    global static final String BASE_URL = URL.getOrgDomainUrl().toExternalForm();

    //Discount Code
    global static final String DISCOUNT_TYPE_PERCENTAGE = 'Discount Code %';
    global static final String DISCOUNT_TYPE_AMOUNT = 'Discount Code Amount';
    
    //CampaignMember Status
    global static final String CAMPAIGN_MEMBER_STATUS_CHECKED_IN     = 'Attended / Checked In';
    global static final String CAMPAIGN_MEMBER_STATUS_CHECKED_OUT    = 'Attended / Checked Out';
    global static final String CAMPAIGN_MEMBER_STATUS_REGISTERED     = 'Registered';
    global static final String CAMPAIGN_MEMBER_STATUS_ATTENDING      = 'Attending';
    global static final String CAMPAIGN_MEMBER_STATUS_CANCELLED      = 'Cancelled';
    global static final String CAMPAIGN_MEMBER_STATUS_NEW            = 'New';
    global static final String CAMPAIGN_MEMBER_STATUS_INVITED        = 'Invited';
    global static final String CAMPAIGN_MEMBER_STATUS_DECLINED       = 'Declined';
    global static final String CAMPAIGN_MEMBER_STATUS_DID_NOT_ATTEND = 'Did Not Attend';
    
    //Event Setting Metadata
    global static final String EVENT_SUCCESS_MESSAGE_EVENT_SETTING = 'Event_Success_Message';
    
    //Event Ticket registration Contact And Enquire Consent functionality
    
    global static final String CONSENT_VALUE_YES = 'Yes';
    global static final String CONSENT_VALUE_NO = 'No';
    
    
    global static final String CONSENT_GIVEN_YES = 'Yes';
    global static final String CONSENT_GIVEN_NO = 'No';
    
    
    global static final String STUDENT_RECRUITMENT_AND_RAO_CONSENT_STATEMENT = 'Student Recruitment & RAO';
    global static final String R_AND_I_B2B_CONSENT_STATEMENT                 = 'R&I / B2B';
    global static final String ALUMNI_AND_ADVANCEMENT_CONSENT_STATEMENT      = 'Alumni & Advancement';
    
    global static final String LATEST_CONSENT_CHANGE_SOURCE_EVENT      = 'Event';
    
    //Event Manager Refund Alert EmAIL Template
    global static final string EVENT_MANAGER_REFUND_TEMPLATE = 'Event_Manager_Refund_Template';
    
    //Event Manager Refund Metadata Record
    global static final string EVENT_MANAGER_REFUND_RECORD_DEVELOPER_NAME = 'Disable_Event_Manager_Refund';
    
    //Event Order Status
    global static final string EVENT_ORDER_STATUS_CANCELLED = 'Cancelled';
    
    //Event Org Wide Address
    global static final string EVENT_FROM_ADDRESS_NAME = 'Open Days';
    
    //B2B Public Group Constant
    global static final String B2B_PUBLIC_GROUP_NAME = 'UoP B2B Users';
}