@isTest

private class TestScheduleFARankings {

    public static string RankingsSchedule = '0 0 7 ? * MON-FRI'; 
    
    static testMethod void TestScheduleRankings() {
    
        Channel__c PCG = new Channel__c(name='PCG');
        insert PCG;
        
        Region__c PCGReg = new Region__c(name = 'PacNorth');
        insert PCGReg;
        
        Account branch = new Account();
        branch.Name = 'Test Branch';
        branch.Channel_Branch__c = PCG.id;
        branch.Region_Branch__c = PCGReg.ID;
        
        insert branch;
        
        Contact FA1 = new Contact();
        FA1.FirstName = 'Test';
        FA1.LastName = 'FA';
        FA1.AccountID = branch.id;
        FA1.Type__c = 'Branch Manager';
        FA1.IBDC__c = 'David Phan';
        FA1.Production_YTD__c = 100000;
        FA1.Production_MTD__c = 1000;
        FA1.Production_Yesterday__c = 100;
        FA1.Annualized_Production__c = 150000;
        FA1.Production_Data_As_Of_Date__c = system.now().date().adddays(-1);

        
        insert FA1;   

        Contact FA2 = new Contact();
        FA2.FirstName = 'Test';
        FA2.LastName = 'FA';
        FA2.AccountID = branch.id;
        FA1.Type__c = 'FA';
        FA2.IBDC__c = 'David Phan';
        FA2.Production_YTD__c = 200000;
        FA2.Production_MTD__c = 2000;
        FA2.Production_Yesterday__c = 200;
        FA2.Annualized_Production__c = 250000;
        FA2.Production_Data_As_Of_Date__c = system.now().date().adddays(-1);

        
        insert FA2;   
    
        Ranking__c FA1Rank = new Ranking__c();
        FA1Rank.Contact__c = FA1.id;
        
        insert FA1Rank;
        
        Ranking__c FA2Rank = new Ranking__c();
        FA2Rank.Contact__c = FA2.id;
        
        insert FA2Rank;
        
        test.StartTest();
        
         // Schedule the test job
        String jobID = System.schedule(
            'ScheduleFARankings',
            RankingsSchedule,
            new ScheduleFARankings()
            );
            
            
        // Get the information from the CronTrigger API object
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            // Assert that the expressions are the same

        
        // Verify the expressions are the same
        System.assertEquals(RankingsSchedule, cronTrigger.CronExpression);
        
        
        // Assert that the cron job has not started
        
        // IN TEST CLASSES THE JOB EXECUTES AFTER TEST.STOPTEST()
        
        System.assertEquals(0, cronTrigger.TimesTriggered);
        
        
        // Verify the next time the job will run (friday at 10 am)
        
        //System.assertEquals('2013-01-10 07:00:00', String.valueOf(cronTrigger.NextFireTime));
        
        Test.stopTest(); // will execute the asynchronous Apex
        
        cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        system.debug('test class # of times crontrigger fired ------------ ' + cronTrigger.TimesTriggered);
        
        //Ranking__c[] FARankings = [SELECT Current_YTD_Production_Rank__c FROM Ranking__c WHERE Contact__c =: FA1.ID OR Contact__c =: FA2.ID];
        
        //system.assert(FARankings[0].Current_YTD_Production_Rank__c != NULL);
        //system.assert(FARankings[1].Current_YTD_Production_Rank__c != NULL);        
        
        
        
    }
    
}