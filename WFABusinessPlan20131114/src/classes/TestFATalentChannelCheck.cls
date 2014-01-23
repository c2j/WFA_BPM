/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestFATalentChannelCheck {

    static testMethod void myUnitTest() {
        Test.startTest();
        
        //create employing firm
        Employing_Firm__c ef = new Employing_Firm__c();
        ef.Name = 'Test EF';
        
        insert ef;        
        
        Main_Branch__c mb = MainBranchUtil.getSampleMainBranchList(1)[0];
        insert mb;
        Account branch = BranchUtil.getSampleBranchList(1, mb, null)[0];
        insert branch;
        
        //create fa talent
        FA_Talent__c fat = new FA_Talent__c();
        fat.Name = 'Test Employee FA Talent';
        fat.FAI_Status__c = 'AV';
        fat.Gender__c = 'F';
        fat.Employing_Firm__c = ef.id;
        fat.First_Name__c = 'Test';
        fat.Last_Name__c = 'Person';
        fat.At_Firm_Since__c = date.today() - 100;
        fat.Broker_Since__c = date.today();
        fat.CRD_Number__c = '11111';
        
        insert fat;        
        
        //create oppty
        //0015000000XwQVLAA3    La Jolla, CA = PCG
        //0015000000YidLmAAJ    Los Angeles - LB = WBS
        
        Opportunity effort1 = new Opportunity();
        effort1.Name = fat.CRD_Number__c;
        effort1.FA_Talent_Name__c = fat.id;
        effort1.StageName = 'Introduced Hiring Manager';
        effort1.CloseDate = date.today();
        effort1.AccountId = branch.Id;
        effort1.Inactive__c = false;
        effort1.RecordTypeId = '01250000000UISSAA4'; //fa integration effort
        //effort1.Recruiting_Responsibility__c = 'Complex Manager';
       
        insert effort1;
        
        //create active lead source
        Lead_Source__c ls = new Lead_Source__c();
        ls.Inactive__c = false;
        ls.Effort__c = effort1.id;
        ls.Lead_Source__c = 'Test Source';
        
        insert ls;        
        
        //create FiNet oppty
        Opportunity effort2 = new Opportunity();
        effort2.Name = fat.CRD_Number__c;
        effort2.FA_Talent_Name__c = fat.id;
        effort2.StageName = 'Introduced Hiring Manager';
        effort2.CloseDate = date.today();
        effort2.AccountId = branch.Id;
        effort2.Inactive__c = false;
        effort2.RecordTypeId = '01250000000UISSAA4'; //fa integration effort
        
        insert effort2;
        
        //create active lead source
        Lead_Source__c ls2 = new Lead_Source__c();
        ls2.Inactive__c = false;
        ls2.Effort__c = effort2.id;
        ls2.Lead_Source__c = 'Test Source';
        
        insert ls2;
                
        //update effort status
        effort1.Inactive__c = true;
        effort1.Inactive_Reason__c = 'CO not interested';
        effort1.CloseDate = date.newinstance(2012, 12, 31);
        
        update effort1;   

        
        delete effort2;     
        
        Test.stopTest();
    }
}