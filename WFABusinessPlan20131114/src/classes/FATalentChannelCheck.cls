public with sharing class FATalentChannelCheck {
        
    public static void ProcessFATalentUpdate(Map<ID,FA_Talent__c> FATalentsToCheck){
        
        //query all related active opptys per lead source
        //Set<Id> fatIDs = new Set<Id>();
        
        //for (Opportunity id : opptysToProcess) {
        //    fatIDs.add(id.FA_Talent_Name__c);
        //}

        system.debug('###fatid :'+FATalentsToCheck.keyset());
        
        //Map<ID,FA_Talent__c> faTalents = new Map<ID,FA_Talent__c>([Select Id, Engaged_With_Other_Channel__c From FA_Talent__c where Id in:fatIDs]);
        
        //list of non channel switching efforts related to 
        List<Opportunity> efforts = [Select Id, StageName, FA_Talent_Name__c, Channel__c, Inactive__c, Inactive_FiNet__c, RecordTypeID From Opportunity WHERE 
        RecordTypeID != '01250000000UITR' AND RecordTypeID != '01250000000UITW' AND FA_Talent_Name__c IN:FATalentsToCheck.Keyset() ORDER BY FA_Talent_Name__c DESC NULLS LAST];                   
        
        //Map<ID,FA_Talent__c> faTalentsToUpdate = new Map<ID,FA_Talent__c>();
        
        System.Debug('NUMBER OF FATALENTS RETURNED: ' + faTalentsToCheck.values().size());
        System.Debug('NUMBER OF EFFORTS RETURNED: ' + efforts.size());        
        

        
        for (FA_Talent__c FA: FATalentsToCheck.values()) { //loop through all fa talents
        
            integer totalFiNet = 0;
            integer totalPCG = 0;
            integer totalWBS = 0;           
            integer totalFARS = 0;
            
            integer totalActiveHiredEfforts = 0;
            
            string multiChannel = 'No';
        
            for (Opportunity ef: efforts) { //loop through all efforts with a FA talent
            
                if (ef.FA_Talent_Name__c == FA.id) { //if current effort is related to current fa talent
                    
                    //make sure effort is active, and check for channel
                    if (ef.Inactive__c == False) {
                        if (ef.Channel__c == 'PCG') {
                            totalPCG = totalPCG + 1;
                        } else if (ef.Channel__c == 'WBS') {
                            totalWBS = totalWBS + 1;
                        } else if (ef.Channel__c == 'FCCS') {
                            totalFARS = totalFARS + 1;
                        }
                    }
            
                    if (ef.Channel__c == 'FiNet' && ef.Inactive_FiNet__c == 'False') {
                        totalFiNet = totalFiNet + 1;
                    }
                    
                    //check for active hired efforts
                    if ((ef.Inactive__c == False && ef.Inactive_FiNet__c == 'False') && 
                    (ef.StageName == 'Hired' || ef.StageName == 'Hired-S7 Licensed' || ef.StageName == 'Graduate/Affiliate' || ef.StageName == 'RPL-4')) {
                        totalActiveHiredEfforts = totalActiveHiredEfforts + 1;
                    }
                    
                }
            }
            
            //if FA Talent has an active effort for more than one channel, set engaged to other channel to YES
            if (totalPCG + totalWBS + totalFiNet + totalFARS > 1) {
                multiChannel = 'Yes';
            }
            
            
            System.Debug('ENGAGED WITH OTHER CHANNEL: ' + multiChannel);
            System.Debug('TOTAL FINET: ' + totalFiNet);
            System.Debug('TOTAL PCG: ' + totalPCG);
            System.Debug('TOTAL WBS: ' + totalWBS);
            System.Debug('TOTAL FARS: ' + totalFARS);
            System.Debug('TOTAL Hired: ' + totalActiveHiredEfforts);
            
            FA.Engaged_With_Other_Channel__c = multiChannel;
            FA.Total_FiNet_Active_Efforts__c = totalFiNet;
            FA.Total_PCG_Active_Efforts__c = totalPCG;
            FA.Total_WBS_Active_Efforts__c = totalWBS;
            FA.Total_FARS_Active_Efforts__c = totalFARS;
            FA.Total_Active_Hired_Efforts__c = totalActiveHiredEfforts;
            
        }
            
        System.Debug('NUMBER OF RECORDS TO UPDATE: ' + faTalentsToCheck.values().size());
        
        try{
            if(faTalentsToCheck.values().size() > 0) update faTalentsToCheck.values();
            } catch(DmlException e) {  //catch errors
            for (FA_talent__c FA: faTalentsToCheck.values()) {
                throw new sfexception(' Error - FA Talent not updated: ' + e.getMessage());
            }               
            return; 
        }
        
    }
}    

