trigger CreateCABOFollowUpTasks on Task (after update) {

//this trigger applies to Internals and PCs

//the initial IBDC task for CABO Cases is created x days after the case itself is created
//that initial task is due after 1 business day.
//when the initial task is completed, a follow up task is scheduled to be created/assigned x days after.
    //the scheduling is done via a time trigger workflow. WF will update the assign cabo follow up field
//the follow up task is due after 1 business day.
//when the follow up task is completed, a PC task is created right away and due 7 days after.

List<Task> NewPCCABOTasks = new List<Task>();
List<Task> ExistingPCCABOTasks = new List<Task>();
Set<ID> ConId = new Set<ID>();
Map<ID, ID> PCtoContact = new Map<ID, ID>();
List<ID> FAsWithNoPC = new List<ID>();

For (task t: trigger.new) {
    Task OldTask = trigger.oldmap.get(t.id);
    
    if (t.RecordTypeID == '012300000000V1J'
    && t.Status == 'Complete' && OldTask.Status != 'Complete' && t.Category__c == 'CABO-Follow Up Task' && 
    (t.Sales_Strategy_Initiative__c != null && 
    string.valueof(t.Sales_Strategy_Initiative__c).contains('IBDC CABO Follow Up Task')) && 
    string.valueof(t.First_CABO_Follow_Up__c).contains('(PC Follow Up)') ) {
    
        conID.add(t.whoID); //store all contact ids to get their PC's User Ids
    
    }
}

if (conID.size()>0) {
    PCToContact = UtilityMethods.GetUserIDMap(conID, 'PC'); //map contact id to pc user's id

    
    //Map task id to a list of 3rd CABO follow up tasks aka PC Tasks
    Task[] ExistingPCTasks = [SELECT WhoID, OwnerID FROM Task WHERE OwnerID IN:
    PCToContact.values() AND RecordTypeID = '012500000005CeB' AND Status = 'Incomplete' AND Category__c = 'CABO-Follow Up Task' 
    AND Sales_Strategy_Initiative__c = 'PC CABO Follow Up Task'];

    system.debug('Existing PC Tasks ---------- ' + ExistingPCTasks);
    
    Map<ID, Task> FAToPCTask = new Map<ID, Task>();
    
    for (task t: ExistingPCTasks) {
        FAToPCTask.put(t.WhoID, t);
    }    
        
    Date TaskAssignedDate = UtilityMethods.TaskDueDate(System.now().date(), 'Friday');
    
    For (task t: trigger.new) {
        task oldt = trigger.oldmap.get(t.id);

        if (t.RecordTypeID == '012300000000V1J' && t.status=='Complete'&& t.category__c == 'CABO-Follow Up Task' &&
        t.Sales_Strategy_Initiative__c == 'IBDC CABO Follow Up Task') { 
                
            //Check to see if the an open PC task exists on contact already; only create new task if there isn't one
            if (FAToPCTask.get(t.WhoId) == null) {// a null value means there is no existing task
                
                if (PCToContact.get(t.WhoID) == null) { //check to see if FA has an active PC user
                    FAsWithNoPC.add(t.WhoID);
                } else {
                
                    Task PCFollowUp = New Task(RecordTypeID = '012500000005CeB', OwnerId = PCToContact.get(t.WhoID), WhoId = t.WhoID,
                    Status = 'Incomplete', Subject = t.Subject, Category__c = t.Category__c, Type = t.Type,
                    Communication_Type__c = t.Communication_Type__c, Sales_Strategy_Initiative__c = 'PC CABO Follow Up Task',
                    First_Cabo_Follow_Up__c = t.First_Cabo_Follow_Up__c,
                    Third_Cabo_Follow_Up__c = t.Third_Cabo_Follow_Up__c, 
                    ActivityDate = UtilityMethods.TaskDueDate(TaskAssignedDate.adddays(10),'Friday'),
                    Task_Due_Date__c = UtilityMethods.TaskDueDate(TaskAssignedDate.adddays(10),'Friday'));
                    
                    NewPCCABOTasks.add(PCFollowUp);
                
                }
            } else {
                
                //if there is an existing PC task, but the ibdc completes a second task with a different first follow up value
                //find the existing pc task and update the first follow up result on it.
                
                FAToPCTask.get(t.whoID).First_CABO_Follow_Up__c = t.First_CABO_Follow_Up__c; 
                ExistingPCCaboTasks.add(FAToPCTask.get(t.whoID));
                
            }

        
        }
    }
} 
 
if (ExistingPCCaboTasks.size() > 0) {
    try {
        update ExistingPCCABOTasks;
    } catch (DMLException e) {
        
        for (task t: ExistingPCCABOTasks) {
            trigger.newmap.get(t.id).adderror('Error occurred: ' + e.getMessage() + ' : Existing PC CABO Follow Up tasks not updated with new IBDC task outcome. Please contact your system administrator');
        }
    }
}
if (NewPCCABOTasks.size() > 0) {
    
    try {
        insert NewPCCABOTasks;
    } catch (DMLException e) {
        
        system.debug('Error occurred when inserting PC CABO Tasks ------- ' + e.getMessage());
        
        for (task t: NewPCCABOTasks) {
            t.adderror('Error occurred. PC CABO Follow Up tasks not assigned. Please contact your system administrator');
        }
    }
}
if (FAsWithNoPC.size() > 0) { //send email notification if there are FAs not tasked because of an inactive IBDC
    
   Contact[] ContactsWithNoPC = [SELECT FirstName, LastName, ID, A_Number__c FROM Contact WHERE ID IN: FAsWithNoPC];
    
   system.debug('FAs with No PCs --------- ' + ContactsWithNoPC );

   String EmailBody = '';

   for (Contact c: ContactsWithNoPC ) {

       EmailBody += c.FirstName + ' ' + c.LastName + '; ' + c.ID + '; ' + c.A_Number__c + '\n';
   }

   String[] toAddresses = new String[] {'jerry.yu@wellsfargoadvisors.com','Matthew.Kane@wellsfargoadvisors.com'};
   
   UtilityMethods.email('FAs Do Not Have Active PCs', 'The following FAs\'s PCS were not tasked for the FAs\'s CABO Cases because the PCs are inactive users. \n' +
   'If the PC is active, make sure the PC name on the customer record matches the PC\'s user record name: \n \n' + EmailBody, toAddresses);
 
}   
/*----------code for second ibdc task: no longer needed----------------
    if ((t.Assign_IBDC_CABO_Follow_Up__c == True && oldt.Assign_IBDC_CABO_Follow_Up__c == False) && 
    t.Sales_Strategy_Initiative__c == 'CABO Follow Up Task #1') { //create second task only if first follow up result is not 'fa not available'
    
        Task IBDCFollowUp = New Task(RecordTypeID = '012300000000V1J', OwnerID = t.OwnerID, WhoId = t.WhoID,
        Status = 'Incomplete', Subject = t.Subject, Category__c = t.Category__c, Type = t.Type,
        Communication_Type__c = t.Communication_Type__c, Sales_Strategy_Initiative__c = 'CABO Follow Up Task #2',
        First_Cabo_Follow_Up__c = t.First_Cabo_Follow_Up__c, Second_Cabo_Follow_Up__c = t.Second_Cabo_Follow_Up__c,
        Third_Cabo_Follow_Up__c = t.Third_Cabo_Follow_Up__c, Description = t.Description,
        ActivityDate = UtilityMethods.TaskDueDate(TaskAssignedDate.adddays(1),'Monday'),
        Task_Due_Date__c = UtilityMethods.TaskDueDate(TaskAssignedDate.adddays(1),'Monday'));
        
        NewPCCABOTasks.add(IBDCFollowUp);
    } else
---------------------------------------------------------------------*/  

}