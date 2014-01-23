@isTest
private class BPBranchBusinessPlanConTest {

	private static testMethod void testCreateAndDisplayFAGoalsFinal() {
    	BPBranchBusinessPlanCon tmpCon = new BPBranchBusinessPlanCon();
    	decimal tonnageGoalAdvisoryNetFlows = tmpCon.tonnageGoalAdvisoryNetFlows;
    	decimal tonnageGoalNewKeyHHs = tmpCon.tonnageGoalNewKeyHHs;
    	decimal tonnageGoalLending = tmpCon.tonnageGoalLending;
    	decimal tonnageGoalNetIncome = tmpCon.tonnageGoalNetIncome;
    	
    	Test.startTest();
    	list<Account> accounts = BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
    	Test.stopTest();
    	
    	Delete [Select Id From BoM_Plan__c];
    	Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
        BPAdminCon adminCon = new BPAdminCon();
		adminCon.selectedYear = adminCon.yearList[0].getValue();
		adminCon.startBoMPlan();
    	
    	BranchUtil.createBranchBusinessPlanHelp();
    	system.debug('bomPlan xx ================>>>>>   ' + [Select Id, Name From BoM_Plan__c limit 1]);
    	
    	for(BoM_Plan__c bomPlan : [Select Id, Name From BoM_Plan__c Where recordTypeId = :BPBranchBusinessPlanUtil.branchPlanRT order by Name limit 2]){
	    	bomPlan.YTD_Profit_Margin__c = 0.25;
	    	bomPlan.Plan_T12_Recruited__c = 50000001;
	    	bomPlan.Plan_T12_Attrited__c = 50000001;
	    	update bomPlan;
	    	list<FA_Goal__c> faGoalList = new list<FA_Goal__c>(); 	
	    	for(FA_Goal__c fa : [Select Plan_Advisory_Net_Flows__c, Plan_Lending__c
	    										, Plan_Net_Income__c, Plan_New_Key_HHs__c
	    										From FA_Goal__c
	    										Where BoM_Plan__c =: bomPlan.Id]) {
	    		fa.Plan_New_Key_HHs__c = 501;
	    		fa.Plan_Advisory_Net_Flows__c = 500000001;
	    		fa.Plan_Lending__c = 250000001;
	    		fa.Plan_Net_Income__c = 15000001;
	    		faGoalList.add(fa);
	    	}
	    	update faGoalList;
	    	system.debug('bomPlan================>>>>>   ' + bomPlan);
	    	PageReference pageRef = Page.bpbranchbusinessplan;
	    	pageRef.getParameters().put('pid', bomPlan.Id);
	        pageRef.getParameters().put('selectedTab','newKeyHHs');
	        pageRef.getParameters().put('index','2');
	        pageRef.getParameters().put('operation','init');
	        Test.setCurrentPage(pageRef);
	        BPBranchBusinessPlanCon con = new BPBranchBusinessPlanCon();
	        con.createAndDisplayFAGoals();
	        con.saveFAGoals();
	        con.cancel();
	        bomPlan = null;
	        con.saveFAGoals();
	        con.cancel();
    	}
    }

    private static testMethod void testCreateAndDisplayFAGoals() {
    	BPBranchBusinessPlanCon tmpCon = new BPBranchBusinessPlanCon();
    	decimal tonnageGoalAdvisoryNetFlows = tmpCon.tonnageGoalAdvisoryNetFlows;
    	decimal tonnageGoalNewKeyHHs = tmpCon.tonnageGoalNewKeyHHs;
    	decimal tonnageGoalLending = tmpCon.tonnageGoalLending;
    	decimal tonnageGoalNetIncome = tmpCon.tonnageGoalNetIncome;
    	
    	Test.startTest();
    	list<Account> accounts = BranchUtil.createSampleBranchWithFAsMainBranchAndPlan();
    	Test.stopTest();
    	BranchUtil.createBranchBusinessPlanHelp();
    	system.debug('bomPlan xx ================>>>>>   ' + [Select Id, Name From BoM_Plan__c limit 1]);
    	BoM_Plan__c bomPlan = [Select Id, Name From BoM_Plan__c limit 1][0];
    	bomPlan.YTD_Profit_Margin__c = 0.25;
    	bomPlan.Plan_T12_Recruited__c = 50000001;
    	bomPlan.Plan_T12_Attrited__c = 50000001;
    	update bomPlan;
    	list<FA_Goal__c> faGoalList = new list<FA_Goal__c>(); 	
    	for(FA_Goal__c fa : [Select Plan_Advisory_Net_Flows__c, Plan_Lending__c
    										, Plan_Net_Income__c, Plan_New_Key_HHs__c
    										From FA_Goal__c
    										Where BoM_Plan__c =: bomPlan.Id]) {
    		fa.Plan_New_Key_HHs__c = 501;
    		fa.Plan_Advisory_Net_Flows__c = 500000001;
    		fa.Plan_Lending__c = 250000001;
    		fa.Plan_Net_Income__c = 15000001;
    		faGoalList.add(fa);
    	}
    	update faGoalList;
    	system.debug('bomPlan================>>>>>   ' + bomPlan);
    	PageReference pageRef = Page.bpbranchbusinessplan;
    	pageRef.getParameters().put('pid', bomPlan.Id);
        pageRef.getParameters().put('selectedTab','newKeyHHs');
        pageRef.getParameters().put('index','2');
        pageRef.getParameters().put('operation','init');
        Test.setCurrentPage(pageRef);
        BPBranchBusinessPlanCon con = new BPBranchBusinessPlanCon();
        
        con.createAndDisplayFAGoals();
        con.saveFAGoals();
        con.cancel();
        bomPlan = null;
        con.saveFAGoals();
        con.cancel();
        
    }
    
