/**************************************************************************************************
 * Name: BatchToUpdateBestAlternativeBranch
 * Purpose: Batch to calculate the Best Alternative Branch based on the distance
 * Author: Keen Xu
 * Create Date: 2013-06-06
 * Modify History: 
 * 2013-06-06    Keen	Created
***************************************************************************************************/
global class BatchToUpdateBestAlternativeBranch implements Database.Batchable<Contact>, Database.stateful, Database.AllowsCallouts {
	global BatchToUpdateBestAlternativeBranch(){
	}
	
    global Iterable<Contact> start (Database.Batchablecontext bc) {
        //return [SELECT Id, Name, AccountId FROM Contact WHERE Re_evaluate_Best_Alternative_Branch__c = true];
        List<Contact> conList = new List<Contact>(ClsBestAlternativeBrancherFinder.getContactListToEvaluate());
        system.debug('*** starting BatchToUpdateBestAlternativeBranch. Count: ' + conList.size() + '; Contact List: ' + conList);
        return conList;
    }
    
    global void execute (Database.Batchablecontext bc, list<Contact> scope) {
    	system.debug('*** executing BatchToUpdateBestAlternativeBranch: ' + scope);
    	ClsBestAlternativeBrancherFinder finder = new ClsBestAlternativeBrancherFinder();
    	for(Contact con : scope){
    		try{
	    		con.Branch_Distance__c = finder.getDistance(con.Id, con.AccountId);
	    		geopointe.API.radialSearchResult result = finder.radialSearchBranch(con.Id);
	    		if(result.error == true){
	    			system.debug('*** Radial Search Result Error: '  + con.Name + ': ' + result.errorMessage);
	    			continue;
	    		}
	    		else if(result.recordCount == 0) {
	    			con.Re_evaluate_Best_Alternative_Branch__c = false;
	    			system.debug('*** Could not find any branches within the radian. ' + con.Name);
	    			continue;
	    		}
	    		else {
	    			List<Id> idList = result.recordsInDistanceOrder;
	    			system.debug('*** RadiasSearch: ' + result);
	    			Id bestAlternativeBranchId;
	    			//If it's not the same as the main branch
	    			if(con.AccountId != idList[0]){
	    				bestAlternativeBranchId = idList[0];
	    			}
	    			//If it's the same as the main branch, get the second nearest
	    			else if(result.recordCount > 1){
	    				bestAlternativeBranchId = idList[1];
	    			}
	    			else {
	    				system.debug('*** Could not find any branches within the radian other than the main branch.  ' + con.Name);
	    				continue;
	    			}
	    			
	    			con.Best_Alternative_Branch__c = bestAlternativeBranchId;
	    			con.Best_Alternative_Branch_Distance__c = result.recordsByDistance.get(bestAlternativeBranchId);
	    			con.Re_evaluate_Best_Alternative_Branch__c = false;
	    			system.debug('*** Identified the nearest branch: ' + con.Name + ': ' + con.Best_Alternative_Branch_Distance__c);
	    			
	    		}
	    		system.debug('***Scope Contact:' + con);
    		}
    		catch(Exception ex){
    			system.debug('***Exception:' + ex);
    		}
    	}
    	update scope;
    }

    global void finish(Database.Batchablecontext bc) {
		System.debug('*** finishing BatchToUpdateBestAlternativeBranch.');
    }
}