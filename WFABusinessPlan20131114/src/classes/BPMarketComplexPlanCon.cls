/**************************************************************************************************
 * Purpose: Controller of the BPMarketComplexPlan Visualforce Page
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-18
 * Modify History:
 * Keen    2013-11-18   Created
***************************************************************************************************/
public class BPMarketComplexPlanCon {
	//Query string key of the Complex/market/region Plan Id
	static final String COMPLEX_PLAN_KEY = 'cid';
	//Message of invalid complex/market/region plan Id
	static final String INVALID_CID_MSG = 'Invalid Complex Plan Id.';
	
	//List of child/grand-child plans
	public list<BoM_Plan__c> bomPlanList {get; set;}
	
	//List of child/grand-child plans in the wrapper class which bind with the UI
	public list<BoMPlanWrapper> bomPlanWrapperList {get;set;}
	public String planId {get;set;}
	//Current Main Plan
	public BoM_Plan__c masterPlan {get;set;}
	//Wrapper class of the current main plan
	public BoMPlanWrapper masterPlanWrapper{get;set;}
	
	public BPMarketComplexPlanCon (){
        planId = ApexPages.currentPage().getParameters().get(COMPLEX_PLAN_KEY);
    }
    
    public BPMarketComplexPlanCon (ApexPages.StandardController stdController){
        planId = stdController.getId();
    }
    //Init the plans when the page is loaded
    public void init(){
    	system.debug('*** PlanId: ' + planId);
    	if(planId == null || planId == ''){
            BPMessageUtil.addInfoMessage(INVALID_CID_MSG);
        }
        else {
        	//Get the master plan
        	masterPlan = BPBranchBusinessPlanUtil.getBoMPlanById(planId);
        	//Get the child/grand-child plans
			bomPlanList = BPBranchBusinessPlanUtil.getFlatPlanList(planId);
			//Copy child/grand-child plans into wrapper class
			copyToWrapperList();
			//Copy master plan into wrapper class
			copyToMasterPlanWrapper();
        }
    }
    
