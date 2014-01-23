@isTest
private class RankingAfterTrgTest {
	private static testmethod void testRankingUpsert(){
		list<Account> branchList = BranchUtil.createSampleBranchWithFAsMainBranchAndPlan();
		
		list<Ranking__c> rankingList = [Select Id, Name From Ranking__c];
		for(Ranking__c ranking : rankingList){
			ranking.FA_Goal_Advisory_Flows__c = 100000;
		}
		update rankingList;
	}
}