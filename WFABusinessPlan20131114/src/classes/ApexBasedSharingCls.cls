Global Class ApexBasedSharingCls {

webservice static void GetManagerIDsOnBranch(ID BranchID) {
    
    Set<Account> CrntBranch = new Set<Account>();
    CrntBranch.addAll([SELECT ID, Name, Main_Branch__c, Manager_Branch__c, Manager_Branch_Email__c,
       Sub_Complex_Manager_ID__c, Manager_Sub_Supl_Complex_Email__c,
       Mkt_Cmplx_Manager_ID__c, Manager_Market_Complex_Email__c,
       Main_Branch_Manager_ID__c, Manager_Main_Branch_Email__c, SDBK_ID__c,
       Senior_Director_of_Brokerage_Email__c FROM Account WHERE ID =: BranchID]);
     
    Map<ID, ID> MgrsToUserIDMap = new Map<ID, ID>(); //map of manager's contact record id to his user record id

    Set<String> Emails = new Set<String>();
    Set<ID> MgrIds = new Set<ID>();
    
    //store all managers emails to use to query their user records. if manager doesn't have an email, there will be no
    //way to match him to a user record
    Emails.addall(MappingUserIDs.MapManagersIDsToEmails(CrntBranch).values());

    if (Emails.size() > 0) {
        //store all managers ids to use to query their user records
        MgrIds.addall(MappingUserIDs.MapManagersIDsToEmails(CrntBranch).keyset());    
        
        //map out each current manager associated with the list of active branches to the manager's user record ids
        MgrsToUserIDMap = MappingUserIDs.MapContactIDToUserID(MgrIDs, MappingUserIds.GetMgrUserMapByEmails(Emails).Values());
        
        system.debug('Manager contact id to user id map ------------ ' + MgrsTouserIDMap);
        
        //call apex class to do all the sharing record evaluations
        ApexBasedSharingCls.CreateBranchAccessAndNoAccessList(CrntBranch, null, MgrsToUserIDMap);
    }
}


webservice static void GetManagerIDsOnMainBranch(ID MainBranchID) {

    Set<Account> BranchesOfMB = new Set<Account>();
    
    Main_Branch__c CrntMB = [SELECT ID, MB_Manager_Email__c,Manager_Main_Branch__c FROM Main_Branch__c WHERE ID =: MainBranchID];
    
    BranchesOfMB.addAll([SELECT ID, Name, Main_Branch__c, Manager_Branch__c, Manager_Branch_Email__c,
       Sub_Complex_Manager_ID__c, Manager_Sub_Supl_Complex_Email__c,
       Mkt_Cmplx_Manager_ID__c, Manager_Market_Complex_Email__c,
       Main_Branch_Manager_ID__c, Manager_Main_Branch_Email__c, SDBK_ID__c,
       Senior_Director_of_Brokerage_Email__c FROM Account WHERE Main_Branch__c =: MainBranchID]);

    Map<ID, ID> MgrsToUserIDMap = new Map<ID, ID>(); //map of manager's contact record id to his user record id

    Set<String> Emails = new Set<String>();
    Set<ID> MgrIds = new Set<ID>();
    
    //store all managers emails to use to query their user records. if manager doesn't have an email, there will be no
    //way to match him to a user record
    Emails.addall(MappingUserIDs.MapManagersIDsToEmails(BranchesOfMB).values());

    if (Emails.size() > 0) {
        //store all managers ids to use to query their user records
        MgrIds.addall(MappingUserIDs.MapManagersIDsToEmails(BranchesOfMB).keyset());    
        
        //map out each current manager associated with the list of active branches to the manager's user record ids
        MgrsToUserIDMap = MappingUserIDs.MapContactIDToUserID(MgrIDs, MappingUserIds.GetMgrUserMapByEmails(Emails).Values());
        
        system.debug('Manager contact id to user id map ------------ ' + MgrsTouserIDMap);
        
        //call apex class to do all the sharing record evaluations
        ApexBasedSharingCls.CreateBranchAccessAndNoAccessList(BranchesOfMB, null, MgrsToUserIDMap);
    }   
   
       
}


Public static void CreateBranchAccessAndNoAccessList(Set<Account> Branches, Map<ID, 
Account> OldBranches, Map<id, id> ContactIdToUserIDMap) {

List<AccountShare> BranchSharesToInsert = new List<AccountShare>();
List<AccountShare> BranchSharesToDelete = new List<AccountShare>();
List<Main_Branch__Share> MainBranchSharesToInsert = new List<Main_Branch__Share>();
List<Main_Branch__Share> MainBranchSharesToDelete = new List<Main_Branch__Share>();

Map<ID, List<ID>> MgrsToGetBranchAccess = new Map<ID, List<ID>>();
Map<ID, List<ID>> MgrsToGetMBAccess = new Map<ID, List<ID>>();

List<ID> CrntMgrsToLoseAccess = new List<ID>();
List<ID> OldMgrsToLoseAccess = new List<ID>();    

List<ID> MainBranchIDs = new List<ID>();
List<ID> OldMainBranchIDs = new List<ID>();
List<ID> BranchIDs = new List<ID>();

for (Account b : Branches) {
    
    
    BranchIDs.add(b.id);
    
    List<ID> CrntMgrUserIDs = new List<ID>();

    //Check all managers related to current branch. If the manager's contact id returns an active user id
    //the manager's user id is stored to grant sharing access
    
    if (ContactIDToUserIDMap.get(b.Manager_Branch__c) != Null) { //crnt branch mgr

        CrntMgrUserIDs.add(ContactIDToUserIDMap.get(b.Manager_Branch__c));
        CrntMgrsToLoseAccess.add(b.Manager_Branch__c);
    }
    
    if (ContactIDToUserIDMap.get(b.Sub_Complex_Manager_ID__c) != Null) { //crnt sub complex mgr

        CrntMgrUserIDs.add(ContactIDToUserIDMap.get(b.Sub_Complex_Manager_ID__c));
        CrntMgrsToLoseAccess.add(b.Sub_Complex_Manager_ID__c);        
    }
            
    if (ContactIDToUserIDMap.get(b.Mkt_Cmplx_Manager_ID__c) != Null) { //crnt mkt complex mgr

        CrntMgrUserIDs.add(ContactIDToUserIDMap.get(b.Mkt_Cmplx_Manager_ID__c));
        CrntMgrsToLoseAccess.add(b.Mkt_Cmplx_Manager_ID__c);
    }
            
    if (ContactIDToUserIDMap.get(b.Main_Branch_Manager_ID__c ) != Null) { //crnt main branch mgr

        CrntMgrUserIDs.add(ContactIDToUserIDMap.get(b.Main_Branch_Manager_ID__c ));
        
    }
    
    //Map current branch id to a list of all related managers' user ids
    MgrsToGetBranchAccess.put(b.id, CrntMgrUserIDs);
    
    //if current branch has a main branch, map that main branch id to all the related managers' user ids
    
    if (b.Main_Branch__c != Null) {
        
        system.debug('Branch name and main branch id ---------- ' + b.Name + ' / ' + b.Main_Branch__c);
        
        MgrsToGetMBAccess.put(b.Main_Branch__c, CrntMgrUserIDs);
        
        MainBranchIds.add(b.Main_Branch__c);
        
    }

    //----------------Managers to Lose Access---------------------
    
    //check to see the managers have changed on the current branch. if they have,
    //store the old managers' ids to be removed from the sharing list on the current branch
    if (OldBranches != Null && OldBranches.keyset().size() > 0 && OldBranches.get(b.id) != Null) {
    
        Account oldBranch = oldBranches.get(b.id);
        
        //if the branch's main branch has changed, store that main branch as a record to remove sharing access for
        //the current set of managers should no longer have access to the old main branch
        
        if (b.Main_Branch__c != oldBranch.Main_Branch__c && oldbranch.Main_Branch__c != null) {
        
            OldMainBranchIds.add(oldbranch.Main_Branch__c);
        
        }
        
        //branch manager has changed
        if (oldBranch.Manager_Branch__c != b.Manager_Branch__c && oldBranch.Manager_Branch__c != Null &&
        ContactIDToUserIDMap.get(oldBranch.Manager_Branch__c) != Null) {
    
            OldMgrsToLoseAccess.add(ContactIDToUserIDMap.get(oldBranch.Manager_Branch__c));
    
        }
        
        //sub complex manager has changed
        if (oldBranch.Sub_Complex_Manager_ID__c != b.Sub_Complex_Manager_ID__c && oldBranch.Sub_Complex_Manager_ID__c != Null &&
        ContactIDToUserIDMap.get(oldBranch.Sub_Complex_Manager_ID__c) != Null) {
    
            OldMgrsToLoseAccess.add(ContactIDToUserIDMap.get(oldBranch.Sub_Complex_Manager_ID__c));
        }
           
        //mkt complex manager has changed   
        if (oldBranch.Mkt_Cmplx_Manager_ID__c != b.Mkt_Cmplx_Manager_ID__c && oldBranch.Mkt_Cmplx_Manager_ID__c != Null &&
        ContactIDToUserIDMap.get(oldBranch.Mkt_Cmplx_Manager_ID__c) != Null) {                
    
            OldMgrsToLoseAccess.add(ContactIDToUserIDMap.get(oldBranch.Mkt_Cmplx_Manager_ID__c));
        }
        
        //main branch manager has changed
        if (oldBranch.Main_Branch_Manager_ID__c != b.Main_Branch_Manager_ID__c && oldBranch.Main_Branch_Manager_ID__c != Null &&
        ContactIDToUserIDMap.get(oldBranch.Main_Branch_Manager_ID__c) != Null) {                
    
            OldMgrsToLoseAccess.add(ContactIDToUserIDMap.get(oldBranch.Main_Branch_Manager_ID__c));
        }
   }
   
}

system.debug('Managers to get branch access ------------ ' + MgrsToGetBranchAccess);
system.debug('Managers to get main branch access ------------ ' + MgrsToGetMBAccess);
system.debug('Managers to lose branch and mb access -------------- ' + CrntMgrsToLoseAccess);
system.debug('Managers to lose branch and mb access -------------- ' + OldMgrsToLoseAccess);

BranchSharesToInsert = ApexBasedSharingCls.CreateBranchSharing(MgrsToGetBranchAccess);

MainBranchSharesToInsert = ApexBasedSharingCls.CreateMainBranchSharing(MgrsToGetMBAccess);


//remove branch and main branch access for old managers
if (OldMgrsToLoseAccess.size() > 0) {

    //System.debug('Branch Sharing to Delete for Sub Complex Mgrs ----------- ' + BranchSharesToDelete);
    
    Map<Id, Opportunity> BranchEfforts = new Map<ID, Opportunity>([SELECT ID FROM Opportunity WHERE AccountID IN: BranchIDs]);
    List<ID> EffortIDs = new List<ID>(BranchEfforts.keyset());
    
    if (EffortIds.size() > 0) {
    
        ApexBasedSharingCls.MakeEffortsPrivateOnBranchSharingRecords(BranchIDs, OldMgrsToLoseAccess);
        
        //ApexBasedSharingCls.DeleteEffortSharingRecords(EffortIDs, OldMgrsToLoseAccess);
        
    }
        
    if (BranchIDs.size() > 0) {
        ApexBasedSharingCls.DeleteBranchSharingRecords(BranchIDs, OldMgrsToLoseAccess);
    } 
    
    if (MainBranchIDs.size() > 0) {
        ApexBasedSharingCls.DeleteMBSharingRecords(MainBranchIDs, OldMgrsToLoseAccess);
    }
    

    
}

//remove current managers' access to old main branch
if (OldMainBranchIDs.size() > 0) {
    ApexBasedSharingCls.DeleteMBSharingRecords(OldMainBranchIDs, CrntMgrsToLoseAccess);
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

Public static List<AccountShare> CreateBranchSharing(Map<ID,List<ID>> BranchIDToUserIDs) {

    List<AccountShare> BranchSharesToInsert = new List<AccountShare>();
    Map<ID, Account> BranchOwnerMap = new Map<ID, Account>([SELECT OwnerID FROM Account WHERE ID IN: BranchIDToUserIDs.keyset()]);
    Map<ID, User> UserMap = MappingUserIDs.GetMgrUserMapByEmails(new Set<string>());
    
    
    for (ID bID : BranchIDToUserIDs.keyset()) { //loop through branch ids
        
        system.debug('Managers getting access to branch --------- ' + bID + ' / ' + BranchIDToUserIDs.get(bID));
        
        for (ID mgrID: BranchIDToUserIDs.get(bID)) { //loop thru every manager assocated with the current branch
            
            if (BranchOwnerMap.get(bID).OwnerID != mgrID) { //do not need to create sharing records for managers who are the branch owners
                AccountShare BranchMgrShare = new AccountShare(); 
                    
                //the account share record's accountID field equals the current branch id
                BranchMgrShare.AccountID = bID; //gets the branch id that the manager is associated with
                
                //system.debug('Manager User ID --------- ' + mgrID);
                
                //getting the user id of the manager based on his or her contract id
                BranchMgrShare.UserOrGroupID = mgrId;
                
                //grant managers read only access
                BranchMgrShare.AccountAccessLevel = 'read';
                BranchMgrShare.ContactAccessLevel = 'read';
                
                //market managers or RBM & SDBK (non chatter) (production id 00e50000000z6nI; sandbox id 00eP0000000QOS1) get edit access to efforts
                if (UserMap.get(mgrID).ProfileID == '00e50000000vLe3' || UserMap.get(mgrID).ProfileID == '00e50000000z6nI') {
                    BranchMgrShare.OpportunityAccessLevel = 'Edit';
                } else if (UserMap.get(mgrID).ProfileID == '00e50000000z2sU' || UserMap.get(mgrID).ProfileID == '00e50000000z482') { //pcg branch managers or RBM & SDBK Chatter Only dont have access to efforts
                    BranchMgrShare.OpportunityAccessLevel = 'None';
                }
                
                BranchMgrShare.CaseAccessLevel = 'None';

                //store share record in a list to be inserted
                BranchSharesToInsert.add(BranchMgrShare);
            }
        }
    }
    
    return BranchSharesToInsert;
    
    
}

Public static List<Main_Branch__Share> CreateMainBranchSharing(Map<ID,List<ID>> MainBranchIDToUserIDs) {

    List<Main_Branch__Share> MainBranchSharesToInsert = new List<Main_Branch__Share>();
    Map<ID, Main_Branch__c> MBranchOwnerMap = new Map<ID, Main_Branch__c>([SELECT OwnerID FROM Main_Branch__c WHERE ID IN: MainBranchIDToUserIDs.keyset()]);
        
    for (ID mbID : MainBranchIDToUserIDs.keyset()) { //loop through branch ids
    
        system.debug('Managers getting access to main branch --------- ' + mbID + ' / ' +  MainBranchIDToUserIDs.get(mbID));
        
        for (ID mgrID: MainBranchIDToUserIDs.get(mbID)) { //loop thru every manager assocated with the current branch
            
            if (MBranchOwnerMap.get(mbID) != Null && MBranchOwnerMap.get(mbID).OwnerID != mgrID) { //do not need to create sharing records for managers who are the main branch owners
                Main_Branch__Share MBMgrShare = new Main_Branch__Share(); 
                    
                MBMgrShare.ParentID = mbID;
            
                MBMgrShare.UserOrGroupID = mgrID;
            
                //grant managers read only access
                MBMgrShare.AccessLevel = 'read';
                
                MBMgrShare.RowCause = Schema.Main_Branch__Share.RowCause.Main_Branch_Manager_Access__c;
                
                //store share record in a list to be inserted
                MainBranchSharesToInsert.add(MBMgrShare); 
            }
        }
    }
    
    return MainBranchSharesToInsert;
    
    
}

Public static List<OpportunityShare> CreateEffortSharing(Map<ID,List<ID>> EffortIDToUserIDs) {

    List<OpportunityShare> EffortSharesToInsert = new List<OpportunityShare>();
    Map<ID, User> UserMap = MappingUserIDs.GetMgrUserMapByEmails(new Set<string>());
    Map<ID, Opportunity> EffortOwnerMap = new Map<ID, Opportunity>([SELECT OwnerID FROM Opportunity WHERE ID IN: EffortIDToUserIDs.keyset()]);

    
    for (ID eID : EffortIDToUserIDs.keyset()) { //loop through effort ids
        
        system.debug('Managers getting access to effort --------- ' + eID + ' / ' +  EffortIDToUserIDs.get(eID));
        
        for (ID mgrID: EffortIDToUserIDs.get(eID)) { //loop thru every manager assocated with the current branch
                
            //if there isn't already an effort sharing record from the branch sharing code
            //create a new sharing record for the market manager or WBS RMB & SDBK profiles (production id 00e50000000z6nI; sandbox id 00eP0000000QOS1), only if the market manager doesn't already own the effort.
            if ((UserMap.get(mgrID).ProfileID == '00e50000000vLe3' || UserMap.get(mgrID).ProfileID == '00e50000000z6nI') && EffortOwnerMap.get(eID).OwnerID != mgrID) {
                OpportunityShare BranchMgrShare = new OpportunityShare(); 
                    
                //the opportunity share record's accountID field equals the current branch id
                BranchMgrShare.OpportunityID = eID; //gets the effort id that the manager is associated with
                
                //system.debug('Manager User ID --------- ' + mgrID);
                
                //getting the user id of the manager based on his or her contract id
                BranchMgrShare.UserOrGroupID = mgrId;
                                
                BranchMgrShare.OpportunityAccessLevel = 'Edit';

                //store share record in a list to be inserted
                EffortSharesToInsert.add(BranchMgrShare);
            }

        }
    }
    
    return EffortSharesToInsert;
    
    
}



public static void DeleteBranchSharingRecords(List<ID> BranchIDs, List<ID> UserIDs) {

    //query a list of sharing records on the branch that need to be deleted
    List<AccountShare> BranchSharesToDelete = [SELECT ID, AccountID, UserOrGroupID FROM AccountShare WHERE AccountID IN: BranchIDs AND
    UserOrGroupID IN : UserIDs AND AccountAccessLevel = 'Read'];
      
    system.debug('Branch Sharing to Delete for Managers ----------- ' + BranchSharesToDelete);
    
    if (BranchSharesToDelete.size() > 0) {
        try {
            system.debug('----------Deleting Branch Sharing Records of Previous Mgrs-----------');
            delete BranchSharesToDelete;
        } catch (Exception e) {
            system.debug('----------Deletion of Branch Sharing Records of Previous Mgrs failed-------------');
            
            throw new SFException('Could not remove sharing rights on Branches and Main Branches for previous Managers because: ' + e.getMessage());
    
        }
    }
}

public static void DeleteMBSharingRecords(List<ID> MainBranchIDs, List<ID> UserIDs) {
    
    //query a list of sharing records on the branch that need to be deleted
    List<Main_Branch__Share> MainBranchSharesToDelete = [SELECT ID, ParentID, UserOrGroupID FROM Main_Branch__Share WHERE ParentID IN: MainBranchIDs AND
    UserOrGroupID IN : UserIDs AND AccessLevel = 'Read'];

    system.debug('Main Branch Sharing to Delete for Managers ----------- ' + MainBranchSharesToDelete);
    
    if (MainBranchSharesToDelete.size() > 0) {
        try {
            system.debug('----------Deleting Main Branch Sharing Records of Previous Mgrs-----------');
            delete MainBranchSharesToDelete;
        } catch (Exception e) {
            system.debug('----------Deletion of Main Branch Sharing Records of Previous Mgrs failed-------------');
            
            throw new SFException('Could not remove sharing rights on Branches and Main Branches for previous Managers because: ' + e.getMessage());
    
        }
    }
}


public static void DeleteEffortSharingRecords(List<ID> EffortIDs, List<ID> UserIDs) {
    
    //query a list of sharing records on the Effort that need to be deleted
    List<OpportunityShare> EffortSharesToDelete = [SELECT ID, UserOrGroupID, OpportunityID, RowCause, OpportunityAccessLevel FROM OpportunityShare WHERE OpportunityID IN: EffortIDs AND
    UserOrGroupID IN : UserIDs AND RowCause = 'Manual']; //AND RowCause = 'Manual' AND OpportunityAccessLevel != 'All'
    
    system.debug('Effort Sharing to Delete for Managers ----------- ' + EffortSharesToDelete);
    
    if (EffortSharesToDelete.size() > 0) {
        try {
            system.debug('----------Deleting Effort Sharing Records of Mgrs-----------');
            delete EffortSharesToDelete;
        } catch (Exception e) {
            system.debug('----------Deletion of Effort Sharing Records of Previous Branch Mgrs failed-------------');
            
            throw new SFException('Could not remove sharing rights on Efforts for previous Branch Managers because: ' + e.getMessage());
    
        }
    }
}

public static void MakeEffortsPrivateOnBranchSharingRecords(List<ID> BranchIDs, List<ID> UserIDs) {

    //query a list of sharing records on the branch that need to be deleted
    List<AccountShare> BranchSharesToUpdate = [SELECT ID, AccountID, UserOrGroupID FROM AccountShare WHERE AccountID IN: BranchIDs AND
    UserOrGroupID IN : UserIDs AND AccountAccessLevel = 'Read' AND OpportunityAccessLevel != 'Private'];
      
    system.debug('Branch Share Records on which to Privatize Effort Access ----------- ' + BranchSharesToUpdate);
    
    for (AccountShare AShr : [SELECT ID, AccountID, UserOrGroupID FROM AccountShare WHERE AccountID IN: BranchIDs AND
    UserOrGroupID IN : UserIDs AND AccountAccessLevel = 'Read' AND OpportunityAccessLevel != 'Private']) {
    
        AShr.OpportunityAccessLevel = 'Private';
        
    }
        
    try {
        system.debug('----------Privatizing Effort Access on Branch Share Records-----------');
        update BranchSharesToUpdate;
    } catch (Exception e) {
        system.debug('----------Privatizing Effort Access on Branch Share Records failed-------------');
        
        throw new SFException('Could not Privatize Effort Access on Branch Share Records because: ' + e.getMessage());

    }

}


public static void InsertBranchSharingRecords(List<AccountShare> BranchSharesToInsert) {
    Database.SaveResult[] BranchShareInsertResult = Database.insert(BranchSharesToInsert,false);
    
    Integer i=0;
        
    // Process the save results 

    for(Database.SaveResult sr : BranchShareInsertResult){
        if(!sr.isSuccess()){
            // Get the first save result error 

            Database.Error err = sr.getErrors()[0];
            
            // Check if the error is related to a trivial access level 

            // Access levels equal or more permissive than the object's default  

            // access level are not allowed.  

            // These sharing records are not required and thus an insert exception is  

            // acceptable.  
            system.debug('Sharing Records Insert error ----------- ' + err);
            
            
            if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                           &&  err.getMessage().contains('AccessLevel'))){
                // Throw an error when the error is not related to trivial access level. 

                Throw new SFException(
                   'Unable to grant sharing access for manager(s) on branch due to following exception: '
                   + err.getMessage());
            }
        }
        i++;
    }   
       
}

public static void InsertMBSharingRecords(List<Main_Branch__Share> MainBranchSharesToInsert) {

    Database.SaveResult[] MainBranchShareInsertResult = Database.insert(MainBranchSharesToInsert,false);
    
    Integer i=0;
    
    // Process the save results 
    
    for(Database.SaveResult sr : MainBranchShareInsertResult){
    if(!sr.isSuccess()){
        // Get the first save result error 
    
        Database.Error err = sr.getErrors()[0];
        
        // Check if the error is related to a trivial access level 
    
        // Access levels equal or more permissive than the object's default  
    
        // access level are not allowed.  
    
        // These sharing records are not required and thus an insert exception is  
    
        // acceptable.  
        system.debug('Sharing Records Insert error ----------- ' + err);
        
        
        if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                       &&  err.getMessage().contains('AccessLevel'))){
            // Throw an error when the error is not related to trivial access level. 
    
            trigger.newMap.get(MainBranchSharesToInsert[i].ParentId).
              addError(
               'Unable to grant sharing access for manager(s) on main branch due to following exception: '
               + err.getMessage());
        }
    }
    i++;
    }   
}

public static void InsertEffortSharingRecords(List<OpportunityShare> EffortSharesToInsert) {
    
    system.debug('Effort shares to insert ---------- ' + EffortSharesToInsert);
    
    Database.SaveResult[] EffortShareInsertResult = Database.insert(EffortSharesToInsert,false);
    
    Integer i=0;
        
    // Process the save results 

    for(Database.SaveResult sr : EffortShareInsertResult ){
        if(!sr.isSuccess()){
            // Get the first save result error 

            Database.Error err = sr.getErrors()[0];
            
            // Check if the error is related to a trivial access level 

            // Access levels equal or more permissive than the object's default  

            // access level are not allowed.  

            // These sharing records are not required and thus an insert exception is  

            // acceptable.  
            system.debug('Sharing Records Insert error ----------- ' + err);
            
            
            if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                           &&  err.getMessage().contains('AccessLevel'))){
                // Throw an error when the error is not related to trivial access level. 
//Unable to grant sharing access for Managers on Effort due to following exception: 
                Throw new SFException(
                   ''
                   + err.getMessage());
            }
        }
        i++;
    }   
       
}
}