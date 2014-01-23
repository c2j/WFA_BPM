@isTest
public class TestTriggerLeadSourceEOCEmail {

    static testMethod void TestLeadSourceEOCEmail() {
    
        Account Branch = new Account();
        Branch.name = 'Test PCG Branch';
        
        insert Branch;
        
        Opportunity Effort = new Opportunity();
        Effort.name = 'Test Effort';
        Effort.RecordTypeID = '01250000000UISS';
        Effort.AccountID = branch.id;
        Effort.StageName = 'Deal Offered With Start Date';
        Effort.CloseDate = date.newinstance(System.Today().Year(), 12, 31);
        Effort.Verified_T12_AUM__c = false;
        
        insert Effort;
        
        Lead_Source__c LeadSource = New Lead_Source__c();
        LeadSource.Effort__c = Effort.ID;
        LeadSource.Lead_Source__c = 'External Recruiter';
        LeadSource.Email_Lead_Source_EOC__c = false;
        
        insert LeadSource;
        
        test.startTest();
        
        Effort.StageName = 'Hired';
        Effort.Verified_T12_AUM__c = True;
        
        update Effort;
        
        test.stopTest();
        
        Lead_Source__c LS = [SELECT Email_Lead_Source_EOC__c FROM Lead_Source__c WHERE ID =: LeadSource.id];
        
        system.assertequals(LS.Email_Lead_Source_EOC__c, True);
        
    }
    
}