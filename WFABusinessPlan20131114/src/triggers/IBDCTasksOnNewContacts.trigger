trigger IBDCTasksOnNewContacts on Contact (after insert, after update) {

//Replaced with scheduled apex class ScheduleIBDCTasksOnNewHires
//new hire intro tasks will be assigned on tuesdays at 6 pm for all hires marked that day or the day before

/*
List<Contact> Cons = new List<Contact>();
Boolean AssignTasks;
Date Task1Date;
Date Task2Date;
Date Task3Date;
set<ID> ConIds = new set<ID>();
set<ID> editedContacts = new set<ID>();

system.debug('Has Trigger run? ------- ' + Validator_cls.hasAlreadyDone());

if (!Validator_cls.hasAlreadyDone()) {//prevents workflows from firing trigger twice
    For (Contact c: Trigger.new) {
         
        system.debug('New or updated contact -------- ' + c.LastName);
        
        system.debug('Contact IBDC -------- ' + string.valueof(c.ibdc__c));
        
        //only consider creating task if the contact is a producer, if the hire date and IBDC fields are not empty
        if ((c.type__c == 'FA' || c.type__c == 'FA in Training' || c.type__c == 'Branch Manager' || c.type__c == 'Licensee') &&
        c.Hire_Date__c != NULL && (c.IBDC__c != NULL && !string.valueof(c.IBDC__c).contains('Open -')) && c.RecordTypeID != '01250000000UGFv' && c.Terminated__c == 'No') { //should not apply to home office record type
            
            if (trigger.isInsert) {
                ConIds.add(c.id); //list of contacts that need intro tasks
            
            } else if (Trigger.isUpdate && c.Firm_History__c != trigger.oldmap.get(c.id).Firm_History__c && 
            
            c.Termination_Date__c != trigger.oldmap.get(c.id).termination_date__c) {
                
                system.debug('-------Contact being updated needs tasks--------');
                
                ConIds.add(c.id);
                //EditedContacts.add(c.id);
            }    
        }
        
    }
    
    if (ConIds.size() > 0) {
    
        Map<ID, Task> FAToIntroTask = new Map<ID, Task>();
        Map<ID, Contact> ContactsNeedIntroTasks = new Map<ID, Contact>(
        [SELECT type__c, typeText__c, Hire_Date__c, IBDC__c, Channel__c, Firm_History__c, termination_date__c FROM Contact 
        WHERE ID IN :ConIds]);
        
        Task[] ExistingIntroTasks = [SELECT WhoId, Sales_Strategy_Initiative__c FROM Task WHERE 
        Sales_Strategy_Initiative__c LIKE 'New Hire Intro%' AND WhoID IN: ConIds];
        
        if (ExistingIntroTasks.size() > 0) {
            for (task t: ExistingIntroTasks) {
                FAToIntroTask.put(t.WhoId, t);
            }
        }
    
    
        For (Contact c: ContactsNeedIntroTasks.values()) {
         
            If (Trigger.isInsert) {
                
                Cons.add(c);
                
            } else if (Trigger.isUpdate) {
                
                if (FAToIntroTask.get(c.id) == null) {
                    
                    Cons.add(c);
                    
                }
                
            }
        }
        
        If (Cons.size()>0) {
            system.debug('new contacts ---------- ' + cons);
            Map<ID, ID> IBDCS = UtilityMethods.getUserIdMap(ConIds, 'IBDC');
            List<Task> IBDCTasks = IBDCTasksForNewHires.AssignIBDCTasks(IBDCS, Cons);   
            
            
            if (IBDCtasks.size() > 0) {
            
                try {
                    insert IBDCtasks;
                    Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again
                } catch (DMLException e) {
                    for (Contact c: cons) {
                        c.adderror('Error occurred: ' + e.getMessage() + ' : IBDC intro tasks not assigned. Contact administrator');
                    }
                }
            } 
        }
    
    }
}*/
}