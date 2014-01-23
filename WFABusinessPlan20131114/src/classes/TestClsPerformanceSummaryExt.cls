@isTest
private class TestClsPerformanceSummaryExt {
	public static testmethod void testPerformanceSummaryExt(){ 
		List<Account> accList = createAccountList();
		Contact con = createContactList(accList[0].Id)[0];
		ClsPerformanceSummaryExt ext = new ClsPerformanceSummaryExt();
		ext.contact = con;
		ext.getPerformanceSummaryList();
		system.assert(ext.psList.size() == 2);
		
		
		con.Production_Data_As_Of_Date__c = Date.parse('04/24/2016');
		con.Production_YTD__c = 1234;
		con.Production_MTD__c = 123;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('05/26/2017');
		con.New_Key_HHs__c = 101;
		con.Compensable_Loans_YTD__c = 102;
		con.Net_Asset_Flows__c = 103;
		con.Advisory_Revenue_Perc_YTD__c = 104;
		con.MTD_Net_New_Advisory_Sales__c = 105;
		con.of_Key_HHs_w_Env_POR2__c = 106;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('06/30/2015');
		con.Official_Trainee_T12__c = 1001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		update con;
		
		ext.getPerformanceSummaryList();
		system.assert(ext.psList.size() == 2);
		
		con.Production_Data_As_Of_Date__c = Date.parse('07/24/2016');
		con.Production_YTD__c = 1234;
		con.Production_MTD__c = 123;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('08/26/2017');
		con.New_Key_HHs__c = 101;
		con.Compensable_Loans_YTD__c = 102;
		con.Net_Asset_Flows__c = 103;
		con.Advisory_Revenue_Perc_YTD__c = 104;
		con.MTD_Net_New_Advisory_Sales__c = 105;
		con.of_Key_HHs_w_Env_POR2__c = 106;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('09/30/2015');
		con.Official_Trainee_T12__c = 1001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		update con;
		
		ext.getPerformanceSummaryList();
		system.assert(ext.psList.size() == 2);
		
		con.Production_Data_As_Of_Date__c = Date.parse('10/24/2016');
		con.Production_YTD__c = 1234;
		con.Production_MTD__c = 123;
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('11/26/2017');
		con.New_Key_HHs__c = 101;
		con.Compensable_Loans_YTD__c = 102;
		con.Net_Asset_Flows__c = 103;
		con.Advisory_Revenue_Perc_YTD__c = 104;
		con.MTD_Net_New_Advisory_Sales__c = 105;
		con.of_Key_HHs_w_Env_POR2__c = 106;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('12/30/2015');
		con.Official_Trainee_T12__c = 1001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		update con;
		
		ext.getPerformanceSummaryList();
		system.assert(ext.psList.size() == 2);
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
		
		con.MBO_Metrics_As_of_Date__c = Date.parse('02/26/2014');
		con.New_Key_HHs__c = 101;
		con.Compensable_Loans_YTD__c = 102;
		con.Net_Asset_Flows__c = 103;
		con.Advisory_Revenue_Perc_YTD__c = 104;
		con.MTD_Net_New_Advisory_Sales__c = 105;
		con.of_Key_HHs_w_Env_POR2__c = 106;
		
		con.Trainee_Data_As_of_Date__c = Date.parse('03/30/2015');
		con.Official_Trainee_T12__c = 1001;
		con.TPM__c = 12;
		con.Trainee_Segment__c = 'Below Minimum';
		
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
}