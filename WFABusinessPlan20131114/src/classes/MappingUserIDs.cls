Public Class MappingUserIDs {

    Public static Map<ID, ID> MapMgrToUserUsingBranch(Set<ID> BranchIDs) {
        
        
        Map<ID, Account> BranchMap = new Map<ID, Account>([SELECT ID, Manager_Branch__c,Sub_Complex_Manager_ID__c,
        Mkt_Cmplx_Manager_ID__c,Main_Branch_Manager_ID__c, Manager_Branch_Email__c,Manager_Sub_Supl_Complex_Email__c, 
        Manager_Market_Complex_Email__c, Manager_Main_Branch_Email__c, SDBK_ID__c, 
        Senior_Director_of_Brokerage_Email__c FROM Account WHERE ID IN: BranchIDs]);
        
        Set<Account> BranchSet = new Set<Account>();
        BranchSet.addAll(BranchMap.values());
        
        Set<ID> ManagerIDs = MappingUserIDs.MapManagersIDsToEmails(BranchSet).Keyset();
        Set<String> Emails = new Set<String>();
        
        Emails.addall(MappingUserIDs.MapManagersIDsToEmails(BranchSet).Values());
                
        system.debug('Branch\'s managers ids ---------- ' + ManagerIDs);
        
        Map<ID, User> UserMap = MappingUserIDs.GetMgrUserMapByEmails(Emails);
       
        
        return MappingUserIDs.MapContactIDToUserID(ManagerIDs, UserMap.values());
        
    }
    
    Public static Map<Id, Id> MapContactIDToUserID(Set<ID> ContactIDs, List<User> Users) {
    
        //all non terminated Branch Managers or Market Managers with a branch
        Map<ID, Contact> ContactMap = new Map<ID, Contact>([SELECT ID, Email FROM Contact WHERE ID IN: ContactIDs]); 
        
        Map<ID, ID> ContactIDToUserIDMap = new Map<ID, ID>();
        
        //map out each Manager to his or her user id
        ContactIDToUserIDMap = UtilityMethods.GetContactIDToUserIDMap(ContactMap.values(), Users);
        
        return ContactIDToUserIDMap;
        
    }
    
    Public static Map<ID, ID> MapPrevMgrToUserUsingBranch(Set<Account> OldBranches) {
        
        
        Set<ID> ManagerIDs = MappingUserIDs.MapManagersIDsToEmails(OldBranches).Keyset();
        Set<String> Emails = new Set<String>();
        Emails.addall(MappingUserIDs.MapManagersIDsToEmails(OldBranches).Values());
        
        system.debug('Old Branch\'s managers ids ---------- ' + ManagerIDs);
        
        Map<ID, User> UserMap = MappingUserIDs.GetMgrUserMapByEmails(Emails);
        
        
        return MappingUserIDs.MapContactIDToUserID(ManagerIDs, UserMap.values());
        
    }
    
    public static Map<ID, User> GetMgrUserMapByEmails(Set<String> Emails) {
        
        Profile[] BrMgrProf = [SELECT ID FROM Profile WHERE Name = 'PCG Branch Manager' OR Name = 'Market Manager' 
                                OR Name = 'WBS RBM & SDBK' OR Name = 'WBS RBM & SDBK Chatter Only']; //PCG Branch Manager, Market Manager, WBS RBM & SDBK (chatter only) Profles
        
        if (Emails.size() > 0) {
            Map<ID, User> UserMap = new Map<ID, User>([SELECT ID, ProfileID, Email FROM User WHERE IsActive = True AND Email IN: Emails AND ProfileID IN: BrMgrProf]); //PCG Branch Manager, Market Manager, WBS RBM & SDBK (chatter only) Profles
        
            return UserMap;
        } 
        
        Map<ID, User> UserMap = new Map<ID, User>([SELECT ID, ProfileID, Email FROM User WHERE IsActive = True AND ProfileID IN: BrMgrProf]); //PCG Branch Manager, Market Manager, WBS RBM & SDBK (chatter only) Profles
        
        return UserMap;
        
    }
        
    public static Map<ID, String> MapManagersIDsToEmails(Set<Account> branches) {
        
        Map<ID,String> ManagerIDsToEmails = new Map<ID,String>();
        
        //store the ids of the trainee's managers
        for (Account a : Branches) {
            if (a.Manager_Branch__c != Null && a.Manager_Branch_Email__c != Null) {
                ManagerIDsToEmails.Put(a.Manager_Branch__c, a.Manager_Branch_Email__c);
            } 
            if (a.Sub_Complex_Manager_ID__c != Null && a.Manager_Sub_Supl_Complex_Email__c != Null) {
                ManagerIDsToEmails.Put(a.Sub_Complex_Manager_ID__c,a.Manager_Sub_Supl_Complex_Email__c);
            } 
            if (a.Mkt_Cmplx_Manager_ID__c != Null && a.Manager_Market_Complex_Email__c != Null) {
                ManagerIDsToEmails.Put(a.Mkt_Cmplx_Manager_ID__c,a.Manager_Market_Complex_Email__c);
            }
            if (a.Main_Branch_Manager_ID__c != Null && a.Manager_Main_Branch_Email__c != Null) {
                ManagerIDsToEmails.Put(a.Main_Branch_Manager_ID__c,a.Manager_Main_Branch_Email__c);
            }
            if (a.SDBK_ID__c != Null && a.Senior_Director_of_Brokerage_Email__c != Null) {
                ManagerIDsToEmails.Put(a.SDBK_ID__c, a.Senior_Director_of_Brokerage_Email__c);
            }            
        }
        
        return ManagerIDsToEmails;
    }

}