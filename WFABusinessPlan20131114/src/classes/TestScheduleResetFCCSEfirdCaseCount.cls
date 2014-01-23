@isTest

private class TestScheduleResetFCCSEfirdCaseCount {

 public static string TaskSchedule = '0 0 0 1 * ? *';
              
    static testMethod void testScheduleResetEfirdCaseCount() {
        
        Test.startTest();
        
        Main_Branch__c[] FCCSFirms = New Main_Branch__c[] {
        new Main_Branch__c (Name = 'Test FCCS Firm 1', RecordTypeID = '01250000000UGdP', Number_Of_FCCS_Efird_Cases__c = 3),
        new Main_Branch__c (Name = 'Test FCCS Firm 2', RecordTypeID = '01250000000UGdP', Number_Of_FCCS_Efird_Cases__c = 6),
        new Main_Branch__c (Name = 'Test FCCS Firm 3', RecordTypeID = '01250000000UGdP', Number_Of_FCCS_Efird_Cases__c = 10)
        };
        
        insert FCCSFirms;
        
        // Schedule the test job
        String jobID = System.schedule(
            'ScheduleResetFCCSEfirdCaseCount',
            TaskSchedule,
            new ScheduleResetFCCSEfirdCaseCount()
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
        
                     
        Main_Branch__c[] FCCSFirmsEfirdCaseCountReset = [SELECT ID FROM Main_Branch__c WHERE (Name = 'Test FCCS Firm 1' OR 
        Name = 'Test FCCS Firm 2' OR Name = 'Test FCCS Firm 3') AND
        Number_Of_FCCS_Efird_Cases__c = null];
        
        System.assertequals(3,FCCSFirmsEfirdCaseCountReset.size());

    
    }
    
}