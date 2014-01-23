@isTest
private class TestFlagBestAlternativeBranchEvaluation {
	static Account createAccount(){
		// Create the new account
		Account acc = new Account();
		acc.Branch_Address_Line1__c = '999 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account';
		insert acc;
		
		return acc;
	}
	
	static Account createClosedAccount(){
		// Create the new account
		Account acc = new Account();
		acc.Branch_Address_Line1__c = '999 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account';
		acc.Branch_Close_Date__c = DateTime.now().date();
		insert acc;
		
		return acc;
	}
	
	static List<Account> createAccountList(){
		// Create the new account
		List<Account> accList = new List<Account>();
		Account acc = new Account();
		acc.Branch_Address_Line1__c = '999 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account0';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1199 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account1';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1299 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account2';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1399 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account3';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1499 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account4';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1599 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account5';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1699 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account6';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1799 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account7';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1899 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account8';
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1999 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account9';
		accList.add(acc);
		
		insert accList;
		
		accList = getAccountListWithMoreInfo(accList);
		
		return accList;
	}
	
	static List<Account> createClosedAccountList(){
		// Create the new account
		List<Account> accList = new List<Account>();
		Account acc = new Account();
		acc.Branch_Address_Line1__c = '999 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account0';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1199 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account1';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1299 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account2';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1399 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account3';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1499 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account4';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1599 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account5';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1699 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account6';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1799 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account7';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1899 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account8';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		acc = new Account();
		acc.Branch_Address_Line1__c = '1999 Market Street';
		acc.Branch_AddressCity__c = 'Saint Louis';
		acc.Branch_AddressState__c = 'MO';
		acc.Branch_AddressZip__c = '63103';
		acc.Branch_Country__c = 'US';
		acc.Name = 'Unit Test Account9';
		acc.Branch_Close_Date__c = DateTime.now().date();
		accList.add(acc);
		
		insert accList;
		
		accList = getAccountListWithMoreInfo(accList);
		
		return accList;
	}
	
	static List<Contact> createContactList(Id mainAccountId){
		// Create the new account
		List<Contact> conList = new List<Contact>();
		Contact con = new Contact();
		con.OtherStreet = '99 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name0';
		con.FirstName = 'First Name0';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '199 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name1';
		con.FirstName = 'First Name1';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '299 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name2';
		con.FirstName = 'First Name2';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '399 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name3';
		con.FirstName = 'First Name3';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		conList.add(con);
				
		insert conList;
		
		conList = getContactListWithMoreInfo(conList);
		return conList;
	}
	
	static List<Contact> createContactList(Id mainAccountId, Id bestAltBranchId){
		// Create the new account
		List<Contact> conList = new List<Contact>();
		Contact con = new Contact();
		con.OtherStreet = '99 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name0';
		con.FirstName = 'First Name0';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		con.Best_Alternative_Branch__c = bestAltBranchId;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '199 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name1';
		con.FirstName = 'First Name1';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		con.Best_Alternative_Branch__c = bestAltBranchId;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '299 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name2';
		con.FirstName = 'First Name2';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		con.Best_Alternative_Branch__c = bestAltBranchId;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '399 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name3';
		con.FirstName = 'First Name3';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		con.Best_Alternative_Branch__c = bestAltBranchId;
		conList.add(con);
				
		insert conList;
		
		conList = getContactListWithMoreInfo(conList);
		return conList;
	}
	
	static void createGeoCode(Account acc, Integer latitude, Integer longitude){
		geopointe__Geocode__c code = new geopointe__Geocode__c();
		code.geopointe__Parent_Object__c = 'Account';
		code.geopointe__Parent_Record_ID__c = acc.Id;
		
		code.geopointe__Country__c = acc.Branch_Country__c;
		code.geopointe__State_Province__c = acc.Branch_AddressState__c;
		code.geopointe__Street__c = acc.Branch_Address_Line1__c;
		code.geopointe__City__c = acc.Branch_AddressCity__c;
		code.geopointe__Postal_Code__c = acc.Branch_AddressZip__c;
		
		code.geopointe__Latitude__c = latitude;
		code.geopointe__Longitude__c = longitude;
		code.geopointe__Latitude_display__c = latitude;
		code.geopointe__Longitude_display__c = longitude;
		insert code;
		
		code = [SELECT LastModifiedDate, geopointe__Parent_Object__c, geopointe__Parent_Record_ID__c FROM geopointe__Geocode__c WHERE geopointe__Parent_Record_ID__c = :acc.Id LIMIT 1];
		acc.geopointe__Geocode__c = code.Id;
		update acc;
		
		System.debug('***Geo:'+code);
	}
	static void createGeoCode(Contact con, Integer latitude, Integer longitude){
		geopointe__Geocode__c code = new geopointe__Geocode__c();
		code.geopointe__Parent_Object__c = 'Contact';
		code.geopointe__Parent_Record_ID__c = con.Id;
		
		code.geopointe__Country__c = con.OtherCountry;
		code.geopointe__State_Province__c = con.OtherState;
		code.geopointe__Street__c = con.OtherStreet;
		code.geopointe__City__c = con.OtherCity;
		code.geopointe__Postal_Code__c = con.OtherPostalCode;
		
		code.geopointe__Latitude__c = latitude;
		code.geopointe__Longitude__c = longitude;
		code.geopointe__Latitude_display__c = latitude;
		code.geopointe__Longitude_display__c = longitude;
		insert code;
		
		code = [SELECT LastModifiedDate, geopointe__Parent_Object__c, geopointe__Parent_Record_ID__c FROM geopointe__Geocode__c WHERE geopointe__Parent_Record_ID__c = :con.Id LIMIT 1];
		con.geopointe__Geocode__c = code.Id;
		update con;
		
		System.debug('***Geo:'+code);
	}
	
