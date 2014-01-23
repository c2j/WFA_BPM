/**************************************************************************************************
 * Purpose: Controller of the BPLeadershipPlan Visualforce Page
 * Author: PwC (Keen)
 * Modify History:
 * Keen    2013-11-8    Created
***************************************************************************************************/
public class BPLeadershipPlanCon {
	//Query string key of Leadershp Plan Id
	static final String LEADERSHIP_PLAN_KEY = 'lid';
	//Query string key of BoM Plan Id
	static final String BOM_PLAN_KEY = 'bid';
	
	//Message if the leadership plan id is invalid
	static final String INVALID_LID_MSG = 'Invalid Leadership Plan Id.';
	//Message if the bom plan id is invalid
	static final String INVALID_BID_MSG = 'The leadership plan is not associated with a BoM Plan.';
	//Message if the operation is invalid
	static final String INVALID_OPER_MSG = 'Invalid operation or operation not implemented.';
	//Query string value of Operation (Submit Leadership Plan)
	static final String OPERATION_SUBMIT_PLAN = 'Submit';
	//Query string value of Operation (Navigate to BoM Plan)
	static final String OPERATION_GOTO_BOM_PLAN = 'BoMPlan';
	//Query string key of Operation
	static final String OPER = 'Operation';
	
	public String planId {get;set;}
	//Query string value of current operation
	public String operation {get;set;}
	public String bomPlanId{get;set;}
	
	public BPLeadershipPlanCon(){
		init();
    }
    
	public BPLeadershipPlanCon(ApexPages.StandardController stdController){
		system.debug('stdController: ' + stdController);
        planId = stdController.getId();//Looks like this doesn't work
        init();
    }
    
    private void init(){
    	operation = ApexPages.currentPage().getParameters().get(OPER);
		planId = ApexPages.currentPage().getParameters().get(LEADERSHIP_PLAN_KEY);
		bomPlanId = ApexPages.currentPage().getParameters().get(BOM_PLAN_KEY);
    }
    
    //Actions which vary according to query string input.
    public PageReference execute(){
    	if(String.isBlank(planId)){
            BPMessageUtil.addInfoMessage(INVALID_LID_MSG);
            return null;
        }
        else if(String.isBlank(operation)){
        	BPMessageUtil.addInfoMessage(INVALID_OPER_MSG);
            return null;
        }
        else if(operation == OPERATION_SUBMIT_PLAN){
        	//Submit Plan
        	return submitPlan();
        }
        else if(operation == OPERATION_GOTO_BOM_PLAN){
        	//Go to BOM Plan
        	return gotoBoMPlan();
        }
        else{
        	BPMessageUtil.addInfoMessage(INVALID_OPER_MSG);
        	return null;
        }
    }
    
    private PageReference submitPlan(){
        String msg = LeadershipPlanUtil.submitPlan(planId);
        if(msg!=null){
	    	BPMessageUtil.addInfoMessage(msg);
	    	return null;
        }
        else{
        	return new PageReference('/'+planId);	        	
        }
    }
    
    public PageReference gotoBoMPlan(){
        if(String.isBlank(bomPlanId)){
	    	BPMessageUtil.addInfoMessage(INVALID_BID_MSG);
	    	return null;
        }
        else{
        	return new PageReference('/'+bomPlanId);	        	
        }
    }
    
    public PageReference gotoLeadershipPlan(){
		if(String.isBlank(planId)){
            BPMessageUtil.addInfoMessage(INVALID_LID_MSG);
            return null;
        }
        else{
        	return new PageReference('/'+planId);
        }
    }
}