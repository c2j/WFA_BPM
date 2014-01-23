trigger ProcessLeadAssignment on Lead (after insert, after update) {    
    
    List<Lead> toProcessPCG = new List<Lead>();  //pcg leads: already geocoded
    Set<Id> setLeadIdPCG = new Set<Id>();
    
    List<Lead> toProcessWBS = new List<Lead>();  //wbs leads: already geocoded
    Set<Id> setLeadIdWBS = new Set<Id>();
    Set<String> setAUIDWBS = new Set<String>();

    //lead must be geocoded before being passed to assignment code
    //trigger assignment off of update being lead will not be auto geocoded upon insert 
    //if lead is to be reassigned or wants offer (response do not mail = false & response no fa call = false & response want offer = true & lead geocode != null) pass to assignment code
    if(Trigger.isUpdate && Trigger.isAfter){
        for(integer i = 0; i < Trigger.new.size(); i++){            
           
            if(trigger.new[i].Remove_From_Future_Mailings__c == false && trigger.new[i].Response_No_FA_Call__c == false && trigger.new[i].geopointe__Geocode__c != NULL){  //paramaters that always need to be set for assignment/re-assignment
        		if(trigger.new[i].Response_Want_Offer__c == true && trigger.new[i].Reassign_Lead__c == true && trigger.old[i].Reassign_Lead__c == false ||  //reassign
            	   trigger.new[i].Response_Want_Offer__c == true && trigger.new[i].geopointe__Geocode__c != trigger.old[i].geopointe__Geocode__c  || //assign mass
            	   trigger.new[i].Response_Want_Offer__c == true && trigger.old[i].Response_Want_Offer__c == false){  //assign individual          
	                    if(trigger.new[i].Channel__c == 'PCG'){
	                        toProcessPCG.add(Trigger.new[i]);
	                        setLeadIdPCG.add(Trigger.new[i].Id);
	                    } else
	                    if(trigger.new[i].Channel__c == 'WBS'){
	                        toProcessWBS.add(Trigger.new[i]);
	                        setLeadIdWBS.add(Trigger.new[i].Id);
	                        setAUIDWBS.add(Trigger.new[i].Store_of_Patronage_ID__c);
	                    }
                }
            }
        }
    }
    
    System.Debug('PCG LEAD SIZE: ' + toProcessPCG.size());
    
    if(toProcessPCG.size() > 0){
        LeadRoutingAssignmentPCG.AssignLeadsPCG(toProcessPCG, setLeadIdPCG);   
    }
    
    System.Debug('WBS LEAD SIZE: ' + toProcessWBS.size());
    
    if(toProcessWBS.size() > 0){
        LeadRoutingAssignmentWBS.AssignLeadsWBS(toProcessWBS, setLeadIdWBS, setAUIDWBS);        
    }

}