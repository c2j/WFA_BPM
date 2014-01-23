/**************************************************************************************************
 * Purpose: FA_Goal Utility
 * Author: PwC (Terry)
 * Create Date (yyyy-MM-dd): 2013-11-07
 * Modify History:
 * Terry    2013-11-07    Created
***************************************************************************************************/
public class FAGoalUtil {
	
	//update bom plan
	public static void processAfterTrg(map<Id, FA_Goal__c> newMap, map<Id, FA_Goal__c> oldMap) { 
		//for insert
		if(trigger.isInsert) {
			list<FA_Goal__c> FAGoalList = trigger.new;
			list<Id> bomPlanIdList = new List<Id>();
			for(FA_Goal__c f : FAGoalList) {
				bomPlanIdList.add(f.BoM_Plan__c);
			}
			Map<Id, BoM_Plan__c> toUpdateBoMPlanMap = getBoMPlanMap(bomPlanIdList);
			for(AggregateResult ar : getFAGoalAggregateResult(bomPlanIdList)) {
				getUpdateBomPlanMap(ar, toUpdateBoMPlanMap);
			}
			update toUpdateBoMPlanMap.values();
		}
		//for update
		if(trigger.isUpdate) {
			list<FA_Goal__c> oldFAGoalList = new list<FA_Goal__c>();
			//update old BomPlan base on the below fields change
			for(FA_Goal__c fa : newMap.values()) {
				if(fa.Plan_New_Key_HHs__c != oldMap.get(fa.Id).Plan_New_Key_HHs__c
					|| fa.YTD_New_Key_HHs__c != oldMap.get(fa.Id).YTD_New_Key_HHs__c
					|| fa.Annualized_New_Key_HHs__c != oldMap.get(fa.Id).Annualized_New_Key_HHs__c
					
					|| fa.Prior_Advisory_Net_Flows__c != oldMap.get(fa.Id).Prior_Advisory_Net_Flows__c
					|| fa.Plan_Advisory_Net_Flows__c != oldMap.get(fa.Id).Plan_Advisory_Net_Flows__c
					|| fa.YTD_Advisory_Net_Flows__c != oldMap.get(fa.Id).YTD_Advisory_Net_Flows__c
					|| fa.Annualized_Advisory_Net_Flows__c != oldMap.get(fa.Id).Annualized_Advisory_Net_Flows__c
					
					|| fa.Prior_Lending__c != oldMap.get(fa.Id).Prior_Lending__c
					|| fa.Plan_Lending__c != oldMap.get(fa.Id).Plan_Lending__c
					|| fa.YTD_Lending__c != oldMap.get(fa.Id).YTD_Lending__c
					|| fa.Annualized_Lending__c != oldMap.get(fa.Id).Annualized_Lending__c
					|| fa.Prior_Net_Income__c != oldMap.get(fa.Id).Prior_Net_Income__c
					|| fa.Plan_Net_Income__c != oldMap.get(fa.Id).Plan_Net_Income__c
					|| fa.YTD_Net_Income__c != oldMap.get(fa.Id).YTD_Net_Income__c
					|| fa.Annualized_Net_Income__c != oldMap.get(fa.Id).Annualized_Net_Income__c
					|| fa.FA_Goal_New_Key_HHs__c != oldMap.get(fa.Id).FA_Goal_New_Key_HHs__c
					|| fa.FA_Goal_Advisory_Net_Flows__c != oldMap.get(fa.Id).FA_Goal_Advisory_Net_Flows__c
					
					|| fa.FA_Goal_Lending__c != oldMap.get(fa.Id).FA_Goal_Lending__c
					|| fa.FA_Goal_Net_Income__c != oldMap.get(fa.Id).FA_Goal_Net_Income__c
					|| fa.Projected_Growth__c != oldMap.get(fa.Id).Projected_Growth__c
				) {
					oldFAGoalList.add(fa);
				}
			}
			if(oldFAGoalList != null && oldFAGoalList.size() > 0) {
				//list<FA_Goal__c> oldFAGoalList = trigger.old;
				list<Id> oldBomPlanIdList = new List<Id>();
				for(FA_Goal__c f : oldFAGoalList) {
					oldBomPlanIdList.add(f.BoM_Plan__c);
				}
				//Map<Id, BoM_Plan__c> oldToUpdateBoMPlanMap = getBoMPlanMap(bomPlanIdList);
				Map<Id, BoM_Plan__c> oldToUpdateBoMPlanMap = getBoMPlanMap(oldBomPlanIdList);
				for(AggregateResult ar : getFAGoalAggregateResult(oldBomPlanIdList)) {
					getUpdateBomPlanMap(ar, oldToUpdateBoMPlanMap);
				}
				if(oldToUpdateBoMPlanMap != null && oldToUpdateBoMPlanMap.size() > 0) update oldToUpdateBoMPlanMap.values();
			}
		}
		
	}
	
