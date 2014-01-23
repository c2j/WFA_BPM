@isTest
private class BPActionPlanElementConTest {

    static testMethod void testBPActionPlanElementCon() {
    	
    	Test.startTest();
        BPBranchBusinessPlanCon tmpCon = new BPBranchBusinessPlanCon();
    	list<Account> accounts = BranchUtil.createSampleBranchWithFAsMainBranchAndPlan();
    	Test.stopTest();
    	BranchUtil.createBranchBusinessPlanHelp();
    	system.debug('ElementCon bomPlanxx ================>>>>>   ' + [Select Id, Name From BoM_Plan__c limit 1]);
    	BoM_Plan__c bomPlan = [Select Id, Name From BoM_Plan__c limit 1][0];
    	system.debug('bomPlan================>>>>>   ' + bomPlan);
    	list<Plan_Activity__c> paList = ActionPlanElementUtil.createTestPlanActivity();
    	//system.debug(JSON.serialize(paList));
    	
    	ApexPages.StandardController controller = new ApexPages.StandardController(bomPlan); 
        BPFAActionPlanningCon con = new BPFAActionPlanningCon(controller);
        List<SelectOption> BPGoalItems = con.BPGoalItems;
        PageReference pageRef = Page.BPFAActionPlanning;
        pageRef.getParameters().put('id', bomPlan.Id);
        Test.setCurrentPage(pageRef);
        con.createFAActionPlan(); 
        for(Action_Plan__c ap : con.actionPlanList) {
        	ap.FA_Goal__r.Primary_Objective__c = ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION;
        }
        List<Action_Plan__c> actionPlanList = con.actionPlanList;
        ActionPlanElementUtil.createTestActionPlan(2, bomPlan);
        //system.debug('Test >>>>> ' + JSON.serialize(actionPlanList));
        ActionPlanElementUtil.createTestActionPlanElement(3, actionPlanList);
        Test.setCurrentPage(con.forward());
    	BPActionPlanElementCon con2 = new BPActionPlanElementCon();
    	con2.init();
    	con2.tabIndex = '0';
    	con2.deleteIndex = 1;
    	for(ActionPlanElementUtil.ObjectWrapper wrapper : con2.firstTabWrapperList) {	
    		if(wrapper.oddList != null) {
	    		list<ActionPlanElementUtil.PlanActivityWrapper> temPAList = wrapper.oddList;
	    		if(temPAList != null) {
	    			for(ActionPlanElementUtil.PlanActivityWrapper p : temPAList) {
	    				p.isSelected = true;
	    			}
	    		}
	    		temPAList = wrapper.evenList;
	    		if(temPAList != null) {
	    			for(ActionPlanElementUtil.PlanActivityWrapper p : temPAList) {
	    				p.isSelected = true;
	    			}
	    		}
	    		temPAList = wrapper.thirdList;
	    		if(temPAList != null) {
	    			for(ActionPlanElementUtil.PlanActivityWrapper p : temPAList) {
	    				p.isSelected = true;
	    			}
	    		}
    		}
    	}
    	con2.addRow();
    	con2.deleteRow();
    	con2.tabIndex = '1';
    	con2.addRow();
    	con2.deleteRow();
    	con2.tabIndex = '2';
    	con2.addRow();
    	con2.deleteRow();
    	con2.tabIndex = '3';
    	con2.addRow();
    	con2.deleteRow();
    	con2.tabIndex = '4';
    	con2.addRow();
    	con2.deleteRow();
    	con2.save();
    	con2.disableInputText();
    	con2.cancel();
    	con2.back();
    	con2.cancel();
    	con.cancel();
    	ActionPlanElementUtil.CustomActivityWrapper wrapper = new ActionPlanElementUtil.CustomActivityWrapper(1, '1', '1', true);
    	ActionPlanElementUtil.CustomActivityWrapper wrapper2 = new ActionPlanElementUtil.CustomActivityWrapper(1, '2', '2', true);
    	wrapper.compareTo(wrapper2);
    }
}