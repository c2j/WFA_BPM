@isTest
private class TestClsSpecialEventLooplusExt {
	static testMethod void testCreateAttChildren(){
		List<Contact> conList = createContactAndChildren();
		SFDC_Special_Event__c sp = createSpecialEvent();
		createAttendance(conList[0].Id, conList[1].Id, sp.Id);
		ClsSpecialEventLooplusExt ext = new ClsSpecialEventLooplusExt(sp.Id);
		ext.looplus();
		
		Map<Id, Attendance_Child__c> childMap = new Map<Id, Attendance_Child__c>([SELECT Id, Name, First_Name__c, Age__c, School_College__c  FROM Attendance_Child__c WHERE Attendance__c in (SELECT Id FROM SFDC_Attendance__c WHERE Attendee__c = :conList[0].Id)]);
		system.debug('***Asert conList[0].Id: ' + childMap.values().size());
		System.assert(childMap.values().size() == 1);
		for(Attendance_Child__c child : childMap.values()){
			system.debug('*** child: ' + child);
			System.assert(child.First_Name__c == 'John');
			System.assert(child.Age__c == 1);
			System.assert(child.School_College__c == 'Washington University 1');
		}
		
		childMap = new Map<Id, Attendance_Child__c>([SELECT Id FROM Attendance_Child__c WHERE Attendance__c in (SELECT Id FROM SFDC_Attendance__c WHERE Attendee__c = :conList[1].Id)]);
		system.debug('***Asert conList[1].Id: ' + childMap.values().size());
		System.assert(childMap.values().size() == 4);
		
		//Rerun it. It won't change.
		ext.looplus();
		childMap = new Map<Id, Attendance_Child__c>([SELECT Id, Name, First_Name__c, Age__c, School_College__c  FROM Attendance_Child__c WHERE Attendance__c in (SELECT Id FROM SFDC_Attendance__c WHERE Attendee__c = :conList[0].Id)]);
		system.debug('***Asert conList[0].Id: ' + childMap.values().size());
		System.assert(childMap.values().size() == 1);
		for(Attendance_Child__c child : childMap.values()){
			system.debug('*** child: ' + child);
			System.assert(child.First_Name__c == 'John');
			System.assert(child.Age__c == 1);
			System.assert(child.School_College__c == 'Washington University 1');
		}
		
		childMap = new Map<Id, Attendance_Child__c>([SELECT Id FROM Attendance_Child__c WHERE Attendance__c in (SELECT Id FROM SFDC_Attendance__c WHERE Attendee__c = :conList[1].Id)]);
		system.debug('***Asert conList[1].Id: ' + childMap.values().size());
		System.assert(childMap.values().size() == 4);
	}
	static SFDC_Special_Event__c createSpecialEvent(){
		// Create the new account
		SFDC_Special_Event__c sp = new SFDC_Special_Event__c();
		sp.Category__c = 'Events';
		sp.Type__c = 'FA';
		SP.Name = 'WFA Global 2013';
		sp.ME_Status__c = 'In Progress';
		sp.Start_Date__c = DateTime.now().date();
		sp.End_Date__c = DateTime.now().date();
		insert sp;
		
		return [SELECT id, Name FROM SFDC_Special_Event__c LIMIT 1];
	}
	static void createAttendance(ID conId1, ID conId2, ID spId){
		// Create the new account
		SFDC_Attendance__c att = new SFDC_Attendance__c();
		att.Attendee__c = conId1;
		att.Special_Event__c = spId;
		insert att;
		
		att = new SFDC_Attendance__c();
		att.Attendee__c = conId2;
		att.Special_Event__c = spId;
		insert att;
	}
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
	static List<Contact> createContactAndChildren(){
		Account acc = createAccount();
		List<Contact> conList = createContactList(acc.Id);
		List<Child__c> childList = createChildList1(conList[0].Id);
		childList = createChildList2(conList[1].Id);
		return [SELECT Id, (SELECT Id, Name FROM Children__r) FROM Contact];
	}
	static List<Child__c> createChildList1(Id conId){
		List<Child__c> childList = new List<Child__c>();
		Child__c child = new Child__c();
		child.Name = 'John';
		child.Parent__c = conId;
		child.Child_Birthdate__c = DateTime.now().date().addYears(-1).addDays(-5);//Make sure it is one year because of the existing formula
		child.Child_School_College__c = 'Washington University 1';
		childList.add(child);
		
		insert childList;
		
		return [SELECT Name, Parent__c FROM Child__c WHERE Parent__c = :conId];
	}
	static List<Child__c> createChildList2(Id conId){
		List<Child__c> childList = new List<Child__c>();
		Child__c child = new Child__c();
		child.Name = 'Sue';
		child.Parent__c = conId;
		child.Child_Birthdate__c = DateTime.now().date().addYears(-1);
		child.Child_School_College__c = 'Washington University 3';
		childList.add(child);
		
		child = new Child__c();
		child.Name = 'Doe';
		child.Parent__c = conId;
		child.Child_Birthdate__c = DateTime.now().date().addYears(-1);
		child.Child_School_College__c = 'Washington University 4';
		childList.add(child);
		
		child = new Child__c();
		child.Name = 'Tue';
		child.Parent__c = conId;
		child.Child_Birthdate__c = DateTime.now().date().addYears(-1);
		child.Child_School_College__c = 'Washington University 5';
		childList.add(child);
		
		child = new Child__c();
		child.Name = 'Tie';
		child.Parent__c = conId;
		child.Child_Birthdate__c = DateTime.now().date().addYears(-1);
		child.Child_School_College__c = 'Washington University 6';
		childList.add(child);
		
		insert childList;
		
		return [SELECT Name, Parent__c FROM Child__c WHERE Parent__c = :conId];
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
}