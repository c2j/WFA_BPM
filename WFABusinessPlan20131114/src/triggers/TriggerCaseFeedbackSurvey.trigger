trigger TriggerCaseFeedbackSurvey on Case (before update) {

    //when a part case is closed and the referrer's email is filled in, check to see if that referrer has received a
    //PART case feedback survey in the last 60 days, and whether the referrer has opted out of the survey. If both conditions
    //are false, update the "send part case feedback survey" box that will fire a workflow with the survey email to the 
    //referrer's email address
    
    Map<String, case> BranchContactEmailToCase = new Map<String, Case>();
    
    for (Case c: trigger.new) {
    
        Case oldCase = trigger.oldmap.get(c.id);
        
        if (c.Status == 'Closed' && oldCase.Status != 'Closed' && c.RecordTypeId == '012500000005J36' && c.Branch_Contact_Email__c != '') { //part case is being closed
            
            BranchContactEmailToCase.put(c.Branch_Contact_Email__c, c);    
                
        }
        
    }
    
    system.debug('BranchContactEmailToCase Keyset --------- ' + BranchContactEmailToCase.keyset());
    
    if (BranchContactEmailToCase.keyset().size() > 0) {
        
        system.debug('Referrer Email to Case Map --------- ' + BranchContactEmailToCase);
        
        Map<String,Secondary_Contact__c> SecondaryContactsMap = new Map<String, Secondary_Contact__c>();
        
        For (Secondary_Contact__c sc: [SELECT Contact_Email__c, Date_Of_Last_PART_Case_Feedback_Response__c, 
        Stop_PART_Case_Feedback_Survey__c FROM Secondary_Contact__c WHERE Contact_Email__c IN: BranchContactEmailToCase.keyset()]) {
        
            SecondaryContactsMap.put(sc.Contact_Email__c, sc);
            
        }
        
        system.debug('Secondary Contacts Map ------- ' + SecondaryContactsMap);
        
        //loop through all just closed part cases with a referrer's email
        for (String email : BranchContactEmailToCase.keyset()) {
            
            //do not send survey if that referrer has responded to one in the last 60 days and
            //has opted out of this survey
            
            if (SecondaryContactsMap.get(email) == Null || 
            ((SecondaryContactsMap.get(email).Date_of_Last_PART_Case_Feedback_Response__c == Null || 
            UtilityMethods.getDaysBetweenDateTimes(system.now(), SecondaryContactsMap.get(email).Date_of_Last_PART_Case_Feedback_Response__c) > 60) &&
            !SecondaryContactsMap.get(email).Stop_Part_Case_Feedback_Survey__c)) {
                
                BranchContactEmailToCase.get(email).Send_Part_Case_Feedback_Survey__c = True;
                
            }
    
        }
        
    }
    
    
}