trigger RankingFAs_InActive on Contact (After Update) {

/*Set<ID> ProducingFAs = new Set<ID>();
Boolean ReRank = False;


For (contact c: trigger.new) {    
    contact oldc = trigger.oldmap.get(c.id);
    if (c.Dummy_Production_Data_Date__c != oldc.Dummy_Production_Data_Date__c 
    && c.Production_YTD__c > 0 && c.Channel__c == 'PCG' && c.Termination_Date__c == NULL) {
    
    ProducingFAs.add(c.id);
   
    }
}

if (ProducingFAs.size()>0){
system.debug('ProducingFAs Size ------------- ' + ProducingFAs.size());
    RankingFAs.RankFAs(ProducingFAs);
}*/
  
}