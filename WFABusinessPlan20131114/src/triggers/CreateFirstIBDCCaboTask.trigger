trigger CreateFirstIBDCCaboTask on Case (after insert) {

//Trigger has been replaced by scheduled apex class ScheduleTaskingForCABOOnDemandCases

/*
//assigns a task to the internal who covers the fa who submitted a batch of CABO cases. 1 task per batch
//this trigger will fire when the Assign IBDC Task check box on the CABO case is updated via a time trigger workflow

Set<ID> ConIDs = new Set<ID>();
Map<ID, ID> ContactToIBDC = new Map<ID, ID>();
Map<ID, Task> ConIDToIBDCTask = new Map<ID, Task>();
List<Case> CABOCases = new List<Case>();
List<ID> CABOCaseIDs = new List<ID>();
Date CaseCreatedDate;

    system.debug('first cabo task trigger already run? ---------- ' + Validator_cls.hasALreadyDone());
    
if (!Validator_cls.hasAlreadyDone()) {//prevents workflows from firing trigger twice
    
    For (Case cs: Trigger.new) {
        //Case oldcs = Trigger.oldmap.get(cs.id);
        
        //system.debug('new case Assign IBDC Task --------- ' + cs.Assign_IBDC_Task__c);
        //system.debug('old case Assign IBDC Task --------- ' + oldcs.Assign_IBDC_Task__c);
        //system.debug('new case rec type id --------- ' + cs.Recordtypeid);
        
        //Cabo Case record type = '012500000005K7J' ; use this in sandbox
        //Cabo on demand record type = '01250000000UKbR'; use this in production
        if (cs.recordtypeid == '01250000000UKbR' && cs.Subject == 'Assigning CABO Tasks') { // Create tasks as soon as cases are created. no more delay 
            
            
            //ConIDs.add(cs.ContactID);
            
            //CABOCases.add(cs);
            if (cs.Case_Created_Date__c != null) {
                CaseCreatedDate = cs.Case_Created_Date__c; //editable case created date field. used this field to allow test class to pass with custom case created dates
            } else {
                CaseCreatedDate = system.now().date();
            }
            
            CABOCaseIDs.add(cs.id);
            
            break;
          
            
        }
        
    }            

    if (CABOCaseIDs.size() > 0 ) {
        
        //new CABO on demand cases have been inserted but need to query cases created in the last 7 days
        //and assign IBDC tasks to those cases
        
        system.debug('CaseCreatedDate ---------- ' + CaseCreatedDate);
        
        //only assign task on previous created cabo on demand cases if the current list of cases are created on a friday
        if (Math.MOD(Date.newinstance(1900,1,7).daysbetween(CaseCreatedDate), 7) == 5) { 
                                                                            
            Date LastWeek = CaseCreatedDate.addDays(-7); //set date of previous friday
            
            //Date testClassDate = date.newinstance(2012,11,9);
            
            //cabo case record type = '012500000005K7J' ; use this in sandbox
            //Cabo on demand record type = '01250000000UKbR'; use this in production

            Case[] PrevWkCABOonDemandCases = [SELECT ID, ContactID FROM Case WHERE RecordTypeID = '01250000000UKbR' AND 
            (Case_Created_Date__c >= : LastWeek AND Case_Created_Date__c < :CaseCreatedDate) AND ContactID != null];
            //
            system.debug('Prev Week Cabo on demand cases ---------- ' + PrevWkCABOonDemandCases);
            
            //loop through prev week cases to store contact id, to use in query that checks for existing ibdc tasks
            for (Case cs: PrevWkCABOonDemandCases) {
                
                ConIds.add(cs.ContactID);
                
            }
            
            if (ConIds.size() > 0) {
                Date TaskAssignedDate = UtilityMethods.TaskDueDate(System.today(),'Monday'); //if task is created on a weekend, push the assigned date up to the monday after.
                
                system.debug('CABO onDemand Cases FAs --------- ' + conIds);
                
                ContactToIBDC = UtilityMethods.GetUserIDMap(conIDs,'IBDC');
                
                Map<ID, Task> FAtoIBDCTask = new Map<ID, Task>();
                
                Task[] ExistingIBDCCABOFollowUp = [SELECT ID, WhoID FROM Task WHERE OwnerID IN : ContactToIBDC.values() AND 
                RecordTypeID = '012300000000V1J' AND Status = 'Incomplete' AND Category__c = 'CABO-Follow Up Task' 
                AND Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task'];
                
                For (Task t: ExistingIBDCCABOFollowUp) {
                    FAtoIBDCTask.put(t.whoid, t);
                }    
              
                For (Case cs : PrevWkCABOonDemandCases) { // create tasks for tasks created in the previous week, not the ones created in trigger.new
                    
                    //check if there's already an open first follow up task for this fa
                    //proceed only if there isn't
                    if (FAtoIBDCTask.get(cs.ContactID) == null) {
                    
                        if (ContactToIBDC.get(cs.ContactID) != NULL) {//makes sure the ibdc is an active user
                        
                        
                            if (!ConIDToIBDCTask.containskey(cs.ContactID)) 
                            {
                            //makes sure a task for this FA hasn't already been added to list
        
                                Task t = new Task(RecordTypeID='012300000000V1J',OwnerID=ContactToIBDC.get(cs.ContactID), WhoID = cs.ContactID,
                                Subject='CABO', Category__c = 'CABO-Follow Up Task', Type = 'Contact-Phone', 
                                Communication_Type__c = 'Outbound', Status = 'Incomplete', 
                                Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task', 
                                ActivityDate = UtilityMethods.TaskDueDate(TaskAssignedDate.adddays(4),'Friday'),
                                Task_Due_Date__c = UtilityMethods.TaskDueDate(TaskAssignedDate.adddays(4),'Friday'));
                            
                                ConIDToIBDCTask.put(cs.ContactID, t);
                            }
                        }    
                     } 
                 } 
             } 
         }
     }
     
     
     
    if (ConIDToIBDCTask.Values().size()>0 ) 
    {
    
    system.debug('IBDC Initial Task -------- ' + ConIDToIBDCtask.Values());
    
        try 
        {
            
            system.debug('IBDC CABO Tasks ---------- ' + ConIDToIBDCTask.Values());
            
            insert ConIDToIBDCTask.Values();
            
            Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again
            

            //SFException.testException(CABOCases, CABOCaseIds);
        } 
        catch (Exception e) 
        {
        
             for (Case cs: CABOCases) 
             {
                trigger.newmap.get(cs.id).adderror('Error occurred: ' + e.getMessage() + ' : Initial IBDC CABO Task Not Assigned. Please contact your system administrator');
             }
        }
    }
}*/
}