/**************************************************************************************************
 * Purpose: Controller of the FA Action Planning Visualforce Page
 * Author: PwC (Terry)
 * Create Date (yyyy-MM-dd): 2013-11-18
 * Modify History:
 * Terry    2013-11-18   Created
***************************************************************************************************/
global class BPFAActionPlanningCon {

    public BoM_Plan__c bomPlan { get;set; }
    
    public list<Action_Plan__c> actionPlanList { get;set; }
    
    public list<ActionPlanWrapper> actionPlanWrapperList { get;set; }
    
    public String msgStr { get;set; }
    
    public String selectedTab { get;set; }
    
    public map<Id, Action_Plan__c> actionPlanMap { get;set; }
    
    public map<String,String> quadrantLinkMap { get;set; }
    
    public List<SelectOption> BPGoalItems {
    	get {
			List<SelectOption> options = new List<SelectOption>();
		    options.add(new SelectOption('--None--', '--None--'));    
			Schema.DescribeFieldResult fieldResult = Ranking__c.Primary_Objective__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple) {
				options.add(new SelectOption(f.getLabel(), f.getValue()));
			}       
			return options;
    	}
	}
	
	public BPFAActionPlanningCon(ApexPages.StandardController stdController) {
        bomPlan = (BoM_Plan__c) stdController.getRecord();
        bomPlan = BPBranchBusinessPlanUtil.getBoMPlanById(bomPlan.Id);
        //system.debug('***bomPlan: ' + bomPlan);
    }
    /**
    public BPFAActionPlanningCon() {
        String bomPlanId = ApexPages.currentPage().getParameters().get('pid');
        if(bomPlanId == null || bomPlanId == '') {
            msgStr = 'Invalid BoM Plan Id.';
            BPMessageUtil.addInfoMessage(msgStr);
        }else {
            bomPlan = BPBranchBusinessPlanUtil.getBoMPlanById(bomPlanId);
            system.debug('***bomPlan: ' + bomPlan);
        }
    }
    **/
    //create non exist fa goal when vf page loading
    public void createFAActionPlan() {
        if(bomPlan == null){
            msgStr = 'Invalid BoM Plan.';
            BPMessageUtil.addInfoMessage(msgStr);
            return;
        }
        
        actionPlanWrapperList = new list<ActionPlanWrapper>();
        //create non exist FA Goal for BoM Plan
        BPBranchBusinessPlanUtil.createNonExistingFAGoal4MainBranch(bomPlan.Main_Branch__c, bomPlan);
        //Create non-existing Action Plan, so every FA should have 1 plan
        ActionPlanUtil.createNonExistingActionPlan4MainBranch(bomPlan.Main_Branch__c, bomPlan);
        //actionPlanMap = ActionPlanUtil.getExistingActionPlan(bomPlan); 
        //actionPlanList = actionPlanMap.values(); 
        actionPlanList = ActionPlanUtil.getExistingActionPlanList(bomPlan);
        String leadershipLink = 'https://my.advisor-connection.com/infomax/PCG/resources/branch_manager_site/leadership_in_action/default.aspx';
        quadrantLinkMap = new map<String, String>();
        for(String link : Quadrant_Link__c.getall().keySet()) {
        	quadrantLinkMap.put(link, Quadrant_Link__c.getall().get(link).Leadership_In_Action__c);
        }
    	if(quadrantLinkMap == null || quadrantLinkMap.size() == 0) quadrantLinkMap = new map<String, String>{'Branch Manager Site' => leadershipLink};
        for(Action_Plan__c ap : actionPlanList){
        	actionPlanWrapperList.add(new ActionPlanWrapper(ap));
        }
        actionPlanWrapperList.sort();
    }
    /***
    public PageReference createActionPlanElements() {
    	try{
	    	//key: Primary_Objective__c; value: list<Action_Plan_Element__c>
	    	Set<String> actionPlanIdSet = new Set<String>();
	    	for(Action_Plan__c ap : actionPlanList) {
	    		actionPlanIdSet.add(ap.Id);
	    	}
	    	//find already exist action plan elements
	    	//kye: Action_Plan__c; value: Primary_Objective__c set
	    	map<String, Set<String>> APId_BPGoalMap = new map<String, Set<String>>();
	    	//key: Action_Plan ID; value: Plan Activity ID set
	    	map<String, Set<String>> actionPlanID_PAIDMap = new map<String, Set<String>>();
	    	for(Action_Plan_Element__c ape : ActionPlanElementUtil.getActionPlanElementByActionPlan(actionPlanIdSet)) {
	    		if(APId_BPGoalMap != null && APId_BPGoalMap.containsKey(ape.Action_Plan__c)) {
	    			APId_BPGoalMap.get(ape.Action_Plan__c).add(ape.Plan_Activity__r.Primary_Objective__c);
	    			actionPlanID_PAIDMap.get(ape.Action_Plan__c).add(ape.Plan_Activity__c);
	    		}else {
	    			Set<String> tmp = new Set<String>();
	    			tmp.add(ape.Plan_Activity__r.Primary_Objective__c);
	    			APId_BPGoalMap.put(ape.Action_Plan__c, tmp);
	    			//
	    			Set<String> tmpPAIDSet = new Set<String>();
	    			tmpPAIDSet.add(ape.Plan_Activity__c);
	    			actionPlanID_PAIDMap.put(ape.Action_Plan__c, tmpPAIDSet);
	    		}
	    	}
	    	list<Action_Plan_Element__c> actionPlanElementList = new list<Action_Plan_Element__c>();
	    	list<FA_Goal__c> faGoalList = new list<FA_Goal__c>();
	    	Set<String> bPGoalSet = new Set<String>();
	    	//key: Action Plan Id; value: Primary_Objective__c
	    	map<String, String> actionPlan_BPGoalMap = new map<String, String>(); 
	    	for(Action_Plan__c ap : actionPlanList) {
	    		if(ap.FA_Goal__r.Primary_Objective__c == '--None--') {
	    			ap.FA_Goal__r.Primary_Objective__c = null;
	    		}else {
	    			//filter exist action plan element which associate with action plan
	    			actionPlan_BPGoalMap.put(ap.Id, ap.FA_Goal__r.Primary_Objective__c);
		    		bPGoalSet.add(ap.FA_Goal__r.Primary_Objective__c);
	    		}
	    		faGoalList.add(ap.FA_Goal__r);
	    	}
	    	Map<Id, sObject> recordtypeMap = BPQueryUtil.queryMap(null, 'RecordType', 'Name=\'Common Plan\'', null);
	    	RecordType recordtype = null;
	    	if(recordtypeMap != null && recordtypeMap.size()> 0) recordtype = (RecordType)recordtypeMap.values()[0];
	    	
	    	
	    	//construct bpGoal_ActionPlanElementMap
	    	//map<String, list<Action_Plan_Element__c>> bpGoal_ActionPlanElementMap = new map<String, list<Action_Plan_Element__c>>();
	    	map<String, list<Plan_Activity__c>> bpGoal_PlanActivityMap = new map<String, list<Plan_Activity__c>>();
	    	//map<Id, Plan_Activity__c> planActivityMap = ActionPlanElementUtil.getPlanActivityMapByBPGoal(bPGoalSet);
	    	list<Plan_Activity__c> planActivityList = ActionPlanElementUtil.getPlanActivityByBPGoal(bPGoalSet);
	    	for(Plan_Activity__c pa : planActivityList) {
	    		if(bpGoal_PlanActivityMap != null && bpGoal_PlanActivityMap.containsKey(pa.Primary_Objective__c)) {
	    			bpGoal_PlanActivityMap.get(pa.Primary_Objective__c).add(pa);
	    		}else {
	    			list<Plan_Activity__c> tmp = new list<Plan_Activity__c>();
	    			tmp.add(pa);
	    			bpGoal_PlanActivityMap.put(pa.Primary_Objective__c, tmp);
	    		}
	    		
	    	}
	    	//Set Action Plan Id with Ation Plan Element
	    	for(String key : actionPlan_BPGoalMap.keySet()) {
	    		Set<String> planActivityIDSet = actionPlanID_PAIDMap.get(key);
	    		String BP_Goal = actionPlan_BPGoalMap.get(key);
	    		if(bpGoal_PlanActivityMap != null && bpGoal_PlanActivityMap.containsKey(BP_Goal)) {
	    			for(Plan_Activity__c pa : bpGoal_PlanActivityMap.get(BP_Goal)) {
	    				if(planActivityIDSet != null && planActivityIDSet.contains(pa.Id)) continue;
	    				//createObjec(String ationPlanId, Plan_Activity__c pa, RecordType recordtype, map<Id, Action_Plan__c> allPageActionPlanMap, String description)
	    				//Action_Plan_Element__c actionPlanElement = new Action_Plan_Element__c(Plan_Activity__c=ape.Plan_Activity__c, RecordTypeId=recordtype.Id, Action_Plan__c=key);
	    				Action_Plan_Element__c actionPlanElement = ActionPlanElementUtil.createObjec(key, pa, recordtype, actionPlanMap, '');
	    				actionPlanElementList.add(actionPlanElement);
	    			}
	    		}
	    	}
	    	upsert actionPlanElementList;
	    	update faGoalList;
    		msgStr = 'Default Ation Plan Elements for Action Plan were created successfully.';
            BPMessageUtil.addInfoMessage(msgStr);
            
    	}catch(Exception e) {
    		msgStr = 'Exception was occured, please contact your administrator.';
            BPMessageUtil.addInfoMessage(msgStr);
    	}
    	//PageReference pr = new PageReference('/apex/BPFAActionPlanning?pid'+bomPlan.Id);
    	//PageReference pr = Page.BPFAActionPlanning;
        //pr.getParameters().put('id', bomPlan.Id);
        //PageReference pr = new PageReference('/'+bomPlan.Id);
        return null;
        
    }
    ***/
    //forward vf page to BPActionPlanElement page
    public PageReference forward() {
    	list<FA_Goal__c> faGoalList = new list<FA_Goal__c>();
    	list<Ranking__c> rankingList = new list<Ranking__c>();
    	boolean forwardFlag = false;
    	//prepare data for updating Ranking, FA Goal
    	for(Action_Plan__c ap : actionPlanList) {
    		if(ap.FA_Goal__r == null) continue;
    		if(ap.FA_Goal__r.Ranking__c != null) {
    			Ranking__c ranking = new Ranking__c(Id=ap.FA_Goal__r.Ranking__c, Focus__c=ap.FA_Goal__r.Ranking__r.Focus__c);
    			rankingList.add(ranking);
    		}
    		if(ap.FA_Goal__r.Primary_Objective__c == '--None--') {
    			forwardFlag = true;
    			break;
    			//ap.FA_Goal__r.Primary_Objective__c = null;
    		}
    		faGoalList.add(ap.FA_Goal__r);
    	}
    	if(forwardFlag) {
    		msgStr = 'Please select a primary goal for all FA\'s';
            BPMessageUtil.addInfoMessage(msgStr);
            return null;
    	}
    	update rankingList;
    	update faGoalList;
    	PageReference pr = Page.BPActionPlanElement;
        pr.getParameters().put('pid', bomPlan.Id);
        pr.getParameters().put('selectedTab', 'selectedTab');
        return pr;
    }
    
    public PageReference cancel() {
    	PageReference pr = new PageReference('/'+bomPlan.Id);
        return pr;
    }
    
    global class actionPlanWrapper implements Comparable{
    	public actionPlanWrapper(Action_Plan__c ap){
    		this.ap = ap;
    		focus = ap.FA_Goal__r.Ranking__r.Focus__c;
    	}
    	
    	public Action_Plan__c ap {get;set;}
    	
    	public Boolean focus{
    		get{
    			if(ap==null || ap.FA_Goal__r==null || ap.FA_Goal__r.Ranking__r==null){
    				return false;
    			}
    			return ap.FA_Goal__r.Ranking__r.Focus__c;
    		}
    		set{
    			if(ap==null || ap.FA_Goal__r==null || ap.FA_Goal__r.Ranking__r==null){
    				return;
    			}
    			ap.FA_Goal__r.Ranking__r.Focus__c = value;
    		}
    	}
    	
    	global Integer compareTo(Object compareTo) {
    		
    		actionPlanWrapper wrapper = (actionPlanWrapper)compareTo;
    		if(wrapper.ap.FA_Goal__r.BP_Quadrant__c == null) {
	        	return -1;
	        }else{
	        	return 1;
	        }
	    }
    }
    
    /**
    public PageReference deleteAll() {
    	list<Action_Plan_Element__c> allElements = [Select Id From Action_Plan_Element__c];
    	delete allElements;
    	PageReference pr = new PageReference('/'+bomPlan.Id);
        return pr;
    }
    
    
    
    public PageReference deleteActionPlan() {
    
        list<Action_Plan__c> oldAPList = new list<Action_Plan__c>([ Select Id
                                                                    From Action_Plan__c
                                                                    Where BoM_Plan__c =: bomPlan.Id
                                                                ]);
        delete oldAPList;
        PageReference pr = new PageReference('/'+bomPlan.Id);
        return pr;
    }
    **/
    
}