@isTest
public class BPFAActionPlanningConTest {
	
	private static testmethod void testBPFAActionPlanningCon() {
        BPBranchBusinessPlanCon tmpCon = new BPBranchBusinessPlanCon();
		Test.startTest();
    	list<Account> accounts = BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
    	Test.stopTest();
        
        Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
        
        Delete [Select Id From BoM_Plan__c];
        Delete [Select Id From FA_Goal__c];
        BPAdminCon adminCon = new BPAdminCon();
		adminCon.selectedYear = adminCon.yearList[0].getValue();
		adminCon.startBoMPlan();
        
    	//BranchUtil.createBranchBusinessPlanHelp();
        Id bPRecordTypeId = BPBranchBusinessPlanUtil.branchPlanRT;

        //BoM_Plan__c bomPlan = [Select Id, Name From BoM_Plan__c Where RecordtypeId=:bPRecordTypeId limit 1][0];
        BoM_Plan__c bomPlan = [Select Id, Name From BoM_Plan__c Where RecordtypeId=:bPRecordTypeId limit 1][0];
        PageReference pageRef = Page.bpbranchbusinessplan;
        pageRef.getParameters().put('pid', bomPlan.Id);
        pageRef.getParameters().put('selectedTab','newKeyHHs');
        pageRef.getParameters().put('index','2');
        pageRef.getParameters().put('operation','init');
        Test.setCurrentPage(pageRef);
        BPBranchBusinessPlanCon bbpCon = new BPBranchBusinessPlanCon();
        bbpCon.createAndDisplayFAGoals();
        bbpCon.saveFAGoals();
        BPCommonUtil.logJson('FA Goals: ', [Select Id, Name, BoM_Plan__c, FA__c, BoM_Plan__r.Main_Branch__c From FA_Goal__c]);
    	//system.debug(JSON.serialize(paList));
    	
    	ApexPages.StandardController controller = new ApexPages.StandardController(bomPlan); 
        BPFAActionPlanningCon con = new BPFAActionPlanningCon(controller);
        List<SelectOption> BPGoalItems = con.BPGoalItems;
        pageRef = Page.BPFAActionPlanning;
        pageRef.getParameters().put('id', bomPlan.Id);
        Test.setCurrentPage(pageRef);
        con.createFAActionPlan(); 
        
        BPCommonUtil.logJson('Action Plan: ', [Select Id, Name, FA_Goal__r.Name, FA_Goal__r.RecordTypeId, FA_Goal__r.RecordType.Name From Action_Plan__c]);
        
        for(Action_Plan__c ap : con.actionPlanList) {
        	ap.FA_Goal__r.Primary_Objective__c = '--None--';
        }
        List<Action_Plan__c> actionPlanList = con.actionPlanList;
        ActionPlanElementUtil.createTestActionPlan(2, bomPlan);
        //system.debug('Test >>>>> ' + JSON.serialize(actionPlanList));
        ActionPlanElementUtil.createTestActionPlanElement(3, actionPlanList);
        con.forward();
         for(Action_Plan__c ap : con.actionPlanList) {
        	ap.FA_Goal__r.Primary_Objective__c = ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION;
        }
        con.forward();
    	con.cancel();
        
	}
}