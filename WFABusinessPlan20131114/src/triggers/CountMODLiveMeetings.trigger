trigger CountMODLiveMeetings on Task (After insert, After update) {

//This trigger will update the number of Marketing Live Meetings a Contact has attended
//as well as the most recent live meeting's date and name

List<Marketing__c> mktingRecs = new List<Marketing__c>();
List<Task> mktingTasks = new List<Task>();
Set<ID> taskContactIDs = new Set<ID>();
Map<Task, ID> TaskToContactID = new Map<Task, ID>();
Map<ID, Marketing__c> ContactIDToMktRec = new Map<ID, Marketing__c>();

Boolean LMSet = False;

Integer countOfLM = 0;

//store a set of all contacts that are affected by the inserting/updating/ of marketing tasks
for (Task tsk : Trigger.new) {
    if (Trigger.isInsert) {
        if (tsk.RecordTypeID == '01250000000UBOX' && tsk.Type == 'Live Meeting' && tsk.Status == 'Complete') { //map all live meeting tasks to contact ids
            TaskToContactID.put(tsk, tsk.whoID);
        }
    } else if (Trigger.isUpdate) {
        Task OldTask = Trigger.oldmap.get(tsk.id);
        
        if (tsk.RecordTypeID == '01250000000UBOX' && tsk.Type == 'Live Meeting' && 
            (tsk.Status == 'Complete' && OldTask.Status != 'Complete') || (tsk.Live_Meeting_Names__c != NUll && 
            tsk.Live_Meeting_Names__c != OldTask.Live_Meeting_Names__c) || (tsk.ActivityDate != OldTask.ActivityDate) ) { //map all live meeting tasks to contact ids
            
            TaskToContactID.put(tsk, tsk.whoID);
        
        }
    }
        
}

If (!TaskToContactID.keyset().isEmpty()) {
    
    system.debug('Live meeting tasks to Contact ID --------- ' + TaskToContactID.keyset().size() + ' / ' + TaskToContactID.keyset());
    
    //map the contact ids to their marketing records
    for (Marketing__c mkt : [SELECT Contact__c, Number_Of_Live_Meetings_Attended__c, Most_Recent_Live_Meeting__c,
    Most_Recent_Live_Meeting_Date__c FROM Marketing__c WHERE Contact__c IN : TaskToContactID.values()]) {
        
        ContactIDToMktRec.put(mkt.Contact__c, mkt);
        
    }    

    If (!ContactIDToMktRec.values().isEmpty()) {
        
        system.debug('Contact Id to Mkt Recs --------- ' + ContactIDToMktRec.values().size() + ' / ' + ContactIDToMktRec.values());
        
        for (Task t : TaskToContactID.keyset()) { // loop through live meeting tasks
            ID cID = TaskToContactID.get(t);
            
            if (ContactIDToMktRec.get(cID) != NULL) { //check if FA on that task has a marketing record
                
                system.debug('Marketing Rec # of LMs attended -------- ' + ContactIDToMktRec.get(cID) + ' / ' + ContactIdToMktRec.get(cID).Number_Of_Live_Meetings_Attended__c);
                
                if (ContactIdToMktRec.get(cID).Number_Of_Live_Meetings_Attended__c == null) {
                    ContactIdToMktRec.get(cID).Number_Of_Live_Meetings_Attended__c = 1;
                } else {
                    
                    if (trigger.isInsert || trigger.oldmap.get(t.id).type != 'Live Meeting') { //only increment Live meetings attended if the task is new or an existing task's type is changed to Live meeting
                        ContactIdToMktRec.get(cID).Number_Of_Live_Meetings_Attended__c += 1; //increment the # of live meetings FA has attended by 1
                    }
                }
                
                system.debug('Marketing Rec most recent LM date -------- ' + ContactIDToMktRec.get(cID) + ' / ' + ContactIdToMktRec.get(cID).Most_Recent_Live_Meeting_Date__c);
                system.debug('Marketing Rec most recent LM name -------- ' + ContactIDToMktRec.get(cID) + ' / ' + ContactIdToMktRec.get(cID).Most_Recent_Live_Meeting__c);
                

                if (ContactIDToMktRec.get(cID).Most_Recent_Live_Meeting_Date__c == null ||
                (ContactIDToMktRec.get(cID).Most_Recent_Live_Meeting_Date__c != null && 
                t.activityDate > ContactIDToMktRec.get(cID).Most_Recent_Live_Meeting_Date__c)) {
                        
                    ContactIdToMktRec.get(cID).Most_Recent_Live_Meeting_Date__c = t.activityDate; //set most recent live meeting date to the current task's activity date
                    ContactIdToMktRec.get(cID).Most_Recent_Live_Meeting__c = t.Live_Meeting_Names__c; //set the most recent live meeting name to the live meeting name on current task
                        
                }   
            
            }
        }
        
        //system.debug('Marketing Records with Live Meetings --------- ' + ContactIDToMktRec.values().size() + ' / ' + ContactIDToMktRec.values());
        
        try {
            update ContactIDToMktRec.Values();
        } catch (Exception e) {
            
            system.debug('Error occured when updating marketing recs ------- ' + e.getMessage());
            
            for (Marketing__c mkt : mktingRecs) {
                mkt.adderror('Error occured. Marketing records not updated with # of live meetings attended');
            }
        }
    }

}

}
/*
        for (Marketing__c m :mktingRecs) {
            for (Task t :mktingTasks) {
                if (t.WhoID == m.Contact__c) {
                    countOfLM++;
                }
                if (t.ActivityDate < dateTime.now() && LMSet == False) {
                    m.Most_Recent_Live_Meeting__c = t.Live_Meeting_Names__c;
                    m.Most_Recent_Live_Meeting_Date__c = t.ActivityDate;
                    LMSet = True;
                }
            }
            
            m.Number_Of_Live_Meetings_Attended__c = countOfLM;
            countOfLM = 0;
        }
    
    } 
    
    else {
        for (Marketing__c m: mktingRecs) {
            m.Number_Of_Live_Meetings_Attended__c = 0;
            m.Most_Recent_Live_Meeting__c = '';
            m.Most_Recent_Live_Meeting_Date__c = Null;
        }
    
    }*/