@isTest
private class BPBoMPlanExtTest {
    private static void prepareBoMPlan(){
        //Clear out all the bom plans
        Delete [Select Id From BoM_Plan__c];
        
		Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
		
		BPAdminCon con = new BPAdminCon ();
		BPCommonUtil.log('Finished BPAdminCon Structor');
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();
		BPCommonUtil.log('Finished startBoMPlan');
		//Test FA Goal Update
        
        Id branchPlanRT = BPBranchBusinessPlanUtil.getBranchPlanRecordTypeId();
        
		list<FA_Goal__c> faGoalList = [Select Name From FA_Goal__c Where BoM_Plan__r.RecordTypeId = :branchPlanRT];
		for(FA_Goal__c faGoal : faGoalList){
			faGoal.Plan_Advisory_Net_Flows__c = 1000000;
			faGoal.Plan_Lending__c = 2000000;
			faGoal.Plan_Net_Income__c = 3000000;
			faGoal.Plan_New_Key_HHs__c = 50;
		}
				
		update faGoalList;
		BPCommonUtil.log('Finished update faGoalList');
    }
    
    private static testmethod void testBPBoMPlanExt(){
		Test.startTest();
		BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
		BPCommonUtil.log('Finished createSampleBranchWithFAsMainBranchComplexMarketAndRegion');
		Test.stopTest();
		
        prepareBoMPlan();
		
        Id branchPlanRT = BPBranchBusinessPlanUtil.getBranchPlanRecordTypeId();
		list<BoM_Plan__c> bomPlanList = [Select Name From BoM_Plan__c Where RecordTypeId = :branchPlanRT limit 10];
        BPCommonUtil.log('bomPlanList', bomPlanList);
		Integer nCount = 0;
        for(BoM_Plan__c plan : bomPlanList){
			
			BPBoMPlanExt ext = new BPBoMPlanExt();
            
			ext.submitPlan();
			ext.finalizePlan();
			ext.gotoPlan();
			ext.gotoLeadershipPlan();
			nCount++;
		}
        
        nCount = 0;
		for(BoM_Plan__c plan : bomPlanList){
			
			BPBoMPlanExt ext = new BPBoMPlanExt();
			ext.planId = plan.Id;
			
			if(nCount == 0){//Meet fa goal
				plan.Status__c = 'In Progress';
				plan.Leadership_Plan_Completed__c = true;
				plan.Plan_Advisory_Net_Flows_Rollup__c = 10000000;
				plan.Plan_Lending_Rollup__c = 20000000;
				plan.Plan_Revenue__c = 30000000;
				plan.YTD_Profit_Margin__c = 12;
				plan.Plan_New_Key_HHs_Rollup__c = 500;
				plan.Action_Plan_Completed__c = true;
                plan.Tonnage_Goal_Advisory_Net_Flows__c = 11;
				plan.Tonnage_Goal_Lending__c = 11;
				plan.Tonnage_Goal_Net_Income__c = 11;
				plan.Tonnage_Goal_New_Key_HHs__c = 11;
				update plan;
			}
            
			ext.submitPlan();
			ext.finalizePlan();
			ext.gotoPlan();
			ext.gotoLeadershipPlan();
			nCount++;
		}
        
        nCount = 0;
        for(BoM_Plan__c plan : bomPlanList){
			
			BPBoMPlanExt ext = new BPBoMPlanExt();
			ext.planId = plan.Id;
            if(nCount == 0){//Meet fa goal
				plan.Status__c = 'In Progress';
				plan.Leadership_Plan_Completed__c = false;
				update plan;
			}
            
			ext.submitPlan();
			ext.finalizePlan();
			ext.gotoPlan();
			ext.gotoLeadershipPlan();
			nCount++;
		}
        
        nCount = 0;
        for(BoM_Plan__c plan : bomPlanList){
			
			BPBoMPlanExt ext = new BPBoMPlanExt();
			ext.planId = plan.Id;

			if(nCount == 0){//Meet fa goal
				plan.Status__c = 'In Progress';
				plan.Action_Plan_Completed__c = false;
				update plan;
			}
            
			ext.submitPlan();
			ext.finalizePlan();
			ext.gotoPlan();
			ext.gotoLeadershipPlan();
			nCount++;
		}
		BPCommonUtil.log('Finished all');
	}
    
    private static testmethod void testBPBoMPlanExtNotMeetGoal(){
		Test.startTest();
		BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
		BPCommonUtil.log('Finished createSampleBranchWithFAsMainBranchComplexMarketAndRegion');
		Test.stopTest();
		
        prepareBoMPlan();
		
        Id branchPlanRT = BPBranchBusinessPlanUtil.getBranchPlanRecordTypeId();
		list<BoM_Plan__c> bomPlanList = [Select Name From BoM_Plan__c Where RecordTypeId = :branchPlanRT limit 10];
        BPCommonUtil.log('bomPlanList', bomPlanList);
		Integer nCount = 0;
		for(BoM_Plan__c plan : bomPlanList){
			
			BPBoMPlanExt ext = new BPBoMPlanExt();
			ext.planId = plan.Id;
			
			if(nCount == 0){//Not meet fa goal
				plan.Status__c = 'In Progress';
				plan.Leadership_Plan_Completed__c = true;
				plan.Plan_Advisory_Net_Flows_Rollup__c = 1000000;
				plan.Plan_Lending_Rollup__c = 2000000;
				plan.Plan_Revenue__c = 3000000;
				plan.YTD_Profit_Margin__c = 12;
				plan.Plan_New_Key_HHs_Rollup__c = 50;
				plan.Action_Plan_Completed__c = true;
				plan.Tonnage_Goal_Advisory_Net_Flows__c = 999999999;
				plan.Tonnage_Goal_Lending__c = 999999999;
				plan.Tonnage_Goal_Net_Income__c = 999999999;
				plan.Tonnage_Goal_New_Key_HHs__c = 55;
				update plan;
			}			
			
			ext.submitPlan();
			ext.finalizePlan();
			ext.gotoPlan();
			ext.gotoLeadershipPlan();
			nCount++;
		}
		BPCommonUtil.log('Finished all');
	}
}