trigger TriggerMarketingCallFeedbackSurvey on Task (before insert, before update) {

/* Since tasks cannot set off workflows, this trigger will fire when a marketing task
of any marketing subject and category, and a Reactive Communication Type and Contact-800 Line Type
is completed on a contact. This trigger will mark a checkbox on the related marketing records, and that update
will set off a workflow to email the FA with survey. */

Map<Task, ID> TasktoContactIDs = new Map<Task, ID>();

for (task t: trigger.new) {
    
    if (trigger.isinsert) {
    
        if (t.RecordTypeID == '01250000000UBOX' && t.Status == 'Complete' 
        && t.Communication_Type__c == 'Reactive' && t.Type == 'Contact-800 Line') {
        
            TaskToContactIDs.put(t, t.whoID);
            
        }
        
    }
    
    if (trigger.isUpdate) {
    
        task oldT = trigger.oldmap.get(t.id);
        
        if (t.RecordTypeID == '01250000000UBOX' && oldT.Status != 'Complete' && t.Status == 'Complete' 
        && t.Communication_Type__c == 'Reactive' && t.Type == 'Contact-800 Line') {
        
            TaskToContactIDs.put(t, t.whoID);
            
        }
           
    } 


}

if (TaskToContactIDs.values().size() > 0 ) {
    
    system.debug('Marketing Tasks requiring FA feedback ---------- ' + TaskToContactIDs.keyset());
    
    Marketing__c[] MarketingRecs = [SELECT Email_FA_For_FA_CAll__c, Email_FA_For_CA_Call__c, Marketing_Consultant_on_800_Line__c, Contact__c FROM Marketing__c WHERE Contact__c IN: TaskToContactIDs.values()];
    
    Map<ID, Marketing__c> FAToMarketingRecs = new Map<ID, Marketing__c>();
    
    For (marketing__c m : MarketingRecs) {
        FAToMarketingRecs.put(m.Contact__c, m);
    }
    
    if (FAToMarketingRecs .keyset().size() > 0 ) {
        
        for (task t : TaskToContactIDs.keyset()) {
            
            //populate the marketing consultant to log the most recent reactive 800 line call on the FA's marketing record
            FAToMarketingRecs.get(TaskToContactIDs.get(t)).Marketing_Consultant_on_800_Line__c = t.OwnerID;
            
            if (t.Client_Associate__c == False) {
            
                FAToMarketingRecs.get(TaskToContactIDs.get(t)).Email_FA_For_FA_CAll__c = True;
                FAToMarketingRecs.get(TaskToContactIDs.get(t)).Email_FA_For_CA_Call__c = False;
                
            } else {
                
                FAToMarketingRecs.get(TaskToContactIDs.get(t)).Email_FA_For_FA_CAll__c = False;
                FAToMarketingRecs.get(TaskToContactIDs.get(t)).Email_FA_For_CA_Call__c = True;
            
            }
            
        }
        
        try {
            update FAToMarketingRecs.values();
        } catch (Exception e) {
            system.debug('Error marking Contact rec to receive survey email --------- ' + e.getMessage());
            
            for (Marketing__c m: FAToMarketingRecs.values()) {
            
                m.adderror('Error occurred. Survey not sent to FA. Please contact your system administrator');
            }
        }
    }
}

}