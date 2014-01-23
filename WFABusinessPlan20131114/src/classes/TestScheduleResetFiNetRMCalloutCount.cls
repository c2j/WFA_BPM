@isTest

private class TestScheduleResetFiNetRMCalloutCount {

 public static string TaskSchedule = '0 0 0 1 1 ? *';
              
    static testMethod void testResetFiNetRMCalloutCount() {
        
        
        
        Account[] FiNetBranches = New Account[] {
        new Account(Name = 'Test FiNet Branch 1', RecordTypeID = '01250000000UGDQ', Call_Out_To_Practice_CM__c = 5, Call_Out_To_Practice_YTD__c = 60),
        new Account(Name = 'Test FiNet Branch 2', RecordTypeID = '01250000000UGDQ', Call_Out_To_Practice_CM__c = 5, Call_Out_To_Practice_YTD__c = 60),
        new Account(Name = 'Test FiNet Branch 3', RecordTypeID = '01250000000UGDQ', Call_Out_To_Practice_CM__c = 5, Call_Out_To_Practice_YTD__c = 60)
        };
        
        insert FiNetBranches;
        
        Test.startTest();
        
        // Schedule the test job
        String jobID = System.schedule(
            'ScheduleResetFiNetRMCalloutCount',
            TaskSchedule,
            new ScheduleResetFiNetRMCalloutCount()
            );
            
            
        // Get the information from the CronTrigger API object
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            // Assert that the expressions are the same

        
        // Verify the expressions are the same
        System.assertEquals(TaskSchedule, cronTrigger.CronExpression);
        
        
        // Assert that the cron job has not started
        
        // IN TEST CLASSES THE JOB EXECUTES AFTER TEST.STOPTEST()
        
        System.assertEquals(0, cronTrigger.TimesTriggered);
        
        
        // Verify the next time the job will run (Tuesday at 6 PM)
         
        //System.assertEquals('2013-05-07 18:00:00', String.valueOf(cronTrigger.NextFireTime));
        
        Test.stopTest(); // will execute the asynchronous Apex
        
        cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        system.debug('test class # of times crontrigger fired ------------ ' + cronTrigger.TimesTriggered);
        
                     
        Account[] FiNetBranchesCalloutCountReset = [SELECT ID FROM Account WHERE (Name = 'Test FiNet Branch 1' OR 
        Name = 'Test FiNet Branch 2' OR Name = 'Test FiNet Branch 3') AND
        Call_Out_To_Practice_CM__c = null];
        
        System.assertequals(3,FiNetBranchesCalloutCountReset.size());

    
    }
    
}