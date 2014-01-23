/**************************************************************************************************
 * Purpose: Trigger Handler of the Object BoM Plan
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-18
 * Modify History:
 * Keen    2013-11-18   Created
***************************************************************************************************/
public class BoMPlanTrgHandler {
	
	//************* Plan Status Constants **************************
	public static String PLAN_STATUS_CLOSED = 'Closed';
	public static String PLAN_STATUS_INACTION = 'In Action';
	public static String PLAN_STATUS_AVAILABLE = 'Available';
	public static String PLAN_STATUS_UNDERREVIEW = 'Under Review';
	//************* End ********************************************
	
	//Primarily means the times the trigger has been fired. This is to prevent infinite loop because of bad data
	public static Integer rollupTimes = 0;
	
	//Flag to indicate whether to ignore rollup when trigger fires
	public static Boolean ignoreRollup = false;
	
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
		List<BoM_Plan__c> newPlanList = trigger.new;
		
		list<BoM_Plan__c> toUpdateStatusPlanList = new list<BoM_Plan__c>();
		list<BoM_Plan__c> toLockStatusPlanList = new list<BoM_Plan__c>();
		list<BoM_Plan__c> toUnlockStatusPlanList = new list<BoM_Plan__c>();
		list<BoM_Plan__c> approvedPlanList = new list<BoM_Plan__c>();
		
