global class ActionPlanElementUtil {
	
	public static final String ALL = 'All'; 
	
	//public static final String CLIENT_AND_ASSET_ACQUISTION = 'Client and Asset Acquisition';
	
	public static final String CLIENT_AND_ASSET_ACQUISTION = 'Growth';
	
	public static final String ENHANCE_CLIENT_SERVICE = 'Enhance Client Service';
	
	public static final String COMPREHENSIVE_WEALTH_MANAGEMENT = 'Comprehensive Wealth Management';
	
	public static final String OPTIMIZE_PRACTICE = 'Optimize Practice';
	
	public static final String OTHER = 'Other';
	
	public static final String CUSTOM_PLAN = 'Custom Plan';
	
	public static final String COMMON_PLAN = 'Common Plan';
	
	//get Plan Activity by Primary Objective field
	public static list<Plan_Activity__c> getPlanActivityTypeIsAll(String primaryObjective) {
		list<Plan_Activity__c> paList = [Select Name
										, Description__c
										, Category__c
										, Primary_Objective__c 
										From Plan_Activity__c
										Where Primary_Objective__c =: primaryObjective
										And Category__c != null
										And Active__c = true
										order by Category__c
										];
	
		return paList;
	}
	/**
	public static list<Plan_Activity__c> getPlanActivityByBPGoal(Set<String> bpGoalSet) {
		list<Plan_Activity__c> paList = [Select Name
										, Description__c
										, Category__c
										, Primary_Objective__c 
										From Plan_Activity__c
										Where Primary_Objective__c IN: bpGoalSet
										And Active__c = true
										order by Primary_Objective__c
										];
	
		return paList;
	}
	
	public static map<Id, Plan_Activity__c> getPlanActivityMapByBPGoal(Set<String> bpGoalSet) {
		map<Id, Plan_Activity__c> paMap = new map<Id, Plan_Activity__c>([Select 
											  Id
											, Name
											, Description__c
											, Category__c
											, Primary_Objective__c 
											From Plan_Activity__c
											Where Primary_Objective__c IN: bpGoalSet
											And Active__c = true
											order by Primary_Objective__c
										 ]);
	
		return paMap;
	}
	*/
	// get Action Plan Element by Action Plan id Set
	public static list<Action_Plan_Element__c> getActionPlanElementByActionPlan(Set<String> actionPlanIdSet) {
		list<Action_Plan_Element__c> apeList = [Select Id
												, Plan_Activity__r.Primary_Objective__c
												, Plan_Activity__c
												, Action_Plan__c 
												From Action_Plan_Element__c 
												Where Action_Plan__c IN:actionPlanIdSet];
		return apeList;
	}
	//filter action plan element by action plan id
	public static list<Action_Plan_Element__c> filterActionPlanElementFromCollection(Set<String> actionPlanIdSet, list<Action_Plan_Element__c> allApeList) {
		list<Action_Plan_Element__c> subApeList = new list<Action_Plan_Element__c>();
		for(Action_Plan_Element__c ape: allApeList) {
			if(actionPlanIdSet != null && actionPlanIdSet.contains(ape.Action_Plan__c)) {
				subApeList.add(ape);
			}		
		}
		return subApeList;
	}
	
	//construct action plan map, key: action plan id; value: plan activity id set
	public static map<String, Set<String>> getActionPlanActivityMap(Set<String> actionPlanIdSet, list<Action_Plan_Element__c> allApeList) {
		//list<Action_Plan_Element__c> apeList = getActionPlanElementByActionPlan(actionPlanIdSet);
		list<Action_Plan_Element__c> apeList = filterActionPlanElementFromCollection(actionPlanIdSet, allApeList);
		//key: Action Plan Id; value: Plan Activity ID Set
		map<String, Set<String>> ApID_PaIDMap = new map<String, Set<String>>();
		for(Action_Plan_Element__c ape : apeList) {
			if(ApID_PaIDMap != null && ApID_PaIDMap.containsKey(ape.Action_Plan__c)) {
				ApID_PaIDMap.get(ape.Action_Plan__c).add(ape.Plan_Activity__c);
			}else {
				Set<String> idSet = new Set<String>();
				idSet.add(ape.Plan_Activity__c);
				ApID_PaIDMap.put(ape.Action_Plan__c, idSet);
			}
		}
		
		return ApID_PaIDMap;
	}
	//prepare action plan id set
	public static Set<String> getIDSetFromList(list<Action_Plan__c> actionPlanList) {
		Set<String> idSet = new Set<String>();
		for(Action_Plan__c ap : actionPlanList) {
			idSet.add(ap.Id);
		}
		return idSet;
	}
	//validate for create action plan element
	public static boolean validate(List<Action_Plan__c> firstTabCustomerTableList, List<ActionPlanElementUtil.ObjectWrapper> firstTabWrapperList, list<CustomActivityWrapper> firstTabCustomActivityList
								  , List<Action_Plan__c> secondTabCustomerTableList, List<ActionPlanElementUtil.ObjectWrapper> secondTabWrapperList, list<CustomActivityWrapper> secondTabCustomActivityList
								  , List<Action_Plan__c> thirdTabCustomerTableList, List<ActionPlanElementUtil.ObjectWrapper> thirdTabWrapperList, list<CustomActivityWrapper> thirdTabCustomActivityList
								  , List<Action_Plan__c> fourthTabCustomerTableList, List<ActionPlanElementUtil.ObjectWrapper> fourthTabWrapperList, list<CustomActivityWrapper> fourthTabCustomActivityList
								  , List<Action_Plan__c> fifthTabCustomerTableList, List<ActionPlanElementUtil.ObjectWrapper> fifthTabWrapperList, list<CustomActivityWrapper> fifthTabCustomActivityList) {
		
		list<Plan_Activity__c> firstTabPlanActivityList = getSelectedPlanActivityList(firstTabWrapperList);
		if((firstTabCustomerTableList != null && firstTabCustomerTableList.size() > 0) && (firstTabPlanActivityList != null && firstTabPlanActivityList.size() == 0) && checkNotNullList(firstTabCustomActivityList)) {
			return true;
		}
		list<Plan_Activity__c> secondTabPlanActivityList = getSelectedPlanActivityList(secondTabWrapperList);
		if((secondTabCustomerTableList != null && secondTabCustomerTableList.size() > 0) && (secondTabPlanActivityList != null && secondTabPlanActivityList.size() == 0) && checkNotNullList(secondTabCustomActivityList)) {
			return true;
		}
		list<Plan_Activity__c> thirdTabPlanActivityList = getSelectedPlanActivityList(thirdTabWrapperList);
		if((thirdTabCustomerTableList != null && thirdTabCustomerTableList.size() > 0) && (thirdTabPlanActivityList != null && thirdTabPlanActivityList.size() == 0) && checkNotNullList(thirdTabCustomActivityList)) {
			return true;
		}
		list<Plan_Activity__c> fourthTabPlanActivityList = getSelectedPlanActivityList(fourthTabWrapperList);
		if((fourthTabCustomerTableList != null && fourthTabCustomerTableList.size() > 0) && (fourthTabPlanActivityList != null && fourthTabPlanActivityList.size() == 0) && checkNotNullList(fourthTabCustomActivityList)) {
			return true;
		}
		list<Plan_Activity__c> fifthTabPlanActivityList = getSelectedPlanActivityList(fifthTabWrapperList);
		if((fifthTabCustomerTableList != null && fifthTabCustomerTableList.size() > 0) && (fifthTabPlanActivityList != null && fifthTabPlanActivityList.size() == 0) && checkNotNullList(fifthTabCustomActivityList)) {
			return true;
		}
		return false;
	}
	//check any item was selected from vf page
	public static boolean checkNotNullList(list<CustomActivityWrapper> tabCustomActivityList) {
		boolean flag = true;
		for(CustomActivityWrapper wrapper : tabCustomActivityList) {
			if(wrapper.description != null && wrapper.description != '') {
				flag = false;
				break;
			} 
		}
		return flag;
	}
	//filter selected item and put all into list
	public static list<Plan_Activity__c> getSelectedPlanActivityList(List<ActionPlanElementUtil.ObjectWrapper> tabWrapperList) {
		//system.debug('====>>> ' + JSON.serialize(tabWrapperList));
		list<Plan_Activity__c> selectedPlanActivityList = new list<Plan_Activity__c>();
		for(ActionPlanElementUtil.ObjectWrapper wrapper : tabWrapperList) {
			//filter selected item form the odd list
			if(wrapper.oddList != null) {
				for(ActionPlanElementUtil.PlanActivityWrapper paw : wrapper.oddList) {
					if(paw.isSelected) {
						selectedPlanActivityList.add(paw.planActivity);
					}
				}
			} 
			//filter selected item form the even list
			if( wrapper.evenList != null) {
				for(ActionPlanElementUtil.PlanActivityWrapper paw : wrapper.evenList) {
					if(paw.isSelected) {
						selectedPlanActivityList.add(paw.planActivity);
					}
				}
			}
			//filter selected item form the third list
			if( wrapper.thirdList != null) {
				for(ActionPlanElementUtil.PlanActivityWrapper paw : wrapper.thirdList) {
					if(paw.isSelected) {
						selectedPlanActivityList.add(paw.planActivity);
					}
				}
			}
		}
		//system.debug(JSON.serialize(selectedPlanActivityList));
		return selectedPlanActivityList;
	}
	//create action plan element for action plan
	public static list<Action_Plan_Element__c> createActionPlanElement(list<Action_Plan__c> actionPlanList, List<ActionPlanElementUtil.ObjectWrapper> tabWrapperList
																		, RecordType recordtype, list<Action_Plan_Element__c> apeList,  Map<Id, Action_Plan__c> allPageActionPlanMap) {
		
		if(actionPlanList == null || actionPlanList.size() == 0) return null;
		Set<String> actionPlanIdSet = getIDSetFromList(actionPlanList);
		//key: Action Plan Id; value: Plan Activity ID Set
		map<String, Set<String>> ApID_PaIDMap = getActionPlanActivityMap(actionPlanIdSet, apeList);
		
		if(tabWrapperList == null || tabWrapperList.size() == 0) return null;
		list<Plan_Activity__c> selectedPlanActivityList = getSelectedPlanActivityList(tabWrapperList);
		//To be created Action Plan Element List
		list<Action_Plan_Element__c> actionPlanElementList = new list<Action_Plan_Element__c>();
		//iterator all Action Plan
		for(String key : actionPlanIdSet) {
			//check wether this Action Plan have Action Plan Element or not
			if(ApID_PaIDMap != null && ApID_PaIDMap.containsKey(key)) {
				Set<String> planActivityIdSet = ApID_PaIDMap.get(key);
				for(Plan_Activity__c pa : selectedPlanActivityList) {
					//check wether Action Plan Element already exist or not
					if(planActivityIdSet != null && planActivityIdSet.contains(pa.Id)) continue;
	    			//actionPlanElementList.add(actionPlanElement);
	    			actionPlanElementList.add(createObjec(key, pa, recordtype, allPageActionPlanMap, ''));
				}
			}else {
				//not have Action Plan Element under current Action Plan
				for(Plan_Activity__c pa : selectedPlanActivityList) {
					//Action_Plan_Element__c actionPlanElement = new Action_Plan_Element__c(Plan_Activity__c=pa.Id, RecordTypeId=recordtype.Id, Action_Plan__c=key);
	    			//actionPlanElementList.add(actionPlanElement);
	    			actionPlanElementList.add(createObjec(key, pa, recordtype, allPageActionPlanMap, ''));
				}
			}
		}
		return actionPlanElementList;
	}
	
	//construct action plan element map, key: action plan id; value: action plan element set
	public static map<String, Set<String>> getCustomActionPlanElementByActionPlans(Set<String> actionPlanIdSet) {
		RecordType rt = [Select Id From RecordType Where Name =: CUSTOM_PLAN];
    	String recordtypeId = '';
    	if(rt != null) {
    		recordtypeId = rt.Id;
    	}
		//key: Action Plan Id, value: Action Plan Element Detail_Plan__c
		map<String, Set<String>> actionPlanID_ApeMap = new map<String, Set<String>>();
		for(Action_Plan_Element__c ape : [Select 
				Id
				, Name
				, RecordTypeId
				, RecordType.Name
				, Plan_Activity__c
				, Detail_Plan__c
				, Action_Plan__c 
				From Action_Plan_Element__c
				Where RecordTypeId =: recordtypeId]) {
			if(actionPlanID_ApeMap.containsKey(ape.Action_Plan__c)) {
				actionPlanID_ApeMap.get(ape.Action_Plan__c).add(ape.Detail_Plan__c);
			}else {
				Set<String> tmp = new Set<String>();
				tmp.add(ape.Detail_Plan__c);
				actionPlanID_ApeMap.put(ape.Action_Plan__c, tmp);
			}
		}
		return actionPlanID_ApeMap;
	}
	/**
	public static list<Action_Plan_Element__c> createSpecialActionPlanElement(list<Action_Plan__c> actionPlanList, RecordType recordtype, String description, Map<Id, Action_Plan__c> allPageActionPlanMap) {
		
		if(description == null || ''== description) {
			return null;
		}
		if(actionPlanList == null || actionPlanList.isEmpty()) {
			return null;
		}
		//To be created Action Plan Element List
		list<Action_Plan_Element__c> actionPlanElementList = new list<Action_Plan_Element__c>();
		for(Action_Plan__c ap : actionPlanList) {
			//Action_Plan_Element__c actionPlanElement = new Action_Plan_Element__c(RecordTypeId=recordtype.Id, Action_Plan__c=ap.Id, Detail_Plan__c=description);
		    actionPlanElementList.add(createObjec(ap.Id, null, recordtype, allPageActionPlanMap, description));
		}
		return actionPlanElementList;
	}
	**/
	//create custom action plan element for action
	public static list<Action_Plan_Element__c> createCustomActionPlanElement(list<Action_Plan__c> actionPlanList, RecordType recordtype, map<String, Set<String>> actionPlanID_ApeMap
																		, Map<Id, Action_Plan__c> allPageActionPlanMap, list<CustomActivityWrapper> firstTabCustomActivityList) {
		
		if(actionPlanList == null || actionPlanList.isEmpty()) {
			return null;
		}
		//To be created Action Plan Element List
		list<Action_Plan_Element__c> actionPlanElementList = new list<Action_Plan_Element__c>();
		for(Action_Plan__c ap : actionPlanList) {
			String key = ap.Id;
			//already have custom action plan element
			if(actionPlanID_ApeMap != null && actionPlanID_ApeMap.containsKey(key)) {
				Set<String> detailPlanSet = actionPlanID_ApeMap.get(key);
				//iterator all input custom action plan element
				for(CustomActivityWrapper ca : firstTabCustomActivityList) {
					String description = ca.description;
					//wether already exist under action plan
					if(description == null || '' == description || detailPlanSet.contains(description)) continue;
					actionPlanElementList.add(createObjec(ap.Id, null, recordtype, allPageActionPlanMap, description));
				}
			}else {
				//new custom action plan element for action plan
				for(CustomActivityWrapper ca : firstTabCustomActivityList) {
					String description = ca.description;
					if(description == null || '' == description) continue;
					actionPlanElementList.add(createObjec(ap.Id, null, recordtype, allPageActionPlanMap, description));
				}
			}
			
			//Action_Plan_Element__c actionPlanElement = new Action_Plan_Element__c(RecordTypeId=recordtype.Id, Action_Plan__c=ap.Id, Detail_Plan__c=description);
		    //actionPlanElementList.add(createObjec(ap.Id, null, recordtype, allPageActionPlanMap, description));
		}
		return actionPlanElementList;
	}
	//create action plan element
	public static Action_Plan_Element__c createObjec(String ationPlanId, Plan_Activity__c pa, RecordType recordtype, map<Id, Action_Plan__c> allPageActionPlanMap, String description) {
		String apeName = '', tmpString = description;
		//ID apId = ID.valueOf(ationPlanId);
		if(allPageActionPlanMap != null && allPageActionPlanMap.containsKey(ationPlanId)) {
			Action_Plan__c tmp = allPageActionPlanMap.get(ationPlanId);
			apeName += tmp.BoM_Plan__r.Year_Text__c + ' - ' ;
			if(tmp.FA_Goal__c != null && tmp.FA_Goal__r.FA__r != null) {
				apeName += tmp.FA_Goal__r.FA__r.Name + ' - ';
			}
		}
		//substring if action plan element'name length greater than 80
		if(apeName.length() >= 80) apeName = apeName.substring(0, 79);
		Action_Plan_Element__c actionPlanElement = null;
		if(pa != null) {
			apeName += pa.Name;
			if(apeName.length() >= 80) apeName = apeName.substring(0, 79);
			actionPlanElement = new Action_Plan_Element__c(Name=apeName, Plan_Activity__c=pa.Id, RecordTypeId=recordtype.Id, Action_Plan__c=ationPlanId);
		}else {
			apeName += description;
			if(apeName.length() >= 80) apeName = apeName.substring(0, 79);
			//actionPlanElement = new Action_Plan_Element__c(Name=apeName, RecordTypeId=recordtype.Id, Action_Plan__c=ationPlanId);
			actionPlanElement = new Action_Plan_Element__c(Name=apeName, RecordTypeId=recordtype.Id, Action_Plan__c=ationPlanId, Detail_Plan__c=tmpString);
		}
		return actionPlanElement;
	}
	/**
	public static list<Action_Plan__c> findActionPlanFromMap(list<Action_Plan__c> tabActionPlanList, Map<Id, Action_Plan__c> allActionPlanMap) {
		list<Action_Plan__c> actionPlanList = new list<Action_Plan__c>();
		return null;
	}
	**/
	//prepare plan activity for vf display
	public static map<String, map<String, List<PlanActivityWrapper>>> groupPlanActivityByBPGoal() {
		
		//key: Category__c:BPGoal__c; value: Plan_Activity__c list
		map<String, List<PlanActivityWrapper>> CategoryBPGoal_ActivityMap = new map<String, List<PlanActivityWrapper>>();
		
		//key: BPGoal__c; value: CategoryBPGoal_ActivityMap
		map<String, map<String, List<PlanActivityWrapper>>> BPGoal_PlanActivityMap = new map<String, map<String, List<PlanActivityWrapper>>>();
		//Set<String> CategorySet = getCategoryPickListValues();
		for(Plan_Activity__c pa : [Select Id 
										, Name
										, Order__c
										, Description__c
										, Category__c
										, Primary_Objective__c 
										From Plan_Activity__c
										Where Category__c != null
										And Primary_Objective__c != null
										And Active__c = true
										]) 
		{
			
			if(pa.Primary_Objective__c == null) continue;
			if(pa.Category__c != null) {
				//already have key: pa.Order__c+'-'+pa.Category__c+':'+pa.Primary_Objective__c
				if(CategoryBPGoal_ActivityMap != null  && CategoryBPGoal_ActivityMap.containsKey(pa.Order__c+'-'+pa.Category__c+':'+pa.Primary_Objective__c)) {
					PlanActivityWrapper wrapper = new PlanActivityWrapper(false, pa.Category__c, pa);
					CategoryBPGoal_ActivityMap.get(pa.Order__c+'-'+pa.Category__c+':'+pa.Primary_Objective__c).add(wrapper);
				}else {
					//create new key, and put value into map
					list<PlanActivityWrapper> tmp = new list<PlanActivityWrapper>();
					PlanActivityWrapper wrapper = new PlanActivityWrapper(false, pa.Category__c, pa);
					tmp.add(wrapper);
					CategoryBPGoal_ActivityMap.put(pa.Order__c+'-'+pa.Category__c+':'+pa.Primary_Objective__c, tmp);
				}
			}
			
		}
		////
		for(String key : CategoryBPGoal_ActivityMap.keySet()) {
			String[] arr = key.split(':');
			if(BPGoal_PlanActivityMap != null && arr.size() > 1 && BPGoal_PlanActivityMap.containsKey(arr[1])) {
				//key: Primary Objective, value: PlanActivityWrapper class list
				map<String, List<PlanActivityWrapper>> tmpMap = BPGoal_PlanActivityMap.get(arr[1]);
				tmpMap.put(arr[0], CategoryBPGoal_ActivityMap.get(key));
				BPGoal_PlanActivityMap.put(arr[1], tmpMap);
				//BPGoal_PlanActivityMap.get(arr[1]).put(arr[0], CategoryBPGoal_ActivityMap.get(key));
			}else {
				map<String, List<PlanActivityWrapper>> tmpMap = new map<String, List<PlanActivityWrapper>>();
				tmpMap.put(arr[0], CategoryBPGoal_ActivityMap.get(key));
				BPGoal_PlanActivityMap.put(arr[1], tmpMap);
			}
		}
		
		return BPGoal_PlanActivityMap;
	}
	//splite data from vf page for save
	public static List<ObjectWrapper> spliteMap(map<String, map<String, List<PlanActivityWrapper>>> BPGoal_PlanActivityMap, String spiltMap) {
		//system.debug('>>>>> ' + JSON.serialize(BPGoal_PlanActivityMap.get('All')));
		
		List<ObjectWrapper> wrapperList = new List<ObjectWrapper>();
		map<String, List<PlanActivityWrapper>> clientAssetAcquisitionMap = new map<String, List<PlanActivityWrapper>>();
		if(BPGoal_PlanActivityMap != null && BPGoal_PlanActivityMap.containsKey(spiltMap)) clientAssetAcquisitionMap = BPGoal_PlanActivityMap.get(spiltMap);
		wrapperList = rebuildList(clientAssetAcquisitionMap, BPGoal_PlanActivityMap.get('All'));
		/**
		if(BPGoal_PlanActivityMap != null && BPGoal_PlanActivityMap.containsKey(spiltMap)) {
			clientAssetAcquisitionMap = BPGoal_PlanActivityMap.get(spiltMap);
			wrapperList = rebuildList(clientAssetAcquisitionMap, BPGoal_PlanActivityMap.get('All'));
		}
		**/
		/**
		if(spiltMap == ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION) {
			if(BPGoal_PlanActivityMap != null && BPGoal_PlanActivityMap.containsKey(ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION)) {
				clientAssetAcquisitionMap = BPGoal_PlanActivityMap.get(ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION);
				wrapperList = rebuildList(clientAssetAcquisitionMap, BPGoal_PlanActivityMap.get('All'));
			}
		}
		if(spiltMap == ActionPlanElementUtil.ENHANCE_CLIENT_SERVICE) {
			if(BPGoal_PlanActivityMap != null && BPGoal_PlanActivityMap.containsKey(ActionPlanElementUtil.ENHANCE_CLIENT_SERVICE)) {
				clientAssetAcquisitionMap = BPGoal_PlanActivityMap.get(ActionPlanElementUtil.ENHANCE_CLIENT_SERVICE);
				wrapperList = rebuildList(clientAssetAcquisitionMap, BPGoal_PlanActivityMap.get('All'));
			}
		}
		if(spiltMap == ActionPlanElementUtil.COMPREHENSIVE_WEALTH_MANAGEMENT) {
			if(BPGoal_PlanActivityMap != null && BPGoal_PlanActivityMap.containsKey(ActionPlanElementUtil.COMPREHENSIVE_WEALTH_MANAGEMENT)) {
				clientAssetAcquisitionMap = BPGoal_PlanActivityMap.get(ActionPlanElementUtil.COMPREHENSIVE_WEALTH_MANAGEMENT);
				wrapperList = rebuildList(clientAssetAcquisitionMap, BPGoal_PlanActivityMap.get('All'));
			}
		}
		if(spiltMap == ActionPlanElementUtil.OPTIMIZE_PRACTICE) {
			if(BPGoal_PlanActivityMap != null) {
				clientAssetAcquisitionMap = BPGoal_PlanActivityMap.get(ActionPlanElementUtil.OPTIMIZE_PRACTICE);
				wrapperList = rebuildList(clientAssetAcquisitionMap, BPGoal_PlanActivityMap.get('All'));
			}
		}
		**/
		return wrapperList;
	}
	//prepare data for vf display
	public static List<ObjectWrapper> rebuildList(map<String, list<PlanActivityWrapper>> inputMap, map<String, List<PlanActivityWrapper>> generalWrapperMap) {
		//can't use below statement, because each tab will refer the same record
		//inputMap.put('General', buildGeneralPrimaryObjectiveList());
		//system.debug('>>>>> ' + JSON.serialize(inputMap));
		List<ObjectWrapper> tmpList = new List<ObjectWrapper>();
		//on data from inputMap, set General list at the even list
		if(inputMap == null || inputMap.isEmpty()) {
			String firstKey1 = '';
			String firstKey2 = '';
			list<PlanActivityWrapper> firstOddList = null;
			list<ActionPlanElementUtil.PlanActivityWrapper> generalPawList =  buildGeneralPrimaryObjectiveList();
			if(generalPawList != null) {
				firstKey2 = 'General';
				list<PlanActivityWrapper> firstEvenList = generalPawList;
				String wrapperId = String.valueOf(BPCommonUtil.getNumberFormat(math.random() * 10000000, 0));
				ObjectWrapper wrapper = new ObjectWrapper(wrapperId, 'TabTitle', firstKey1, firstKey2, firstOddList, firstEvenList, '', null);
				tmpList.add(wrapper);
			} 
		}else {
			Set<String> keySet = inputMap.keySet();
			list<String> keyList = new list<String>();
			keyList.addAll(keySet);
			keyList.sort();
			//for the first row start
			String firstKey1 = keyList.get(0);
			String firstKey2 = '';
			list<PlanActivityWrapper> firstOddList = inputMap.get(firstKey1);
			String thirdTitle = '';
			list<PlanActivityWrapper> thirdList = null;
			//has the third list or not
			if(inputMap.size() > 1) {
				thirdTitle = keyList.get(1);
				thirdList = inputMap.get(thirdTitle);
			}
			//get the General list for even list
			list<ActionPlanElementUtil.PlanActivityWrapper> generalPawList =  buildGeneralPrimaryObjectiveList();
			if(generalPawList != null) {
				firstKey2 = 'General';
				list<PlanActivityWrapper> firstEvenList = generalPawList;
				String wrapperId = String.valueOf(BPCommonUtil.getNumberFormat(math.random() * 10000000, 0));
				String tmpThirdTitle = '';
				if(thirdTitle != null && thirdTitle != '') {
					tmpThirdTitle = thirdTitle.split('-')[1];
				}
				//construct the fir ObjectWrapper, and put it into wrapper list
				ObjectWrapper wrapper = new ObjectWrapper(wrapperId, 'TabTitle', firstKey1.split('-')[1], firstKey2, firstOddList, firstEvenList, tmpThirdTitle, thirdList);
				tmpList.add(wrapper);
			} 
			//remove the first and second element from list
			keyList.remove(0);
			if(keyList.size() >= 1) {
				keyList.remove(0);
			}
			if(keyList == null || keyList.size() == 0) return tmpList;
			
			Integer remainderSize = keyList.size();
			Integer length = 0;
			//calculate vf display list size
			if(math.mod(remainderSize, 3) == 0) {
				length = (remainderSize / 3);
			}else {
				length = (remainderSize / 3) + 1;
			}
			for(Integer i=0; i<length; i++) {
				Integer odd = i * 3;
				String key1 = keyList.get(odd);
				String key2 = '';
				list<PlanActivityWrapper> oddList = inputMap.get(key1);
				list<PlanActivityWrapper> evenList = null;
				String tmpThirdKey = '';
				list<PlanActivityWrapper> tmpThirdList = null;
				//key1 = key1.substring(1, key1.length());
				if((i * 3 + 1) == remainderSize || (i * 3 + 1) > remainderSize) {
					evenList = null;
					tmpThirdList = null;
				}else if((i * 3 + 2) == remainderSize || (i * 3 + 2) > remainderSize) {
					key2 = keyList.get(i * 3 + 1);
					evenList = inputMap.get(key2);
					tmpThirdList = null;//the third list
				}else {
					Integer even = i * 3 + 1;
					key2 = keyList.get(even);
					evenList = inputMap.get(key2);
					key2 = key2.split('-')[1];
					String tmpStr = keyList.get(i * 3 + 2);
					tmpThirdList = inputMap.get(tmpStr);
					tmpThirdKey = tmpStr.split('-')[1];
				}
				String wrapperId = String.valueOf(BPCommonUtil.getNumberFormat(math.random() * 10000000, 0));
				ObjectWrapper wrapper = new ObjectWrapper(wrapperId, 'TabTitle', key1.split('-')[1], key2, oddList, evenList, tmpThirdKey, tmpThirdList);
				tmpList.add(wrapper);
			}
			
			//swap(tmpList);
		}
		return tmpList;
	}
	///no use
	/**
	public static List<ObjectWrapper> swap(List<ObjectWrapper> tmpList) {
		for(Integer i=0; i<tmpList.size(); i++) {
			ObjectWrapper wrapper = tmpList.get(i);
			if(wrapper == null) continue; 
			if(wrapper.oddTitle != null && wrapper.oddTitle == 'General' && wrapper.evenTitle != null) {
				String oddTitle = wrapper.evenTitle;
				String evenTitle = wrapper.oddTitle;
				wrapper.oddTitle = oddTitle;
				wrapper.evenTitle = evenTitle;
				if(wrapper.evenList != null) {
					list<PlanActivityWrapper> oddList = wrapper.evenList;
					list<PlanActivityWrapper> evenList = wrapper.oddList;
					wrapper.oddList = oddList;
					wrapper.evenList = evenList;
				}
				tmpList.set(i, tmpList.get(0));
				tmpList.set(0, wrapper);
			}
		}
		return tmpList;
	}
	**/
	//build General list  for vf display
	public static list<ActionPlanElementUtil.PlanActivityWrapper> buildGeneralPrimaryObjectiveList() {
		list<Plan_Activity__c> generalList = getPlanActivityTypeIsAll('All');
		List<PlanActivityWrapper> wrapperList = new List<PlanActivityWrapper>();
		for(Plan_Activity__c pa : generalList) {
			PlanActivityWrapper wrapper = new PlanActivityWrapper(false, pa.Category__c, pa);
			wrapperList.add(wrapper);
		}
		return wrapperList;
	}
	/*
	public static List<Action_Plan__c> splitActionPlanMap(Map<Id, Action_Plan__c> actionPlanMap, String primaryObjective) {
		List<Action_Plan__c> actionPlanList = new List<Action_Plan__c>();
		
		return actionPlanList;
	}
	**/
	//update action plan element Ranking field after action plan elements were created
	public static void updateFARankingField() {
		List<Action_Plan_Element__c> newActionPlanElementList = trigger.new;
		Set<String> actionPlanIdSet = new Set<String>();
		for(Action_Plan_Element__c ape : newActionPlanElementList) {
			actionPlanIdSet.add(ape.Action_Plan__c);
		}
		Map<Id, Action_Plan__c> actionPlanMap = ActionPlanUtil.getExistingActionPlanByIds(actionPlanIdSet);
		Set<Id> contactIdSet = new Set<Id>();
		for(Action_Plan__c actionPlan : actionPlanMap.values()) {
			if(actionPlan.FA_Goal__c != null && actionPlan.FA_Goal__r.FA__c != null && actionPlan.FA_Goal__r.FA__r.Id != null) {
				contactIdSet.add(actionPlan.FA_Goal__r.FA__r.Id);
			}
		}
		//key: contact id; value: Ranking__c
		Map<String, Ranking__c> rankingMap = BPBranchBusinessPlanUtil.getRanking4FAGoal(contactIdSet);
		for(Action_Plan_Element__c ape : newActionPlanElementList) {
			Action_Plan__c actionPlan = actionPlanMap.get(ape.Action_Plan__c);
			if(actionPlan.FA_Goal__c != null && actionPlan.FA_Goal__r.FA__c != null
											 && actionPlan.FA_Goal__r.FA__r.Id != null
											 && rankingMap.containsKey(actionPlan.FA_Goal__r.FA__r.Id)) {
				Ranking__c ranking = rankingMap.get(actionPlan.FA_Goal__r.FA__r.Id);
				ape.FA_Ranking__c = ranking.Id;
			}
		}
		//nsert newActionPlanElementList;
	}
	//prepare Primary Goal dropdown list for vf:bpfaactionplanning display
	public static list<String> getPrimaryGoalItems() {
		list<String> primaryGoalList = new list<String>();
		Schema.DescribeFieldResult fieldResult = Ranking__c.Primary_Objective__c.getDescribe();
		list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			primaryGoalList.add(f.getValue());
		} 
		return primaryGoalList;
	}
	//get Custom Activity Wrapper by select tab
	public static list<CustomActivityWrapper> getDefaultCustomActivityWrapper(String tabIndex) {
		list<CustomActivityWrapper>  wrapperList = new list<CustomActivityWrapper>();
		CustomActivityWrapper wrapper = new CustomActivityWrapper(0, tabIndex, '', false);
		wrapperList.add(wrapper);
		return wrapperList;
	}
	
	public static CustomActivityWrapper createDefaultCustomActivityWrapper(Integer index, String tabIndex, String description, boolean disabled) {
		CustomActivityWrapper wrapper = new CustomActivityWrapper(index+1, tabIndex, '', disabled);
		return wrapper;
	}
	
	/**
	public static Set<String> getBPGoalPickListValues() {
		
		Set<String> options = new Set<String>();
		Schema.DescribeFieldResult fieldResult = Plan_Activity__c.Primary_Objective__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			options.add(f.getValue());
		}
		
		return options; 
	}
	public static Set<String> getCategoryPickListValues() {
		Set<String> options = new Set<String>();
		Schema.DescribeFieldResult fieldResult = Plan_Activity__c.Category__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			options.add(f.getValue());
		}
		return options; 
	}
	**/
	public class PlanActivityWrapper {
    	
    	public boolean isSelected { get;set; }
    	
    	public String bPCategory { get;set; }
    	
    	public Plan_Activity__c planActivity { get;set; }
    	
    	public PlanActivityWrapper(boolean isSelected, String bPCategory, Plan_Activity__c planActivity) {
    		this.isSelected = isSelected;
    		this.bPCategory = bPCategory;
    		this.planActivity = planActivity;
    	}
    }
    
    public class ObjectWrapper {
    	
    	public String Id { get;set; }
    	
    	public String tabTitle { get;set; }
    	
    	public String oddTitle { get;set; }
    	
    	public String evenTitle { get;set; }
    	
    	public String thirdTitle { get;set; }// the third list
    	
    	public list<PlanActivityWrapper> oddList { get;set; }
    	
    	public list<PlanActivityWrapper> evenList { get;set; }
    	
    	public list<PlanActivityWrapper> thirdList { get;set; }// the third list
    	
    	public ObjectWrapper(String Id, String tabTitle, String oddTitle, String evenTitle, list<PlanActivityWrapper> oddList, list<PlanActivityWrapper> evenList
    						, String thirdTitle, list<PlanActivityWrapper> thirdList) {
    		this.Id = Id;
    		this.tabTitle = tabTitle;
    		this.oddTitle = oddTitle;
    		this.evenTitle = evenTitle;
    		this.oddList = oddList;
    		this.evenList = evenList;
    		this.thirdTitle = thirdTitle;
    		this.thirdList = thirdList;
    	}
    	
    }
    
    global class CustomActivityWrapper implements Comparable {
    	
    	public Integer index { get;set; }
    	public String tabIndex { get;set; }
    	public boolean disabled { get;set; }
    	public String description { get;set; }
    	
    	global CustomActivityWrapper(Integer index, String tabIndex, String description, boolean disabled) {
    		this.index = index;
    		this.tabIndex = tabIndex;
    		this.description = description;
    		this.disabled = disabled;
    	}
    	
    	global Integer compareTo(Object compareTo) {
    		CustomActivityWrapper compareToCustomActivity = (CustomActivityWrapper)compareTo;
    		String compareDescription = compareToCustomActivity.description;

			if(description == null || description == ''){
	        	return 1;
	        }
	        
    		if(compareDescription == null || compareDescription == ''){
	        	return -1;
	        }
	        if (description < compareToCustomActivity.description) return -1;
	        else if (description == compareToCustomActivity.description) return 0;
	        else return 1;
	    }
	    
    }
    
    
    /****************************** Start Testing ********************************************************************/
    
    public static list<Plan_Activity__c> createTestPlanActivity() {
    	list<Plan_Activity__c> paList = new list<Plan_Activity__c>();
    	for(Integer i=0; i<6; i++) {
    		String primaryObjective = CLIENT_AND_ASSET_ACQUISTION;
    		for(Integer j=0; j<3; j++) {
	    		Plan_Activity__c pa = new Plan_Activity__c();
	    		pa.Name = 'Test ' + j;
	    		if(i==0) {
	    			pa.Category__c = 'All';
	    		}else {
		    		pa.Category__c = ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION;
	    		}
	    		pa.Primary_Objective__c = primaryObjective;
	    		pa.Order__c = i;
	    		pa.Active__c = true;
	    		paList.add(pa);
    		} 
    	}
    	insert paList;
    	return paList;
    }
    
    public static list<Action_Plan__c> createTestActionPlan(Integer maxNumber, BoM_Plan__c bomPlan) {
    	list<Action_Plan__c> actionPlanList = new list<Action_Plan__c>();
    	list<FA_Goal__c> faGoalList = [Select Id, Name From FA_Goal__c Where BoM_Plan__c =: bomPlan.Id];
    	Integer index = 0;
    	if(faGoalList != null && faGoalList.size() > 0) index = faGoalList.size();
    	if(index > 0 && index >= maxNumber) index = maxNumber - 1;
    	for(Integer i=0; i<maxNumber; i++) {
    		Action_Plan__c ap = new Action_Plan__c();
    		if(index != 0) ap.FA_Goal__c = faGoalList.get(i).Id;
    		ap.BoM_Plan__c = bomPlan.Id;
    		actionPlanList.add(ap);
    	}
    	return actionPlanList;
    }
    
    public static list<Action_Plan_Element__c> createTestActionPlanElement(Integer maxNumber, list<Action_Plan__c> actionPlanList) {
    	list<Action_Plan_Element__c> actionPlanLElementist = new list<Action_Plan_Element__c>();
    	for(Action_Plan__c ap : actionPlanList) {
	    	for(Integer i=0; i<maxNumber; i++) {
	    		Action_Plan_Element__c ape = new Action_Plan_Element__c();
	    		ape.Action_Plan__c = ap.Id;
	    		actionPlanLElementist.add(ape);
	    	}
    	}
    	insert actionPlanLElementist;
    	return actionPlanLElementist;
    }
    /****************************** End Testing ********************************************************************/
}