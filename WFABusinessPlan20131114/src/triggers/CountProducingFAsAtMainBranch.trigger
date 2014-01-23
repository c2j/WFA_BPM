trigger CountProducingFAsAtMainBranch on Account (after update) {

Set<ID> MBIds = new Set<ID>();

    For (Account a : trigger.new) {
        Account oldBr = trigger.oldmap.get(a.id);
        if (a.Number_Of_Producing_FAs__c != oldBr.Number_Of_Producing_FAs__c) {
            
            MBIds.add(a.Main_Branch__c);
        
        }
    }  
    
    if (MBIds.size() > 0) {
        
        List<Account> accts = [SELECT ID, Main_Branch__c, Number_Of_Producing_FAs__c FROM Account WHERE
                                Main_Branch__c IN : MBIds ORDER BY Number_Of_Producing_FAs__c DESC];
        
        
        Map<ID, Integer> MBFAs = new Map<ID, Integer>();
        
        for (integer i = 0; i<accts.size(); i++) {
        
            system.debug('Account ID ---------- ' + accts[i].id);
            system.debug('Main Branch ID ---------- ' + accts[i].Main_Branch__c);
            system.debug('Number of FAs ---------- ' + accts[i].Number_Of_Producing_FAs__c);
            
            
            if (MBFAs.containskey(accts[i].Main_Branch__c)) {
            system.debug('Main Branch FAs --------- ' + MBFAs.get(accts[i].Main_Branch__c));
                if (MBFAs.get(accts[i].Main_Branch__c) == NULL) {
                    MBFAs.put(accts[i].Main_Branch__c, integer.valueof(accts[i].Number_Of_Producing_FAs__c));
                } else {
                    MBFAs.put(accts[i].Main_Branch__c, MBFAs.get(accts[i].Main_Branch__c) + integer.valueof(accts[i].Number_Of_Producing_FAs__c));
                }
            } else {
                MBFAs.put(accts[i].Main_Branch__c, integer.valueof(accts[i].Number_Of_Producing_FAs__c));
            }
        }
        
        Main_Branch__c[] MainBranches = [SELECT ID, Number_Of_Producing_FAs__c FROM Main_Branch__c WHERE ID IN : MBIds];
       
       system.debug('Main Branches ----------- ' + MainBranches); 
       
        for (Main_Branch__c mb : MainBranches) {
            mb.Number_Of_Producing_FAs__c = MBFAs.get(mb.id);
        }
        
        try {
            update MainBranches;
        } catch (System.DmLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                e.setMessage('Error occured while updating number of producing FAs at main branch');
            }
        }   
        
        
        
    }
    
            
         
}