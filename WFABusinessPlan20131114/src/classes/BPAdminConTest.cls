@isTest
private class BPAdminConTest {
	private static testmethod void testAdminCon() {
		//CustomerUtil.createTestUser();
		//list<User> userList = [Select Id From User];
		
		Test.startTest();
		BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
		Test.stopTest();
		
		Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
		
		CustomerUtil.createTestUser();
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();
		con.closeBoMPlan();
		con.cleanupBoMPlan();
		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbx';
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbx';
				conTmp.Type__c = 'Branch Manager';
			}
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Market_Complex__c> tmpMarketList = [select Id from Market_Complex__c];
		list<Account> accountList = [Select Id, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(1).Id;
			}
		}
		update accountList;
		//system.debug('Sub_Supl_Complex__c ===>>>  ' + JSON.serialize(tmpList));
		//update tmpList;
		system.debug('============>>>  333');
		con.updateUserManager();
		con.grantManagerAccess();
		system.debug('============>>>  444');
		/**
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(1).Id;
			}
		}
		update accountList;
		con.updateUserManager();
		con.grantManagerAccess();
		**/
	}
	
	
	private static testmethod void testAdminCon2() {
		//CustomerUtil.createTestUser();
		//list<User> userList = [Select Id From User];
		
		Test.startTest();
		BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
		Test.stopTest();
        
        Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
        
		CustomerUtil.createTestUser();
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbx';
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbx';
				conTmp.Type__c = 'Branch Manager';
			}
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Market_Complex__c> tmpMarketList = [select Id from Market_Complex__c];
		list<Account> accountList = [Select Id, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(1).Id;
			}
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
		system.debug('============>>>  222');
	}
	
	private static testmethod void testAdminCon3() {
		//CustomerUtil.createTestUser();
		//list<User> userList = [Select Id From User];
		
		Test.startTest();
		BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
		Test.stopTest();
		
		Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
		
		CustomerUtil.createTestUser();
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();
		
		con.selectedYear = con.yearList[0].getValue();
		con.closeBoMPlan();
		
		con.selectedYear = con.yearList[0].getValue();
		con.cleanupBoMPlan();

	}
}