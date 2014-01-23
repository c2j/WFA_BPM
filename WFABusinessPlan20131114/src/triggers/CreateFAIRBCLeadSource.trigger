trigger CreateFAIRBCLeadSource on Opportunity (After Insert) {

//when a Regional Business Consultant role user creates a FiNet effort, auto create a FAI RBC lead source with lead accepted date
//equal to current date

Set<Id> oppIds = trigger.newMap.keySet();
List<Lead_Source__c> FAIRBCLS = new list<Lead_Source__c>();
Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, UserRoleID FROM User WHERE Id IN (SELECT CreatedById FROM Opportunity WHERE Id IN :oppIds)]);


for (Opportunity effort : trigger.new) {
    
    User EffortCreator = mapUsers.get(Effort.Createdbyid);
    
    system.debug('Effort Creator ----------- ' + EffortCreator + ' / ' + EffortCreator.UserRoleID);
    
    //FINET effort created by FAI RBC Role
    if (EffortCreator.UserRoleID == '00E500000013nin' && Effort.RecordTypeID == '01250000000UISQ') { 
        
        Lead_Source__c ls = new Lead_Source__c();
        ls.Effort__c = effort.id;
        ls.RecordTypeID = '01250000000UJOT'; //FAI record type
        ls.Lead_Source__c = 'FAI RBC';
        ls.Lead_Accepted_Date__c = system.today();
        
        FAIRBCLS.add(ls);
    }
    
}    

if (FAIRBCLS.size() > 0 ) {

    try {
        system.debug('Inserting FAI RBC Lead Sources ---------- ' + FAIRBCLS.size() + ' / ' + FAIRBCLS);
        insert FAIRBCLS;
    } catch (Exception e) {
        for (opportunity o: trigger.new) {
            o.adderror('Error occurred inserting FAI RBC lead source for FiNet effort. Contact the salesforce administrator.');
            system.debug('Error while inserting FAI RBC lead source --------- ' + e.getMessage());
        }
    }
}

}