public class vfFASeminarFeedbackCtrlr {
    
    
    public ID EventRecID;
    public SFDC_Special_Event__c EventRecord {get;set;}
    public List<SFDC_Attendance__c> Attendees {get;set;}
    public SFDC_Attendance__c PrimaryHost {get;set;}
    public Boolean FeedbackSubmitted {get;set;}
    public Survey_Response__c SurveyResponse {get {if (SurveyResponse == NULL) {SurveyResponse = new Survey_Response__c(); } return SurveyResponse; } set;}
    public List<Survey_Response__c> ExistingSurveyResponse {get;set;}
    public Map<ID, Prospect__c> Prospects;
    public Map<ID, Prospect_Referral__c> ProspectReferrals;
    public Boolean SurveyDisabled {get;set;}
    public Boolean PCGFA {get;set;}
    
    public vfFASeminarFeedbackCtrlr(ApexPages.StandardController controller) {
    
        EventRecID = Controller.getRecord().ID;
    
        EventRecord = [SELECT Start_date__c, End_Date__c, Event_ID_Number__c, Survey_Sent_Date__c, Event_Survey_ID__c FROM SFDC_Special_Event__c WHERE ID =: EventRecID];
        
        getAttendees();
        
        getPrimaryHost();

        if (PrimaryHost.Attendee__r.Channel__c == 'PCG' || PrimaryHost.Attendee__r.Channel__c == 'Latin America') { //only display prospect follow up mailings data for PCG FAs
            PCGFA = true;
        } else {
            PCGFA = false;
        }
        
        getExistingSurveyResponse();
        
        if (ExistingSurveyResponse.size() == 0) {
            CreateSurveyResponse();
        }
        
        getProspects();
        
        getProspectReferrals();
        
        //surveys are sent on Friday Morning, and they are disabled after 12 PM NOON the following Friday
        if (EventRecord.Survey_Sent_Date__c != null && ((system.today() == date.valueof(EventRecord.Survey_Sent_Date__c).adddays(8) 
            && system.now().hour() > 12) || system.today() > date.valueof(EventRecord.Survey_Sent_Date__c).adddays(8))) {
            SurveyDisabled = true;
        } else {
            SurveyDisabled = false;
        }
        
        if (PrimaryHost.Feedback_Received__c != Null) {
            FeedbackSubmitted = true;
        } else {
            FeedbackSubmitted = false;
        }
    }

    
    public void getPrimaryHost() {
    
        PrimaryHost = [SELECT Attendee__r.FirstName, Attendee__r.LastName, Attendee__r.Channel__c, Attendee__c, Feedback_Received__c FROM SFDC_Attendance__c WHERE Special_Event__c =: EventRecID AND Type_Of_Attendee__c = 'Primary Host'];
        
    }
    
    public void getAttendees() {
    
        Attendees = [SELECT Prospect__c, Prospect__r.First_Name__c, Prospect__r.Last_Name__c, Prospect_s_Email__c, Prospect_s_Phone_Number__c,
        Prospect_Appointment_Date__c, Status__c, Prospect_Follow_Up_Mailing__c, Set_Up_Appointment__c, Attended_Event__c, Party_Size__c FROM SFDC_Attendance__c WHERE 
        RecordTypeID = '01250000000UIbu' AND Special_Event__c =: EventRecID 
        AND Type_Of_Attendee__c = 'Primary Guest' ORDER BY Prospect__r.Last_Name__c ASC NULLS LAST];
        
    }
    
    public void getProspects() {
    
        List<ID> ProspectIDs = new List<ID>();
        
        For (SFDC_Attendance__c a: Attendees) {
            ProspectIDs.add(a.Prospect__c);
        }
        
        Prospects = new Map<ID, Prospect__c>([SELECT Email__c, First_Name__c, Last_Name__c, Phone_Number__c FROM Prospect__c WHERE ID 
        IN: ProspectIDs]);
        
    }
    
    public void getProspectReferrals() {

        Map<ID, Prospect_Referral__c> ProspectRefsMap = new Map<ID, Prospect_Referral__c>();
        
        for (Prospect_Referral__c pr : [SELECT Prospect__c, FA_Name__c, Prospect_Follow_Up_Mailing__c, Set_Up_Appointment__c, 
        Appointment_Date__c FROM Prospect_Referral__c WHERE Prospect__c IN: Prospects.keyset() AND FA_Name__c =: PrimaryHost.Attendee__c]) {
        
            ProspectRefsMap.put(pr.Prospect__c, pr);
            
        }
        
        ProspectReferrals = ProspectRefsMap;
        
        system.debug('Prospect Referral Records ------------ ' + ProspectReferrals);
        
    }
    
    public void getExistingSurveyResponse() {
        
        system.debug('FA Surveyed --------- ' + PrimaryHost.Attendee__c);
        system.debug('Survey Program Id ---------- ' + EventRecord.Event_Survey_ID__c);
        system.debug('Special Event --------- ' + EventRecID);
        
        ExistingSurveyResponse = [SELECT ID, Customer_Service_Provided_By_RME__c, Did_Seminar_Help_With_Client_Acqusition__c, Do_you_have_any_other_comments__c,
        FA_Surveyed__c, Overall_Seminar_Express_Experience__c,  Participate_in_Seminar_Express_Again__c, Printed_Materials__c, Quality_of_Prospects_Attendees__c,
        RSVP_Service__c, Seminar_Cost__c, Special_Event__c, Support_from_WFA_Marketing_Team__c, Survey_Program__c FROM Survey_Response__c WHERE 
        FA_Surveyed__c =: PrimaryHost.Attendee__c AND Survey_Program__c =: EventRecord.Event_Survey_ID__c AND Special_Event__c =: EventRecID];
        
        system.debug('Existing Survey Response ------------- ' + ExistingSurveyResponse);
        
        
    }
    
