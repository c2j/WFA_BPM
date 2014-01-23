@isTest
public class TestUserAccessCheck{
	static testMethod void myUnitTest() {
		test.startTest();
		UserAccessDays__c uad = new UserAccessDays__c();
		uad.Name = 'Test Default';
		uad.Profile_Name__c = 'System Administrator';
		uad.Password_Reset_Days__c = 10;
		uad.Total_Days_LastLogin__c = 10;
		uad.Reply_to_Email__c = 'test@wfatest.com';
		insert uad;
		UserAccessCheck uac = new UserAccessCheck();
		String CRON_EXP = '0 0 23 * * ?';
		
		// Schedule the test job
		String jobId = System.schedule('UserAccess',CRON_EXP,uac);
		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
		// Verify the expressions are the same
		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		// Verify the next time the job will run
		test.stopTest();
		
	}
}