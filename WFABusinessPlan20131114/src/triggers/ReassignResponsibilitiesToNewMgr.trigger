trigger ReassignResponsibilitiesToNewMgr on Account (after update) {

Boolean Reassign = False;

for (account a : trigger.new) {
    account olda = trigger.oldmap.get(a.id);
    
    if ( (a.Manager_Branch__c != olda.Manager_Branch__c) ||
    (a.Market_Complex_Branch__c != olda.Market_Complex_Branch__c) ||
    (a.Sub_Supl_Complex_Branch__c != olda.Sub_Supl_Complex_Branch__c) )  {
        
        Reassign = True;    
        break;    
    
    }
   
}

if (Reassign) {
    
    //Map<ID, Contact> MgrMap = New Map<ID, Contact>([SELECT Terminated__c, ID, AccountID FROM Contact WHERE AccountID IN: Trigger.newmap.keyset()]);
    
    Map<ID, ID> ContactIDToUserIDMap = new Map<ID, ID>();
    
    //map out each Manager to his or her user id
    ContactIDToUserIDMap = MappingUserIDs.MapMgrToUserUsingBranch(trigger.newmap.Keyset());
    
    //Query all responsibilities related to the branchs of the termed managers
    Responsibilities__c[] rspb = [SELECT OwnerID, Branch__c FROM Responsibilities__c WHERE Branch__c IN: trigger.newmap.keyset()];
    
    if (rspb.size() > 0) {
        //reassign the owner of these responsibilities. check for sub cmplx mgr, and then mkt mgr
        for (Responsibilities__c r : rspb) {
            
            //branch mgr is rehired and his or her name is still listed on the branch
            if (ContactIDToUserIDMap.get(trigger.newmap.get(r.branch__c).Manager_Branch__c) != Null) {
                r.OwnerID = ContactIDToUserIDMap.get(trigger.newmap.get(r.branch__c).Manager_Branch__c);
            
            //sub complex mgr is an active sf user
            } else if (ContactIDToUserIDMap.get(trigger.newmap.get(r.branch__c).Sub_Complex_Manager_ID__c) != Null) {
                r.OwnerID = ContactIDToUserIDMap.get(trigger.newmap.get(r.branch__c).Sub_Complex_Manager_ID__c);
            
            //Mkt manager is an active sf user
            } else if (ContactIDToUserIDMap.get(trigger.newmap.get(r.branch__c).Mkt_Cmplx_Manager_ID__c) != Null) {
                r.OwnerID = ContactIDToUserIDMap.get(trigger.newmap.get(r.branch__c).Mkt_Cmplx_Manager_ID__c);
                
            }
        }
        

        try {
            system.debug('Reassigned Mgr Responsibilities -------- ' + rspb);
            update rspb;
        } catch (exception e) {
            for (account a: trigger.new) {
           
                a.adderror(' Error occured while reassigning manager responsibilities. Contact your system administrator.');
                system.debug('Error while reassigning manager responsibilities ------ ' + e.getMessage());
            }
        }
    }

}  


}