@isTest
private class TestCaptureMonthlyMetrics {
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
		con.Production_Data_As_Of_Date__c = Date.parse('01/24/2013');
		con.Production_YTD__c = 1234;
		con.Production_MTD__c = 123;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('01/26/2013');
		con.New_Key_HHs__c = 101;
		con.Compensable_Loans_YTD__c = 102;
		con.Net_Asset_Flows__c = 103;
		con.Advisory_Revenue_Perc_YTD__c = 104;
		con.MTD_Net_New_Advisory_Sales__c = 105;
		con.of_Key_HHs_w_Env_POR2__c = 106;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('01/30/2013');
		con.Official_Trainee_T12__c = 1001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		//con.Minimum_Production__c = 60000;
		//con.Target_Production__c = 60000;
		
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
		con.Production_Data_As_Of_Date__c = Date.parse('02/24/2013');
		con.Production_YTD__c = 2234;
		con.Production_MTD__c = 223;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('03/26/2013');
		con.New_Key_HHs__c = 201;
		con.Compensable_Loans_YTD__c = 202;
		con.Net_Asset_Flows__c = 203;
		con.Advisory_Revenue_Perc_YTD__c = 204;
		con.MTD_Net_New_Advisory_Sales__c = 205;
		con.of_Key_HHs_w_Env_POR2__c = 206;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('04/30/2013');
		con.Official_Trainee_T12__c = 2001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		//con.Minimum_Production__c = 60000;
		//con.Target_Production__c = 60000;
		
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
		con.Production_Data_As_Of_Date__c = Date.parse('03/24/2013');
		con.Production_YTD__c = 3234;
		con.Production_MTD__c = 323;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('03/26/2013');
		con.New_Key_HHs__c = 301;
		con.Compensable_Loans_YTD__c = 302;
		con.Net_Asset_Flows__c = 303;
		con.Advisory_Revenue_Perc_YTD__c = 304;
		con.MTD_Net_New_Advisory_Sales__c = 305;
		con.of_Key_HHs_w_Env_POR2__c = 306;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('04/30/2013');
		con.Official_Trainee_T12__c = 3001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		//con.Minimum_Production__c = 60000;
		//con.Target_Production__c = 60000;
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
		con.Production_Data_As_Of_Date__c = Date.parse('04/24/2013');
		con.Production_YTD__c = 4234;
		con.Production_MTD__c = 423;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('03/26/2013');
		con.New_Key_HHs__c = 301;
		con.Compensable_Loans_YTD__c = 302;
		con.Net_Asset_Flows__c = 303;
		con.Advisory_Revenue_Perc_YTD__c = 304;
		con.MTD_Net_New_Advisory_Sales__c = 305;
		con.of_Key_HHs_w_Env_POR2__c = 306;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('04/30/2013');
		con.Official_Trainee_T12__c = 3001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		//con.Minimum_Production__c = 60000;
		//con.Target_Production__c = 60000;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '399 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name4';
		con.FirstName = 'First Name4';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		con.Production_Data_As_Of_Date__c = Date.parse('02/24/2013');
		con.Production_YTD__c = 4234;
		con.Production_MTD__c = 423;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('03/26/2013');
		con.New_Key_HHs__c = 301;
		con.Compensable_Loans_YTD__c = 302;
		con.Net_Asset_Flows__c = 303;
		con.Advisory_Revenue_Perc_YTD__c = 304;
		con.MTD_Net_New_Advisory_Sales__c = 305;
		con.of_Key_HHs_w_Env_POR2__c = 306;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('03/30/2013');
		con.Official_Trainee_T12__c = 3001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		//con.Minimum_Production__c = 60000;
		//con.Target_Production__c = 60000;
		conList.add(con);
		
		con = new Contact();
		con.OtherStreet = '299 Market Street';
		con.OtherCity = 'Saint Louis';
		con.OtherState = 'MO';
		con.OtherPostalCode = '63103';
		con.OtherCountry = 'US';
		con.LastName = 'Last Name5';
		con.FirstName = 'First Name5';
		con.Type__c = 'FA';
		con.AccountId = mainAccountId;
		con.Production_Data_As_Of_Date__c = Date.parse('05/24/2013');
		con.Production_YTD__c = 3234;
		con.Production_MTD__c = 323;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('06/26/2014');
		con.New_Key_HHs__c = 301;
		con.Compensable_Loans_YTD__c = 302;
		con.Net_Asset_Flows__c = 303;
		con.Advisory_Revenue_Perc_YTD__c = 304;
		con.MTD_Net_New_Advisory_Sales__c = 305;
		con.of_Key_HHs_w_Env_POR2__c = 306;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('07/30/2015');
		con.Official_Trainee_T12__c = 3001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		//con.Minimum_Production__c = 60000;
		//con.Target_Production__c = 60000;
		conList.add(con);
				
