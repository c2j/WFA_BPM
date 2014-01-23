public class ApexBasedValidation {

    public static void TaskValidation(task t, task oldt) {
        
        string ErrorMsg = '';
        String TaskRecTypeID = '01250000000UMv5'; //Production BLSG Task Rec Type ID 01250000000UMv5; sandbox BLSG Task Rec Type ID 012P0000000Cvxv
        
        if (t.RecordTypeID == TaskRecTypeID) {//blsg task rec type
        
            //BLSG Task activity date cannot moved beyond 30 days from task creation date
            if (string.valueof(t.Subject).contains('First Pass') && t.ActivityDate != OldT.ActivityDate && oldT.Status != 'Complete - Referral Dead') {
                    
                t.ActivityDate.adderror('Cannot Change Due Date on First Pass Reminder');
                
            } else if ((string.valueof(t.Subject).contains('Second Pass') || string.valueof(t.Subject).contains('Follow Up')) && t.ActivityDate > t.CreatedDate.date() + 60) {
                
                system.debug('activity date ---------- ' + t.activitydate);
                system.debug('created date + 60 ---------- ' + t.createddate.date() + 60);            
                t.ActivityDate.adderror('Error: Task Due Date Cannot Be Greater Than 60 Days after Task Created Date');
                
            }
            
            //blsg tasks have to have updated comments before being completed
            /*if ((t.Status == 'Complete' || t.Status == 'Complete Series') && oldt.Status != 'Complete' &&
                oldt.Status != 'Complete Series' && t.Description == oldt.Description) {
                
                t.Description.adderror('Error: Cannot complete task without updating comments');
                
            }*/
        }

    }
    
}