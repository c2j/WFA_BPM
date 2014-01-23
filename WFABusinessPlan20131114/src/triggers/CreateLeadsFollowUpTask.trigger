trigger CreateLeadsFollowUpTask on Task (before update) {

//Trigger created for the leads oversight pilot, but now being reactivated for the client referral sweepstakes

List<Task> FollowUpTasks = new List<Task>();

system.debug('Creating Leads Follow Up Task Already Done?------ ' + Validator_cls.hasAlreadyDone());

if (!Validator_cls.hasAlreadyDone()) {
    
    system.debug('------Creating Leads Follow Up Task------');
    
    for (task t: trigger.new) {
        task oldt = trigger.oldmap.get(t.id);
            
            //system.debug('task category -------- ' + t.category__c);
            //system.debug('status --------- ' + t.status);
            //system.debug('old status --------- ' + oldt.status);
            //system.debug('lead rating ---------- ' + t.lead_rating__c);
            
        string comments = oldt.Sales_Strategy_Initiative__c;
        
        Date DueDate = UtilityMethods.TaskDueDate(System.today().adddays(7),'Monday');
            
        if (t.recordtypeid == '012300000000V1J' && t.Category__c == 'Leads Distribution-Initial Contact' &&
        (t.status == 'Complete' && oldt.status == 'Incomplete') && t.Lead_Rating__c == 'Follow Up Needed') {
            
            //if (comments != null && comments.contains('Potential KHH Lead')) {
            //    comments = comments.replace('Potential KHH Lead', 'Action Taken On Lead');
            //}
            
            Task firstFollowUp = new task(RecordTypeId = '012300000000V1J', OwnerID = t.OwnerID, Subject = 'Leads Distribution', 
        Category__c = 'Leads Distribution-Follow Up', Sales_Strategy_Initiative__c = comments,
        WhoID = t.WhoId, Lead_Status__c = t.Lead_Status__c,  
        Communication_Type__c = 'Outbound', Type = 'Contact-Phone', status= 'Incomplete', 
        ActivityDate = DueDate, Task_Due_Date__c = DueDate); //Lead_Outcome__c = t.Lead_Outcome__c, don't prepopulate second task with first task's lead outcome. force ibdc to input a new outcome
        
            FollowUpTasks.add(firstFollowUp);
        
        } /*else if (t.recordtypeid == '012300000000V1J' && t.Category__c == 'Leads Distribution-Follow Up' &&
        (t.status == 'Complete' && oldt.status == 'Incomplete') && t.Lead_Rating__c == 'Follow Up Needed') {
            
            if (comments != null && comments.contains('Action Taken On Lead')) {
                comments = comments.replace('Action Taken On Lead', 'Action Taken/Quality of Lead');
            }
                                
            Task finalFollowUp = new task(RecordTypeId = '012300000000V1J', OwnerID = t.OwnerID, Subject = 'Leads Distribution', 
        Category__c = 'Leads Distribution-Final Follow Up', Description = comments,
        WhoID = t.WhoId, Lead_Status__c = t.Lead_Status__c, Lead_Outcome__c = t.Lead_Outcome__c,
        Communication_Type__c = 'Outbound', Type = 'Contact-Phone', status= 'Incomplete', 
        ActivityDate = DueDate,Task_Due_Date__c = DueDate);
        
            FollowUpTasks.add(finalFollowUp);
            
            system.debug('follow up tasks ---------- ' + followuptasks);
        }*/
            
    }
    
    if (FollowUpTasks.size()>0) {
        
        try {
            system.debug('Inserting follow up tasks size --------- ' + followuptasks.size() + ' / ' + followuptasks);        
            insert FollowUpTasks;
            Validator_cls.setAlreadyDone();
        } catch (DMLException e) {
            for (task t : trigger.new) {
               t.adderror('Error occurred: ' + e.getMessage() + ' : Follow Up Task not created. Please contact your system administrator');
            }
        }
     }   

}    
}