    public void CreateSurveyResponse() {
    
        SurveyResponse.Survey_Program__c = EventRecord.Event_Survey_ID__c;
        SurveyResponse.FA_Surveyed__c = PrimaryHost.Attendee__c;
        SurveyResponse.Special_Event__c = EventRecID;
        SurveyResponse.RecordTypeID = '01250000000UMCI';
        
    }
    
    
    public PageReference SubmitFeedback() {

        ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error occurred while saving your updates. ' +
        'An email has been sent to your Salesforce Administrators, and you will be notified of a solution shortly. ' +
        'If you have any questions please email SeminarExpress@wfadvisors.com');
        
        try {

            PrimaryHost.Feedback_Received__c = system.now();

            update PrimaryHost;
            
        } catch (exception e) {
            if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                ApexPages.addmessage(ErrorMsg);
                
                SendErrorEmail(e.getMessage());
                
                system.debug('Error updating seminar Primary Host ------------- ' + e.getMessage());
            }
            return null;
        }
        
        try {
            for (SFDC_Attendance__c a: Attendees) {
                if (a.Attended_Event__c) {
                    a.Status__c = 'Attended';
                }
                //a.Feedback_Received__c = system.now();
            }
            update Attendees;
            
        } catch (exception e) {
            if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                ApexPages.addmessage(ErrorMsg);
                
                SendErrorEmail(e.getMessage());
                
                system.debug('Error updating seminar attendances ------------- ' + e.getMessage());
            }
            return null;
        }
        
        
       try {
           
           system.debug('Prospect  Referrals ------------ ' + ProspectReferrals);
           
            for (SFDC_Attendance__c a: Attendees) {
                ProspectReferrals.get(a.Prospect__c).Set_Up_Appointment__c = a.Set_Up_Appointment__c;
                ProspectReferrals.get(a.Prospect__c).Appointment_Date__c = a.Prospect_Appointment_Date__c;
                ProspectReferrals.get(a.Prospect__c).Prospect_Follow_Up_Mailing__c = a.Prospect_Follow_Up_Mailing__c;                
            }
            
            update ProspectReferrals.values();

        } catch (exception e) {
        
            if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                ApexPages.addmessage(ErrorMsg);
                
                SendErrorEmail(e.getMessage());
                
                system.debug('Error updating prospect appointments information ------------- ' + e.getMessage());
            }
            return null;
        
        }
                
        try {
            for (SFDC_Attendance__c a: Attendees) {
                Prospects.get(a.Prospect__c).First_Name__c = a.Prospect__r.First_Name__c;
                Prospects.get(a.Prospect__c).Last_Name__c = a.Prospect__r.Last_Name__c;                
                Prospects.get(a.Prospect__c).Email__c = a.Prospect_s_Email__c;
                Prospects.get(a.Prospect__c).Phone_Number__c = a.Prospect_s_Phone_Number__c;
            }
            
            update Prospects.values();

        } catch (exception e) {
        
            if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                ApexPages.addmessage(ErrorMsg);
                
                SendErrorEmail(e.getMessage());
                
                system.debug('Error updating seminar prospect contact information ------------- ' + e.getMessage());
            }
            return null;
        
        }
        
        if (ExistingSurveyResponse.size() == 0) {
        
            try {
                system.debug('Seminar survey response to insert --------- ' + SurveyResponse);
                
                insert SurveyResponse;
                
            } catch (exception e) {

                if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                    ApexPages.addmessage(ErrorMsg);
                    
                    SendErrorEmail(e.getMessage());
                    
                    system.debug('Error inserting seminar survey response ------------- ' + e.getMessage());
                }
                return null;                
            }
            
        } else {
        
            try {
                system.debug('Seminar survey response to update --------- ' + ExistingSurveyResponse);
                
                update ExistingSurveyResponse;
            } catch (exception e) {
            
                if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                    ApexPages.addmessage(ErrorMsg);
                    
                    SendErrorEmail(e.getMessage());
             
                    system.debug('Error updating seminar survey response ------------- ' + e.getMessage());
                }
                return null; 
            }
            
        }
        
        FeedbackSubmitted = True;
        
        PageReference SeminarExpressPage;

        system.debug('Primary Host FA\'s channel ---------- ' + PrimaryHost.Attendee__r.Channel__c);
        
        if (PrimaryHost.Attendee__r.Channel__c == 'FiNet') {
             SeminarExpressPage = new PageReference('/apex/vfSubmissionConfirmation?id=FiNetFASeminarFeedback');

        } else {
             SeminarExpressPage = new PageReference('/apex/vfSubmissionConfirmation?id=PCGFASeminarFeedback');
        }
        
        SeminarExpressPage.setRedirect(true);
        
        return SeminarExpressPage;

    }
         
    public void SendErrorEmail(String ErrorMsg) {
       
        UtilityMethods.email('Error Occurred On FA Seminar Feedback Submission', 'The following error occurred when ' + 
        PrimaryHost.Attendee__r.FirstName + ' ' + PrimaryHost.Attendee__r.LastName + ' tried saving feedback for Seminar ' + EventRecID + ': \n \n' + ErrorMsg, null);

       
    }    
}