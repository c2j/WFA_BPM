@isTest
private class BPAdminUtilTest {

    private static testMethod void testBPAdminUtil1() {
		
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
		
		list<user> userList = CustomerUtil.createTestUser();
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();
		
		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
				conTmp.Type__c = 'Branch Manager';
			}
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		
		list<Account> accountList = [Select Id, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				if(tmpList != null) accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(0).Id;
			}else {
				if(tmpList != null && tmpList.size() > 1) accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(1).Id;
			}
		}
		update accountList;
		//system.debug('Sub_Supl_Complex__c ===>>>  ' + JSON.serialize(tmpList));
		//update tmpList;
		system.debug('============>>>  333');
		con.updateUserManager();
		con.grantManagerAccess();
		system.debug('============>>>  444');
    }
    
    private static testmethod void testBPAdminUtil2() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
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
				if(tmpMarketList != null)  accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				if(tmpMarketList != null && tmpMarketList.size() > 1) accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(1).Id;
			}
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
		system.debug('============>>>  222');
	}
	
	private static testmethod void testBPAdminUtil3() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		Profile p = [select Id from Profile where name='Read Only'][0];
		for(User u : userList) {
			u.ProfileId = p.Id;
		}
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
				conTmp.Type__c = 'Branch Manager';
			}
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		//list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Market_Complex__c> tmpMarketList = [select Id from Market_Complex__c];
		list<Account> accountList = [Select Id, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				if(tmpMarketList != null) accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				if(tmpMarketList != null && tmpMarketList.size() > 1) accountList.get(i).Market_Complex_Branch__c = tmpMarketList.get(1).Id;
			}
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
		system.debug('============>>>  222');
	}
	
	private static testmethod void testBPAdminUtil4() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		Profile p = [select Id from Profile where name='Read Only'][0];
		system.debug('------------->>>> ' + p);
		for(User u : userList) {
			u.ProfileId = p.Id;
		}
		system.debug('----userList--------->>>> ' + userList);
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtestxx';
				conTmp.Type__c = 'Branch Manager';
			}
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		//list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Region__c> tmpRegionList = [select Id from Region__c];
		list<Account> accountList = [Select Id, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = null;
				if(tmpRegionList != null) accountList.get(i).Region_Branch__c = tmpRegionList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = null;
				if(tmpRegionList != null && tmpRegionList.size() > 1)accountList.get(i).Region_Branch__c = tmpRegionList.get(1).Id;
			}
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
	}
	
	private static testmethod void testBPAdminUtil5() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		Profile p = [select Id from Profile where name='Read Only'][0];
		system.debug('------------->>>> ' + p);
		for(User u : userList) {
			u.ProfileId = p.Id;
		}
		system.debug('----userList--------->>>> ' + userList);
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		//list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Region__c> tmpRegionList = [select Id from Region__c];
		list<Account> accountList = [Select Id, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = null;
				if(tmpRegionList != null) accountList.get(i).Region_Branch__c = tmpRegionList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = null;
				if(tmpRegionList != null && tmpRegionList.size() > 1)accountList.get(i).Region_Branch__c = tmpRegionList.get(1).Id;
			}
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
	}
	
	private static testmethod void testBPAdminUtil6() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		Profile p = [select Id from Profile where name='Read Only'][0];
		system.debug('------------->>>> ' + p);
		for(User u : userList) {
			u.ProfileId = p.Id;
			u.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
		}
		system.debug('----userList--------->>>> ' + userList);
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Email = 'tim.mcallister@wellsfargoadvisors.com.cnfigsndbxtest';
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtestxx';
				conTmp.Type__c = 'Branch Manager';
			}
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		//list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Region__c> tmpRegionList = [select Id from Region__c];
		list<Account> accountList = [Select Id, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = null;
				if(tmpRegionList != null) accountList.get(i).Region_Branch__c = tmpRegionList.get(0).Id;
			}else {
				accountList.get(i).Sub_Supl_Complex_Branch__c = null;
				accountList.get(i).Market_Complex_Branch__c = null;
				if(tmpRegionList != null && tmpRegionList.size() > 1)accountList.get(i).Region_Branch__c = tmpRegionList.get(1).Id;
			}
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
	}
	
	private static testmethod void testBPAdminUtil7() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		Profile p = [select Id from Profile where name='Read Only'][0];
		system.debug('------------->>>> ' + p);
		for(User u : userList) {
			u.ProfileId = p.Id;
			u.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
		}
		system.debug('----userList--------->>>> ' + userList);
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Type__c = 'Branch Manager';
			}
			conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		//list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Account> accountList = [Select Id, Manager_Branch__c, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				if(tmpList != null){
					accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(0).Id;
				} 
			}else {
				if(tmpList != null && tmpList.size() > 1) accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(1).Id;
			}
			if(tmpList != null) accountList.get(i).Manager_Branch__c = updatedList.get(0).Id;
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
	}
	
	private static testmethod void testBPAdminUtil8() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		for(User u : userList) {
			u.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtestvvvv';
		}
		system.debug('----userList--------->>>> ' + userList);
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Type__c = 'Branch Manager';
			}
			conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		//list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Account> accountList = [Select Id, Manager_Branch__c, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				if(tmpList != null){
					accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(0).Id;
				} 
			}else {
				if(tmpList != null && tmpList.size() > 1) accountList.get(i).Sub_Supl_Complex_Branch__c = tmpList.get(1).Id;
			}
			if(tmpList != null) accountList.get(i).Manager_Branch__c = updatedList.get(0).Id;
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
	}
	
	private static testmethod void testBPAdminUtil9() {
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
        
		//CustomerUtil.createTestUser();
		list<user> userList = CustomerUtil.createTestUser();
		//Profile p = [select Id from Profile where name='Read Only'][0];
		//system.debug('------------->>>> ' + p);
		for(User u : userList) {
			//u.ProfileId = p.Id;
			u.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtestvvvv';
		}
		system.debug('----userList--------->>>> ' + userList);
		insert userList;
		list<Contact> contactList = [Select Id, Email From Contact];
		list<Contact> updatedList = new list<Contact>();
		BPAdminCon con = new BPAdminCon();
		system.debug('============>>>  ' + con.yearList[0].getValue());
		con.selectedYear = con.yearList[0].getValue();
		con.startBoMPlan();

		for(Integer i=0; i<contactList.size(); i++) {
			Contact conTmp = contactList.get(i);
			if(math.mod(i, 2) == 0) {
				conTmp.Type__c = 'Market Manager';
			}else {
				conTmp.Type__c = 'Branch Manager';
			}
			conTmp.Email = 'matthew.kane@wellsfargoadvisors.com.cnfigsndbxtest';
			updatedList.add(conTmp);
		}
		update updatedList;
		//system.debug('updatedList == >> ' + JSON.serialize(updatedList));
		//list<Sub_Supl_Complex__c> tmpList = [select Id, Name, Manager_Sub_Supl_Complex_Email__c from Sub_Supl_Complex__c];
		list<Account> accountList = [Select Id, Manager_Branch__c, Sub_Supl_Complex_Branch__c From Account];
		//Sub_Supl_Complex_Branch__c
		list<Market_Complex__c> tmpList = [select Id, Name from Market_Complex__c];
		//Sub_Supl_Complex_Branch__c
		for(Integer i=0; i<accountList.size(); i++) {
			if(math.mod(i, 2) == 0) {
				if(tmpList != null){
					accountList.get(i).Market_Complex_Branch__c = tmpList.get(0).Id;
				} 
			}else {
				if(tmpList != null && tmpList.size() > 1) accountList.get(i).Market_Complex_Branch__c = tmpList.get(1).Id;
			}
			if(tmpList != null) accountList.get(i).Manager_Branch__c = updatedList.get(0).Id;
		}
		update accountList;
		system.debug('============>>>  111');
		con.updateUserManager();
		con.grantManagerAccess();
	}
	
}