		insert conList;
		
		conList = getContactListWithMoreInfo(conList);
		return conList;
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
	
	static testMethod void captureMonthlyMetrics(){
		List<Account> accList = createAccountList();
		List<Contact> conList = createContactList(accList[0].Id);
		system.debug('***conList: ' + conList);
		
		List<Performance_History__c> phList = [SELECT Id, Contact__r.FirstName, Production_YTD__c, Production_Year__c, 
			(SELECT Id, Name, Production_YTD__c, Production_MTD__c, New_Key_HHs__c, Compensable_Loans__c, Net_Asset_Flows__c,
				YTD_Advisory_Revenue__c, MTD_Net_New_Advisory_Sales__c, of_Key_HHs_w_Env_POR__c,
				Official_Trainee_T12__c, Trainee_Month__c, Trainee_Segment__c, Minimum_T12_Production__c, Target_T12_Production__c
				FROM Performance_History_Details__r Order By Name) 
			FROM Performance_History__c];
			
		List<Performance_History__c> phPrintOutList = [SELECT Id, 
			(SELECT Id FROM Performance_History_Details__r) 
			FROM Performance_History__c];
		system.debug('***phPrintOutList: ' + phPrintOutList);
		system.assert(phList.size() == 8);
		
		Boolean name0Found = false;
		Boolean name1Found = false;
		Boolean name2Found = false;
		Boolean name3Found = false;
		Boolean name4Found = false;
		Boolean name5Found = false;
		Boolean name6Found = false;
		Boolean name7Found = false;
		
		for(Performance_History__c ph : phList){
			
			if(ph.Contact__r.FirstName == 'First Name0'){
				Performance_History_Detail__c phd = ph.Performance_History_Details__r[0];
				system.assert(ph.Production_Year__c == '2013');
				system.assert(phd.Name == '01');
				
				system.assert(phd.Production_YTD__c == 1234);
				system.assert(phd.Production_MTD__c == 123);
				
				system.assert(phd.New_Key_HHs__c == 101);
				system.assert(phd.Compensable_Loans__c == 102);
				system.assert(phd.Net_Asset_Flows__c == 103);
				system.assert(phd.YTD_Advisory_Revenue__c == 104);
				system.assert(phd.MTD_Net_New_Advisory_Sales__c == 105);
				system.assert(phd.of_Key_HHs_w_Env_POR__c == 106);
				
				system.assert(phd.Official_Trainee_T12__c == 1001);
				system.assert(phd.Trainee_Month__c == 12);
				system.assert(phd.Trainee_Segment__c == 'Below Minimum');
				//system.assert(phd.Minimum_T12_Production__c == 40000);
				//system.assert(phd.Target_T12_Production__c == 60000);
				name0Found = !name0Found;
				system.debug('*** name0Found: ' + name0Found);
			}
			if(ph.Contact__r.FirstName == 'First Name1'){
				system.assert(ph.Production_Year__c == '2013');
				
				Performance_History_Detail__c phd = ph.Performance_History_Details__r[0];
				system.assert(ph.Performance_History_Details__r[0].Name == '02');
				system.assert(phd.Production_YTD__c == 2234);
				system.assert(phd.Production_MTD__c == 223);
				
				phd = ph.Performance_History_Details__r[1];
				system.assert(ph.Performance_History_Details__r[1].Name == '03');
				system.assert(phd.New_Key_HHs__c == 201);
				system.assert(phd.Compensable_Loans__c == 202);				
				
				system.assert(ph.Performance_History_Details__r[2].Name == '04');
				name1Found = !name1Found;
			}
			
			if(ph.Contact__r.FirstName == 'First Name2'){
				system.assert(ph.Production_Year__c == '2013');
				system.assert(ph.Performance_History_Details__r[0].Name == '03');
				system.assert(ph.Performance_History_Details__r[1].Name == '04');
				name2Found = !name2Found;
			}
			
			if(ph.Contact__r.FirstName == 'First Name3'){
				system.assert(ph.Production_Year__c == '2013');
				Performance_History_Detail__c phd = ph.Performance_History_Details__r[0];
				system.assert(ph.Performance_History_Details__r[0].Name == '03');
				system.assert(phd.Production_YTD__c == null);
				system.assert(phd.Production_MTD__c == null);
				system.assert(phd.New_Key_HHs__c == 301);
				system.assert(phd.Compensable_Loans__c == 302);
				system.assert(phd.Net_Asset_Flows__c == 303);
				system.assert(phd.YTD_Advisory_Revenue__c == 304);
				system.assert(phd.MTD_Net_New_Advisory_Sales__c == 305);
				system.assert(phd.of_Key_HHs_w_Env_POR__c == 306);
				
				phd = ph.Performance_History_Details__r[1];
				system.assert(ph.Performance_History_Details__r[1].Name == '04');
				system.assert(phd.Production_YTD__c == 4234);
				system.assert(phd.Production_MTD__c == 423);
				
				system.assert(phd.Official_Trainee_T12__c == 3001);
				system.assert(phd.Trainee_Month__c == 12);
				system.assert(phd.Trainee_Segment__c == 'Below Minimum');
				name3Found = !name3Found;
			}
			
			if(ph.Contact__r.FirstName == 'First Name4'){
				system.assert(ph.Production_Year__c == '2013');
				Performance_History_Detail__c phd = ph.Performance_History_Details__r[0];
				system.assert(ph.Performance_History_Details__r[0].Name == '02');
				system.assert(phd.Production_YTD__c == 4234);
				system.assert(phd.Production_MTD__c == 423);
				
				phd = ph.Performance_History_Details__r[1];
				system.assert(ph.Performance_History_Details__r[1].Name == '03');
				system.assert(phd.New_Key_HHs__c == 301);
				system.assert(phd.Official_Trainee_T12__c == 3001);

				name4Found = !name4Found;
			}
			
			if(ph.Contact__r.FirstName == 'First Name5' && ph.Production_Year__c == '2013'){
				system.assert(ph.Performance_History_Details__r[0].Name == '05');
				name5Found = true;
			}
			
			if(ph.Contact__r.FirstName == 'First Name5' && ph.Production_Year__c == '2014'){
				system.assert(ph.Performance_History_Details__r[0].Name == '06');
				name6Found = true;
			}
			
			if(ph.Contact__r.FirstName == 'First Name5' && ph.Production_Year__c == '2015'){
				system.assert(ph.Performance_History_Details__r[0].Name == '07');
				name7Found = true;
			}
		}
		system.assert(name0Found);
		system.assert(name1Found);
		system.assert(name2Found);
		system.assert( name3Found);
		system.assert( name4Found );
		system.assert( name5Found );
		system.assert(name6Found);
		system.assert(name7Found);
		
		//Start to update
		Contact con = conList[0];
		con.Production_Data_As_Of_Date__c = Date.parse('01/29/2013');
		con.Production_YTD__c = 9999;
		con.Production_MTD__c = 999;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('02/26/2014');
		con.New_Key_HHs__c = 101;
		con.Compensable_Loans_YTD__c = 102;
		con.Net_Asset_Flows__c = 103;
		con.Advisory_Revenue_Perc_YTD__c = 104;
		con.MTD_Net_New_Advisory_Sales__c = 105;
		con.of_Key_HHs_w_Env_POR2__c = 106;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('06/30/2013');
		con.Official_Trainee_T12__c = 1001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		update con;
		
		phList = [SELECT Id, Contact__r.FirstName, Production_YTD__c, Production_Year__c, 
			(SELECT Id, Name, Production_YTD__c, Production_MTD__c, New_Key_HHs__c, Compensable_Loans__c, Net_Asset_Flows__c,
				YTD_Advisory_Revenue__c, MTD_Net_New_Advisory_Sales__c, of_Key_HHs_w_Env_POR__c,
				Official_Trainee_T12__c, Trainee_Month__c, Trainee_Segment__c, Minimum_T12_Production__c, Target_T12_Production__c
				FROM Performance_History_Details__r Order By Name) 
			FROM Performance_History__c WHERE Contact__r.FirstName='First Name0'];
			
		system.assert(phList[0].Production_Year__c == '2013');
		Performance_History_Detail__c phd = phList[0].Performance_History_Details__r[0];
		system.assert(phd.Name == '01');		
		system.assert(phd.Production_YTD__c == 9999);
		system.assert(phd.Production_MTD__c == 999);
		phd = phList[0].Performance_History_Details__r[1];
		system.assert(phd.Name == '06');		
		system.assert(phd.Production_YTD__c == null);
		system.assert(phd.Production_MTD__c == null);
		
		system.assert(phList[1].Production_Year__c == '2014');
		phd = phList[1].Performance_History_Details__r[0];
		system.assert(phd.Name == '02');		
		system.assert(phd.Production_YTD__c == null);
		system.assert(phd.Production_MTD__c == null);
		
		system.assert(phList.size()==2);
	}
}