/**************************************************************************************************
 * Purpose: Action Plan Utility
 * Author: PwC (Terry)
 * Create Date (yyyy-MM-dd): 2013-11-18
 * Modify History:
 * Terry    2013-10-28    Created
***************************************************************************************************/
public class ActionPlanUtil {
	
	public static void createNonExistingActionPlan4MainBranch(String mainBranchId, BoM_Plan__c bomPlan){
		//get exist action plan map
		map<Id, Action_Plan__c> existAPMap = getExistingActionPlan(bomPlan);
		//key: FA_Goal__c; value: Action_Plan__c
		map<String, Action_Plan__c> faGoal_ApMap = new map<String, Action_Plan__c>();
		if(existAPMap != null && !existAPMap.isEmpty()) {
			for(Action_Plan__c ap : existAPMap.values()) {
				if(ap.FA_Goal__c != null) {
					faGoal_ApMap.put(ap.FA_Goal__c, ap);
				}		
			}
		}
		//get all Fa Goal by BoM Plan id
		map<Id, FA_Goal__c> faGoalMap = BPBranchBusinessPlanUtil.getFAGoal4BoMPlan(bomPlan.Id);
		
		list<Action_Plan__c> actionPlanList = new list<Action_Plan__c>();
		for(FA_Goal__c fa : faGoalMap.values()) {
			//exclude Recruiting FA Goal
			if(fa.RecordType.Name == 'Recruiting') {
				continue;
			}
			//filter already exist action plan
			if(faGoal_ApMap != null && faGoal_ApMap.containsKey(fa.Id)) continue;
			//
			if(faGoal_ApMap == null || (faGoal_ApMap.containsKey(fa.Id) || fa.FA__c == null)) continue;
			actionPlanList.add(createActionPlan(bomPlan, fa));
		}
    	if(actionPlanList != null) insert actionPlanList;
    }
    //construct action plan
    public static Action_Plan__c createActionPlan(BoM_Plan__c bomPlan, FA_Goal__c fa) {
    	String name = bomPlan.Year_Text__c + ' Action Plan ' + fa.FA__r.Name;
    	Action_Plan__c ap = new Action_Plan__c(Name=name, FA_Goal__c=fa.Id, BoM_Plan__c=bomPlan.Id);
    	ap.OwnerId = bomPlan.OwnerId;
    	return ap;
    } 
    
