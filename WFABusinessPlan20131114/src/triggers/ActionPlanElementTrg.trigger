trigger ActionPlanElementTrg on Action_Plan_Element__c (before insert) {
	
	if(trigger.isBefore && trigger.isInsert) {
		ActionPlanElementUtil.updateFARankingField();
	}
}