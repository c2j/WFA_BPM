global class SetupUsersToViewNewSysAdminMsgButton {

    webservice static string ResetViewedMsgFieldOnClick(ID SACID) {
    
        Boolean UsersReset = SetupUsersToViewNewSysAdminMsg.ResetViewedSystemAdminMsgField();
        System_Administrator_Controls__c SAC = [SELECT Users_Not_Setup_to_View_Message__c FROM System_Administrator_Controls__c
        WHERE ID =: SACID];
        
        if (UsersReset) {
            
            SAC.Users_Not_Setup_To_View_Message__c = False;
            update SAC;
                
            return 'Users will now view the new System Admin Message';
        
        } else {
            
            return 'ERROR OCCURRED while setting up users to view new System Admin Message. Contact your developer';
            
        }        
      
  }
  
}