public class LeadershipPlanTrgHandler {
	
	public static String PLAN_STATUS_CLOSED = 'Closed';
	public static String PLAN_STATUS_INACTION = 'In Action';
	public static String PLAN_STATUS_AVAILABLE = 'Available';
	public static String PLAN_STATUS_UNDERREVIEW = 'Under Review';
	
	public static void processTrigger(){
		if(trigger.isBefore){
			processBeforeTrigger();
		}
		else{
			processAfterTrigger();
		}
	}
	
	//***************Before Trigger********************************************************************************************
	public static void processBeforeTrigger(){
		//Get all the inserted or updated BoM Plans in scope
		List<Leadership_Plan__c> newPlanList = trigger.new;
		
		list<Leadership_Plan__c> toUpdateStatusPlanList = new list<Leadership_Plan__c>();
		list<Leadership_Plan__c> toLockStatusPlanList = new list<Leadership_Plan__c>();
		list<Leadership_Plan__c> toUnlockStatusPlanList = new list<Leadership_Plan__c>();
		
		if(trigger.isInsert){
			for(Leadership_Plan__c newPlan : newPlanList){
				//Any new added records with status as 'Closed' are considered in scope
				if(newPlan.Status__c == PLAN_STATUS_CLOSED){
					toLockStatusPlanList.add(newPlan);
				}
				
			}
		}
		else if(trigger.isUpdate){
			for(Leadership_Plan__c newPlan : newPlanList){
				Leadership_Plan__c oldPlan = (Leadership_Plan__c)trigger.oldMap.get(newPlan.Id);
				
				//If any update at the status of Available and Under Review, the status should be udpated to In Progress
				if((BPCommonUtil.defaultNull(oldPlan.Status__c) == PLAN_STATUS_AVAILABLE
				|| BPCommonUtil.defaultNull(oldPlan.Status__c) == PLAN_STATUS_UNDERREVIEW)
				&& BPCommonUtil.defaultNull(newPlan.Status__c) == BPCommonUtil.defaultNull(oldPlan.Status__c)){
					toUpdateStatusPlanList.add(newPlan);
				}
				
				//If the status is Closed, the plan needs to be locked
				if(BPCommonUtil.defaultNull(oldPlan.Status__c) != BPCommonUtil.defaultNull(newPlan.Status__c) 
				&& BPCommonUtil.defaultNull(newPlan.Status__c) == PLAN_STATUS_CLOSED){
					//newPlan.X_Approval_Process_Token__c = 'Lock';//Secret token to trigger the auto lock approval process
					toLockStatusPlanList.add(newPlan);
				}
				
				//If the status is Re-Opened, the plan needs to be unlocked
				if(BPCommonUtil.defaultNull(oldPlan.Status__c) != BPCommonUtil.defaultNull(newPlan.Status__c) 
				&& BPCommonUtil.defaultNull(oldPlan.Status__c) == PLAN_STATUS_CLOSED){
					//newPlan.X_Approval_Process_Token__c = 'Unlock';//Secret token to trigger the auto unlock approval process
					toUnlockStatusPlanList.add(newPlan);
				}
				
			}
		}
		//Update to in Progress from and only from Available and Under Review. At this point, it means the Branch Manager is making updates
		updateStatus(toUpdateStatusPlanList);
		
		//Lock the record if the status is updated to 'Closed'
		lockPlans(toLockStatusPlanList);
		
		//Unlock the record if it's reactivated
		unlockPlans(toUnlockStatusPlanList);
		
	}
	
	//Update leadership plan status to "In Progress"
	private static void updateStatus(list<Leadership_Plan__c> toUpdateStatusPlanList){
		for(Leadership_Plan__c plan : toUpdateStatusPlanList){
			plan.Status__c = 'In Progress';
		}
	}
	
	//Lock plans with approval process
	private static void lockPlans(list<Leadership_Plan__c> toLockStatusPlanList){
		list<Approval.ProcessSubmitRequest> reqList = new list<Approval.ProcessSubmitRequest>();
		try{
			for(Leadership_Plan__c plan : toLockStatusPlanList){
				// Create an approval request for the plan
				Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
				req1.setComments('Automatic record lock.');
				req1.setObjectId(plan.id);
				 
				reqList.add(req1);
			}
			
			// Submit the approval request for the plan
			Approval.ProcessResult[] resultList = Approval.process(reqList, false);
			
			//Update the plan to to be locked so that the lock will no longer be triggered again. Make sure this is a criteria of the approval process to lock the record
			for(Leadership_Plan__c plan : toLockStatusPlanList){
				plan.xLocked__c = true;
			}
		}
		catch(Exception ex){
			system.debug('*** Exception: ' + ex);
		}
	}
	//Unlock plans with approval process
	private static void unlockPlans(list<Leadership_Plan__c> toUnlockStatusPlanList){
		
		list<Approval.ProcessSubmitRequest> reqList = new list<Approval.ProcessSubmitRequest>();
		
		try{
			for(Leadership_Plan__c plan : toUnlockStatusPlanList){
				// Create an approval request for the plan
				Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
				req1.setComments('Automatic record lock.');
				req1.setObjectId(plan.id);
				 
				reqList.add(req1);				
			}
			
			// Submit the approval request for the plan
			Approval.ProcessResult[] resultList = Approval.process(reqList, false);
			
			//Update the plan to to be unlocked so that the lock will no longer be triggered again. Make sure this is a criteria of the approval process to unlock the record
			for(Leadership_Plan__c plan : toUnlockStatusPlanList){
				plan.xLocked__c = false;
			}
		}
		catch(Exception ex){
			system.debug('*** Exception: ' + ex);
		}
	}
	
	
	//***************End Before Trigger********************************************************************************************
	
	//***************After Trigger********************************************************************************************
	public static void processAfterTrigger(){
		
	}
	//***************End After Trigger********************************************************************************************
}