@isTest
private class BoMPlanTrgTest {
	private static testmethod void testBoMPlanTrigger(){
		Test.startTest();
		BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
		Test.stopTest();
		
		Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
		
		BPAdminCon con = new BPAdminCon ();
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();
		//Test FA Goal Update
		list<FA_Goal__c> faGoalList = [Select Name From FA_Goal__c];
		for(FA_Goal__c faGoal : faGoalList){
			faGoal.Plan_Advisory_Net_Flows__c = 1000000;
			faGoal.Plan_Lending__c = 2000000;
			faGoal.Plan_Net_Income__c = 3000000;
			faGoal.Plan_New_Key_HHs__c = 50;
		}
		
		update faGoalList;
		
		//Test Status Update
		list<BoM_Plan__c> bomPlanList = [Select Name From BoM_Plan__c];
		bomPlanList[0].Status__c = 'Closed';
		bomPlanList[1].Status__c = 'In Action';
		bomPlanList[2].Status__c = 'Closed';
		/*
		bomPlanList[3].Status__c = 'In Action';
		bomPlanList[4].Status__c = 'In Action';
		bomPlanList[5].Status__c = 'In Action';
		*/
		update bomPlanList;
		
		//Test unlock
		bomPlanList[0].Status__c = 'Available';
		bomPlanList[1].Status__c = 'Available';
		bomPlanList[2].Status__c = 'Available';
		
		update bomPlanList;
	}
}