    //get all action plan map by BoM Plan
    public static Map<Id, Action_Plan__c> getExistingActionPlan(BoM_Plan__c bomPlan) {
    	map<Id, Action_Plan__c> actionPlanMap = new map<Id, Action_Plan__c>([ Select Id
    													, Name
    													, FA_Goal__r.FA__r.Id
    													, FA_Goal__r.FA__r.Account.Id
    													, FA_Goal__r.FA__r.Account.Name
    													, FA_Goal__r.FA__r.Name
    													
    													, FA_Goal__r.BP_Quadrant__c
    													, FA_Goal__r.Primary_Objective__c
    													, FA_Goal__r.Name
    													
    													, FA_Goal__r.Plan_New_Key_HHs__c
    													, FA_Goal__r.Plan_Net_Income__c
    													, FA_Goal__r.Plan_Lending__c
    													, FA_Goal__r.Plan_Advisory_Net_Flows__c
    													
    													, FA_Goal__r.Id
    													, FA_Goal__r.FA_Photo__c
    													, FA_Goal__c
    													, BoM_Plan__r.Name
    													, BoM_Plan__r.Year_Text__c
    													, BoM_Plan__c 
    													From Action_Plan__c
    													Where BoM_Plan__c =: bomPlan.Id
    													order by FA_Goal__r.BP_Quadrant__c asc
    										]);
    	return actionPlanMap;
    }
    //get all action plan list by BoM Plan
    public static list<Action_Plan__c> getExistingActionPlanList(BoM_Plan__c bomPlan) {
    	RecordType rt = [Select Id From RecordType Where Name = 'Master'];
    	String recordtypeId = '';
    	if(rt != null) {
    		recordtypeId = rt.Id;
    	}
    	list<Action_Plan__c> actionPlanList = [Select Id
    													, Name
    													, FA_Goal__r.FA__c
    													, FA_Goal__r.FA__r.Id
    													, FA_Goal__r.FA__r.Account.Id
    													, FA_Goal__r.FA__r.Account.Name
    													, FA_Goal__r.FA__r.Name
    													
    													, FA_Goal__r.BP_Quadrant__c
    													, FA_Goal__r.Primary_Objective__c
    													, FA_Goal__r.Name
    													, FA_Goal__r.Ranking__c
    													, FA_Goal__r.Ranking__r.Focus__c
    													
    													, FA_Goal__r.Plan_New_Key_HHs__c
    													, FA_Goal__r.Plan_Net_Income__c
    													, FA_Goal__r.Plan_Lending__c
    													, FA_Goal__r.Plan_Advisory_Net_Flows__c
    													
    													, FA_Goal__r.Id
    													, FA_Goal__r.FA_Photo__c
    													, FA_Goal__c
    													, BoM_Plan__r.Name
    													, BoM_Plan__r.Year_Text__c
    													, BoM_Plan__c 
    													From Action_Plan__c
    													Where BoM_Plan__c =: bomPlan.Id
    													And FA_Goal__r.RecordTypeId =: recordtypeId
    													order by FA_Goal__r.BP_Quadrant__c asc
    										];
    	return actionPlanList;
    }
    //get all action plan map by BoM Plan id set
    public static Map<Id, Action_Plan__c> getExistingActionPlanByIds(Set<String> actionPlanIdSet) {
    	map<Id, Action_Plan__c> actionPlanMap = new map<Id, Action_Plan__c>([ Select Id
    													, Name
    													, FA_Goal__r.FA__r.Id
    													, FA_Goal__r.FA__r.Name
    													, FA_Goal__r.Name
    													
    													, FA_Goal__r.Id
    													, FA_Goal__c
    													, BoM_Plan__r.Name
    													, BoM_Plan__r.Year_Text__c
    													, BoM_Plan__c 
    													From Action_Plan__c
    													Where Id =: actionPlanIdSet
    										]);
    	return actionPlanMap;
    }
    //splite action plan(or FA) by Primary Objective
    public static List<Action_Plan__c> splitActionPlanMapByPrimaryObjective(Map<Id, Action_Plan__c> actionPlanMap, String primaryObjective) {
    	
    	List<Action_Plan__c> tabCustomerTableList = new List<Action_Plan__c>();
    	for(Action_Plan__c ap : actionPlanMap.values()) {
			if(ap.FA_Goal__c != null && ap.FA_Goal__r.Primary_Objective__c != null) { 
				if(ap.FA_Goal__r.Primary_Objective__c == primaryObjective) {
					tabCustomerTableList.add(ap);
				}
			}
			
    	}
    	return tabCustomerTableList;
    	/**
    	List<Action_Plan__c> firstTabCustomerTableList = new List<Action_Plan__c>();
	
		List<Action_Plan__c> secondTabCustomerTableList = new List<Action_Plan__c>(); 
	
		List<Action_Plan__c> thirdTabCustomerTableList = new List<Action_Plan__c>();
	
		List<Action_Plan__c> fourthTabCustomerTableList = new List<Action_Plan__c>();
    	for(Action_Plan__c ap : actionPlanMap.values()) {
			if(ap.FA_Goal__c != null && ap.FA_Goal__r.Primary_Objective__c != null) { 
				if(ap.FA_Goal__r.Primary_Objective__c == ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION) {
					firstTabCustomerTableList.add(ap);
				}
				if(ap.FA_Goal__r.Primary_Objective__c == ActionPlanElementUtil.ENHANCE_CLIENT_SERVICE) {
					secondTabCustomerTableList.add(ap);
				}
				if(ap.FA_Goal__r.Primary_Objective__c == ActionPlanElementUtil.COMPREHENSIVE_WEALTH_MANAGEMENT) {
					thirdTabCustomerTableList.add(ap);
				}
				if(ap.FA_Goal__r.Primary_Objective__c == ActionPlanElementUtil.OPTIMIZE_PRACTICE) {
					fourthTabCustomerTableList.add(ap);
				}
			}
			
    	}
		if(primaryObjective == ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION) {
			return firstTabCustomerTableList;
		}
		if(primaryObjective == ActionPlanElementUtil.ENHANCE_CLIENT_SERVICE) {
			return secondTabCustomerTableList;
		}
		if(primaryObjective == ActionPlanElementUtil.COMPREHENSIVE_WEALTH_MANAGEMENT) {
			return thirdTabCustomerTableList;
		}
		if(primaryObjective == ActionPlanElementUtil.OPTIMIZE_PRACTICE) {
			return fourthTabCustomerTableList;
		}
    	return null;
    	**/
    }
    
}