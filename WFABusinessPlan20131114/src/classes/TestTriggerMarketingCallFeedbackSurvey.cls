@isTest
private class TestTriggerMarketingCallFeedbackSurvey {

static testMethod void TriggerMarketingCallFeedbackSurvey() {

Account branch = new Account(name = 'Test Branch');

insert branch;

Contact FA = new Contact(FirstName = 'Test', LastName = 'FA', AccountID = branch.id);

insert FA;

Marketing__c Mkting = new Marketing__c(name = 'Test FA Marketing', Contact__c = FA.ID, Email_FA_For_FA_Call__c = False,
Email_FA_For_CA_Call__c = False);

insert Mkting;

//stage user: marketing sales rep user
User userMkt = new User();
userMkt.Username = 'Test_user_marketing@test.com';
userMkt.LastName = 'Test_marketing_name';
userMkt.ProfileId = '00e30000000uREk';
userMkt.Alias = 'tstmkt';
userMkt.Email = 'Test_marketing@email.com';
userMkt.CommunityNickname = 'Test_marketing_nickname';
userMkt.TimeZoneSidKey = 'GMT';
userMkt.LocaleSidKey = 'en_US';
userMkt.LanguageLocaleKey = 'en_US';
userMkt.EmailEncodingKey = 'ISO-8859-1';
userMkt.MobilePhone = '+1 999-999-9999';
userMkt.AU__c = '0012345';
userMkt.EmployeeNumber = '1234567';
insert userMkt;

test.StartTest();

task t = new Task();
t.RecordTypeID = '01250000000UBOX';
t.WhoId = FA.id;
t.Subject = 'Branding';
t.Category__c = 'Branding-Custom Logo';
t.Communication_Type__c = 'Reactive';
t.Type = 'Contact-800 Line';
t.Status = 'Complete';
t.OwnerId = userMkt.id;

insert t;

Marketing__c[] FAsReceivingSurvey = [SELECT Email_FA_For_FA_Call__c, Contact__c FROM Marketing__c WHERE Email_FA_For_FA_Call__c = TRUE];

//system.assertequals(FAsReceivingSurvey.size(),1);
//system.assertequals(FAsReceivingSurvey[0].Contact__c,FA.id);

task t2 = new Task();
t2.RecordTypeID = '01250000000UBOX';
t2.WhoId = FA.id;
t2.Subject = 'Branding';
t2.Category__c = 'Branding-Brand Review';
t2.Communication_Type__c = 'Reactive';
t2.Type = 'Contact-800 Line';
t2.Status = 'Incomplete';

insert t2;

t2.Status = 'Complete';
t2.Client_Associate__c = True;

update t2;

FAsReceivingSurvey = [SELECT Email_FA_For_FA_Call__c, Contact__c, Marketing_Consultant_on_800_Line__c FROM Marketing__c WHERE Email_FA_For_FA_Call__c = TRUE];

//system.assertequals(FAsReceivingSurvey.size(),0);

FAsReceivingSurvey = [SELECT Email_FA_For_CA_Call__c, Contact__c, Marketing_Consultant_on_800_Line__c FROM Marketing__c WHERE Email_FA_For_CA_Call__c = TRUE];

//system.assertequals(FAsReceivingSurvey.size(),1);
//system.assertequals(FAsReceivingSurvey[0].Contact__c,FA.id);
//system.assertequals(FAsReceivingSurvey[0].Marketing_Consultant_on_800_Line__c,userMkt.id);

test.StopTest();

}

}