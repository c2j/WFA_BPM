trigger AssigningResponsibilities on Responsibilities__c (before insert) {

//Setting to the owner ids of responsibility records that have branches to one of the managers at those branches
//if no manager at the branch is an active salesforce user, then assign the record to the creator
    
Map<ID, ID> ContactIDToUserIDMap = new Map<ID, ID>();

Set<ID> BranchIDs = new Set<ID>();
        
for (Responsibilities__c r: trigger.new) {

    if (r.Branch__c != Null) {
        
        BranchIDs.add(r.Branch__c);
        
    }
    
}

if (BranchIDs.size() > 0) {
    
    Map<ID, Account> BranchMap = new Map<ID, Account>([SELECT ID, Manager_Branch__c,Sub_Complex_Manager_ID__c,
    Mkt_Cmplx_Manager_ID__c FROM Account WHERE ID IN: BranchIDs]);
    
    //map out each Manager to his or her user id
    ContactIDToUserIDMap = MappingUserIDs.MapMgrToUserUsingBranch(BranchIDs);
    
    system.debug('Contact id to user id map for assigning responsibilities ------------- ' + ContactIDToUserIDMap);
    
    if (ContactIDTouserIDMap != Null) {
        for (Responsibilities__c r: trigger.new) {
        
            if (r.Branch__c != Null) {
            
                if (ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Manager_Branch__c) != Null) {
                
                    r.OwnerID = ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Manager_Branch__c);
                    
                } else if (ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Sub_Complex_Manager_ID__c) != Null) {
                
                    r.OwnerID = ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Sub_Complex_Manager_ID__c);
                    
                } else if (ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Mkt_Cmplx_Manager_ID__c) != Null) {
                
                    r.OwnerID = ContactIDToUserIDMap.get(BranchMap.get(r.Branch__c).Mkt_Cmplx_Manager_ID__c);
                    
                }
                
            }
        }
    }   
}

}