	//prepare bom plan update data
	public static void getUpdateBomPlanMap(AggregateResult ar, Map<Id, BoM_Plan__c> toUpdateBoMPlanMap) {
		long prior = 0, plan = 0, ytd = 0, annual = 0
				  , advisoryPrior = 0, advisoryPlan = 0, advisoryYtd = 0, advisoryAnnual = 0
				  , lendingPrior = 0, lendingPlan = 0, lendingYtd = 0, lendingAnnual = 0
				  , projectedGrowth = 0
				  ;
			//New Key HHs
			if(ar.get('prior') != null && ar.get('prior') != '') prior = BPCommonUtil.fromatString2Long(ar.get('prior')+'');
			if(ar.get('plan') != null && ar.get('plan') != '') plan = BPCommonUtil.fromatString2Long(ar.get('plan')+'');
			if(ar.get('ytd') != null && ar.get('ytd') != '') ytd = BPCommonUtil.fromatString2Long(ar.get('ytd')+'');
			if(ar.get('annual') != null && ar.get('annual') != '') annual = BPCommonUtil.fromatString2Long(ar.get('annual')+'');
			//Advisory
			if(ar.get('advisoryPrior') != null && ar.get('advisoryPrior') != '') advisoryPrior = BPCommonUtil.fromatString2Long(ar.get('advisoryPrior')+'');
			if(ar.get('advisoryPlan') != null && ar.get('advisoryPlan') != '') advisoryPlan = BPCommonUtil.fromatString2Long(ar.get('advisoryPlan')+'');
			if(ar.get('advisoryYtd') != null && ar.get('advisoryYtd') != '') advisoryYtd = BPCommonUtil.fromatString2Long(ar.get('advisoryYtd')+'');
			if(ar.get('advisoryAnnual') != null && ar.get('advisoryAnnual') != '') advisoryAnnual = BPCommonUtil.fromatString2Long(ar.get('advisoryAnnual')+'');
			//Lending
			if(ar.get('lendingPrior') != null && ar.get('lendingPrior') != '') lendingPrior = BPCommonUtil.fromatString2Long(ar.get('lendingPrior')+'');
			if(ar.get('lendingPlan') != null && ar.get('lendingPlan') != '') lendingPlan = BPCommonUtil.fromatString2Long(ar.get('lendingPlan')+'');
			if(ar.get('lendingYtd') != null && ar.get('lendingYtd') != '') lendingYtd = BPCommonUtil.fromatString2Long(ar.get('lendingYtd')+'');
			if(ar.get('lendingAnnual') != null && ar.get('lendingAnnual') != '') lendingAnnual = BPCommonUtil.fromatString2Long(ar.get('lendingAnnual')+'');
			//Net Income
			if(ar.get('projectedGrowth') != null && ar.get('projectedGrowth') != '') projectedGrowth = BPCommonUtil.fromatString2Long(ar.get('projectedGrowth')+'');//same as Total Revenue
			
			String bomPlanId = ar.get('BoM_Plan__c') + '';
			if(bomPlanId != null && bomPlanId != '' && toUpdateBoMPlanMap.containsKey(bomPlanId)) {
				BoM_Plan__c bomPlan = toUpdateBoMPlanMap.get(bomPlanId);
				//New Key HHs
				bomPlan.Prior_New_Key_HHs__c = prior;
				bomPlan.Plan_New_Key_HHs_Rollup__c = plan;
				bomPlan.YTD_New_Key_HHs__c = ytd;
				bomPlan.Annualized_New_Key_HHs__c = annual;
				//Advisory
				bomPlan.Prior_Advisory_Net_Flows__c = advisoryPrior;
				bomPlan.Plan_Advisory_Net_Flows_Rollup__c = advisoryPlan;
				bomPlan.YTD_Advisory_Net_Flows__c = advisoryYtd;
				bomPlan.Annualized_Advisory_Net_Flows__c = advisoryAnnual;
				//Lending
				bomPlan.Prior_Lending__c = lendingPrior;
				bomPlan.Plan_Lending_Rollup__c = lendingPlan;
				bomPlan.YTD_Lending__c = lendingYtd;
				bomPlan.Annualized_Lending__c = lendingAnnual;
				//Net Income
				bomPlan.Plan_Revenue__c = projectedGrowth; //same as Total Revenue
			}
	}
	
