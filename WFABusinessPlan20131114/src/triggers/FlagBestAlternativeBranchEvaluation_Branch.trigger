/**************************************************************************************************
 * Name: FlagBestAlternativeBranchEvaluation_Branch
 * Object: Customer
 * Purpose: Evaluate whether there is need to re-calc the Best Alternative Branch of the customer
 * Author: Keen Xu
 * Create Date: 2013-06-07
 * Modify History: 
***************************************************************************************************/
trigger FlagBestAlternativeBranchEvaluation_Branch on Account (after update) {
	if(trigger.isAfter) {
		//Store all the contact Ids that are affected by the branch change.
		Set<Id> affectedConIdSet = new Set<Id>(); 
		if(trigger.isUpdate){
			Map<Id, Account> oldMap = trigger.oldMap;
			Map<Id, Account> newMap = new Map<Id, Account>(
				[SELECT Id, Name, Branch_Close_Date__c
				, (SELECT Id, Name FROM Contacts) 
				, (SELECT Id, Name FROM Contacts__r) 
				FROM Account 
				WHERE Id in :trigger.newMap.keySet()]);
			
			
			for(Account tmpAcc : trigger.new){
				Account oldAcc = oldMap.get(tmpAcc.Id);
				Account newAcc = newMap.get(tmpAcc.Id);
				//If the branch address is updated, or branch is closed
				//1. GeoCoder will re-calcuate the geolocation, (already done by GeoPointe)
				//2. Require to re-evaluate the best alternative branch, so that the BatchToUpdateBestAlternativeBranch could pickup and recalcuate
				if(ClsBestAlternativeBrancherFinder.isBranchNewlyClosed(oldAcc, tmpAcc)){
					system.debug('*** The branch has newly been closed.');
    				ClsBestAlternativeBrancherFinder finder = new ClsBestAlternativeBrancherFinder();
    				
					//All the main branch contacts and All the best alternative branch contacts
    				affectedConIdSet.addAll(finder.findRelatedContact(newAcc));
    				//All the other affected contacts within the range
    				//affectedConIdSet.addAll(finder.findNearbyContact(tmpAcc.Id));
				}
				else if(ClsBestAlternativeBrancherFinder.isBranchNewlyOpen(oldAcc, tmpAcc)){ 
					system.debug('*** The branch has newly been opened.');
    				ClsBestAlternativeBrancherFinder finder = new ClsBestAlternativeBrancherFinder();
    				
					//All the main branch contacts and All the best alternative branch contacts
    				affectedConIdSet.addAll(finder.findRelatedContact(newAcc));
    				//All the other affected contacts within the range
    				affectedConIdSet.addAll(finder.findNearbyContact(tmpAcc.Id));
					
				}
				
				/*
				//The Branch is active and address is udpated
				else if(tmpAcc.Branch_Close_Date__c == null && ClsBestAlternativeBrancherFinder.isBranchAddressChanged(oldAcc, tmpAcc)){
					system.debug('*** The branch address has been updated.');
					ClsBestAlternativeBrancherFinder finder = new ClsBestAlternativeBrancherFinder();
    				
    				List<Id> foundIdList;
					//All the main branch contacts and All the best alternative branch contacts
					foundIdList = finder.findRelatedContact(newAcc);
    				affectedConIdSet.addAll(foundIdList);
    				//system.debug('*** relatedContactIds: ' + foundIdList);
    				//All the other affected contacts within the range. At this time, the new address has NOT been geocoded yet.
    				foundIdList = finder.findNearbyContact(tmpAcc.Id);
    				//system.debug('*** nearbyContactIds: ' + foundIdList);
    				affectedConIdSet.addAll(foundIdList);
    				
    				//Geocode the new address and search out the affected contacts
    				system.debug('*** Start geocoding record: ' + tmpAcc.Id);
    				ClsBestAlternativeBrancherFinder.geocodeRecord(tmpAcc.Id);
    				foundIdList = finder.findNearbyContact(tmpAcc.Id);
    				//system.debug('*** newnearbyContactIds: ' + foundIdList);
    				affectedConIdSet.addAll(foundIdList);
				}*/
			}
		}
		/*
		else if(trigger.isInsert){
			for(Account tmpAcc : trigger.new){
				Account newAcc = newMap.get(tmpAcc.Id);
				system.debug('*** This is a new branch.');
				//If the branch address is updated, or branch is closed
				//1. GeoCoder will re-calcuate the geolocation, (already done by GeoPointe)
				//2. Require to re-evaluate the best alternative branch, so that the BatchToUpdateBestAlternativeBranch could pickup and recalcuate
				ClsBestAlternativeBrancherFinder.geocodeRecord(tmpAcc.Id);
				
				ClsBestAlternativeBrancherFinder finder = new ClsBestAlternativeBrancherFinder();
				//All the main branch contacts and All the best alternative branch contacts
				affectedConIdSet.addAll(finder.findRelatedContact(newAcc));
				//All the other affected contacts within the range
				affectedConIdSet.addAll(finder.findNearbyContact(tmpAcc.Id));
			}
		}*/
		
		//Query the affect contacts and add them into the map
		Map<Id, Contact> affectedConMap = new Map<Id, Contact>([SELECT Id, Name /*, Re_evaluate_Best_Alternative_Branch__c*/ FROM Contact WHERE Id in :affectedConIdSet]); 
		//Update the flag
		for(Contact tmpCon : affectedConMap.values()){
			tmpCon.Re_evaluate_Best_Alternative_Branch__c = true;
		}
		//Commit into SFDC
		update affectedConMap.values();
	}
}