		if(trigger.isInsert){
			for(BoM_Plan__c newPlan : newPlanList){
				//Any new added records with status as 'Closed' are considered in scope
				if(newPlan.Status__c == PLAN_STATUS_CLOSED){
					toLockStatusPlanList.add(newPlan);
				}
				
				if(newPlan.Status__c == PLAN_STATUS_INACTION){
					approvedPlanList.add(newPlan);
				}
			}
		}
		else if(trigger.isUpdate){
			
			
			for(BoM_Plan__c newPlan : newPlanList){
				BoM_Plan__c oldPlan = (BoM_Plan__c)trigger.oldMap.get(newPlan.Id);
				
				//If any update at the status of Available and Under Review, the status should be udpated to In Progress
				if((BPCommonUtil.defaultNull(oldPlan.Status__c) == PLAN_STATUS_AVAILABLE
					|| BPCommonUtil.defaultNull(oldPlan.Status__c) == PLAN_STATUS_UNDERREVIEW)
				&& BPCommonUtil.defaultNull(newPlan.Status__c) == BPCommonUtil.defaultNull(oldPlan.Status__c)
				&& (BPCommonUtil.defaultNull(newPlan.Plan_Advisory_Net_Flows_Rollup__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Advisory_Net_Flows_Rollup__c)
					|| BPCommonUtil.defaultNull(newPlan.Plan_Lending_Rollup__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Lending_Rollup__c)
					|| BPCommonUtil.defaultNull(newPlan.Plan_New_Key_HHs_Rollup__c) != BPCommonUtil.defaultNull(oldPlan.Plan_New_Key_HHs_Rollup__c)
					|| BPCommonUtil.defaultNull(newPlan.Plan_Net_Income_Rollup_By_Revenue__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Net_Income_Rollup_By_Revenue__c)
					|| BPCommonUtil.defaultNull(newPlan.Plan_Revenue__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Revenue__c)
					|| BPCommonUtil.defaultNull(newPlan.Plan_T12_Recruited__c) != BPCommonUtil.defaultNull(oldPlan.Plan_T12_Recruited__c)
					|| BPCommonUtil.defaultNull(newPlan.Plan_T12_Attrited__c) != BPCommonUtil.defaultNull(oldPlan.Plan_T12_Attrited__c))){
						
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
				
				//If the status is In Action, approved values should be logged
				if(BPCommonUtil.defaultNull(oldPlan.Status__c) != BPCommonUtil.defaultNull(newPlan.Status__c)
				&& BPCommonUtil.defaultNull(newPlan.Status__c) == PLAN_STATUS_INACTION){
					approvedPlanList.add(newPlan);
				}
			}
		}
		//Update to in Progress from and only from Available and Under Review. At this point, it means the Branch Manager is making updates
		updateStatus(toUpdateStatusPlanList);
		
		//Lock the record if the status is updated to 'Closed'
		lockPlans(toLockStatusPlanList);
		
		//Unlock the record if it's reactivated
		unlockPlans(toUnlockStatusPlanList);
		
		//Capture approved values
		copyApprovedValues(approvedPlanList);
	}
	//Update the status to 'In Progress'
	private static void updateStatus(list<BoM_Plan__c> toUpdateStatusPlanList){
		for(BoM_Plan__c plan : toUpdateStatusPlanList){
			plan.Status__c = 'In Progress';
		}
	}
	//Lock plans using the approval process
	private static void lockPlans(list<BoM_Plan__c> toLockStatusPlanList){
		list<Approval.ProcessSubmitRequest> reqList = new list<Approval.ProcessSubmitRequest>();
		try{
			for(BoM_Plan__c plan : toLockStatusPlanList){
				// Create an approval request for the plan
				Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
				req1.setComments('Automatic record lock.');
				req1.setObjectId(plan.id);
				 
				reqList.add(req1);
			}
			
			// Submit the approval request for the plan
			Approval.ProcessResult[] resultList = Approval.process(reqList, false);
			
			//Update the plan to to be locked so that the lock will no longer be triggered again. Make sure this is a criteria of the approval process to lock the record
			for(BoM_Plan__c plan : toLockStatusPlanList){
				plan.xLocked__c = true;
			}
		}
		catch(Exception ex){
			system.debug('*** Exception: ' + ex);
		}
	}
	//Unlock plan using the approval process
	private static void unlockPlans(list<BoM_Plan__c> toUnlockStatusPlanList){
		
		list<Approval.ProcessSubmitRequest> reqList = new list<Approval.ProcessSubmitRequest>();
		
		try{
			for(BoM_Plan__c plan : toUnlockStatusPlanList){
				// Create an approval request for the plan
				Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
				req1.setComments('Automatic record lock.');
				req1.setObjectId(plan.id);
				 
				reqList.add(req1);				
			}
			
			// Submit the approval request for the plan
			Approval.ProcessResult[] resultList = Approval.process(reqList, false);
			
			//Update the plan to to be unlocked so that the lock will no longer be triggered again. Make sure this is a criteria of the approval process to unlock the record
			for(BoM_Plan__c plan : toUnlockStatusPlanList){
				plan.xLocked__c = false;
			}
		}
		catch(Exception ex){
			system.debug('*** Exception: ' + ex);
		}
	}
	//Copy plan values to approved values when the plan got approved
	private static void copyApprovedValues(list<BoM_Plan__c> approvedPlanList){
		for(BoM_Plan__c plan : approvedPlanList){
			plan.Plan_Advisory_Net_Flows_Approved__c = plan.Plan_Advisory_Net_Flows_Rollup__c;
			plan.Plan_Lending_Approved__c = plan.Plan_Lending_Rollup__c;
			plan.Plan_New_Key_HHs_Approved__c = plan.Plan_New_Key_HHs_Rollup__c;
			plan.Plan_Net_Income_Approved__c = plan.Plan_Net_Income_Rollup_By_Revenue__c;
			plan.Plan_T12_Recruited_Approved__c = plan.Plan_T12_Recruited__c;
			plan.Plan_T12_Attrited_Approved__c = plan.Plan_T12_Attrited__c;
		}
	}
	//***************End Before Trigger********************************************************************************************


