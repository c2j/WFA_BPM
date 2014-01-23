public with sharing class LeadSourceToEffortUpdate {

    public static void ProcessEffortUpdate(Set<ID> EffortIDs) { //List<Lead_Source__c> leadSourceToProcess){
    
        //populate active lead source related effort (oppty) with designated lead source data
    
        //get lead sources related oppty ids
        //Set<Id> opptyIDs = new Set<Id>();
        
        //for (Lead_Source__c oid : leadSourceToProcess) {
        //    opptyIDs.add(oid.Effort__c);
        //}
        
        Integer ActvStrCrsMktLdSrcs = 0;
        Boolean FirstActiveLS = True;
        String PrevEffortID;
        
        //Map of effort records related to the affected lead sources
        Map<ID, Opportunity> EffortsToProcess = new Map<ID, Opportunity>(
        [Select Id, Lead_Source__c, Lead_Accepted_Date__c, Lead_Declined_Date__c, 
        Lead_Declined_Reason__c, Recruiter_Firm_Name__c, Lead_Expired_Date__c,of_Active_Strategic_Cross_Mkt_Leads__c, Channel__c 
        From Opportunity where Id in:EffortIDs]);

        system.debug('Efforts ------------------ ' + EffortsToProcess);
        
        //List<Opportunity> EffortsToUpdate = new list<Opportunity>(); //list of effort records to be updated
        
        //map of inserted or updated lead sources sorted by effort id then lead accepted date, oldest to newest
        List<Lead_Source__c> leadSourceToProcess = [SELECT Lead_Source__c, Associate_Channel__c, Lead_Accepted_Date__c, 
        External_Recruiter_Firm_Name__c, Inactive__c, Effort__c FROM Lead_Source__c WHERE
        Effort__c IN : EffortIDs ORDER BY Effort__c DESC, Inactive__c  ASC, Lead_Accepted_Date__c ASC];
        
        
        if (leadSourceToProcess.size() > 0) {
            
            system.debug('Lead Sources ------------------ ' + leadSourceToProcess);    
            PrevEffortID = leadSourceToProcess[0].effort__c;

            for (integer l = 0; l < leadSourceToProcess.size(); l++) {//loop through all lead sources related to affected efforts
               
               system.debug('current lead source ------------ ' + leadSourceToProcess[l]);
               system.debug('Lead count ------------- ' + l);
               system.debug('Prev Effort ID ----------- ' + PrevEffortID);
                
               if (l == 0) {
                   FirstActiveLS = True;
               } else{
                   if (leadSourceToProcess[l].effort__c != PrevEffortID) {//current lead source belongs to a different effort
                       ActvStrCrsMktLdSrcs = 0; //reset the count of active strategic cross mkt lead sources
                       FirstActiveLS = True; //the next lead source will the the first accepted one for a new effort
                   } else {

                       FirstActiveLS = False; //next lead source still related to same effort, it must not be the first lead source accepted
                   } 
               }
               
               system.debug('First Active LS? ------------ ' + FirstActiveLS);
                   
                //check if lead source is an active strategic cross market lead source
                if (leadSourceToProcess[l].Lead_Accepted_Date__c != NULL && leadSourceToProcess[l].Inactive__c == False &&
                ((leadSourceToProcess[l].Lead_Source__c == 'Strategic Cross-Market Referral') ||
                (leadSourceToProcess[l].Lead_Source__c == 'Talent Scout' && EffortsToProcess.get(LeadSourceToProcess[l].effort__c).channel__c == 'PCG' && 
                leadSourceToProcess[l].Associate_Channel__c == 'FiNet'))) {
                   
                    ActvStrCrsMktLdSrcs = 1;
               
                } 
                
                system.debug('Active Strat Cross Mkt ------------------ ' + ActvStrCrsMktLdSrcs);
                EffortsToProcess.get(LeadSourceToProcess[l].effort__c).of_Active_Strategic_Cross_Mkt_Leads__c = ActvStrCrsMktLdSrcs;
                
              
                if (leadSourceToProcess[l].Inactive__c == False && FirstActiveLS) {//only update the effort with information from the first accepted active lead source
                    
                    system.debug('first active LS for effort ------------- ' + leadsourcetoprocess[l]); 
                    
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Lead_Source__c = leadSourceToProcess[l].Lead_Source__c;
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Lead_Accepted_Date__c = leadSourceToProcess[l].Lead_Accepted_Date__c;
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Recruiter_Firm_Name__c = leadSourceToProcess[l].External_Recruiter_Firm_Name__c;    
                
                } else if (leadSourceToProcess[l].Inactive__c == True && FirstActiveLS) {
                    
                    system.debug('Inactive LS for effort ------------- ' + leadsourcetoprocess[l]); 
                    
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Lead_Source__c = null;
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Lead_Accepted_Date__c = null;
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Recruiter_Firm_Name__c = null;    
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Lead_Declined_Date__c = null;                    
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Lead_Expired_Date__c = null;    
                    EffortsToProcess.get(LeadSourceToProcess[l].effort__c).Lead_Declined_Reason__c = null;                  
                }
                

                PrevEffortID = leadSourceToProcess[l].effort__c; //store the current lead source's effort id  
                //leadSourceToProcess.remove(l); //remove the current lead source once it has been processed
            
            }
            
            try{
                if(EffortsToProcess.values().size() > 0) update EffortsToProcess.values();
            } catch(DmlException e) {  //catch errors
                for (Lead_Source__c ls : leadSourceToProcess) {
                    throw new SFException('Error - Effort not updated: ' + e.getMessage() + ': Contact your administrator');
                }               
                return;
            }       
        }
        
        
        //query related opptys fields that will be updated
        /*List<Opportunity> opptyData = [Select Id, Lead_Source__c, Lead_Accepted_Date__c, Lead_Declined_Date__c, 
        Lead_Declined_Reason__c, Recruiter_Firm_Name__c, Lead_Expired_Date__c,of_Active_Strategic_Cross_Mkt_Leads__c, Channel__c 
        From Opportunity where Id in:EffortIDs];
        List<Opportunity> opptyToUpdate = new List<Opportunity>();
        
        for (Integer i = 0; i < leadSourceToProcess.size(); i++) { //loop through passed lead source records
            for(Integer colIndex=0; colIndex<opptyData.size(); colIndex++) { //loop through related opptys
                
                ActvStrCrsMktLdSrcs = 0;
                
                if(opptyData[colIndex].Id == leadSourceToProcess[i].Effort__c && leadSourceToProcess[i].Inactive__c == false){ //update effort lead source fields if lead source is active
                    
                    if (leadSourceToProcess[i].Lead_Accepted_Date__c != NULL && ((leadSourceToProcess[i].Lead_Source__c == 'Strategic Cross-Market Referral') ||
                    (leadSourceToProcess[i].Lead_Source__c == 'Talent Scout' && opptyData[colIndex].channel__c == 'PCG' && leadSourceToProcess[i].Associate_Channel__c == 'FiNet'))) {
                        ActvStrCrsMktLdSrcs = 1;
                    }
                    
                    opportunity updateOppty = new opportunity(Id = opptyData[colIndex].Id, 
                                                                   Lead_Source__c = leadSourceToProcess[i].Lead_Source__c,
                                                                   Lead_Accepted_Date__c = leadSourceToProcess[i].Lead_Accepted_Date__c,
                                                                   Lead_Declined_Date__c = leadSourceToProcess[i].Lead_Declined_Date__c,
                                                                   Recruiter_Firm_Name__c = leadSourceToProcess[i].External_Recruiter_Firm_Name__c,
                                                                   Lead_Expired_Date__c = leadSourceToProcess[i].Lead_Expired_Date__c,
                                                                   Lead_Declined_Reason__c = leadSourceToProcess[i].Lead_Declined_Reason__c,                                                        
                                                                   of_Active_Strategic_Cross_Mkt_Leads__c = ActvStrCrsMktLdSrcs
                                                                   );
                
                    System.Debug('LEAD SOURCE UPDATE: ' + leadSourceToProcess[i].Lead_Source__c);
                    System.Debug('RECRUITER FIRM UPDATE: ' + leadSourceToProcess[i].External_Recruiter_Firm_Name__r.Id);
                
                    opptyToUpdate.add(updateOppty);
                } else if(opptyData[colIndex].Id == leadSourceToProcess[i].Effort__c && leadSourceToProcess[i].Inactive__c == true){ //null out effort lead source fields if lead source is deactivated
                    
                    ActvStrCrsMktLdSrcs = 0;
                    
                    opportunity updateOppty = new opportunity(Id = opptyData[colIndex].Id, 
                                                                   Lead_Source__c = null,
                                                                   Lead_Accepted_Date__c = null,
                                                                   Lead_Declined_Date__c = null,
                                                                   Recruiter_Firm_Name__c = null,
                                                                   Lead_Expired_Date__c = null,
                                                                   Lead_Declined_Reason__c = null,
                                                                   of_Active_Strategic_Cross_Mkt_Leads__c = ActvStrCrsMktLdSrcs                                                      
                                                                   );
                
                    System.Debug('LEAD SOURCE UPDATE: ' + leadSourceToProcess[i].Lead_Source__c);
                    System.Debug('RECRUITER FIRM UPDATE: ' + leadSourceToProcess[i].External_Recruiter_Firm_Name__r.Id);
                
                    opptyToUpdate.add(updateOppty);
                    
                } //end of if statement  
                               
            } //end of oppty loop
        } //end of lead source loop     
        
        System.Debug('NUMBER OF OPPTYS TO UPDATE: ' + opptyToUpdate.size());
        
        try{
            if(opptyToUpdate.size() > 0) update opptyToUpdate;
            } catch(DmlException e) {  //catch errors
            for (Lead_Source__c ls : leadSourceToProcess) {
                ls.addError(' Error - Effort not updated: ' + e.getMessage());
            }               
            return;
        }*/
        
    } //end of method  
    
} //end of class