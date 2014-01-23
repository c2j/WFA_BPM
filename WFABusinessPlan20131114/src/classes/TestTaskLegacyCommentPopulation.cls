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
private class TestTaskLegacyCommentPopulation {

    static testMethod void myUnitTest() {
        
        Test.startTest();
        
        //stage user: internal
        User userInt = new User();
        userInt.Username = 'Test_user_internal@test.com';
        userInt.LastName = 'Test_internal_name';
        userInt.ProfileId = '00e50000000vBn0AAE';
        userInt.Alias = 'tstint';
        userInt.Email = 'Test_internal@email.com';
        userInt.CommunityNickname = 'Test_internal_nickname';
        userInt.TimeZoneSidKey = 'GMT';
        userInt.LocaleSidKey = 'en_US';
        userInt.LanguageLocaleKey = 'en_US';
        userInt.EmailEncodingKey = 'ISO-8859-1';
        userInt.MobilePhone = '+1 999-999-9999';
        userInt.AU__c = '0012345';
        userInt.EmployeeNumber = '1234567';
        insert userInt;
        
        //stage task
        Task tsk = new Task();
        tsk.OwnerId = userInt.id;
        tsk.Subject = 'Advisory';
        tsk.Category__c = 'Advisory-FundSource';
        tsk.Type = 'Call-Individual';
        tsk.Status = 'Complete';
        tsk.Priority = 'Normal';
        tsk.Communication_Type__c = 'Inbound';
        tsk.RecordTypeId = '012300000000V1JAAU';
                
        insert tsk;     
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(tsk);
        ApexPages.currentPage().getParameters().put('id', tsk.Id);
        
        TaskLegacyCommentPopulation controllertsk = new TaskLegacyCommentPopulation(sc);
        
        controllertsk.getCommentData();
                
        Test.stopTest();
    }
}