	//***************After Trigger********************************************************************************************
	public static void processAfterTrigger(){
		//Get all the inserted or updated BoM Plans in scope
		List<BoM_Plan__c> newPlanList = trigger.new;
		
		list<BoM_Plan__c> toRollupPlanList = new list<BoM_Plan__c>();
		
		
		
		if(trigger.isInsert){
			for(BoM_Plan__c newPlan : newPlanList){
				//Any new added records, will affect the rollup total of the parents
				toRollupPlanList.add(newPlan);
			}
		}
		else if(trigger.isUpdate){
			for(BoM_Plan__c newPlan : newPlanList){
				BoM_Plan__c oldPlan = (BoM_Plan__c)trigger.oldMap.get(newPlan.Id);
				
				
				
				//If updates are made on the following fields, the parent's rollup needs to be updated
				if(BPCommonUtil.defaultNull(newPlan.Tonnage_Goal_Advisory_Net_Flows__c) != BPCommonUtil.defaultNull(oldPlan.Tonnage_Goal_Advisory_Net_Flows__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Advisory_Net_Flows_Rollup__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Advisory_Net_Flows_Rollup__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Advisory_Net_Flows_Approved__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Advisory_Net_Flows_Approved__c)
					
				|| BPCommonUtil.defaultNull(newPlan.Tonnage_Goal_Lending__c) != BPCommonUtil.defaultNull(oldPlan.Tonnage_Goal_Lending__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Lending_Rollup__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Lending_Rollup__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Lending_Approved__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Lending_Approved__c)
					
				|| BPCommonUtil.defaultNull(newPlan.Tonnage_Goal_New_Key_HHs__c) != BPCommonUtil.defaultNull(oldPlan.Tonnage_Goal_New_Key_HHs__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_New_Key_HHs_Rollup__c) != BPCommonUtil.defaultNull(oldPlan.Plan_New_Key_HHs_Rollup__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_New_Key_HHs_Approved__c) != BPCommonUtil.defaultNull(oldPlan.Plan_New_Key_HHs_Approved__c)
					
				|| BPCommonUtil.defaultNull(newPlan.Tonnage_Goal_Net_Income__c) != BPCommonUtil.defaultNull(oldPlan.Tonnage_Goal_Net_Income__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Net_Income_Rollup_By_Revenue__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Net_Income_Rollup_By_Revenue__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Net_Income_Rollup_Text__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Net_Income_Rollup_Text__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Net_Income_Approved__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Net_Income_Approved__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_Revenue__c) != BPCommonUtil.defaultNull(oldPlan.Plan_Revenue__c)
					
				|| BPCommonUtil.defaultNull(newPlan.Plan_T12_Recruited__c) != BPCommonUtil.defaultNull(oldPlan.Plan_T12_Recruited__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_T12_Attrited__c) != BPCommonUtil.defaultNull(oldPlan.Plan_T12_Attrited__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_T12_Recruited_Approved__c) != BPCommonUtil.defaultNull(oldPlan.Plan_T12_Recruited_Approved__c)
				|| BPCommonUtil.defaultNull(newPlan.Plan_T12_Attrited_Approved__c) != BPCommonUtil.defaultNull(oldPlan.Plan_T12_Attrited_Approved__c)){
					
					
					toRollupPlanList.add(newPlan);
				}
				
			}
		}
		
		//BPCommonUtil.logJson('toRollupPlanList', toRollupPlanList);
		//Update the rollup number of their parent if there is any children's update
		if(!ignoreRollup){
			BPBranchBusinessPlanUtil.initRecordType();
			updateRollupValues(toRollupPlanList);
		}
	}
	
