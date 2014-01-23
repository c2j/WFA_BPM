@isTest

private class TestScheduleIBDCTasksForNewHires {

 public static string TaskSchedule = '0 0 7 ? * 5 *';
              
    static testMethod void testScheduleIntroTasks() {
        
        Test.startTest();
        
        Channel__c PCG = new Channel__c(Name = 'PCG');
        Channel__c WBS = new Channel__c(Name = 'WBS');    
        Channel__c FiNet = new Channel__c(Name = 'FiNet');    
        
        insert PCG;
        insert WBS;
        insert FiNet;
        
        Employing_Firm__c ef = new Employing_Firm__c(Name = 'Employer');
        insert ef;
        
        Region__c region = new Region__c(name='Region');
		insert region;
        
        Account ap = new account(name = 'PCG Branch', Region_Branch__c = region.Id, Channel_Branch__c = PCG.id);
        Account aw = new account(name = 'WBS Branch', Region_Branch__c = region.Id, Channel_Branch__c = WBS.id);
        Account af = new account(name = 'FiNet Branch', Region_Branch__c = region.Id, Channel_Branch__c = FiNet.id);
        
        insert ap;
        insert aw;
        insert af;

        FA_Talent__c[] FTals = new FA_Talent__c[] {
            new FA_Talent__c(Name = 'Test FA 1', Employing_Firm__c=ef.id, 
            FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 1', A_Number__c = 'A123456',
            CRD_Number__c = '654321'),
            
            new FA_Talent__c(Name = 'Test FA 2', Employing_Firm__c=ef.id, 
            FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 2', A_Number__c = 'A234567',
            CRD_Number__c = '765432'),
            
            new FA_Talent__c(Name = 'Test FA 3', Employing_Firm__c=ef.id, 
            FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 3', A_Number__c = 'A345678',
            CRD_Number__c = '876543'),
            
            new FA_Talent__c(Name = 'Test FA 4', Employing_Firm__c=ef.id, 
            FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 4', A_Number__c = 'A456789',
            CRD_Number__c = '987654')

            };
        
        insert FTals;
        
        Opportunity[] Efforts = new Opportunity[] {
        
            new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA PCG Q212 654321', FA_Talent_Name__c = FTals[0].id, 
            StageName = 'Hired', CloseDate = System.today(), AccountId = ap.id, ChannelText__c = 'PCG', FA_Talent_Hired__c = System.today()),
            
            new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA WBS Q212 765432', FA_Talent_Name__c = FTals[1].id, 
            StageName = 'Hired', CloseDate = System.today(), AccountId = aw.id, ChannelText__c = 'WBS', FA_Talent_Hired__c = System.today()),
            
            new Opportunity(RecordTypeID = '01250000000UISQ', Name = 'Test FA FiNet Q212 876543', FA_Talent_Name__c = FTals[2].id, 
            StageName = 'RPL-4', CloseDate = System.today(), AccountId = af.id, ChannelText__c = 'FiNet', FA_Talent_Hired__c = System.today()),
            
            new Opportunity(RecordTypeID = '01250000000UISO', Name = 'Test FAIT 4 Q212 987654', FA_Talent_Name__c = FTals[3].id, 
            StageName = 'Hired', CloseDate = System.today(), AccountId = ap.id, ChannelText__c = 'PCG', FA_Talent_Hired__c = System.today(), Special_Hire_Type__c = null)
            
            }; 
        
        insert Efforts;   
        
        Contact[] Contacts = new Contact[] {
        
            new Contact(LastName = 'FA PCG', RecordTypeID='01250000000UHL7', FirstName = 'Test', Type__c = 'FA',  
            A_Number__c = 'A123456', AccountID = ap.id, Effort__c = Efforts[0].id, IBDC__c = 'Adrian Vega'), 
     
            new Contact(LastName = 'FA WBS', RecordTypeID='01250000000UHKs', FirstName = 'Test', Type__c = 'Branch Manager', 
            A_Number__c = 'A234567', AccountID = aw.id, Effort__c = Efforts[1].id, IBDC__c = 'Adrian Vega'),
            
            new Contact(LastName = 'FA FiNet', RecordTypeID='01250000000UHLC', FirstName = 'Test', Type__c = 'Licensee', 
            A_Number__c = 'A345678', AccountID = af.id, Effort__c = Efforts[2].id, IBDC__c = 'Adrian Vega'),
                   
            new Contact(LastName = 'FAIT PCG', RecordTypeID='01250000000UHL7', FirstName = 'Test', Type__c = 'FA in Training', 
            A_Number__c = 'A456789', AccountID = ap.id, Effort__c = Efforts[3].id, IBDC__c = 'Adrian Vega')                     
            

        }; 
        
        insert Contacts;
        
        
        system.debug('Date effort marked hired ---------- ' + efforts[0].FA_Talent_Hired__c);
        
        
        // Schedule the test job
        String jobID = System.schedule(
            'ScheduleIBDCTasksForNewHires',
            TaskSchedule,
            new ScheduleIBDCTasksForNewHires()
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
        
        Map<ID, Contact> NewHires = new Map<ID, Contact>([SELECT Name, ID FROM Contact WHERE Effort__c IN 
             (SELECT ID FROM Opportunity WHERE FA_Talent_Hired__c =: System.Today())]);
             
        Task[] IBDCIntroTasks = [SELECT ID FROM Task WHERE WhoID IN: NewHires.Keyset() AND Category__c = 'Relationship Building-Introduction'];
        
        //System.assertequals(12,IBDCIntroTasks.size());

    
    }
    
}