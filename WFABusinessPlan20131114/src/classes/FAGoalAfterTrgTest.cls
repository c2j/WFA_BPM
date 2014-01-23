@isTest
private class FAGoalAfterTrgTest {
	private static testmethod void testFAGoalMassInsert(){
		Test.startTest();
		list<Main_Branch__c> mbList = MainBranchUtil.getSampleMainBranchList(1);
		insert mbList;
		
		BranchUtil.createMassSampleBranchWithFAs(mbList[0]);
		
		list<Contact> faList = [Select Id, Name From Contact];
		
		BoM_Plan_Group__c planGroup = BPBranchBusinessPlanUtil.createSampleBoMPlanGroup();
		list<BoM_Plan__c> planList = BPBranchBusinessPlanUtil.getSampleBoMPlanList(1, mbList[0], planGroup);		
		insert planList;
		
		Test.stopTest();
		
		list<FA_Goal__c> faGoalList = new list<FA_Goal__c>();
		for(Contact fa : faList){
			faGoalList.addAll(FAGoalUtil.getSampleFAGoalList(1, planList[0], fa));
		}
		system.debug('*** number of FA Goal: ' + faGoalList.size());
		system.debug('*** Start insert fa goals.');
		insert faGoalList;
		system.debug('*** End insert fa goals.');
	}
	
	private static testmethod void testFAGoalMassUpdate(){
		Test.startTest();
		list<Main_Branch__c> mbList = MainBranchUtil.getSampleMainBranchList(1);
		insert mbList;
		
		BranchUtil.createMassSampleBranchWithFAs(mbList[0]);
		
		list<Contact> faList = [Select Id, Name From Contact];
		
		BoM_Plan_Group__c planGroup = BPBranchBusinessPlanUtil.createSampleBoMPlanGroup();
		list<BoM_Plan__c> planList = BPBranchBusinessPlanUtil.getSampleBoMPlanList(1, mbList[0], planGroup);		
		insert planList;
		
		
		
		list<FA_Goal__c> faGoalList = new list<FA_Goal__c>();
		for(Contact fa : faList){
			faGoalList.addAll(FAGoalUtil.getSampleFAGoalList(1, planList[0], fa));
		}
		insert faGoalList;
		Test.stopTest();
		
		for(FA_Goal__c faGoal : faGoalList){
			faGoal.Plan_Lending__c = 100332;
		}
		system.debug('*** number of FA Goal: ' + faGoalList.size());
		system.debug('*** Start insert fa goals.');
		update faGoalList;
		system.debug('*** End insert fa goals.');
	}
	
}