@isTest
public class TestTransitionReduction {
	static testMethod void myUnitTest() {
		Account acc = new Account();
		acc.RecordTypeId = '01250000000UGDa';
		acc.Name = 'test branch';
		insert acc;
		Contact con = new Contact(lastname = 'test');
		con.Type__c = 'FA';
		con.AccountId =acc.id;
		con.RecordTypeId = '01250000000UHL7';
		Date tempdate = System.today().addMonths(3);
		tempdate = tempDate.addYears(-1);
		con.T12_Production_As_Of_Date__c = system.today();
		con.Recruit_Anniversary_Date__c = tempdate;
		con.T12_Production__c = 300000;
		con.Production_Threshold__c = 500000;
		insert con;
		con.Type__c = 'Non-FA';
		update con;
		con.TR_Approval_Alert_Sent_Date__c = System.now().addYears(-1);
		con.T12_Production__c = 200000;
		update con;
		
	}
}