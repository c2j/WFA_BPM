public with sharing class vfActivitiesOnRecordCtrlr {

    public ID RecordID {get;set;}
    public List<Task> Activities;

    public vfActivitiesOnRecordCtrlr(ApexPages.StandardController controller) {
        
        RecordID = controller.getRecord().id;
        
        if (RecordID != null) {
            getActivities();
        }
    }

    public List<Task> getActivities() {
        
        Activities = new List<Task>();
        
        if (RecordID != Null) {
            Activities = [SELECT ActivityDate, Status, Description, LastModifiedDate, Subject, Resolved_Date__c, Owner.Name FROM Task WHERE 
            (WhoID =: RecordID OR WhatID =: RecordID) Order By LastModifiedDate DESC, Status DESC limit 1000];
        }
                    
        return Activities;
    }
    
}