trigger CheckTransitionalReductionAlert on Contact (before insert, before update) {
    
    for(Contact con: Trigger.new){
        //Check Timestamp for TR Alert Send
        //Check if difference between Recruit Anniversary Date and T12 Production As of Date is 3 months
        //Check if Contact type is FA
        
        Date CalculatedDate;
        if(con.Recruit_Anniversary_Date__c != null && con.Recruit_Anniversary_Date__c.year() <= System.today().year() && con.Termination_Date__c == null)
            CalculatedDate = con.Recruit_Anniversary_Date__c.addMonths(-3); // shift back Recruit Anniv Date by 3 months
        if(con.T12_Production__c != null && con.Production_Threshold__c != null && CalculatedDate != null && con.T12_Production_As_Of_Date__c != null && CalculatedDate.month() == con.T12_Production_As_Of_Date__c.month()){
            if(con.TR_Alert_Sent_Date__c == null || con.TR_Alert_Sent_Date__c.year() != System.today().year()){
                    //As per Jeff's recent update <50% - mail dated 06/06/2013
                    if(con.T12_Production__c / con.Production_Threshold__c <(1101.0/1000.0) && con.T12_Production__c / con.Production_Threshold__c >(501.0/1000.0)){
                        if(con.Type__c == 'FA'){
                            con.Send_TR_Alert__c = true;
                            
                        }else{
                            if(con.TR_Approval_Alert_Sent_Date__c == null || con.TR_Approval_Alert_Sent_Date__c.year() != System.today().year())
                                con.Alert_Approval__c = true;
                                // mark field true to send alert for Approval
                        }
                    }else if(con.T12_Production__c / con.Production_Threshold__c <(501.0/1000.0)){
                        if(con.TR_Approval_Alert_Sent_Date__c == null || con.TR_Approval_Alert_Sent_Date__c.year() != System.today().year())
                            con.Alert_Approval__c = true;
                            // mark field true to send alert for Approval
                    }
            }
        }
        
    }
    
}