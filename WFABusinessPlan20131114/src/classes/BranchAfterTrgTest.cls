@isTest
private class BranchAfterTrgTest {

	static testMethod void testMassBranchInsert () {
		list<Main_Branch__c> mainBranchList = MainBranchUtil.getSampleMainBranchList(1);
		list<Account> branchList = BranchUtil.createMassSampleBranchWithFAs(mainBranchList[0]);
	}
	
	static testMethod void testMassBranchUpdate () {
		Test.startTest();
		list<Main_Branch__c> mainBranchList = MainBranchUtil.getSampleMainBranchList(1);
		list<Account> branchList = BranchUtil.createMassSampleBranchWithFAs(mainBranchList[0]);
		Test.stopTest();
		
		system.debug('*** Start updating Branch...');
		for(Account branch : branchList){
			//make it different to fire the update trigger
			branch.X2013_TONNAGE_GOAL_NETINCOME__C = 12345590;
		}
		system.debug('*** Finished updating Branch...');
		
		update branchList;
	}
	
	static testMethod void testBranchInsert () {

		list<Account> branchList = BranchUtil.createSampleBranchWithFAsMainBranchAndPlan();

	}
	
	static testMethod void testBranchInsertUpdate () {

		list<Account> branchList = BranchUtil.createSampleBranchWithFAsMainBranchAndPlan();
		
		system.debug('*** Start updating Branch...');
		for(Account branch : branchList){
			//make it different to fire the update trigger
			branch.X2013_TONNAGE_GOAL_NETINCOME__C = 12345590;
		}
		system.debug('*** Finished updating Branch...');

	}
}