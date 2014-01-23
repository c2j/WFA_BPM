/**************************************************************************************************
 * Purpose: Controller of the Branch Business Plan Visualforce Page
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-10-28
 * Modify History:
 * Keen    2013-10-28    Created
***************************************************************************************************/

public with sharing class BPBranchBusinessPlanCon {
	
    public BoM_Plan__c bomPlan {get;set;}
    
    public List<FA_Goal__c> faGoalList {get;set;}
    
    public Map<Id, FA_Goal__c> faGoalMap {get;set;}
    
    public List<Branch_Business_Plan_Help__c> helpList {get; set;}
    public List<Branch_Business_Plan_Help__c> newHeyHHsHelpList {get; set;}
    public List<Branch_Business_Plan_Help__c> advisoryHelpList {get; set;}
    public List<Branch_Business_Plan_Help__c> lendingHelpList {get; set;}
    public List<Branch_Business_Plan_Help__c> netIncomeHelpList {get; set;}
    
    public List<BPBranchBusinessPlanUtil.FAGoalWrapper> wrapperList { get;set; }
    
    public Plan_Value_Validation__c planValueCap {
    	get{
    		if(planValueCap == null){
    			mPlanValueCap = Plan_Value_Validation__c.getInstance('Cap');
    			if(mPlanValueCap == null){
    				mPlanValueCap = new Plan_Value_Validation__c();
    				mPlanValueCap.Name = 'Cap';
    				mPlanValueCap.Advisory__c = 500000000;
    				mPlanValueCap.Lending__c = 250000000;
    				mPlanValueCap.Net_Income__c = 15000000;
    				mPlanValueCap.New_Key_HHs__c = 500;
    				mPlanValueCap.T12_Attrited__c = 50000000;
    				mPlanValueCap.T12_Recruited__c = 50000000;
    			}
    		}
    		return mPlanValueCap;
    	}
    }
    private Plan_Value_Validation__c mPlanValueCap;
    
    public String msgStr;
    public Integer year {get;set;}
	
	public String selectedTab { get;set; }
	
	public String index { get;set; }
	
	public decimal FAGoalNewKeyHHs {get;set;}
	public decimal FAGoalAdvisory {get;set;}
	public decimal FAGoalLending {get;set;}
	public decimal FAGoalNetIncome {get;set;}
	
	public decimal PriorNetIncome {get;set;}
	public decimal PlanNetIncome {get;set;}
	
	public decimal PlanNewKeyHHsRollupCompare { get;set; }
	
	public decimal PlanAdvisoryNetFlowsRollupCompare { get;set; }
	
	public decimal PlanLendingRollupCompare { get;set; }
	
	public decimal PlanNetIncomeCompare { get;set; }
	
	public decimal tonnageGoalNewKeyHHs { 
		get{
			if(bomPlan == null){
				return 0;
			}
			
			//system.debug('*** BPCommonUtil.defaultNull(bomPlan.Tonnage_Goal_New_Key_HHs__c): ' + BPCommonUtil.defaultNull(bomPlan.Tonnage_Goal_New_Key_HHs__c));
			return BPCommonUtil.defaultNull(bomPlan.Tonnage_Goal_New_Key_HHs__c); 
		} 
	}
	
	public decimal tonnageGoalAdvisoryNetFlows { 
		get{
			if(bomPlan == null){
				return 0;
			}
			
			return BPCommonUtil.defaultNull(bomPlan.Tonnage_Goal_Advisory_Net_Flows__c); 
		} 
	}
	
	public decimal tonnageGoalLending { 
		get{
			if(bomPlan == null){
				return 0;
			}
			
			return BPCommonUtil.defaultNull(bomPlan.Tonnage_Goal_Lending__c); 
		} 
	}
	
	public decimal tonnageGoalNetIncome { 
		get{
			if(bomPlan == null){
				return 0;
			}
			return BPCommonUtil.defaultNull(bomPlan.Tonnage_Goal_Net_Income__c); 
		} 
	}
	
    public BPBranchBusinessPlanCon() {
    	index = ApexPages.currentPage().getParameters().get('index');
    	String operation = ApexPages.currentPage().getParameters().get('operation');
    	selectedTab = ApexPages.currentPage().getParameters().get('selectedTab');
        String bomPlanId = ApexPages.currentPage().getParameters().get('pid');
		if(bomPlanId == null || bomPlanId == ''){
            msgStr = 'Invalid BoM Plan Id.';
            BPMessageUtil.addInfoMessage(msgStr);
        }
        else {
            bomPlan = BPBranchBusinessPlanUtil.getBoMPlanById(bomPlanId);
            year = Integer.valueOf(bomPlan.Year_Text__c) - 1;
            list<String> strList = new list<String>();
            //wether it is the first time into vf page
            if(index != '1') {
            	msgStr = BPBranchBusinessPlanUtil.getPlanNotMeetGoalMessage(bomPlan);
            	if(msgStr != null) {
            		//BPMessageUtil.addInfoMessage(msgStr);
            		strList.add(msgStr);
            	}
	    	}
	    	index = '1';
	    	//wether click the save button on vf page
	    	if(operation == 'save') {
	    		//FA Goals have been saved.  Once all sections have been completed, click “Go Back to Plan”
	    		String msgStr1 = 'FA Goals have been saved.  Once all sections have been completed, click "Go Back to Plan".';
	    		strList.add(msgStr1);
	    		//BPMessageUtil.addInfoMessage(msgStr);
	    	}
	    	if(strList != null && strList.size() > 0) {
		    	for(integer i=strList.size()-1; i >= 0; i-- ) {
		    		BPMessageUtil.addInfoMessage(strList.get(i));
		    	}
	    	}
            //system.debug('***bomPlan: ' + bomPlan);
        }
    }
    
    //Create all the non-existing FA Goals and retrieve them out for display
    public void createAndDisplayFAGoals(){
    	if(bomPlan == null){
            msgStr = 'Invalid BoM Plan.';
            BPMessageUtil.addInfoMessage(msgStr);
        }else {
            //Create non-existing FA Goals, so every FA should have 1 goal
	        BPBranchBusinessPlanUtil.createNonExistingFAGoal4MainBranch(bomPlan.Main_Branch__c, bomPlan);
	        //Retrieve them into the property which will be consumed in the UI
	        faGoalMap = BPBranchBusinessPlanUtil.getFAGoal4BoMPlan(bomPlan.Id);
	        list<FA_Goal__c> tmpList = faGoalMap.values();
	        faGoalList = new list<FA_Goal__c>();
	        //faGoalList.sort();
	        Map<Id, sObject> recordtypeMap = BPQueryUtil.queryMap(null, 'RecordType', 'Name=\'Recruiting\'', null);
        	RecordType recordtype = null;
        	if(recordtypeMap != null && recordtypeMap.size()> 0) recordtype = (RecordType)recordtypeMap.values()[0];
        	FA_Goal__c fa_Goal = null;
	        for(FA_Goal__c fa : tmpList) {
	        	if(recordtype == null || fa.RecordType.Name != 'Recruiting') {
	        		faGoalList.add(fa);
	        	}else {
	        		fa_Goal = fa;
	        	}
	        }
	        faGoalList.sort();
	        if(fa_Goal != null) faGoalList.add(fa_Goal);
	        
	        Set<Id> contactIdSet = new Set<Id>();
	        for(FA_Goal__c fa : faGoalList) {
	        	contactIdSet.add(fa.FA__c);
	        }
	        //key: contact id; value: Ranking__c
	        Map<String, Ranking__c> rankingMap = BPBranchBusinessPlanUtil.getRanking4FAGoal(contactIdSet);
	        
	        wrapperList = BPBranchBusinessPlanUtil.getRanking4FAGoalList(faGoalList, rankingMap); 
	        wrapperList.sort();
	        //system.debug('====>>> ' + JSON.serialize(wrapperList));
	        List<Id> bomPlanIdList = new List<Id>{bomPlan.Id};
	        //get FA Goal aggregate data for vf display
	        AggregateResult[] arArray = FAGoalUtil.getFAGoalAggregateResult(bomPlanIdList);
	        //FA Goal Summary
	        FAGoalNewKeyHHs = 0; 
	        FAGoalAdvisory = 0;
	        FAGoalLending = 0;
	        FAGoalNetIncome = 0;
	        PriorNetIncome = 0;
	        PlanNetIncome = 0;
	        /**
	        decimal profitMargin = 0;
	        //Number(valueFormat($("#YTD_Profit_Margin").val())) >= 25?valueFormat($("#YTD_Profit_Margin").val()):25;
	        if(bomPlan.YTD_Profit_Margin__c == null) {
	        	profitMargin = 0.25;
	        }else {
		        if(bomPlan.YTD_Profit_Margin__c / 100 >= 0.25) {
		        	profitMargin = bomPlan.YTD_Profit_Margin__c;
		        }else {
		        	profitMargin = 0.25;
		        }
	        }
	        **/
	        decimal planProfitMargin = 0;
	        if(bomPlan.Plan_Profit_Margin__c != null) planProfitMargin = bomPlan.Plan_Profit_Margin__c;
	        //formate vf display data
	        if(arArray != null && arArray.size() > 0) {
				if(arArray[0].get('FAGoalNewKeyHHs') != null && arArray[0].get('FAGoalNewKeyHHs') != '') FAGoalNewKeyHHs = BPCommonUtil.getNumberFormat(arArray[0].get('FAGoalNewKeyHHs')+'', 0);
				if(arArray[0].get('FAGoalAdvisory') != null && arArray[0].get('FAGoalAdvisory') != '') FAGoalAdvisory = BPCommonUtil.getNumberFormat(arArray[0].get('FAGoalAdvisory')+'', 0);
				if(arArray[0].get('FAGoalLending') != null && arArray[0].get('FAGoalLending') != '') FAGoalLending = BPCommonUtil.getNumberFormat(arArray[0].get('FAGoalLending')+'', 0);
				if(arArray[0].get('FAGoalNetIncome') != null && arArray[0].get('FAGoalNetIncome') != '') FAGoalNetIncome = BPCommonUtil.getNumberFormat(arArray[0].get('FAGoalNetIncome')+'', 0);
				if(arArray[0].get('incomePrior') != null && arArray[0].get('incomePrior') != '') PriorNetIncome = BPCommonUtil.getNumberFormat(arArray[0].get('incomePrior')+'', 0);
				if(arArray[0].get('incomePlan') != null && arArray[0].get('incomePlan') != '') PlanNetIncome = BPCommonUtil.getNumberFormat(arArray[0].get('incomePlan')+'', 0) * planProfitMargin / 100;
				//BPCommonUtil.log('PlanNetIncome ------------- >>>> ', PlanNetIncome);
				//if(bomPlan.Allocated_Revenue__c != null) PlanNetIncome += BPCommonUtil.fromatString2Long(bomPlan.Allocated_Revenue__c+'');
				//if(bomPlan.Other_Revenue__c != null) PlanNetIncome += BPCommonUtil.fromatString2Long(bomPlan.Other_Revenue__c+'');
				//BPCommonUtil.log('PlanNetIncome ------------- >>>> ', PlanNetIncome);
	        }
	        
	        //system.debug('***faGoalMap: ' + faGoalMap);
        }
        //prepare help list for vf display
        helpList = BPBranchBusinessPlanUtil.getHelpList();
        newHeyHHsHelpList = new List<Branch_Business_Plan_Help__c>();
        advisoryHelpList = new List<Branch_Business_Plan_Help__c>();
        lendingHelpList = new List<Branch_Business_Plan_Help__c>();
        netIncomeHelpList = new List<Branch_Business_Plan_Help__c>();
        //filter help list by category
        for(Branch_Business_Plan_Help__c help : helpList) {
        	if(help.Category__c != null && help.Category__c == 'New Key HHs') {
        		help.Help_Link__c = BPCommonUtil.formatLink(help.Help_Link__c);
        		newHeyHHsHelpList.add(help);
        	}
        	if(help.Category__c != null && help.Category__c == 'Advisory') {
        		help.Help_Link__c = BPCommonUtil.formatLink(help.Help_Link__c);
        		advisoryHelpList.add(help);
        	} 
        	if(help.Category__c != null && help.Category__c == 'Lending') {
        		help.Help_Link__c = BPCommonUtil.formatLink(help.Help_Link__c);
        		lendingHelpList.add(help);
        	}
        	if(help.Category__c != null && help.Category__c == 'Net Income') {
        		help.Help_Link__c = BPCommonUtil.formatLink(help.Help_Link__c);
        		netIncomeHelpList.add(help);
        	}
        }
    }
    //save FA Goal
    public PageReference saveFAGoals() {
    	if(bomPlan == null){
            msgStr = 'Invalid BoM Plan.';
            BPMessageUtil.addInfoMessage(msgStr);
            return null;
        }
        
        
    	//validate before saving FA Goal
        if((bomPlan.Status__c == 'In Action' || bomPlan.Status__c == 'Closed') && (tonnageGoalNewKeyHHs > PlanNewKeyHHsRollupCompare 
														        		|| tonnageGoalAdvisoryNetFlows > PlanAdvisoryNetFlowsRollupCompare
														        		|| tonnageGoalLending > PlanLendingRollupCompare
														        		|| tonnageGoalNetIncome > PlanNetIncomeCompare)) {
        		
        		msgStr = BPBranchBusinessPlanUtil.getPlanNotMeetGoalMessage(bomPlan);//'Plan value must be more than goal value.';
            	BPMessageUtil.addErrorMessage(msgStr);
        		return null;
        }
        
        //Validate the fa goal values
        if(!validateFAGoals()){
        	msgStr = 'Please correct FA Plan Values before saving';
        	BPMessageUtil.addErrorMessage(msgStr);
        	return null;
        }
        
        if(faGoalList == null || faGoalList.size() < 1) return null;
        Recruiting_Metric__c recruitingMetric = Recruiting_Metric__c.getall().get(bomPlan.Year_Text__c);
        boolean flag = false;
        FA_Goal__c recruitingFAGoal;
        for(FA_Goal__c fa : faGoalList) {
        	if(fa.RecordType != null && fa.RecordType.Name == 'Recruiting'){
	        	flag = true;
	        	recruitingFAGoal = fa;
        	}
        	String tmpStr = '0';
        	if(fa.Plan_New_Key_HHs__c != null) {
        		tmpStr = fa.Plan_New_Key_HHs__c+'';
        	}
        	long tmp = BPCommonUtil.fromatString2Long(tmpStr);
        	fa.Plan_New_Key_HHs__c = tmp;
        }
        //created Recruiting FA Goal
        recruitingFAGoal = BPBranchBusinessPlanUtil.createRecruitingFAGoal(flag, recruitingFAGoal, bomPlan, recruitingMetric);
        update bomPlan;
        upsert recruitingFAGoal;
        upsert faGoalList;
        
        //prepare URL parameter before redirection
        PageReference pr = Page.BPBranchBusinessPlan;
        pr.getParameters().put('pid',bomPlan.Id);
        pr.getParameters().put('selectedTab',selectedTab);
        pr.getParameters().put('index',index);
        pr.getParameters().put('operation','save');
        pr.setRedirect(true);
        return pr;
    }
    public String recruitedInputClass {get;set;}
    public String recruitedErrorMessage {get;set;}
    public String attritedInputClass {get;set;}
    public String attritedErrorMessage {get;set;}
    //validate vf input data before save all FA Goals
    private Boolean validateFAGoals(){
    	Boolean result = true;
    	
    	Decimal capValue = BPCommonUtil.getNumberFormat(planValueCap.T12_Recruited__c, 0);
        if(bomPlan.Plan_T12_Recruited__c > capValue) {
        	recruitedInputClass = 'error';
        	recruitedErrorMessage = 'Number cannot exceed ' + BPCommonUtil.formatNumber(capValue);
           	result = false;
        }
        else if(bomPlan.Plan_T12_Recruited__c < 0){
        	recruitedInputClass = 'error';
        	recruitedErrorMessage = 'Number cannot be negative';
           	result = false;
        }
        else{
        	recruitedInputClass = '';
        	recruitedErrorMessage = '';
        }
        
        capValue = BPCommonUtil.getNumberFormat(planValueCap.T12_Attrited__c, 0);
        if(bomPlan.Plan_T12_Attrited__c > capValue) {
        	attritedInputClass = 'error';
        	attritedErrorMessage = 'Number cannot exceed ' + BPCommonUtil.formatNumber(capValue);
           	result = false;
        }
        else if(bomPlan.Plan_T12_Attrited__c < 0){
        	attritedInputClass = 'error';
        	attritedErrorMessage = 'Number cannot be negative';
           	result = false;
        }
        else{
        	attritedInputClass = '';
        	attritedErrorMessage = '';
        }
    	
    	for(BPBranchBusinessPlanUtil.FAGoalWrapper wrapper: wrapperList){
    		
    		capValue = BPCommonUtil.getNumberFormat(planValueCap.New_Key_HHs__c, 0);
    		if(wrapper.faGoal.Plan_New_Key_HHs__c > capValue && wrapper.faGoal.RecordType.Name != 'Recruiting'){
    			wrapper.newKeyHHsInputClass = 'error';
    			wrapper.newKeyHHsErrorMessage = 'Number cannot exceed ' + BPCommonUtil.formatNumber(capValue);
    			result = false;
    		}
    		else{
    			wrapper.newKeyHHsInputClass = '';
    			wrapper.newKeyHHsErrorMessage = '';
    		}
    		
    		capValue = BPCommonUtil.getNumberFormat(planValueCap.advisory__c, 0);
    		if(wrapper.faGoal.Plan_Advisory_Net_Flows__c > capValue && wrapper.faGoal.RecordType.Name != 'Recruiting'){
    			wrapper.advisoryInputClass = 'error';
    			wrapper.advisoryErrorMessage = 'Number cannot exceed ' + BPCommonUtil.formatNumber(capValue);
    			result = false;
    		}
    		else{
    			wrapper.advisoryInputClass = '';
    			wrapper.advisoryErrorMessage = '';
    		}
    		
    		capValue = BPCommonUtil.getNumberFormat(planValueCap.Lending__c, 0);
    		if(wrapper.faGoal.Plan_Lending__c > capValue && wrapper.faGoal.RecordType.Name != 'Recruiting'){
    			wrapper.lendingInputClass = 'error';
    			wrapper.lendingErrorMessage = 'Number cannot exceed ' + BPCommonUtil.formatNumber(capValue);
    			result = false;
    		}
    		else{
    			wrapper.lendingInputClass = '';
    			wrapper.lendingErrorMessage = '';
    		}
    		
    		capValue = BPCommonUtil.getNumberFormat(planValueCap.Net_Income__c, 0);
    		if(wrapper.faGoal.Plan_Net_Income__c > capValue && wrapper.faGoal.RecordType.Name != 'Recruiting'){
    			wrapper.netIncomeInputClass = 'error';
    			wrapper.netIncomeErrorMessage = 'Number cannot exceed ' + BPCommonUtil.formatNumber(capValue);
    			result = false;
    		}
    		else{
    			wrapper.netIncomeInputClass = '';
    			wrapper.netIncomeErrorMessage = '';
    		}
    	}
    	return result;
    }
    
    public PageReference cancel(){
    	if(bomPlan == null) {
    		msgStr = 'Invalid BoM Plan.';
            BPMessageUtil.addInfoMessage(msgStr);
            return null;
    	}
        PageReference pr = new PageReference('/' + bomPlan.Id);
        return pr;
    }
    /***
    public PageReference createQuadrantActionPlans(){
        PageReference pr = Page.BPCreateQuadrantActionPlan;
        pr.getParameters().put('pid',bomPlan.Id);
        return pr;
    }
    
    public PageReference createFAActionPlan(){
        String faGoalId = ApexPages.currentPage().getParameters().get('faGoalId');
        
        if(faGoalId == null || faGoalId == '') {
            msgStr = 'Invalid Action Plan Id.';
            BPMessageUtil.addInfoMessage(msgStr);
            return null;
        }
        
        FA_Goal__c faGoal = faGoalMap.get(faGoalId);
        Action_Plan__c ap = BPBranchBusinessPlanUtil.getActionPlanByFAGoalId(faGoalId);
        
        if(ap == null){ //If the action plan doesn't exist, create it
            ap = BPBranchBusinessPlanUtil.createActionPlan(bomPlan.Id, bomPlan.Year_Text__c, faGoalId, faGoal.FA__r.Name);
            insert ap;
        }

        return new ApexPages.StandardController(ap).view();
    }
    **/
}