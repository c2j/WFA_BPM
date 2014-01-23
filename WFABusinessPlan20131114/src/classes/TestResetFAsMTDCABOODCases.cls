@isTest

private class TestResetFAsMTDCABOODCases {
    
    public static string TaskSchedule = '0 0 0 2 * ? *';
               
    static testMethod void testResetYestCABOODCaseCount() {
        
        Account branch = new Account();
        branch.name = 'Test Branch';
        
        insert branch;
        
        contact fa = new contact();
        fa.FirstName = 'Test';
        fa.LastName = 'FA';
        fa.AccountID = branch.id;
        fa.Type__c = 'FA';
        
        insert fa;
        
        contact fa2 = new contact();
        fa2.FirstName = 'Test';
        fa2.LastName = 'FA2';
        fa2.AccountID = branch.id;
        fa2.Type__c = 'FA';
        
        insert fa2;

        List<Case> NewCABOODCases = new List<Case>();
        
        //012500000005K7J use in sandbox; 01250000000UKbR use in production
        for (integer i = 0; i < 5; i++) {
            case cs = new case();
            cs.RecordTypeID = '01250000000UKbR';
            cs.ContactID = fa.id;
            cs.Client_Name__c = 'Test FA';
            cs.Which_Product__c = 'Asset Advisor';
            cs.Case_Created_Date__c = date.newinstance(system.today().year(), system.now().month()-1,math.min(i+3,30));
            
            NewCABOODCases.add(cs);
        }
        
        for (integer i = 0; i < 5; i++) {
            case cs = new case();
            cs.RecordTypeID = '01250000000UKbR';
            cs.ContactID = fa2.id;
            cs.Client_Name__c = 'Test FA2';
            cs.Which_Product__c = 'Asset Advisor';
            cs.Case_Created_Date__c = date.newinstance(system.today().year(), system.now().month()-1,math.min(i+3,30));
            
            NewCABOODCases.add(cs);
        }
                
        insert NewCABOODCases;

        Test.startTest();
       
        // Schedule the test job
        String jobID = System.schedule(
            'ResetFAsMTDCABOODCases',
            TaskSchedule,
            new ResetFAsMTDCABOODCases()
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
        
        Contact FA1CABOCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c FROM
                                      Contact WHERE ID =: FA.id];
        
        if (system.now().day() == 1) {
            system.assertequals(FA1CABOCases.MTD_CABO_on_Demand_Cases__c, null);
        } else {
            system.assertequals(FA1CABOCases.MTD_CABO_on_Demand_Cases__c, 0);
        }
        
        Contact FA2CABOCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c FROM
                                      Contact WHERE ID =: FA2.id];
        
        if (system.now().day() == 1) {
            system.assertequals(FA2CABOCases.MTD_CABO_on_Demand_Cases__c, null);
        } else {
            system.assertequals(FA2CABOCases.MTD_CABO_on_Demand_Cases__c, 0);
        }
        
    
    }
    
}