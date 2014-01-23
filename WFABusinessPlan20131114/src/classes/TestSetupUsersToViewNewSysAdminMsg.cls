@isTest
public class TestSetupUsersToViewNewSysAdminMsg {

    static testMethod void TestSetupUsersToViewSysAdminMsg() {
    
        User[] ActiveUsers = [SELECT Viewed_System_Admin_Message__c FROM User WHERE IsActive = True AND 
                              MobilePhone = '+1 999-999-9999' AND AU__c != '' AND EmployeeNumber != '' AND
                              Viewed_System_Admin_Message__c = False];
        
        For (User u : ActiveUsers) {
        
            u.Viewed_System_Admin_Message__c = True;
            
        }
        
        update ActiveUsers;
    
        test.startTest();
        
        System_Administrator_Controls__c SAC = New System_Administrator_Controls__c();
        SAC.Name = 'New SA Message';
        SAC.RecordTypeID = '01250000000UMKM'; //Production Rec Type Id = 01250000000UMKM, Sandbox Rec Type Id = 012R0000000D9Cs
        SAC.System_Admin_Message__c = 'Test Message';
        SAC.Make_Message_Viewable__c = 'Yes';
        
        insert SAC;
        
        User[] ResetUsers = [SELECT Viewed_System_Admin_Message__c FROM User WHERE IsActive = True AND 
                              MobilePhone = '+1 999-999-9999' AND AU__c != '' AND EmployeeNumber != '' AND
                              Viewed_System_Admin_Message__c = True];
        
        system.assertequals(Resetusers.size(), 0);
        
        test.stopTest();
     }   
}