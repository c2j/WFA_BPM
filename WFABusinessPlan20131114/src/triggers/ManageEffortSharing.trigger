trigger ManageEffortSharing on Opportunity (after insert, after update) {

//give the market manager related to the branch that an experienced effort is being recruited into
//edit access to that effort record. If the branch on the effort changes, the manager sharing
//record should change as well

List<OpportunityShare> EffortSharesToInsert = new List<OpportunityShare>();

List<OpportunityShare> EffortSharesToDelete = new List<OpportunityShare>();

Map<ID, List<ID>> MgrsToGetEffortAccess = new Map<ID, List<ID>>();
List<ID> MgrsToLoseEffortAccess = new List<ID>();

Map<Id, Opportunity> OldEffortsMap = new Map<ID, Opportunity>();
Map<ID, Opportunity> EffortsMap = new Map<ID, Opportunity>();

Set<ID> BranchIDs = new Set<ID>();
Set<ID> OldBranchIDs = new Set<ID>();

for (opportunity effort : trigger.new) {

    if (effort.RecordTypeID == '01250000000UISS') {//only experienced efforts
        
        EffortsMap.put(effort.id, effort);
        BranchIDs.add(effort.AccountID);
        
        if (trigger.isUpdate) {
        
            Opportunity oldEffort = trigger.oldmap.get(effort.id);
            
            //the branch on the effort is changing, so the managers sharing records need to be reevaluated
               // OldEffortsMap.put(effort.Id, OldEffort);
               // OldBranchIDs.add(oldEffort.AccountID);
                
            if (effort.AccountID != oldEffort.AccountID) {
                
                OldEffortsMap.put(effort.Id, OldEffort);
               
                OldBranchIDs.add(oldEffort.AccountID);
                
            }
            
        }
    }
}

//only reevaluate sharing if the effort is being inserted with a branch or the branch is being updated on an existing effort
if ((Trigger.IsInsert || OldBranchIDs.size() > 0) && BranchIDs.size() > 0) {

    Set<String> Emails = new Set<String>();
    Map<ID, User> MgrUsersMap = new Map<ID, User>();
    Set<Account> Branches = new Set<Account>();
    Set<ID> MgrIDs = new Set<ID>();
    
    Map<ID, Account> branchMap = new Map<ID, Account>([SELECT ID, Manager_Branch__c, Sub_Complex_Manager_ID__c, Mkt_Cmplx_Manager_ID__c, Main_Branch_Manager_ID__c,
    Manager_Branch_Email__c, Manager_Sub_Supl_Complex_Email__c, Manager_Market_Complex_Email__c, Manager_Main_Branch_Email__c, SDBK_ID__c,
    Senior_Director_of_Brokerage_Email__c FROM
    Account WHERE (ID IN: BranchIDs OR ID IN: OldBranchIDs)]);
    
    Branches.addall(BranchMap.Values());
        
    List<String> EmailList = MappingUserIDs.MapManagersIDsToEmails(Branches).values();
    
    Emails.addall(EmailList);
    
    system.debug('Branches with efforts --------- ' + Branches);
    system.debug('Managers emails ---------- ' + Emails);
    
    if (Emails.size() > 0) {
        MgrIDs = MappingUserIDs.MapManagersIDsToEmails(Branches).keyset();
        
        MgrUsersMap = MappingUserIDs.GetMgrUserMapByEmails(Emails);

        system.debug('Mgr Users Map ------------- ' + MgrUsersMap);
                
        Map<ID, ID> MgrIDsToUserIDsMap = new Map<ID, ID>();
        
        MgrIDsToUserIDsMap = MappingUserIDs.MapContactIDToUserID(MgrIds, MgrUsersMap.values());
        
        system.debug('Mgr Ids to User Ids Map ------------- ' + MgrIDsToUserIDsMap);
        
        for (Opportunity e: EffortsMap.values()) {
            
            List<ID> CrntMgrIds = new List<ID>();
            
            //check if crnt branch manager is a sf user and has a market manager profile
            
            //system.debug('Branch Mgr a user? --------- ' + MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Manager_Branch__c));
            if (MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Manager_Branch__c) != Null) {
                
                CrntMgrIds.add(MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Manager_Branch__c));
                
            } 
            
            //check if crnt main branch manager is a sf user and has a market manager profile
            
            //system.debug('Main Branch Mgr a user? --------- ' + MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Main_Branch_Manager_ID__c));        
            if (MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Main_Branch_Manager_ID__c) != Null) {
                
                CrntMgrIds.add(MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Main_Branch_Manager_ID__c));
                
            }
            
            //check if crnt sub complex manager is a sf user and has a market manager profile
            //system.debug('SC Mgr a user? --------- ' + MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Sub_Complex_Manager_ID__c));                
            if (MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Sub_Complex_Manager_ID__c) != Null) {
                
                CrntMgrIds.add(MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Sub_Complex_Manager_ID__c));
                
            }
    
            //check if crnt market complex manager is a sf user and has a market manager profile 
            //system.debug('Mkt Mgr a user? --------- ' + MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Mkt_Cmplx_Manager_ID__c));        
            if (MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Mkt_Cmplx_Manager_ID__c) != Null) {
                
                CrntMgrIds.add(MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).Mkt_Cmplx_Manager_ID__c));
                
            }  

            //check if crnt SDBK is a sf user and has a market manager profile 
            //system.debug('SDBK a user? --------- ' + MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).SDBK_ID__c));        
            if (MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).SDBK_ID__c) != Null) {
                
                CrntMgrIds.add(MgrIDsToUserIDsMap.get(BranchMap.get(e.AccountId).SDBK_ID__c));
                
            }                     
            
            //map crnt effort id to list of managers that should get access to it     
            //only if there are any managers related to the branch
            if (CrntMgrIDs.size() > 0) { 
                MgrsToGetEffortAccess.put(e.id, CrntMgrIds);
            }
            
            //get list of managers who need to have access to current list of efforts removed
            if (OldEffortsMap.keyset().size()> 0 && OldEffortsMap.get(e.Id) != Null) {
            
                Opportunity oldEffort = OldEffortsMap.get(e.Id);
                
                //check if old branch manager is a sf user and has a market manager profile
                if (MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Manager_Branch__c) != Null) {
                    
                    MgrsToLoseEffortAccess.add(MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Manager_Branch__c));
                    
                } 
                
                //check if old main branch manager is a sf user and has a market manager profile        
                if (MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Main_Branch_Manager_ID__c) != Null) {
                    
                    MgrsToLoseEffortAccess.add(MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Main_Branch_Manager_ID__c));
                    
                }
                
                //check if old sub complex manager is a sf user and has a market manager profile        
                if (MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Sub_Complex_Manager_ID__c) != Null) {
                    
                    MgrsToLoseEffortAccess.add(MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Sub_Complex_Manager_ID__c));
                    
                }
        
                //check if old market complex manager is a sf user and has a market manager profile        
                if (MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Mkt_Cmplx_Manager_ID__c) != Null) {
                    
                    MgrsToLoseEffortAccess.add(MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).Mkt_Cmplx_Manager_ID__c));
                    
                } 

                //check if old sdbk is a sf user and has a market manager profile        
                if (MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).SDBK_ID__c) != Null) {
                    
                    MgrsToLoseEffortAccess.add(MgrIDsToUserIDsMap.get(BranchMap.get(oldEffort.AccountId).SDBK_ID__c));
                    
                }                 
            }
            
    
        }
        
        if (MgrsToLoseEffortAccess.size() > 0) {
            List<ID> EffortIDs = new List<String>();
            EffortIds.addall(EffortsMap.keyset());
            
            system.debug('Mgrs to lose effort access ---------------- ' + MgrsToLoseEffortAccess + ' / ' + EffortIDs);
            
            ApexBasedSharingCls.DeleteEffortSharingRecords(EffortIDs, MgrsToLoseEffortAccess);
        }        
        
        system.debug('Mgrs to get effort access --------- ' + MgrsToGetEffortAccess);
        
        if (MgrsToGetEffortAccess.values().size() > 0) {
            EffortSharesToInsert = ApexBasedSharingCls.CreateEffortSharing(MgrsToGetEffortAccess);
            
            system.debug('Effort shares to insert --------- ' + EffortSharesToInsert);
                
            //system.debug('Old branch ids ---------- ' + oldbranchids);
            
            //if (OldbranchIds.size() >= 0) {
                ApexBasedSharingCls.InsertEffortSharingRecords(EffortSharesToInsert);
            //}
        }
    

    }
    
}

}