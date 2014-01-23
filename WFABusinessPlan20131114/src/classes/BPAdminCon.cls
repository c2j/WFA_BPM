/**************************************************************************************************
 * Purpose: Controller of the BPAdmin Visualforce Page
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-8
 * Modify History:
 * Keen    2013-11-8    Created
***************************************************************************************************/

public class BPAdminCon {

	//******************* Public Fields *************************************************************
	//List of years to select from
	public list<SelectOption> yearList{get;set;}
	
	//The current selected year
	public String selectedYear{get;set;}
	
	//Error list of Grant Manager Access
	public list<BPAdminUtil.ErrorWarpper> grantErrorList { get;set; }
	
	//Error list of Update User Manager
	public list<BPAdminUtil.ErrorWarpper> updateErrorList { get;set; }
	//******************* End Public Fields *********************************************************
	
	
	
	//******************* Constructor *************************************************************
	public BPAdminCon(){
		init();
	}
	//******************* End Constructor *********************************************************
	
	
	
	//******************* Public Actions *************************************************************
	//Init the year List which is always the existing BoM Plans Year + The next year after the most recent one
	public void init(){
		list<BoM_Plan_Group__c> groupList = BPBranchBusinessPlanUtil.getBoMPlanGroupList();
		yearList = new list<SelectOption>();
		
		for(BoM_Plan_Group__c planGroup : groupList){
			yearList.add(new SelectOption(planGroup.Year__c, planGroup.Year__c + ' - ' + planGroup.Status__c));
		}
		
		//Add the new year to the plan list
		if(groupList.size()>0){
			Integer nYear = Integer.valueOf(groupList[groupList.size() - 1].Year__c);
			nYear = nYear + 1;
			String newYearStr = String.valueOf(nYear);
			yearList.add(new SelectOption(newYearStr, newYearStr + ' - Not Started'));
			//selectedYear = newYearStr;
		}
		else{
			yearList.add(new SelectOption('2013', '2013 - Not Started'));
		}
		
	}
	//Create all the BoM Plans for the selected year
	public PageReference startBoMPlan(){
		
		updateErrorList = null;
		grantErrorList = null;
		//Disable triggers
		BoMPlanTrgHandler.ignoreRollup = true;
		
		BoM_Plan_Group__c planGroup = BPBranchBusinessPlanUtil.createPlanGroup(selectedYear);
		map<Id, BoM_Plan__c> regionPlanMap = BPBranchBusinessPlanUtil.createRegionPlans(selectedYear, planGroup.Id);
		map<Id, BoM_Plan__c> marketPlanMap = BPBranchBusinessPlanUtil.createMarketPlans(selectedYear, planGroup.Id, regionPlanMap);
		map<Id, BoM_Plan__c> subComplexPlanMap = BPBranchBusinessPlanUtil.createSubComplexPlans(selectedYear, planGroup.Id, regionPlanMap, marketPlanMap);
		map<Id, BoM_Plan__c> mainBranchPlanMap = BPBranchBusinessPlanUtil.createMainBranchPlans(selectedYear, planGroup.Id, regionPlanMap, marketPlanMap, subComplexPlanMap);
		
		//Get the keyset of the Plan Id
		set<Id> emptySet = new set<Id>();
		set<Id> complexPlanIdSet = new set<Id>();
		set<Id> marketPlanIdSet = new set<Id>();
		set<Id> regionPlanIdSet = new set<Id>();
		
		for(BoM_Plan__c plan : subComplexPlanMap.values()){
			complexPlanIdSet.add(plan.Id);
		}
		for(BoM_Plan__c plan : marketPlanMap.values()){
			marketPlanIdSet.add(plan.Id);
		}
		for(BoM_Plan__c plan : regionPlanMap.values()){
			regionPlanIdSet.add(plan.Id);
		}
		//Rollup the values by calling functions. Each time, there is only one level of plans
		BoMPlanTrgHandler.rollupParentPlanList(complexPlanIdSet, emptySet, emptySet );
		BoMPlanTrgHandler.rollupParentPlanList(emptySet, marketPlanIdSet, emptySet);
		BoMPlanTrgHandler.rollupParentPlanList(emptySet, emptySet, regionPlanIdSet);
		//system.debug('mainBranchPlanMap JSON: ' + JSON.serialize(mainBranchPlanMap));
		map<Id, Leadership_Plan__c> leadershipPlanMap = BPBranchBusinessPlanUtil.createLeadershipPlans(selectedYear, planGroup.Id,  regionPlanMap, marketPlanMap, subComplexPlanMap, mainBranchPlanMap);

		BPMessageUtil.addInfoMessage('BoM Plan for ' + selectedYear + ' have been created');
		
		init();
		return null;
	}
	//Close the BoM Plans for the selected year
	public PageReference closeBoMPlan(){
		updateErrorList = null;
		grantErrorList = null;
		if(selectedYear == null || selectedYear == ''){
			BPMessageUtil.addInfoMessage('Please select the year first.');
			return null;
		}
		String result = BPBranchBusinessPlanUtil.closeBoMPlans(selectedYear); 
		BPMessageUtil.addInfoMessage(result);
		
		init();
		
		return null;
	}
	//Delete the BoM Plans for the selected year
	public PageReference cleanupBoMPlan(){
		
		updateErrorList = null;
		grantErrorList = null;
		if(selectedYear == null || selectedYear == ''){
			BPMessageUtil.addInfoMessage('Please select the year first.');
			return null;
		}
		String result = BPBranchBusinessPlanUtil.cleanupBoMPlans(selectedYear); 
		BPMessageUtil.addInfoMessage(result);
		
		init();
		
		return null;
	}
	//Grant Manager Access for the selected year
	public PageReference grantManagerAccess() {
		//errorList = new list<BPBranchBusinessPlanUtil.ErrorWarpper>();
		updateErrorList = null;
		if(selectedYear == null || selectedYear == '') {
			BPMessageUtil.addInfoMessage('Please select the year first.');
			return null;
		}
		grantErrorList = BPAdminUtil.updateRecordOwner(selectedYear); 
		BPMessageUtil.addInfoMessage('Manager Access for ' + selectedYear + ' have been granted.');
		
		init();
		
		return null;
	}
	//Update Manager Access for the selected year
	public PageReference updateUserManager() {
		grantErrorList = null;
		updateErrorList = BPAdminUtil.updateUserManager();
		BPMessageUtil.addInfoMessage('User Manager for ' + selectedYear + ' have been updated.');
		/**
		for(String msg : errorList) {
			BPMessageUtil.addInfoMessage(msg);
		}**/
		return null;
	}
	//******************* End Public Actions *************************************************************
	
}