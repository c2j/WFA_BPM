/**************************************************************************************************
 * Purpose: Customer Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-06
 * Modify History:
 * Keen    2013-11-06    Created
***************************************************************************************************/
global class CustomerUtil {
	public static void processAfterTrg(){
		List<Contact> newFAList = trigger.new;
		Map<Id, Contact> toUpdateFAMap = new Map<Id, Contact>();
		
		//Start picking out the records
		if(trigger.isUpdate){
			for(Contact newFA : newFAList){
				Contact oldFA = (Contact)trigger.oldMap.get(newFA.Id);
				if(newFA.AccountId != null && newFA.AccountId != oldFA.AccountId){
					toUpdateFAMap.put(newFA.id, newFA);
				}
			}
		}
		
		//Start handling the records
		transferFAGoalList(toUpdateFAMap);
		
	}
	//Transfer FA Goals to other BoM Plan. This usually happens when the FA changes his Branch
	public static void transferFAGoalList(Map<Id, Contact> toUpdateFAMap){
		//Only transfer the FA Goals for the most recent year plan; The previous FA Goal will remain as is
		String mostRecentYear = getMostRecentYearSet();
		
		//A map of FA Goals that needs to be transferred
		map<Id, FA_Goal__c> faGoalMap = getFAGoalMap(toUpdateFAMap.keySet(), mostRecentYear);
		list<FA_Goal__c> faGoalList = faGoalMap.values();
		
		set<Id> mainBranchIdSet = getMainBranchIdSet(toUpdateFAMap.keySet());
		list<BoM_Plan__c> bomPlanList = getBoMPlanListByMainBranch(mainBranchIdSet, mostRecentYear);
		//system.debug('*** bomPlanList: ' + bomPlanList);
		
		//Match between faGoal and bomPlan
		Boolean found = false;
		list<FA_Goal__c> toUpdateFAGoalList = new list<FA_Goal__c>();
		list<FA_Goal__c> toDeleteFAGaolList = new list<FA_Goal__c>();
		for(FA_Goal__c faGoal : faGoalList){
			found = false;
			for(BoM_Plan__c bomPlan : bomPlanList){
				//If the FA and BoM plan belongs to the same main branch, move the FA Goal under that Plan
				if(faGoal.FA__r.Account.Main_Branch__c == bomPlan.Main_Branch__c){
					faGoal.BoM_Plan__c = bomPlan.Id;
					found = true;
				}
			}
			
			if(found){
				toUpdateFAGoalList.add(faGoal);
			}
			else {
				//If the BoM Plan for that main branch has not been created yet, it will be enqueued into a delete list
				toDeleteFAGaolList.add(faGoal);
			}
		}
		
		update toUpdateFAGoalList;
		delete toDeleteFAGaolList;
	}
	
	public static map<Id, FA_Goal__c> getFAGoalMap(set<Id> faIdSet, String year){
		map<Id, FA_Goal__c> faGoalMap = new map<Id, FA_Goal__c>([
			Select Name,
				BoM_Plan__c,
				FA__r.Account.Main_Branch__c
			From FA_Goal__c
			Where FA__c in :faIdSet
			And BoM_Plan__r.Year_Text__c = :year
		]);
		return faGoalMap;
	}
	
	//Get the most recent year from all existing plans
	public static String getMostRecentYearSet(){
		String mostRecentYear = '';
		list<AggregateResult> aggList = [
			Select MAX(Year_Text__c) year
			From BoM_Plan__c
		];
		
		for(AggregateResult ar : aggList){
			mostRecentYear = String.valueOf(ar.get('year'));
		}
		
		return mostRecentYear;
	}
	
	//Get the plan by the main branch Ids and year
	public static list<BoM_Plan__c> getBoMPlanListByMainBranch(set<Id> mainBranchIdSet, String year){
		list<BoM_Plan__c> bomPlanList = [
			Select Id, Name,
				Main_Branch__c
			From BoM_Plan__c
			Where Main_Branch__c in :mainBranchIdSet
			And Year_Text__c = :year
		];
		
		return bomPlanList;
	}
	
	//Get the main branch Id set from the FAs
	public static set<Id> getMainBranchIdSet(set<Id> faIdSet){
		
		list<Contact> faList = [
			Select Name,
				Account.Main_Branch__c
			From Contact
			Where Id in :faIdSet
		];
		set<Id> mainBranchIdSet = new set<Id>();
		
		for(Contact fa : faList){
			mainBranchIdSet.add(fa.Account.Main_Branch__c);
		}
		
		return mainBranchIdSet;
	}
	
	//****************************** Start Testing ********************************************************************

	/* For testing */
	public static list<Contact> getSampleFAList(Integer faCount, Account branch){
		list<Contact> faList = new list<Contact>();
		Contact fa;
		
		Integer maxCount = faCount;
		for(Integer i = 0; i<=maxCount; i++){
			fa = new Contact();
			fa.LastName = 'FA' + i;
			fa.FirstName = 'Carole';
			fa.Production_YTD__c = 2014000;
			fa.Annualized_Production__c = 2015000;
			fa.Production_Data_As_Of_Date__c = Date.newInstance(2013, 10, 21);
			
			if(math.mod(i, 2) == 0) {
				fa.Type__c = 'Market Manager';
			}else {
				fa.Type__c = 'Branch Manager';
			}
			fa.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
			fa.AccountId = branch.Id;
			faList.add(fa);
		}
		
		return faList;
	}
	
	public static list<User> createTestUser() {
		list<Profile> pList = [Select Id From Profile Where Name='PCG Admin'];
		User u = new User();
		u.Username = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
		u.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
		u.Alias = 'tAdmin';
		u.CommunityNickname = 'tAdmin';
		if(pList != null) {
			u.ProfileId = pList.get(0).Id;
		}
		u.AU__c = '0055801';
        u.Phone = '+1 999-999-9999';
        u.EmployeeNumber = '1028106';
        u.MobilePhone = '+1 999-999-9999';
        u.LastName = 'Test 1';
        //u.CurrencyIsoCode = 'USD';
		u.TimeZoneSidKey = 'GMT';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.LanguageLocaleKey = 'en_US';
		u.UserPermissionsMobileUser = false;
		
		User u1 = new User();
		u1.Username = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
		u1.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
		u1.Alias = 'KaneM';
		u1.CommunityNickname = 'Kane, Matthew';
		if(pList != null) {
			u1.ProfileId = pList.get(0).Id;
		}
		u1.AU__c = '0055802';
		u1.Phone = '+1 999-999-9999';
		u1.EmployeeNumber = '1028106';
		u1.MobilePhone = '+1 999-999-9999';
		u1.LastName = 'Test 2';
        //u.CurrencyIsoCode = 'USD';
		u1.TimeZoneSidKey = 'GMT';
		u1.LocaleSidKey = 'en_US';
		u1.EmailEncodingKey = 'ISO-8859-1';
		u1.LanguageLocaleKey = 'en_US';
		u1.UserPermissionsMobileUser = false;
		
		User u2 = new User();
		u2.Username = 'premieradvisors@wellsfargoadvisors.com.cnfigsndbxtest';
		u2.Email = 'premieradvisors@wellsfargoadvisors.com.cnfigsndbxtest';
		u2.Alias = 'AP';
		u2.CommunityNickname = 'Advisors, Premier';
		if(pList != null) {
			u2.ProfileId = pList.get(0).Id;
		}
		u2.AU__c = '0055801';
		u2.Phone = '+1 999-999-9999';
		u2.EmployeeNumber = '1028106';
		u2.MobilePhone = '+1 999-999-9999';
		u2.LastName = 'Test 3';
        //u.CurrencyIsoCode = 'USD';
		u2.TimeZoneSidKey = 'GMT';
		u2.LocaleSidKey = 'en_US';
		u2.EmailEncodingKey = 'ISO-8859-1';
		u2.LanguageLocaleKey = 'en_US';
		u2.UserPermissionsMobileUser = false;
		list<User> userList = new list<User>();
		userList.add(u);
		userList.add(u1);
		userList.add(u2);
		return userList;
	}
	//****************************** End Testing ********************************************************************
	
}