	static List<Contact> getContactListWithMoreInfo(List<Contact> conList){
		List<String> conNameList = new List<String>();
		for(Contact tmpCon : conList){
			conNameList.add(tmpCon.FirstName);
		}
		
		List<Contact> newConList = [SELECT Id, FirstName, AccountId, Branch_Distance__c, Best_Alternative_Branch__c, Best_Alternative_Branch_Distance__c, Re_evaluate_Best_Alternative_Branch__c 
			, OtherCountry, OtherState, OtherStreet, OtherCity, OtherPostalCode
			FROM Contact
			WHERE Contact.FirstName in :conNameList ORDER BY FirstName];
		return conList;
	}
	static List<Account> getAccountListWithMoreInfo(List<Account> accList){
		List<String> accNameList = new List<String>();
		for(Account acc : accList){
			accNameList.add(acc.Name);
		}
		List<Account> newAccList = [SELECT Id, Name, Branch_Close_Date__c, Branch_Country__c, Branch_AddressState__c, Branch_Address_Line1__c, Branch_AddressCity__c, Branch_AddressZip__c
			, (SELECT Id, FirstName, AccountId, Branch_Distance__c, Best_Alternative_Branch__c, Best_Alternative_Branch_Distance__c, Re_evaluate_Best_Alternative_Branch__c, OtherCountry, OtherState, OtherStreet, OtherCity, OtherPostalCode FROM Contacts ORDER BY FirstName) 
			, (SELECT Id, FirstName, AccountId, Branch_Distance__c, Best_Alternative_Branch__c, Best_Alternative_Branch_Distance__c, Re_evaluate_Best_Alternative_Branch__c, OtherCountry, OtherState, OtherStreet, OtherCity, OtherPostalCode FROM Contacts__r ORDER BY FirstName) 
			FROM Account 
			WHERE Account.Name in :accNameList ORDER BY Account.Name];
			
		return newAccList;
	}
	
