trigger UpdateLeadSourceEffort on Lead_Source__c (after insert, after update) {

    //if lead source is active roll up selected data to related effort
    //List<Lead_Source__c> toUpdate = new List<Lead_Source__c>();
    Set<ID> EffortIDs = new Set<ID>();
    
    if (Trigger.isAfter) {
        For (Lead_Source__c l : Trigger.new) {
            //Lead_Source__c oldLS = trigger.oldmap.get(l.id);
            //if (l.inactive__c != oldLS.inactive__c || l.Lead_Source__c != oldLS.Lead_Source__c 
            //|| l.Associate_Channel__c != oldLS.Associate_Channel__c || l.Lead_Accepted_Date__c != oldLS.Lead_Accepted_Date__c) {
                EffortIDs.add(l.effort__c);
            //}
        }
    }

    if(EffortIDs.size() > 0){
        LeadSourceToEffortUpdate.ProcessEffortUpdate(EffortIDs);     
    }

    //kevin's code
    /*if(Trigger.isInsert && Trigger.isAfter){ //check for lead source that has been inserted as active
        for(integer i = 0; i < Trigger.new.size(); i++){
            if(trigger.new[i].Inactive__c == false){
                toUpdate.add(Trigger.new[i]);
            }
        }
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){ //check for a lead source that has been updated to active / inactive
        for(integer i = 0; i < Trigger.new.size(); i++){
            if((trigger.new[i].Inactive__c == false && trigger.old[i].Inactive__c == true) || (trigger.new[i].Inactive__c == false && trigger.old[i].Inactive__c == false) || (trigger.new[i].Inactive__c == true && trigger.old[i].Inactive__c == false)){
                toUpdate.add(Trigger.new[i]);
            }
        }
    }
    
    if(toUpdate.size() > 0){
        LeadSourceToEffortUpdate.ProcessEffortUpdate(toUpdate);     
    }*/ 
   

    
}