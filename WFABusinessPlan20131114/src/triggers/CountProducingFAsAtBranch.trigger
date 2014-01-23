trigger CountProducingFAsAtBranch on Contact (After Insert, After Update, after Delete) {

Set<ID> aID = new Set<ID>();
Set<Contact> updatedFAs = new Set<Contact>();
Map<ID, Integer> BranchFAs = new Map<ID, Integer>();
Integer NumOfFAs = 0;
List<Contact> FAs = new List<Contact>();

    if (Trigger.isInsert) {
    
        for (contact c : trigger.new) {
            if (c.AccountID != NULL) {
                aID.add(c.AccountID);
            }
        }
        
        if (aID.size() > 0) {
            FAs = [SELECT Id, AccountID, Channel__c, Type__c, Terminated__c, Production_YTD__c FROM Contact WHERE
            AccountID IN: aID AND (Type__c = 'FA' OR Type__c = 'FA in Training' OR Type__c = 'Branch Manager'
            OR Type__c = 'Licensee') AND Terminated__c != 'Yes' AND Production_YTD__c >0 ORDER BY AccountID];
        }
    
    } else if (Trigger.isUpdate) {

        for (contact c : trigger.new) {
            Contact oldFA = trigger.OldMap.get(c.id);
            
            //system.debug('new type ------ ' + c.type__c);
            //system.debug('old type ------ ' + oldFA.type__c);
            //system.debug('new ytd prod ------ ' + c.production_ytd__c);
            //system.debug('old ytd prod ------ ' + oldFA.production_ytd__c);
            
            if (oldFA.AccountID != c.AccountID) {
                aID.add(c.AccountID);
                aID.add(oldFA.AccountID); //add the previous branch id to update the number of producing FA fields on it
            } else if (
               (oldFA.Terminated__c != 'Yes' && c.Terminated__c == 'Yes') || 
               
               ((oldFA.Production_YTD__c <= 0 || oldFA.Production_YTD__c == NULL) && c.Production_YTD__c >0) ||
              
               (oldFA.Production_YTD__c > 0 && (c.Production_YTD__c <= 0 || c.Production_YTD__c == NULL)) || 
            
               ((oldFA.Type__c != 'FA' && 
                oldFA.Type__c != 'FA in Training' && oldFA.Type__c != 'Branch Manager' && oldFA.Type__c != 'Licensee') &&
               (c.Type__c == 'FA' || c.Type__c == 'FA in Training' || c.Type__c == 'Branch Manager' || 
                c.Type__c == 'Licensee')) ||
            
               ((oldFA.Type__c == 'FA' ||
                oldFA.Type__c == 'FA in Training' || oldFA.Type__c == 'Branch Manager' || oldFA.Type__c == 'Licensee') &&
               (c.Type__c != 'FA' && c.Type__c != 'FA in Training' && c.Type__c != 'Branch Manager' && 
                c.Type__c != 'Licensee'))
                )
            
            {
            
            system.debug('Account id ------- ' + c.AccountID);
            
                aID.add(c.AccountID);
                
            }
            
        }
        
        if (aID.size()>0) {
            FAs = [SELECT Id, AccountID, Channel__c, Type__c, Terminated__c, Production_YTD__c FROM Contact WHERE
            AccountID IN: aID AND (Type__c = 'FA' OR Type__c = 'FA in Training' OR Type__c = 'Branch Manager'
            OR Type__c = 'Licensee') AND Terminated__c != 'Yes' AND Production_YTD__c >0 ORDER BY AccountID];
        }
  
 
    } else if (Trigger.isDelete) {
        
        for (contact c : trigger.old) {
            if (c.AccountID != NULL) {
                aID.add(c.AccountID);
            }
        }
        system.debug('Account id --------- ' + aID);
        
        if (aID.size() > 0) {
            FAs = [SELECT Id, AccountID, Channel__c, Type__c, Terminated__c, Production_YTD__c FROM Contact WHERE
            AccountID IN: aID AND (Type__c = 'FA' OR Type__c = 'FA in Training' OR Type__c = 'Branch Manager'
            OR Type__c = 'Licensee') AND Terminated__c != 'Yes' AND Production_YTD__c >0 ORDER BY AccountID];           
        }
        
        system.debug('FAs -------- ' + FAs);
        
    }


if (FAs.size()>0) {
    system.debug('FA Size -------- ' + FAs.size());
    
    for (Integer i=0;i<FAs.size();i++) {
        If (BranchFAs.containskey(FAs[i].AccountID)) {
        system.debug('Num of FAs --------- ' + BranchFAs.get(FAs[i].AccountID));
        
            BranchFAs.put(FAs[i].AccountID, BranchFAs.get(FAs[i].AccountID)+1);
        } else {
            BranchFAs.put(FAs[i].AccountID, 1);
        }
    }
    
    if (BranchFAs.keyset().size()>0) {
        Account[] accts = [SELECT ID, Number_of_Producing_FAs__c FROM Account WHERE Id IN : BranchFAs.keyset()];
    
    system.debug('Accounts --------- ' + accts);

        if (accts.size()> 0) {
            for (Account a : accts) {
                a.Number_of_Producing_FAs__c = BranchFAs.get(a.id);
            }
            
            try {
                update accts;
            } catch (System.DmLException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    e.setMessage('Error occured while updating number of Producing FAs at branch');
                }
            }   
        }
    }
}
   
}