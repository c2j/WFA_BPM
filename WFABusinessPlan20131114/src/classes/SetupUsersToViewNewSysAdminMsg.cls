public class SetupUsersToViewNewSysAdminMsg {

    public static boolean ResetViewedSystemAdminMsgField() {
        
        User[] ActiveUsers = [SELECT Viewed_System_Admin_Message__c FROM User WHERE IsActive = True AND 
                              MobilePhone = '+1 999-999-9999' AND AU__c != '' AND EmployeeNumber != '' AND
                              Viewed_System_Admin_Message__c = True];
        
        For (User u : ActiveUsers) {
        
            u.Viewed_System_Admin_Message__c = False;
            
        }
        
        try {
            update ActiveUsers;
        } catch (exception e) {
        
            UtilityMethods.email('Error Setting up Users to View new Sys Admin Message', e.getMessage(), null);
            return False;
        }
        
        return True;
    }
    
}