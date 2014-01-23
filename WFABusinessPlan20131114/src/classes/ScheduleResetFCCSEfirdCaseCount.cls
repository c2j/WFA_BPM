global class ScheduleResetFCCSEfirdCaseCount implements Schedulable {
    
    
    //at the beginning of every month, query a list of all FCCS Firm Main branches that had Efird Cases logged on them
    //in the previous month, indicated by the Number of FCCS Efird Cases field not being blank or greater than 0.
    //Then reset that field to blank for all of those main branches
    
    global void execute(SchedulableContext sc) {
    
        Main_Branch__c[] FCCSMBsWithEfirdCases = [SELECT ID, Name, Number_of_FCCS_Efird_Cases__c, Last_Date_Case_Logged__c 
        FROM Main_Branch__c WHERE RecordTypeID = '01250000000UGdP' AND (Number_Of_FCCS_Efird_Cases__c != Null AND 
        Number_Of_FCCS_Efird_Cases__c > 0)];
        
        String EmailBody = '';
        
        if (FCCSMBsWithEfirdCases.size() > 0) {
        
            for (Main_Branch__c mb: FCCSMBsWithEfirdCases) {
            
                mb.Number_of_FCCS_Efird_Cases__c = null;
                
                EmailBody += mb.ID + '; ' + mb.Name + '; ' + mb.Number_of_FCCS_Efird_Cases__c + '\n';
            }
            
            try {
                
                update FCCSMBsWithEfirdCases;
                
            } catch (exception e) {
            
                system.debug('Error when reseting Efird Case Count on FCCS Main Branches -------------- ' + e.getMessage());
                
                //email error to jerry.yu@wellsfargoadvisors.com
                UtilityMethods.Email('Error resetting FCCS Efird Case Count', e.getMessage(), null);
            }      
        
            //email confirmation to jerry.yu@wellsfargoadvisors.com
            UtilityMethods.Email('FCCS Main Branches to have Efird Case Count Reset', EmailBody, null);

            
        }
        
    }
}