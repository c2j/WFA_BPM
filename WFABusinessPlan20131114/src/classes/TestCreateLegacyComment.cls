@isTest

private Class TestCreateLegacyComment {

    static testMethod void TestCreatingLegacyComment() {
        
        //stage user: FAI RBC
        /*User userFAIRBC = new User();
        userFAIRBC.Username = 'Test_user_FAI_RBC@test.com';
        userFAIRBC.LastName = 'Test_FAI_RBC_name';
        userFAIRBC.ProfileId = '00e50000000z2GP';
        userFAIRBC.UserRoleID = '00E500000013nin';
        userFAIRBC.Alias = 'tstRBC';
        userFAIRBC.Email = 'Test_FAI_RBC@email.com';
        userFAIRBC.CommunityNickname = 'Test_FAI_RBC_nickname';
        userFAIRBC.TimeZoneSidKey = 'GMT';
        userFAIRBC.LocaleSidKey = 'en_US';
        userFAIRBC.LanguageLocaleKey = 'en_US';
        userFAIRBC.EmailEncodingKey = 'ISO-8859-1';
        
        insert userFAIRBC;*/
        
        User userFAIRBC = [SELECT ID, UserRoleID, ProfileID FROM User WHERE UserRoleID = '00E500000013nin' AND MobilePhone = '+1 999-999-9999'
        And EmployeeNumber != Null AND AU__c != Null AND IsActive = True Limit 1];
        
        Account branch = new Account();
        branch.name = 'Test Branch';
        insert branch;
        
        FA_Talent__c FAtal = new FA_Talent__c();
        FAtal.Name = 'Test FA 654321';
        FAtal.First_Name__c = 'Test';
        FAtal.Last_Name__c = 'FA';
        FAtal.FAI_Status__c = 'AV';
        FAtal.CRD_Number__c = '654321';
         
        insert FAtal;
        
        Opportunity effort = new Opportunity();
        effort.name = 'Test FA 654321 Effort';
        effort.FA_Talent_name__c = FAtal.id;
        effort.accountid = branch.id;
        effort.closedate = date.newinstance(2013,5,2);
        effort.stageName = 'Disclosure';
        
        insert effort;
        
        Contact FA = new Contact();
        FA.FirstName = 'Existing';
        FA.LastName = 'FA';
        FA.AccountID = branch.id;
        FA.Type__c = 'FA';
        
        insert FA;
        
        List<Task> TasksList = new List<Task>();
        
        Task EffortTask = new Task();
        EffortTask.RecordTypeID = '01250000000UIqp';
        EffortTask.OwnerID = userFAIRBC.id;
        EffortTask.WhatID = effort.id;
        EffortTask.subject = 'Communication';
        EffortTask.category__c = 'Communication-Competitive Intel';
        EffortTask.Type = 'Contact-Phone';
        EffortTask.ActivityDate = date.newinstance(2013,1,24);
        EffortTask.Communication_Type__c = 'FA';
        EffortTask.Status = 'Complete';
        EffortTask.Description = 'Testing';
        
        Task ContactTask = new Task();
        ContactTask.RecordTypeID = '01250000000UIqp'; // '012300000000V1J';
        ContactTask.OwnerID = userFAIRBC.id; //userInt.id;
        ContactTask.WhoID = FA.id;
        ContactTask.subject = 'Post Hire';
        ContactTask.category__c = 'Post Hire-Confirm FA Joined';
        ContactTask.Type = 'Contact-Phone';
        ContactTask.ActivityDate = date.newinstance(2013,2,24);
        ContactTask.Communication_Type__c = 'FA';
        ContactTask.Status = 'Incomplete';
        ContactTask.Description = 'Testing again';
        
        TasksList.add(EffortTask);
        TasksList.add(ContactTask);
        
        
        test.StartTest();
        
        insert TasksList;
        
        
        Legacy_Comments__c[] lc = [SELECT Task_ID__c, Effort__c, Customer__c, Comments__c FROM Legacy_Comments__c WHERE task_id__c =: EffortTask.ID];
        
        System.assertequals(lc.size(),1);
        system.assert(lc[0].comments__c == 'Testing');

        Legacy_Comments__c LegacyCmnt = new Legacy_Comments__c();
        LegacyCmnt.Task_ID__c = ContactTask.id;
        LegacyCmnt.LegacyWhoID__c = FA.ID;
        LegacyCmnt.Customer__c = FA.ID;
        
        insert LegacyCmnt; //create legacy comment for incomplete task

        Validator_cls.resetAlreadyDone();

        TasksList[1].Status = 'Complete';
        TasksList[1].Description = 'Testing Again. the first time was not complete';
        
        update TasksList[1];
        
        lc = [SELECT Task_ID__c, Effort__c, Customer__c, Comments__c, status__c FROM Legacy_Comments__c WHERE task_id__c =: ContactTask.ID];
        
        system.debug('test class LC after task with LC marked complete ------------ ' + lc);
        
        System.assertequals(lc.size(),1);
        system.assert(lc[0].comments__c == 'Testing Again. the first time was not complete');
        system.assert(lc[0].status__c == 'Complete');

        
        test.StopTest();
            
    }
}