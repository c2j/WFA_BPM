trigger PopulateIFVDateFields on Task (after insert, after update) {

//when a user with the FAI RBC Role logs on an effort a completed task with subject = one of the IFV values,
//the effort field that has the same name as the task subject is populated with the Due date of the task.
//Existing Dates do not get overwritten.

Set<ID> EffortIDs = new Set<ID>();
String EffortPrefix =  Schema.SObjectType.Opportunity.getKeyPrefix();
Set<ID> UserIDs = new Set<ID>();
Set<Task> IFVTasks = new Set<Task>();

for (task t: trigger.new) {
    
    //Task record type is FAI task, status is complete, related to an effort, and subject is one of the IFV values
    if (
    (Trigger.isInsert || (trigger.IsUpdate && trigger.oldmap.get(t.id).status != 'Complete')) &&
    t.recordtypeid == '01250000000UIqp' && 
    t.Status == 'Complete' && 
    t.whatId != null && string.valueof(t.WhatID).startswith(EffortPrefix) && 
    (t.Subject == 'IFV Qualifying Call' || t.Subject == 'IFV Scheduled' || t.Subject == 'IFV Confirmed' || 
    t.Subject == 'IFV Completed' || t.Subject == 'IFV Cancelled')) {
        
        IFVTasks.add(t);    
        EffortIDs.add(t.WhatID);
        UserIDs.add(t.OwnerID);        
    }
}

if (EffortIDs.size() > 0 ) {
    
    Map<ID, User> UsersMap = new Map<ID, User>([SELECT UserRoleId FROM User WHERE ID IN: UserIDs]);
    
    Map<ID, Opportunity> EffortsMap = new Map<ID, Opportunity>([SELECT IFV_Qualifying_Call__c, IFV_Scheduled__c, IFV_Confirmed__c, IFV_Completed__c,
                            IFV_Cancelled__c FROM Opportunity WHERE ID IN: EffortIDs]);
                            
    for (Task t: IFVTasks) {
    
        //user logging the task must be an FAI RBC role
        if (UsersMap.get(t.OwnerID).UserRoleId == '00E500000013nin') {
        
            //only stamp current date if the corresponding IFV date field on the effort is blank
            if (t.subject == 'IFV Qualifying Call' && EffortsMap.get(t.WhatID).IFV_Qualifying_Call__c == Null) {
                
                EffortsMap.get(t.WhatID).IFV_Qualifying_Call__c = t.ActivityDate; //system.today();
                
            } else if (t.subject == 'IFV Scheduled' && EffortsMap.get(t.WhatID).IFV_Scheduled__c == Null) {
                
                EffortsMap.get(t.WhatID).IFV_Scheduled__c = t.ActivityDate; //system.today();
                
            } else if (t.subject == 'IFV Confirmed' && EffortsMap.get(t.WhatID).IFV_Confirmed__c == Null) {
                
                EffortsMap.get(t.WhatID).IFV_Confirmed__c = t.ActivityDate; //system.today();
                
            } else if (t.subject == 'IFV Completed' && EffortsMap.get(t.WhatID).IFV_Completed__c == Null) {
                
                EffortsMap.get(t.WhatID).IFV_Completed__c = t.ActivityDate; //system.today();
                
            } else if (t.subject == 'IFV Cancelled' && EffortsMap.get(t.WhatID).IFV_Cancelled__c == Null) {
                
                EffortsMap.get(t.WhatID).IFV_Cancelled__c = t.ActivityDate; //system.today();
                
            }
        }
        
    }
    
    try {
    
        update EffortsMap.values();
    
    } catch (exception e) {
    
        for (Opportunity eff : EffortsMap.values()) {
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                integer errorMsgStart = string.valueof(e.getMessage()).indexof('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 34;
                integer errorMsgEnd = string.valueof(e.getMessage()).indexof(': [');
                string errorMsg = string.valueof(e.getMessage()).MID(errorMsgStart, errorMsgEnd - errorMsgStart);
                
                system.debug('Error message start ---------- ' + errorMsgStart);
                
                system.debug('Error message ---------- ' + errorMsg);
                system.debug('Error message ---------- ' + e.getMessage());
                
                throw new SFException('Effort Validation Rule Violated: ' + errorMsg + ' :Please resolve on the effort record and then log activity');

             } else {
             
                throw new SFException('Error occurred: ' + e.getMessage() + ' : Please contact your administrator');
                
             }
        }
    }
}
       
}