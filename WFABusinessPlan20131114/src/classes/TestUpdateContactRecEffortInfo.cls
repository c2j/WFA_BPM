@isTest
private class TestUpdateContactRecEffortInfo {

Static testMethod void TestUpdateContactRec() {

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
Account aw = new account(name = 'WBS Branch', Region_Branch__c = region.Id, Channel_Branch__c = WBS.id);
Account af = new account(name = 'FiNet Branch', Region_Branch__c = region.Id, Channel_Branch__c = FiNet.id);
insert ap;
insert aw;
insert af;


FA_Talent__c[] FTals = new FA_Talent__c[] {
    new FA_Talent__c(Name = 'Test FA 1', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 1', A_Number__c = 'A123456',
    CRD_Number__c = '654321'),
    new FA_Talent__c(Name = 'Test FA 2', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 2', A_Number__c = 'A234567',
    CRD_Number__c = '765432'),
    new FA_Talent__c(Name = 'Test FA 3', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 3', A_Number__c = 'A345678',
    CRD_Number__c = '876543')
    };

insert FTals;

Opportunity[] Efforts = new Opportunity[] {
    new Opportunity(RecordTypeID = '01250000000UISO', Name = 'Test FA 1 Q212 654321', FA_Talent_Name__c = FTals[0].id, 
    StageName = 'Hired', Amount=150, AUM__c = 10000, 
    CloseDate = date.newinstance(2012,12,31), AccountId = ap.id, ChannelText__c = 'PCG' ),
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 2 Q212 765432', FA_Talent_Name__c = FTals[1].id, 
    StageName = 'Introduced CO', CloseDate = date.newinstance(2012,12,31), AccountId = aw.id, ChannelText__c = 'WBS'),
    new Opportunity(RecordTypeID = '01250000000UISQ', Name = 'Test FA 2 Q212 876543', FA_Talent_Name__c = FTals[2].id, 
    StageName = 'BDC-1', CloseDate = date.newinstance(2012,12,31), AccountId = af.id, ChannelText__c = 'FiNet' )

    }; 

insert Efforts;   

Contact[] Contacts = new Contact[] {
    new Contact(LastName = 'FA 1', FirstName = 'Test', Type__c = 'FA', AccountID = ap.id, IBDC__c = 'Adrian Vega', effort__c = Efforts[0].id,
    Regional_Sales_Manager__c = 'Chris Barsi', National_Sales_Territory__c = 'Missouri', Productivity_Consultant__c = 'Ally Shuman')

    }; 
insert Contacts;

test.starttest();

Efforts[0].Amount = 100000;
Efforts[0].AUM__c = 10000000;
Efforts[0].CloseDate = date.newinstance(2012,5,25);
update Efforts; 

Test.StopTest();

contact[] con = [SELECT Pre_Hire_T12_Production__c, Hire_Date__c, Pre_Hire_AUM__c FROM Contact WHERE ID =: Contacts[0].id];

system.assertequals(con[0].Pre_Hire_T12_Production__c, 100000);
system.assertequals(con[0].Pre_Hire_AUM__c, 10000000);
system.assertequals(con[0].Hire_Date__c, date.newinstance(2012,5,25));

}
}