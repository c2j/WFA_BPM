trigger CreateLegacyComment on Task (after Insert, after Update) {

/*when activities on the contact, effort, or fa talent are inserted completed or marked completed,
or updated in subject, category, type, due date, or comments after it's been marked completed,
check to see if the task already has a legacy comment record. If it does, update that one,
if not, create a new legacy comments record for the task*/

String ContactPrefix =  Schema.SObjectType.Contact.getKeyPrefix();
String EffortPrefix =  Schema.SObjectType.Opportunity.getKeyPrefix();
String FATalentPrefix =  Schema.SObjectType.FA_Talent__c.getKeyPrefix();
List<Legacy_Comments__c> LegacyComments = new List<Legacy_Comments__c>();
Map<ID,Legacy_Comments__c> ExistingLgcyCmnts = new Map<ID, Legacy_Comments__c>();
Map<ID, RecordType> TaskRecTypesMap = new Map<ID, RecordType>();
Boolean Proceed = false;

if (!Validator_cls.hasAlreadyDone()) {//prevents workflows from firing trigger twice

For (task t: trigger.new) {
    
    If ( (trigger.isInsert || (trigger.isUpdate && (
    (t.description != null && trigger.oldmap.get(t.id).Description != t.Description) || 
    (trigger.oldmap.get(t.id).subject != t.subject) || 
    (trigger.oldmap.get(t.id).category__c != t.category__c) || 
    (trigger.oldmap.get(t.id).activitydate != t.activitydate) || 
    (trigger.oldmap.get(t.id).type != t.type)))) && (t.Status == 'Complete' || t.Status == 'Complete Series')) { //&& 
    //trigger.oldmap.get(t.id).status != 'Complete' && trigger.oldmap.get(t.id).status != 'Complete Series'
    //) ) 
        
        //system.debug('------task is being marked completed. Check if legacy comment is needed---------');
        
        If ( (t.whoId != null && string.valueof(t.whoID).startswith(ContactPrefix)) || 
        (t.whatId != null && (string.valueof(t.WhatID).startswith(EffortPrefix) || 
        string.valueof(t.WhatID).startswith(FATalentPrefix))) ) {//task is on a contact, or effort, or fa talent
            
            //mapping existing legacy comments
            for (Legacy_Comments__c lgc : [SELECT ID, Task_ID__c, Comments__c, Due_Date__c, status__c, Subject__c, Category__c,
            type__c FROM Legacy_Comments__c WHERE Task_ID__c IN: Trigger.newmap.Keyset() OR Task_ID_15_Char__c IN: Trigger.newmap.Keyset()]) {
                
                ExistingLgcyCmnts.put(lgc.Task_ID__c, lgc);
                
            }
            system.debug('Existing legacy comments for trigger tasks ------- ' + ExistingLgcyCmnts.values());
            
            TaskRecTypesMap = new Map<ID, RecordType>([SELECT ID, Name FROM RecordType WHERE SobjectType='Task']);
            
            Proceed = True;
            
            break;
                    
        }
    }
}

//if (Proceed) {             
    For (task t: trigger.new) {
        
        //proceed with trigger if the task is being inserted complete, or updated to complete, or is updated in subject, category, type
        //comments, or due date after it has been marked complete
        If ( (trigger.isInsert || (trigger.isUpdate && (
            (t.description != null && trigger.oldmap.get(t.id).Description != t.Description) || 
            (trigger.oldmap.get(t.id).subject != t.subject) || 
            (trigger.oldmap.get(t.id).category__c != t.category__c) || 
            (trigger.oldmap.get(t.id).activitydate != t.activitydate) || 
            (trigger.oldmap.get(t.id).type != t.type)))) && (t.Status == 'Complete' || t.Status == 'Complete Series')) { //&& 
            //trigger.oldmap.get(t.id).status != 'Complete' && trigger.oldmap.get(t.id).status != 'Complete Series'
            //) ) 
            
            system.debug('trigger insert? ------ ' + trigger.isInsert);
            system.debug('trigger update? ------ ' + trigger.isUpdate);        
            system.debug('task status --------- ' + t.status);
            
            system.debug('------task is being marked completed. Check if legacy comment is needed---------');
            
            If ( (t.whoId != null && string.valueof(t.whoID).startswith(ContactPrefix)) || 
            (t.whatId != null && (string.valueof(t.WhatID).startswith(EffortPrefix) || 
            string.valueof(t.WhatID).startswith(FATalentPrefix) ) ) ) {//task is on a contact, or effort, or fa talent
                    
                
                system.debug('Completed task is on the contact, effort or fa talent');
                system.debug('Task who id---------- ' + t.whoID);
                system.debug('Task what id---------- ' + t.whatID);
                
                //task already has existing legacy comment record, just update existing one
                if (ExistingLgcyCmnts.get(t.ID) != Null && ExistingLgcyCmnts.get(t.id).Task_ID__c == t.ID) {
                    
                    system.debug('--------task already has a legacy comment record--------');
                    
                    ExistingLgcyCmnts.get(t.ID).Due_Date__c = t.ActivityDate;
                    ExistingLgcyCmnts.get(t.ID).Subject__c = t.Subject;
                    ExistingLgcyCmnts.get(t.ID).Category__c = t.Category__c;
                    ExistingLgcyCmnts.get(t.ID).Type__c = t.Type;
                    ExistingLgcyCmnts.get(t.ID).Status__c = t.Status;
                    ExistingLgcyCmnts.get(t.ID).Comments__c = t.Description;
                    ExistingLgcyCmnts.get(t.ID).Record_Type_ID__c = t.RecordTypeID;
                    ExistingLgcyCmnts.get(t.ID).Record_Type_Name__c = TaskRecTypesMap.get(t.RecordTypeID).name;
                    
                } else { //task doesn't already have a legacy comment, so create a new one
                    
                    system.debug('--------task needs a legacy comment record--------');
                    
                    Legacy_Comments__c LC = new Legacy_Comments__c();
                    LC.Assigned_To__c = t.OwnerID;
                    LC.Task_ID__c = t.ID;
                    LC.Due_Date__c = t.ActivityDate;
                    LC.Subject__c = t.Subject;
                    LC.Category__c = t.Category__c;
                    LC.Type__c = t.Type;
                    LC.Status__c = t.Status;
                    LC.Customer__c = t.WhoID;
                    LC.LegacyWhoID__c = t.WhoID;
                    LC.LegacyWhatID__c = t.WhatID;  
                    LC.Comments__c = t.Description;
                    LC.Record_Type_ID__c = t.RecordTypeID;
                    LC.Record_Type_Name__c = TaskRecTypesMap.get(t.RecordTypeID).name;
        
                    if (t.WhatID != Null) {
                        if (string.valueof(t.WhatID).startswith(EffortPrefix)) {
                            LC.Effort__c = t.WhatID;        
                        } else if (string.valueof(t.WhatID).startswith(FATalentPrefix)) {
                            LC.FA_Talent__c = t.WhatID; 
                                  
                        }  
                    }
                    
                    LegacyComments.add(LC);         
                
                }
    
            }
        }
    }     
     
    if (LegacyComments.size() > 0) {
        
        system.debug('Legacy Comments to insert ----------- ' + LegacyComments.size() + ' / ' + LegacyComments);
        
        try {
            insert LegacyComments;
            //Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again
            
        } catch (Exception e) {
            system.debug('Error creating Legacy Comments ---------- ' + e.getMessage());
            
            for (Legacy_Comments__c lc : LegacyComments) {
                
                lc.adderror('Error occurred creating Legacy Comments. Please contact your administrator');
                
            }
        }           
    
    }
    
    if (ExistingLgcyCmnts.values().size() > 0) {
    
        system.debug('Legacy Comments to update----------- ' + ExistingLgcyCmnts.values().size() + ' / ' + ExistingLgcyCmnts.values());
        
        try {
            update ExistingLgcyCmnts.values();
            //Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again
            
        } catch (Exception e) {
            system.debug('Error updating Legacy Comments ---------- ' + e.getMessage());
            
            for (Legacy_Comments__c lc : ExistingLgcyCmnts.values()) {
                
                lc.adderror('Error occurred creating Legacy Comments. Please contact your administrator');
                
            }
        }   
    }        
      
Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again
    
//}
     
}
    
}