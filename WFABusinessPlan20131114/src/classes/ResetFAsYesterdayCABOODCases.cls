global class ResetFAsYesterdayCABOODCases implements Schedulable {
     
    global void execute(SchedulableContext sc) {
        
        system.debug('----------Schedule Reset FA\'s Yesterday\'s CABO OD Cases--------------');
        
        Contact[] FAsWithCABOODCasesYesterday = [SELECT A_Number__c, ID, Yesterday_s_CABO_on_Demand_Cases__c FROM
                                Contact WHERE Yesterday_s_CABO_on_Demand_Cases__c != Null 
                                AND Yesterday_s_CABO_on_Demand_Cases__c > 0];
                                
        system.debug('FAs who submitted CABO OD cases yesterday ---------- ' + FAsWithCABOODCasesYesterday.size() + ' / ' + FAsWithCABOODCasesYesterday);
                            
        string EmailBody = '';
        
        for (contact c: FAsWithCABOODCasesYesterday) {//reset the number of yesterday's cabo on demand cases
            
            
            c.Yesterday_s_CABO_on_Demand_Cases__c = 0;
            
            
            EmailBody += c.Id + ' ' + c.Yesterday_s_CABO_on_Demand_Cases__c + '\n';
            
        }
        
        //email confirmation to jerry.yu@wellsfargoadvisors.com
        UtilityMethods.Email('FAs with CABO OD Case Yesterday', EmailBody, null);
        
        try {
            
            system.debug('Resetting FAs with CABO OD Cases Yesterday');
            
            update FAsWithCABOODCasesYesterday;
            
        } catch (Exception e) {
            system.debug('Error reseting yesterday\'s CABO OD cases: ---------- ' + e.getMessage());
            
            //email error to jerry.yu@wellsfargoadvisors.com
            UtilityMethods.Email('Error resetting Yesterday\'s CABO OD Case Count', e.getMessage(), null);
        }
                                         

    }
        
}