        private static testMethod void reTestCreateAndDisplayFAGoals() {
    	
    	BPBranchBusinessPlanCon tmpCon = new BPBranchBusinessPlanCon();
    	decimal tonnageGoalAdvisoryNetFlows = tmpCon.tonnageGoalAdvisoryNetFlows;
    	decimal tonnageGoalNewKeyHHs = tmpCon.tonnageGoalNewKeyHHs;
    	decimal tonnageGoalLending = tmpCon.tonnageGoalLending;
    	decimal tonnageGoalNetIncome = tmpCon.tonnageGoalNetIncome;
    	
    	Test.startTest();
    	list<Account> accounts = BranchUtil.createSampleBranchWithFAsMainBranchAndPlan();
    	Test.stopTest();
    	delete [Select Id From FA_Goal__c];
    	BranchUtil.createBranchBusinessPlanHelp();
    	system.debug('bomPlan xx ================>>>>>   ' + [Select Id, Name From BoM_Plan__c limit 1]);
    	BoM_Plan__c bomPlan = [Select Id, Name From BoM_Plan__c limit 1][0];
    	bomPlan.Plan_T12_Recruited__c = 5000001;
    	bomPlan.YTD_Profit_Margin__c = 0.40;
    	update bomPlan;
            
    	system.debug('bomPlan================>>>>>   ' + bomPlan);
    	PageReference pageRef = Page.bpbranchbusinessplan;
    	pageRef.getParameters().put('pid', bomPlan.Id);
        pageRef.getParameters().put('selectedTab','newKeyHHs');
        pageRef.getParameters().put('index','2');
        pageRef.getParameters().put('operation','save');
        Test.setCurrentPage(pageRef);
        BPBranchBusinessPlanCon con = new BPBranchBusinessPlanCon();
        con.year = 2013;
        con.createAndDisplayFAGoals();
        con.saveFAGoals();
        con.cancel();
        bomPlan = null;
        con.saveFAGoals();
        con.cancel();
    }
    
    private static testMethod void reTestCreateAndDisplayFAGoalsWithRecruitingMetrics() {
    	
    	BPBranchBusinessPlanCon tmpCon = new BPBranchBusinessPlanCon();
    	decimal tonnageGoalAdvisoryNetFlows = tmpCon.tonnageGoalAdvisoryNetFlows;
    	decimal tonnageGoalNewKeyHHs = tmpCon.tonnageGoalNewKeyHHs;
    	decimal tonnageGoalLending = tmpCon.tonnageGoalLending;
    	decimal tonnageGoalNetIncome = tmpCon.tonnageGoalNetIncome;
    	
    	Test.startTest();
    	list<Account> accounts = BranchUtil.createSampleBranchWithFAsMainBranchAndPlan();
    	Test.stopTest();
    	delete [Select Id From FA_Goal__c];
    	BranchUtil.createBranchBusinessPlanHelp();
    	system.debug('bomPlan xx ================>>>>>   ' + [Select Id, Name From BoM_Plan__c limit 1]);
    	BoM_Plan__c bomPlan = [Select Id, Name From BoM_Plan__c limit 1][0];
    	bomPlan.Plan_T12_Recruited__c = 5000001;
    	bomPlan.YTD_Profit_Margin__c = 0.40;
    	update bomPlan;
        
        list<Recruiting_Metric__c> rmList = new list<Recruiting_Metric__c>();
        Recruiting_Metric__c rm = new Recruiting_Metric__c();
        rm.Name = '2013';
        rm.Lending_Originations__c = 0.001;
        rm.Net_Advisory_Flows__c = 0.001;
        rm.Net_Income__c = 0.001;
        rm.New_Key_HHs__c = 1;
        rmList.add(rm);
        
        rm = new Recruiting_Metric__c();
        rm.Name = '2014';
        rm.Lending_Originations__c = 0.001;
        rm.Net_Advisory_Flows__c = 0.001;
        rm.Net_Income__c = 0.001;
        rm.New_Key_HHs__c = 1;
        rmList.add(rm);
        
        rm = new Recruiting_Metric__c();
        rm.Name = '2015';
        rm.Lending_Originations__c = 0.001;
        rm.Net_Advisory_Flows__c = 0.001;
        rm.Net_Income__c = 0.001;
        rm.New_Key_HHs__c = 1;
        rmList.add(rm);
        insert rmList;
        
    	system.debug('bomPlan================>>>>>   ' + bomPlan);
    	PageReference pageRef = Page.bpbranchbusinessplan;
    	pageRef.getParameters().put('pid', bomPlan.Id);
        pageRef.getParameters().put('selectedTab','newKeyHHs');
        pageRef.getParameters().put('index','2');
        pageRef.getParameters().put('operation','save');
        Test.setCurrentPage(pageRef);
        BPBranchBusinessPlanCon con = new BPBranchBusinessPlanCon();
        con.year = 2013;
        con.createAndDisplayFAGoals();
        con.saveFAGoals();
        con.cancel();
        bomPlan = null;
        con.saveFAGoals();
        con.cancel();
    }
    
}