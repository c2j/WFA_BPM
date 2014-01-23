trigger PopulateUserLookUpFields on Case (before insert) {

//This trigger was created to auto populate the Regional Banking Consultant Field on LABS cases based on the FA associated
//with the case, before the case is inserted. But it can be expanded to populate other user lookup fields on other case types.


Map<Case, ID> MapCaseToFAID = new Map<Case,ID>();

for (Case c: trigger.new) {
    //LABS case record type, with a contact
    if (c.RecordTypeID == '01250000000UHoi' && c.ContactID != Null) {
    
        MapCaseToFAID.put(c, c.ContactID);
        
    }
}

if (MapCaseToFAID.values().size() > 0) {
    
    Set<ID> ConIds = new Set<ID>();
    Map<ID, ID> MapRelatedUserToFA = new Map<ID,ID>(); //map of Contact Ids to Regional Banking Consultant user Ids
    
    ConIDs.addall(MapCaseToFAID.values());
    
    MapRelatedUserToFA = UtilityMethods.GetUserIDMap(ConIDs, 'RBC');
    
    for (Case c : MapCaseToFAId.keyset()) {
    
        if (MapRelatedUserToFA.get(c.ContactID) != Null) {
            
            c.Regional_Banking_Consultant__c = MapRelatedUserToFA.get(c.ContactID);
            
        }
    }
    
}
}