	static testMethod void testFlagWhenBranchClosed(){
		List<Account> accList = createAccountList();
		List<Contact> conList = createContactList(accList[0].Id, accList[1].Id);
		accList = getAccountListWithMoreInfo(accList);
		
		for(Account acc : accList){
			for(Contact con : acc.Contacts){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false || con.Re_evaluate_Best_Alternative_Branch__c == null);
			}
		
			for(Contact con : acc.Contacts__r){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false || con.Re_evaluate_Best_Alternative_Branch__c == null);
			}
		}
		
		for(Account acc : accList){
			acc.Branch_Close_Date__c = DateTime.now().date();
		}
		
		update accList;
		
		accList = getAccountListWithMoreInfo(accList);
		for(Account acc : accList){
			for(Contact con : acc.Contacts){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == true);
			}
		
			for(Contact con : acc.Contacts__r){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == true);
			}
		}
	}
	
	static testMethod void testFlagWhenBranchOpened(){
		List<Account> accList = createClosedAccountList();
		List<Contact> conList = createContactList(accList[0].Id, accList[1].Id);
		accList = getAccountListWithMoreInfo(accList);
		
		for(Account acc : accList){
			for(Contact con : acc.Contacts){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false || con.Re_evaluate_Best_Alternative_Branch__c == null);
			}
		
			for(Contact con : acc.Contacts__r){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false || con.Re_evaluate_Best_Alternative_Branch__c == null);
			}
		}
		
		for(Account acc : accList){
			acc.Branch_Close_Date__c = null;
		}
		
		update accList;
		
		accList = getAccountListWithMoreInfo(accList);
		for(Account acc : accList){
			for(Contact con : acc.Contacts){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == true);
			}
		
			for(Contact con : acc.Contacts__r){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == true);
			}
		}
	}
	
	
	
	static testMethod void testBatchToUpdateBestAlternativeBranch(){
		List<Account> accList = createAccountList();
		List<Contact> conList = createContactList(accList[0].Id);
		accList = getAccountListWithMoreInfo(accList);
		
		system.debug('*** accList: ' + accList);
		system.debug('*** conList: ' + conList);
		
		Best_Alternative_Branch__c setting = new Best_Alternative_Branch__c();
		setting.Name = 'Default';
		setting.Search_Radius__c = 25;
		setting.Branch_Dataset_Id__c = '13705501852500.9658115332580457';
		setting.Customer_Dataset_Id__c = '13706353760650.38332925624480196';
		setting.Recently_Modified_Threshhold_Minutes__c = 120;
		insert setting;
		
		for(Account acc : accList){
			if(acc.Name == 'Unit Test Account0'){
				createGeoCode(acc, 100, 100);
			}
			else if(acc.Name == 'Unit Test Account1'){
				createGeoCode(acc, 200, 100);
			}
			else if(acc.Name == 'Unit Test Account2'){
				createGeoCode(acc, 300, 100);
			}
			else{
				createGeoCode(acc, 50, 100);
			}
			for(Contact con : acc.Contacts){
				if(con.FirstName == 'First Name0'){
					createGeoCode(con, 110, 100);
				}
				else if(con.FirstName == 'First Name1'){
					createGeoCode(con, 210, 100);
				}
				else if(con.FirstName == 'First Name2'){
					createGeoCode(con, 310, 100);
				}
				else if(con.FirstName == 'First Name3'){
					createGeoCode(con, 410, 100);
				}
				else{
					createGeoCode(con, 40, 100);
				}
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == null || con.Re_evaluate_Best_Alternative_Branch__c == false);
			}
		}
		
		for(Account acc : accList){
			acc.Branch_Close_Date__c = DateTime.now().date();
		}
		
		update accList;
		
		accList = getAccountListWithMoreInfo(accList);
		
		for(Account acc : accList){
			for(Contact con : acc.Contacts){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == true);
			}
		}
		test.startTest();
		BatchToFlagContactsBestAltBranch batch = new BatchToFlagContactsBestAltBranch();
		Database.executeBatch(batch, 20);
		test.stopTest();
		
		accList = getAccountListWithMoreInfo(accList);
		System.assert(accList[0].Contacts.size()>0);
		system.debug('*** accList[0].Contacts: ' + accList[0].Contacts);
		for(Contact con : accList[0].Contacts){
			system.debug('***Contact: ' + con);
			/*
			if(con.FirstName == 'First Name0'){
				System.assert(con.Branch_Distance__c == 99);
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false);
				System.assert(con.Best_Alternative_Branch__c == accList[1].Id);
			}
			else if(con.FirstName == 'First Name1'){
				System.assert(con.Branch_Distance__c == 99);
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false);
				System.assert(con.Best_Alternative_Branch__c == accList[1].Id);
			}
			*/
		}
	}
	
	static testMethod void testBatchToUpdateBestAlternativeBranchFullRun(){
		List<Account> accList = createAccountList();
		List<Contact> conList = createContactList(accList[0].Id);
		accList = getAccountListWithMoreInfo(accList);
		
		system.debug('*** accList: ' + accList);
		system.debug('*** conList: ' + conList);
		
		Best_Alternative_Branch__c setting = new Best_Alternative_Branch__c();
		setting.Name = 'Default';
		setting.Search_Radius__c = 25;
		setting.Branch_Dataset_Id__c = '13705501852500.9658115332580457';
		setting.Customer_Dataset_Id__c = '13706353760650.38332925624480196';
		setting.Recently_Modified_Threshhold_Minutes__c = 0;
		insert setting;
		
		for(Account acc : accList){
			if(acc.Name == 'Unit Test Account0'){
				createGeoCode(acc, 100, 100);
			}
			else if(acc.Name == 'Unit Test Account1'){
				createGeoCode(acc, 200, 100);
			}
			else if(acc.Name == 'Unit Test Account2'){
				createGeoCode(acc, 300, 100);
			}
			else{
				createGeoCode(acc, 50, 100);
			}
			for(Contact con : acc.Contacts){
				if(con.FirstName == 'First Name0'){
					createGeoCode(con, 110, 100);
				}
				else if(con.FirstName == 'First Name1'){
					createGeoCode(con, 210, 100);
				}
				else if(con.FirstName == 'First Name2'){
					createGeoCode(con, 310, 100);
				}
				else if(con.FirstName == 'First Name3'){
					createGeoCode(con, 410, 100);
				}
				else{
					createGeoCode(con, 40, 100);
				}
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == null || con.Re_evaluate_Best_Alternative_Branch__c == false);
			}
		}
		
		for(Account acc : accList){
			acc.Branch_Close_Date__c = DateTime.now().date();
		}
		
		update accList;
		
		accList = getAccountListWithMoreInfo(accList);
		
		for(Account acc : accList){
			for(Contact con : acc.Contacts){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == true);
			}
		}
		test.startTest();
		BatchToFlagContactsBestAltBranch batch = new BatchToFlagContactsBestAltBranch();
		Database.executeBatch(batch, 20);
		test.stopTest();
		
		accList = getAccountListWithMoreInfo(accList);
		System.assert(accList[0].Contacts.size()>0);
		system.debug('*** accList[0].Contacts: ' + accList[0].Contacts);
		for(Contact con : accList[0].Contacts){
			system.debug('***Contact: ' + con);
			/*
			if(con.FirstName == 'First Name0'){
				System.assert(con.Branch_Distance__c == 99);
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false);
				System.assert(con.Best_Alternative_Branch__c == accList[1].Id);
			}
			else if(con.FirstName == 'First Name1'){
				System.assert(con.Branch_Distance__c == 99);
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false);
				System.assert(con.Best_Alternative_Branch__c == accList[1].Id);
			}
			*/
		}
	}
	static testMethod void testBatchToUpdateBestAlternativeBranchNoThreshhold(){
		List<Account> accList = createAccountList();
		List<Contact> conList = createContactList(accList[0].Id);
		accList = getAccountListWithMoreInfo(accList);
		
		system.debug('*** accList: ' + accList);
		system.debug('*** conList: ' + conList);
		
		Best_Alternative_Branch__c setting = new Best_Alternative_Branch__c();
		setting.Name = 'Default';
		setting.Search_Radius__c = 25;
		setting.Branch_Dataset_Id__c = '13705501852500.9658115332580457';
		setting.Customer_Dataset_Id__c = '13706353760650.38332925624480196';
		insert setting;
		
		for(Account acc : accList){
			if(acc.Name == 'Unit Test Account0'){
				createGeoCode(acc, 100, 100);
			}
			else if(acc.Name == 'Unit Test Account1'){
				createGeoCode(acc, 200, 100);
			}
			else if(acc.Name == 'Unit Test Account2'){
				createGeoCode(acc, 300, 100);
			}
			else{
				createGeoCode(acc, 50, 100);
			}
			for(Contact con : acc.Contacts){
				if(con.FirstName == 'First Name0'){
					createGeoCode(con, 110, 100);
				}
				else if(con.FirstName == 'First Name1'){
					createGeoCode(con, 210, 100);
				}
				else if(con.FirstName == 'First Name2'){
					createGeoCode(con, 310, 100);
				}
				else if(con.FirstName == 'First Name3'){
					createGeoCode(con, 410, 100);
				}
				else{
					createGeoCode(con, 40, 100);
				}
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == null || con.Re_evaluate_Best_Alternative_Branch__c == false);
			}
		}
		
		for(Account acc : accList){
			acc.Branch_Close_Date__c = DateTime.now().date();
		}
		
		update accList;
		
		accList = getAccountListWithMoreInfo(accList);
		
		for(Account acc : accList){
			for(Contact con : acc.Contacts){
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == true);
			}
		}
		test.startTest();
		BatchToFlagContactsBestAltBranch batch = new BatchToFlagContactsBestAltBranch();
		Database.executeBatch(batch, 20);
		test.stopTest();
		
		accList = getAccountListWithMoreInfo(accList);
		System.assert(accList[0].Contacts.size()>0);
		system.debug('*** accList[0].Contacts: ' + accList[0].Contacts);
		for(Contact con : accList[0].Contacts){
			system.debug('***Contact: ' + con);
			/*
			if(con.FirstName == 'First Name0'){
				System.assert(con.Branch_Distance__c == 99);
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false);
				System.assert(con.Best_Alternative_Branch__c == accList[1].Id);
			}
			else if(con.FirstName == 'First Name1'){
				System.assert(con.Branch_Distance__c == 99);
				System.assert(con.Re_evaluate_Best_Alternative_Branch__c == false);
				System.assert(con.Best_Alternative_Branch__c == accList[1].Id);
			}
			*/
		}
	}
}