trigger BranchManagerShare on Account (after insert, after update) {

Map<Account, ID> BranchesMap = new Map<Account, ID>();
Map<Account, ID> OldBranchesMap = new Map<Account, ID>();

if (!Validator_cls.hasAlreadyDone()) {//prevents workflows from firing trigger twice

for (account branch : trigger.new) {

    if (branch.branch_close_date__c == null) {//only create access records for active branches
        
        if (branch.Manager_Branch__c != null ||
            branch.Sub_Complex_Manager_ID__c != null ||
            branch.Mkt_Cmplx_Manager_ID__c != null ||
            branch.Main_Branch_Manager_ID__c != null ||
            branch.SDBK_ID__c != null) {
    
            BranchesMap.put(branch,branch.id);
            
        }
        
        if (trigger.isUpdate) {
        
            Account oldBranch = trigger.oldmap.get(branch.id);
            
            //if the manager, sub complex, market complex, or main branch is updated on a branch, the branch's sharing
            //records need to be reevaluated 
            
            if (branch.Manager_Branch__c != oldBranch.Manager_Branch__c ||
            branch.Sub_Supl_Complex_Branch__c != oldBranch.Sub_Supl_Complex_Branch__c ||
            branch.Market_Complex_Branch__c != oldBranch.Market_Complex_Branch__c ||
            branch.Main_Branch__c != oldBranch.Main_Branch__c || 
            branch.Region_Branch__c != oldBranch.Region_Branch__c) {
                
                system.debug('Branch manager, main branch, sub complex, mkt complex, or region is being updated on ------- ' + branch.Name);
                
                BranchesMap.put(branch,branch.id);
                OldBranchesMap.put(oldBranch, oldbranch.id);
                
            }
            
        }
    }
}

//Process below only if branch is inserted or its managers and/or main branch are being updated
if ((Trigger.isInsert || OldBranchesMap.values().size() > 0) && BranchesMap.values().size() > 0) {

    Map<ID, ID> MgrsToUserIDMap = new Map<ID, ID>(); //map of manager's contact record id to his user record id
    
    Set<String> Emails = new Set<String>();
    Set<ID> MgrIds = new Set<ID>();
    
    //store all managers emails to use to query their user records. if manager doesn't have an email, there will be no
    //way to match him to a user record
    Emails.addall(MappingUserIDs.MapManagersIDsToEmails(BranchesMap.keyset()).values());
    Emails.addall(MappingUserIDs.MapManagersIDsToEmails(OldBranchesMap.keyset()).values());
    
    if (Emails.size() > 0) {
        //store all managers ids to use to query their user records
        MgrIds.addall(MappingUserIDs.MapManagersIDsToEmails(BranchesMap.keyset()).keyset());    
        MgrIds.addall(MappingUserIDs.MapManagersIDsToEmails(OldBranchesMap.keyset()).keyset());
        
        //map out each current manager associated with the list of active branches to the manager's user record ids
        MgrsToUserIDMap = MappingUserIDs.MapContactIDToUserID(MgrIDs, MappingUserIds.GetMgrUserMapByEmails(Emails).Values());
        
        system.debug('Manager contact id to user id map ------------ ' + MgrsTouserIDMap);
        
        //call apex class to do all the sharing record evaluations
        ApexBasedSharingCls.CreateBranchAccessAndNoAccessList(BranchesMap.keyset(), Trigger.oldmap, MgrsToUserIDMap);
    }
    
}

//Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again   
}
}