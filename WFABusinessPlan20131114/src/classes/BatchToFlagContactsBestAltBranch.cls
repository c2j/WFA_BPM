/**************************************************************************************************
 * Name: BatchToFlagContactsBestAltBranch
 * Purpose: Batch to flag the contacts that needs to evaluate the best alternative branch
 * Author: Keen Xu
 * Create Date: 2013-06-06
 * Modify History: 
 * 2013-06-06    Keen	Created
***************************************************************************************************/
global class BatchToFlagContactsBestAltBranch  implements Database.Batchable<Account>, Database.stateful, Database.AllowsCallouts {
	Datetime timeAfter; 
    Integer timespanInMins;
    List<String> accountRecordTypeList;
    List<String> contactRecordTypeList;
	global BatchToFlagContactsBestAltBranch(){
		timeAfter = ClsBestAlternativeBrancherFinder.getTimeAfter(); 
		timespanInMins = ClsBestAlternativeBrancherFinder.getTimeSpanInMins();
		accountRecordTypeList = ClsBestAlternativeBrancherFinder.getAccountRecordType();
		contactRecordTypeList = ClsBestAlternativeBrancherFinder.getContactRecordType();
	}
	
    global Iterable<Account> start (Database.Batchablecontext bc) {
        
        //Flag the contacts whose locations are updated after the specified time
        List<Contact> conList = [SELECT Id FROM Contact 
    		WHERE (Contact.geopointe__Geocode__r.LastModifiedDate >= :timeAfter OR Contact.Best_Alternative_Branch__c = NULL)
    		AND Terminated__c = 'No'
    		AND RecordTypeId in (select Id from RecordType where Name IN :contactRecordTypeList AND SobjectType = 'Contact') LIMIT 5000];
    	for(Contact tmpCon : conList){
    		//Mark them as required to evaluate.
    		tmpCon.Re_evaluate_Best_Alternative_Branch__c =true;
    	}
    	update conList;
    	

    	Set<Contact> conSet = new Set<Contact>();
    	Set<Contact> tmpConSet = new Set<Contact>(); 
    	Set<Id> tmpConIdSet = new Set<Id>(); 
    	
    	//Query out Accounts that are affected by the updates of account locations. This will be sent to the batch to determine the contacts that need evaluate
    	Map<Id, Account> accMap;
    	
    	accMap = new Map<Id, Account>(
			[SELECT Id, Name, Branch_Close_Date__c
			, (SELECT Id, Name FROM Contacts WHERE RecordTypeId in (select Id from RecordType where Name IN :contactRecordTypeList AND SobjectType = 'Contact')) 
			, (SELECT Id, Name FROM Contacts__r WHERE RecordTypeId in (select Id from RecordType where Name IN :contactRecordTypeList AND SobjectType = 'Contact')) 
			FROM Account 
			WHERE Account.RecordTypeId in (select Id from RecordType where Name IN :accountRecordTypeList AND SobjectType = 'Account') AND Account.geopointe__Geocode__r.LastModifiedDate >= :timeAfter]);
		system.debug('*** starting getContactListToEvaluate. TimeAfter: ' + timeAfter + '; Count: ' + accMap.size() + '; Account Map: ' + accMap);
        return accMap.values();
    }
    
    global void execute (Database.Batchablecontext bc, list<Account> scope) {
    	system.debug('*** executing BatchToUpdateBestAlternativeBranch: ' + scope);
    	Set<Id> tmpConIdSet = new Set<Id>();
    	for(Account acc : scope){
    		try{
    			//Contacts that are affected by the updates of location. Related contacts and nearby contacts.
	    		ClsBestAlternativeBrancherFinder finder = new ClsBestAlternativeBrancherFinder();
				tmpConIdSet.addAll(finder.findRelatedContact(acc));
				tmpConIdSet.addAll(finder.findNearbyContact(acc.Id));
				system.debug('***tmpConIdSet:'+tmpConIdSet);
    		}
    		catch(Exception ex){
    			system.debug('***Exception:' + ex);
    		}
    	}
    	
    	List<Contact> conList = [SELECT Id FROM Contact 
    		WHERE Id in :tmpConIdSet
    		AND RecordTypeId in (select Id from RecordType where Name IN :contactRecordTypeList AND SobjectType = 'Contact')];
    	for(Contact tmpCon : conList){
    		//Mark them as required to evaluate.
    		tmpCon.Re_evaluate_Best_Alternative_Branch__c =true;
    	}
    	update conList;
    }

    global void finish(Database.Batchablecontext bc) {
		System.debug('*** finishing BatchToFlagContactsBestAltBranch');
		BatchToUpdateBestAlternativeBranch batch = new BatchToUpdateBestAlternativeBranch();
        ID BatchProcessID = Database.executeBatch(batch, 10); 
    }
}