	//Prepare the list of parent plans in scope and Update the plans values which will rollup from its child plans
	private static void updateRollupValues(list<BoM_Plan__c> toRollupPlanList){
		
		if(toRollupPlanList == null || toRollupPlanList.size() ==0){
			return;
		}
		
		rollupTimes++;
		if(rollupTimes > 50){
			//It's probably because there is a incorrect point of parent and child relationship in the data which causes the infinite loop
			//Stop here
			BPCommonUtil.log('Reaching the maximum rollup times');
			return;
		}
		
		set<Id> planIdSet = new set<Id>();
		set<Id> complexPlanIdSet = new set<Id>();
		set<Id> marketPlanIdSet = new set<Id>();
		set<Id> regionPlanIdSet = new set<Id>();
		
		//Get all the parent plan's Id. Each plan only has one direct parent and only direct parents should be updated
		for(BoM_Plan__c plan : toRollupPlanList){
			planIdSet.add(plan.Id);
			if(plan.Sub_Supl_Complex_Plan__c != null){
				complexPlanIdSet.add(plan.Sub_Supl_Complex_Plan__c);
			}
			else if(plan.Market_Complex_Plan__c != null){
				marketPlanIdSet.add(plan.Market_Complex_Plan__c);
			}
			else if(plan.Region_Plan__c != null){
				regionPlanIdSet.add(plan.Region_Plan__c);
			}
		}
		rollupParentPlanList(complexPlanIdSet, marketPlanIdSet, regionPlanIdSet);
	}
	//Sum up the child plans' plan values to its parent plan. The inputs are all parent plan Ids.
	public static void rollupParentPlanList(set<Id> complexPlanIdSet, set<Id> marketPlanIdSet, set<Id> regionPlanIdSet){
		
		list<BoM_Plan__c> toUpdateParentPlanList = BPBranchBusinessPlanUtil.getParentPlanList(complexPlanIdSet, marketPlanIdSet, regionPlanIdSet);
		BPCommonUtil.log('toUpdateParentPlanList', toUpdateParentPlanList);
		//Sum up the values from children
		for(BoM_Plan__c parentPlan : toUpdateParentPlanList){
			parentPlan.Tonnage_Goal_Advisory_Net_Flows__c = 0;
			parentPlan.Plan_Advisory_Net_Flows_Rollup__c = 0;
			parentPlan.Plan_Advisory_Net_Flows_Approved__c = 0;
			
			parentPlan.Tonnage_Goal_Lending__c = 0;
			parentPlan.Plan_Lending_Rollup__c = 0;
			parentPlan.Plan_Lending_Approved__c = 0;
			
			parentPlan.Tonnage_Goal_New_Key_HHs__c = 0;
			parentPlan.Plan_New_Key_HHs_Rollup__c = 0;
			parentPlan.Plan_New_Key_HHs_Approved__c = 0;
			
			parentPlan.Tonnage_Goal_Net_Income__c = 0;
			parentPlan.Plan_Net_Income_Rollup_Text__c = 0;//Specially, create a new field because it's orginally a formula
			parentPlan.Plan_Net_Income_Approved__c = 0;
			
			parentPlan.Plan_T12_Recruited__c = 0;
			parentPlan.Plan_T12_Attrited__c = 0;
			parentPlan.Plan_T12_Recruited_Approved__c = 0;
			parentPlan.Plan_T12_Attrited_Approved__c = 0;

			//when updating parent plan, only the direct children should be considered in scope. so search from market plans until branch plans for direct children
			if(parentPlan.Market_Plans__r.size() > 0){
				for(BoM_Plan__c marketPlan : parentPlan.Market_Plans__r){
					addTotal(parentPlan, marketPlan);
				}
			}
			else if(parentPlan.Complex_Plans__r.size() > 0){
				for(BoM_Plan__c complexPlan : parentPlan.Complex_Plans__r){
					addTotal(parentPlan, complexPlan);
				}
			}
			else{
				for(BoM_Plan__c branchPlan : parentPlan.BoM_Plans__r){
					addTotal(parentPlan, branchPlan);
				}
			}
			//BPCommonUtil.logJson('parentPlan', parentPlan);
			
		}
		
		//BPCommonUtil.logJson('Before update ParentPlanList', toUpdateParentPlanList);
		BPCommonUtil.log('After toUpdateParentPlanList', toUpdateParentPlanList);
		update toUpdateParentPlanList;
		//BPCommonUtil.logJson('After update ParentPlanList', toUpdateParentPlanList);
	}
	//Add child plan values to its parent plan values
	private static void addTotal(BoM_Plan__c parentPlan, BoM_Plan__c childPlan){
		if(!BPBranchBusinessPlanUtil.isDirectChild(parentPlan, childPlan)){
			return;
		}
		
		//Goals: Simply sum up of goal values
		//Approved: Simply sum up of approved values
		//Rollup: If the child is approved, sum up its approved values, otherwise, sum up the rollup values; So any update after approval will NOT affect the complex/market plan		
		if(isApproved(childPlan)){
			parentPlan.Plan_Advisory_Net_Flows_Rollup__c += BPCommonUtil.defaultNull(childPlan.Plan_Advisory_Net_Flows_Approved__c);
			parentPlan.Plan_Lending_Rollup__c += BPCommonUtil.defaultNull(childPlan.Plan_Lending_Approved__c);
			parentPlan.Plan_New_Key_HHs_Rollup__c += BPCommonUtil.defaultNull(childPlan.Plan_New_Key_HHs_Approved__c);
			parentPlan.Plan_Net_Income_Rollup_Text__c += BPCommonUtil.defaultNull(childPlan.Plan_Net_Income_Approved__c);
			parentPlan.Plan_T12_Recruited__c += BPCommonUtil.defaultNull(childPlan.Plan_T12_Recruited_Approved__c);
			parentPlan.Plan_T12_Attrited__c += BPCommonUtil.defaultNull(childPlan.Plan_T12_Attrited_Approved__c);
			
			system.debug('*** approved: parentPlan.Plan_Advisory_Net_Flows_Rollup__c: ' + parentPlan.Plan_Advisory_Net_Flows_Rollup__c);
		}
		else{
			parentPlan.Plan_Advisory_Net_Flows_Rollup__c += BPCommonUtil.defaultNull(childPlan.Plan_Advisory_Net_Flows_Rollup__c);
			parentPlan.Plan_Lending_Rollup__c += BPCommonUtil.defaultNull(childPlan.Plan_Lending_Rollup__c);
			parentPlan.Plan_New_Key_HHs_Rollup__c += BPCommonUtil.defaultNull(childPlan.Plan_New_Key_HHs_Rollup__c);
			
			BPCommonUtil.log('BPBranchBusinessPlanUtil.branchPlanRT', BPBranchBusinessPlanUtil.branchPlanRT);
			if(childPlan.RecordTypeId == BPBranchBusinessPlanUtil.branchPlanRT){
				//The child is a branch plan, add up with Plan_Net_Income_Rollup_By_Revenue__c instead, NOT Plan_Net_Income_Rollup_Text__c
				parentPlan.Plan_Net_Income_Rollup_Text__c += BPCommonUtil.defaultNull(childPlan.Plan_Net_Income_Rollup_By_Revenue__c);
			}
			else{
				parentPlan.Plan_Net_Income_Rollup_Text__c += BPCommonUtil.defaultNull(childPlan.Plan_Net_Income_Rollup_Text__c);
			}
			parentPlan.Plan_T12_Recruited__c += BPCommonUtil.defaultNull(childPlan.Plan_T12_Recruited__c);
			parentPlan.Plan_T12_Attrited__c += BPCommonUtil.defaultNull(childPlan.Plan_T12_Attrited__c);
			
			system.debug('*** not approved: parentPlan.Plan_Advisory_Net_Flows_Rollup__c: ' + parentPlan.Plan_Advisory_Net_Flows_Rollup__c);
		}
		
		
		
		parentPlan.Tonnage_Goal_Advisory_Net_Flows__c += BPCommonUtil.defaultNull(childPlan.Tonnage_Goal_Advisory_Net_Flows__c);
		parentPlan.Plan_Advisory_Net_Flows_Approved__c += BPCommonUtil.defaultNull(childPlan.Plan_Advisory_Net_Flows_Approved__c);
		
		parentPlan.Tonnage_Goal_Lending__c += BPCommonUtil.defaultNull(childPlan.Tonnage_Goal_Lending__c);
		parentPlan.Plan_Lending_Approved__c += BPCommonUtil.defaultNull(childPlan.Plan_Lending_Approved__c);
		
		parentPlan.Tonnage_Goal_New_Key_HHs__c += BPCommonUtil.defaultNull(childPlan.Tonnage_Goal_New_Key_HHs__c);
		parentPlan.Plan_New_Key_HHs_Approved__c += BPCommonUtil.defaultNull(childPlan.Plan_New_Key_HHs_Approved__c);
		
		parentPlan.Tonnage_Goal_Net_Income__c += BPCommonUtil.defaultNull(childPlan.Tonnage_Goal_Net_Income__c);
		parentPlan.Plan_Net_Income_Approved__c += BPCommonUtil.defaultNull(childPlan.Plan_Net_Income_Approved__c);
		
		parentPlan.Plan_T12_Recruited_Approved__c += BPCommonUtil.defaultNull(childPlan.Plan_T12_Recruited_Approved__c);
		parentPlan.Plan_T12_Attrited_Approved__c += BPCommonUtil.defaultNull(childPlan.Plan_T12_Attrited_Approved__c);
	}
	
	private static Boolean isApproved(BoM_Plan__c plan){
		return plan.Status__c == PLAN_STATUS_INACTION || plan.Status__c == PLAN_STATUS_CLOSED;
	}
	//***************End After Trigger********************************************************************************************

}