@isTest
private class TestFAProfileVFPage {

    static testMethod void ViewFAProfileVFPage() {
       
        //stage user: Regional President
        User userRP = new User();
        userRP.Username = 'Test_user_RP@test.com';
        userRP.LastName = 'Test_RP_name';
        userRP.ProfileId = '00e50000000v2D3';
        userRP.Alias = 'tstRP';
        userRP.Email = 'Test_RP@email.com';
        userRP.CommunityNickname = 'Test_RP_nickname';
        userRP.TimeZoneSidKey = 'GMT';
        userRP.LocaleSidKey = 'en_US';
        userRP.LanguageLocaleKey = 'en_US';
        userRP.EmailEncodingKey = 'ISO-8859-1';
        userRP.MobilePhone = '+1 999-999-9999';
        userRP.AU__c = '0012345';
        userRP.EmployeeNumber = '1234567';
        insert userRP;
        
        system.debug('test class user ID ------------ ' + userRP.id);
        
        //create branch
        Account branch = new Account();
        branch.Name = 'Test Branch';
        branch.ownerid = userRP.id;
        
        insert branch;
        
        //create FA that works at branch
        Contact FA = new Contact();
        FA.FirstName = 'Test';
        FA.LastName = 'FA';
        FA.AccountId = branch.id;
        FA.OwnerID = userRP.id;
        
        insert FA;    
        
        system.debug('test class FA ID ------------ ' + FA.id);
        
        //create profiling information record for FA
        Hobbies_Charities__c FAProfile = new Hobbies_Charities__c();
        FAProfile.Name__c = FA.ID;
        FAProfile.First_Name__c = FA.FirstName;
        FAProfile.Last_Name__c = FA.LastName;
        
        insert FAProfile;
        
        //create child record for FA
        List<Child__c> children = new List<Child__c>();

        for (integer i = 0;i<7;i++) {
            Child__c child = new Child__c();
            child.Name = 'Child';
            child.Child_Last_Name__c = 'one';
            child.Parent__c = FA.Id;
        
            children.add(child);
        }
        
        insert children;
        
        
        
        system.runAs(userRP) { //run as the Mkt Mgr user
            //create instance of CurrentUsersActivities visualforce page
            PageReference pageRef = Page.vfFAsProfile;
            
            test.setCurrentPage(pageRef);
            
            //create standard controller
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(FAProfile);
            
            //update vf page url with the FA Profile's record id
            ApexPages.currentPage().getParameters().put('id', FAProfile.Id);
        
            vfFAsProfileCtrlr controllerFAProfile = new vfFAsProfileCtrlr(sc);
            controllerFAProfile.getChildren();
            controllerFAProfile.addNewChild(); 
            controllerFAProfile.SetAllowShowMore();
            controllerFAProfile.showMore();
            controllerFAProfile.GoToFullList();
            
            controllerFAProfile.selectedChildID = children[0].id;
            controllerFAProfile.DeleteChild();
         
                
        
        }
        
    }
}