    //Copy child plans into the wrapper class
    private void copyToWrapperList(){
    	bomPlanWrapperList = new list<BoMPlanWrapper>();
    	if(bomPlanList == null) {
    		return;
    	}
    	
    	BoMPlanWrapper wrapper;
    	for(BoM_Plan__c bomPlan : bomPlanList){
    		wrapper = createChildWrapper(bomPlan);
    		
    		bomPlanWrapperList.add(wrapper);
    	}
    }
    //Copy master plans into the wrapper class
    private void copyToMasterPlanWrapper(){
    	masterPlanWrapper = createMasterWrapper(masterPlan);
    }
    
    
    private BoMPlanWrapper createMasterWrapper(BoM_Plan__c bomPlan){
    	if(bomPlan==null){
    		return null;
    	}
    	
    	BoMPlanWrapper wrapper = new BoMPlanWrapper();
		wrapper.advisoryGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Advisory_Net_Flows__c, 1);
		wrapper.advisoryPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Advisory_Net_Flows_Approved__c, 1);
		wrapper.advisoryPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Approved__c), 1);
		
		wrapper.lendingGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Lending__c, 1, 'K');
		wrapper.lendingPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Lending_Approved__c, 1, 'K');
		wrapper.lendingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Approved__c), 1, 'K');
		
		wrapper.newKeyHHsGoal = BPCommonUtil.formatNumber(bomPlan.Tonnage_Goal_New_Key_HHs__c);
		wrapper.newKeyHHsPlan = BPCommonUtil.formatNumber(bomPlan.Plan_New_Key_HHs_Approved__c);
		wrapper.newKeyHHsPlanGap = BPCommonUtil.formatNumber(BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Approved__c));
		
		wrapper.netIncomeGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Net_Income__c);
		wrapper.netIncomePlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Net_Income_Approved__c);
		wrapper.netIncomePlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Rollup_Text__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Approved__c));
		
		wrapper.netRecruitingPlan = BPCommonUtil.formatCurrency(bomPlan.Recruiting_Net_Approved__c);
		wrapper.netRecruitingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Recruiting_Net__c) - BPCommonUtil.defaultNull(bomPlan.Recruiting_Net_Approved__c));
		
		wrapper.bomPlan = bomPlan;
		wrapper.status = bomPlan.Finalized__c? 'Finalized':'Not Finalized';
		
		BPBranchBusinessPlanUtil.initRecordType();
		if(masterPlan.RecordTypeId == BPBranchBusinessPlanUtil.branchPlanRT){
			wrapper.planType = 'BoM Plan';
		}
		else if(masterPlan.RecordTypeId == BPBranchBusinessPlanUtil.subComplexPlanRT){
			wrapper.planType = 'Complex Plan';
		}
		else if(masterPlan.RecordTypeId == BPBranchBusinessPlanUtil.marketPlanRT){
			wrapper.planType = 'Market Plan';
		}
		else if(masterPlan.RecordTypeId == BPBranchBusinessPlanUtil.regionPlanRT){
			wrapper.planType = 'Region Plan';
		}
		
		
		return wrapper;
    }
    
    
    
    private BoMPlanWrapper createChildWrapper(BoM_Plan__c bomPlan){
    	if(bomPlan==null){
    		return null;
    	}
    	
    	BoMPlanWrapper wrapper = new BoMPlanWrapper();
		
		system.debug('*** branchPlanRT: ' + BPBranchBusinessPlanUtil.branchPlanRT);
		system.debug('*** bomPlan.RecordTypeId: ' + bomPlan.RecordTypeId);
		
		String planStatus_InAction = 'In Action';
		String planStatus_Closed = 'Closed';
		
		BPBranchBusinessPlanUtil.initRecordType();
		if(BPBranchBusinessPlanUtil.branchPlanRT == bomPlan.RecordTypeId){

			//For the branch level plan, the udpates after approval won't affect the parent plan (complex, market and region plans)
			if(bomPlan.Status__c == planStatus_InAction || bomPlan.Status__c == planStatus_Closed ){
				wrapper.advisoryPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Advisory_Net_Flows_Approved__c, 1);
				wrapper.advisoryPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Approved__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Approved__c), 1);
			
				wrapper.lendingPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Lending_Approved__c, 1, 'K');
				wrapper.lendingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Approved__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Approved__c), 1, 'K');
			
				wrapper.newKeyHHsPlan = BPCommonUtil.formatNumber(bomPlan.Plan_New_Key_HHs_Approved__c);
				wrapper.newKeyHHsPlanGap = BPCommonUtil.formatNumber(BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Approved__c) - BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Approved__c));
				
				wrapper.netIncomePlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Net_Income_Approved__c);
				wrapper.netIncomePlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Approved__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Approved__c));
				
				wrapper.netRecruitingPlan = BPCommonUtil.formatCurrency(bomPlan.Recruiting_Net_Approved__c);
				wrapper.netRecruitingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Recruiting_Net_Approved__c) - BPCommonUtil.defaultNull(bomPlan.Recruiting_Net_Approved__c));
			}
			else{
				wrapper.advisoryPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Advisory_Net_Flows_Rollup__c, 1);
				wrapper.advisoryPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Approved__c), 1);
				
				wrapper.lendingPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Lending_Rollup__c, 1, 'K');
				wrapper.lendingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Approved__c), 1, 'K');
				
				wrapper.newKeyHHsPlan = BPCommonUtil.formatNumber(bomPlan.Plan_New_Key_HHs_Rollup__c);
				wrapper.newKeyHHsPlanGap = BPCommonUtil.formatNumber(BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Approved__c));
				
				wrapper.netIncomePlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Net_Income_Rollup_By_Revenue__c);
				wrapper.netIncomePlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Rollup_Text__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Approved__c));
				
				wrapper.netRecruitingPlan = BPCommonUtil.formatCurrency(bomPlan.Recruiting_Net__c);
				wrapper.netRecruitingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Recruiting_Net__c) - BPCommonUtil.defaultNull(bomPlan.Recruiting_Net_Approved__c));
			}
			
			wrapper.advisoryGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Advisory_Net_Flows__c, 1);
			
			wrapper.lendingGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Lending__c, 1, 'K');
			
			wrapper.newKeyHHsGoal = BPCommonUtil.formatNumber(bomPlan.Tonnage_Goal_New_Key_HHs__c);
			
			wrapper.netIncomeGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Net_Income__c);
			
			wrapper.status = bomPlan.Status__c;
		}
		else{
			
			//For complex, market and region plans, the update after approval has been considered at the branch level. There is no need to catch that here specifically
			wrapper.advisoryGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Advisory_Net_Flows__c, 1);
			wrapper.advisoryPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Advisory_Net_Flows_Rollup__c, 1);
			wrapper.advisoryPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Advisory_Net_Flows_Approved__c), 1);
			
			wrapper.lendingGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Lending__c, 1, 'K');
			wrapper.lendingPlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Lending_Rollup__c, 1, 'K');
			wrapper.lendingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Lending_Approved__c), 1, 'K');
			
			wrapper.newKeyHHsGoal = BPCommonUtil.formatNumber(bomPlan.Tonnage_Goal_New_Key_HHs__c);
			wrapper.newKeyHHsPlan = BPCommonUtil.formatNumber(bomPlan.Plan_New_Key_HHs_Rollup__c);
			wrapper.newKeyHHsPlanGap = BPCommonUtil.formatNumber(BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Rollup__c) - BPCommonUtil.defaultNull(bomPlan.Plan_New_Key_HHs_Approved__c));
			
			wrapper.netIncomeGoal = BPCommonUtil.formatCurrency(bomPlan.Tonnage_Goal_Net_Income__c);
			wrapper.netIncomePlan = BPCommonUtil.formatCurrency(bomPlan.Plan_Net_Income_Rollup_Text__c);
			wrapper.netIncomePlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Rollup_Text__c) - BPCommonUtil.defaultNull(bomPlan.Plan_Net_Income_Approved__c));
		
			wrapper.netRecruitingPlan = BPCommonUtil.formatCurrency(bomPlan.Recruiting_Net__c);
			wrapper.netRecruitingPlanGap = BPCommonUtil.formatCurrency(BPCommonUtil.defaultNull(bomPlan.Recruiting_Net__c) - BPCommonUtil.defaultNull(bomPlan.Recruiting_Net_Approved__c));
			
			wrapper.status = bomPlan.Finalized__c? 'Finalized':'Not Finalized';
		}
		
		wrapper.bomPlan = bomPlan;
		return wrapper;
    }
    
    
    //Wrapper class of BOM Plan which will bind with the UI
    public class BoMPlanWrapper{
    	//The hierarchy info is translated into indent which is the CSS Class
    	private String getIndent(String planName){
	    	String indent = '';
	    	if(planName.startsWith('###')){
				indent = 'indent3';
			}
			else if(planName.startsWith('##')){
				indent = 'indent2';
			}
			else if(planName.startsWith('#')){
				indent = 'indent1';
			}
			else{
				indent = 'indent0';
			}
	
	    	return indent;
	    }
    	public BoMPlanWrapper(){
    		
    	}
    	public String advisoryGoal {get;set;}
    	public String advisoryPlan {get;set;}
    	public String advisoryPlanGap {get;set;}
    	
    	public String lendingGoal {get;set;}
    	public String lendingPlan{get;set;}
    	public String lendingPlanGap{get;set;}
    	
    	public String newKeyHHsGoal{get;set;}
    	public String newKeyHHsPlan{get;set;}
    	public String newKeyHHsPlanGap{get;set;}
    	
    	public String netIncomeGoal{get;set;}
    	public String netIncomePlan{get;set;}
    	public String netIncomePlanGap{get;set;}
    	
    	public String netRecruitingPlan{get;set;}
    	public String netRecruitingPlanGap{get;set;}
    	
    	public BoM_Plan__c bomPlan {get;set;}
    	//Css Class of the Plan Name Column
    	public String indentClass {
    		get {
    			return getIndent(bomPlan.Name);
    		}
    	}
    	//Css Class of the other columns except for Name
    	public String cotentIndentClass {
    		get {
    			return 'content' + getIndent(bomPlan.Name);
    		}
    	}
    	public String status{get;set;}
    	public String planType{get;set;}
    }
}