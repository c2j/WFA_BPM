trigger CompileRecentEffortActivities on Task (after insert, after update) {

//when an activity is logged on an effort, update the recent activities information field on the related effort to contain
//the activity's last modified date - assigned to/category/communication type/type/notes

//List<Task> EffortActs = new List<Task>();
Map<ID,ID> EffortToTaskMap = new Map<ID,ID>();
//List<ID> UserIDs = new List<ID>();

for (Task t: trigger.new) {

    if (trigger.IsInsert) {
        //(t.RecordTypeID == '01250000000UIqp' || t.RecordTypeID == '01250000000UJQA' || t.RecordTypeID == '01250000000UIqk' || 
        //t.RecordTypeID == '012500000005ICH') && 
        //no longer need a filter on task type. All tasks logged on effort should be included in recent activities info field
        
        if (t.WhatID != NULL &&
        string.valueof(t.WhatID).startswith(Schema.SObjectType.Opportunity.getKeyPrefix())) {//if activity is related to an effort
             
             EffortToTaskMap.put(t.WhatID, t.ID);

        }
        
    } else if (trigger.IsUpdate) {
        //(t.RecordTypeID == '01250000000UIqp' || t.RecordTypeID == '01250000000UJQA' || t.RecordTypeID == '01250000000UIqk' || 
        //t.RecordTypeID == '012500000005ICH') && 
        
        Task OldTask = trigger.oldmap.get(t.id);
        
        if (t.WhatID != NULL && 
        string.valueof(t.WhatID).startswith(Schema.SObjectType.Opportunity.getKeyPrefix()) && t.Status == 'Complete') { //if activity is related to an effort
            
            //if any of the fields that show up in the recent activities info field on the effort change. 
            //If the description changes to blank, do not count it as a change
            if ((t.Description != NULL && t.Description != OldTask.Description) ||
                 (t.Category__c != OldTask.Category__c) || (t.ActivityDate != OldTask.ActivityDate)) { 
       
                    EffortToTaskMap.put(t.WhatID, t.ID);  
                    system.debug('Effort ID ------------ ' + t.WhatID);
            }
        }
    }

}

if (EffortToTaskMap.keyset().size() > 0) {
    CompileRecentEffortActivities.CompileActivityInfo(EffortToTaskMap); //, EffortActs); //, UserIDs);
}


}