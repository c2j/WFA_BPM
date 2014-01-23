@isTest
private class TestCreateResolutionCases {

    static testMethod void CreateResolutionCases() {
        
        Account branch = new Account();
        branch.name = 'Test Branch';
        
        insert branch;
        
        Contact FA = new Contact();
        FA.FirstName = 'Test';
        FA.LastName = 'FA';
        FA.AccountID = branch.id;
        
        insert FA;
        
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
        
        List<Task> TasksInserted = new List<Task>();
        
        for (integer i = 0; i<5;i++) {
            Task t = new Task();
            
            t.RecordTypeId = '012300000000V1J';
            t.OwnerId = userInt.id;
            t.WhoID = FA.id;
            t.Subject = 'CABO';
            t.Category__c = 'CABO-Access/Login';
            t.Status = 'Complete';
            t.Communication_Type__c = 'Outbound';
            t.ActivityDate = system.now().date();
            t.Escalated_Issue__c = TRUE;
            t.Description = 'Test Insert';
            
            TasksInserted.add(t);
            
        }
                
        for (integer i = 0; i<5;i++) {
            Task t = new Task();
            
            t.RecordTypeId = '012300000000V1J';
            t.OwnerId = userInt.id;
            t.WhoID = FA.id;
            t.Subject = 'CABO';
            t.Category__c = 'CABO-Access/Login';
            t.Status = 'Incomplete';
            t.Communication_Type__c = 'Outbound';
            t.ActivityDate = system.now().date();
            t.Escalated_Issue__c = FALSE;
            t.Description = 'Test Update';
            
            TasksInserted.add(t);
            
        }     
        
        test.StartTest();
        
        insert TasksInserted;

        //use 01250000000ULSt in production and 012W0000000CpoG in sandbox 
        Case[] ResolutionCases = [SELECT Description, Category__c FROM Case WHERE RecordTypeID = '01250000000ULSt' And
                                    ContactID =: FA.ID];
                                    
        system.assertequals(ResolutionCases.size(), 5);
        system.assertequals(ResolutionCases[0].Category__c, 'CABO-Access/Login');
        system.assertequals(ResolutionCases[0].Description, 'Test Insert');
        
        Task[] TasksUpdated = [SELECT Status, Escalated_Issue__c, Description, RecordTypeId FROM Task WHERE 
                        Escalated_Issue__c = False AND RecordTypeID = '012300000000V1J'];
        
        system.debug('Test Class TasksUpdated List --------- ' + TasksUpdated);
                        
        For (task t: TasksUpdated) {
            t.Status = 'Complete';
            t.Escalated_Issue__c = TRUE;
        }
        
        update TasksUpdated;
        
        ResolutionCases = [SELECT Description, Category__c FROM Case WHERE RecordTypeID = '01250000000ULSt' And
                                    ContactID =: FA.ID];
                                    
        
        system.assertequals(ResolutionCases.size(), 10);
        system.assertequals(ResolutionCases[9].Category__c, 'CABO-Access/Login');
        system.assert(ResolutionCases[9].Description != Null);
         
        test.StopTest();
        
    }
}