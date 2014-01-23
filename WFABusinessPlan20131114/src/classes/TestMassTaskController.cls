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
private class TestMassTaskController {

static testMethod void myUnitTest() {
        Test.startTest();
        
        //Create Accounts
        Account account1 = new Account();
        account1.Name = 'Test_Account_01';
        insert account1;
        
        Account account2 = new Account();
        account2.Name = 'Test_Account_02';
        insert account2;        
        
        //Create Contacts
        Contact contact1 = new Contact();
        contact1.LastName = 'Test_Contact_01';
        insert contact1;
        
        Contact contact2 = new Contact();
        contact2.LastName = 'Test_Contact_01';
        insert contact2;
        
        //Set id of account (branch) that a task will be created against
        String[] branches = new String[]{}; 
        branches.add(account1.id);        
        
        //Create a users utilizing different profiles     
        //User: Internal
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
        
        //User: Productivity Consultant
        User userPC = new User();
        userPC.Username = 'Test_user_prodc@test.com';
        userPC.LastName = 'Test_prodc_name';
        userPC.ProfileId = '00e50000000vBn5AAE';
        userPC.Alias = 'tstprodc';
        userPC.Email = 'Test_prodc@email.com';
        userPC.CommunityNickname = 'Test_prodc_nickname';
        userPC.TimeZoneSidKey = 'GMT';
        userPC.LocaleSidKey = 'en_US';
        userPC.LanguageLocaleKey = 'en_US';
        userPC.EmailEncodingKey = 'ISO-8859-1';
        userPC.MobilePhone = '+1 999-999-9999';
        userPC.AU__c = '0023456';
        userPC.EmployeeNumber = '2345678';
        insert userPC;        
        
        //User: Regional Banking Consultant
        User userRBC = new User();
        userRBC.Username = 'Test_user_rbc@test.com';
        userRBC.LastName = 'Test_rbc_name';
        userRBC.ProfileId = '00e50000000v97gAAA';
        userRBC.Alias = 'tstrbc';
        userRBC.Email = 'Test_rbc@email.com';
        userRBC.CommunityNickname = 'Test_rbc_nickname';
        userRBC.TimeZoneSidKey = 'GMT';
        userRBC.LocaleSidKey = 'en_US';
        userRBC.LanguageLocaleKey = 'en_US';
        userRBC.EmailEncodingKey = 'ISO-8859-1';
        userRBC.MobilePhone = '+1 999-999-9999';
        userRBC.AU__c = '0034567';
        userRBC.EmployeeNumber = '3456789';
        insert userRBC;
        
        //Simulate the page for What Id
        PageReference pPageReference = Page.MassTaskCreatePage;
        pPageReference.getParameters().put('objIds',account1.Id+','+account2.Id);
        pPageReference.getParameters().put('retUrl','');
        Test.setCurrentPage(pPageReference);
        
        MassTaskController controller = new MassTaskController();
        //System.assertEquals(controller.showWhoId, true);
        controller.getTableDisplayNames();
        controller.saveNew();
        controller.save();
        controller.back();

        //Simulate the page for Who Id
        pPageReference = Page.MassTaskCreatePage;
        pPageReference.getParameters().put('objIds',contact1.Id+','+contact2.Id);
        pPageReference.getParameters().put('retUrl','');
        Test.setCurrentPage(pPageReference);
        controller = new MassTaskController();
        System.assertEquals(controller.showWhoId, false);
        controller.getBranch();
        controller.setBranch(branches);
        controller.getTableDisplayNames();
        controller.getselReminderOptions();
        controller.saveNew();
        Pagereference pageRef = controller.save();
        System.assertEquals(pageRef, null);
        controller.back();
        
        controller.task.OwnerId = userInt.Id;
        controller.task.RecordTypeId = '012300000000V1JAAU';
        controller.task.Category__c = 'Banking-Business Banking';
        controller.task.Type = 'Call-Individual';
        controller.task.Communication_Type__c = 'Inbound';
        controller.task.Subject = 'Banking';
        controller.task.Status = 'Complete';
        controller.task.Priority = 'High';
        
        //Set the reminder
        controller.task.IsReminderSet = true;
        controller.contact.Birthdate = Date.today();
        controller.reminderTime = '23:30';
        
        //Send Email notification
        controller.sendNotificationEmailCheckBox = true;
        
        controller.saveNew();
        pageRef = controller.save();
        //System.assertNotEquals(pageRef, null);
        
        
        Test.stopTest();
    }
}