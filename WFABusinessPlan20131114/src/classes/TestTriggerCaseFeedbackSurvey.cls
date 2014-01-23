@isTest
private class TestTriggerCaseFeedbackSurvey {

static testMethod void TriggerPARTCaseFeedbackSurvey() {

//-------------secondary contact and part case that should get survey----------//
Secondary_Contact__c SC = new Secondary_Contact__c();
SC.Name = 'Test SC';
SC.Contact_Email__c = 'test.sc@wfadvisors.com';
SC.Date_of_Last_PART_Case_Feedback_Response__c = null;
SC.Stop_PART_Case_Feedback_Survey__c = false;

insert SC;

Case PARTCase = new Case();
PARTCase.recordtypeid = '012500000005J36';
PARTCase.Branch_Contact_For_Case__c = 'Test referrer';
PARTCase.Branch_Contact_Email__c = 'test.sc@wfadvisors.com';
PARTCase.Subject__c = 'Administrative Support';
PARTCase.Category__c = 'Advanced Education';
PARTCase.origin = 'Call';
PARTCase.Inquiry_Type__c = 'Inquiry';
PARTCase.Referral_Source__c = 'FA';
PARTCase.Subject = 'Test Subject';
PARTCase.Initial_Steps_taken__c = 'Access Online';
PARTCase.Follow_Up_Date__c = system.today().addDays(10);
PARTCase.Send_PART_Case_Feedback_Survey__c = False;

insert PARTCase;

//-------------secondary contact and part case that should NOT get survey because contact opts out ----------//
Secondary_Contact__c SC2 = new Secondary_Contact__c();
SC2.Name = 'Test SC';
SC2.Contact_Email__c = 'test2.sc@wfadvisors.com';
SC2.Date_of_Last_PART_Case_Feedback_Response__c = system.now();
SC2.Stop_PART_Case_Feedback_Survey__c = true;

insert SC2;

Case PARTCase2 = new Case();
PARTCase2.recordtypeid = '012500000005J36';
PARTCase2.Branch_Contact_For_Case__c = 'Test referrer';
PARTCase2.Branch_Contact_Email__c = 'test2.sc@wfadvisors.com';
PARTCase2.Subject__c = 'Administrative Support';
PARTCase2.Category__c = 'Advanced Education';
PARTCase2.origin = 'Call';
PARTCase2.Inquiry_Type__c = 'Inquiry';
PARTCase2.Referral_Source__c = 'FA';
PARTCase2.Subject = 'Test Subject';
PARTCase2.Initial_Steps_taken__c = 'Access Online';
PARTCase2.Follow_Up_Date__c = system.today().addDays(10);
PARTCase2.Send_PART_Case_Feedback_Survey__c = False;

insert PARTCase2;

//-------------secondary contact and part case that should NOT get survey because last response < 60 days ago----------//

Secondary_Contact__c SC3 = new Secondary_Contact__c();
SC3.Name = 'Test SC';
SC3.Contact_Email__c = 'test3.sc@wfadvisors.com';
SC3.Date_of_Last_PART_Case_Feedback_Response__c = system.now().addDays(-20);
SC3.Stop_PART_Case_Feedback_Survey__c = false;

insert SC3;

Case PARTCase3 = new Case();
PARTCase3.recordtypeid = '012500000005J36';
PARTCase3.Branch_Contact_For_Case__c = 'Test referrer';
PARTCase3.Branch_Contact_Email__c = 'test3.sc@wfadvisors.com';
PARTCase3.Subject__c = 'Administrative Support';
PARTCase3.Category__c = 'Advanced Education';
PARTCase3.origin = 'Call';
PARTCase3.Inquiry_Type__c = 'Inquiry';
PARTCase3.Referral_Source__c = 'FA';
PARTCase3.Subject = 'Test Subject';
PARTCase3.Initial_Steps_taken__c = 'Access Online';
PARTCase3.Follow_Up_Date__c = system.today().addDays(10);
PARTCase3.Send_PART_Case_Feedback_Survey__c = False;

insert PARTCase3;

test.startTest();

PARTCase.Status = 'Closed';
PARTCase.Reason = 'Backoffice Error';
PARTCase.Detailed_Resolution__c = 'Test resolution';

update PARTCase;

PARTCase2.Status = 'Closed';
PARTCase2.Reason = 'Backoffice Error';
PARTCase2.Detailed_Resolution__c = 'Test resolution';

update PARTCase2;

PARTCase3.Status = 'Closed';
PARTCase3.Reason = 'Backoffice Error';
PARTCase3.Detailed_Resolution__c = 'Test resolution';

update PARTCase3;

test.stopTest();

Case[] PARTCaseToSurvey = [SELECT Send_Part_Case_Feedback_Survey__c FROM Case WHERE Send_Part_Case_Feedback_Survey__c = True];

system.assertequals(PARTCaseToSurvey.size(),1);

Case[] PARTCaseToNotSurvey = [SELECT Send_Part_Case_Feedback_Survey__c FROM Case WHERE Send_Part_Case_Feedback_Survey__c = false AND
                        (Branch_Contact_Email__c = 'test2.sc@wfadvisors.com' OR Branch_Contact_Email__c = 'test3.sc@wfadvisors.com')]; 

system.assertequals(PARTCaseToNotSurvey.size(),2);

}

}