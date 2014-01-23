@isTest

public class TestPopulateUserLookUpFieldOnCase {

    static testMethod void testPopulateUserLookupField() {
        
        User RBC = [SELECT ID, Name FROM User WHERE ProfileID = '00e50000000v97g' AND IsActive = True Limit 1];
        
        Account Branch1 = new Account();
        Branch1.Name = 'Test Branch 1';
        Branch1.Regional_Banking_Consultant__c = RBC.Name;
        
        insert Branch1;
        
        Account Branch2 = new Account();
        Branch2.Name = 'Test Branch 2';
        
        insert Branch2;
        
        Contact FA1 = new Contact();
        FA1.FirstName = 'Test';
        FA1.LastName = 'FA1';
        FA1.AccountId = Branch1.ID;
        FA1.Regional_Banking_Consultant__c = RBC.Name;
        
        insert FA1;
        
        Contact FA2 = new Contact();
        FA2.FirstName = 'Test';
        FA2.LastName = 'FA2';
        FA2.AccountID = Branch2.ID;
        
        insert FA2;
        
        test.StartTest();
        
        Case case1 = new Case();
        case1.RecordTypeID = '01250000000UHoi';
        case1.ContactId = FA1.id;
        case1.Subject__c = 'Bank Related';
        case1.Category__c = 'Online';
        case1.Follow_Up_Date__c = system.today().adddays(5);
        case1.Origin = 'Email';
        case1.Referral_Source__c = 'Home Office';
        case1.Referrer_Name__c = 'Test Referrer';
        case1.Inquiry_Type__c = 'Inquiry';
        case1.Subject = 'Test Subject';
        
        insert case1;
        
        Case case2 = new Case();
        case2.RecordTypeID = '01250000000UHoi';
        case2.ContactId = FA2.id;
        case2.Subject__c = 'Bank Related';
        case2.Category__c = 'Online';
        case2.Follow_Up_Date__c = system.today().adddays(5);
        case2.Origin = 'Email';
        case2.Referral_Source__c = 'Home Office';
        case2.Referrer_Name__c = 'Test Referrer';
        case2.Inquiry_Type__c = 'Inquiry';
        case2.Subject = 'Test Subject';
        
        insert case2;
        
        test.StopTest();
        
        Case CaseWithRBC = [SELECT Regional_Banking_Consultant__c FROM Case WHERE ID =: case1.id];
        
        System.assertequals(CaseWithRBC.Regional_Banking_Consultant__c, RBC.id);
        
        Case CaseWithNoRBC = [SELECT Regional_Banking_Consultant__c FROM Case WHERE ID =: case2.id];
        
        System.assertequals(CaseWithNoRBC.Regional_Banking_Consultant__c, null);
        
        
    }
        
}