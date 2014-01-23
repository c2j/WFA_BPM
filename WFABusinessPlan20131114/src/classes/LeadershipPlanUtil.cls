/**************************************************************************************************
 * Purpose: LeadershipPlan Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-12-03
 * Modify History:
 * Keen    2013-12-03    Created
***************************************************************************************************/
public class LeadershipPlanUtil {
	
	public static String PLAN_STATUS_AVAILABLE = 'Available';
	public static String PLAN_STATUS_INPROGRESS = 'In Progress';
	public static String PLAN_STATUS_SUBMITTED = 'Submitted';
	public static String PLAN_STATUS_INACTION = 'In Action';
	public static String PLAN_STATUS_UNDERREVIEW = 'Under Review';
	public static String PLAN_STATUS_CLOSED = 'Closed';
	
	//Submit the leadership plan for approval
	public static String submitPlan(String planId){
		list<Leadership_Plan__c> planList = [
    		Select Id
    		, Status__c
    		, FA__r.Email
    		, FA__r.Account.Manager_Branch__c
    		, FA__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c
    		, FA__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c
    		, FA__r.Account.Region_Branch__r.Regional_President__c
    		, FA__c
    		, Business_Mission_and_Vision_Statement__c
    		, Risk_Management__c
    		, Team_Member_Engagement__c
    		, Community_Involvement__c
    		, Manager_Development_Growth__c
    		, Manager_Development_Quality__c
    		, Diversity_and_Inclusion__c
    		, Financial_Performance__c
    		, Key_Focus_Areas__c
    		, BoM_Plan__r.Id
    		, BoM_Plan__r.Leadership_Plan_Completed__c
    		, OwnerId
    		From Leadership_Plan__c
    		Where Id = :planId
    	];
    	
    	
    	if(planList.size()==0){
    		return 'Plan not found';
    	}
    	
    	Leadership_Plan__c plan = planList[0];
    	
    	if(plan.Status__c == PLAN_STATUS_SUBMITTED){
    		return 'Leadership plan already submitted';
    	}
    	
    	if(plan.Status__c == PLAN_STATUS_CLOSED){
    		return 'Leadership plan already closed';
    	}
    	
    	if(plan.Status__c == PLAN_STATUS_INACTION){
    		return 'Leadership plan already submitted';
    	}
    	
    	if(String.isBlank(plan.Business_Mission_and_Vision_Statement__c)
    		 || String.isBlank(plan.Risk_Management__c)
    		 || String.isBlank(plan.Team_Member_Engagement__c)
    		 || String.isBlank(plan.Community_Involvement__c)
    		 || String.isBlank(plan.Diversity_and_Inclusion__c)
    		 || String.isBlank(plan.Financial_Performance__c)
    		 || String.isBlank(plan.Key_Focus_Areas__c)){
    		 	
    		 	return 'Please finish the leadership plan before submission';
    	}
    	/*
    	if(String.isBlank(plan.OwnerId)){
    		return 'Plan doesn\'t have owner';
    	}
    	else {
    		User user = [Select ManagerId From User Where Id = :plan.OwnerId Limit 1];
    		if(String.isBlank(user.ManagerId)){
    			return 'Owner doesn\'t have a manager';
    		}
    	}*/
    	
    	//Start to check the manager of the leadership plan owner. If they are the same, automatically approve it
    	
    	BPCommonUtil.log('Plan Manager: ' + plan.FA__c);
    	BPCommonUtil.log('Branch Manager: ' + plan.FA__r.Account.Manager_Branch__c);
    	BPCommonUtil.log('Sub Manager: ' + plan.FA__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c);
    	BPCommonUtil.log('Market Manager: ' + plan.FA__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c);
    	BPCommonUtil.log('Region Manager: ' + plan.FA__r.Account.Region_Branch__r.Regional_President__c);
    	
    	String managerId;
    	if(plan.FA__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c != null 
    		&& plan.FA__r.Account.Manager_Branch__c == plan.FA__c
    		//&& plan.FA__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c != plan.FA__c 
    		){
    		
    		BPCommonUtil.log('Manager: Manager_Sub_Supl_Complex__c');
    		managerId = plan.FA__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c;
    	}
    	else if(plan.FA__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c != null 
    		&& (plan.FA__r.Account.Manager_Branch__c == plan.FA__c
    			|| plan.FA__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c == plan.FA__c)
    		//&& plan.FA__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c != plan.FA__c 
    		){
    		
			BPCommonUtil.log('Manager: Manager_Market_Complex__c');
    		managerId = plan.FA__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c;
    	}
    	else if(plan.FA__r.Account.Region_Branch__r.Regional_President__c != null
    		&& (plan.FA__r.Account.Manager_Branch__c == plan.FA__c
    			|| plan.FA__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__c == plan.FA__c
    			|| plan.FA__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c == plan.FA__c)
    		){
    		
			BPCommonUtil.log('Manager: Regional_President__c');
    		managerId = plan.FA__r.Account.Region_Branch__r.Regional_President__c;
    	}
    	else{
    		/*
    		BPCommonUtil.log('Plan: ', plan);
    		return 'Could not find the manager to approve the plan';*/
    	}
    	
    	BPCommonUtil.log('managerId: ', managerId);
    	
    	plan.Assignee_Email__c = getAssigneeEmail(plan);
    	
    	/* No Need for self Approval
    	if(plan.FA__c == managerId){
    		//Self Approval
    		plan.Skip_Approval__c = true;
    	}*/
    	update plan;
    	
    	// Create an approval request for the plan
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Manager Approval');
		/* No need for self approval
		if(plan.Skip_Approval__c){
			req.setComments('Self Approval');
		}
		else{
			req.setComments('Manager Approval');
		}*/
		req.setObjectId(plan.id);
		
    	// Submit the approval request for the plan
		Approval.ProcessResult result = Approval.process(req, false);
		if(!result.isSuccess()){
			return result.getErrors()[0].getMessage();
		}
		
		//Update the indicator on the BoM Plan record that the leadership plan associated has been completed
		BoM_Plan__c bomPlan = plan.Bom_Plan__r;
		if(bomPlan != null){
			bomPlan.Leadership_Plan_Completed__c = true;
			update bomPlan;
		}
    	
    	return null;
	}
	
	//Get the assignee's email address so that email alert could be sent when the plan is approved or rejected
	public static String getAssigneeEmail(Leadership_Plan__c plan){
    	if(plan == null){
    		return null;
    	}
    	
    	return plan.FA__r.Email;
    }
}