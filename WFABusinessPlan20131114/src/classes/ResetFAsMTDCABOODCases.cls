global class ResetFAsMTDCABOODCases implements Schedulable {
     
    global void execute(SchedulableContext sc) {
        
        system.debug('----------Schedule Reset Fa\'s MTD CABO OD Cases--------------');
        
        Contact[] FAsWithCABOODCasesMTD = [SELECT A_Number__c, ID, MTD_CABO_on_Demand_Cases__c FROM
                                Contact WHERE MTD_CABO_on_Demand_Cases__c != Null 
                                AND MTD_CABO_on_Demand_Cases__c > 0];
                                
        system.debug('FAs who submitted CABO OD cases MTD ---------- ' + FAsWithCABOODCasesMTD.size() + ' / ' + FAsWithCABOODCasesMTD);
        
        String EmailBody = '';
                
        for (contact c: FAsWithCABOODCasesMTD) {//reset the number of MTD cabo on demand cases
        
            c.MTD_CABO_on_Demand_Cases__c = 0;
            
            EmailBody += c.ID + ' ' + c.MTD_CABO_on_Demand_Cases__c + '\n';
        }
        
        //email confirmation to jerry.yu@wellsfargoadvisors.com
        UtilityMethods.Email('FAs with CABO OD Case MTD', EmailBody, null);
            
        try {
            
            update FAsWithCABOODCasesMTD;
            
        } catch (Exception e) {
            system.debug('Error reseting FA\'s MTD CABO OD cases: ---------- ' + e.getMessage());
            
            //email error to jerry.yu@wellsfargoadvisors.com
            UtilityMethods.Email('Error resetting MTD CABO OD Case Count', e.getMessage(), null);
            
        }
                                         

    }
        
}