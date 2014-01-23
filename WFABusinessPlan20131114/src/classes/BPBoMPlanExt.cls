/**************************************************************************************************
 * Purpose: Extension of the BPBoMPlan Visualforce Page
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-8
 * Modify History:
 * Keen    2013-11-8    Created
***************************************************************************************************/
public class BPBoMPlanExt {
	//Query string key of the Branch/Complex/market/region Plan Id
	static final String COMPLEX_PLAN_KEY = 'cid';
	
	//Message of invalid Branch/complex/market/region plan Id
	static final String INVALID_CID_MSG = 'Invalid Complex Plan Id.';
	
	//Id of the BoM Plan
	public String planId {get;set;}
	
	public BPBoMPlanExt (){
    }
	
	public BPBoMPlanExt (ApexPages.StandardController stdController){
        planId = stdController.getId();
    }
    
    public PageReference finalizePlan(){
        if(planId == null || planId == ''){
            BPMessageUtil.addInfoMessage(INVALID_CID_MSG);
            return null;
        }
        else {
	        String msg = BPBranchBusinessPlanUtil.finalizePlan(planId);
	        if(msg!=null){
		    	BPMessageUtil.addInfoMessage(msg);
		    	return null;
	        }
	        else{
	        	return new PageReference('/'+planId);	        	
	        }
        }
    }
    
    public PageReference submitPlan(){
        if(planId == null || planId == ''){
            BPMessageUtil.addInfoMessage(INVALID_CID_MSG);
            return null;
        }
        else {
	        String msg = BPBranchBusinessPlanUtil.submitPlan(planId);
	        if(msg!=null){
		    	BPMessageUtil.addInfoMessage(msg);
		    	return null;
	        }
	        else{
	        	return new PageReference('/'+planId);	        	
	        }
        }
    }
    //Navigate to the standard Plan page
    public PageReference gotoPlan(){
    	return new PageReference('/'+planId);
    }
    
    //Navigate to the Leadership Plan Page
    public PageReference gotoLeadershipPlan(){
    	Leadership_Plan__c leadershipPlan = BPBranchBusinessPlanUtil.getLeadershipPlan(planId);
    	if(leadershipPlan == null){
    		BPMessageUtil.addInfoMessage('Could not find the Leadership Plan.');
    		return null;
    	}
    	return new PageReference('/'+leadershipPlan.Id);
    }
    
}