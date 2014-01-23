trigger CreateResolutionCaseOnTaskEscalation on Task (before insert, before update) {

//00GW0000000LZop //Cabo SMEs queue id in sandbox
//00G50000001RIJC //CABO SMES queue id in production

List<Task> EscalatedTasks = new List<Task>();

for (Task t: trigger.new) {
    
    if (trigger.isupdate) {
        
        system.debug('---------Escalated Task Updated----------');
        
        Task oldT = trigger.oldmap.get(t.id);
        
        system.debug('New Task Status -------- ' + t.status);
        system.debug('Old Task Status -------- ' + oldt.Status);
        system.debug('New Task Escalated Issue --------- ' + t.Escalated_Issue__c);
        system.debug('Old Task Escalated Issue --------- ' + oldT.Escalated_Issue__c);
        
        if (t.RecordTypeID == '012300000000V1J' && (t.Subject == 'CABO' || t.Subject == 'WFA Tools')  &&  
            t.status == 'Complete' && 
            t.escalated_issue__c == True && oldT.escalated_issue__c == False
            ) {
            
            EscalatedTasks.add(t);
            
        }
    } else if (trigger.isinsert) {
    
        system.debug('----------Escalated Task Inserted---------');
        
        if (t.RecordTypeID == '012300000000V1J' && t.Subject == 'CABO' && t.status == 'Complete' 
            && t.escalated_issue__c == True
            ) {
            
            EscalatedTasks.add(t);
            
        }   
    } 
        
        
    
}
        
if (EscalatedTasks.size() > 0) {
    
    system.debug('Escalated Tasks List -------------- ' + EscalatedTasks);
    
    List<Case> ResolutionCases = new List<Case>();
    
    Database.DMLOptions dmo = new Database.DMLOptions(); //specifies the assignment rule to be used when creating a case
    dmo.assignmentRuleHeader.assignmentRuleId= '01Q50000000F6UI'; //specifies the assignment rule id
    dmo.EmailHeader.TriggerUserEmail = true; // allows the case assignment notification to be emailed to case owner
       
    for (task t: EscalatedTasks) {
    
    //012W0000000CpoG //cabo issue resolution case record type in sandbox
//01250000000ULSt //cabo issue resolution case record type in production
        Case c = new case();
        c.RecordTypeID = '01250000000ULSt'; 
        c.ContactID = t.WhoID;
        c.Subject__C = 'CABO';
        c.Category__c = t.category__c;
        c.Description = t.Description;
        c.Date__c = system.now().date();
        
        system.debug('DML Option assignment rule --------- ' + dmo.assignmentRuleHeader.assignmentRuleId);
        system.debug('DML Option trigger email? -------- ' + dmo.EmailHeader.TriggerUserEmail);
        
        c.setOptions(dmo); //ensures the cases are assigned based on the proper assignment rule and their owners notified
        
        //c.OwnerID = '00GW0000000LZop'; //let the case assignment rules assign to queue
        
        ResolutionCases.add(c);
    }

    if (ResolutionCases.size() > 0) {
    
        system.debug('Resolution Cases --------- ' + ResolutionCases.size() + ' / ' + ResolutionCases);
        
        try {
            
            insert ResolutionCases;
        } catch (Exception e) {
        
            system.debug('Resolution cases insert error ------------ ' + e.getMessage());
        
            for (Case c : ResolutionCases) {
                Throw new SFException('Error Occurred. Could not insert Resolution Cases');
                
            }
        }
    }
                
}

}