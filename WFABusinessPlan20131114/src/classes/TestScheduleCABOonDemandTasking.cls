@isTest

private class TestScheduleCABOonDemandTasking {
    
    public static string TaskSchedule = '0 0 10 ? * 6 *';
               
    static testMethod void testSchedule() {
        
        Account branch = new Account();
        branch.Name = 'Test Branch';
        
        insert branch;
        
        Contact FA = new Contact();
        FA.FirstName = 'Test';
        FA.LastName = 'FA';
        FA.AccountID = branch.id;
        FA.IBDC__c = 'Open-LA/LH';
        
        insert FA;   
        
        Contact FA2 = new Contact();
        FA2.FirstName = 'Test';
        FA2.LastName = 'FA';
        FA2.AccountID = branch.id;
        FA2.IBDC__c = 'David Phan';
        
        insert FA2; 
            
        Case COD1 = new case();
        COD1.RecordTypeID = '01250000000UKbR';   //012500000005K7J use in sandbox; 01250000000UKbR use in production
        COD1.ContactID = FA.ID;
        COD1.Client_Name__c = 'Test123';
        COD1.Account_Number_s__c = '12345678';
        COD1.Which_Product__c = 'Allocation Advisors';
        COD1.Case_Created_Date__c = system.today().adddays(-4) ;
        COD1.Origin = 'CABO on Demand';
        
        insert COD1;
        
        Case COD2 = new case();
        COD2.RecordTypeID = '01250000000UKbR';   //012500000005K7J use in sandbox; 01250000000UKbR use in production
        COD2.ContactID = FA2.ID;
        COD2.Client_Name__c = 'Test123';
        COD2.Account_Number_s__c = '12345678';
        COD2.Which_Product__c = 'Allocation Advisors';
        COD2.Case_Created_Date__c = system.today().adddays(-7) ;
        COD2.Origin = 'CABO on Demand';
        
        insert COD2;
        
        Test.startTest();
       
        // Schedule the test job
        String jobID = System.schedule(
            'ScheduleCABOonDemandTasking',
            TaskSchedule,
            new ScheduleTaskingForCABOOnDemandCases()
            );
            
            
        // Get the information from the CronTrigger API object
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            // Assert that the expressions are the same

        
        // Verify the expressions are the same
        System.assertEquals(TaskSchedule, cronTrigger.CronExpression);
        
        
        // Assert that the cron job has not started
        
        // IN TEST CLASSES THE JOB EXECUTES AFTER TEST.STOPTEST()
        
        System.assertEquals(0, cronTrigger.TimesTriggered);
        
        
        // Verify the next time the job will run (friday at 10 am)
        
        //System.assertEquals('2013-01-18 10:00:00', String.valueOf(cronTrigger.NextFireTime));
        
        Test.stopTest(); // will execute the asynchronous Apex
        

        cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        system.debug('test class # of times crontrigger fired ------------ ' + cronTrigger.TimesTriggered);
        
        Task[] IBDCCABOTasks = [SELECT ID FROM Task WHERE WhoID =: FA.ID AND Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task'];
        
        System.assertequals(0,IBDCCABOTasks.size());
        
        IBDCCABOTasks = [SELECT ID FROM Task WHERE WhoID =: FA2.ID AND Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task'];
        
        System.assertequals(1,IBDCCABOTasks.size());
        
        //System.assertEquals(1, cronTrigger_after.TimesTriggered);
        
    
    }
    
}