trigger MainBranchManagerShare on Main_Branch__c (after insert, after update) {
    
List<Main_Branch__Share> MainBranchSharesToInsert = new List<Main_Branch__Share>();
List<Main_Branch__Share> MainBranchSharesToDelete = new List<Main_Branch__Share>();
List<AccountShare> BranchSharesToInsert = new List<AccountShare>();
List<AccountShare> BranchSharesToDelete = new List<AccountShare>();

Map<Id, List<ID>> MgrsToGetMBAccess = new Map<ID,List<ID>>();
Map<Id, List<ID>> MgrsToGetBranchAccess = new Map<ID,List<ID>>();
List<ID> MgrsToLoseAccess = new List<ID>();

Set<String> Emails = new Set<String>();
Set<ID> MgrIDs = new Set<ID>();

Map<Main_Branch__c, ID> MainBranchesMap= new Map<Main_Branch__c, ID>();
Map<Main_Branch__c, ID> OldMainBranchesMap = new Map<Main_Branch__c, ID>();


if (!Validator_cls.hasAlreadyDone()) {//prevents workflows from firing trigger twice

//loop through main branches and store all the current and old manager ids to use in contacts query
for (Main_Branch__c mb: Trigger.new) {
    
    if (mb.Main_Branch_Close_Date__c == null) {
        
        MainBranchesMap.put(MB, MB.ID);
        
        if (MB.Manager_Main_Branch__c != Null) {
            MgrIds.add(MB.Manager_Main_Branch__c);
            
        }

        if (mb.MB_Manager_Email__c != Null) {
            Emails.add(mb.MB_Manager_Email__c);
            
        }
                    
        if (trigger.isUpdate) {
            Main_Branch__c oldMB = trigger.oldmap.get(mb.id);
            
            if (mb.Manager_Main_Branch__c != oldMB.Manager_Main_Branch__c) {
                
                OldMainBranchesMap.put(oldMB, oldMB.id);
                
                if (oldMB.Manager_Main_Branch__c != Null) {
                    MgrIds.add(oldMB.Manager_Main_Branch__c);                   
                }    

                if (oldMB.MB_Manager_Email__c != Null) {
                    Emails.add(oldMB.MB_Manager_Email__c);
                }
                

            }
        }
    }
}
    
if ((Trigger.isInsert || OldMainBranchesMap.values().size() > 0) && MainBranchesMap.values().size() > 0 && Emails.size() > 0) {

    Map<ID, ID> MgrsToUserIDMap = new Map<ID, ID>(); //map of manager's contact record id to his user record id
    
    //map out each current manager associated with the list of active branches to the manager's user record ids
    MgrsToUserIDMap = MappingUserIDs.MapContactIDToUserID(MgrIDs, MappingUserIds.GetMgrUserMapByEmails(Emails).Values());
    
    List<ID> BranchIDs = new List<ID>();
    List<ID> OldMainBranchIDs = new List<ID>();
    
    for (Account b : [SELECT Main_Branch__c, Main_Branch_Manager_ID__c,
    Manager_Branch__c, Sub_Complex_Manager_ID__c FROM Account WHERE Active__c = True AND Main_Branch__c IN : MainBranchesMap.values()
    ORDER BY Main_Branch__c DESC]) {
        
        BranchIds.add(b.id);
        
        List<ID> NewMgrUserIDs = new List<ID>();
        
        If (b.Main_Branch_Manager_ID__c != Null && MgrsToUserIDMap.get(b.Main_Branch_Manager_ID__c) != Null) {
            
            NewMgrUserIDs.add(MgrsToUserIDMap.get(b.Main_Branch_Manager_ID__c));
            
        }
        
        MgrsToGetBranchAccess.put(b.id, NewMgrUserIDs);
        
        MgrsToGetMBAccess.put(b.Main_Branch__c, NewMgrUserIDs);
        
        if (trigger.oldmap.get(b.Main_Branch__c) != Null) {
        
            Main_Branch__c oldMB = Trigger.oldMap.get(b.Main_Branch__c);
            
            if (b.Main_Branch_Manager_ID__c != oldMB.Manager_Main_Branch__c &&
            MgrsToUserIDMap.get(oldMB.Manager_Main_Branch__c) != Null) {
            
                MgrsToLoseAccess.add(MgrsToUserIDMap.get(oldMB.Manager_Main_Branch__c)); 
                
            }
        }
        
    }
    
    system.debug('Main branch managers to get MB access ----------- ' + MgrsToGetMBAccess);
    system.debug('Main branch managers to get Branch access ----------- ' + MgrsToGetBranchAccess);
    system.debug('Main branch managers to lose access ----------- ' + MgrsToLoseAccess);
    
    MainBranchSharesToInsert = ApexBasedSharingCls.CreateMainBranchSharing(MgrsToGetMBAccess);
    
    BranchSharesToInsert = ApexBasedSharingCls.CreateBranchSharing(MgrsToGetBranchAccess);
    
    if (MgrsToLoseAccess.size() > 0) {
        
        if (BranchIDs.size() > 0) {
            
            ApexBasedSharingCls.MakeEffortsPrivateOnBranchSharingRecords(BranchIDs, MgrsToLoseAccess);
            
            ApexBasedSharingCls.DeleteBranchSharingRecords(BranchIDs, MgrsToLoseAccess);
        }    
        if (OldMainBranchesMap.Values().size() > 0) {       
            ApexBasedSharingCls.DeleteMBSharingRecords(OldMainBranchesMap.Values(), MgrsToLoseAccess);
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
//Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again   
}
}