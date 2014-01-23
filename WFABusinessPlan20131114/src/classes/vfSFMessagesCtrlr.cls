public class vfSFMessagesCtrlr {

    public System_Administrator_Controls__c SysAdminCtrl {get;set;}
    public User CrntUser {get;set;}
    public Boolean UserExempted {get {if (UserExempted == null) {UserExempted = False;} return UserExempted;}set;}
    
    public vfSFMessagesCtrlr(ApexPages.StandardController controller) {
        
        //System admin control Salesforce message Sandbox recordtype id 012R0000000D9Cs
        //System admin control Salesforce message Production recordtype id 01250000000UMKM

        
        //select the most recently created Salesforce message that is made to be viewable
        SysAdminCtrl = [SELECT System_Admin_Message__c, Times_Message_Viewed__c, User_IDs_Granted_Exception__c FROM System_Administrator_Controls__c 
        WHERE RecordTypeID='01250000000UMKM' AND Make_Message_Viewable__c = 'Yes' ORDER BY CreatedDate DESC ];

        
        CrntUser = [SELECT ID, FirstName, LastName, Viewed_System_Admin_Message__c FROM User WHERE ID =:UserInfo.getUserId()]; 
        
        if (SysAdminCtrl.User_IDs_Granted_Exception__c != '' && SysAdminCtrl.User_IDs_Granted_Exception__c != Null) {
            if (String.valueof(SysAdminCtrl.User_IDs_Granted_Exception__c).contains(CrntUser.ID)) {
                UserExempted = True;
            }
        }

    }

    public PageReference ContinueToHome() {
        
        PageReference HomeTab = new PageReference('/'); 
        
        return HomeTab;
    }
    
    public void MarkAsViewed() {
        
        system.debug('-----------Mark As Viewed----------- ');
        
        if (!CrntUser.Viewed_System_Admin_Message__c) {
        
            CrntUser.Viewed_System_Admin_Message__c = True;
            
            try {
                update CrntUser;
            } catch (exception e) {
            
            //    system.debug('Error occurred while marking User as having viewed SF Message ------ ' + e.getMessage());
            
                if (SysAdminCtrl.User_IDs_Granted_Exception__c == '' || SysAdminCtrl.User_IDs_Granted_Exception__c == Null) {
                
                    SysAdminCtrl.User_IDs_Granted_Exception__c = CrntUser.ID;
                    
                } else if(!String.valueof(SysAdminCtrl.User_IDs_Granted_Exception__c).contains(CrntUser.ID)) {
                
                    SysAdminCtrl.User_IDs_Granted_Exception__c += '\n' + CrntUser.ID;
                   
                }
                
                UtilityMethods.email('Error occurred when ' + CrntUser.FirstName + ' ' + CrntUser.LastName + ' viewed System Admin Message', 
                'User Record could not be marked has having viewed message because: \n' + e.getMessage(), null);
    
                update SysAdminCtrl;
                
            }
            
        }
       
        system.debug('Viewed message ---------- ' + CrntUser.Viewed_System_Admin_Message__c);
    }
    

}