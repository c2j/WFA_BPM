trigger ReEvalSharingRecsWhenMktCmplxMgrChanges on Market_Complex__c (after update) {

//when a market complex manager changes, the previous manager needs to have his sharing records on
//all the related branches and main branches removed, where as the new manager, if he is a SF user,
//needs to have a sharing record created for all the related branches and main branches

List<AccountShare> BranchSharesToInsert = new List<AccountShare>();
List<Main_Branch__Share> MainBranchSharesToInsert = new List<Main_Branch__Share>();

List<AccountShare> BranchSharesToDelete = new List<AccountShare>();
List<Main_Branch__Share> MainBranchSharesToDelete = new List<Main_Branch__Share>();

Map<ID, List<ID>> MgrsToGetBranchAccess = new Map<ID, List<ID>>();
Map<ID, List<ID>> MgrsToGetMBAccess = new Map<ID, List<ID>>();

List<ID> MgrsToLoseAccess = new List<ID>();

List<ID> MktComplexIDs = new List<ID>();
Set<ID> MgrIDs = new Set<ID>();
Set<ID> OldMgrIds = new Set<ID>();

List<ID> BranchIDs = new  List<ID>();
List<ID> MainBranchIDs = new  List<ID>();
Set<String> Emails = new Set<String>();

for (Market_Complex__c mc : Trigger.new) {

    Market_Complex__c oldMC = trigger.oldmap.get(mc.id);
    
    if (mc.Manager_Market_Complex__c != Null) {
        MgrIDs.add(mc.Manager_Market_Complex__c);
        
    }

    if (mc.Manager_Market_Complex__c != oldMC.Manager_Market_Complex__c) {
        OldMgrIDs.add(oldMC.Manager_Market_Complex__c);
        MktComplexIds.add(mc.id);
    }
            
    if (mc.Manager_Market_Complex_Email__c != Null) {
        Emails.add(mc.Manager_Market_Complex_Email__c);
    }
    
        
    if (oldMC.Manager_Market_Complex_Email__c != Null) {
        
        Emails.add(oldMC.Manager_Market_Complex_Email__c);
        
        
    }
 
}

if (MktComplexIds.size() > 0 && Emails.size() > 0) {       
        
    Set<ID> AllMgrIds = new Set<ID>();
    AllMgrIds.AddAll(MgrIds);
    AllMgrIds.AddAll(OldMgrIds);
    
    Map<ID, ID> MgrsToUserIDMap = new Map<ID, ID>(); //map of manager's contact record id to his user record id
    
    //map out each current manager associated with the list of active branches to the manager's user record ids
    MgrsToUserIDMap = MappingUserIDs.MapContactIDToUserID(AllMgrIDs, MappingUserIds.GetMgrUserMapByEmails(Emails).Values());
    
    for (Account b : [SELECT Main_Branch__c, Main_Branch_Manager_ID__c,Market_Complex_Branch__c,
    Manager_Branch__c, Mkt_Cmplx_Manager_ID__c FROM Account WHERE Active__c = True AND Market_Complex_Branch__c IN : MktComplexIds
    ORDER BY Market_Complex_Branch__c DESC]) {
        
        Market_Complex__c oldMC = trigger.oldmap.get(b.Market_Complex_Branch__c);
                    
        BranchIds.add(b.id);
        MainBranchIDs.add(b.Main_Branch__c);
            
        List<ID> NewMgrUserIDs = new List<ID>();
        
        If (MgrsToUserIDMap.get(b.Mkt_Cmplx_Manager_ID__c) != Null) {
            
            NewMgrUserIDs.add(MgrsToUserIDMap.get(b.Mkt_Cmplx_Manager_ID__c));
            
        }
        
        MgrsToGetBranchAccess.put(b.id, NewMgrUserIDs);
        
        MgrsToGetMBAccess.put(b.Main_Branch__c, NewMgrUserIDs);
        
        if (b.Mkt_Cmplx_Manager_ID__c != oldMC.Manager_Market_Complex__c &&
        MgrsToUserIDMap.get(oldMC.Manager_Market_Complex__c) != Null) {
        
            MgrsToLoseAccess.add(MgrsToUserIDMap.get(oldMC.Manager_Market_Complex__c)); 

        }
    
    }
    
    system.debug('Mkt Complex Managers to get branch access ---------- ' + MgrsToGetBranchAccess);
    system.debug('Mkt Complex Managers to get main branch access ---------- ' + MgrsToGetMBAccess);    
    
    BranchSharesToInsert = ApexBasedSharingCls.CreateBranchSharing(MgrsToGetBranchAccess);
    MainBranchSharesToInsert = ApexBasedSharingCls.CreateMainBranchSharing(MgrsToGetMBAccess);
    
    system.debug('Mkt Complex Managers to lose branch and main branch access ---------- ' + MgrsToLoseAccess);
    
    //BranchSharesToDelete = ApexBasedSharingCls.DeleteBranchSharing(BranchIDs, MgrsToLoseAccess);
    //MainBranchSharesToDelete = ApexBasedSharingCls.DeleteMainBranchSharing(MainBranchIDs, MgrsToLoseAccess);
    
    if (MgrsToLoseAccess.size() > 0) {
    
        if (BranchIds.size() > 0) {
            ApexBasedSharingCls.DeleteBranchSharingRecords(BranchIDs, MgrsToLoseAccess);
        }
         
        if (MainBranchIDs.size() > 0) {   
            ApexBasedSharingCls.DeleteMBSharingRecords(MainBranchIDs, MgrsToLoseAccess);
        }

        Map<Id, Opportunity> BranchEfforts = new Map<ID, Opportunity>([SELECT ID FROM Opportunity WHERE AccountID IN: BranchIDs]);
        List<ID> EffortIDs = new List<ID>(BranchEfforts.keyset());
        
        if (EffortIds.size() > 0) {
            ApexBasedSharingCls.DeleteMBSharingRecords(EffortIDs, MgrsToLoseAccess);
        }        
    }
    
    if (MainBranchSharesToInsert.size()>0) {
    
        system.debug('Main Branch Shares ------------ ' + MainBranchSharesToInsert);
        
        ApexBasedSharingCls.InsertMBSharingRecords(MainBranchSharesToInsert);
        
    
    }

    if (BranchSharesToInsert.size()>0) {
    
        system.debug('Branch Shares to insert ------------ ' + BranchSharesToInsert);
    
        ApexBasedSharingCls.InsertBranchSharingRecords(BranchSharesToInsert);
        
    }        
    
}    
    
}