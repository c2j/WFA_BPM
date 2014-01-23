/**************************************************************************************************
 * Purpose: Controller of the BPActionPlanElement Visualforce Page
 * Author: PwC (Terry)
 * Create Date (yyyy-MM-dd): 2013-11-18
 * Modify History:
 * Terry    2013-11-18   Created
***************************************************************************************************/
public class BPActionPlanElementCon {
	
	public String msgStr { get;set; }
	
	public BoM_Plan__c bomPlan { get;set; }
	
	/**
	public String firstTabDescription { get;set; }
	
	public String secondTabDescription { get;set; }
	
	public String thirdTabDescription { get;set; }
	
	public String fourthTabDescription { get;set; }
	
	public String fifthTabDescription { get;set; }
	**/
	public List<ActionPlanElementUtil.ObjectWrapper> firstTabWrapperList { get;set; } 
	
	public List<ActionPlanElementUtil.ObjectWrapper> secondTabWrapperList { get;set; }
	
	public List<ActionPlanElementUtil.ObjectWrapper> thirdTabWrapperList { get;set; }
	
	public List<ActionPlanElementUtil.ObjectWrapper> fourthTabWrapperList { get;set; }
	
	public List<ActionPlanElementUtil.ObjectWrapper> fifthTabWrapperList { get;set; }
	
	public List<Action_Plan__c> firstTabCustomerTableList { get;set; }
	
	public List<Action_Plan__c> secondTabCustomerTableList { get;set; }
	
	public List<Action_Plan__c> thirdTabCustomerTableList { get;set; }
	
	public List<Action_Plan__c> fourthTabCustomerTableList { get;set; }
	
	public List<Action_Plan__c> fifthTabCustomerTableList { get;set; }
	
	public list<ActionPlanElementUtil.CustomActivityWrapper> firstTabCustomActivityList { get;set; }
	
	public list<ActionPlanElementUtil.CustomActivityWrapper> secondTabCustomActivityList { get;set; }
	
	public list<ActionPlanElementUtil.CustomActivityWrapper> thirdTabCustomActivityList { get;set; }
	
	public list<ActionPlanElementUtil.CustomActivityWrapper> fourthTabCustomActivityList { get;set; }
	
	public list<ActionPlanElementUtil.CustomActivityWrapper> fifthTabCustomActivityList { get;set; }
	
	public Map<Id, Action_Plan__c> actionPlanMap { get;set; }
	
	public list<String> primaryGoalList { get;set; }
	
	public String tabIndex { get;set; }
	
	public Integer deleteIndex { get;set; }
	
	public BPActionPlanElementCon() {
		String bomPlanId = ApexPages.currentPage().getParameters().get('pid');
        if(bomPlanId == null || bomPlanId == '') {
            msgStr = 'Invalid BoM Plan Id.';
            BPMessageUtil.addInfoMessage(msgStr);
        }else {
            bomPlan = BPBranchBusinessPlanUtil.getBoMPlanById(bomPlanId);
            system.debug('***bomPlan: ' + bomPlan);
        }
	}
	
