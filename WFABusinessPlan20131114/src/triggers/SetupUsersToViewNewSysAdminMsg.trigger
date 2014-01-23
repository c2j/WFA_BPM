trigger SetupUsersToViewNewSysAdminMsg on System_Administrator_Controls__c (before insert) {

//when a new system admin message is created, reset the Viewed System Admin Message field on all active user records to False

if (trigger.new[0].Make_Message_Viewable__c == 'Yes') {
    
    system.debug('System Admin Message should be viewable');
    
    Boolean UsersReset = SetupUsersToViewNewSysAdminMsg.ResetViewedSystemAdminMsgField();
    
    if (!UsersReset) {
    
        Trigger.new[0].Users_Not_Setup_To_View_Message__c = True;
    
    }   
   
}


}