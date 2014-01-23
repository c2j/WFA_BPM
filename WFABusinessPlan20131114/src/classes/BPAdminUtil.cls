global class BPAdminUtil {
	
	/************************************************ update user manager start ****************************************/
    //update user manager field
    public static list<ErrorWarpper> updateUserManager() {
    	list<ErrorWarpper> errorList = new list<ErrorWarpper>();
    	map<String, Contact> checkContactMap = new map<String, Contact>();
    	//update user manager field from contact
    	errorList = updateUserManagerFromLeaderShipPlan(checkContactMap, errorList);
    	if(errorList != null && errorList.size() < 1000) {
    		//update user manager field from mainbranch
	    	errorList = updateUserManagerFromMainBranch(checkContactMap, errorList);
    	}
    	return errorList;
    }
    
    public static list<ErrorWarpper> updateUserManagerFromLeaderShipPlan(map<String, Contact> checkContactMap, list<ErrorWarpper> errorList) {
    	Set<String> contactEmailSet = new Set<String>();
    	
    	Set<String> subEmailSet = new Set<String>();
    	Set<String> marketEmailSet = new Set<String>();
    	Set<String> regionEmailSet = new Set<String>();
    	
    	map<String, Contact> deEmptyContactMap = new map<String, Contact>();
    	//map<String, Contact> checkContactMap = new map<String, Contact>();
    	//key: account id, value: email
    	map<String, String> account_emailMap = new map<String, String>();
    	
    	Set<String> typeSet = Customer_Type_Info__c.getall().keySet();
    	if(typeSet == null || typeSet.size() == 0) {
    		typeSet = new Set<String>{'Branch Manager', 'Complex Manager', 'Market Manager'};
    	}
    	list<Contact> tmpContactList = [Select Id
								    		, Name
								    		, Account.Manager_Branch__c
								    		
											, Account.Manager_Sub_Supl_Complex_Email__c
											, Account.Sub_Supl_Complex_Branch__c
											, Account.Manager_Sub_Supl_Complex__c
											, Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Id
											, Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Name
											
											, Account.Manager_Market_Complex_Email__c
											, Account.Manager_Market_Complex__c
											, Account.Market_Complex_Branch__c
											, Account.Market_Complex_Branch__r.Manager_Market_Complex__c
											, Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id
											, Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name
											
											, Account.Region_Branch__c
											, Account.Region_Branch__r.Id
											, Account.Region_Branch__r.Regional_President__r.Id
											, Account.Region_Branch__r.Regional_President__r.Name
											, Account.Region_Branch__r.Regional_President__r.Email
											
											, Account.Id
											, Account.Name
											, AccountId 
											, Email
											From Contact
											Where Type__c IN: typeSet
											AND Terminated__c = 'No'
											AND Account.Main_Branch__r.Main_Branch_Channel__c =: BPBranchBusinessPlanUtil.CHANNEL
										];
    	for(Contact con : tmpContactList) {
			if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
			if(con.Email != null) {
    			String branchManagerId = '';
    			String branchManagerName = '';
    			//deEmptyContactMap.put(con.Id, con);
    			contactEmailSet.add(con.Email);
    			//check wether Sub Supl Complex Email is null or not
    			if(con.Account.Manager_Sub_Supl_Complex_Email__c != null) {
    				branchManagerId = con.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Id;
    				//check wether account complex manager is the same branch manager or not
    				if(branchManagerId == con.Account.Manager_Branch__c) {
    					if(con.Account.Manager_Market_Complex_Email__c != null) {
    						branchManagerId = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
    						//check wether account market manager is the same branch manager or not
    						if(branchManagerId == con.Account.Manager_Branch__c) {
    							if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
				    													&& con.Account.Region_Branch__r.Regional_President__r.Email != null) {
				    				branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
				    				//check wether account regional manager is the same branch manager or not
				    				if(branchManagerId != con.Account.Manager_Branch__c) {
				    					prepareData(con, deEmptyContactMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
				    				}
				    			}
    						}else {
    							prepareData(con, deEmptyContactMap, account_emailMap, null, marketEmailSet, null, branchManagerName);
    						}
		    			}else {
		    				if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
				    													&& con.Account.Region_Branch__r.Regional_President__r.Email != null) {
			    				branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
			    				//check wether account regional manager is the same branch manager or not
			    				if(branchManagerId != con.Account.Manager_Branch__c) {
			    					prepareData(con, deEmptyContactMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
			    				}
			    			}
		    			}
    				}else {
    					prepareData(con, deEmptyContactMap, account_emailMap, subEmailSet, null, null, branchManagerName);
    				}
    			}
    			//check wether Market Complex Email is null or not
    			else if(con.Account.Manager_Market_Complex_Email__c != null) {
    				branchManagerId = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
    				if(branchManagerId == con.Account.Manager_Branch__c) {
						if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
		    													&& con.Account.Region_Branch__r.Regional_President__r.Email != null) {
		    				branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
		    				//check wether account regional manager is the same branch manager or not
		    				if(branchManagerId != con.Account.Manager_Branch__c) {
		    					prepareData(con, deEmptyContactMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
		    				}
		    			}
					}else {
						prepareData(con, deEmptyContactMap, account_emailMap, null, marketEmailSet, null, branchManagerName);
					}
    			}else if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
    														  && con.Account.Region_Branch__r.Regional_President__r.Email != null) {
    				branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
    				//check wether account regional manager is the same branch manager or not
    				if(branchManagerId != con.Account.Manager_Branch__c) {
    					prepareData(con, deEmptyContactMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
    				}
    			}else {
    				checkContactMap.put(con.Id, con);
    				String detail = 'Can\'t find the manager\'s user record';
    				ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail, branchManagerId, branchManagerName);
    				errorList.add(e);
    			}
    		}else {
    			checkContactMap.put(con.Id, con);
    			String detail = 'Can\'t find the user record';
    			ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail);
    			errorList.add(e);
    		}
		}
		subEmailSet.addAll(marketEmailSet);
    	subEmailSet.addAll(regionEmailSet);
    	//get users from customer email
    	map<String, list<User>> userMap1 = getUserMap(getUsersByEmail(contactEmailSet));
    	//system.debug('userMap1 ---- >>>>  ' + userMap1);
    	//get all manager user from branch email
    	list<User> allUserList = getUsersByEmail(subEmailSet);
    	map<String, list<User>> userMap2 = getUserMap(allUserList);
    	map<String, User> allUserMap = new map<String, User>();
    	for(User u : allUserList) {
    		allUserMap.put(u.Id, u);
    	}
    	if(errorList != null && errorList.size() < 1000) {
	    	errorList = updateUserInfoLeaderShipPlan(deEmptyContactMap, userMap1, userMap2, account_emailMap, errorList, checkContactMap, allUserMap);
    	}
    	return errorList;
    }
    //prepare update data
    public static void prepareData(Contact con, map<String, Contact> deEmptyContactMap, map<String, String> account_emailMap, Set<String> subEmailSet, Set<String> marketEmailSet
    																						, Set<String> regionEmailSet, String branchManagerName) {
    	if(con != null) deEmptyContactMap.put(con.Id, con);
		if(subEmailSet != null) subEmailSet.add(con.Account.Manager_Sub_Supl_Complex_Email__c);
		if(subEmailSet != null) account_emailMap.put(con.AccountId, con.Account.Manager_Sub_Supl_Complex_Email__c);
		if(subEmailSet != null) branchManagerName = con.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Name;
		
    	if(marketEmailSet != null) marketEmailSet.add(con.Account.Manager_Market_Complex_Email__c);
    	if(marketEmailSet != null) account_emailMap.put(con.AccountId, con.Account.Manager_Market_Complex_Email__c);
    	if(marketEmailSet != null) branchManagerName = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
    	
		if(regionEmailSet != null) regionEmailSet.add(con.Account.Region_Branch__r.Regional_President__r.Email);
		if(regionEmailSet != null) account_emailMap.put(con.AccountId, con.Account.Region_Branch__r.Regional_President__r.Email);
		if(regionEmailSet != null) branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
    }
    
    public static list<ErrorWarpper> updateUserInfoLeaderShipPlan(map<String, Contact> deEmptyContactMap, map<String, list<User>> userMap1
										, map<String, list<User>> userMap2, map<String, String> account_emailMap
										, list<ErrorWarpper> errorList, map<String, Contact> checkContactMap, map<String, User> allUserMap) {
    	//key: contact email, value: contact
    	map<String, Contact> customerMap = new map<String, Contact>();
    	map<Id, User> updatedUserMap = new map<Id, User>();
    	list<User> updatedUserList = new list<User>();
    	//iterator contact map
    	for(Contact con : deEmptyContactMap.values()) {
    		if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
    		//Leadership_Plan__c leader = deEmptyContactMap.get(key);
    		String email = con.Email;
    		//wether contact in the userMap1 or not
    		if(userMap1 == null || !userMap1.containsKey(email)) {
    			String detail = 'Can\'t find the user record with the email: ' + email + '.';
    			ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail);
    			if(!checkContactMap.containsKey(con.Id)) errorList.add(e);
    			checkContactMap.put(con.Id, con);
    			continue;
    		}
    		list<User> userList = userMap1.get(email);
    		//wether user who from customer email exist in the system or not
    		if(userList == null || userList.size() == 0) {
    			String detail = 'Can\'t find the user record with the email: ' + email + '.';
    			//String detail = 'Customer: ' + con.Name + ', Can\'t find the manager\'s user record with the email: ' + email + '.';
    			ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail);
    			if(!checkContactMap.containsKey(con.Id)) errorList.add(e);
    			checkContactMap.put(con.Id, con);
    			continue;
    		}
    		customerMap.put(email, con);
			User customerUser = userList.get(0);
			if(userList.size() > 1) {
				String detail = 'Find multiple user records with the email: ' + email + '.';
    			ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail);
    			if(!checkContactMap.containsKey(con.Id)) errorList.add(e);
    			checkContactMap.put(con.Id, con);
			}
			String brancheId = con.Account.Id;
			
			String branchManagerId = '';
			String branchManagerName = '';
			//filter out branch manager record id and name, 
			map<String, String> tmpMap = filterManagerInfo(con, con.Account.Manager_Branch__c, branchManagerId, branchManagerName);
			branchManagerId = tmpMap.get('branchManagerId');
			branchManagerName = tmpMap.get('branchManagerName');
			/**
			if(con.Account.Manager_Sub_Supl_Complex_Email__c != null) {
				branchManagerId = con.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Id;
    			if(con.Id == branchManagerId) {
    				if(con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r != null) {
	    				branchManagerId = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
	    				if(con.Id == branchManagerId) {
	    					if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null && con.Account.Region_Branch__r.Regional_President__r.Email != null) {
								branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
								if(con.Id != branchManagerId) {
									branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
								}else {
									branchManagerId = '';
								}			
							}
	    				}else {
							branchManagerName = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
	    				}
    				}else {
    					if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null && con.Account.Region_Branch__r.Regional_President__r.Email != null) {
							branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
							if(con.Id != branchManagerId) {
								branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
							}			
						}else {
							branchManagerId = '';
						}
    				}
    			}else {
					branchManagerName = con.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Name;
    			}	
			}else if(con.Account.Manager_Market_Complex_Email__c != null) {
				branchManagerId = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
				if(con.Id == branchManagerId) {
					if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null && con.Account.Region_Branch__r.Regional_President__r.Email != null) {
						branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
						if(con.Id != branchManagerId) {
							branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
						}
					}else {
						branchManagerId = '';
					}
				}else {
					branchManagerName = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
				}
			}else if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
									                      && con.Account.Region_Branch__r.Regional_President__r.Email != null) {
				branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
				if(con.Id != branchManagerId) {
					branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
				}else {
					branchManagerId = '';
				}						
			}
			**/	
			String branchEmail;
			if(account_emailMap.containsKey(brancheId)) {
				branchEmail = account_emailMap.get(brancheId);
			}
			if(branchEmail == null) continue;
			//wether user who from branch manager email exist in the userMap2 or not
			list<User> branchUserList = userMap2.get(branchEmail);
			if(branchUserList == null || branchUserList.size() == 0) {
				String detail = 'Can\'t find the manager\'s user record with the email: ' + branchEmail + '.';
    			ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail, branchManagerId, branchManagerName);
    			if(!checkContactMap.containsKey(con.Id)) errorList.add(e);
    			checkContactMap.put(con.Id, con);
    			continue;
    		}
    		//wether user who from branch manager email exist in the system or not
    		if(branchUserList.size() > 1) {
    			String detail = 'Find multiple manager\'s user records with the email: ' + branchEmail + '.';
    			ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail, branchManagerId, branchManagerName);
    			if(!checkContactMap.containsKey(con.Id)) errorList.add(e);
    			checkContactMap.put(con.Id, con);
			}
			User branchUser = branchUserList.get(0);
			//is the same user or not
			if(customerUser.Id == branchUser.Id) {
				String detail = 'Can\'t find the manager\'s user record';
    			ErrorWarpper e = new ErrorWarpper(con.Id, con.Name, detail, branchManagerId, branchManagerName);
    			if(!checkContactMap.containsKey(con.Id)) errorList.add(e);
    			checkContactMap.put(con.Id, con);
			}else {
				customerUser.ManagerId = branchUser.Id;
				updatedUserMap.put(customerUser.Id, customerUser);
			}
    	}
    	updatedUserList = updatedUserMap.values();
    	if(errorList != null && errorList.size() < 1000) {
	    	if(updatedUserList != null) updateUserManagerField(errorList, updatedUserList, customerMap, allUserMap);
    	}
    	system.debug('Leadership updatedUserList   ' + updatedUserList);
    	return errorList;
    }
    //update user manager field from main branch
    public static list<ErrorWarpper> updateUserManagerFromMainBranch(map<String, Contact> checkContactMap, list<ErrorWarpper> errorList) {
    	
    	Set<String> contactEmailSet = new Set<String>();
    	
    	Set<String> subEmailSet = new Set<String>();
    	Set<String> marketEmailSet = new Set<String>();
    	Set<String> regionEmailSet = new Set<String>();
    	
    	map<String, Main_Branch__c> deEmptyEmailMainBranchMap = new map<String, Main_Branch__c>();
    	//map<String, Contact> checkContactMap = new map<String, Contact>();
    	//key: account id, value: email
    	map<String, String> account_emailMap = new map<String, String>();
    	
    	//list<ErrorWarpper> errorList = new list<ErrorWarpper>();
    	
    	//map<String, String> errorMsgMap = new map<String, String>();
    	for(Main_Branch__c mb : [Select Id
    		, Name
    		
			, Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c
			, Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__c
			, Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex__c
			, Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Id
			, Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Name
			
			, Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c
			, Manager_Main_Branch__r.Account.Manager_Market_Complex__c
			, Manager_Main_Branch__r.Account.Market_Complex_Branch__c
			, Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__c
			, Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id
			, Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name
			
			, Manager_Main_Branch__r.Account.Region_Branch__c
			, Manager_Main_Branch__r.Account.Region_Branch__r.Id
			, Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id
			, Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name
			, Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email
			
			, Manager_Main_Branch__r.Account.Id
			, Manager_Main_Branch__r.Account.Name
			, Manager_Main_Branch__r.Account.Manager_Branch__c
			
			, Manager_Main_Branch__r.AccountId 
			, Manager_Main_Branch__r.Email
			, Manager_Main_Branch__r.Name
			, Manager_Main_Branch__r.Id
			, Manager_Main_Branch__c 
			From Main_Branch__c
			Where Manager_Main_Branch__c != null
			And Main_Branch_Channel__c =: BPBranchBusinessPlanUtil.CHANNEL
		]) {
			if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
    		if(mb.Manager_Main_Branch__r.Email != null) {
    			String branchManagerId = '';
    			String branchManagerName = '';
    			//deEmptyEmailMainBranchMap.put(mb.Id, mb);
    			contactEmailSet.add(mb.Manager_Main_Branch__r.Email);
    			//check wether Sub Supl Complex Email is null or not
    			if(mb.Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c != null) {
    				branchManagerId = mb.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Id;
    				//check wether account complex manager is the same branch manager or not
    				if(branchManagerId == mb.Manager_Main_Branch__r.Account.Manager_Branch__c) {
    					if(mb.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c != null) {
		    				branchManagerId = mb.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
		    				//check wether account market manager is the same branch manager or not
	    					if(branchManagerId == mb.Manager_Main_Branch__r.Account.Manager_Branch__c) {
	    						if(mb.Manager_Main_Branch__r.Account.Region_Branch__r != null && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
	    																					  && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
	    							branchManagerId = mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
	    							//check wether account regional manager is the same branch manager or not
	    							if(branchManagerId != mb.Manager_Main_Branch__r.Account.Manager_Branch__c) {
	    								prepareMainBranchData(mb, deEmptyEmailMainBranchMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
	    							}				
	    						}
	    					}else {
	    						prepareMainBranchData(mb, deEmptyEmailMainBranchMap, account_emailMap, null, marketEmailSet, null, branchManagerName);
	    					}
    					}else {
    						if(mb.Manager_Main_Branch__r.Account.Region_Branch__r != null && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
    																		        && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
			    				branchManagerId = mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
			    				//check wether account regional manager is the same branch manager or not
			    				if(branchManagerId != mb.Manager_Main_Branch__r.Account.Manager_Branch__c) {
			    					prepareMainBranchData(mb, deEmptyEmailMainBranchMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
			    				}
			    			}
    					}
    				}else {
    					prepareMainBranchData(mb, deEmptyEmailMainBranchMap, account_emailMap, subEmailSet, null, null, branchManagerName);
    				}
    			}else if(mb.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c != null) {
    				branchManagerId = mb.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
    				//check wether account market manager is the same branch manager or not
    				if(branchManagerId == mb.Manager_Main_Branch__r.Account.Manager_Branch__c) {
    					if(mb.Manager_Main_Branch__r.Account.Region_Branch__r != null && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
    																					  && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
							branchManagerId = mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
							//check wether account regional manager is the same branch manager or not
							if(branchManagerId != mb.Manager_Main_Branch__r.Account.Manager_Branch__c) {
								prepareMainBranchData(mb, deEmptyEmailMainBranchMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
							}				
						}
    				}else {
    					prepareMainBranchData(mb, deEmptyEmailMainBranchMap, account_emailMap, null, marketEmailSet, null, branchManagerName);
    				}
    			}else if(mb.Manager_Main_Branch__r.Account.Region_Branch__r != null && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
    																		        && mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
    				branchManagerId = mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
    				//check wether account regional manager is the same branch manager or not
    				if(branchManagerId != mb.Manager_Main_Branch__r.Account.Manager_Branch__c) {
    					prepareMainBranchData(mb, deEmptyEmailMainBranchMap, account_emailMap, null, null, regionEmailSet, branchManagerName);
    				}
    			}else {
    				checkContactMap.put(mb.Manager_Main_Branch__r.Id, mb.Manager_Main_Branch__r);
    				String detail = 'Can\'t find the manager\'s user record';
    				ErrorWarpper e = new ErrorWarpper(mb.Manager_Main_Branch__r.Id, mb.Manager_Main_Branch__r.Name, detail, branchManagerId, branchManagerName);
    				errorList.add(e);
    			}
    		}else {
    			checkContactMap.put(mb.Manager_Main_Branch__r.Id, mb.Manager_Main_Branch__r);
    			String detail = 'Can\'t find the manager\'s user record';
    			ErrorWarpper e = new ErrorWarpper(mb.Manager_Main_Branch__r.Id, mb.Manager_Main_Branch__r.Name, detail);
    			errorList.add(e);
    		}
    	}
    	subEmailSet.addAll(marketEmailSet);
    	subEmailSet.addAll(regionEmailSet);
    	//get users from customer email
    	map<String, list<User>> userMap1 = getUserMap(getUsersByEmail(contactEmailSet));
    	////get users from branch manager email
    	list<User> managerUserList = getUsersByEmail(subEmailSet);
    	map<String, list<User>> userMap2 = getUserMap(managerUserList);
    	map<String, User> managerUserMap = new map<String, User>();
    	for(User u : managerUserList) {
    		managerUserMap.put(u.Id, u);
    	}
    	if(errorList != null && errorList.size() < 1000) {
	    	errorList = updateUserInfoFromMainBranch(deEmptyEmailMainBranchMap, userMap1, userMap2, account_emailMap, errorList, checkContactMap, managerUserMap);
		}
			
    	return errorList;
    }
    
    //prepare update records
    public static void prepareMainBranchData(Main_Branch__c mb, map<String, Main_Branch__c> deEmptyEmailMainBranchMap, map<String, String> account_emailMap, Set<String> subEmailSet, Set<String> marketEmailSet
    																						, Set<String> regionEmailSet, String branchManagerName) {
    	if(mb != null) deEmptyEmailMainBranchMap.put(mb.Id, mb);
		if(subEmailSet != null) subEmailSet.add(mb.Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c);
		if(subEmailSet != null) account_emailMap.put(mb.Manager_Main_Branch__r.AccountId, mb.Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c);
		if(subEmailSet != null) branchManagerName = mb.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Name;
		
    	if(marketEmailSet != null) marketEmailSet.add(mb.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c);
    	if(marketEmailSet != null) account_emailMap.put(mb.Manager_Main_Branch__r.AccountId, mb.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c);
    	if(marketEmailSet != null) branchManagerName = mb.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
			    				
		if(regionEmailSet != null) regionEmailSet.add(mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email);
		if(regionEmailSet != null) account_emailMap.put(mb.Manager_Main_Branch__r.AccountId, mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email);
		if(regionEmailSet != null) branchManagerName = mb.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
    }
    
    /***
     * this method used to update user's manager field
     *@deEmptyEmailMainBranchMap: Main_Branch__c map which email not null
     *@userMap1: key is email, value is User list
     *@userMap2: key is email, value is User list 
     *@account_emailMap: key is account id, value is email
     *@errorList
    ***/
    public static list<ErrorWarpper> updateUserInfoFromMainBranch(map<String, Main_Branch__c> deEmptyEmailMainBranchMap, map<String, list<User>> userMap1
										, map<String, list<User>> userMap2, map<String, String> account_emailMap
										, list<ErrorWarpper> errorList, map<String, Contact> checkContactMap, map<String, User> managerUserMap) {
    	//key: contact email, value: contact
    	map<String, Contact> customerMap = new map<String, Contact>();
		map<Id, User> updatedUserMap = new map<Id, User>();
    	list<User> updatedUserList = new list<User>();
    	for(String key : deEmptyEmailMainBranchMap.keySet()) {
    		if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
    		Main_Branch__c mainBranch = deEmptyEmailMainBranchMap.get(key);
    		String tmpBranchManagerId = mainBranch.Manager_Main_Branch__r.Account.Manager_Branch__c;
    		String email = mainBranch.Manager_Main_Branch__r.Email;
    		//wether user who from main branch manager email exist in the system or not
    		if(userMap1 == null || !userMap1.containsKey(email)) {
    			String detail = 'Can\'t find the user record with the email: ' + email + '.';
    			ErrorWarpper e = new ErrorWarpper(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r.Name, detail);
    			if(!checkContactMap.containsKey(mainBranch.Manager_Main_Branch__r.Id)) errorList.add(e);
    			checkContactMap.put(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r);
    			continue;
    		}
    		list<User> userList = userMap1.get(email);
    		if(userList == null || userList.size() == 0) {
    			String detail = 'Can\'t find the user record with the email: ' + email + '.';
    			//String detail = 'Customer: ' + mainBranch.Manager_Main_Branch__r.Name + ', Can\'t find the manager\'s user record with the email: ' + email + '.';
    			ErrorWarpper e = new ErrorWarpper(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r.Name, detail);
    			if(!checkContactMap.containsKey(mainBranch.Manager_Main_Branch__r.Id)) errorList.add(e);
    			checkContactMap.put(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r);
    			continue;
    		}
			User customerUser = userList.get(0);
			if(userList.size() > 1) {
				String detail = 'Find multiple user records with the email: ' + email + '.';
    			ErrorWarpper e = new ErrorWarpper(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r.Name, detail);
    			if(!checkContactMap.containsKey(mainBranch.Manager_Main_Branch__r.Id)) errorList.add(e);
    			checkContactMap.put(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r);
			}
			customerMap.put(email, mainBranch.Manager_Main_Branch__r);
			
			String brancheId = mainBranch.Manager_Main_Branch__r.Account.Id;
			String branchManagerId = '';
			String branchManagerName = '';
			Contact con = mainBranch.Manager_Main_Branch__r;
			map<String, String> tmpMap = filterManagerInfo(con, tmpBranchManagerId, branchManagerId, branchManagerName);
			branchManagerId = tmpMap.get('branchManagerId');
			branchManagerName = tmpMap.get('branchManagerName');
			/**
			if(mainBranch.Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c != null) {
				branchManagerId = mainBranch.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Id;
    			if(branchManagerId == tmpBranchManagerId) {
    				if(mainBranch.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c != null) {
    					branchManagerId = mainBranch.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
    					if(branchManagerId == tmpBranchManagerId) {
    						if(mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r != null && mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
																						&& mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
								branchManagerId = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
								if(branchManagerId == tmpBranchManagerId) {
									branchManagerId = '';
								}else {
									branchManagerName = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
								}			
							}
    					}else {
    						branchManagerName = mainBranch.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
    					}
    				}else {
    					if(mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r != null && mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
																						&& mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
							branchManagerId = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
							if(branchManagerId == tmpBranchManagerId) {
								branchManagerId = '';
							}else {
								branchManagerName = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
							}			
						}
    				}
    			}else {
					branchManagerName = mainBranch.Manager_Main_Branch__r.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Name;
    			}	
			}else if(mainBranch.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c != null) {
				branchManagerId = mainBranch.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
				if(branchManagerId == tmpBranchManagerId) {
					if(mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r != null && mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
																						&& mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
						branchManagerId = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
						if(branchManagerId == tmpBranchManagerId) {
							branchManagerId = '';
						}else {
							branchManagerName = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
						}			
					}
				}else {
					branchManagerName = mainBranch.Manager_Main_Branch__r.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
				}
			}else if(mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r != null && mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r != null
																						&& mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
				branchManagerId = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
				if(branchManagerId == tmpBranchManagerId) {
					branchManagerId = '';
				}else {
					branchManagerName = mainBranch.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
				}	
			}
    		**/	
    			
			String branchEmail;
			if(account_emailMap.containsKey(brancheId)) {
				branchEmail = account_emailMap.get(brancheId);
			}
			if(branchEmail == null) continue;
			list<User> branchUserList = userMap2.get(branchEmail);
			//wether user who from branch manager email exist in the system or not
			if(branchUserList == null || branchUserList.size() == 0) {
				String detail = 'Can\'t find the manager\'s user record with the email: ' + branchEmail + '.';
    			ErrorWarpper e = new ErrorWarpper(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r.Name, detail, branchManagerId, branchManagerName);
    			if(!checkContactMap.containsKey(mainBranch.Manager_Main_Branch__r.Id)) errorList.add(e);
    			checkContactMap.put(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r);
    			continue;
    		}
    		if(branchUserList.size() > 1) {
    			String detail = 'Find multiple manager\'s user records with the email: ' + branchEmail + '.';
    			ErrorWarpper e = new ErrorWarpper(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r.Name, detail, branchManagerId, branchManagerName);
    			if(!checkContactMap.containsKey(mainBranch.Manager_Main_Branch__r.Id)) errorList.add(e);
    			checkContactMap.put(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r);
			}
			User branchUser = branchUserList.get(0);
			//is the same user or not
			if(customerUser.Id == branchUser.Id) {
				String detail = 'Can\'t find the manager\'s user record';
    			ErrorWarpper e = new ErrorWarpper(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r.Name, detail, branchManagerId, branchManagerName);
    			if(!checkContactMap.containsKey(mainBranch.Manager_Main_Branch__r.Id)) errorList.add(e);
    			checkContactMap.put(mainBranch.Manager_Main_Branch__r.Id, mainBranch.Manager_Main_Branch__r);
			}else {
				customerUser.ManagerId = branchUser.Id;
				updatedUserMap.put(customerUser.Id, customerUser);
			}
			//updatedUserList.add(customerUser);
    	}
    	updatedUserList = updatedUserMap.values();
    	if(errorList != null && errorList.size() < 1000) {
	    	if(updatedUserList != null) errorList = updateUserManagerField(errorList, updatedUserList, customerMap, managerUserMap);
    	}
    	return errorList;
    }
    //filter out branch manager record 
    public static map<String, String> filterManagerInfo(Contact con, String tmpBranchManagerId, String branchManagerId, String branchManagerName) {
    	map<String, String> managerMap = new map<String, String>();
    	if(con.Account.Manager_Sub_Supl_Complex_Email__c != null) {
			branchManagerId = con.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Id;
			if(branchManagerId == tmpBranchManagerId) {
				if(con.Account.Manager_Market_Complex_Email__c != null) {
					branchManagerId = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
					if(branchManagerId == tmpBranchManagerId) {
						if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
																					&& con.Account.Region_Branch__r.Regional_President__r.Email != null) {
							branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
							if(branchManagerId == tmpBranchManagerId) {
								branchManagerId = '';
							}else {
								branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
							}			
						}
					}else {
						branchManagerName = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
					}
				}else {
					if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
																					&& con.Account.Region_Branch__r.Regional_President__r.Email != null) {
						branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
						if(branchManagerId == tmpBranchManagerId) {
							branchManagerId = '';
						}else {
							branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
						}			
					}
				}
			}else {
				branchManagerName = con.Account.Sub_Supl_Complex_Branch__r.Manager_Sub_Supl_Complex__r.Name;
			}	
		}else if(con.Account.Manager_Market_Complex_Email__c != null) {
			branchManagerId = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Id;
			if(branchManagerId == tmpBranchManagerId) {
				if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
																					&& con.Account.Region_Branch__r.Regional_President__r.Email != null) {
					branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
					if(branchManagerId == tmpBranchManagerId) {
						branchManagerId = '';
					}else {
						branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
					}			
				}
			}else {
				branchManagerName = con.Account.Market_Complex_Branch__r.Manager_Market_Complex__r.Name;
			}
		}else if(con.Account.Region_Branch__r != null && con.Account.Region_Branch__r.Regional_President__r != null
																					&& con.Account.Region_Branch__r.Regional_President__r.Email != null) {
			branchManagerId = con.Account.Region_Branch__r.Regional_President__r.Id;
			if(branchManagerId == tmpBranchManagerId) {
				branchManagerId = '';
			}else {
				branchManagerName = con.Account.Region_Branch__r.Regional_President__r.Name;
			}
		}
		managerMap.put('branchManagerId', branchManagerId);
		managerMap.put('branchManagerName', branchManagerName);
		return managerMap;
    }
    
    //update user manager field
    public static list<ErrorWarpper> updateUserManagerField(list<ErrorWarpper>errorList, list<User> updatedUserList, map<String, Contact> customerMap, map<String, User> managerUserMap) {
    	Database.SaveResult[] resultList = null;
    	if(updatedUserList == null || updatedUserList.size() == 0) return errorList;
    	resultList = Database.update(updatedUserList, false);
		Integer index = 0;
    	for(Database.SaveResult sr : resultList) {
    		if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
			if(sr.isSuccess()) {
				index ++;
				continue;
			}
			//put all error message into error list
			for(Database.Error err : sr.getErrors()) {
				if(errorList != null && errorList.size() >= 1000) {
					return errorList;
				}
				String email = updatedUserList.get(index).Email;
				String customerId = customerMap.get(email).Id;
				String customerName = customerMap.get(email).Name;
				String managerId = updatedUserList.get(index).ManagerId;
				String managerName = managerUserMap.get(managerId).Name;
				
				ErrorWarpper error = new ErrorWarpper(customerId, customerName, err.getMessage(), managerId, managerName);
				errorList.add(error);
			}
			index ++;
		}
		return errorList;
    }
    //construct user map, key: email, value: user list
    public static map<String, list<User>> getUserMap(list<User> users) {
    	map<String, list<User>> userMap = new map<String, list<User>>();
    	for(User u : users)  {
    		if(userMap.containsKey(u.Email)) {
    			userMap.get(u.Email).add(u);
    		}else {
    			list<User> tmp = new list<User>();
    			tmp.add(u);
    			userMap.put(u.Email, tmp);
    		}
    	}
    	return userMap;
    }
    //get user by email set
    public static list<User> getUsersByEmail(Set<String> emailSet) {
    	list<User> users = [Select ManagerId, Id, Name, Email From User Where IsActive = true And Email IN: emailSet And UserType != 'Guest'];
    	return users;
    }
    /************************************************ update user manager end ****************************************/
    
    
    
    
    /************************************************ update record owner start ****************************************/
    //update record owner
    public static list<ErrorWarpper> updateRecordOwner(String selectedYear) {
    	
    	list<BoM_Plan__c> updatedBomPlanList = new list<BoM_Plan__c>();
    	list<FA_Goal__c> updatedFaGoalList = new list<FA_Goal__c>();
    	list<Action_Plan__c> updatedActionPlanList = new list<Action_Plan__c>();
    	//Set<String> bomPlanIDSet = new Set<String>();
    	list<ErrorWarpper> errorList = new list<ErrorWarpper>();
    	map<Id, BoM_Plan__c> bomPlanMap = new map<Id, BoM_Plan__c>();
    	
    	Set<String> mainBranchEmailSet = new Set<String>(); 
    	Set<String> subComplexEmailSet = new Set<String>(); 
    	Set<String> marketComplexEmailSet = new Set<String>(); 
    	Set<String> regionEmailSet = new Set<String>(); 
    	list<BoM_Plan__c> tmpBomPlanList = [Select Name
							    	, Id
							    	, OwnerId
							    	, Main_Branch__r.Name
							    	, Main_Branch__r.Manager_Main_Branch__r.Name
							    	, Main_Branch__r.Manager_Main_Branch__r.Email
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Id
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__c
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__c
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id
							    	, Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name
							    	, Main_Branch__c
							    	
							    	, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex_Email__c
									, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Name
									, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Id
									, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Manager_Market_Complex_Email__c
							    	, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__c
							    	, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__c
							    	, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Email
							    	, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Id
							    	, Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Name
									, Sub_Supl_Complex__r.Id
									, Sub_Supl_Complex__r.Name
									, Sub_Supl_Complex__c
									
									, Market_Complex__r.Manager_Market_Complex__c
									, Market_Complex__r.Manager_Market_Complex__r.Name
									, Market_Complex__r.Manager_Market_Complex_Email__c
									, Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__c
							    	, Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__c
							    	, Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Email
							    	, Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Id
							    	, Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Name
									, Market_Complex__r.Name
									, Market_Complex__r.Id
									, Market_Complex__c 
									
									, Region__r.Name
									, Region__r.Id
									, Region__c
									, Region__r.Regional_President__r.Email
									, Region__r.Regional_President__r.Id
									, Region__r.Regional_President__r.Name
									, Region__r.Regional_President__c
									
									
							    	, (Select Id, Name, OwnerId From FA_Goals__r)
							    	, (Select Id, Name, OwnerId From Action_Plans__r) 
							    	From BoM_Plan__c
							    	Where Year_Text__c =: selectedYear
							    	];
    	for(BoM_Plan__c bomPlan : tmpBomPlanList) {
			if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
			if(bomPlan.Main_Branch__c != null) {
				String errorId = bomPlan.Main_Branch__r.Id + '';
				String mainBranchName = 'Main Branch: ' + bomPlan.Main_Branch__r.Name;
				if(bomPlan.Main_Branch__r.Manager_Main_Branch__r != null) {
					if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Email != null) {
						mainBranchEmailSet.add(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Email);
					}
				}else {
					String detail = 'Can\'t find the Main Branch Manager associated with this Main Branch.';
	    			ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
	    			errorList.add(error);
				}
				bomPlanMap.put(bomPlan.Id, bomPlan);
			}else if(bomPlan.Sub_Supl_Complex__c != null) {
				String errorId = bomPlan.Sub_Supl_Complex__r.Id + '';
				String subComplexName = 'Sub / Supl Complex Manager: ' + bomPlan.Sub_Supl_Complex__r.Name + '';
				if(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r != null) {
					if(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex_Email__c != null) {
						subComplexEmailSet.add(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex_Email__c);
					}
				}else {
					String detail = 'Can\'t find the Sub / Supl Complex Manager associated with this Complex.';
	    			ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
	    			errorList.add(error);
				}
				bomPlanMap.put(bomPlan.Id, bomPlan);
			}else if(bomPlan.Market_Complex__c != null) {
				String errorId = bomPlan.Market_Complex__r.Id + '';
				String marketComplexName = 'Market / Complex: ' + bomPlan.Market_Complex__r.Name + '';
				if(bomPlan.Market_Complex__r.Manager_Market_Complex__c != null) {
					if(bomPlan.Market_Complex__r.Manager_Market_Complex_Email__c != null) {
						marketComplexEmailSet.add(bomPlan.Market_Complex__r.Manager_Market_Complex_Email__c);
					}
				}else {
					String detail = 'Can\'t find the Market / Complex Manager associated with this Complex.';
	    			ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
	    			errorList.add(error);
				}
				bomPlanMap.put(bomPlan.Id, bomPlan);
			}else if(bomPlan.Region__c != null) {
				String errorId = bomPlan.Region__r.Id;
				String regionName = 'Region: ' + bomPlan.Region__r.Name;
				if(bomPlan.Region__r.Regional_President__r != null) {
					if(bomPlan.Region__r.Regional_President__r.Email != null) {
						regionEmailSet.add(bomPlan.Region__r.Regional_President__r.Email);
					}
				}else {
					String detail = 'Can\'t find the Regional President associated with this Region.';
	    			ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
	    			errorList.add(error);
				}
				bomPlanMap.put(bomPlan.Id, bomPlan);
			}else {
				String detail = 'Can\'t find the Main Branch / Complex / Market / Region associated with this Region.';
	    		ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail);
	    		errorList.add(error);
			}
			
    	}
    	Set<String> allEmailSet = new Set<String>();
    	if(mainBranchEmailSet != null) allEmailSet.addAll(mainBranchEmailSet);
    	if(subComplexEmailSet != null) allEmailSet.addAll(subComplexEmailSet);
    	if(marketComplexEmailSet != null) allEmailSet.addAll(marketComplexEmailSet);
    	if(regionEmailSet != null) allEmailSet.addAll(regionEmailSet);
    	//get user from email set
    	list<User> userList = getUsersByEmail(allEmailSet);
    	map<String, list<User>> userMap = getUserMap(userList);
    	
    	map<Id, User> allUserMap = new map<Id, User>();
    	for(User u : userList) {
    		allUserMap.put(u.Id, u);
    	}
    	/**
    	if(updatedBomPlanList != null && updatedBomPlanList.size() > 0) update updatedBomPlanList;
    	if(updatedFaGoalList != null && updatedFaGoalList.size() > 0) update updatedFaGoalList;
    	if(updatedActionPlanList != null && updatedActionPlanList.size() > 0) update updatedActionPlanList;
    	return 'Manager Access for ' + selectedYear + ' were successfully granted.';
    	**/
    	//update record owner
    	errorList = setUpRecordOwner(bomPlanMap, mainBranchEmailSet, subComplexEmailSet, marketComplexEmailSet, regionEmailSet, userMap, errorList, allUserMap);
    	if(errorList != null && errorList.size() < 1000) {
	    	//update LeadershipPlan Owner
	    	updateLeaderShipPlanOwner(selectedYear, errorList);
    	}
    	
    	return errorList;
    }
    //set up record which need to be update owner field
    public static list<ErrorWarpper> setUpRecordOwner(map<Id, BoM_Plan__c> bomPlanMap, Set<String> mainBranchEmailSet, Set<String> subComplexEmailSet
    						,Set<String> marketComplexEmailSet, Set<String> regionEmailSet, map<String, list<User>> userMap
    						, list<ErrorWarpper> errorList, map<Id, User> allUserMap) {
    	
    	list<BoM_Plan__c> bomPlanUpdatedList = new list<BoM_Plan__c>();
    	list<FA_Goal__c> faGoalList = new list<FA_Goal__c>();
    	list<Action_Plan__c> actionPlanList = new list<Action_Plan__c>();
    	list<BoM_Plan__c> bomPlanList = bomPlanMap.values();
    	for(BoM_Plan__c bomPlan : bomPlanList) {
    		if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
    		if(bomPlan.Main_Branch__c != null) {
    			String errorId = bomPlan.Main_Branch__r.Id;
    			String mainBranchName = 'Main Branch: ' + bomPlan.Main_Branch__r.Name;
				if(bomPlan.Main_Branch__r.Manager_Main_Branch__r != null) {
					String email = '';
					if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Email != null) email = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Email;
					String customerId = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Id;
					String customerName = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Name;
					//wether main branch manager exist in the userMap or not
					if(mainBranchEmailSet.contains(email) && userMap.containskey(email)) {
						prepareUpdatedBoMPlanFAGoalActionPlanErrorList(email, customerId, customerName, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList);
					}else {
						String tmpEmail = '';
						String tmpId = '';
						String tmpName = '';
						if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c != null) {
							tmpEmail = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Sub_Supl_Complex_Email__c;
							if(tmpEmail != '' && userMap.containsKey(tmpEmail)) {
								prepareUpdatedBoMPlanFAGoalActionPlan(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap);
							}else if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c != null) {
								tmpEmail = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c;
								if(tmpEmail != '' && userMap.containsKey(tmpEmail)) {
									prepareUpdatedBoMPlanFAGoalActionPlan(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap);
								}else if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null){
									tmpId = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
									tmpName = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
									tmpEmail = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email;
									prepareRegionErrorList(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList, tmpId, tmpName);
								}else{
									String detail = 'Can\'t find the user record.';
									ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
									errorList.add(error);
								}
							}else{
								String detail = 'Can\'t find the user record.';
								ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
								errorList.add(error);
							}
						}else if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c != null) {
							tmpEmail = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Manager_Market_Complex_Email__c;
							if(tmpEmail != '' && userMap.containsKey(tmpEmail)) {
								prepareUpdatedBoMPlanFAGoalActionPlan(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap);
							}else if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
								tmpId = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
								tmpName = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
								tmpEmail = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email;
								prepareRegionErrorList(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList, tmpId, tmpName);
							}else{
								String detail = 'Can\'t find the user record.';
								ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
								errorList.add(error);
							}
						}else if(bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
							tmpId = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Id;
							tmpName = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Name;
							tmpEmail = bomPlan.Main_Branch__r.Manager_Main_Branch__r.Account.Region_Branch__r.Regional_President__r.Email;
							prepareRegionErrorList(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList, tmpId, tmpName);
						}else{
							String detail = 'Can\'t find the user record.';
							ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
							errorList.add(error);
						}
					}
				}
			}else if(bomPlan.Sub_Supl_Complex__c != null) {
				String errorId = bomPlan.Sub_Supl_Complex__r.Id + '';
				String subComplexName = 'Sub / Supl Complex: ' + bomPlan.Sub_Supl_Complex__r.Name + '';
				if(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r != null) {
					String email = '';
					if(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex_Email__c != null) email = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex_Email__c;
					String customeId = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Id;
					String customeName = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Name;
					//wether complex branch manager exist in the userMap or not
					if(subComplexEmailSet.contains(email) && userMap.containskey(email)) {
						prepareUpdatedBoMPlanFAGoalActionPlanErrorList( email, customeId, customeName, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList);
					}else {
						String tmpEmail = '';
						String tmpId = '';
						String tmpName = '';
						if(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Manager_Market_Complex_Email__c != null) {
							tmpEmail = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Manager_Market_Complex_Email__c;
							if(tmpEmail != '' && userMap.containsKey(tmpEmail)) {
								prepareUpdatedBoMPlanFAGoalActionPlan(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap);
							}else if(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
								tmpId = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Id;
								tmpName = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Name;
								tmpEmail = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Email;
								prepareRegionErrorList(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList, tmpId, tmpName);
							}else{
								String detail = 'Can\'t find the user record.';
								ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
								errorList.add(error);
							}
						}else if(bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
							tmpId = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Id;
							tmpName = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Name;
							tmpEmail = bomPlan.Sub_Supl_Complex__r.Manager_Sub_Supl_Complex__r.Account.Region_Branch__r.Regional_President__r.Email;
							prepareRegionErrorList(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList, tmpId, tmpName);
						}else{
							String detail = 'Can\'t find the user record.';
							ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
							errorList.add(error);
						}
					}
				}
			}else if(bomPlan.Market_Complex__c != null) {
				String errorId = bomPlan.Market_Complex__r.Id + '';
				String marketComplexName = 'Market Complex: ' + bomPlan.Market_Complex__r.Name + '';
				if(bomPlan.Market_Complex__r.Manager_Market_Complex__c != null) {
					String email = '';
					if(bomPlan.Market_Complex__r.Manager_Market_Complex_Email__c != null) email = bomPlan.Market_Complex__r.Manager_Market_Complex_Email__c;
					String complexId = bomPlan.Market_Complex__r.Manager_Market_Complex__r.Id + '';
    				String complexName = bomPlan.Market_Complex__r.Manager_Market_Complex__r.Name + '';
					//wether market branch manager exist in the userMap or not
					if(marketComplexEmailSet.contains(email) && userMap.containskey(email)) {
						prepareUpdatedBoMPlanFAGoalActionPlanErrorList(email, complexId, complexName, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList);
					}else {
						String tmpEmail = '';
						String tmpId = '';
						String tmpName = '';
						if(bomPlan.Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Email != null) {
							tmpId = bomPlan.Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Id;
							tmpName = bomPlan.Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Name;
							tmpEmail = bomPlan.Market_Complex__r.Manager_Market_Complex__r.Account.Region_Branch__r.Regional_President__r.Email;
							prepareRegionErrorList(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList, tmpId, tmpName);
						}else{
							String detail = 'Can\'t find the user record.';
							ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, '', '');
							errorList.add(error);
						}
					}
				}
				
			}else if(bomPlan.Region__c != null) {
				String errorId = bomPlan.Region__r.Id;
				String regionName = 'Region: ' + bomPlan.Region__r.Name;
				if(bomPlan.Region__r.Regional_President__r != null) {
					String email = '';
					if(bomPlan.Region__r.Regional_President__r.Email != null) email = bomPlan.Region__r.Regional_President__r.Email;
					String presidentId = bomPlan.Region__r.Regional_President__r.Id;
    				String presidentName = bomPlan.Region__r.Regional_President__r.Name;
					//wether regional branch manager exist in the userMap or not
					if(regionEmailSet.contains(email) && userMap.containskey(email)) {
						prepareUpdatedBoMPlanFAGoalActionPlanErrorList(email, presidentId, presidentName, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap, errorList);
					}else {
						String detail = 'Can\'t find the user associated with '+presidentName+'\'s email: ' + email + '.';
		    			ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, presidentId, presidentName);
		    			errorList.add(error);
					}
				}
			}
			
    	}
    	
    	errorList = updateObjectList(bomPlanUpdatedList, faGoalList, actionPlanList, allUserMap, errorList, 'BoM_Plan__c');
    	
    	errorList = updateObjectList(bomPlanUpdatedList, faGoalList, actionPlanList, allUserMap, errorList, 'FA_Goal__c');
    	
		errorList = updateObjectList(bomPlanUpdatedList, faGoalList, actionPlanList, allUserMap, errorList, 'Action_Plan__c');
		
    	
    	//updateBomPlanList(bomPlanUpdatedList, allUserMap, errorList, bomPlanMap);
    	
    	return errorList;
    }
    
    public static void prepareUpdatedBoMPlanFAGoalActionPlanErrorList(String email, String tmpId, String tmpName,BoM_Plan__c bomPlan, list<BoM_Plan__c> bomPlanUpdatedList
    												, list<FA_Goal__c> faGoalList, list<Action_Plan__c> actionPlanList , map<String, list<User>> userMap, list<ErrorWarpper> errorList) {
    	list<User> userList = userMap.get(email);
		if(userList != null) {
			//bomPlan.OwnerId = userList.get(0).Id;
			bomPlanUpdatedList.add(new BoM_Plan__c(Id=bomPlan.Id, Name=bomPlan.Name, OwnerId=userList.get(0).Id));
			getUpdatedFaGoalList(faGoalList, bomPlan.FA_Goals__r, userList.get(0).Id);
			getUpdatedActionPlanist(actionPlanList, bomPlan.Action_Plans__r, userList.get(0).Id);
			if(userList.size() > 1) {
				String detail = 'Find multiple users associated with '+tmpName+'\'s email: ' + email + '.';
				ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, tmpId, tmpName);
				errorList.add(error);
			}
		}else {
			String detail = 'Can\'t find the user associated with '+tmpName+'\'s email: ' + email + '.';
			ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, tmpId, tmpName);
			errorList.add(error);
		}
    }
    
    public static void prepareUpdatedBoMPlanFAGoalActionPlan(String tmpEmail, BoM_Plan__c bomPlan, list<BoM_Plan__c> bomPlanUpdatedList, list<FA_Goal__c> faGoalList
   																				 , list<Action_Plan__c> actionPlanList , map<String, list<User>> userMap) {
    	list<User> userList = userMap.get(tmpEmail);
		if(userList != null) {
			bomPlanUpdatedList.add(new BoM_Plan__c(Id=bomPlan.Id, Name=bomPlan.Name, OwnerId=userList.get(0).Id));
			getUpdatedFaGoalList(faGoalList, bomPlan.FA_Goals__r, userList.get(0).Id);
			getUpdatedActionPlanist(actionPlanList, bomPlan.Action_Plans__r, userList.get(0).Id);
		}
    }
    
    public static void  prepareRegionErrorList(String tmpEmail, BoM_Plan__c bomPlan, list<BoM_Plan__c> bomPlanUpdatedList, list<FA_Goal__c> faGoalList
   												, list<Action_Plan__c> actionPlanList , map<String, list<User>> userMap, list<ErrorWarpper> errorList
   												, String tmpId, String tmpName) {
		if(tmpEmail != '' && userMap.containsKey(tmpEmail)) {
			prepareUpdatedBoMPlanFAGoalActionPlan(tmpEmail, bomPlan, bomPlanUpdatedList, faGoalList, actionPlanList , userMap);
		}else {
			String detail = 'Can\'t find the user associated with '+tmpName+'\'s email: ' + tmpEmail + '.';
			ErrorWarpper error = new ErrorWarpper(bomPlan.Id,  bomPlan.Name, detail, tmpId, tmpName);
			errorList.add(error);
		}
    }
    /**
    public static void updateBomPlanList(list<BoM_Plan__c>bomPlanUpdatedList, map<Id, User> allUserMap, list<ErrorWarpper> errorList, map<Id, BoM_Plan__c> bomPlanMap) {
    	Database.SaveResult[] resultList3 = null;   
    	if(bomPlanUpdatedList != null && bomPlanUpdatedList.size() > 0) {
	    	Integer index = 0;
    		resultList3 = Database.update(bomPlanUpdatedList, false);
	    	///update bomPlanMap.values();
	    	for(Database.SaveResult sr : resultList3) {
				if(sr.isSuccess()) continue;
				for(Database.Error err : sr.getErrors()) {
					String userName = '';
					if(allUserMap.containsKey(bomPlanUpdatedList.get(index).OwnerId)) {
						userName = allUserMap.get(bomPlanUpdatedList.get(index).OwnerId).Name;
					}
					ErrorWarpper error = new ErrorWarpper(bomPlanUpdatedList.get(index).Id, 'BoM Plan: '+bomPlanUpdatedList.get(index).Name, err.getMessage(), bomPlanUpdatedList.get(index).OwnerId, userName);
					errorList.add(error);
				}
				index ++;
			}
    	}
    }
    **/
    //update record owner
    public static list<ErrorWarpper> updateObjectList(list<BoM_Plan__c> bomPlanUpdatedList, list<FA_Goal__c> faGoalList, list<Action_Plan__c> actionPlanList, map<Id, User> allUserMap, list<ErrorWarpper> errorList, String objectType) {
    	Database.SaveResult[] resultList = null;
    	if(objectType == 'BoM_Plan__c') {
	    	if(bomPlanUpdatedList == null || bomPlanUpdatedList.size() == 0) return errorList;
			resultList = Database.update(bomPlanUpdatedList, false);
    	}
    	if(objectType == 'FA_Goal__c') {
	    	if(faGoalList == null || faGoalList.size() == 0) return errorList;
			resultList = Database.update(faGoalList, false);
    	}
    	if(objectType == 'Action_Plan__c') {
	    	if(actionPlanList == null || actionPlanList.size() == 0) return errorList;
	    	resultList = Database.update(actionPlanList, false);
    	}
    	
    	//BPCommonUtil.logJson('bomPlanUpdatedList', bomPlanUpdatedList);
    	//BPCommonUtil.logJson('resultList', resultList);
    	
		Integer index = 0;
    	///update bomPlanMap.values();
    	for(Database.SaveResult sr : resultList) {
    		if(errorList != null && errorList.size() >= 1000) {
				return errorList;
			}
			if(sr.isSuccess()) {
				index ++;
				continue;
			}
			//put all error message into error list
			for(Database.Error err : sr.getErrors()) {
				if(errorList != null && errorList.size() >= 1000) {
					return errorList;
				}
				String userName = '';
				String ownerId = '';
				String objectId = '';
				String objectName = '';
				if(objectType == 'BoM_Plan__c') {
					ownerId = bomPlanUpdatedList.get(index).OwnerId;
					objectId = bomPlanUpdatedList.get(index).Id;
					objectName = bomPlanUpdatedList.get(index).Name;
				}
				if(objectType == 'FA_Goal__c') {
					ownerId = faGoalList.get(index).OwnerId;
					objectId = faGoalList.get(index).Id;
					objectName = faGoalList.get(index).Name;
				}
				if(objectType == 'Action_Plan__c') {
					ownerId = actionPlanList.get(index).OwnerId;
					objectId = actionPlanList.get(index).Id;
					objectName = faGoalList.get(index).Name;
				}
				if(allUserMap.containsKey(ownerId)) {
					userName = allUserMap.get(ownerId).Name;
				}
				ErrorWarpper error = new ErrorWarpper(objectId, objectName, err.getMessage(), ownerId, userName);
				errorList.add(error);
			}
			index ++;
		}
		return errorList;
    }
    //set fa goal owner
    public static list<FA_Goal__c> getUpdatedFaGoalList(list<FA_Goal__c> faGoalList, list<FA_Goal__c> subFaGoalList, String ownerId) {
    	if(subFaGoalList == null) return faGoalList;
    	for(FA_Goal__c faGoal : subFaGoalList) {
			faGoal.OwnerId = ownerId;
			faGoalList.add(faGoal);
		}
		return faGoalList;
    }
    //set action plan owner
    public static list<Action_Plan__c> getUpdatedActionPlanist(list<Action_Plan__c> actionPlanList, list<Action_Plan__c> subActionPlanList, String ownerId) {
    	if(actionPlanList == null) return actionPlanList;
    	for(Action_Plan__c actionPlan : subActionPlanList) {
			actionPlan.OwnerId = ownerId;
			actionPlanList.add(actionPlan);
		}
		return actionPlanList;
    }
    //update leadership plan owner
    public static void updateLeaderShipPlanOwner(String selectedYear, list<ErrorWarpper> errorList) {
    	
    	list<Leadership_Plan__c> updatedBomPlanList = new list<Leadership_Plan__c>();
    	Set<String> customerEmailSet = new Set<String>(); 
    	list<Leadership_Plan__c> updatedLeadshipPlanList = new list<Leadership_Plan__c>();
    	map<Id, Leadership_Plan__c> updateLeadshipPlanMap = new map<Id, Leadership_Plan__c>();
    	//prepare update record
    	for(Leadership_Plan__c leader : [Select Id
    										, Name
    										, FA__r.Email
    										, FA__r.Name
    										, FA__r.Id
    										, FA__c
    									 From Leadership_Plan__c 
    									 Where FA__c != null
    									 And Year_Text__c =: selectedYear]) {
			if(errorList != null && errorList.size() >= 1000) return;
    		if(leader.FA__r.Email != null) {
    			customerEmailSet.add(leader.FA__r.Email);
    			updateLeadshipPlanMap.put(leader.Id, leader);
    		}else {
    			String detail = 'Customer email is blank.';
    			ErrorWarpper error = new ErrorWarpper(leader.Id, 'Leadership Plan: ' + leader.Name, detail, leader.FA__r.Id, leader.FA__r.Name);
    			errorList.add(error);
    		}
    	}
    	if(errorList != null && errorList.size() >= 1000) return;
    	//get user by customer email set
    	list<User> userList = getUsersByEmail(customerEmailSet);
    	map<String, list<User>> userMap = getUserMap(userList);
    	
    	map<Id, User> allUserMap = new map<Id, User>();
    	for(User u : userList) {
    		allUserMap.put(u.Id, u);
    	}
    	//set owner id
    	for(Leadership_Plan__c leader : updateLeadshipPlanMap.values()) {
    		if(errorList != null && errorList.size() >= 1000) return;
    		String email = leader.FA__r.Email;
    		String detail = '';
    		String customerName = leader.FA__r.Name;
    		if(userMap != null && userMap.containsKey(email)) {
    			String ownerId = userMap.get(email).get(0).Id;
    			Leadership_Plan__c tmp = new Leadership_Plan__c(Id=leader.Id, Name=leader.Name, OwnerId=ownerId);
    			updatedLeadshipPlanList.add(tmp);
    			if(userMap.get(email).size() > 1) {
    				detail = 'Find multiple users associated with '+customerName+'\'s email: ' + email + '.';
					ErrorWarpper error = new ErrorWarpper(leader.Id, 'Leadership Plan: ' + leader.Name, detail, leader.FA__r.Id, customerName);
					errorList.add(error);
    			}
    		}else {
    			detail = 'Can\'t find the user associated with '+ customerName + '\'s email:' + email; 
    			ErrorWarpper error = new ErrorWarpper(leader.Id, 'Leadership Plan: ' + leader.Name, detail, leader.FA__r.Id, customerName);
    			errorList.add(error);
    		}
    	}
    	if(errorList != null && errorList.size() >= 1000) return;
    	Database.SaveResult[] resultList = null;
    	if(updatedLeadshipPlanList == null || updatedLeadshipPlanList.size() == 0) return;
    	//update leadership plan owner
    	resultList = Database.update(updatedLeadshipPlanList, false);
		Integer index = 0;
    	for(Database.SaveResult sr : resultList) {
    		if(errorList != null && errorList.size() >= 1000) return;
			if(sr.isSuccess()) {
				index ++;
				continue;
			}
			//put all error message into error list
			for(Database.Error err : sr.getErrors()) {
				if(errorList != null && errorList.size() >= 1000) return;
				String userName = '';
				String ownerId = updatedLeadshipPlanList.get(index).OwnerId;
				String objectId = updatedLeadshipPlanList.get(index).Id;
				String objectName = '';
				objectName = 'Leadership Plan: ' + updatedLeadshipPlanList.get(index).Name;
				if(allUserMap.containsKey(ownerId)) {
					userName = allUserMap.get(ownerId).Name;
				}
				ErrorWarpper error = new ErrorWarpper(objectId, objectName, err.getMessage(), ownerId, userName);
				errorList.add(error);
			}
			index ++;
		}
    }
    
    public class ErrorWarpper {
    	
    	public String errorId { get;set; }
    	
    	public String errorName { get;set; }
    	
    	public String customerId { get;set; }
    	
    	public String customerName { get;set; }
    	
    	public String errorDetail { get;set; }
    	
    	public ErrorWarpper(String errorId, String errorName, String errorDetail) {
    		this.errorId = errorId;
    		this.errorName = errorName;
    		this.errorDetail = errorDetail;
    	}
    	
    	public ErrorWarpper(String errorId, String errorName, String errorDetail, String customerId, String customerName) {
    		this.errorId = errorId;
    		this.errorName = errorName;
    		this.errorDetail = errorDetail;
    		this.customerId = customerId;
    		this.customerName = customerName;
    	}
    }
    /************************************************ update record owner end ****************************************/
}