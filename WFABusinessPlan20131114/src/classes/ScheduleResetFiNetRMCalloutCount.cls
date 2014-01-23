global class ScheduleResetFiNetRMCalloutCount implements Schedulable {
    
    
    //at the beginning of every month, query a list of all FCCS Firm Main branches that had Efird Cases logged on them
    //in the previous month, indicated by the Number of FCCS Efird Cases field not being blank or greater than 0.
    //Then reset that field to blank for all of those main branches
    
    global void execute(SchedulableContext sc) {
        
        Account[] FiNetBranchesWithCallouts = [SELECT ID, Name, Call_Out_To_Practice_CM__c, Call_Out_To_Practice_YTD__c
            FROM Account WHERE RecordTypeID = '01250000000UGDQ' AND (Call_Out_To_Practice_CM__c != Null AND 
            Call_Out_To_Practice_CM__c > 0)];
        
        system.debug('FiNet Branches with RM callout Counts to Reset --------- ' + FiNetBranchesWithCallouts.size() + ' / ' + FiNetBranchesWithCallouts);
        
        String MTDEmailBody = '';
        String YTDEmailBody = '';
        
        if (FiNetBranchesWithCallouts.size() > 0) {
        
            for (Account b: FiNetBranchesWithCallouts) {
            
                b.Call_Out_To_Practice_CM__c = null;
                
                MTDEmailBody += b.ID + '; ' + b.Name + '; ' + b.Call_Out_To_Practice_CM__c + '\n';
                
                if (system.today().month() == 1 && system.today().day() == 1) { //if the current day is january first, reset YTD numbers
                    
                    system.debug('Resetting YTD FiNet RM Callout Counts');
                    
                    b.Call_Out_To_Practice_YTD__c = null;
                
                    YTDEmailBody += b.ID + '; ' + b.Name + '; ' + b.Call_Out_To_Practice_YTD__c + '\n';
                
                }
            }
            
            try {
                
                update FiNetBranchesWithCallouts;
                
            } catch (exception e) {
            
                system.debug('Error when resetting FiNet RM Callouts Count -------------- ' + e.getMessage());
                
                //email error to jerry.yu@wellsfargoadvisors.com
                UtilityMethods.Email('Error resetting FiNet RM Callouts Count', e.getMessage(), null);
            }      
        
            //email confirmation to jerry.yu@wellsfargoadvisors.com
            UtilityMethods.Email('MTD FiNet RM Callouts Count Reset', MTDEmailBody, null);
            
            if (YTDEmailBody != null) {
                //email confirmation to jerry.yu@wellsfargoadvisors.com
                UtilityMethods.Email('YTD FiNet RM Callouts Count Reset', YTDEmailBody, null);
                
            }
        }
        
    }
}