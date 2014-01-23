Public class CompileRecentEffortActivities  {

    Public static void CompileActivityInfo(Map<ID,ID> EffortToTaskMap) { //, List<ID> UserIDs) {


    List<Task> RecentActs = new List<Task>();
    // AND (RecordTypeID = '01250000000UIqp' OR RecordTypeID = '01250000000UJQA' OR RecordTypeID = '01250000000UIqk' OR
    // RecordTypeID = '012500000005ICH')
                          
    List<Task> EffortActivities = [SELECT ActivityDate, Last_Modified_Date_Time__c, OwnerID, WhatID, Category__c, Communication_Type__c, Type, Description FROM
                         Task WHERE WhatID IN : EffortToTaskMap.keyset() AND Status = 'Complete'
                         ORDER BY WhatID DESC, ActivityDate DESC,Last_Modified_Date_Time__c DESC]; //list of logged activities on efforts sorted by Effort ID
    
    system.debug('EffortActivities ---------------- ' + EffortActivities);                 
    
    Map<ID, User> Users = new Map<ID, User>([SELECT Name FROM User]); //map of all users and their ids 
    
    Map<ID, Opportunity> Efforts = new Map<ID, Opportunity>([SELECT Recent_Activities_Information__c FROM Opportunity WHERE ID IN: EffortToTaskMap.keyset() ORDER BY ID DESC]);
        
        //integer r = 0;
        if (EffortActivities.size() > 0) {
            RecentActs.add(EffortActivities[0]);
            EffortActivities.remove(0);
            
            for (Integer t = 0; t < EffortActivities.size();) {
            
            System.debug('Task id -------------------- ' + EffortActivities[t].id);
            System.debug('What ID vs effort id -------------------- ' + EffortActivities[t].WhatID + '/' +Efforts.get(EffortActivities[t].whatid).ID);
            
                if (EffortActivities[t].WhatID == RecentActs[RecentActs.size()-1].WhatID) { 
                //system.debug('EffortActivities[t] ---------------- ' + EffortActivities[t]);
    
                    RecentActs.add(EffortActivities[t]);
                    //r++;
                    EffortActivities.remove(t); //remove the task from the queried list once it has been counted as a recent activity for the effort           
                    
                    System.debug('Effort Acts Size ------------------ ' + EffortActivities.size()); 
                    System.debug('NumOfActs ----------------- ' + RecentActs.size());                 
                    
                } else {//if the id is not a match, the first effort's tasks are stored and need to be formatted
                    Efforts.get(RecentActs[RecentActs.size()-1].WhatID).Recent_Activities_Information__c = FormatActivityInfo(RecentActs, Users); //format the activity information                
                    RecentActs.clear(); //clear recent activities for the next effort
                    //r = 0;
                    RecentActs.add(EffortActivities[t]); //add the first task from the new effort
                    EffortActivities.remove(t);
                    //t++;
                    
                }
            }
            
            if (RecentActs.size()>0) {
                
                String NewActivityInfo = FormatActivityInfo(RecentActs, Users);
                
                if (NewActivityInfo.length() < 32768) { //length of newly compiled recent activities info cannot exceed 32768 characters (limit of long text area)
                    Efforts.get(RecentActs[RecentActs.size()-1].WhatID).Recent_Activities_Information__c = FormatActivityInfo(RecentActs, Users); //format the activity information                
                }
                
            }


            try {
                update Efforts.values();
            } catch (exception e) {
                for (Opportunity eff : Efforts.values()) {
                    if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                        integer errorMsgStart = string.valueof(e.getMessage()).indexof('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 34;
                        integer errorMsgEnd = string.valueof(e.getMessage()).indexof(': [');
                        string errorMsg = string.valueof(e.getMessage()).MID(errorMsgStart, errorMsgEnd - errorMsgStart);
                        
                        system.debug('Error message start ---------- ' + errorMsgStart);
                        
                        system.debug('Error message ---------- ' + errorMsg);
                        system.debug('Error message ---------- ' + e.getMessage());
                        
                        trigger.newmap.get(EffortToTaskMap.get(eff.id)).adderror('Effort Validation Rule Violated: ' + errorMsg + ' :Please resolve on the effort record and then log activity');

                     } else {
                     
                        trigger.newmap.get(EffortToTaskMap.get(eff.id)).adderror('Error occurred: ' + e.getMessage() + ' : Please contact your administrator');
                        
                     }
                }
            }
        }
    }
     
    Public static String FormatActivityInfo(List<Task> RecentActs, Map<ID, User>Users) {
    
    String ActInfo = '';
    String notes = '';
    String Categ = '';
    DateTime dt = NULL;
    system.debug('RecentActs Size --------------- ' + RecentActs.size());
    
    For (integer i = 0; i < Math.min(7,RecentActs.size()); i++) { //only display at most 7 recent tasks
    
    system.debug('RecentActs[i] --------------- ' + RecentActs[i]);
    
        dt  = RecentActs[i].ActivityDate;
        if (dt != NULL) {
            dt = dt.adddays(1);
        } else {
            dt = RecentActs[i].Last_modified_Date_time__c;
        }
        
        if (RecentActs[i].Description == NULL && RecentActs[i].Category__c == NULL) {
            notes = '';
            Categ = '';
        } else if (RecentActs[i].Description != NULL) {
            notes = RecentActs[i].Description + '\n';
            Categ = '';
        } else if (RecentActs[i].Category__c != NULL) {
            notes = '';
            Categ = '/' + RecentActs[i].Category__c;
        }
        
        ActInfo = ActInfo + '(' + string.valueof(i+1) + '.) > ' + dt.format('MM/dd/yyyy') + ' - ' + Users.get(RecentActs[i].OwnerID).Name + Categ + '\n' + notes + '\n';
        
       
    }
     system.debug('Activity Info ----------- ' + ActInfo);
    return ActInfo;
    }
}