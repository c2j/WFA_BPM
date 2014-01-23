public with sharing class LeadRoutingAssignmentPCG {
    
public static geopointe.API.radialSearchResult resultRadialSearch;

public static void AssignLeadsPCG(List<Lead> leadsToProcess, Set<Id> leadIDToProcess){
    
        //build maps (virtual tables) of fa's / fa data
        Map<ID, Contact> c = new Map<ID, Contact>([Select Id, Account.Manager_Branch_Email__c, Account.Manager_Market_Complex_Email__c, Lead_Assignment_ID__c From Contact where Max_PCG_FA_Selection_BPs__c >= 3 and Terminated__c = 'No' and Channel__c = 'PCG']); // Max_PCG_FA_Selection_BPs__c >= 3 and    map qualified fa's contactid with count
        Map<ID, Contact> cVar = new Map<ID, Contact>([Select Id, Account.Manager_Branch_Email__c, Account.Manager_Market_Complex_Email__c From Contact where Max_PCG_FA_Selection_BPs__c >= 3 and Terminated__c = 'No' and Channel__c = 'PCG']); //map detailing static set of variables needed when processing the contact map - variables cannot be re-added to c map (computed data from related account)
        Map<ID, List<Lead_Assignment_History__c>> mapLeadAssgnHist = new Map<Id, List<Lead_Assignment_History__c>>(); //build map containing by lead id fa's that have been assigned to the lead...used with lead reassignment logic
        
        System.Debug('\n\nC VALUES: ' + c);
        
        //build lists containing records to process
        List<Lead> leadsToUpdate = new List<Lead>(); //build list of leads to update with assigned contact id
        List<Contact> contactsToUpdate = new List<Contact>(); //build list of contacts to update with last lead assigned date/time
        List<Lead_Assignment_History__c> lahToInsert = new List<Lead_Assignment_History__c>(); //build list of lead assignment history records to insert
        List<Lead_Assignment_History__c> lahToUpdate = new List<Lead_Assignment_History__c>(); //build list of lead assignment history records to update
        
        //set containing ids of contacts to be updated with a new lead assignment id
        Set<String> contactIDs = new Set<String>();
        
        Double faInRadiusReturned;
        Boolean assignedAllFAs;
        Boolean noFAInSearchRadius;
              
        Integer x = 0;
        Integer y = 0;
        Integer z = 0;
                        
        //build map detailing by lead id the fa's that have been assigned to a lead     
        Id currLeadID = null;
        
        List<Lead_Assignment_History__c> lahAllFAid = new List<Lead_Assignment_History__c>();
        
        for(Lead_Assignment_History__c lahRec : [Select Lead__c, Assigned_FA__c, Id From Lead_Assignment_History__c where Lead__c in :leadIDToProcess order by Lead__c]){
            
            if(currLeadId == null){
                currLeadId = lahRec.Lead__c;
            }
            
            if(currLeadID != lahRec.Lead__c && lahAllFAid.size() > 0){
                mapLeadAssgnHist.put(currLeadId, lahAllFAid);
                
                lahAllFAid = new List<Lead_Assignment_History__c>(); //clear list
                
            }
            
            lahAllFAid.add(lahRec);
            currLeadId = lahRec.Lead__c;
            
        } //end of lahRec loop
        
        if(lahAllFAid.size() > 0){
            mapLeadAssgnHist.put(currLeadId, lahAllFAid);
        }
        //end of lah map building logic
        
        Decimal intCounter;
        
        //integer to augment derived lead id to help ensure uniqueness
        integer idAugment = 0;
        
        System.Debug('LEAD COUNT: ' + leadsToProcess.size());
        System.Debug('FA COUNT: ' + c.size());
    
        //process leads and fa's
        // on insert: assign contact id (fa) to lead and send email (workflow manages email)
        // on update: assign contact id (fa) to lead / reset reassign flag on lead / send email (workflow manages email setting of reassign flag)
        for (Integer i = 0; i < leadsToProcess.size(); i++) { //loop through passed lead records
        
            Id ContactID;
            String branchMgrEmail;
            String marketMgrEmail;
            intCounter = -1;
            faInRadiusReturned = null;
            
            //build set of fa's already assigned to lead - need to know who has been assigned to lead for reassignment purposes
            Set<String> assignedFAs = new Set<String>();
            Map<Id, String> mapFAHrecIDs = new Map<Id, String>();
            
            //if new lead do not run - ensure that lah exists for the lead
            if(mapLeadAssgnHist.containsKey(leadsToProcess[i].Id)){ //if new lead do not run - ensure that lah exists for the lead
                for(Lead_Assignment_History__c aFA : mapLeadAssgnHist.get(leadsToProcess[i].Id)){
                    assignedFAs.add(aFA.Assigned_FA__c); //build set of assigned FA's for this lead
                    
                    mapFAHrecIDs.put(aFA.Assigned_FA__c, aFA.Id); //build a map of contacts and their associated lah records for this lead
                }
            }
            
            System.Debug('LEAD FA HISTORY: ' + mapFAHrecIDs);
            
            //arrowpointe api call - assumes address is at lead and has been geocoded         
            if(!test.isRunningTest()){  //staging geopointe function in test class
                resultRadialSearch = geopointe.API.radialSearchMapObject(
                     leadsToProcess[i].Id,
                     'Contact',
                     'Max_PCG_FA_Selection_BPs__c >= 3 and Channel__c = \'PCG\' and Terminated__c = \'No\'',                  
                     100,
                     geopointe.API.units.MILES);
            }
            System.Debug('RADIALSEARCHRESULTSCOUNT: ' + resultRadialSearch.recordCount);
            
            //faInRadiusReturned = resultRadialSearch.recordCount;
            //if faInRadiusReturned == 0 then break;
                 
            List<String> faInRange = new List<String>(resultRadialSearch.recordsInDistanceOrder); //sorted list of sm closest to farthest from lead
            Map<String, Double> faInRangeMi = new Map<String, Double>(resultRadialSearch.recordsByDistance);  //unsorted map of sm with their distance
            List<String> faInFirstRadius = new List<String>();  //list to contain all fa's within first radius grouping
            List<String> faInSecondRadius = new List<String>();  //list to contain all fa's within second radius grouping
            List<String> faInThirdRadius = new List<String>();  //list to contain all fa's within third radius grouping         
            List<String> faInRadius = new List<String>();  //list of sm in radius to be evaluated

            System.Debug('faInRange COUNT: ' + faInRange.size());

            for(String cid : faInRange){  //loop through all fa's in full radius range and assign to their respective radius groupings
                System.Debug('FAINRANGELOOP: ' + cid + ' - ' + faInRangeMi.get(cid));
                  
                System.Debug('\n\n********C: ' + c);  
                System.Debug('ASSIGNED FA ' + assignedFAs); 
                          
                if(faInRangeMi.get(cid) < 31 && assignedFAs.contains(c.get(cid).Id) == FALSE){
                    faInFirstRadius.add(cid);                   
                } else if(faInRangeMi.get(cid) >= 31 && faInRangeMi.get(cid) < 51 && assignedFAs.contains(c.get(cid).Id) == FALSE){
                    faInSecondRadius.add(cid);
                } else if(faInRangeMi.get(cid) >= 51 && faInRangeMi.get(cid) <= 100 && assignedFAs.contains(c.get(cid).Id) == FALSE){
                    faInThirdRadius.add(cid);
                }  
         
            }
            
            //build list of fa's to iterate through for round robin assignment code.  exhaust first radius grouping before proceeding to the second...etc.
            if(!faInFirstRadius.isEmpty()){         
                faInRadius.addAll(faInFirstRadius);  //0-30
                System.Debug('faInFirstRadius COUNT: ' + faInRadius.size());
            } else if(!faInSecondRadius.isEmpty() && faInFirstRadius.isEmpty()){                
                faInRadius.addAll(faInSecondRadius);  //31-50
                System.Debug('faInSecondRadius COUNT: ' + faInRadius.size());
            } else if(!faInThirdRadius.isEmpty() && faInSecondRadius.isEmpty()){                
                faInRadius.addAll(faInThirdRadius);  //51-100
                System.Debug('faInThirdRadius COUNT: ' + faInRadius.size());
            }

            System.Debug('faInRadius COUNT: ' + faInRadius.size());
            faInRadiusReturned = faInRadius.size();

            for(String cont : faInRadius){ //loop through contact (fa's) radius list
                
                if(assignedFAs.contains(cont) == FALSE){ //only include fa's that have not already been assigned to the lead
                    if(c.get(cont).Lead_Assignment_ID__c == null || intCounter == -1 || c.get(cont).Lead_Assignment_ID__c < intCounter){
                                    
                        ContactId = c.get(cont).Id;
                        branchMgrEmail = cVar.get(cont).Account.Manager_Branch_Email__c;
                        marketMgrEmail = cVar.get(cont).Account.Manager_Market_Complex_Email__c;
                        
                        if(c.get(cont).Lead_Assignment_ID__c == NULL){
                            intCounter = 0;
                            
                            break; //if fa has not been assigned a lead (no leadassignment id) then assign and stop processing fa's
                        } else{
                            intCounter = c.get(cont).Lead_Assignment_ID__c;
                        }
        
                        System.Debug('LEAD ASSIGNMENT ID IN LOOP: ' + c.get(cont).Lead_Assignment_ID__c);
       
                    } //end of zip check if 
                } // end of assignedFA check if     
            } //end of fa for map loop          
            
            contactIDs.add(ContactId); //add processed contactids to set - looped through when determining which contact is to be updated with their respective leadassignmentid
            
            System.Debug('CONTACT ID OUT LOOP: ' + ContactId);
            System.Debug('COUNTER AFTER LOOP: ' + intCounter);
            
            //fa was not processed due to each fa was assigned the lead or an fa was not returned in the radius search
            if(intCounter == -1){
                
                //add lead to collection of leads to be updated with assignment data
                lead updateLead = new lead(Id = leadsToProcess[i].Id, 
                                               Assigned_FA__c = NULL,
                                               Branch_Manager_Email__c = NULL,
                                               Market_Manager_Email__c = NULL,
                                               Prior_Assigned_FA_Email_Address__c = NULL,
                                               Prior_Assigned_FA_Name__c = NULL,
                                               Assigned_Reassigned_to_All_Branch_FA_s__c = TRUE
                                               );
                                               
                leadsToUpdate.add(updateLead);              
            }
            
            //fa was processed - remove and re-add updated contact data to map  
            if(intCounter > -1){
                
                idAugment += 1;
                
                Contact newCont = new Contact(Id = ContactId, Lead_Assignment_ID__c = datetime.now().getTime() + idAugment);
                
                System.Debug('COUNTER ADDED TO MAP: ' + ContactId + ' - ' + newCont.Lead_Assignment_ID__c);
                
                //remove item from map      
                c.remove(ContactId);
                
                System.Debug('UPDATE MAP WITH: ' + newCont);
                
                //re-add removed map item with updated count
                c.put(newCont.Id, newCont);
                
                //add lead to collection of leads to be updated with assignment data
                lead updateLead = new lead(Id = leadsToProcess[i].Id, 
                                               Assigned_FA__c = ContactId,
                                               Branch_Manager_Email__c = branchMgrEmail,
                                               Market_Manager_Email__c = marketMgrEmail,
                                               Prior_Assigned_FA_Email_Address__c = leadsToProcess[i].Assigned_FA_Email_Address__c,
                                               Prior_Assigned_FA_Name__c = leadsToProcess[i].Assigned_FA_Familiar_Name__c,
                                               Assigned_Reassigned_to_All_Branch_FA_s__c = FALSE                                                                         
                                               );

                //System.Debug('LEAD TO UPDATE: ' + leadsToProcess[i].Id);
                
                leadsToUpdate.add(updateLead);
                
                //add fa to collection of lead assignment records to insert related to the assigned lead
                Lead_Assignment_History__c insertLAH = new Lead_Assignment_History__c(Lead__c = leadsToProcess[i].Id,
                                                                                        Assigned_FA__c = ContactId
                                                                                        );
                lahToInsert.add(insertLAH);                         
                
                //add prior fa to collection of lead assignment records to be updated with reassignment data
                if(leadsToProcess[i].Reassign_Lead__c == TRUE){
                    
                    System.Debug('LAH FA ID: ' + leadsToProcess[i].Assigned_FA__c);
                    
                    Lead_Assignment_History__c updateLAH = new Lead_Assignment_History__c(Id = mapFAHrecIDs.get(leadsToProcess[i].Assigned_FA__c),
                                                                        Reason_for_Reassignment__c = leadsToProcess[i].Reason_for_Reassignment__c
                                                                      );    
                    
                    System.Debug('UPDATE LAH: ' + updateLAH);
                    
                    lahToUpdate.add(updateLAH); 
                }               
                                
            } //end of contact map if                               
        } //end of lead processing loop

        //loop through map and add id's where counter is > 0 - set contact counter
        if(intCounter != -1){  //process if lead has not been assigned to all qualified FA's
            List<String> contactsToProcess = new List<String>(ContactIds); //create list of unique contact ids from contactids set that need to be updated with leadassignmentid

            for(Integer n = 0; n < contactsToProcess.size(); n++){
            
                contact updateContact = new contact(Id = contactsToProcess.get(n), 
                                       Lead_Assignment_ID__c = c.get(contactsToProcess.get(n)).Lead_Assignment_ID__c                                   
                                       );
                
                System.Debug('UPDATE CONTACT: ' + updateContact);  
                                       
                contactsToUpdate.add(updateContact);                     
            }            
        }
        
        System.Debug('CONTACTS TO UPDATE: ' + contactsToUpdate.size());     
         
        //update contacts
        try{
            if(contactsToUpdate.size() > 0){ update contactsToUpdate;}
            } catch(DmlException e) {  //catch errors
            for (Lead leadrecContact : leadsToProcess) {
                leadrecContact.addError(' Contact not updated: ' + e.getMessage());
            }               
            return;
        }       
        
        //update leads
        System.Debug('LEADS TO INSERT: ' + leadsToUpdate.size());
        try{
            if(leadsToUpdate.size() > 0) update leadsToUpdate;
            } catch(DmlException e) {  //catch errors
            for (Lead leadrecLead : leadsToProcess) {
                leadrecLead.addError(' Lead not updated: ' + e.getMessage());
            }               
            return;
        }         

        //insert lead assignment history
        System.Debug('LAH TO INSERT: ' + lahToInsert.size());
        try{
            if(lahToInsert.size() > 0) insert lahToInsert;
            } catch(DmlException e) {  //catch errors
            for (Lead leadrecLAH : leadsToProcess) {
                leadrecLAH.addError(' Lead Assignment History not inserted: ' + e.getMessage());
            }               
            return;
        }   
        
        //update lead assignment history
        System.Debug('LAH TO UPDATE: ' + lahToUpdate.size());        
        try{
            if(lahToUpdate.size() > 0) update lahToUpdate;
            } catch(DmlException e) {  //catch errors
            for (Lead leadrecLAHid : leadsToProcess) {
                leadrecLAHid.addError(' Lead Assignment History not updated: ' + e.getMessage());
            }               
            return;
        }   
        
    } //end of method
} //end of class