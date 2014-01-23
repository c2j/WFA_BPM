trigger ReassignTermedMgrsResponsibilities on Contact (after update) {

List<Contact> TermedMgrs = New List<Contact>();
Set<ID> BranchIDs = New Set<ID>();


for (contact c : trigger.new) {
    contact oldc = trigger.oldmap.get(c.id);
    /*
    system.debug('termed contact name ----- ' + c.FirstName + ' ' + c.LastName);
    system.debug('Branch Mgr name ------ ' + c.Manager_Branch__c);
    system.debug('Sub Cmplx Mgr name ------- ' + c.Manager_Sub_Supl_Complex__c);
    system.debug('Mkt mgr name ------ ' + c.Manager_Market_Complex__c);
    system.debug('name match? ---------- ' +  (c.FirstName + ' ' + c.LastName == c.Manager_Branch__c || c.FirstName + ' ' + c.LastName == c.Manager_Sub_Supl_Complex__c || c.FirstName + ' ' + c.LastName == c.Manager_Market_Complex__c));
    */
    if (((c.Terminated__c == 'Yes' && oldc.Terminated__c == 'No') || (c.Terminated__c == 'No' && oldc.Terminated__c == 'Yes'))&& 
        c.FirstName + ' ' + c.LastName == c.Manager_Branch__c || c.FirstName + ' ' + c.LastName == c.Manager_Sub_Supl_Complex__c || 
        c.FirstName + ' ' + c.LastName == c.Manager_Market_Complex__c) {
        
            TermedMgrs.add(c);
            BranchIDs.add(c.AccountID);
    }
}    

if (TermedMgrs.size() > 0) {

    //system.debug('Termed Branch Managers ---------- ' + TermedMgrs);
    
    Map<ID, Account> BranchMap = new Map<ID, Account>([SELECT ID, Manager_Branch__c,Sub_Complex_Manager_ID__c,
    Mkt_Cmplx_Manager_ID__c FROM Account WHERE ID IN: BranchIDs]);
    
    
    Map<ID, ID> ContactIDToUserIDMap = new Map<ID, ID>();
    
    //map out each Manager to his or her user id
    ContactIDToUserIDMap = MappingUserIDs.MapMgrToUserUsingBranch(BranchMap.Keyset());
    
    //Query all responsibilities related to the branchs of the termed managers
    Responsibilities__c[] rspb = [SELECT OwnerID, Branch__c FROM Responsibilities__c WHERE Branch__c IN: BranchIDs];
    
    if (rspb.size() > 0) {
        //reassign the owner of these responsibilities. check for sub cmplx mgr, and then mkt mgr
        for (Responsibilities__c r : rspb) {
            
            system.debug('mkt mgr user ------- ' + BranchMap.get(r.Branch__c).Mkt_Cmplx_Manager_ID__c + ' / ' + ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Mkt_Cmplx_Manager_ID__c));

            //branch mgr is rehired and his or her name is still listed on the branch
            if (trigger.newmap.get(BranchMap.get(r.Branch__c).Manager_Branch__c) != Null && 
            trigger.newmap.get(BranchMap.get(r.Branch__c).Manager_Branch__c).Terminated__c == 'No' &&
            ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Manager_Branch__c) != Null) {
            
                r.OwnerID = ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Manager_Branch__c);
            
            //sub complex mgr is an active sf user
            } else if (ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Sub_Complex_Manager_ID__c) != Null) {
            
                r.OwnerID = ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Sub_Complex_Manager_ID__c);
            
            //Mkt manager is an active sf user
            } else if (ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Mkt_Cmplx_Manager_ID__c) != Null) {
            
                r.OwnerID = ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Mkt_Cmplx_Manager_ID__c);
                
            }
        }
        

        try {
            system.debug('Reassigned Mgr Responsibilities -------- ' + rspb);
            update rspb;
        } catch (exception e) {
            for (contact c: TermedMgrs) {
            
                c.adderror(' Error occured while reassigning manager responsibilities. Contact your system administrator.');
                system.debug('Error while reassigning manager responsibilities ------ ' + e.getMessage());
            }
        }
    }
}

}