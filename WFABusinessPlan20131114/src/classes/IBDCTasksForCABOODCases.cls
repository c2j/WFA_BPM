Public class IBDCTasksForCABOODCases {

    Public static string AssignIBDCCABOTasksOnClick(Date CaseCreatedDate, Date EndDate) {
    
        Map<ID, ID> ContactToIBDC = new Map<ID, ID>();
        Map<ID, Task> ConIDToIBDCTask = new Map<ID, Task>();
        Set<ID> conIds = new Set<ID>();
        List<ID> FAsNotTasked = new List<ID>();       
        String EmailBody = '';
        String TaskedFAsEmail = '';
        
        if (EndDate == null) {
            EndDate = system.today();
        }
        
        //****DEBUG****
        UtilityMethods.email('Commencing CABO OD Cases Tasking', 'Debugging Email', null);
        
        //list of cabo on demand record type cases created in the past week from when this class is run. Not including the day
        //this class runs
        
         //012500000005K7J use in sandbox; 01250000000UKbR use in production
        Case[] PrevWkCABOonDemandCases = [SELECT ID, ContactID, Contact.FirstName, Contact.LastName, Contact_s_A_Number__c FROM Case 
        WHERE RecordTypeID = '01250000000UKbR' AND Origin = 'CABO on Demand' AND 
            (Case_Created_Date__c >= : CaseCreatedDate AND Case_Created_Date__c < : EndDate) AND ContactID != null];
        
        system.debug('Prev Week CABO OD Cases --------- ' + PrevWkCABOonDemandCases);
        
        //****DEBUG****
        UtilityMethods.email('CABO OD Cases to Task', '# of Cases: ' + PrevWkCABOonDemandCases.size(), null);
        
        for (Case cs: PrevWkCABOonDemandCases) {
                
            ConIds.add(cs.ContactID);
                
        }
        
        if (ConIDs.size() > 0) {   
            
            //****DEBUG****
            UtilityMethods.email('FAs On CABO OD Cases To Tasks', '# of FA Ids: ' + ConIDs.size(), null);
            
            Date TaskAssignedDate = UtilityMethods.TaskDueDate(EndDate,'Monday'); //if task is created on a weekend, push the assigned date up to the monday after.
            Date TaskDueDate = UtilityMethods.TaskDueDate(TaskAssignedDate.adddays(4),'Friday');
            
            system.debug('CABO onDemand Cases FAs --------- ' + conIds);
                        
            //map contact to user id of contact's IBDC
            ContactToIBDC = UtilityMethods.GetUserIDMap(conIDs,'IBDC');
            
            Map<ID, Task> FAtoIBDCTask = new Map<ID, Task>();
            
            Task[] ExistingIBDCCABOFollowUp = [SELECT ID, WhoID FROM Task WHERE OwnerID IN : ContactToIBDC.values() AND 
            WhoID IN: ConIDs AND 
            RecordTypeID = '012300000000V1J' AND Status = 'Incomplete' AND Category__c = 'CABO-Follow Up Task' AND
            Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task'];
            
            For (Task t: ExistingIBDCCABOFollowUp) {
                FAtoIBDCTask.put(t.whoid, t);
            }       
                  
            For (Case cs : PrevWkCABOonDemandCases) { // create tasks for tasks created in the previous week, not the ones created in trigger.new
                
                //check if there's already an open first follow up task for this fa
                //proceed only if there isn't
                if (FAtoIBDCTask.get(cs.ContactID) == null) {
                
                    if (ContactToIBDC.get(cs.ContactID) == NULL) {//makes sure the ibdc is an active user
                            
                            if (!EmailBody.contains(cs.ContactID)) {
                                EmailBody += '\n' + cs.Contact.FirstName + ' ' + cs.Contact.LastName + '; ' + cs.ContactID + '; ' + cs.Contact_s_A_Number__c + '\n';
                                //FAsNotTasked.add(cs.ContactID);
                            }
                                                
                    } else {

                        if (!ConIDToIBDCTask.containskey(cs.ContactID)) 
                        {
                        //makes sure a task for this FA hasn't already been added to list
    
                            Task t = new Task(RecordTypeID='012300000000V1J',OwnerID=ContactToIBDC.get(cs.ContactID), WhoID = cs.ContactID,
                            Subject='CABO', Category__c = 'CABO-Follow Up Task', Type = 'Contact-Phone', 
                            Communication_Type__c = 'Outbound', Status = 'Incomplete', 
                            Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task', 
                            ActivityDate = TaskDueDate,
                            Task_Due_Date__c = TaskDueDate);
                        
                            ConIDToIBDCTask.put(cs.ContactID, t);
                            
                            TaskedFAsEmail += '\n' + cs.Contact.FirstName + ' ' + cs.Contact.LastName + '; ' + cs.ContactID + '; ' + cs.Contact_s_A_Number__c + '\n';
                        }
                    }    
                 } 
             }    

            if (ConIDToIBDCTask.Values().size()>0 ) {
                
                //****DEBUG****
                UtilityMethods.email('CABO OD Cases Tasks Being Assigned', '# of Tasks : ' + ConIDToIBDCTask.Values().size(), null);
                
                system.debug('IBDC CABO Tasks -------- ' + ConIDToIBDCtask.Values());
        
                try {
                    
                    system.debug('IBDC CABO Tasks ---------- ' + ConIDToIBDCTask.Values());
                    
                    insert ConIDToIBDCTask.Values();
                    
                    //Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again
        
                } catch (Exception e) {
                    
                    system.debug('IBDC CABO Tasks not created -------------- ' + e.getMessage());
                    
                    UtilityMethods.Email('Error inserting IBDC CABO Tasks', e.getMessage(), null);
                    
                    return 'Error Inserting IBDC Tasks on CABO OD Cases: ' + e.getCause();
                    
                }
            }
            
            if (TaskedFAsEmail!= '') { //email of FAs who were tasked
                
               //Contact[] ContactsNotTasked = [SELECT FirstName, LastName, ID, A_Number__c FROM Contact WHERE ID IN: FAsNotTasked];
                
               //system.debug('FAs not CABO Tasked --------- ' + ContactsNotTasked);
               
               //String[] toAddresses = new String[] {'jerry.yu@wellsfargoadvisors.com'};
               
               String Body = 'The following FAs were given IBDC CABO OD Cases Tasks: \n' + TaskedFAsEmail;
               
               UtilityMethods.email('FAs Tasked for CABO Cases', Body, null);
               
    
           }            
           
           if (EmailBody != '') { //send email notification if there are FAs not tasked because of an inactive IBDC
                
               //Contact[] ContactsNotTasked = [SELECT FirstName, LastName, ID, A_Number__c FROM Contact WHERE ID IN: FAsNotTasked];
                
               //system.debug('FAs not CABO Tasked --------- ' + ContactsNotTasked);
               
               //String[] toAddresses = new String[] {'jerry.yu@wellsfargoadvisors.com'};
               
               String Body = 'The following FAs were not tasked for their CABO Cases because their IBDCs are inactive users. \n' +
               'If the IBDC is active, make sure the IBDC name on the customer record matches the IBDC\'s user record name: \n' + EmailBody;

               UtilityMethods.email('FAs not Tasked for CABO Cases', Body, null);
               
    
           }
           
           //****DEBUG****
           UtilityMethods.email('IBDC Tasks on CABO OD Cases Successfully Assigned', 'Debugging Email', null);
           
           return 'IBDC Tasks on CABO OD Cases Successfully Assigned';
           
       } else {
           
           //****DEBUG****
           UtilityMethods.email('No CABO OD Cases Created in Last 7 Days', 'Debugging Email', null);
           
           return 'No CABO OD Cases Created in Last 7 Days';
           
       }   
       
   }
   
}