trigger TriggerLeadSourceEOCEmail on Opportunity (after update) {

//when an effort is marked hired and the Verified T12 AUM box is checked, check the Email Lead Source EOC checkbox
//on the related active lead source, which will fire off an email, via workflow, to Jonathon Hubbard, including the ER payout
//amount and reason

Set<ID> EffortIds = new Set<ID>();

    for (Opportunity o : trigger.new) {
        
        Opportunity oldEffort = trigger.oldmap.get(o.id);
        
        if ((o.RecordTypeID == '01250000000UISQ' || o.recordTypeID == '01250000000UISS') && 
            (o.StageName == 'Hired' || o.StageName == 'RPL-4' || o.StageName == 'Graduate/Affiliate') &&
            (o.Verified_T12_AUM__c == True && oldEffort.Verified_T12_AUM__c == False)
            ) {
        
            EffortIDs.add(o.id);
            
        }
        
    }
    
    if (EffortIds.size() > 0) {
        
        Lead_Source__c[] LeadSources = [SELECT Email_Lead_Source_EOC__c FROM Lead_Source__c WHERE Effort__c IN: EffortIDs 
        AND Inactive__c = False AND Lead_Source__c = 'External Recruiter'];
        
        if (LeadSources.size() > 0) {
            for (Lead_Source__c ls: LeadSources) {
            
                ls.Email_Lead_Source_EOC__c = True;
                
            }
            
            try {
                
                update LeadSources;
                
            } catch (exception e) {
            
                system.debug('Error occurred while verifying effort\'s T12 and AUM ------------ ' + e.getMEssage());
                throw new SFException('Error occurred while verifying effort\'s T12 and AUM. Please contact your system administrator.');
            
            }
        }
    }
}