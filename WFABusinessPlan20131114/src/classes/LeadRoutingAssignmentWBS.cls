public with sharing class LeadRoutingAssignmentWBS {

public static geopointe.API.radialSearchResult resultRadialSearch;

public static void AssignLeadsWBS(List<Lead> leadsToProcess, Set<Id> leadIDToProcess, Set<String> auIDToProcess){

        //map to represent all fa's that belong to a store with an auid
        Map<ID, WBS_Store_Member__c> auidFA = new Map<ID, WBS_Store_Member__c>([Select Id, FA_Name__r.Id, Store_AU_ID__c, FA_Name__r.Lead_Assignment_ID__c, RBM_Email_Address__c From WBS_Store_Member__c where WBS_Store__r.Store_AU__c in :auIDToProcess]);
        System.Debug('auidFA COUNT: ' + auidFA.size());
        
        //map to represent all fa's used in the processing of fa's returned by the radius search
        Map<ID, WBS_Store_Member__c> allQualFA = new Map<ID, WBS_Store_Member__c>([Select Id, FA_Name__r.Id, Store_AU_ID__c, FA_Name__r.Lead_Assignment_ID__c, RBM_Email_Address__c From WBS_Store_Member__c]);
        System.Debug('allQualFA COUNT: ' + allQualFA.size());                                   
                                
        //create map of contact ids relative to their leadassignment id - need to remove potential for duplicate contacts that can occur with allQualFA map
        Map<ID, Decimal> mapContactIdLeadAsngId = new Map<ID, Decimal>();
        for(ID id : allQualFA.keySet()){
            mapContactIdLeadAsngId.put(allQualFA.get(id).FA_Name__r.Id, allQualFA.get(id).FA_Name__r.Lead_Assignment_ID__c);
        }
        
        //get unique set of contact ids from the store contactid/leadassignmentid map
        Set<Id> setContactIds = new Set<Id>();
        for(Id contId : mapContactIdLeadAsngId.keySet()){
            setContactIds.add(contId);
        }
        System.Debug('CONTACT ID SET: ' + setContactIds.size());
        
        //build map of unique contacts with their lead processing id to base the contact/leadprocessingid processing off of
        Map<String, Decimal> contactMap = new Map<String, Decimal>();
        for (ID Id : setContactIds){
            contactMap.put(id, mapContactIdLeadAsngId.get(id));
        }
        System.Debug('CONTACT MAP: ' + contactMap.size());      
        
        //build lists containing records to process
        List<WBS_Store_Member__c> wbsAUIDs = new List<WBS_Store_Member__c>([Select Store_AU_ID__c from WBS_Store_Member__c where WBS_Store__r.Store_AU__c in :auIDToProcess]); //depricate?
        List<Lead> leadsToUpdate = new List<Lead>(); //build list of leads to update with assigned contact id
        List<Contact> contactsToUpdate = new List<Contact>(); //build list of contacts to update with last lead assigned date/time
        List<Lead_Assignment_History__c> lahToInsert = new List<Lead_Assignment_History__c>(); //build list of lead assignment history records to insert
        List<Lead_Assignment_History__c> lahToUpdate = new List<Lead_Assignment_History__c>(); //build list of lead assignment history records to update
        
        Set<String> contactIDs = new Set<String>();
        Set<String> faAUIDs = new Set<String>();  //depricate?
        
        for(WBS_Store_Member__c fasm : wbsAUIDs){ //depricate?
            faAUIDs.add(fasm.Store_AU_ID__c);
        }       

        //build map detailing by lead id the fa's that have been assigned to a lead 
        //build map containing by lead id fa's that have been assigned to the lead...used with lead reassignment logic                      
        Map<Id, List<Lead_Assignment_History__c>> mapLeadAssgnHist = new Map<Id, List<Lead_Assignment_History__c>>();
            
        Id currLeadID = null;
        
        Double faInRadiusReturned;
        Boolean assignedAllFAs;
        Boolean noFAInSearchRadius;
        
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
        
        Integer x = 0;
        Integer y = 0;
        Integer z = 0;
                        
        //=================================================
        
        Decimal intCounter;
        
        //integer to augment derived lead id to help ensure uniqueness
        integer idAugment = 0;
        
        System.Debug('LEAD COUNT: ' + leadsToProcess.size());
        System.Debug('FA COUNT: ' + allQualFA.size());
    
        //process leads and fa's
        // on insert: assign contact id to lead and send email (workflow manages email)
        // on update: assign contact id to lead / reset reassign flag on lead / send email (workflow manages email setting of reassign flag)
        for (Integer i = 0; i < leadsToProcess.size(); i++) { //loop through passed lead records
        
            Id ContactId;
            String rbmMgrEmail;            
            String leadStoreAUID = leadsToProcess[i].Store_of_Patronage_ID__c;
            faInRadiusReturned = null;
            
            intCounter = -1;
            
            //build set of fa's already assigned to lead - need to know who has been assigned to lead for reassignment purposes
            Set<String> assignedFAs = new Set<String>();
            Map<Id, String> mapFAHrecIDs = new Map<Id, String>();
            
            if(mapLeadAssgnHist.containsKey(leadsToProcess[i].Id)){ //if new lead do not run - ensure that lah exists for the lead
                for(Lead_Assignment_History__c aFA : mapLeadAssgnHist.get(leadsToProcess[i].Id)){
                    assignedFAs.add(aFA.Assigned_FA__c); //build set of assigned FA's for this lead
                    
                    mapFAHrecIDs.put(aFA.Assigned_FA__c, aFA.Id); //build a map of contacts and their associated lah records for this lead
                }
            }
            
            //arrowpointe api call - assumes address is at lead and has been geocoded    
            if(!test.isRunningTest()){  //staging geopointe function in test class
                resultRadialSearch = geopointe.API.radialSearchMapObject(
                     leadsToProcess[i].Id,
                     'WBS_Store_Member__c',
                     '',
                     100,
                     geopointe.API.units.MILES);
            }

            System.Debug('RADIALSEARCHRESULTS: ' + resultRadialSearch.recordCount);
            
            faInRadiusReturned = resultRadialSearch.recordCount;
                 
            List<String> faInRange = new List<String>(resultRadialSearch.recordsInDistanceOrder); //sorted list of sm closest to farthest from lead
            Map<String, Double> faInRangeMi = new Map<String, Double>(resultRadialSearch.recordsByDistance);  //unsorted map of sm with their distance
            List<String> faInFirstRadius = new List<String>();  //list to contain all fa's within first radius grouping
            List<String> faInSecondRadius = new List<String>();  //list to contain all fa's within second radius grouping
            List<String> faInThirdRadius = new List<String>();  //list to contain all fa's within third radius grouping 
            List<String> faInRadius = new List<String>();  //list of sm in radius to be evaluated

            for(String smid : faInRange){  //loop through all fa's in full radius range and assign to their respective radius groupings
                System.Debug('RADIALSEARCHRESULTSMAP: ' + smid + ' - ' + faInRangeMi.get(smid));
                
                if(faInRangeMi.get(smid) < 31 && assignedFAs.contains(allQualFA.get(smid).FA_Name__r.Id) == FALSE){
                    faInFirstRadius.add(smid);
                } else if(faInRangeMi.get(smid) >= 31 && faInRangeMi.get(smid) < 51 && assignedFAs.contains(allQualFA.get(smid).FA_Name__r.Id) == FALSE){
                    faInSecondRadius.add(smid);
                } else if(faInRangeMi.get(smid) >= 51 && faInRangeMi.get(smid) <= 100 && assignedFAs.contains(allQualFA.get(smid).FA_Name__r.Id) == FALSE){
                    faInThirdRadius.add(smid);
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

            //first loop through sm with auid
            //second loop through sm via radius method: closest to farthest
                //create 3 sets: <=30 / >=31 - 50 / >=51 - 100
                //sort 3 sets closest to farthest - list of smid's
                //loop through subsequent sets once prior set fa's have been assigned
            
            for(WBS_Store_Member__c smAUID : auidFA.values()){ //loop through contact (fa's) map who are assigned to the leads AUID         
                
                String smContactId = auidFA.get(smAUID.Id).FA_Name__r.Id;
                Decimal smLeadAssignID = contactMap.get(auidFA.get(smAUID.Id).FA_Name__r.Id);
                
                System.Debug('smContactID BEGIN smAUID LOOP: ' + smContactId);
                System.Debug('smLeadAssignID BEGIN smAUID LOOP: ' + smLeadAssignID);

                if(assignedFAs.contains(smContactId) == FALSE){ //only include fa's that have not already been assigned to the lead 

                    System.Debug('LEAD AU ID: ' + leadsToProcess[i].Store_of_Patronage_ID__c);
                    System.Debug('LEAD ASSIGN ID: ' + smLeadAssignID);
                    System.Debug('INTCOUNTER: ' + intCounter);
                    
                    //assign lead where auids match between the lead and the fa
                    if(leadsToProcess[i].Store_of_Patronage_ID__c != null && leadsToProcess[i].Store_of_Patronage_ID__c == auidFA.get(smAUID.Id).Store_AU_ID__c){
                        if(smLeadAssignID == null || intCounter == -1 || smLeadAssignID < intCounter){
                                                    
                            System.Debug('AUID CHECK INTCOUNTER: ' + intCounter);
                            System.Debug('AUID CHECK LEAD ASSIGNMENT ID: ' + smLeadAssignID);

                            ContactId = smContactId;  //NEW
                            rbmMgrEmail = auidFA.get(smAUID.Id).RBM_Email_Address__c;                       
                            
                            if(smLeadAssignID == NULL){
                                intCounter = 0;
                                
                                break;  //if fa has not been assigned a lead (no leadassignment id) then assign and stop processing fa's
                            } else {
                                intCounter = contactMap.get(ContactId);
                            }                           
                            
                            System.Debug('CONTACT ID IN LOOP AUID: ' + ContactId);
                            System.Debug('LEAD ASSIGNMENT ID IN LOOP AUID: ' + smLeadAssignID);
                            System.Debug('INTCOUNTER IN LOOP AUID: ' + intCounter);
                            
                      } //end of lead assignment id check if
                    } //end of auid check if
                } //end of assigned fa check if
            } //end of smAUID loop
            
            System.Debug('INTCOUNTER AFTER SMAUID LOOP: ' + intCounter);
                    
            if(intCounter == -1){  //if this point is reached then all of the fa's assigned to the lead auid have been processed...now process fa's returned via radius search

                for(String smRadius : faInRadius){
                    
                    System.Debug('SMRADIUS KEY: ' + smRadius);
                    
                    String smContactId = allQualFA.get(smRadius).FA_Name__r.Id;
                    Decimal smLeadAssignID = contactMap.get(allQualFA.get(smRadius).FA_Name__r.Id);
                    
                    System.Debug('smContactID BEGIN smRadius LOOP: ' + smContactId);
                    System.Debug('smLeadAssignID BEGIN smRadius LOOP: ' + smLeadAssignID);

                    if(assignedFAs.contains(smContactId) == FALSE){
                        
                        if(smLeadAssignID == null || intCounter == -1 || smLeadAssignID < intCounter){
                                
                            System.Debug('smRadius INTCOUNTER: ' + intCounter);
                            System.Debug('smRadius LEAD ASSIGNMENT ID: ' + smleadAssignID);

                            ContactId = smContactId;  //NEW
                            rbmMgrEmail = allQualFA.get(smRadius).RBM_Email_Address__c;
                            
                            if(smLeadAssignID == NULL){
                                intCounter = 0;
                                
                                break;  //if fa has not been assigned a lead (no leadassignment id) then assign and stop processing fa's.  assumes looping through geolocated fa's from closest to lead to farthest
                            } else {
                                intCounter = contactMap.get(ContactId);                             
                            }
                            
                            System.Debug('smContactID END smRadius LOOP: ' + ContactId);        
                            System.Debug('smLeadAssignID END smRadius LOOP: ' + smLeadAssignID);
                                                        
                        } //end of lead assignment id check if
                    } //end of assigned fa check if 
                } //end of smRadius loop
            } //end of smRadius check if        
        
            System.Debug('CONTACTID ID ADDED TO SET AFTER LOOP: ' + ContactId);
            
            contactIDs.add(ContactId); //add processed contactids to set - looped through when determining which contact is to be updated with their respective leadassignmentid - ADD FUNCTIONALITY TO PCG CODE
            
            System.Debug('COUNTER AFTER LOOP: ' + intCounter);
            System.Debug('CONTACTID SET SIZE AFTER LOOP: ' + contactIDs.size());
            
            //====================================================
            //END OF LEAD / CONTACT (FA) PROCESSING
            //====================================================          
            
            //fa was not processed due to each fa was assigned the lead or an fa was not returned in the radius search
            if(intCounter == -1){
                
                //add lead to collection of leads to be updated with assignment data
                lead updateLead = new lead(Id = leadsToProcess[i].Id, 
                                               Assigned_FA__c = NULL,
                                               Branch_Manager_Email__c = NULL,
                                               Prior_Assigned_FA_Email_Address__c = NULL,
                                               Prior_Assigned_FA_Name__c = NULL,
                                               Assigned_Reassigned_to_All_Branch_FA_s__c = TRUE
                                               //No_FA_Within_Search_Radius__c = noFAInSearchRadius                                                      
                                               );
                                               
                leadsToUpdate.add(updateLead);
                
                //add prior fa to collection of lead assignment records to be updated with reassignment data
                if(leadsToProcess[i].Reassign_Lead__c == TRUE){
                    
                    Lead_Assignment_History__c updateLAH = new Lead_Assignment_History__c(Id = mapFAHrecIDs.get(leadsToProcess[i].Assigned_FA__c),
                                                                        Reason_for_Reassignment__c = leadsToProcess[i].Reason_for_Reassignment__c
                                                                      );    
                    lahToUpdate.add(updateLAH); 
                }               
            }
            
            //fa was processed - remove and re-add updated contact data to map  
            if(intCounter > -1){
                
                idAugment += 1;
                                
                //remove item from map      
                contactMap.remove(ContactId);

                System.Debug('UPDATE MAP WITH: ' + ContactId + ' ' + datetime.now().getTime() + idAugment);
                
                //re-add removed map item with updated count
                contactMap.put(ContactId, datetime.now().getTime() + idAugment);
                
                //add lead to collection of leads to be updated with assignment data
                lead updateLead = new lead(Id = leadsToProcess[i].Id, 
                                               Assigned_FA__c = ContactId,
                                               Branch_Manager_Email__c = rbmMgrEmail,
                                               Prior_Assigned_FA_Email_Address__c = leadsToProcess[i].Assigned_FA_Email_Address__c,
                                               Prior_Assigned_FA_Name__c = leadsToProcess[i].Assigned_FA_Familiar_Name__c,
                                               Assigned_Reassigned_to_All_Branch_FA_s__c = FALSE
                                               //No_FA_Within_Search_Radius__c = FALSE                                                                                               
                                               );

                System.Debug('LEAD TO UPDATE - ASSIGNMENT: ' + leadsToProcess[i].Id);
                
                leadsToUpdate.add(updateLead);
                
                //add fa to collection of lead assignment records to insert related to the assigned lead
                Lead_Assignment_History__c insertLAH = new Lead_Assignment_History__c(Lead__c = leadsToProcess[i].Id,
                                                                                        Assigned_FA__c = ContactId
                                                                                        );
                
                lahToInsert.add(insertLAH);                         
                
                //add prior fa to collection of lead assignment records to be updated with reassignment data
                if(leadsToProcess[i].Reassign_Lead__c == TRUE){
                    
                    System.Debug('LEAD TO UPDATE: ' + mapFAHrecIDs.get(leadsToProcess[i].Assigned_FA__c));
                    
                    Lead_Assignment_History__c updateLAH = new Lead_Assignment_History__c(Id = mapFAHrecIDs.get(leadsToProcess[i].Assigned_FA__c),
                                                                        Reason_for_Reassignment__c = leadsToProcess[i].Reason_for_Reassignment__c
                                                                      );    
                    lahToUpdate.add(updateLAH); 
                }               
                                
            } //end of contact map if
        } //end of lead processing loop     
         
        if(intCounter != -1){  //process if lead has not been assigned to all qualified FA's
            List<String> contactsToProcess = new List<String>(ContactIds); //create list of unique contact ids from contactids set that need to be updated with leadassignmentid
            
            for(Integer n = 0; n < contactsToProcess.size(); n++){
            
                contact updateContact = new contact(Id = contactsToProcess.get(n), 
                                       Lead_Assignment_ID__c = contactMap.get(contactsToProcess.get(n))                                                    
                                       );
                
                System.Debug('UPDATE CONTACT: ' + updateContact);
                                       
                contactsToUpdate.add(updateContact);                     
            }                           
        } 
         
         
        //update contacts
        System.Debug('CONTACTS TO UPDATE: ' + contactsToUpdate.size());
        try{
            if(contactsToUpdate.size() > 0){ update contactsToUpdate;}
            } catch(DmlException e) {  //catch errors
            for (Lead leadrecContact : leadsToProcess) {
                leadrecContact.addError(' Contact not updated: ' + e.getMessage());
            }               
            return;
        }       
        
        //update leads
        System.Debug('LEADS TO UPDATE: ' + leadsToUpdate.size());
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