	public void init() {
		//list<Plan_Activity__c> generalList = ActionPlanElementUtil.getPlanActivityTypeIsAll('All');
		//list<ActionPlanElementUtil.PlanActivityWrapper> generalWrapperList =  ActionPlanElementUtil.buildGeneralPrimaryObjectiveList(generalList); 
		
		primaryGoalList = ActionPlanElementUtil.getPrimaryGoalItems();
		//get all plan activity, group by Primary Objective field
		map<String, map<String, List<ActionPlanElementUtil.PlanActivityWrapper>>> BPGoal_PlanActivityMap = ActionPlanElementUtil.groupPlanActivityByBPGoal();
		//get first tab plan activity
		firstTabWrapperList = ActionPlanElementUtil.spliteMap(BPGoal_PlanActivityMap, primaryGoalList[0]); 
		//get second tab plan activity
		secondTabWrapperList = ActionPlanElementUtil.spliteMap(BPGoal_PlanActivityMap, primaryGoalList[1]);
		//get third tab plan activity
		thirdTabWrapperList = ActionPlanElementUtil.spliteMap(BPGoal_PlanActivityMap, primaryGoalList[2]);
		//get fourth tab plan activity
		fourthTabWrapperList = ActionPlanElementUtil.spliteMap(BPGoal_PlanActivityMap, primaryGoalList[3]);
		//get fifth tab plan activity
		fifthTabWrapperList = ActionPlanElementUtil.spliteMap(BPGoal_PlanActivityMap, primaryGoalList[4]);
		//get tab customer tables
		actionPlanMap = ActionPlanUtil.getExistingActionPlan(bomPlan);
		//first tab customer table
		firstTabCustomerTableList = ActionPlanUtil.splitActionPlanMapByPrimaryObjective(actionPlanMap, primaryGoalList[0]);
		//second tab customer table
		secondTabCustomerTableList = ActionPlanUtil.splitActionPlanMapByPrimaryObjective(actionPlanMap, primaryGoalList[1]);
		//third tab customer table
		thirdTabCustomerTableList = ActionPlanUtil.splitActionPlanMapByPrimaryObjective(actionPlanMap, primaryGoalList[2]);
		//fourth tab customer table
		fourthTabCustomerTableList = ActionPlanUtil.splitActionPlanMapByPrimaryObjective(actionPlanMap, primaryGoalList[3]);
		//fourth tab customer table
		fifthTabCustomerTableList = ActionPlanUtil.splitActionPlanMapByPrimaryObjective(actionPlanMap, primaryGoalList[4]);
		
		firstTabCustomActivityList = ActionPlanElementUtil.getDefaultCustomActivityWrapper('0');
		secondTabCustomActivityList = ActionPlanElementUtil.getDefaultCustomActivityWrapper('1');
		thirdTabCustomActivityList = ActionPlanElementUtil.getDefaultCustomActivityWrapper('2');
		fourthTabCustomActivityList = ActionPlanElementUtil.getDefaultCustomActivityWrapper('3');
		fifthTabCustomActivityList = ActionPlanElementUtil.getDefaultCustomActivityWrapper('4');
	}
	//save action plan element for action plan
	public PageReference save() {
		boolean flag = false;
		if(bomPlan.Action_Plan_Completed__c) {
			flag = false;
		}else {
			flag = ActionPlanElementUtil.validate(firstTabCustomerTableList, firstTabWrapperList, firstTabCustomActivityList 
														, secondTabCustomerTableList, secondTabWrapperList, secondTabCustomActivityList
														, thirdTabCustomerTableList, thirdTabWrapperList, thirdTabCustomActivityList
														, fourthTabCustomerTableList, fourthTabWrapperList, fourthTabCustomActivityList
														, fifthTabCustomerTableList, fifthTabWrapperList, fifthTabCustomActivityList);
		}
		if(flag) {
			msgStr = 'Please select at least one plan activity for each FA Goal';
            BPMessageUtil.addInfoMessage(msgStr);
            return null;
		}
		Set<String> allActionPlanIDSet = new Set<String>();
		allActionPlanIDSet.addAll(ActionPlanElementUtil.getIDSetFromList(firstTabCustomerTableList));
		allActionPlanIDSet.addAll(ActionPlanElementUtil.getIDSetFromList(secondTabCustomerTableList));
		allActionPlanIDSet.addAll(ActionPlanElementUtil.getIDSetFromList(thirdTabCustomerTableList));
		allActionPlanIDSet.addAll(ActionPlanElementUtil.getIDSetFromList(fourthTabCustomerTableList));
		allActionPlanIDSet.addAll(ActionPlanElementUtil.getIDSetFromList(fifthTabCustomerTableList));
		list<Action_Plan_Element__c> allPageApeList = ActionPlanElementUtil.getActionPlanElementByActionPlan(allActionPlanIDSet);
		
		Map<Id, sObject> recordtypeMap = BPQueryUtil.queryMap(null, 'RecordType', 'Name=\''+ActionPlanElementUtil.COMMON_PLAN+'\'', null);
    	RecordType recordtype = (RecordType)recordtypeMap.values()[0];
		list<Action_Plan_Element__c> tabFirstAPElementList = ActionPlanElementUtil.createActionPlanElement(firstTabCustomerTableList, firstTabWrapperList, recordtype, allPageApeList, actionPlanMap);
		list<Action_Plan_Element__c> tabSecondAPElementList = ActionPlanElementUtil.createActionPlanElement(secondTabCustomerTableList, secondTabWrapperList, recordtype, allPageApeList, actionPlanMap);
		list<Action_Plan_Element__c> tabThirdAPElementList = ActionPlanElementUtil.createActionPlanElement(thirdTabCustomerTableList, thirdTabWrapperList, recordtype, allPageApeList, actionPlanMap);
		list<Action_Plan_Element__c> tabFourthAPElementList = ActionPlanElementUtil.createActionPlanElement(fourthTabCustomerTableList, fourthTabWrapperList, recordtype, allPageApeList, actionPlanMap);
		list<Action_Plan_Element__c> tabfifthAPElementList = ActionPlanElementUtil.createActionPlanElement(fifthTabCustomerTableList, fifthTabWrapperList, recordtype, allPageApeList, actionPlanMap);
		
    	list<Action_Plan_Element__c> allInsertAPEList = new list<Action_Plan_Element__c>();
		if(tabFirstAPElementList != null) allInsertAPEList.addAll(tabFirstAPElementList);
		if(tabSecondAPElementList != null) allInsertAPEList.addAll(tabSecondAPElementList);
		if(tabThirdAPElementList != null) allInsertAPEList.addAll(tabThirdAPElementList);
		if(tabFourthAPElementList != null) allInsertAPEList.addAll(tabFourthAPElementList);
		if(tabfifthAPElementList != null) allInsertAPEList.addAll(tabfifthAPElementList);
		//system.debug('allAPEList ==--->>>>>   ' + JSON.serialize(allAPEList));
		
		//create special action plan element
		Map<Id, sObject> specialRecordtypeMap = BPQueryUtil.queryMap(null, 'RecordType', 'Name=\''+ActionPlanElementUtil.CUSTOM_PLAN+'\'', null);
    	RecordType specialRecordtype = (RecordType)specialRecordtypeMap.values()[0];
		list<Action_Plan_Element__c> allSpecialAPEList = new list<Action_Plan_Element__c>();
		/**
		list<Action_Plan_Element__c> tabFirstSpecialAPElementList = ActionPlanElementUtil.createSpecialActionPlanElement(firstTabCustomerTableList, specialRecordtype, firstTabDescription, actionPlanMap);
		list<Action_Plan_Element__c> tabSecondSpecialAPElementList = ActionPlanElementUtil.createSpecialActionPlanElement(secondTabCustomerTableList, specialRecordtype, secondTabDescription, actionPlanMap);
		list<Action_Plan_Element__c> tabThirdSpecialAPElementList = ActionPlanElementUtil.createSpecialActionPlanElement(thirdTabCustomerTableList, specialRecordtype, thirdTabDescription, actionPlanMap);
		list<Action_Plan_Element__c> tabFourthSpecialAPElementList = ActionPlanElementUtil.createSpecialActionPlanElement(fourthTabCustomerTableList, specialRecordtype, fourthTabDescription, actionPlanMap);
		list<Action_Plan_Element__c> tabfifthSpecialAPElementList = ActionPlanElementUtil.createSpecialActionPlanElement(fifthTabCustomerTableList, specialRecordtype, fifthTabDescription, actionPlanMap);
		//system.debug(JSON.serialize(tabFirstSpecialAPElementList));
		if(tabFirstSpecialAPElementList != null) allSpecialAPEList.addAll(tabFirstSpecialAPElementList);
		if(tabSecondSpecialAPElementList != null) allSpecialAPEList.addAll(tabSecondSpecialAPElementList);
		if(tabThirdSpecialAPElementList != null) allSpecialAPEList.addAll(tabThirdSpecialAPElementList);
		if(tabFourthSpecialAPElementList != null) allSpecialAPEList.addAll(tabFourthSpecialAPElementList);
		if(tabfifthSpecialAPElementList != null) allSpecialAPEList.addAll(tabfifthSpecialAPElementList);
		insert allSpecialAPEList;
		**/
		//system.debug('firstTabCustomActivityList ===>>>>    ' + JSON.serialize(firstTabCustomActivityList));
		//system.debug('secondTabCustomActivityList ===>>>>    ' + JSON.serialize(secondTabCustomActivityList));
		map<String, Set<String>> actionPlanID_ApeMap = ActionPlanElementUtil.getCustomActionPlanElementByActionPlans(allActionPlanIDSet); 
		//get first tab custom action plan element
		list<Action_Plan_Element__c> tabFirstSpecialAPElementList = ActionPlanElementUtil.createCustomActionPlanElement(firstTabCustomerTableList, specialRecordtype, actionPlanID_ApeMap, actionPlanMap, firstTabCustomActivityList);
		//get second tab custom action plan element
		list<Action_Plan_Element__c> tabSecondSpecialAPElementList = ActionPlanElementUtil.createCustomActionPlanElement(secondTabCustomerTableList, specialRecordtype, actionPlanID_ApeMap, actionPlanMap, secondTabCustomActivityList);
		//get third tab custom action plan element
		list<Action_Plan_Element__c> tabThirdSpecialAPElementList = ActionPlanElementUtil.createCustomActionPlanElement(thirdTabCustomerTableList, specialRecordtype, actionPlanID_ApeMap, actionPlanMap, thirdTabCustomActivityList);
		//get fourth tab custom action plan element
		list<Action_Plan_Element__c> tabFourthSpecialAPElementList = ActionPlanElementUtil.createCustomActionPlanElement(fourthTabCustomerTableList, specialRecordtype, actionPlanID_ApeMap, actionPlanMap, fourthTabCustomActivityList);
		//get fifth tab custom action plan element
		list<Action_Plan_Element__c> tabfifthSpecialAPElementList = ActionPlanElementUtil.createCustomActionPlanElement(fifthTabCustomerTableList, specialRecordtype, actionPlanID_ApeMap, actionPlanMap, fifthTabCustomActivityList);
		//system.debug(JSON.serialize(tabFirstSpecialAPElementList));
		//add first tab custom action plan element
		if(tabFirstSpecialAPElementList != null) allSpecialAPEList.addAll(tabFirstSpecialAPElementList);
		//add second tab custom action plan element
		if(tabSecondSpecialAPElementList != null) allSpecialAPEList.addAll(tabSecondSpecialAPElementList);
		//add third tab custom action plan element
		if(tabThirdSpecialAPElementList != null) allSpecialAPEList.addAll(tabThirdSpecialAPElementList);
		//add fourth tab custom action plan element
		if(tabFourthSpecialAPElementList != null) allSpecialAPEList.addAll(tabFourthSpecialAPElementList);
		//add fifth tab custom action plan element
		if(tabfifthSpecialAPElementList != null) allSpecialAPEList.addAll(tabfifthSpecialAPElementList);
		
		insert allSpecialAPEList;
		insert allInsertAPEList;
		
		//Update indicator on BoM Plan that the action plan has been completed
		bomPlan.Action_Plan_Completed__c = true;
		update bomPlan;
		
		//clear();
		disableInputText();
		//PageReference prf = Page.bpactionplanelement;
		//prf.getParameters().put('pid', bomPlan.Id);
		BPMessageUtil.addInfoMessage('Action Plan elements have been saved');
		return null; 
	}
	//disable already exist rows after click save button
	public void disableInputText() {
		list<ActionPlanElementUtil.CustomActivityWrapper> allPageCustomActivityWrapper = new list<ActionPlanElementUtil.CustomActivityWrapper>();
		if(firstTabCustomActivityList != null) allPageCustomActivityWrapper.addAll(firstTabCustomActivityList);
		if(secondTabCustomActivityList != null) allPageCustomActivityWrapper.addAll(secondTabCustomActivityList);
		if(thirdTabCustomActivityList != null) allPageCustomActivityWrapper.addAll(thirdTabCustomActivityList);
		if(fourthTabCustomActivityList != null) allPageCustomActivityWrapper.addAll(fourthTabCustomActivityList);
		if(fifthTabCustomActivityList != null) allPageCustomActivityWrapper.addAll(fifthTabCustomActivityList);
		for(ActionPlanElementUtil.CustomActivityWrapper wrapper : allPageCustomActivityWrapper) {
			if(wrapper.description == null || wrapper.description == '' ) continue;
			wrapper.disabled = true;
		}
		firstTabCustomActivityList.sort();
		secondTabCustomActivityList.sort();
		thirdTabCustomActivityList.sort();
		fourthTabCustomActivityList.sort();
		fifthTabCustomActivityList.sort();
		
	}
	
