/**************************************************************************************************
 * Name: ClsBestAlternativeBrancherFinder
 * Purpose: Calculate the Best Alternative Branch based on the distance
 * Author: Keen Xu
 * Create Date: 2013-06-07
 * Modify History: 
 * 2013-06-07    Keen	Created
***************************************************************************************************/
global class ClsBestAlternativeBrancherFinder {
	global geopointe.API.units distanceUnits {get;set;}
	global decimal radius {get;set;}
	global string branchDataSetId {get;set;}
	global string contactDataSetId {get;set;}  
	global ClsBestAlternativeBrancherFinder(){
		distanceUnits = geopointe.API.units.MILES;
		
    	Best_Alternative_Branch__c babSettings = Best_Alternative_Branch__c.getValues('Default');
    	radius = 25;
    	branchDataSetId = '13705501852500.9658115332580457';//Default to the "branch (Active)" dataset
		contactDataSetId = '13706353760650.38332925624480196';//Default to the "Customers (Active)" dataset
		
    	if(babSettings!=null) {
    		radius = Integer.valueOf(babSettings.Search_Radius__c);
    		branchDataSetId = babSettings.Branch_Dataset_Id__c;
    		contactDataSetId = babSettings.Customer_Dataset_Id__c;
    	}
	}
	global Decimal getDistance(ID id1, ID id2){
		if(id1 == null || id2 == null) {
			return 0;
		}
		
		if(Test.isRunningTest()){
			return 99;
		}
		else{
			return geopointe.API.getDistance(id1, id2, distanceUnits);
		}

    }
	//Calls to Geopointe API to have a radial search for the branches around the Contact
    global geopointe.API.radialSearchResult radialSearchBranch(ID id){
    	
    	if(Test.isRunningTest()){
    		geopointe.API.radialSearchResult result = new geopointe.API.radialSearchResult();
    		result.error = false;
    		result.recordCount = 2;
    		result.recordsInDistanceOrder = new List<String>();
    		
    		List<String> accIdList = new List<String>();
    		
    		for(Account acc : [SELECT Id FROM Account ORDER BY Name]){
    			accIdList.add(acc.Id);
    		}
    		
    		result.recordsInDistanceOrder.addAll(accIdList);
    		return result;
    	}
    	
    	geopointe.API.radialSearchResult result = geopointe.API.radialSearchDataSet(Id, branchDataSetId, radius, distanceUnits);
    	return result;
    }
    //Calls to Geopointe API to have a radial search for the contacts around the Branch
    global geopointe.API.radialSearchResult radialSearchContact(ID id){
    	if(Test.isRunningTest()){
    		geopointe.API.radialSearchResult result = new geopointe.API.radialSearchResult();
    		result.error = false;
    		result.recordCount = 2;
    		result.recordsInDistanceOrder = new List<String>();
    		
    		List<String> conIdList = new List<String>();
    		
    		for(Contact con : [SELECT Id FROM Contact ORDER BY Name]){
    			conIdList.add(con.Id);
    		}
    		
    		result.recordsInDistanceOrder.addAll(conIdList);
    		return result;
    	}
    	geopointe.API.radialSearchResult result = geopointe.API.radialSearchDataSet(Id, contactDataSetId, radius, distanceUnits);
    	return result;
    }
    //Radial research of the branch and return the nearly contact Ids in a list
    global List<Id> findNearbyContact(ID branchId){
    	List<String> conIdStrList = null;
		geopointe.API.radialSearchResult result = radialSearchContact(branchId);
		if(result.error == true){
			system.debug('*** Radial Search Result Error: '  + branchId + ': ' + result.errorMessage);
			conIdStrList = new List<String>();
		}
		else if(result.recordCount == 0) {
			system.debug('*** Could not find any contacts within the radian. ' + branchId);
			conIdStrList = new List<String>();
		}
		else {
			system.debug('*** Identified the contacts near the branch: ' + branchId);
			conIdStrList = result.recordsInDistanceOrder;
		}
		
		List<Id> conIdList = new List<Id>();
		for(String tmpId :  conIdStrList){
			conIdList.add(Id.valueOf(tmpId));
		}
		
		return conIdList;
    }
    global List<Id> findRelatedContact(Account acc){
    	List<Id> conIdList = new List<Id>();
		//All the main branch contacts
		for(Contact con : acc.Contacts){
			conIdList.add(con.Id);
		}
		//All the best alternative branch contacts
		for(Contact con : acc.Contacts__r){
			conIdList.add(con.Id);
		}
		return conIdList;
    }
    global static void geocodeRecord(Id recordId){
    	geopointe.API.geocodeRecord(recordID);
    }

    //Check the if the branch is closed this time
    global static boolean isBranchNewlyClosed(Account oldAcc, Account newAcc){
    	if(oldAcc == null || newAcc == null){
    		return false; //Return false if either of the param is null
    	}
    	//If branch close date has been changed and it's updated to Non-Null, the branch is marked as closed
    	if(oldAcc.Branch_Close_Date__c == null && newAcc.Branch_Close_Date__c != null){
    		return true;
    	}
    	
    	return false;
    }
    //Check the if the branch is activated this time
    global static boolean isBranchNewlyOpen(Account oldAcc, Account newAcc){
    	if(oldAcc == null || newAcc == null){
    		return true; //Return true if either of the param is null
    	}
    	system.debug('*** Date: ' + oldAcc.Branch_Close_Date__c + 'New Date: ' + newAcc.Branch_Close_Date__c);
    	
    	//If branch close date has been changed and it's updated to Non-Null, the branch is marked as closed
    	if(oldAcc.Branch_Close_Date__c != null && newAcc.Branch_Close_Date__c == null){
    		return true;
    	}
    	
    	return false;
    }
    global static Integer getTimeSpanInMins(){
		//Get the setting of the timespan. The batch will only pickup those who were modified in the recent configured minutes.
    	Integer timespanInMins = 60;
    	Best_Alternative_Branch__c babSettings = Best_Alternative_Branch__c.getValues('Default');
    	if(babSettings!=null) {
    		timespanInMins = Integer.valueOf(babSettings.Recently_Modified_Threshhold_Minutes__c);
    	}
    	return timespanInMins;
	}
	global static DateTime getTimeAfter(){
		Integer timespanInMins = getTimeSpanInMins();
    	timespanInMins = -timespanInMins;
    	Datetime timeAfter = DateTime.now().addMinutes(timespanInMins);
    	return timeAfter;
	}
	global static List<String> getAccountRecordType(){
		List<String> accRecordTypeList = new List<String>();
		accRecordTypeList.add('PCG');
		return accRecordTypeList;
	}
	global static List<String> getContactRecordType(){
		List<String> conRecordTypeList = new List<String>();
		conRecordTypeList.add('PCG');
		return conRecordTypeList;
	}
    //Get a list of Contacts that requires to be evaluated
    global static Set<Contact> getContactListToEvaluate(){
    	Set<Contact> conSet;
    	List<String> contactRecordTypeList = ClsBestAlternativeBrancherFinder.getContactRecordType();
    	DateTime timeAfter = ClsBestAlternativeBrancherFinder.getTimeAfter(); 
    	if(getTimeSpanInMins() == 0){
    		conSet = new Set<Contact>([SELECT Id, Name, AccountId 
    			//Account.geopointe__Geocode__r.geopointe__Longitude__c, Account.geopointe__Geocode__r.geopointe__Latitude__c,
    			//geopointe__Geocode__r.geopointe__Longitude__c, geopointe__Geocode__r.geopointe__Latitude__c 
    			FROM Contact 
    			WHERE RecordTypeId in (SELECT Id FROM RecordType WHERE Name IN :contactRecordTypeList AND SobjectType = 'Contact')]);
    	}
    	else {
    		conSet = new Set<Contact>([SELECT Id, Name, AccountId 
    			//Account.geopointe__Geocode__r.geopointe__Longitude__c, Account.geopointe__Geocode__r.geopointe__Latitude__c,
    			//geopointe__Geocode__r.geopointe__Longitude__c, geopointe__Geocode__r.geopointe__Latitude__c 
    			FROM Contact 
    			WHERE Re_evaluate_Best_Alternative_Branch__c = true
    			AND RecordTypeId in (SELECT Id FROM RecordType WHERE Name IN :contactRecordTypeList AND SobjectType = 'Contact')]);
    	}
    	return conSet;  
    }
}