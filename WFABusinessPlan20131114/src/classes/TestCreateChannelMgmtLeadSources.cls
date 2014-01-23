@isTest

Private Class TestCreateChannelMgmtLeadSources {

//Trigger has been replaced by scheduled apex class ScheduleTaskingForCABOOnDemandCases


Static testMethod void TestCreatingChnlMgmtLS () {

//get a market manager user
User MktMgr = [SELECT ID, ProfileID FROM User WHERE ProfileID = '00e50000000vLe3'  AND AU__c != Null AND EmployeeNumber != Null 
    AND MobilePhone = '+1 999-999-9999' AND IsActive = True Limit 1];
    
Account b = new Account(Name = 'PCG Branch');

insert b;


AccountShare BranchMgrShare = new AccountShare(); 
                
//create sharing record on test branch for mkt mgr
BranchMgrShare.AccountID = b.ID;
            
BranchMgrShare.UserOrGroupID = MktMgr.ID;

//grant managers read only access
BranchMgrShare.AccountAccessLevel = 'Edit';
BranchMgrShare.ContactAccessLevel = 'read';
BranchMgrShare.OpportunityAccessLevel = 'edit';
BranchMgrShare.CaseAccessLevel = 'None';
            
insert BranchMgrShare;

            
FA_Talent__c FT = New FA_Talent__c(Name = 'Test FA 123456', First_Name__c = 'Test', Last_Name__c = 'FA', CRD_Number__c = '123456');

insert FT;

//create sharing record on test branch for mkt mgr
FA_Talent__Share FTShare = new FA_Talent__Share(); 
                
FTShare.ParentID = FT.ID;

FTShare.UserOrGroupID = MktMgr.ID;

FTShare.AccessLevel = 'Edit';

//MBMgrShare.RowCause = Schema.Main_Branch__Share.RowCause.Main_Branch_Manager_Access__c;

insert FTShare;


test.StartTest();

system.runAs(MktMgr) {

Opportunity PCGEffort = new Opportunity(Name = 'Test FA Effort 123456', AccountID = b.id, FA_Talent_Name__c = FT.ID, StageName = 'Discussion',
CloseDate = date.newinstance(system.now().date().year(), 12,31));

insert PCGEffort;

test.StopTest();

Lead_Source__c ls = [SELECT Effort__c, Lead_Accepted_Date__c, Lead_Source__c FROM Lead_Source__c WHERE Effort__c =: PCGEffort.ID];

system.assertequals(ls.lead_accepted_date__c, system.now().date());
system.assertequals(ls.lead_source__c, 'Channel Management');

}
}
}