@isTest
private class TestCurrentUsersActivitiesVFPage {

    static testMethod void ViewCurrentUsersActivities() {
       
        //stage user: internal
        User userInt = new User();
        userInt.Username = 'Test_user_internal@test.com';
        userInt.LastName = 'Test_internal_name';
        userInt.ProfileId = '00e50000000vBn0AAE';
        userInt.Alias = 'tstint';
        userInt.Email = 'Test_internal@email.com';
        userInt.CommunityNickname = 'Test_internal_nickname';
        userInt.TimeZoneSidKey = 'GMT';
        userInt.LocaleSidKey = 'en_US';
        userInt.LanguageLocaleKey = 'en_US';
        userInt.EmailEncodingKey = 'ISO-8859-1';
        userInt.MobilePhone = '+1 999-999-9999';
        userInt.AU__c = '0012345';
        userInt.EmployeeNumber = '1234567';
        insert userInt;
        
        system.debug('test class user ID ------------ ' + userInt.id);
        
       /* //stage user: FAI RBC
        User userRBC = new User();
        userInt.Username = 'Test_user_FAI_RBC@test.com';
        userInt.LastName = 'Test_FAI_RBC_name';
        userInt.ProfileId = '00e50000000z2GP';
        userInt.Alias = 'tstRBC';
        userInt.Email = 'Test_RBC@email.com';
        userInt.CommunityNickname = 'Test_RBC_nickname';
        userInt.TimeZoneSidKey = 'GMT';
        userInt.LocaleSidKey = 'en_US';
        userInt.LanguageLocaleKey = 'en_US';
        userInt.EmailEncodingKey = 'ISO-8859-1';
        
        insert userRBC;*/
        
        
        //create branch
        Account branch = new Account();
        branch.Name = 'Test Branch';
        
        insert branch;
        
        //create FA that works at branch
        Contact FA = new Contact();
        FA.FirstName = 'Test';
        FA.LastNAme = 'FA';
        FA.AccountId = branch.id;
        
        insert FA;    
        
        system.debug('test class FA ID ------------ ' + FA.id);
        
        //create set of task logged by internal user on FA
        List<Task> Tasks = new List<Task>();
        
        for (integer i = 0; i < 4; i++) {
            Task tsk = new Task();
            tsk.OwnerId = userInt.id;
            tsk.Subject = 'Advisory';
            tsk.Description = 'testing visualforce controller';
            tsk.Category__c = 'Advisory-FundSource';
            tsk.Type = 'Call-Individual';
            tsk.Status = 'Complete';
            tsk.Priority = 'Normal';
            tsk.Communication_Type__c = 'Inbound';
            tsk.RecordTypeId = '012300000000V1JAAU';
            tsk.activitydate = date.newinstance(2012, 1, 1);
            tsk.WhoID = FA.id;
            
            Tasks.add(tsk);
        }
        for (integer i = 0; i < 4; i++) {
            Task tsk = new Task();
            tsk.OwnerId = userInt.id;
            tsk.Subject = 'Advisory';
            tsk.Description = 'continuing VF controller test';
            tsk.Category__c = 'Advisory-FundSource';
            tsk.Type = 'Call-Individual';
            tsk.Status = 'Complete';
            tsk.Priority = 'Normal';
            tsk.Communication_Type__c = 'Inbound';
            tsk.RecordTypeId = '012300000000V1JAAU';
            tsk.activitydate = date.newinstance(2012, 11, 1);            
            tsk.WhoID = FA.id;
            
            Tasks.add(tsk);
        }
            
        insert Tasks;
        
        system.runAs(userInt) { //run as the internal user
            //create instance of CurrentUsersActivities visualforce page
            PageReference pageRef = Page.vfCurrentUsersActivities;
            
            test.setCurrentPage(pageRef);
            
            //create standard controller
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(FA);
            
            //update vf page url with the FA's record id
            ApexPages.currentPage().getParameters().put('id', FA.Id);
        
            
            UsersActivities controllerContact = new UsersActivities(sc);
            
            controllerContact.getUsersActivities();
            controllerContact.showMore();
            
            Task proxyTask = controllerContact.getProxyTask();
            proxyTask.callDisposition = 'Visualforce';
            
            
            
            controllerContact.ApplyFilters();
            controllerContact.ResetFilters();
        }
        
        
 /*       include below test code if view users activities is rolled out to effort.
        
        Tasks.clear(); //clear task list to sotre effort tasks later
        
        //create fa talent
        FA_Talent__c FATalent = new FA_Talent__c();
            FATalent.name = 'Test FA talent';
            FATalent.First_Name__c = 'Test';
            FATalent.Last_Name__c = 'FA Talent';
        
        insert FATalent;
        
        //create effort on fa talent
        Opportunity Effort = new Opportunity();
            Effort.Name = 'Test Effort';
            Effort.FA_Talent__c= FATalent.id;
        
        insert Effort;
        
        
        //create FAI RBC Tasks on effort
        for (integer i = 0; i < 4; i++) {
            Task tsk = new Task();
            tsk.OwnerId = userRBC.id;
            tsk.Subject = 'Coaching';
            tsk.Description = 'testing visualforce controller';
            tsk.Category__c = 'Coaching-Integration Best Practices';
            tsk.Type = 'Contact-Phone';
            tsk.Status = 'Complete';
            tsk.Communication_Type__c = 'outbound';
            tsk.RecordTypeId = '01250000000UIqp';
            tsk.activitydate = date.newinstance(2012, 1, 1);
            tsk.WhatID = Effort.id;
            
            Tasks.add(tsk);
        }
        for (integer i = 0; i < 4; i++) {
            Task tsk = new Task();
            tsk.OwnerId = userRBC.id;
            tsk.Subject = 'Coaching';
            tsk.Description = 'testing visualforce controller';
            tsk.Category__c = 'Coaching-Integration Best Practices';
            tsk.Type = 'Contact-Phone';
            tsk.Communication_Type__c = 'outbound';
            tsk.RecordTypeId = '01250000000UIqp';
            tsk.activitydate = date.newinstance(2012, 11, 1);
            tsk.WhatID = Effort.id;
            
            Tasks.add(tsk);
        }
            
        insert Tasks;
        
        
        
        
        
        system.runAs(userRBC) { //run as the FAI RBC user
        
            //create instance of CurrentUsersActivities visualforce page
            PageReference pageRef = Page.vfCurrentUsersActivities;
            
            test.setCurrentPage(pageRef);
            
            //create standard controller
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(FA);
            
            //update vf page url with the FA's record id
            ApexPages.currentPage().getParameters().put('id', FA.Id);
        
            
            UsersActivities controllerContact = new UsersActivities(sc);
            
            controllerContact.getUsersActivities();
            controllerContact.showMore();
            
            Task proxyTask = controllerContact.getProxyTask();
            proxyTask.callDisposition = 'Visualforce';
            
            
            
            controllerContact.ApplyFilters();
            controllerContact.ResetFilters();
        }
        
        
        
   */
        
        
    }
    
}