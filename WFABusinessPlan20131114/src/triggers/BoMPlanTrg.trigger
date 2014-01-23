trigger BoMPlanTrg on BoM_Plan__c (after insert, after update, before insert, before update) {
	BoMPlanTrgHandler.processTrigger();	
}