/* system.debug('current effort --------- ' + ef);
            system.debug('fa talents to update ------------- ' + FATalentsToUpdate);
            
            if (!faTalentsToUpdate.containskey(ef.FA_Talent_Name__c)) {
                totalFiNet = 0;
                totalPCG = 0;
                totalWBS = 0;           
                totalFARS = 0;
                
                TotalActiveHiredEfforts = 0;
                multiChannel = 'No';
            }

            if (ef.Inactive__c == False) {
                if (ef.Channel__c == 'PCG') {
                    totalPCG = totalPCG + 1;
                } else if (ef.Channel__c == 'WBS') {
                    totalWBS = totalWBS + 1;
                } else if (ef.Channel__c == 'FCCS') {
                    totalFARS = totalFARS + 1;
                }
            }
            
            if (ef.Channel__c == 'FiNet' && ef.Inactive_FiNet__c == 'False') {
                totalFiNet = totalFiNet + 1;
            }
            
            if ((ef.Inactive__c == False && ef.Inactive_FiNet__c == 'False') && 
            (ef.StageName == 'Hired' || ef.StageName == 'Hired-S7 Licensed' || ef.StageName == 'Graduate/Affiliate' || ef.StageName == 'RPL-4')) {
                totalActiveHiredEfforts = totalActiveHiredEfforts + 1;
            }
            
            if (totalPCG + totalWBS + totalFiNet + totalFARS > 1) {
                multiChannel = 'Yes';
            }
            
            //if (!faTalentsToUpdate.containskey(ef.FA_Talent_Name__c)) {
                FA_talent__c PrevFATalent;
                if (FATalentsToUpdate.values().size() == 0) {
                    PrevFATalent = FATalentsToCheck.get(ef.FA_Talent_Name__c);
                } else {
                    PrevFATalent = FATalentsToUpdate.values()[FATalentsToUpdate.values().size() - 1];
                }
                
                
                system.debug('Current FA ---------- ' + FATalentsToCheck.get(ef.FA_Talent_Name__c));
                system.debug('Prev FA ---------- ' + PrevFATalent);
                
                
                System.Debug('ENGAGED WITH OTHER CHANNEL: ' + multiChannel);
                System.Debug('TOTAL FINET: ' + totalFiNet);
                System.Debug('TOTAL PCG: ' + totalPCG);
                System.Debug('TOTAL WBS: ' + totalWBS);
                System.Debug('TOTAL FARS: ' + totalFARS);
                System.Debug('TOTAL Hired: ' + totalActiveHiredEfforts);
                
                FA_Talent__c updateFA = new FA_Talent__c(Id = PrevFATalent.id,
                                                  Engaged_With_Other_Channel__c = multiChannel,
                                                  Total_FiNet_Active_Efforts__c = totalFiNet,
                                                  Total_PCG_Active_Efforts__c = totalPCG,
                                                  Total_WBS_Active_Efforts__c = totalWBS,
                                                  Total_FARS_Active_Efforts__c = totalFARS,
                                                  Total_Active_Hired_Efforts__c = totalActiveHiredEfforts
                                                  );
                
                //map of FA Talents that need to be updated with efforts metrics                                      
                FATalentsToUpdate.put(PrevFATalent.id,updateFA);
                

           // }*/







      /*  for(Integer colIndexT=0; colIndexT<faTalents.size(); colIndexT++){ //loop through queried fa talents
            
            System.Debug('FA TALENT ID: ' + faTalents[colIndexT].Id);
            
            integer totalFiNet = 0;
            integer totalPCG = 0;
            integer totalWBS = 0;           
            integer totalFARS = 0;
            
            integer totalActiveHiredEfforts = 0;
            
            string multiChannel = 'No';
            string currentChannel;            
            
            for(Integer colIndexE=0; colIndexE<efforts.size(); colIndexE++){ //loop through queried efforts
               
                //perform multichannel engagement check
                //01250000000UISQAA4 = finet effort record type
                if(faTalents[colIndexT].Id == efforts[colIndexE].FA_Talent_Name__c && efforts[colIndexE].RecordTypeID != '01250000000UISQAA4' && efforts[colIndexE].Inactive__c == false || faTalents[colIndexT].Id == efforts[colIndexE].FA_Talent_Name__c && efforts[colIndexE].RecordTypeID == '01250000000UISQAA4' && efforts[colIndexE].Inactive_FiNet__c == 'False'){
                    
                    System.Debug('EFFORT ID: ' + efforts[colIndexE].Id); 
                    System.Debug('CURRENT CHANNEL BEFORE IF: ' + currentChannel);
                    System.Debug('OPPTY CHANNEL BEFORE IF: ' + efforts[colIndexE].Channel__c);
                    
                    if(currentChannel == NULL){
                        currentChannel = efforts[colIndexE].Channel__c;
                    } else if(currentChannel != efforts[colIndexE].Channel__c){
                        multiChannel = 'Yes';   

                    } //end of multi channel check if                                                  
                //} //end fa talent - effort id if  
                
                //perform active channel check  
                //if(faTalents[colIndexT].Id == efforts[colIndexE].FA_Talent_Name__c && efforts[colIndexE].RecordTypeID != '01250000000UISQAA4' && efforts[colIndexE].Inactive__c == false || faTalents[colIndexT].Id == efforts[colIndexE].FA_Talent_Name__c && efforts[colIndexE].RecordTypeID == '01250000000UISQAA4' && efforts[colIndexE].Inactive_FiNet__c == 'False'){              
                    System.Debug('CHANNEL COUNT: ' + efforts[colIndexE].Channel__c);
                
                    System.Debug('PCG COUNT EFFORT INDEX: ' + efforts[colIndexE].Channel__c);
                    System.Debug('PCG COUNT BEFORE: ' + totalPCG);
                
                    if(efforts[colIndexE].Channel__c == 'FiNet'){
                        totalFiNet = totalFiNet + 1;
                    } else if(efforts[colIndexE].Channel__c == 'PCG'){
                        totalPCG = totalPCG + 1;
                        System.Debug('PCG COUNT IN IF: ' + totalPCG);
                    } else if(efforts[colIndexE].Channel__c == 'WBS'){
                        totalWBS = totalWBS + 1;
                    } else if(efforts[colIndexE].Channel__c == 'FCCS'){
                        totalFARS = totalFARS + 1;
                    }
                    
                    if(efforts[colIndexE].StageName == 'Hired' || efforts[colIndexE].StageName == 'RPL-4'  ){ //calculate total active hired efforts
                        totalActiveHiredEfforts = totalActiveHiredEfforts + 1;
                    }
                    
                    
                } //end fa talent - effort id if 
                                         
            } //end of effort loop
            
            FA_Talent__c updateFAT = new FA_Talent__c(Id = faTalents[colIndexT].Id,
                                                      Engaged_With_Other_Channel__c = multiChannel,
                                                      Total_FiNet_Active_Efforts__c = totalFiNet,
                                                      Total_PCG_Active_Efforts__c = totalPCG,
                                                      Total_WBS_Active_Efforts__c = totalWBS,
                                                      Total_FARS_Active_Efforts__c = totalFARS,
                                                      Total_Active_Hired_Efforts__c = totalActiveHiredEfforts
                                                      );

            faTalentToUpdate.add(updateFAT);        
            
            System.Debug('ENGAGED WITH OTHER CHANNEL: ' + multiChannel);
            System.Debug('TOTAL FINET: ' + totalFiNet);
            System.Debug('TOTAL PCG: ' + totalPCG);
            System.Debug('TOTAL WBS: ' + totalWBS);
            System.Debug('TOTAL FARS: ' + totalFARS);
            System.Debug('TOTAL Hired: ' + totalActiveHiredEfforts);
                            
        } //end of fa talent loop
        
        System.Debug('NUMBER OF RECORDS TO UPDATE: ' + faTalentToUpdate.size());
        
        try{
            if(faTalentToUpdate.size() > 0) update faTalentToUpdate;
            } catch(DmlException e) {  //catch errors
            for (Opportunity opp : opptysToProcess) {
                opp.addError(' Error - FA Talent not updated: ' + e.getMessage());
            }               
            return; 
        }

    } //end of method

}*/