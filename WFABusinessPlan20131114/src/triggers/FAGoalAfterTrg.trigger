trigger FAGoalAfterTrg on FA_Goal__c (after insert, after update) {
	
	if(trigger.isAfter) {
		if(trigger.isInsert) {
			FAGoalUtil.processAfterTrg(trigger.newMap, null); 
		}else if(trigger.isUpdate) {
			FAGoalUtil.processAfterTrg(trigger.newMap, trigger.oldMap); 
		}
	}
}