	public PageReference deleteRow() {
		//which tab's row will be remove
		if(tabIndex == '0') {
			removeRow(firstTabCustomActivityList);
		}else if(tabIndex == '1') {
			removeRow(secondTabCustomActivityList);
		}else if(tabIndex == '2') {
			removeRow(thirdTabCustomActivityList);
		}else if(tabIndex == '3') {
			removeRow(fourthTabCustomActivityList);
		}else if(tabIndex == '4') {
			removeRow(fifthTabCustomActivityList);
		}
		return null;
	}
	//remove row from vf page
	public void removeRow(list<ActionPlanElementUtil.CustomActivityWrapper> selectedTabCustomActivityList) {
		if(selectedTabCustomActivityList.size() == 1) {
			return;
		}
		Integer tmpIndex = 0;
		//calculate which row will be remove
		for(Integer i=0; i<selectedTabCustomActivityList.size(); i++) {
			ActionPlanElementUtil.CustomActivityWrapper wrapper = selectedTabCustomActivityList.get(i);
			if(wrapper.index == deleteIndex) {
				tmpIndex = i;
				break;
			}
		}
		selectedTabCustomActivityList.remove(tmpIndex);
	}
	//add row for vf display
	public PageReference addRow() {
		if(tabIndex == '0') {
			Integer size = firstTabCustomActivityList.size();
			//ActionPlanElementUtil.CustomActivityWrapper wrapper = new ActionPlanElementUtil.CustomActivityWrapper(size+1, tabIndex, '', false);
			ActionPlanElementUtil.CustomActivityWrapper wrapper = ActionPlanElementUtil.createDefaultCustomActivityWrapper(size, tabIndex, '', false);
			firstTabCustomActivityList.add(wrapper);
		}else if(tabIndex == '1') {
			Integer size = secondTabCustomActivityList.size();
			ActionPlanElementUtil.CustomActivityWrapper wrapper = ActionPlanElementUtil.createDefaultCustomActivityWrapper(size, tabIndex, '', false);
			secondTabCustomActivityList.add(wrapper);
		}else if(tabIndex == '2') {
			Integer size = thirdTabCustomActivityList.size();
			ActionPlanElementUtil.CustomActivityWrapper wrapper = ActionPlanElementUtil.createDefaultCustomActivityWrapper(size, tabIndex, '', false);
			thirdTabCustomActivityList.add(wrapper);
		}else if(tabIndex == '3') {
			Integer size = fourthTabCustomActivityList.size();
			ActionPlanElementUtil.CustomActivityWrapper wrapper = ActionPlanElementUtil.createDefaultCustomActivityWrapper(size, tabIndex, '', false);
			fourthTabCustomActivityList.add(wrapper);
		}else if(tabIndex == '4') {
			Integer size = fifthTabCustomActivityList.size();
			ActionPlanElementUtil.CustomActivityWrapper wrapper = ActionPlanElementUtil.createDefaultCustomActivityWrapper(size, tabIndex, '', false);
			fifthTabCustomActivityList.add(wrapper);
		}
		
		return null;
	}
	/*
	private void clear() {
		firstTabDescription = '';
		secondTabDescription = '';
		thirdTabDescription = '';
		fourthTabDescription = '';
		fifthTabDescription = '';
	}
	*/
	public PageReference back() {
		//id=a3NW00000000HAz
		if(bomPlan != null) {
			PageReference pRef = Page.BPFAActionPlanning;
        	pRef.getParameters().put('id', bomPlan.Id);
			return pRef;
		}else {
			return null;
		}
	}
	
	public PageReference cancel() {
		if(bomPlan != null) {
			PageReference pRef = new PageReference('/' + bomPlan.Id);
			return pRef;
		}else {
			return null;
		}
	}
}