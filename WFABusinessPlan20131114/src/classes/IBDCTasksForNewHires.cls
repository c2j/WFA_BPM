public class IBDCTasksForNewHires {

    public static string AssignIBDCTasksOnClick(Date DateEffortMarkedHired) {
        
        List<Task> IBDCTasks = new List<Task>();
        Date Task1Date;
        Date Task2Date;
        Date Task3Date;
        Set<Contact> NewFAsNotTasked = new Set<Contact>();
        String EmailBody = '';
        String NoTasksEmailBody = '';
        
        //****DEBUG****
        UtilityMethods.email('Commencing New  Hires Tasking', 'Debugging Email', null);
                
        Map<ID, Opportunity> NewlyHiredEfforts = new Map<ID, Opportunity>(
        [SELECT ID FROM Opportunity WHERE FA_Talent_Hired__c >=: DateEffortMarkedHired AND (StageName = 'Hired' OR StageName = 'RPL-4'
        OR StageName='Graduate/Affiliate')]);
        
        //****DEBUG****
        UtilityMethods.email('New Hires (Efforts)', '# of Cases: ' + NewlyHiredEfforts.values().size(), null);   
        
        system.debug('Newly Marked Effort Hires ------------ ' + NewlyHiredEfforts.values().size() + ' / ' + NewlyHiredEfforts.values());
        
        //only query newly created contact records, created date matches date effort marked hired. This should exclude rehires, who would have been created more than 1 day ago.
        Map<ID, Contact> NewHires = new Map<ID, Contact>([SELECT Name, FirstName, LastName, A_Number__c,
        ID, IBDC__c, Type__c, Channel__c, Introduction_Tasks_Assigned__c FROM Contact WHERE 
        Effort__c IN: NewlyHiredEfforts.keyset() AND CreatedDate >=: DateEffortMarkedHired AND Introduction_Tasks_Assigned__c = False AND
        (Type__c = 'FA' OR Type__c = 'FA in Training' OR Type__c = 'Branch Manager' OR Type__c = 'Licensee')]);

        system.debug('Newly Marked Contact Hires ------------ ' + NewHires.values().size() + ' / ' + NewHires.values());
        
        if (NewHires.values().size() > 0) { 
            
            Map<ID, ID> IBDCS = UtilityMethods.getUserIdMap(NewHires.keyset(), 'IBDC');
        
            //****DEBUG****
            UtilityMethods.email('New Hires (Contacts) to Task', '# of Cases: ' + NewHires.values().size(), null);  
            
            Date PCGTask1Date = UtilityMethods.TaskDueDate(System.now().date().addmonths(3),'Friday');
            Date PCGTask2Date = UtilityMethods.TaskDueDate(System.now().date().addmonths(4),'Friday');
            Date PCGTask3Date = UtilityMethods.TaskDueDate(System.now().date().addmonths(5),'Friday');
            Date WBSTask1Date = UtilityMethods.TaskDueDate(System.now().date().adddays(14),'Friday');
            Date WBSTask2Date = UtilityMethods.TaskDueDate(System.now().date().adddays(28),'Friday');
            Date WBSTask3Date = UtilityMethods.TaskDueDate(System.now().date().adddays(42),'Friday');
            Date FiNetTask1Date = UtilityMethods.TaskDueDate(System.now().date().adddays(120),'Friday');
            Date FiNetTask2Date = UtilityMethods.TaskDueDate(System.now().date().adddays(150),'Friday');
            Date FiNetTask3Date = UtilityMethods.TaskDueDate(System.now().date().adddays(180),'Friday');
            Date FAITTask1Date = UtilityMethods.TaskDueDate(System.now().date().addmonths(3),'Friday');
            Date FAITTask2Date = UtilityMethods.TaskDueDate(System.now().date().addmonths(4),'Friday');
            Date FAITTask3Date = UtilityMethods.TaskDueDate(System.now().date().addmonths(5),'Friday'); 

            
            For (Contact c: NewHires.values() ) {
                
                if (IBDCS.get(c.id) == null) {
                    
                    NoTasksEmailBody += '\n' + c.FirstName + ' ' + c.LastName + '; ' + c.ID + '; ' + c.A_Number__c + '\n';
                    //NewFAsNotTasked.add(c);
                    //system.debug('Newly Hired FA with inactive IBDC -------- ' + c.Name);
                    
                } else {           
                    //create tasks and add to list to be inserted all at once later.
    
                    if (c.Type__c == 'FA' || c.Type__c == 'Branch Manager' || c.Type__c == 'Licensee') {
                        if (c.Channel__c == 'WBS') {//wbs task due days are in weeks
                            Task1Date = WBSTask1Date;
                            Task2Date = WBSTask2Date; 
                            Task3Date = WBSTask3Date; 
                        } else if (c.Channel__c == 'PCG') {
                            Task1Date = PCGTask1Date;
                            Task2Date = PCGTask2Date;
                            Task3Date = PCGTask3Date;
                        } else if (c.Channel__c == 'FiNet') {
                            Task1Date = FiNetTask1Date;
                            Task2Date = FiNetTask2Date;
                            Task3Date = FiNetTask3Date;
                        }
                    } else if (c.Type__c == 'FA in Training') { //trainee tasks should be due 3,4,5 months from hire date
                        Task1Date = FAITTask1Date;
                        Task2Date = FAITTask2Date;
                        Task3Date = FAITTask3Date;
                    } 
                    
                    Task t1 = new task(RecordTypeID = '012300000000V1J',WhoId = c.Id, OwnerId = IBDCS.get(c.id), 
                    Subject = 'Relationship Building', ActivityDate = Task1Date, Task_Due_Date__c = Task1Date,
                    Category__c = 'Relationship Building-Introduction', Type = 'Contact-Phone', 
                    Communication_Type__c = 'Outbound', Status = 'Incomplete', Description = 'Advisory', 
                    Sales_Strategy_Initiative__c = c.Channel__c + ' - New Hire Intro Conversations: 1st of 3');
                    
                    IBDCtasks.add(t1);
                    
                    Task t2 = new task(RecordTypeID = '012300000000V1J',WhoId = c.Id, OwnerId = IBDCS.get(c.id), 
                    Subject = 'Relationship Building', ActivityDate = Task2Date, Task_Due_Date__c = Task2Date,
                    Category__c = 'Relationship Building-Introduction', Type = 'Contact-Phone', 
                    Communication_Type__c = 'Outbound', Status = 'Incomplete', Description = 'Envision', 
                    Sales_Strategy_Initiative__c = c.Channel__c + ' - New Hire Intro Conversations: 2nd of 3');
                    
                    IBDCtasks.add(t2);
                    
                    Task t3 = new task(RecordTypeID = '012300000000V1J',WhoId = c.Id, OwnerId = IBDCS.get(c.id), 
                    Subject = 'Relationship Building', ActivityDate = Task3Date, Task_Due_Date__c = Task3Date,
                    Category__c = 'Relationship Building-Introduction', Type = 'Contact-Phone', 
                    Communication_Type__c = 'Outbound', Status = 'Incomplete', Description = 'Envision', 
                    Sales_Strategy_Initiative__c = c.Channel__c + ' - New Hire Intro Conversations: 3rd of 3');
                    
                    IBDCtasks.add(t3);
    
                    c.Introduction_Tasks_Assigned__c = True;
                    
                    EmailBody += '\n' + c.FirstName + ' ' + c.LastName + '; ' + c.ID + '; ' + c.A_Number__c + '\n';
    
                }
            }
            
            if (IBDCtasks.size() > 0 ) {
                
                //****DEBUG****
                UtilityMethods.email('New Hires Tasks Being Assigned', '# of Tasks : ' + IBDCtasks.size(), null);
                                
                try {
                    system.debug('IBDC Intro Tasks to insert ---------- ' + IBDCTasks.size() + ' / ' + IBDCTasks);
                    
                    insert IBDCTasks;
                    
                } catch (Exception e) {
                    
                    system.debug('Error occurred while inserting IBDC Intro tasks ----------- ' + e.getMessage());
                    UtilityMethods.Email('Error while inserting IBDC Intro Tasks for New FAs', e.getMessage(), null);
                    
                    return 'Error inserting IBDC Intro tasks: ' + e.getCause();
                }
                
                try {
                    system.debug('updating contacts who received ibdc intro tasks ---------- ' + NewHires.size() + ' / ' + NewHires);
                    
                    update NewHires.values();
                    
                } catch (Exception e) {
                    
                    system.debug('Error occurred while updating contacts who received IBDC Intro tasks ----------- ' + e.getMessage());
                    
                    UtilityMethods.Email('Error while marking FAs as having received intro tasks', e.getMessage(), null);
                    
                    return 'Error Updating Contacts as having received intro tasks: ' + e.getCause();
                }
                
                //email confirmation to jerry.yu@wellsfargoadvisors.com
                UtilityMethods.Email('Newly Hired FAs given IBDC Intro Tasks', EmailBody, null);
                
                    
            } else {
            
                //email confirmation to jerry.yu@wellsfargoadvisors.com
                UtilityMethods.Email('No Newly Hired FAs received Tasks', 'There were ' + NewlyHiredEfforts.size() + ' newly hired efforts since ' + DateEffortMarkedHired , null);
            }
                
            if (NoTasksEmailBody != '') { //send email notification if there are FAs not tasked because of an inactive IBDC
                
                //system.debug('Newly Hired FAs not given IBDC Intro Tasks --------- ' + NewFAsNotTasked);
                
                //String[] toAddresses = new String[] {'jerry.yu@wellsfargoadvisors.com'};
                
                string Body = 'The following Newly Hired FAs were not given IBDC Intro Tasks because their IBDCs are inactive users. \n' +
                'If the IBDC is active, make sure the IBDC name on the customer record matches the IBDC\'s user record name: \n' + NoTasksEmailBody;
                
                utilityMethods.email('Newly Hired FAs not given IBDC Intro Tasks',Body, null);
               
            
            }   
            
           //****DEBUG****
           UtilityMethods.email('IBDC Intro Tasks Successfully Assigned', 'Debugging Email', null);
                       
            return 'IBDC Intro Tasks Successfully Assigned';
            
        } else {
        
           //****DEBUG****
           UtilityMethods.email('No Contacts Need IBDC Intro Tasks', 'Debugging Email', null);
                   
            return 'No Contacts Need IBDC Intro Tasks';
        
        }
        
    }
}