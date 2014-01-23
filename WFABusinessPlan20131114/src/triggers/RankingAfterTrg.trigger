trigger RankingAfterTrg on Ranking__c (after insert, after update) {
	if(trigger.isAfter){
		RankingUtil.processAfterTrg();
	}
	
}