trigger LeadershipPlanTrg on Leadership_Plan__c (after insert, after update, before insert, before update) {
	LeadershipPlanTrgHandler.processTrigger();
}