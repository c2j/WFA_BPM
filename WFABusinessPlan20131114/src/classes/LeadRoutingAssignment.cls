public class LeadRoutingAssignment {

	public static void AssignLeads(List<Lead> leadsToProcess, Set<String> zipsToProcess, Set<Id> leadIDToProcess){
	
		//build maps (virtual tables) of fa's / fa data
		Map<ID, Contact> c = new Map<ID, Contact>([Select Id, Branch_ZIP_5_Character__c, Account.Manager_Branch_Email__c, Account.Manager_Market_Complex_Email__c, Lead_Assignment_ID__c From Contact where (PCG_FA_Selection_BPs__c >= 3 or X2011_FA_Selection_BPs__c >= 3) and Terminated__c = 'No' and Branch_ZIP_5_Character__c in :zipsToProcess]); //map qualified fa's contactid with count
		Map<ID, Contact> cVar = new Map<ID, Contact>([Select Id, Branch_ZIP_5_Character__c, Account.Manager_Branch_Email__c, Account.Manager_Market_Complex_Email__c From Contact where (PCG_FA_Selection_BPs__c >= 3 or X2011_FA_Selection_BPs__c >= 3) and Terminated__c = 'No' and Branch_ZIP_5_Character__c in :zipsToProcess]); //map detailing static set of variables needed when processing the contact map
		Map<Id, List<Lead_Assignment_History__c>> mapLeadAssgnHist = new Map<Id, List<Lead_Assignment_History__c>>(); //build map containing by lead id fa's that have been assigned to the lead...used with lead reassignment logic
		//build lists containing records to process
		List<Lead> leadsToUpdate = new List<Lead>(); //build list of leads to update with assigned contact id
		List<Contact> contactsToUpdate = new List<Contact>(); //build list of contacts to update with last lead assigned date/time
		List<Lead_Assignment_History__c> lahToInsert = new List<Lead_Assignment_History__c>(); //build list of lead assignment history records to insert
		List<Lead_Assignment_History__c> lahToUpdate = new List<Lead_Assignment_History__c>(); //build list of lead assignment history records to update
		
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
		
		//integer to augment derived lead id to help ensure uniqueness
		integer idAugment = 0;
		
		System.Debug('LEAD COUNT: ' + leadsToProcess.size());
		System.Debug('FA COUNT: ' + c.size());
	
		//process leads and fa's
		// on insert: assign contact id to lead and send email
		// on update: assign contact id to lead / reset reassign flag on lead / send email
		for (Integer i = 0; i < leadsToProcess.size(); i++) { //loop through passed lead records
		
			Id ContactID;
			String branchMgrEmail;
			String marketMgrEmail;
			Decimal intCounter = -1;
			
			//build set of fa's already assigned to lead - need to know who has been assigned to lead for reassignment purposes
			Set<String> assignedFAs = new Set<String>();
			Map<Id, String> mapFAHrecIDs = new Map<Id, String>();
			
			//if(mapLeadAssgnHist.size() > 0){ //if new lead do not run - ensure that lah exists for the lead
			if(mapLeadAssgnHist.containsKey(leadsToProcess[i].Id)){ //if new lead do not run - ensure that lah exists for the lead
				for(Lead_Assignment_History__c aFA : mapLeadAssgnHist.get(leadsToProcess[i].Id)){
					assignedFAs.add(aFA.Assigned_FA__c); //build set of assigned FA's for this lead
					
					mapFAHrecIDs.put(aFA.Assigned_FA__c, aFA.Id); //build a map of contacts and their associated lah records for this lead
				}
			}
			
			for(Contact cont : c.values()){ //loop through contact (fa's) map
				
				//System.Debug('INT COUNTER: ' + intCounter);
				//System.Debug('COUNTER BEFORE LOOP: ' + cont.Lead_Assignment_ID__c);
				//System.Debug('CONT BEFORE CONT IF: ' + cont);
				
				if(assignedFAs.contains(cont.Id) == FALSE){ //only include fa's that have not already been assigned to the lead
					if(leadsToProcess[i].Closest_Branch_ZIP_5_Character__c == cVar.get(cont.id).Branch_ZIP_5_Character__c && (cont.Lead_Assignment_ID__c == null || intCounter == -1 || cont.Lead_Assignment_ID__c < intCounter)){
									
						ContactId = cont.Id;
						branchMgrEmail = cVar.get(cont.id).Account.Manager_Branch_Email__c;
						marketMgrEmail = cVar.get(cont.id).Account.Manager_Market_Complex_Email__c;
						
						if(cont.Lead_Assignment_ID__c == NULL){
							intCounter = 0;
						} else{
							intCounter = cont.Lead_Assignment_ID__c;
						}
		
						//System.Debug('CONTACT ID IN LOOP: ' + ContactId);
						//System.Debug('CONTACT ZIP: ' + zip);
						//System.Debug('COUNTER AFTER IF IN LOOP: ' + intCounter);				
					} //end of zip check if	
				} // end of assignedFA check if		
			} //end of fa for map loop			
			
			//System.Debug('CONTACT ID OUT LOOP: ' + ContactId);
			System.Debug('COUNTER AFTER LOOP: ' + intCounter);
			
			//fa was not processed due to each fa was assigned the lead
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
				
				//System.Debug('COUNTER ADDED TO MAP: ' + ContactId + ' - ' + newCont.Lead_Assignment_ID__c);
				
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
					
					Lead_Assignment_History__c updateLAH = new Lead_Assignment_History__c(Id = mapFAHrecIDs.get(leadsToProcess[i].Assigned_FA__c),
																		Reason_for_Reassignment__c = leadsToProcess[i].Reason_for_Reassignment__c
																	  );	
					lahToUpdate.add(updateLAH);	
				}				
								
			} //end of contact map if
		} //end of lead processing loop
		
		//System.Debug('FA COUNT AFTER: ' + c.size());
		
		//loop through map and add id's where counter is > 0 - set contact counter
		for(Contact cont : c.values()){ 
			contact updateContact = new contact(Id = cont.id, 
								   Lead_Assignment_ID__c = cont.Lead_Assignment_ID__c													   
								   );
			
			//System.Debug('UPDATE CONTACT: ' + updateContact);
								   
			contactsToUpdate.add(updateContact);					 
		}
	
		//System.Debug('CONTACTS TO UPDATE: ' + contactsToUpdate.size());
		 
		//update contacts
		try{
			if(contactsToUpdate.size() > 0){ update contactsToUpdate;}
			} catch(DmlException e) {  //catch errors
   			for (Lead leadrecContact : leadsToProcess) {
            	leadrecContact.addError('Error - Contact not updated: ' + e.getMessage());
     		}   			
			return;
		}		
		
		//update leads
		try{
			if(leadsToUpdate.size() > 0) update leadsToUpdate;
			} catch(DmlException e) {  //catch errors
   			for (Lead leadrecLead : leadsToProcess) {
            	leadrecLead.addError('Error - Lead not updated: ' + e.getMessage());
     		}   			
			return;
		}	
		
		System.Debug('LAH TO INSERT: ' + lahToInsert.size());
		
		//insert lead assignment history
		try{
			if(lahToInsert.size() > 0) insert lahToInsert;
			} catch(DmlException e) {  //catch errors
   			for (Lead leadrecLAH : leadsToProcess) {
            	leadrecLAH.addError('Error - Lead Assignment History not inserted: ' + e.getMessage());
     		}   			
			return;
		}	
		
		System.Debug('LAH TO UPDATE: ' + lahToUpdate.size());
		
		//update lead assignment history
		try{
			if(lahToUpdate.size() > 0) update lahToUpdate;
			} catch(DmlException e) {  //catch errors
   			for (Lead leadrecLAHid : leadsToProcess) {
            	leadrecLAHid.addError('Error - Lead Assignment History not updated: ' + e.getMessage());
     		}   			
			return;
		}	
		
	} //end of method

} //end of class