	//get rollup data for update bom plan
	public static AggregateResult[] getFAGoalAggregateResult(List<Id> bomPlanIdList) {
		AggregateResult[] groupedResults = [Select sum(Prior_New_Key_HHs__c) prior
												 , sum(Plan_New_Key_HHs__c) plan
												 , sum(YTD_New_Key_HHs__c) ytd
												 , sum(Annualized_New_Key_HHs__c) annual
												 
												 , sum(Prior_Advisory_Net_Flows__c) advisoryPrior
												 , sum(Plan_Advisory_Net_Flows__c) advisoryPlan
												 , sum(YTD_Advisory_Net_Flows__c) advisoryYtd
												 , sum(Annualized_Advisory_Net_Flows__c) advisoryAnnual
												 
												 , sum(Prior_Lending__c) lendingPrior
												 , sum(Plan_Lending__c) lendingPlan
												 , sum(YTD_Lending__c) lendingYtd
												 , sum(Annualized_Lending__c) lendingAnnual
												 
												 , sum(Prior_Net_Income__c) incomePrior
												 , sum(Plan_Net_Income__c) incomePlan
												 , sum(YTD_Net_Income__c) incomeYtd
												 , sum(Annualized_Net_Income__c) incomeAnnual
												 
												 , sum(FA_Goal_New_Key_HHs__c) FAGoalNewKeyHHs
												 , sum(FA_Goal_Advisory_Net_Flows__c) FAGoalAdvisory
												 , sum(FA_Goal_Lending__c) FAGoalLending
												 , sum(FA_Goal_Net_Income__c) FAGoalNetIncome
												 
												 , sum(Projected_Growth__c) projectedGrowth //same as Total Revenue
												 , BoM_Plan__c  
												 From FA_Goal__c 
												 Where BoM_Plan__c IN : bomPlanIdList
												 GROUP BY BoM_Plan__c
											];
		return groupedResults;
	}
	
	//get Bom Plan map by id list
	public static Map<Id, BoM_Plan__c> getBoMPlanMap(list<Id> bomPlanIdList){
    	Map<Id, sObject> sObjMap = BPQueryUtil.queryMap(bomPlanIdList, 'BoM_Plan__c', null, 'Name'); 
    	Map<Id, BoM_Plan__c> bomPlanMap = new Map<Id, BoM_Plan__c>();
    	bomPlanMap.putAll((List<BoM_Plan__c>)sObjMap.values());
    	return bomPlanMap;
    }
    //****************************** Start Testing ********************************************************************
    public static list<FA_Goal__c> getSampleFAGoalList(Integer nCount, BoM_Plan__c plan, Contact fa){
		
		list<FA_Goal__c> faGoalList = new list<FA_Goal__c>();
		FA_Goal__c goal;
		
		Integer maxCount = nCount;
		for(Integer i = 0; i<=maxCount; i++){
			goal = new FA_Goal__c();
			goal.Name = 'FA Goal' + i;
			goal.Primary_Objective__c = ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION;
			goal.BoM_Plan__c = plan.Id;
			goal.FA__c = fa.Id;
			faGoalList.add(goal);
		}
		
		return faGoalList;
	}
	//****************************** End Testing ********************************************************************
}