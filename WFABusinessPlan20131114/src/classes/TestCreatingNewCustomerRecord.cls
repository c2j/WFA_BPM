@isTest
private class TestCreatingNewCustomerRecord {

Static testMethod void TestCreateCustomerRecord() {

//Region__c[] Home = [SELECT ID FROM Region__c WHERE Id = 'a1550000000JZpF'];

Channel__c PCG = new Channel__c(Name = 'PCG');
Channel__c WBS = new Channel__c(Name = 'WBS');    
Channel__c FiNet = new Channel__c(Name = 'FiNet');    

insert PCG;
insert WBS;
insert FiNet;

Employing_Firm__c ef = new Employing_Firm__c(Name = 'Employer');
insert ef;

Region__c region = new Region__c(name='Region');
insert region;

Account ap = new account(name = 'PCG Branch', Region_Branch__c = region.Id, Channel_Branch__c = PCG.id);
Account aw = new account(name = 'WBS Branch', Channel_Branch__c = WBS.id);
Account af = new account(name = 'FiNet Branch',  Channel_Branch__c = FiNet.id);
insert ap;
insert aw;
insert af;

Contact[] Contacts = new Contact[] {
    new Contact(LastName = 'Manager', FirstName = 'Branch', Type__c = 'Branch Manager', AccountID = ap.id, 
    email = 'Test.BranchManager@wellsfargoadvisors.com.april12', IBDC__c = 'Adrian Vega',
    Regional_Sales_Manager__c = 'Chris Barsi', National_Sales_Territory__c = 'Missouri', Productivity_Consultant__c = 'Ally Shuman'),
    new Contact(LastName = 'FA', FirstName = 'Test', Type__c = 'FA', AccountID = ap.id, A_Number__c = 'A111111'),
    new Contact(LastName = 'FAIT', FirstName = 'Test', Type__c = 'FA in Training', AccountID = ap.id, A_Number__c = 'A456789')
    }; 
insert Contacts;

Main_Branch__c mb = new Main_Branch__c(Name = 'Main Branch', Manager_Main_Branch__c = contacts[0].id);
insert mb;


FA_Talent__c[] FTals = new FA_Talent__c[] {
    new FA_Talent__c(Name = 'Test FA 1', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 1', A_Number__c = 'A123456',
    CRD_Number__c = '654321'),
    
    new FA_Talent__c(Name = 'Test FA 2', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 2', A_Number__c = 'A234567',
    CRD_Number__c = '765432'),
    
    new FA_Talent__c(Name = 'Test FA 3', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 3', A_Number__c = 'A345678',
    CRD_Number__c = '876543'),
    
    new FA_Talent__c(Name = 'Test FA 4', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 4', A_Number__c = 'A456789',
    CRD_Number__c = '987654'),
    
    new FA_Talent__c(Name = 'Test FA 5', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 5', A_Number__c = 'A567890',
    CRD_Number__c = '098765')
    };

insert FTals;

Opportunity[] Efforts = new Opportunity[] {
    new Opportunity(RecordTypeID = '01250000000UISO', Name = 'Test FA 1 Q212 654321', FA_Talent_Name__c = FTals[0].id, 
    StageName = 'Introduced CO', CloseDate = date.newinstance(system.today().year(),12,31), AccountId = ap.id, ChannelText__c = 'PCG', FA_Talent_Hired__c = NULL),
    
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 2 Q212 765432', FA_Talent_Name__c = FTals[1].id, 
    StageName = 'Introduced CO', CloseDate = date.newinstance(system.today().year(),12,31), AccountId = aw.id, ChannelText__c = 'WBS', FA_Talent_Hired__c = NULL),
    
    new Opportunity(RecordTypeID = '01250000000UISQ', Name = 'Test FA 2 Q212 876543', FA_Talent_Name__c = FTals[2].id, 
    StageName = 'BDC-1', CloseDate = date.newinstance(system.today().year(),12,31), AccountId = af.id, ChannelText__c = 'FiNet', FA_Talent_Hired__c = NULL),
    
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 4 Q212 987654', FA_Talent_Name__c = FTals[3].id, 
    StageName = 'Introduced CO', CloseDate = date.newinstance(system.today().year(),12,31), AccountId = ap.id, ChannelText__c = 'PCG', FA_Talent_Hired__c = NULL, Special_Hire_Type__c = null),
    
    new Opportunity(RecordTypeID = '01250000000UISO', Name = 'Test FA 5 Q212 098765', FA_Talent_Name__c = FTals[4].id, 
    StageName = 'Introduced CO', CloseDate = date.newinstance(system.today().year(),12,31), AccountId = aw.id, ChannelText__c = 'WBS', FA_Talent_Hired__c = NULL)
    
    }; 

insert Efforts;   


ap.Manager_Branch__c = Contacts[0].id;
ap.Main_Branch__c = mb.id;
update ap;


Test.startTest();

system.debug('hire pcg effort\'s region id --------- ' + string.valueof(Efforts[0].Account.Region_Branch__c));
Contact[] c1 = new Contact[] {
new Contact(LastName = 'Test', Phone = '(314) 123-1234', Type__c = 'FA', 
Hire_Date__c = Date.newinstance(2012, 3,25), IBDC__c = 'Adrian Vega')};
insert c1;

Efforts[0].StageName = 'Hired';
Efforts[0].CloseDate = system.today();
Efforts[1].StageName = 'Hired';
Efforts[1].CloseDate = system.today();
Efforts[2].StageName = 'RPL-4';
Efforts[2].CloseDate = system.today();
Efforts[3].StageName = 'Hired';
Efforts[3].CloseDate = system.today();
update Efforts;

FTals[0].FAI_Status__c = 'Hired';
FTals[1].FAI_Status__c = 'Hired';
FTals[2].FAI_Status__c = 'Hired';
FTals[3].FAI_Status__c = 'Hired';
update FTals;



Test.StopTest();

Contact[] newFAs = [SELECT A_Number__c FROM Contact WHERE A_Number__c = 'A123456'];

system.assertequals(newFAs.size(),1);

newFAs = [SELECT A_Number__c FROM Contact WHERE A_Number__c = 'A456789'];

system.assertequals(newFAs.size(),1);

newFAs = [SELECT A_Number__c FROM Contact WHERE A_Number__c = 'A345678'];
system.assertequals(newFAs.size(),1);

//Contact[] existingFAs = [SELECT A_Number__c FROM Contact WHERE Date_Effort_Marked_Hired__c =: system.today() AND
//Previous_Firm__c = 'Employer'];
//system.assertequals(existingFAs.size(),4);
    
}

}