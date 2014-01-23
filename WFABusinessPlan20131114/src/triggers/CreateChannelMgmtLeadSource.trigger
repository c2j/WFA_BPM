trigger CreateChannelMgmtLeadSource on Opportunity (After Insert) {

//when a market manager profile user creates a pcg effort, auto create a channel management lead source with lead accepted date
//equal to current date

Set<Id> oppIds = trigger.newMap.keySet();
List<Lead_Source__c> ChnlMgmtLS = new list<Lead_Source__c>();
Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, ProfileID FROM User WHERE Id IN (SELECT CreatedById FROM Opportunity WHERE Id IN :oppIds)]);


for (Opportunity effort : trigger.new) {
    
    User EffortCreator = mapUsers.get(Effort.Createdbyid);
    
    system.debug('Effort Creator ----------- ' + EffortCreator + ' / ' + EffortCreator.ProfileID);
    
    if (EffortCreator.ProfileID == '00e50000000vLe3') { //effort created by market manager profile
        
        Lead_Source__c ls = new Lead_Source__c();
        ls.Effort__c = effort.id;
        ls.RecordTypeID = '01250000000UJOT'; //FAI record type
        ls.Lead_Source__c = 'Channel Management';
        ls.Lead_Accepted_Date__c = system.today();
        
        ChnlMgmtLS.add(ls);
    }
    
}    

if (ChnlMgmtLS.size() > 0 ) {

    try {
        system.debug('Inserting Channel Management Lead Sources ---------- ' + ChnlMgmtLS.size() + ' / ' + ChnlMgmtLS);
        insert ChnlMgmtLS;
    } catch (Exception e) {
        for (opportunity o: trigger.new) {
            o.adderror('Error occurred inserting channel management lead source for effort. Contact the salesforce administrator.');
            system.debug('Error while inserting channel management lead source --------- ' + e.getMessage());
        }
    }
}

}