trigger CreateRankingRecords on Contact (After Insert) {

//------Replaced with CreateRecsRelatedtoContacts Trigger-------

/*List<Ranking__c> NewRankingRecs = new List<Ranking__c>();

for (Contact c: Trigger.new) {
    if ((c.Type__c == 'FA' || c.Type__c == 'FA in Training' || c.Type__c == 'Licensee' ||
    c.Type__c == 'Branch Manager') && 
    (c.channel__c == 'PCG' || c.Channel__c == 'WBS' || c.Channel__c == 'FiNet')) {
    
        Ranking__c r = new Ranking__c(
        Name = c.FirstName + ' ' + c.LastName,
        Contact__c = c.ID);
        
        NewRankingRecs.add(r);
        
    }
}

   
//insert new ranking records for the newly hired FAs
//try{
//system.debug('New Ranking Recs -------------- ' + NewRankingRecs);
    if (NewRankingRecs.size() > 0) {
        insert NewRankingRecs;
    }
//} catch (DMLException e){
//    for (Ranking__c ranks : NewRankingRecs) {
//         ranks.addError('Ranking Record Not Created');
//    }
//}
*/
}