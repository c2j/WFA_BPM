trigger AssociateBranchToMcLagan on McLagan__c (before insert, before update) {
	
	Set<String> BranchAU  = new Set<String>();
	Map<String, Id> BranchMap = new Map<String, Id>();
	Map<String, McLagan__c> MLMap = new Map<String, McLagan__c>();
    
	for(McLagan__c ml: Trigger.new){
		if(ml.Branch__c != null & ml.Branch__c !='')
			BranchAU.add('%'+ml.Branch__c);
	}
	List<Account> branchList = [Select id, AU__c, Name from Account where AU__c LIKE : BranchAU];
	System.debug('Retrieved branch list size: '+branchList.size());
	for(Account branch : branchList){
		system.debug('Branch substring: '+branch.AU__c.substring(branch.AU__c.length()-5));
		BranchMap.put(branch.AU__c.substring(branch.AU__c.length()-5), branch.id);
	}
	for(McLagan__c ml: Trigger.new){
		ml.Related_Branch__c = BranchMap.get(ml.Branch__c);
		ml.McLagan_Unique_Id__c = ml.Branch__c + ml.Period__c;
		if ((ml.McLagan_Unique_Id__c != null) && (System.Trigger.isInsert || (ml.McLagan_Unique_Id__c != System.Trigger.oldMap.get(ml.Id).McLagan_Unique_Id__c))) {
		
            if (MLMap.containsKey(ml.McLagan_Unique_Id__c)) {
                ml.McLagan_Unique_Id__c.addError('Another new McLagan record for same quarter of the same branch.');
            } else {
                MLMap.put(ml.McLagan_Unique_Id__c, ml);
            }
       }
		
	}
	for (McLagan__c ml : [SELECT McLagan_Unique_Id__c FROM McLagan__C WHERE McLagan_Unique_Id__c IN :MLMap.KeySet()]) {
        McLagan__c newML = MLMap.get(ml.McLagan_Unique_Id__c);
        newML.McLagan_Unique_Id__c.addError('McLagan record for this quarter of the branch exist');
    }
}