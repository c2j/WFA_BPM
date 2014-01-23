/**************************************************************************************************
 * Purpose: Branch Business Plan Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-10-28
 * Modify History:
 * Keen    2013-10-28    Created
***************************************************************************************************/

global class BPBranchBusinessPlanUtil {

    
    //public static final Set<String> typeSet = new Set<String>{'Market Manager', 'Branch Manager', 'Complex Manager'};
    
    public static Integer MAX_RECRUITED_NUMBER = 50000000;
    
    public static Integer MAX_ATTRITED_NUMBER = 50000000;
    
    public static String CHANNEL = 'PCG';
    
    public static final String PROFIT_FORMULA = 'pf';
    
    public static final Set<String> faTypeSet = new Set<String>{'FA', 'FA in Training', 'Branch Manager', 'Branch Supervisor', 'Complex Manager', 'Assistant Branch Manager'};

    public static BoM_Plan__c getBoMPlanById(String bomPlanId){
        return (BoM_Plan__c)BPQueryUtil.query(bomPlanId, 'BoM_Plan__c'); 
    }
    
    public static List<Branch_Business_Plan_Help__c> getHelpList(){
        return (List<Branch_Business_Plan_Help__c>)BPQueryUtil.query(null, 'Branch_Business_Plan_Help__c', null, 'Name');
    }

    public static Map<Id, Contact> getAllFA4MainBranch(String mainBranchId){
    	
    	Set<String> typeSet = FA_Goal_Customer_Type__c.getall().keySet();
    	if(typeSet == null || typeSet.size() == 0) {
    		typeSet = faTypeSet;
    	}
    	Map<Id, Contact> contactMap = new Map<Id, Contact>([
    		Select Id
    		, Name
    		From Contact
    		Where Account.Main_Branch__c = :mainBranchId
    		And Terminated__c = 'No'
    		And Type__c IN : typeSet
    	]);
    	
    	return contactMap;
    }
    //gel all FA Goals by BoM Plan id
    public static Map<Id, FA_Goal__c> getExistingFAGoal4MainBranch(String bomPlanId){
    	//dynamic SOQL, select all BoM Plan fields 
    	Map<Id, sObject> sObjMap = BPQueryUtil.queryMap(null, 'FA_Goal__c', 'BoM_Plan__c = \'' + bomPlanId + '\'', 'Name'); 
    	
    	Map<Id, FA_Goal__c> faGoalMap = new Map<Id, FA_Goal__c>();
    	faGoalMap.putAll((List<FA_Goal__c>)sObjMap.values());
    	return faGoalMap;
    }
    //get all non exist contact for fa goal
    public static Map<Id, Contact> getNonExistingFA4MainBranch(String mainBranchId, String bomPlanId){
    	//get all contact map by main branch id
    	Map<Id, Contact> contactMap = getAllFA4MainBranch(mainBranchId);
    	//get all fa goals map by bom plan id
    	Map<Id, FA_Goal__c> faGoalMap = getExistingFAGoal4MainBranch(bomPlanId);
    	
    	Set<Id> contactIdSetWithFAGoal = new Set<Id>();
    	for(FA_Goal__c faGoal : faGoalMap.values()){
    		contactIdSetWithFAGoal.add(faGoal.FA__c);
    	}
		//filter out all non exist contact for create fa goal
		Map<Id, Contact> contactWoFAGoalMap = new Map<Id, Contact>();
		for(Contact contact : contactMap.values()){
			if(!contactIdSetWithFAGoal.contains(contact.Id)){
				contactWoFAGoalMap.put(contact.Id, contact);
			}
		}
		return contactWoFAGoalMap;
    }
    //create fa goal instance
    public static FA_Goal__c createFAGoal(String year, String contactName, BoM_Plan__c bomPlan, String contactId, Object[] dataArray, Map<String, Ranking__c> rankingMap){
    	FA_Goal__c faGoal = new FA_Goal__c();
    	faGoal.Name = year + ' Goal - ' + contactName;
    	faGoal.BoM_Plan__c = bomPlan.Id;
    	faGoal.FA__c = contactId;
    	Map<Id, sObject> recordtypeMap = BPQueryUtil.queryMap(null, 'RecordType', 'Name=\'Master\'', null);
        RecordType recordtype = null;
        if(recordtypeMap != null && recordtypeMap.size()> 0) recordtype = (RecordType)recordtypeMap.values()[0];
        if(recordtype != null) faGoal.RecordTypeId = recordtype.Id;
    	//copy ranking data for new fa goal
    	if(rankingMap.containsKey(contactId)) {
	    	faGoal.Ranking__c = rankingMap.get(contactId).Id;
	    	if(rankingMap.get(contactId).Primary_Objective__c != null && rankingMap.get(contactId).Primary_Objective__c != '') {
		    	faGoal.Primary_Objective__c = rankingMap.get(contactId).Primary_Objective__c;
	    	}
	    	if(rankingMap.get(contactId).Quadrant__c != null) {
		    	faGoal.BP_Quadrant__c = rankingMap.get(contactId).Quadrant__c + '';
	    	}
	    	if(rankingMap.get(contactId).FA_Goal_New_Key_HHs__c != null) {
	    		faGoal.FA_Goal_New_Key_HHs__c = rankingMap.get(contactId).FA_Goal_New_Key_HHs__c;
	    	}
	    	if(rankingMap.get(contactId).FA_Goal_Advisory_Flows__c != null) {
	    		faGoal.FA_Goal_Advisory_Net_Flows__c = rankingMap.get(contactId).FA_Goal_Advisory_Flows__c;
	    	}
	    	if(rankingMap.get(contactId).FA_Goal_Lending__c != null) {
	    		faGoal.FA_Goal_Lending__c = rankingMap.get(contactId).FA_Goal_Lending__c;
	    	}
	    	if(rankingMap.get(contactId).FA_Goal_Revenue__c != null) {
	    		faGoal.FA_Goal_Net_Income__c = rankingMap.get(contactId).FA_Goal_Revenue__c;
	    	}
	    	if(rankingMap.get(contactId).Prior_Year_Advisory_Revenue__c != null) faGoal.Prior_Year_Advisory_Revenue__c = rankingMap.get(contactId).Prior_Year_Advisory_Revenue__c;
	    	
    	}
    	//set fa goal field from data array
    	if(dataArray != null && dataArray.size() > 0) {
	    	faGoal.Prior_Advisory_Net_Flows__c = Double.valueOf(dataArray[0]);
	    	faGoal.Prior_New_Key_HHs__c = Double.valueOf(dataArray[1]);
	    	faGoal.Prior_Lending__c = Double.valueOf(dataArray[2]);
	    	faGoal.Prior_Net_Income__c = Double.valueOf(dataArray[3]);
	    	faGoal.YTD_Advisory_Net_Flows__c = Double.valueOf(dataArray[4]);
	    	faGoal.YTD_New_Key_HHs__c = Double.valueOf(dataArray[5]);
	    	faGoal.YTD_Lending__c = Double.valueOf(dataArray[6]);
	    	faGoal.YTD_Net_Income__c = Double.valueOf(dataArray[7]);
	    	faGoal.Annualized_Net_Income__c = Double.valueOf(dataArray[8]);
	    	
	    	faGoal.Annualized_New_Key_HHs__c = Double.valueOf(dataArray[9]);
	    	faGoal.Annualized_Advisory_Net_Flows__c = Double.valueOf(dataArray[10]);
	    	faGoal.Annualized_Lending__c = Double.valueOf(dataArray[11]);
	    	faGoal.Annualized_Net_Income__c = Double.valueOf(dataArray[12]);
	    	
	    	faGoal.BP_Quadrant__c = String.valueOf(dataArray[13]);
	    	faGoal.Primary_Objective__c = String.valueOf(dataArray[14]);
    	}
    	faGoal.OwnerId = bomPlan.OwnerId;
    	return faGoal;
    }
    //create recruiting fa goal
    public static FA_Goal__c createRecruitingFAGoal(boolean flag, FA_Goal__c faGoal, BoM_Plan__c bomPlan, Recruiting_Metric__c recruitingMetric) {
		Map<Id, sObject> recordtypeMap = BPQueryUtil.queryMap(null, 'RecordType', 'Name=\'Recruiting\'', null);
        RecordType recordtype = null;
        if(recordtypeMap != null && recordtypeMap.size()> 0) recordtype = (RecordType)recordtypeMap.values()[0];
        Main_Branch__c mainBranch = null;
        if(bomPlan.Main_Branch__c != null) {
	        mainBranch = (Main_Branch__c)BPQueryUtil.query(bomPlan.Main_Branch__c, 'Main_Branch__c');
        }
    	if(!flag) {
	    	faGoal =  new FA_Goal__c();//BPBranchBusinessPlanUtil.createFAGoal(bomPlan.Year_Text__c, '', bomPlan.Id, '', null);
	    	String faGoalName = bomPlan.Year_Text__c + ' Goal';
	    	if(mainBranch != null) {
	    		faGoalName += ' - ' + mainBranch.Name + ' - Recruiting Impact';
	    	}
	    	faGoal.Name = faGoalName;
    		faGoal.BoM_Plan__c = bomPlan.Id;
    		if(recordtype != null) faGoal.RecordTypeId = recordtype.Id;
    	}
    	decimal Plan_T12_Recruited = 0, Plan_T12_Attrited = 0; 
    	if(bomPlan.Plan_T12_Recruited__c != null) {
    		Plan_T12_Recruited = bomPlan.Plan_T12_Recruited__c;
    	}
    	if(bomPlan.Plan_T12_Attrited__c != null) {
    		Plan_T12_Attrited = bomPlan.Plan_T12_Attrited__c;
    	}
    	//New Key HHS (Plan)
    	if(recruitingMetric == null) {
    		faGoal.Plan_New_Key_HHs__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * 0, 0);
    	}else {
	    	faGoal.Plan_New_Key_HHs__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * recruitingMetric.New_Key_HHs__c, 0);
    	}
    	//Advisory (Plan)
    	if(recruitingMetric == null) {
	    	faGoal.Plan_Advisory_Net_Flows__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * 0, 0);
    	}else {
    		faGoal.Plan_Advisory_Net_Flows__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * recruitingMetric.Net_Advisory_Flows__c, 0);
    	}
    	//Lending (Plan)
    	if(recruitingMetric == null) {
    		faGoal.Plan_Lending__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * 0, 0);
    	}else {
    		faGoal.Plan_Lending__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * recruitingMetric.Lending_Originations__c, 0);
    	}
    	//Net Income (Plan)
    	if(recruitingMetric == null) {
    		faGoal.Plan_Net_Income__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * 0, 0);
    	}else {
    		faGoal.Plan_Net_Income__c = BPCommonUtil.getNumberFormat(Plan_T12_Recruited * recruitingMetric.Net_Income__c, 0);
    	} 
    	faGoal.OwnerId = bomPlan.OwnerId;
    	return faGoal; 
    }
    
    //create fa goal for bom plan
    public static void createNonExistingFAGoal4MainBranch(String mainBranchId, BoM_Plan__c bomPlan){
    	//get all non exist contact for creating fa goals
    	Map<Id, Contact> contactWoFAGoalMap = getNonExistingFA4MainBranch(mainBranchId, bomPlan.Id);
    	List<FA_Goal__c> newFAGoalList = new List<FA_Goal__c>();
    	Map<String, Ranking__c> rankingMap = new Map<String, Ranking__c>();
    	//get all rankings by contact id set
    	if(contactWoFAGoalMap != null && contactWoFAGoalMap.size() > 0) rankingMap = getRanking4FAGoal(contactWoFAGoalMap.keySet());
    	
    	for(Contact contact : contactWoFAGoalMap.values()) {
    		Object[] dataArray = createUpdateData(rankingMap, contact, bomPlan);
    		newFAGoalList.add(createFAGoal(bomPlan.Year_Text__c, contact.Name, bomPlan, contact.Id, dataArray, rankingMap));
    	}
    	
    	insert newFAGoalList;
    }
    //prepare update data for new fa goal
    public static Object[] createUpdateData(Map<String, Ranking__c> rankingMap, Contact contact, BoM_Plan__c bomPlan) {
    	Double priorAdvisoryNetFlows = 0, priorNewKeyHHs = 0, priorLending = 0, priorNetIncome = 0
    			  , YTDAdvisoryNetFlows = 0, YTDNewKeyHHs = 0, YTDLending = 0, YTDNetIncome = 0
    			  															 , annualizedNetIncome = 0;
		Double Annualized_New_Key_HHs_Anzld = 0
			 , Annualized_Advisory_Net_Flows_Anzld = 0
			 , Annualized_Lending_Anzld = 0
			 , Annualized_Net_Income_Anzld = 0;
		
		String BP_Quadrant = '0', BP_Goal = null;	 
		//copy ranking data to fa goal fields
		if(rankingMap != null && rankingMap.size() > 0 && rankingMap.containsKey(contact.Id)) {
			Ranking__c ranking = rankingMap.get(contact.Id);
			
			if(bomPlan.Year_Text__c != null 
						&& ranking.Advisory_as_of_Date__c != null 
						&& bomPlan.Year_Text__c == String.valueOf(ranking.Advisory_as_of_Date__c.year())) {
							
				priorAdvisoryNetFlows = ranking.Prior_Year_Advisory_Flows__c;
				YTDAdvisoryNetFlows = ranking.Advisory_YTD_Net_Flows__c;
			}
			
			if(bomPlan.Year_Text__c != null 
						&& ranking.New_Key_HHs_as_of_Date__c != null 
						&& bomPlan.Year_Text__c == String.valueOf(ranking.New_Key_HHs_as_of_Date__c.year())) {
							
				priorNewKeyHHs = ranking.Prior_Year_New_Key_HHs__c;
				YTDNewKeyHHs = ranking.New_Key_HHs__c;
			}
			
			if(bomPlan.Year_Text__c != null 
						&& ranking.Lending_as_of_Date__c != null 
						&& bomPlan.Year_Text__c == String.valueOf(ranking.Lending_as_of_Date__c.year())) {
							
				priorLending = ranking.Prior_Year_Lending_YTD__c;
				YTDLending = ranking.Lending_YTD__c;
			}
			
			if(bomPlan.Year_Text__c != null 
						&& ranking.Production_Data_As_Of_Date__c != null 
						&& bomPlan.Year_Text__c == String.valueOf(ranking.Production_Data_As_Of_Date__c.year())) {
							
				priorNetIncome = ranking.Prior_Year_Production__c;
				YTDNetIncome = ranking.Production_YTD__c;
				annualizedNetIncome = ranking.Annualized_Production__c;
			}
			if(ranking.New_Key_HHs__c != null) {
				Annualized_New_Key_HHs_Anzld = BPCommonUtil.defaultNull(ranking.New_Key_HHs__c) * BPCommonUtil.defaultNull(ranking.Anzld__c);
			} 
			
			if(ranking.Advisory_YTD_Net_Flows__c != null) {
				Annualized_Advisory_Net_Flows_Anzld = BPCommonUtil.defaultNull(ranking.Advisory_YTD_Net_Flows__c) * BPCommonUtil.defaultNull(ranking.Anzld__c);
			}  
			
			if(ranking.Lending_YTD__c != null) {
				Annualized_Lending_Anzld = BPCommonUtil.defaultNull(ranking.Lending_YTD__c) * BPCommonUtil.defaultNull(ranking.Anzld__c);
			} 
			
			//net income
			if(ranking.Production_YTD__c != null) {
				Annualized_Net_Income_Anzld = BPCommonUtil.defaultNull(ranking.Production_YTD__c) * BPCommonUtil.defaultNull(ranking.Anzld__c);
			} 
			
			//BP Quadrant this's a string on FA_Goal__C
			if(ranking.Quadrant__c != null) {
				BP_Quadrant = String.valueOf(BPCommonUtil.getNumberFormat(ranking.Quadrant__c, 0));
			}
			
			if(ranking.Primary_Objective__c != null) {
				BP_Goal = ranking.Primary_Objective__c;
			}
		}
		//set data into data array
		Object[] dataArray = new Object[]{priorAdvisoryNetFlows, priorNewKeyHHs, priorLending, priorNetIncome
											, YTDAdvisoryNetFlows, YTDNewKeyHHs, YTDLending, YTDNetIncome, annualizedNetIncome
											
											, Annualized_New_Key_HHs_Anzld
											, Annualized_Advisory_Net_Flows_Anzld
											, Annualized_Lending_Anzld
											, Annualized_Net_Income_Anzld
											
											, BP_Quadrant
											, BP_Goal
										};
    	return dataArray;
    }
    
    //get all ranking by contact id set
    public static Map<String, Ranking__c> getRanking4FAGoal(Set<Id> contactIdSet) {
    	//key: contact id; value: Ranking__c
    	Map<String, Ranking__c> rankingMap = new Map<String, Ranking__c>();
    	for(Ranking__c r : [Select 
    								 Prior_Year_New_Key_HHs__c
    								, New_Key_HHs_as_of_Date__c
    								, New_Key_HHs__c

    								, Lending_as_of_Date__c
    								, Prior_Year_Lending_YTD__c //This is Lending Credits
    								, Lending_YTD__c
    								
    								, Net_Asset_Flows_as_of_Date__c 
    								, Advisory_as_of_Date__c
    								, Prior_Year_Advisory_Flows__c
    								, Advisory_YTD_Net_Flows__c
    								
    								, Production_Data_As_Of_Date__c
    								, Production_YTD__c
    								, Prior_Year_Production__c 
    								, Annualized_Production__c
    								
    								, Quadrant__c
    								, Primary_Objective__c
    								
    								, FA_Goal_Advisory_Flows__c
    								, FA_Goal_Lending__c
    								, FA_Goal_New_Key_HHs__c
    								, FA_Goal_Revenue__c
    								
    								, Anzld__c
    								, Contact__c
    								, Name
    								, Id
    								
    								, Prior_Year_Advisory_Revenue__c
    						From Ranking__c
    						Where Contact__c IN : contactIdSet
    						]) {
    		rankingMap.put(r.Contact__c, r);
    	}
    	return rankingMap;
    }
    //prepare wrapper data for vf display
    public static List<FAGoalWrapper> getRanking4FAGoalList(List<FA_Goal__c>faGoalList, Map<String, Ranking__c> rankingMap) {
    	List<FAGoalWrapper> wrapperList = new List<FAGoalWrapper>();
    	for(FA_Goal__c fa : faGoalList) {
			boolean flag = true;
			if(fa.RecordType.Name != 'Recruiting' && fa.FA__c != null && !rankingMap.containskey(fa.FA__c)) {
				flag = false;
			}
    		if(fa.FA__c != null && rankingMap.containskey(fa.FA__c)) {
    			FAGoalWrapper wrapper = new FAGoalWrapper(rankingMap.get(fa.FA__c), fa, flag);
    			wrapperList.add(wrapper);
    		}else {
    			FAGoalWrapper wrapper = new FAGoalWrapper(null, fa, flag);
    			wrapperList.add(wrapper);
    		}
    	}
    	return wrapperList;
    }
    //get fa goal map by bom plan id
    public static Map<Id, FA_Goal__c> getFAGoal4BoMPlan(String bomPlanId){
    	Map<Id, FA_Goal__c> faGoalMap = new Map<Id, FA_Goal__c>([
    		Select Id, Name, 
    			FA__c, 
	            FA__r.AccountId,
	            FA__r.Account.Name,
	            FA__r.Name,
	            FA__r.Terminated__c,
	            //Plan_T12_Recruited__c,
	            //Plan_T12_Attrited__c,
	            
	            Prior_New_Key_HHs__c,
	            YTD_New_Key_HHs__c,
	            Annualized_New_Key_HHs__c,
	            Plan_New_Key_HHs__c,
	            
	            Prior_Advisory_Net_Flows__c,
	            YTD_Advisory_Net_Flows__c,
	            Annualized_Advisory_Net_Flows__c,
	            Plan_Advisory_Net_Flows__c,
	            
	            Prior_Lending__c,
	            YTD_Lending__c,
	            Annualized_Lending__c,
	            Plan_Lending__c,
	            
	            Prior_Net_Income__c,
	            YTD_Net_Income__c,
	            Annualized_Net_Income__c,
	            Plan_Net_Income__c,
	            Projected_Growth__c,
	            
	            BoM_Plan__c,
	            RecordType.Name,
	            RecordTypeId,
	            
	            FA_Goal_New_Key_HHs__c, 
	            FA_Goal_Net_Income__c,
	            FA_Goal_Lending__c,
	            FA_Goal_Advisory_Net_Flows__c,
	            
	            Prior_Year_Advisory_Revenue__c
	            
            From FA_Goal__c
            Where BoM_Plan__c = :bomPlanId
            Order by FA__r.AccountId 
    	]);
    	return faGoalMap;
    }
    
    //******************************Start Complex/Market Plan ********************************************************************
    
    //Check if the child is the direct child of the parent. If a branch plan is related to a complex plan as well as a market plan. The relationship between the branch plan and market plan is indirect.
    public static Boolean isDirectChild(BoM_Plan__c parentPlan, BoM_Plan__c childPlan){
		return isDirectChild(parentPlan.Id, childPlan);
	}
	
	public static Boolean isDirectChild(Id parentPlanId, BoM_Plan__c childPlan){
		if(childPlan.Region_Plan__c == parentPlanId && (childPlan.Sub_Supl_Complex_Plan__c!=null || childPlan.Market_Complex_Plan__c!=null)){
			//Indirect Children
			return false;
		}
		else if(childPlan.Market_Complex_Plan__c == parentPlanId && childPlan.Sub_Supl_Complex_Plan__c!=null){
			//Indirect Children
			return false;
		}		
		else{
			return true;
		}
	}
    
    //Branch Plan -> Complex Plan -> Market Plan -> Region Plan. It happens that the Branch Plans could be directedly associated with Market or Region Plan;
    //But It won't associate with both two parent levels (eg. complex and market)
    public static list<BoM_Plan__c> getFlatPlanList(ID parentPlanId){
    	
    	set<Id> planIdSet = new Set<Id>();
    	planIdSet.add(parentPlanId);
    	
    	
    	//The list contains all the market plan, complex plans or branch plans 
    	//(along with their children: complex plans and branch plans) directed associated with the parent plan.
    	//Suppose the parentPlanId is a region plan. The list contains all the market plans as main records and (complex plan, branch plans) as children.
    	//For children complex plan, it may have futher grandchildren which will be retrieved into another list
    	list<BoM_Plan__c> childPlanList = getChildPlanList(planIdSet);
    	
    	//Clear it to store new ones
    	planIdSet = new Set<Id>();
    	
    	//Suppose the parentPlanId is a region plan, planIdSet is a set of complex plans.
    	for(BoM_Plan__c plan : childPlanList){
    		for(BoM_Plan__c subPlan : plan.Complex_Plans__r){
    			planIdSet.add(subPlan.Id);
    		}
    	}
    	
    	system.debug('***childPlanList: ' + childPlanList.size() + ' ' + childPlanList);
    	
    	//Suppose the parentPlanId is a region plan and planIdSet is a set of complex plans. The list contains all the branch plans under complex plans
    	list<BoM_Plan__c> subChildPlanList = getChildPlanList(planIdSet);
    	system.debug('***subChildPlanList: ' + subChildPlanList.size() + ' ' + subChildPlanList);
    	
    	//Start to build the flat structure which is like:
    	//Market Plan 1
    	//	Complex Plan 1-1
    	//		Branch Plan 1-1-1
    	//		Branch Plan 1-1-2
    	//	Complex Plan 1-2 (No Child)
    	//Market Plan 2 (No Child)
    	//Complex Plan 3 (No Child)
    	//Branch Plan 4
    	//
    	//Market Plan 2
    	//...
    	list<BoM_Plan__c> flatPlanList = new list<BoM_Plan__c>();
    	for(BoM_Plan__c plan : childPlanList){//Market Plans: It's possible to have complex plans and branch plans under market plans
    		if(!isDirectChild(parentPlanId, plan)){
    			continue;
    		}
    		flatPlanList.add(plan);
    		for(BoM_Plan__c childPlan : plan.Complex_Plans__r){//Complex Plans: It's possible to have branch plans under market plans
    			if(!isDirectChild(plan, childPlan)){
	    			continue;
	    		}
    			childPlan.Name = getIndent(1) + childPlan.Name;
    			flatPlanList.add(childPlan);
    			for(BoM_Plan__c grandPlan : subChildPlanList){//Branch Plans: No Children
    				if(!isDirectChild(childPlan, grandPlan)){
		    			continue;
		    		}
					if(grandPlan.Sub_Supl_Complex_Plan__c == childPlan.Id){//It's possbile to have branch plans under complex plans
						grandPlan.Name = getIndent(2) + grandPlan.Name;
						flatPlanList.add(grandPlan);
					}
				}
    		}
    		
    		for(BoM_Plan__c childPlan : plan.BoM_Plans__r){//Branch Plans: No Children
    			if(!isDirectChild(plan, childPlan)){
	    			continue;
	    		}
    			childPlan.Name = getIndent(1) + childPlan.Name;
    			flatPlanList.add(childPlan);
    		}
    	}
    	
    	for(BoM_Plan__c plan : flatPlanList){
    		system.debug('*** FlatPlan: ' + plan.Name + ' : ' + plan.RecordTypeId);
    	}
    	
    	return flatPlanList;
    }
    
    public static String getIndent(Integer nLevel){
    	String indent = '';
    	for(Integer i = 0; i< nLevel; i++){
    		indent = '#' + indent;
    	}
    	return indent;
    }
    
    public static list<BoM_Plan__c> getChildPlanList(set<ID> parentPlanIdSet){
    	list<BoM_Plan__c> childPlanList = [
			Select Id, Name, RecordTypeId, Status__c, Finalized__c,
			Main_Branch__c,
	        Main_Branch__r.Name,
	        Sub_Supl_Complex__c,
	        Sub_Supl_Complex__r.Name,
	        Market_Complex__c,
	        Market_Complex__r.Name,
	        Region__c,
	        Region__r.Name,
	        
	        Sub_Supl_Complex_Plan__c,
	        Market_Complex_Plan__c,
	        Region_Plan__c,
	        
			Tonnage_Goal_Advisory_Net_Flows__c,
			Plan_Advisory_Net_Flows_Rollup__c,
			Plan_Advisory_Net_Flows_Approved__c,
			
			Tonnage_Goal_Lending__c,
			Plan_Lending_Rollup__c,
			Plan_Lending_Approved__c,
			
			Tonnage_Goal_New_Key_HHs__c,
			Plan_New_Key_HHs_Rollup__c,
			Plan_New_Key_HHs_Approved__c,
			
			Tonnage_Goal_Net_Income__c,
			Plan_Net_Income_Rollup_By_Revenue__c,
			Plan_Net_Income_Rollup_Text__c,
			Plan_Net_Income_Approved__c,
			
			Plan_T12_Recruited__c,
			Plan_T12_Attrited__c,
			Recruiting_Net__c,
			
			Plan_T12_Recruited_Approved__c,
			Plan_T12_Attrited_Approved__c,
			Recruiting_Net_Approved__c,
			
			(Select Status__c, Name, RecordTypeId, Finalized__c,
				Main_Branch__c,
		        Main_Branch__r.Name,
		        Sub_Supl_Complex__c,
		        Sub_Supl_Complex__r.Name,
		        Market_Complex__c,
		        Market_Complex__r.Name,
		        Region__c,
		        Region__r.Name,
		        
		        Sub_Supl_Complex_Plan__c,
		        Market_Complex_Plan__c,
		        Region_Plan__c,
	        
				Tonnage_Goal_Advisory_Net_Flows__c,
				Plan_Advisory_Net_Flows_Rollup__c,
				Plan_Advisory_Net_Flows_Approved__c,
				
				Tonnage_Goal_Lending__c,
				Plan_Lending_Rollup__c,
				Plan_Lending_Approved__c,
				
				Tonnage_Goal_New_Key_HHs__c,
				Plan_New_Key_HHs_Rollup__c,
				Plan_New_Key_HHs_Approved__c,
				
				Tonnage_Goal_Net_Income__c,
				Plan_Net_Income_Rollup_By_Revenue__c,
				Plan_Net_Income_Rollup_Text__c,
				Plan_Net_Income_Approved__c,
				
				Plan_T12_Recruited__c,
				Plan_T12_Attrited__c,
				Recruiting_Net__c,
				
				Plan_T12_Recruited_Approved__c,
				Plan_T12_Attrited_Approved__c,
				Recruiting_Net_Approved__c
				
				From BoM_Plans__r
			),
			(Select Status__c, Name, RecordTypeId, Finalized__c,
				Main_Branch__c,
		        Main_Branch__r.Name,
		        Sub_Supl_Complex__c,
		        Sub_Supl_Complex__r.Name,
		        Market_Complex__c,
		        Market_Complex__r.Name,
		        Region__c,
		        Region__r.Name, 
		        
		        Sub_Supl_Complex_Plan__c,
		        Market_Complex_Plan__c,
		        Region_Plan__c,
		        
				Tonnage_Goal_Advisory_Net_Flows__c,
				Plan_Advisory_Net_Flows_Rollup__c,
				Plan_Advisory_Net_Flows_Approved__c,
				
				Tonnage_Goal_Lending__c,
				Plan_Lending_Rollup__c,
				Plan_Lending_Approved__c,
				
				Tonnage_Goal_New_Key_HHs__c,
				Plan_New_Key_HHs_Rollup__c,
				Plan_New_Key_HHs_Approved__c,
				
				Tonnage_Goal_Net_Income__c,
				Plan_Net_Income_Rollup_By_Revenue__c,
				Plan_Net_Income_Rollup_Text__c,
				Plan_Net_Income_Approved__c,
				
				Plan_T12_Recruited__c,
				Plan_T12_Attrited__c,
				Recruiting_Net__c,
				
				Plan_T12_Recruited_Approved__c,
				Plan_T12_Attrited_Approved__c,
				Recruiting_Net_Approved__c
				
				From Complex_Plans__r
			),
			(Select Status__c, Name, RecordTypeId, Finalized__c,
				Main_Branch__c,
		        Main_Branch__r.Name,
		        Sub_Supl_Complex__c,
		        Sub_Supl_Complex__r.Name,
		        Market_Complex__c,
		        Market_Complex__r.Name,
		        Region__c,
		        Region__r.Name, 
		        
		        Sub_Supl_Complex_Plan__c,
		        Market_Complex_Plan__c,
		        Region_Plan__c,
		        
				Tonnage_Goal_Advisory_Net_Flows__c,
				Plan_Advisory_Net_Flows_Rollup__c,
				Plan_Advisory_Net_Flows_Approved__c,
				
				Tonnage_Goal_Lending__c,
				Plan_Lending_Rollup__c,
				Plan_Lending_Approved__c,
				
				Tonnage_Goal_New_Key_HHs__c,
				Plan_New_Key_HHs_Rollup__c,
				Plan_New_Key_HHs_Approved__c,
				
				Tonnage_Goal_Net_Income__c,
				Plan_Net_Income_Rollup_By_Revenue__c,
				Plan_Net_Income_Rollup_Text__c,
				Plan_Net_Income_Approved__c,
				
				Plan_T12_Recruited__c,
				Plan_T12_Attrited__c,
				Recruiting_Net__c,
				
				Plan_T12_Recruited_Approved__c,
				Plan_T12_Attrited_Approved__c,
				Recruiting_Net_Approved__c
				
				From Market_Plans__r
			)
			From BoM_Plan__c
			Where Region_Plan__c in :parentPlanIdSet
			Or Market_Complex_Plan__c in :parentPlanIdSet
			Or Sub_Supl_Complex_Plan__c in :parentPlanIdSet
		];
		
		return childPlanList;
    }
    
    public static list<BoM_Plan__c> getParentPlanList(set<Id> complexPlanIdSet, set<Id> marketPlanIdSet, set<Id> regionPlanIdSet){
    	set<Id> directParentIdSet = new set<Id>();
    	if(complexPlanIdSet.size() > 0){
    		directParentIdSet = complexPlanIdSet;
    	}
    	else if(marketPlanIdSet.size() > 0){
    		directParentIdSet = marketPlanIdSet;
    	}
    	else{
    		directParentIdSet = regionPlanIdSet;
    	}
    	
    	list<BoM_Plan__c> toUpdateParentPlanList = [
			Select Id, RecordTypeId,
			Tonnage_Goal_Advisory_Net_Flows__c,
			Plan_Advisory_Net_Flows_Rollup__c,
			Plan_Advisory_Net_Flows_Approved__c,
			
			Tonnage_Goal_Lending__c,
			Plan_Lending_Rollup__c,
			Plan_Lending_Approved__c,
			
			Tonnage_Goal_New_Key_HHs__c,
			Plan_New_Key_HHs_Rollup__c,
			Plan_New_Key_HHs_Approved__c,
			
			Tonnage_Goal_Net_Income__c,
			Plan_Net_Income_Rollup_By_Revenue__c,
			Plan_Net_Income_Rollup_Text__c,
			Plan_Net_Income_Approved__c,
			
			Plan_T12_Recruited__c,
			Plan_T12_Attrited__c,
			Recruiting_Net__c,
			
			Plan_T12_Recruited_Approved__c,
			Plan_T12_Attrited_Approved__c,
			Recruiting_Net_Approved__c,
			(Select Status__c, RecordTypeId,
				Tonnage_Goal_Advisory_Net_Flows__c,
				Plan_Advisory_Net_Flows_Rollup__c,
				Plan_Advisory_Net_Flows_Approved__c,
				
				Tonnage_Goal_Lending__c,
				Plan_Lending_Rollup__c,
				Plan_Lending_Approved__c,
				
				Tonnage_Goal_New_Key_HHs__c,
				Plan_New_Key_HHs_Rollup__c,
				Plan_New_Key_HHs_Approved__c,
				
				Tonnage_Goal_Net_Income__c,
				Plan_Net_Income_Rollup_By_Revenue__c,
				Plan_Net_Income_Rollup_Text__c,
				Plan_Net_Income_Approved__c,
				
				Plan_T12_Recruited__c,
				Plan_T12_Attrited__c,
				Recruiting_Net__c,
				
				Plan_T12_Recruited_Approved__c,
				Plan_T12_Attrited_Approved__c,
				Recruiting_Net_Approved__c,
				
				Market_Complex_Plan__c,
				Sub_Supl_Complex_Plan__c,
				Region_Plan__c				
				
				From BoM_Plans__r
			),
			(Select Status__c,  RecordTypeId,
				Tonnage_Goal_Advisory_Net_Flows__c,
				Plan_Advisory_Net_Flows_Rollup__c,
				Plan_Advisory_Net_Flows_Approved__c,
				
				Tonnage_Goal_Lending__c,
				Plan_Lending_Rollup__c,
				Plan_Lending_Approved__c,
				
				Tonnage_Goal_New_Key_HHs__c,
				Plan_New_Key_HHs_Rollup__c,
				Plan_New_Key_HHs_Approved__c,
				
				Tonnage_Goal_Net_Income__c,
				Plan_Net_Income_Rollup_By_Revenue__c,
				Plan_Net_Income_Rollup_Text__c,
				Plan_Net_Income_Approved__c,
				
				Plan_T12_Recruited__c,
				Plan_T12_Attrited__c,
				Recruiting_Net__c,
				
				Plan_T12_Recruited_Approved__c,
				Plan_T12_Attrited_Approved__c,
				Recruiting_Net_Approved__c,
				
				Market_Complex_Plan__c,
				Sub_Supl_Complex_Plan__c,
				Region_Plan__c
				
				From Complex_Plans__r
			),
			(Select Status__c, RecordTypeId,
				Tonnage_Goal_Advisory_Net_Flows__c,
				Plan_Advisory_Net_Flows_Rollup__c,
				Plan_Advisory_Net_Flows_Approved__c,
				
				Tonnage_Goal_Lending__c,
				Plan_Lending_Rollup__c,
				Plan_Lending_Approved__c,
				
				Tonnage_Goal_New_Key_HHs__c,
				Plan_New_Key_HHs_Rollup__c,
				Plan_New_Key_HHs_Approved__c,
				
				Tonnage_Goal_Net_Income__c,
				Plan_Net_Income_Rollup_By_Revenue__c,
				Plan_Net_Income_Rollup_Text__c,
				Plan_Net_Income_Approved__c,
				
				Plan_T12_Recruited__c,
				Plan_T12_Attrited__c,
				Recruiting_Net__c,
				
				Plan_T12_Recruited_Approved__c,
				Plan_T12_Attrited_Approved__c,
				Recruiting_Net_Approved__c,
				
				Market_Complex_Plan__c,
				Sub_Supl_Complex_Plan__c,
				Region_Plan__c
				
				From Market_Plans__r
			)
			From BoM_Plan__c
			Where Id in :directParentIdSet
		];
		
		return toUpdateParentPlanList;
    }
    
    //Get the manager's manager email for a sub complex/market or complex/market plan. The input plan won't be a Branch Manager Plan
    public static String getManagerEmail(BoM_Plan__c plan){
    	if(plan == null){
    		return null;
    	}
    	
    	if(!String.isBlank(plan.Sub_Supl_Complex__c)){
    		//Return the market/complex manager's email
    		return plan.Sub_Supl_Complex__r.Market_Complex__r.Manager_Market_Complex_Email__c;
    	}
    	else{
    		//Return the regional president's email
    		return plan.Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Email;
    	}
    }
    
    public static String getAssigneeEmail(BoM_Plan__c plan){
    	if(plan == null){
    		return null;
    	}
    	
    	return plan.Main_Branch__r.MB_Manager_Email__c;
    }
    
    
    public static String finalizePlan(String planId){
    	list<BoM_Plan__c> planList = [
    		Select Id, Status__c, Finalized__c,
    		Sub_Supl_Complex__c,
    		Sub_Supl_Complex__r.Market_Complex__r.Manager_Market_Complex_Email__c,
    		Market_Complex__c,
    		Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Email,
    		//Market_Complex__r.Region2__r.Regional_President__r.Email,
    		Main_Branch__c,
    		Main_Branch__r.MB_Manager_Email__c
    		, (
    			Select Status__c, Finalized__c, RecordTypeId
    			From BoM_Plans__r
    		)
    		, (
    			Select Status__c, Finalized__c, RecordTypeId
    			From Complex_Plans__r
    		)
    		, (
    			Select Status__c, Finalized__c, RecordTypeId
    			From Market_Plans__r
    		)
    		From BoM_Plan__c
    		Where Id = :planId
    	];
    	
    	if(planList.size()==0){
    		return 'Plan not found';
    	}
    	else if(planList[0].Finalized__c == true){
    		return 'Plan already finalized';
    	}
    	
    	Id mainBranchRTId = getBranchPlanRecordTypeId();
    	
    	String childPlanApprovedMsg = 'All the BoM plans must be approved before finalizing the Market/Complex plan';
    	String childPlanFinalizedMsg = 'All the complex plans must be finalized before finalizing the Market plan';
    	for(BoM_Plan__c plan : planList[0].BoM_Plans__r){
    		if(plan.RecordTypeId == mainBranchRTId){
    			if(plan.Status__c != 'In Action' && plan.Status__c != 'Closed'){
    				return childPlanApprovedMsg;
    			}
    		}    		
    		else if(plan.Finalized__c != true){
    			return childPlanFinalizedMsg;
    		}
    	}
    	
    	for(BoM_Plan__c plan : planList[0].Complex_Plans__r){
    		if(plan.RecordTypeId == mainBranchRTId){
    			if(plan.Status__c != 'In Action' && plan.Status__c != 'Closed'){
    				return childPlanApprovedMsg;
    			}
    		}    		
    		else if(plan.Finalized__c != true){
    			return childPlanFinalizedMsg;
    		}
    	}
    	
    	for(BoM_Plan__c plan : planList[0].Market_Plans__r){
    		if(plan.RecordTypeId == mainBranchRTId){
    			if(plan.Status__c != 'In Action' && plan.Status__c != 'Closed'){
    				return childPlanApprovedMsg;
    			}
    		}
    		else if(plan.Finalized__c != true){
    			return childPlanFinalizedMsg;
    		}
    	}
    	planList[0].Manager_Email__c = getManagerEmail(planList[0]);
    	planList[0].Finalized__c = true;
    	update planList;
    	
    	return null;
    }
    
    public static String submitPlan(String planId){
    	list<BoM_Plan__c> planList = [
    		Select Id, Status__c, RecordTypeId, Meet_Submit_Criteria__c, Skip_Approval__c,
    		Leadership_Plan_Completed__c,
    		Advisory_Net_Flows_Meet_Goal__c,
    		Lending_Meet_Goal__c,
    		New_Key_HHs_Meet_Goal__c,
    		NI_Comp__c,
    		Main_Branch__r.Manager_Main_Branch__c,
    		Main_Branch__r.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c,
    		Main_Branch__r.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c,
    		Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__c,
    		Main_Branch__c,
    		Main_Branch__r.MB_Manager_Email__c,
    		Action_Plan_Completed__c,
    		(
    			Select Id
    			From Leadership_Plans__r
    		)
    		From BoM_Plan__c
    		Where Id = :planId
    	];
    	
    	
    	if(planList.size()==0){
    		return 'Plan not found';
    	}
    	
    	BoM_Plan__c plan = planList[0];
    	
    	if(plan.Status__c == 'Closed'){
    		return 'Plan already closed';
    	}
    	
    	if(plan.Status__c == 'In Action' || plan.Status__c == 'Submitted'){
    		return 'Plan already submitted';
    	}
    	
    	Id mainBranchRTId = getBranchPlanRecordTypeId();
    	if(plan.RecordTypeId != mainBranchRTId){
    		return 'Only main branch plans can be submitted';
    	}
    	
    	boolean checkFlag = false;
    	
		if(plan.Status__c != 'In Progress'){
			BPMessageUtil.addInfoMessage('Please update the plan (FA Goals) prior to submission of the BoM Plan');
			checkFlag = true;
    		//return 'Please update the plan (FA Goals) prior to submission of the BoM Plan';
    	}    	
    	else if(!plan.Meet_Submit_Criteria__c){
    		String tmpMsg = getPlanNotMeetGoalMessage(plan);
    		if(tmpMsg != null) BPMessageUtil.addInfoMessage(tmpMsg);
    		checkFlag = true;
    		//return getPlanNotMeetGoalMessage(plan);
    	}
    	
    	if(!plan.Leadership_Plan_Completed__c && plan.Leadership_Plans__r.size() != 0){
    		BPMessageUtil.addInfoMessage('Please complete and submit the leadership plan prior to submission of the BoM Plan');
    		checkFlag = true;
    		//return 'Please complete and submit the leadership plan prior to submission of the BoM Plan';
    	}
    	
    	if(!plan.Action_Plan_Completed__c){
    		BPMessageUtil.addInfoMessage('Please complete FA Action Plan prior to BoM plan submission');
    		checkFlag = true;
    		//return 'Please complete FA Action Plan prior to BoM plan submission';
    	}
    	
    	if(checkFlag) return '';
    	//Start to check the manager of the mainbranch manager. If they are the same, automatically approve it
    	String managerId;
    	if(plan.Main_Branch__r.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c != null){
    		managerId = plan.Main_Branch__r.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c;
    	}
    	else if(plan.Main_Branch__r.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c != null){
    		managerId = plan.Main_Branch__r.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c;
    	}
    	else if(plan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__c != null){
    		managerId = plan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__c;
    	}
    	
    	plan.Assignee_Email__c = getAssigneeEmail(plan);
    	if(plan.Main_Branch__r.Manager_Main_Branch__c == managerId){
    		//Self Approval
    		plan.Skip_Approval__c = true;
    	}
    	update plan;
    	
    	// Create the approval request for the plan
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		if(plan.Skip_Approval__c){
			req.setComments('Self Approval');
		}
		else{
			req.setComments('Manager Approval');
		}
		req.setObjectId(plan.id);
		
    	// Submit the approval request for the plan
		Approval.ProcessResult resultList = Approval.process(req, false);
		if(!resultList.isSuccess()){
			return resultList.getErrors()[0].getMessage();
		}
    	
    	return null;
    }
    
    public static String getPlanNotMeetGoalMessage(BoM_Plan__c plan){
    	if(!plan.Meet_Submit_Criteria__c){
    		
    		//Start to compose the message indicates which metric (or all metrics) that fails the criteria
	    	String msg = '';
	    	if(!plan.Advisory_Net_Flows_Meet_Goal__c){
	    		if(msg != ''){
	    			msg = msg + ', ';
	    		}
	    		msg = msg + 'Advisory Net Flows';
	    	}
	    	
	    	if(!plan.Lending_Meet_Goal__c){
	    		if(msg != ''){
	    			msg = msg + ', ';
	    		}
	    		msg = msg + 'Lending';
	    	}
	    	
	    	if(!plan.New_Key_HHs_Meet_Goal__c){
	    		if(msg != ''){
	    			msg = msg + ', ';
	    		}
	    		msg = msg + 'New Key HHs';
	    	}
	    	
	    	if(!plan.NI_Comp__c){
	    		if(msg != ''){
	    			msg = msg + ', ';
	    		}
	    		msg = msg + 'Net Income';
	    	}
	    	
	    	//msg = msg + ' goal values can’t exceed plan values';
	    	//Plan must meet or exceed your PCG provided Goal.  Please complete (W, X,Y,Z) section(s) below.
	    	msg = 'Plan must meet or exceed your PCG provided Goal.  Please complete ' + msg + ' section(s) below.';
	    	return msg;
    	}
    	else{
    		return null;
    	}
    }
    
    public static Leadership_Plan__c getLeadershipPlan(String bomPlanId){
    	list<Leadership_Plan__c> leadershipPlanList = [Select Id
    		From Leadership_Plan__c
    		Where BoM_Plan__c = :bomPlanId];
    	
    	if(leadershipPlanList.size() == 0){
    		return null;
    	}
    	else{
    		return leadershipPlanList[0];
    	}
    }
    
    //******************************End Complex/Market Plan ********************************************************************


    //****************************** Admin BoM Plan ********************************************************************
    
    public static BoM_Plan_Group__c getBoMPlanGroup(String year){
    	list<BoM_Plan_Group__c> groupList = (list<BoM_Plan_Group__c>)BPQueryUtil.query(null, 'BoM_Plan_Group__c', 'Year__c = \''+ year +'\'', 'Name');
    	BoM_Plan_Group__c planGroup;
    	if(groupList.size() == 0){
    		planGroup = null;
    	}
    	else{
    		planGroup = groupList[0];
    	}
    	return planGroup;
    }
    
    public static list<BoM_Plan_Group__c> getBoMPlanGroupList(){
    	list<BoM_Plan_Group__c> groupList = (list<BoM_Plan_Group__c>)BPQueryUtil.query(null, 'BoM_Plan_Group__c', null, 'Year__c');
   	
    	system.debug('*** plan group list: ' + groupList);
    	return groupList;
    }
    
    //Init the Record Types
    public static Id getBoMPlanRecordTypeId(String recordTypeName){
    	list<RecordType> rtList = [select Id from RecordType where Name = :recordTypeName and SobjectType = 'BoM_Plan__c'];
    	if(rtList.size() == 0){
    		return null;
    	}
    	else{
    		return rtList[0].Id;
    	}
    }
    public static Id getBranchPlanRecordTypeId(){
    	return getBoMPlanRecordTypeId('BoM Plan');
    }
    public static Id getSubComplexPlanRecordTypeId(){
    	return getBoMPlanRecordTypeId('Sub / Supl Complex Plan');
    }
    public static Id getMarketComplexPlanRecordTypeId(){
    	return getBoMPlanRecordTypeId('Market / Complex Plan');
    }
    public static Id getRegionPlanRecordTypeId(){
    	return getBoMPlanRecordTypeId('Region Plan');
    }

    public static Id mbranchPlanRT;
    public static Id msubComplexPlanRT;
    public static Id mmarketPlanRT;
    public static Id mregionPlanRT;
	
    public static Id branchPlanRT{
    	get{
    		initRecordType();
	    	return mbranchPlanRT;
    	}
    }
    public static Id subComplexPlanRT{
    	get{
    		initRecordType();
	    	return msubComplexPlanRT;
    	}
    }
    public static Id marketPlanRT{
    	get{
    		initRecordType();
	    	return mmarketPlanRT;
    	}
    }
    public static Id regionPlanRT{
    	get{
    		initRecordType();
	    	return mregionPlanRT;
    	}
    }
    public static void initRecordType(){
    	if(String.isBlank(mbranchPlanRT)){
    		mbranchPlanRT = BPBranchBusinessPlanUtil.getBranchPlanRecordTypeId();
    	}
    	if(String.isBlank(msubComplexPlanRT)){
    		msubComplexPlanRT = BPBranchBusinessPlanUtil.getSubComplexPlanRecordTypeId();
    	}
    	if(String.isBlank(mmarketPlanRT)){
    		mmarketPlanRT = BPBranchBusinessPlanUtil.getMarketComplexPlanRecordTypeId();
    	}
    	if(String.isBlank(mregionPlanRT)){
    		mregionPlanRT = BPBranchBusinessPlanUtil.getRegionPlanRecordTypeId();
    	}
    }
    
    //End Init the Record Types
    
    //Create the missing Region plans for the year and return back a map combined with RegionId and RegionPlan
    public static map<Id, BoM_Plan__c> createRegionPlans(String year, String planGroupId){
    	
    	Id regionRTId = getRegionPlanRecordTypeId();
    	list<Region__c> regionList = [
    		Select Id
    		, Name
    		, (
    			Select Id
    			, Year_Text__c
    			From BoM_Plans__r
    			Where Year_Text__c = :year
    		)
    		, (Select Id, Name From BranchesAccountsR__r) 
    		From Region__c
    		Where Regional_President__r.Channel__c = :CHANNEL
    	];
    	
    	list<BoM_Plan__c> newRegionPlanList = new list<BoM_Plan__c>();
    	map<Id, BoM_Plan__c> regionPlanMap = new map<Id, BoM_Plan__c>();//RegionId and RegionPlan as a Map.
    	for(Region__c region : regionList){
    		
    		if(region.BranchesAccountsR__r == null || region.BranchesAccountsR__r.size() == 0) continue; 
    		
    		if(region.BoM_Plans__r.size() == 0){
    			BoM_Plan__c newPlan = new BoM_Plan__c();
    			newPlan.Name = 'Region Plan - ' + region.Name + ' - ' + year;
    			newPlan.BoM_Plan_Group__c = planGroupId;
    			newPlan.RecordTypeId = regionRTId;
    			newPlan.Region__c = region.Id;
    			newPlan.Finalized__c = false;
    			
    			newRegionPlanList.add(newPlan);
    			regionPlanMap.put(region.Id, newPlan);
    		}
    		else{
    			BoM_Plan__c existingPlan = region.BoM_Plans__r[0];
    			regionPlanMap.put(region.Id, existingPlan);
    		}
    	}
    	
    	insert newRegionPlanList;
    	
    	return regionPlanMap;
    }
    
    //Create the missing Market plans for the year and return back a map combined with MarketId and MarketPlan
    public static map<Id, BoM_Plan__c> createMarketPlans(String year, String planGroupId, map<Id, BoM_Plan__c> regionPlanMap){
    	
    	Id marketRTId = getMarketComplexPlanRecordTypeId();
    	list<Market_Complex__c> marketList = [
    		Select Id
    		, Name
    		, Manager_Market_Complex__r.Account.Region_Branch__c
    		, (
    			Select Id
    			, Year_Text__c
    			From BoM_Plans__r
    			Where Year_Text__c = :year
    		)
    		, (Select Id, Name From BranchesAccountsMC__r) 
    		From Market_Complex__c
    		Where Manager_Market_Complex__r.Channel__c = :CHANNEL
    		And Market_Complex_Close_Date__c = null
    	];
    	
    	list<BoM_Plan__c> newPlanList = new list<BoM_Plan__c>();
    	map<Id, BoM_Plan__c> planMap = new map<Id, BoM_Plan__c>();
    	for(Market_Complex__c market : marketList){
    		
    		if(market.BranchesAccountsMC__r == null || market.BranchesAccountsMC__r.size() == 0) continue; 
    		
    		if(market.BoM_Plans__r.size() == 0){
    			BoM_Plan__c newPlan = new BoM_Plan__c();
    			newPlan.Name = 'Market/Complex Plan - ' + market.Name + ' - ' + year;
    			newPlan.BoM_Plan_Group__c = planGroupId;
    			newPlan.RecordTypeId = marketRTId;
    			newPlan.Market_Complex__c = market.Id;
    			newPlan.Finalized__c = false;
    			
    			if(market.Manager_Market_Complex__r.Account.Region_Branch__c != null){
	    			BoM_Plan__c parentPlan = regionPlanMap.get(market.Manager_Market_Complex__r.Account.Region_Branch__c);
	    			if(parentPlan != null){
	    				newPlan.Region_Plan__c = parentPlan.Id;
	    			}
    			}
    			
    			newPlanList.add(newPlan);
    			planMap.put(market.Id, newPlan);
    		}
    		else{
    			BoM_Plan__c existingPlan = market.BoM_Plans__r[0];
    			planMap.put(market.Id, existingPlan);
    		}
    	}
    	
    	insert newPlanList;
    	
    	return planMap;
    }
    
    //Create the missing Sub Complex plans for the year and return back a map combined with SubComplex Id and Subcomplex Plan
    public static map<Id, BoM_Plan__c> createSubComplexPlans(String year, String planGroupId, map<Id, BoM_Plan__c> regionPlanMap, map<Id, BoM_Plan__c> marketPlanMap){
    	
    	Id subComplexRTId = getSubComplexPlanRecordTypeId();
    	list<Sub_Supl_Complex__c> subComplextList = [
    		Select Id
    		, Name
    		, Market_Complex__c
    		, Manager_Sub_Supl_Complex__r.Account.Region_Branch__c
    		, (
    			Select Id
    			, Year_Text__c
    			From BoM_Plans__r
    			Where Year_Text__c = :year
    		)
    		, (Select Id, Name From BranchesAccountsSSC__r)
    		From Sub_Supl_Complex__c
    		Where Manager_Sub_Supl_Complex__r.Channel__c = :CHANNEL
    		And Sub_Supl_Complex_Closed__c != true
    	];
    	
    	list<BoM_Plan__c> newPlanList = new list<BoM_Plan__c>();
    	map<Id, BoM_Plan__c> planMap = new map<Id, BoM_Plan__c>();
    	for(Sub_Supl_Complex__c subComplex : subComplextList) {
    		
    		if(subComplex.BranchesAccountsSSC__r == null || subComplex.BranchesAccountsSSC__r.size() == 0) continue; 
    		
    		if(subComplex.BoM_Plans__r.size() == 0){
    			BoM_Plan__c newPlan = new BoM_Plan__c();
    			newPlan.Name = 'Sub / Supl Complex Plan - ' + subComplex.Name + ' - ' + year;
    			newPlan.BoM_Plan_Group__c = planGroupId;
    			newPlan.RecordTypeId = subComplexRTId;
    			newPlan.Sub_Supl_Complex__c = subComplex.Id;
    			newPlan.Finalized__c = false;
    			
    			if(subComplex.Market_Complex__c != null){
    				BoM_Plan__c parentPlan = marketPlanMap.get(subComplex.Market_Complex__c);
	    			if(parentPlan != null){
	    				newPlan.Market_Complex_Plan__c = parentPlan.Id;
	    			}
    			}
    			if(subComplex.Manager_Sub_Supl_Complex__r.Account.Region_Branch__c != null){
    				BoM_Plan__c parentPlan = regionPlanMap.get(subComplex.Manager_Sub_Supl_Complex__r.Account.Region_Branch__c);
	    			if(parentPlan != null){
	    				newPlan.Region_Plan__c = parentPlan.Id;
	    			}
    			}    			
    			
    			newPlanList.add(newPlan);
    			planMap.put(subComplex.Id, newPlan);
    		}
    		else{
    			BoM_Plan__c existingPlan = subComplex.BoM_Plans__r[0];
    			planMap.put(subComplex.Id, existingPlan);
    		}
    	}
    	
    	insert newPlanList;
    	
    	return planMap;
    }
    
    //Create the missing main branch plans for the year and return back a map combined with Main Branch Id and Main Branch Plan
    public static map<Id, BoM_Plan__c> createMainBranchPlans(String year, String planGroupId
    															, map<Id, BoM_Plan__c> regionPlanMap
    															, map<Id, BoM_Plan__c> marketPlanMap
    															, map<Id, BoM_Plan__c> subComplexPlanMap){
    	
    	Id mainBranchRTId = getBranchPlanRecordTypeId();
    	list<Main_Branch__c> mainBranchList = [
    		Select Id
    		, Name
    		, Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__c
    		, Manager_Main_Branch__r.Account.Market_Complex_Branch__c
    		, Manager_Main_Branch__r.Account.Region_Branch__c
    		, (
    			Select Id
    			, Year_Text__c
    			, Main_Branch__r.Manager_Main_Branch__c
    			From BoM_Plans__r
    			Where Year_Text__c = :year
    		)
    		, (Select Id, Name From Accounts__r)
    		
    		From Main_Branch__c
    		Where Main_Branch_Channel__c =: CHANNEL
    		And Main_Branch_Close_Date__c = null
    	];
    	
    	list<BoM_Plan__c> newPlanList = new list<BoM_Plan__c>();
    	map<Id, BoM_Plan__c> planMap = new map<Id, BoM_Plan__c>();
    	set<Id> mainBranchIdSet = new set<Id>();
    	for(Main_Branch__c mainBranch : mainBranchList){
    		//Ignore the main branches with "Admin" Key word as the name
    		if((mainBranch.Name.indexOfIgnoreCase('Admin')>=0) || (mainBranch.Accounts__r == null || mainBranch.Accounts__r.size() == 0) ) continue;
    		
    		mainBranchIdSet.add(mainBranch.Id);
    		if(mainBranch.BoM_Plans__r.size() == 0){
    			BoM_Plan__c newPlan = new BoM_Plan__c();
    			newPlan.Name = 'Main Branch Plan - ' + mainBranch.Name + ' - ' + year;
    			newPlan.BoM_Plan_Group__c = planGroupId;
    			newPlan.RecordTypeId = mainBranchRTId;
    			newPlan.Main_Branch__c = mainBranch.Id;
    			newPlan.Status__c = 'Available';
    			
    			if(mainBranch.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__c != null){
    				BoM_Plan__c parentPlan = subComplexPlanMap.get(mainBranch.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__c);
	    			if(parentPlan != null){
	    				newPlan.Sub_Supl_Complex_Plan__c = parentPlan.Id;
	    			}
    			}
    			if(mainBranch.Manager_Main_Branch__r.Account.Market_Complex_Branch__c != null){
    				BoM_Plan__c parentPlan = marketPlanMap.get(mainBranch.Manager_Main_Branch__r.Account.Market_Complex_Branch__c);
	    			if(parentPlan != null){
	    				newPlan.Market_Complex_Plan__c = parentPlan.Id;
	    			}
    			}
    			if(mainBranch.Manager_Main_Branch__r.Account.Region_Branch__c != null){
    				BoM_Plan__c parentPlan = regionPlanMap.get(mainBranch.Manager_Main_Branch__r.Account.Region_Branch__c);
	    			if(parentPlan != null){
	    				newPlan.Region_Plan__c = parentPlan.Id;
	    			}
    			}
    			
    			newPlanList.add(newPlan);
    			planMap.put(mainBranch.Id, newPlan);
    		}
    		else{
    			BoM_Plan__c existingPlan = mainBranch.BoM_Plans__r[0];
    			planMap.put(mainBranch.Id, existingPlan);
    		}
    	}
    	
    	//Capturing metrics data for the newly created BoM Plans. Ignore the returned values because all in the newPlanList should be created 
    	BranchUtil.copyToBoMPlan(mainBranchIdSet, year, newPlanList);
    	
    	insert newPlanList;
    	
    	return planMap;
    }
    
    //Create the missing leadership plans for the year and return back a map combined with Branch Id and leadership Plan
    public static map<Id, Leadership_Plan__c> createLeadershipPlans(String year, String planGroupId
    															, map<Id, BoM_Plan__c> regionPlanMap
    															, map<Id, BoM_Plan__c> marketPlanMap
    															, map<Id, BoM_Plan__c> subComplexPlanMap
    															, map<Id, BoM_Plan__c> mainBranchPlanMap){
    	//get customer type from Custom Settings
    	Set<String> typeSet = Customer_Type_Info__c.getall().keySet();
    	//if null, set default customer type
    	if(typeSet == null || typeSet.size() == 0) {
    		typeSet = new Set<String>{'Branch Manager', 'Complex Manager', 'Market Manager'};
    	}
    	//get email from customer
    	Set<String> emailSet = new Set<String>();
    	for(Contact con : [
    					Select Id
    						  , Name 
    						  , Email
    					From Contact
    					Where Type__c IN: typeSet
    					AND Terminated__c = 'No'
    					AND Account.Main_Branch__r.Main_Branch_Channel__c =: CHANNEL
    					AND Email != null
    	]) {
    		emailSet.add(con.Email);
    	}
    	//build user map, key: email, value: user
    	map<String, User> userMap = new map<String, User>();
    	for(User u : [Select Id, Email From User Where Email IN : emailSet AND IsActive = true]) {
    		userMap.put(u.Email, u);
    	}
    	//create leadership plan from bom plan
    	map<Id, BoM_Plan__c> actionPlanMap = new map<Id, BoM_Plan__c>([Select Id
							    			, Year_Text__c
							    			, Main_Branch__r.Name
							    			, Main_Branch__r.Manager_Main_Branch__c
							    			, Main_Branch__r.Manager_Main_Branch__r.Email
							    			
							    			, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__c
							    			, Market_Complex__r.Manager_Market_Complex__c
							    			, Region__r.Regional_President__c
							    			From BoM_Plan__c
							    			Where Year_Text__c = :year]);
    	
    	map<String, Leadership_Plan__c> leaderShipPlanMap = getLeadershipPlanByYear(year);
    	list<Leadership_Plan__c> newPlanList = new list<Leadership_Plan__c>();
    	map<Id, Leadership_Plan__c> planMap = new map<Id, Leadership_Plan__c>();
    	//created leadership_plan from bom_plan
    	for(BoM_Plan__c bp : [Select Main_Branch__r.RecordTypeId
    							, Main_Branch__r.Manager_Main_Branch__c
    							, Main_Branch__r.Manager_Main_Branch__r.Name
    							, Main_Branch__r.Manager_Main_Branch__r.Email
    							
    							, Main_Branch__r.Name
    							, Main_Branch__c
    							, Year_Text__c
    							, Name 
    							, Sub_Supl_Complex_Plan__c
    							, Market_Complex_Plan__c
    							, Region_Plan__c
    						  From BoM_Plan__c 
    						  Where Year_Text__c =: year 
    						  And RecordTypeId =: branchPlanRT
    						  And Main_Branch__c != null]) {
    		//if can't find an user by email, then continue
    		String email = '';
    		if(bp.Main_Branch__c != null && bp.Main_Branch__r.Manager_Main_Branch__r != null && bp.Main_Branch__r.Manager_Main_Branch__r.Email != null) {
	    		email = bp.Main_Branch__r.Manager_Main_Branch__r.Email;
    		}
    		if(userMap != null && !userMap.containsKey(email)) continue;
    		
    		String key = year + '-' + bp.Main_Branch__r.Manager_Main_Branch__r.Name;
    		Id contactId = bp.Main_Branch__r.Manager_Main_Branch__c;
    		String mainBranchName = bp.Main_Branch__r.Name;
    		if(leaderShipPlanMap != null && !leaderShipPlanMap.containsKey(key) && !mainBranchName.toLowerCase().contains(PROFIT_FORMULA)) {
    			Leadership_Plan__c newPlan = new Leadership_Plan__c();
    			newPlan.Name = year + ' - ' + bp.Main_Branch__r.Manager_Main_Branch__r.Name;
    			newPlan.BoM_Plan__c = bp.Id;
    			
    			//Associate with Complex, Market and Region Plan as well
    			/*
    			newPlan.Sub_Supl_Complex_Plan__c = bp.Sub_Supl_Complex_Plan__c;
    			newPlan.Market_Complex_Plan__c = bp.Market_Complex_Plan__c;
    			newPlan.Region_Plan__c = bp.Region_Plan__c;*/
    			
    			newPlan.BoM_Plan_Group__c = planGroupId;
    			newPlan.FA__c = contactId;
    			newPlan.Status__c = 'Available';
    			newPlanList.add(newPlan);
    			leaderShipPlanMap.put(key, newPlan);
    		}else {
    			if(leaderShipPlanMap != null && leaderShipPlanMap.containsKey(key)) {
	    			Leadership_Plan__c existingPlan = leaderShipPlanMap.get(key);
	    			planMap.put(contactId, existingPlan);
    			}
    		}
    		
    	}
    	
    	for(Contact con : [
    					Select Id
    						  , Name 
    						  , Email
    						  , Account.Id
    						  , Account.Main_Branch__c
    						  , Account.Sub_Supl_Complex_Branch__c
    						  , Account.Market_Complex_Branch__c
    						  , Account.Region_Branch__c
    						  , AccountId 
    					From Contact
    					Where Type__c IN: typeSet
    					AND Terminated__c = 'No'
    					AND Account.Main_Branch__r.Main_Branch_Channel__c =: CHANNEL
    					AND Email != null
    	]) {
    		if(userMap != null && !userMap.containsKey(con.Email)) continue;
    		String key = year + '-' + con.Name;
    		if(leaderShipPlanMap != null && !leaderShipPlanMap.containsKey(key)) {
    			Leadership_Plan__c newPlan = new Leadership_Plan__c();
    			newPlan.Name = year + ' - ' + con.Name;
    			newPlan.BoM_Plan_Group__c = planGroupId;
    			newPlan.FA__c = con.Id;
    			//newPlan.Branch__c = con.Account.Id;
    			newPlan.Status__c = 'Available';
    			if(con.Account.Main_Branch__c != null && mainBranchPlanMap.containsKey(con.Account.Main_Branch__c)){
    				BoM_Plan__c tmp = mainBranchPlanMap.get(con.Account.Main_Branch__c);
    				BoM_Plan__c parentPlan = actionPlanMap.get(tmp.Id);
    				if(parentPlan != null && parentPlan.Main_Branch__r != null && parentPlan.Main_Branch__r.Manager_Main_Branch__c == con.Id
    																		   && !parentPlan.Main_Branch__r.Name.toLowerCase().contains(PROFIT_FORMULA)) {
    					newPlan.BoM_Plan__c = parentPlan.Id;
    				}
    			}
    			else if(con.Account.Sub_Supl_Complex_Branch__c != null && subComplexPlanMap.containsKey(con.Account.Sub_Supl_Complex_Branch__c)){
    				BoM_Plan__c tmp = subComplexPlanMap.get(con.Account.Sub_Supl_Complex_Branch__c);
    				BoM_Plan__c parentPlan = actionPlanMap.get(tmp.Id);
    				if(parentPlan != null && parentPlan.Sub_Supl_Complex__r != null && parentPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__c == con.Id) {
    					newPlan.BoM_Plan__c = parentPlan.Id;
    				}
    			}
    			else if(con.Account.Market_Complex_Branch__c != null && marketPlanMap.containsKey(con.Account.Market_Complex_Branch__c)){
    				BoM_Plan__c tmp = marketPlanMap.get(con.Account.Market_Complex_Branch__c);
    				BoM_Plan__c parentPlan = actionPlanMap.get(tmp.Id);
    				if(parentPlan != null && parentPlan.Market_Complex__r != null && parentPlan.Market_Complex__r.Manager_Market_Complex__c == con.Id) {
    					newPlan.BoM_Plan__c = parentPlan.Id;
    				}
    			}
    			else if(con.Account.Region_Branch__c != null && regionPlanMap.containsKey(con.Account.Region_Branch__c)){
    				BoM_Plan__c tmp = regionPlanMap.get(con.Account.Region_Branch__c);
    				BoM_Plan__c parentPlan = actionPlanMap.get(tmp.Id);
    				if(parentPlan != null && parentPlan.Region__r != null && parentPlan.Region__r.Regional_President__c == con.Id) {
    					newPlan.BoM_Plan__c = parentPlan.Id;
    				}
    			}
    			newPlanList.add(newPlan);
    			planMap.put(con.Id, newPlan);
    		}else {
    			if(leaderShipPlanMap != null && leaderShipPlanMap.containsKey(key)) {
	    			Leadership_Plan__c existingPlan = leaderShipPlanMap.get(key);
	    			planMap.put(con.Id, existingPlan);
    			}
    		}
    	}
    	/***
    	for(Account branch : branchList){
    		if(branch.Leadership_Plans__r.size() == 0) {
    			Leadership_Plan__c newPlan = new Leadership_Plan__c();
    			newPlan.Name = 'Leadership Plan - ' + branch.Name + ' - ' + year;
    			newPlan.BoM_Plan_Group__c = planGroupId;
    			newPlan.Branch__c = branch.Id;
    			newPlan.Status__c = 'Available';
    			
    			if(branch.Main_Branch__c != null){
    				BoM_Plan__c parentPlan = mainBranchPlanMap.get(branch.Main_Branch__c);
	    			if(parentPlan != null){
	    				newPlan.BoM_Plan__c = parentPlan.Id;
	    			}
    			}
    			
    			newPlanList.add(newPlan);
    			planMap.put(branch.Id, newPlan);
    		}else {
    			Leadership_Plan__c existingPlan = branch.Leadership_Plans__r[0];
    			planMap.put(branch.Id, existingPlan);
    		}
    	}
    	****/
    	insert newPlanList;
    	
    	return planMap;
    }
    
    public static BoM_Plan_Group__c createPlanGroup(String year){
    	//If the plan group for that year doesn't exist, create it
    	BoM_Plan_Group__c planGroup = getBoMPlanGroup(year);
    	if(planGroup == null){
    		planGroup = new BoM_Plan_Group__c();
    		planGroup.Name = 'BoM Plan Group - ' + year;
    		planGroup.Year__c = year;
    		planGroup.Status__c = 'Available';
    		insert planGroup;
    	}
    	return planGroup;
    }
    
    
    
    public static BoM_Plan_Group__c getBoMPlanGroupByYear(String year){
    	
    	list<BoM_Plan_Group__c> planGroupList = [
    		Select Id, Name
    		, (
				Select Id, Name, Year_Text__c, Status__c
				From BoM_Plans__r
			)
			, (
				Select Id, Name, Year_Text__c, Status__c
				From Leadership_Plans__r
			)
    		From BoM_Plan_Group__c
    		Where Year__c = :year
    	];
    	
    	if(planGroupList.size() == 0){
    		return null;
    	}
    	else{
    		system.debug('*** Number of planGroupList: ' + planGroupList.size());
    		return planGroupList[0];
    	}
    }
    
    public static String closeBoMPlans(String year){
    	BoM_Plan_Group__c planGroup = getBoMPlanGroupByYear(year);
    	if(planGroup == null){
    		return 'Please select the year with BoM Plan.';
    	}
    	
    	planGroup.Status__c = 'Closed';
    	for(BoM_Plan__c bomPlan : planGroup.BoM_Plans__r){
    		if(bomPlan.Status__c != 'Closed'){
    			bomPlan.Status__c = 'Closed';
    		}
    	}
    	
    	for(Leadership_Plan__c lsPlan : planGroup.Leadership_Plans__r){
    		if(lsPlan.Status__c != 'Closed'){
    			lsPlan.Status__c = 'Closed';
    		}
    	}
    	
    	update planGroup.Bom_Plans__r;
    	update planGroup.Leadership_Plans__r;
    	update planGroup;
    	
    	return 'BoM Plans for ' + year + ' were successfully closed';
    }
    
    public static String cleanupBoMPlans(String year){
    	BoM_Plan_Group__c planGroup = getBoMPlanGroupByYear(year);
    	if(planGroup == null){
    		return 'Please select the year with BoM Plan.';
    	}
    	
    	set<String> bomPlanIdSet = new set<String>();
    	for(BoM_Plan__c bomPlan : planGroup.BoM_Plans__r){
    		bomPlanIdSet.add(bomPlan.Id);
    	}
    	
    	list<FA_Goal__c> faGoalList = [
    		Select Name
    		From FA_Goal__c
    		Where BoM_Plan__c in :bomPlanIdSet
    	];
    	
    	list<Action_Plan__c> actionPlanList = [
    		Select Id, Name
    		From Action_Plan__c
    		Where BoM_Plan__c IN :bomPlanIdSet
    	];
    	delete actionPlanList;
    	delete faGoalList;
    	delete planGroup.BoM_Plans__r;
    	delete planGroup.Leadership_Plans__r;
    	delete planGroup;    	
    	
    	return 'BoM Plans for ' + year + ' have been deleted';
    }
    
    public static map<String, Leadership_Plan__c> getLeadershipPlanByYear(String year) {
    	
    	map<String, Leadership_Plan__c> leaderShipPlanMap = new map<String, Leadership_Plan__c>();
    	for(Leadership_Plan__c leader : [
    								Select Id
    									 , Name
    									 , FA__r.Name
    									 , Year_Text__c
    								From Leadership_Plan__c
    								Where Year_Text__c =: year
    	]) {
    		if(leader.FA__c == null) continue; 
    		String key = leader.Year_Text__c + '-' + leader.FA__r.Name;
    		leaderShipPlanMap.put(key, leader);
    	}
    	return leaderShipPlanMap;
    }
    
    
    global class FAGoalWrapper implements Comparable {
    	
    	public Ranking__c ranking { get;set; }
    	public FA_Goal__c faGoal { get;set; }
    	public boolean flag { get;set; }//ranking is null && FA is not equals 'Recruiting'
    	
    	public String newKeyHHsInputClass {get;set;}
    	public String newKeyHHsErrorMessage {get;set;}
    	
    	public String advisoryInputClass {get;set;}
    	public String advisoryErrorMessage {get;set;}
    	
    	public String lendingInputClass {get;set;}
    	public String lendingErrorMessage {get;set;}
    	
    	public String netIncomeInputClass {get;set;}
    	public String netIncomeErrorMessage {get;set;}
    	
    	public FAGoalWrapper(Ranking__c ranking, FA_Goal__c faGoal, boolean flag) {
    		this.ranking = ranking;
    		this.faGoal = faGoal;
    		this.flag = flag;
    	}
    	
    	global Integer compareTo(Object compareTo) {
    		
    		String recordTypename = faGoal.RecordType.Name;
    		FAGoalWrapper compareToFAGoal = (FAGoalWrapper)compareTo;
    		String compareRecordTypename = compareToFAGoal.faGoal.RecordType.Name;

    		if(recordTypename == 'Recruiting') {
	        	return 1;
	        }else if(compareRecordTypename == 'Recruiting'){
	        	return -1;
	        }
    		if(compareToFAGoal.ranking != null && ranking != null) {
	    		String name = ranking.Name;
		        if (name < compareToFAGoal.ranking.Name) return -1;
		        else if (name == compareToFAGoal.ranking.Name) return 0;
		        else return 1;
    		}else {
    			return 1;
    		}
	    }
    }
    
    //****************************** End Admin BoM Plan ********************************************************************
    
    //****************************** Start Testing ********************************************************************
    public static BoM_Plan_Group__c createSampleBoMPlanGroup(){
    	BoM_Plan_Group__c planGroup = new BoM_Plan_Group__c();
		planGroup.Name = 'PlanGroup';
		planGroup.Year__c = '2013';
		insert planGroup;
		
		return planGroup;
    }
    /* For testing */
	public static list<BoM_Plan__c> getSampleBoMPlanList(Integer nCount, Main_Branch__c mainBranch, BoM_Plan_Group__c planGroup){
		
		list<BoM_Plan__c> planList = new list<BoM_Plan__c>();
		BoM_Plan__c plan;
		
		Integer maxCount = nCount;
		for(Integer i = 0; i<=maxCount; i++){
			plan = new BoM_Plan__c();
			plan.Name = 'BoM Plan' + i;
			plan.Main_Branch__c = mainBranch.Id;
			plan.BoM_Plan_Group__c = planGroup.Id;
			planList.add(plan);
		}
		
		return planList;
	}

	//****************************** End Testing ********************************************************************
	

}