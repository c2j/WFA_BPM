trigger UpdateFATalentChannelMetrics on Opportunity (after delete, after insert, after update) {

    //if lead source is active roll up selected data to related effort
    List<ID> toCheck = new List<ID>();
    List<ID> PrevFATalents = new List<ID>();
    
    //INSERT: check against new active effort inserts and existing inactivated efforts
    if(Trigger.isInsert && Trigger.isAfter){
        for(integer i = 0; i < Trigger.new.size(); i++){
            if(trigger.new[i].FA_Talent_Name__c != NULL && (trigger.new[i].Inactive__c == false || trigger.new[i].Inactive_FiNet__c == 'False')){ //evaluate inserted active efforts
                toCheck.add(Trigger.new[i].FA_Talent_Name__c);
            }       
        }
    }
    
    //UPDATE: check against new active effort inserts and existing inactivated efforts
    if(Trigger.isUpdate && Trigger.isAfter){
        for(integer i = 0; i < Trigger.new.size(); i++){
            //toCheck.add(trigger.new[i].FA_Talent_Name__c);
            if(trigger.new[i].FA_Talent_Name__c != NULL) {//effort is linked to a FA Talent
                if (((trigger.old[i].StageName != 'Hired' && trigger.old[i].StageName != 'Hired-S7 Licensed' && trigger.old[i].StageName != 'RPL-4' && trigger.old[i].StageName != 'Graduate/Affiliate') &&
                (trigger.new[i].StageName == 'Hired' || trigger.new[i].StageName == 'Hired-S7 Licensed' || trigger.new[i].StageName == 'RPL-4' || trigger.new[i].StageName == 'Graduate/Affiliate')) || 
                 (trigger.old[i].Inactive__c != trigger.new[i].Inactive__c || trigger.old[i].Inactive_FiNet__c != trigger.new[i].Inactive_FiNet__c)) { //evaluate updated active efforts
                    toCheck.add(Trigger.new[i].FA_Talent_Name__c);
                }
                if (trigger.old[i].FA_Talent_Name__c != trigger.new[i].FA_Talent_Name__c) { //if fa talent record is changed on effort
                    toCheck.add(trigger.old[i].FA_Talent_Name__c);
                    toCheck.add(trigger.new[i].FA_Talent_Name__c);
                }
                if (trigger.old[i].Channel__c != trigger.new[i].Channel__c) { //if channel on the effort changes
                    toCheck.add(trigger.new[i].FA_Talent_Name__c);
                }
                
            }      
        }
    }
    
    //DELETE: check against deleted active efforts
    if(Trigger.isDelete && Trigger.isAfter){
        for(integer i = 0; i < Trigger.old.size(); i++){
            if(trigger.old[i].FA_Talent_Name__c != NULL && (trigger.old[i].Inactive__c == false || trigger.old[i].Inactive_FiNet__c == 'False')){ //evaluate deleted active efforts
                toCheck.add(Trigger.old[i].FA_Talent_Name__c);
            }       
        }
    }
    
    
    if(toCheck.size() > 0){
        Map<ID,FA_Talent__c> FATalentsToCheck = new Map<ID,FA_Talent__c>([Select Id, Name, Engaged_With_Other_Channel__c From FA_Talent__c where Id in:toCheck]);
        
        system.debug('FA Talents to check ---------- ' + FATalentsToCheck.values());
        
        FATalentChannelCheck.ProcessFATalentUpdate(FATalentsToCheck);        
    }

}