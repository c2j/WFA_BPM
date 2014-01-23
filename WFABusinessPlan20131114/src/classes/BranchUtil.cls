/**************************************************************************************************
 * Purpose: Branch Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-06
 * Modify History:
 * Keen    2013-11-06    Created
***************************************************************************************************/
global class BranchUtil {
	public static void processAfterTrg(){
		List<Account> newBranchList = trigger.new;
		Map<Id, Account> toCopyBranchMap = new Map<Id, Account>();
		Map<Id, Account> toTransferBranchMap = new Map<Id, Account>();
		
		//Start picking out the records
		if(trigger.isInsert){
			for(Account newBranch : newBranchList){
				if(BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_Advisory_Flows__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_New_Key_Households__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_Lending__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_NetIncome__c) != 0
					
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Prior_Year_T12_Recruited__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Prior_Year_T12_Attrited__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.YTD_T12_Recruited__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.YTD_T12_Attrited__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X3_Year_Avg_T12_Hired__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X3_Year_Avg_T12_Attrited__c) != 0
					
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Other_Revenue__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Prior_Year_Profit_Margin__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Allocated_Revenue__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.PriorYearNetIncome__c) != 0
					
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Prior_Year_Sales_Revenue__c) != 0
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Annualized_Sales_Revenue__c) != 0){
						
						toCopyBranchMap.put(newBranch.Id, newBranch);
				}
			}
		}
		else if(trigger.isUpdate){
			for(Account newBranch : newBranchList){
				Account oldBranch = (Account)trigger.oldMap.get(newBranch.Id);

				//If any fields below to capture are changed, update them into the corresponding BoM Plan
				if(BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_Advisory_Flows__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.X2013_Tonnage_Goal_Advisory_Flows__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_New_Key_Households__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.X2013_Tonnage_Goal_New_Key_Households__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_Lending__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.X2013_Tonnage_Goal_Lending__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X2013_Tonnage_Goal_NetIncome__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.X2013_Tonnage_Goal_NetIncome__c)
					
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Prior_Year_T12_Recruited__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.Prior_Year_T12_Recruited__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Prior_Year_T12_Attrited__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.Prior_Year_T12_Attrited__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.YTD_T12_Recruited__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.YTD_T12_Recruited__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.YTD_T12_Attrited__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.YTD_T12_Attrited__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X3_Year_Avg_T12_Hired__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.X3_Year_Avg_T12_Hired__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.X3_Year_Avg_T12_Attrited__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.X3_Year_Avg_T12_Attrited__c)
					
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Other_Revenue__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.Other_Revenue__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Prior_Year_Profit_Margin__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.Prior_Year_Profit_Margin__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Allocated_Revenue__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.Allocated_Revenue__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.PriorYearNetIncome__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.PriorYearNetIncome__c)
					
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.PriorYearNetRevenue__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.PriorYearNetRevenue__c)
					|| BPCommonUtil.getDefaultNumberFormat(newBranch.Annualized_Sales_Revenue__c) != BPCommonUtil.getDefaultNumberFormat(oldBranch.Annualized_Sales_Revenue__c)){
						
					if(!toCopyBranchMap.containsKey(newBranch.Id)){
						toCopyBranchMap.put(newBranch.Id, newBranch);
					}
				}
				
				if(newBranch.Main_Branch__c != null && newBranch.Main_Branch__c != oldBranch.Main_Branch__c){
					if(!toTransferBranchMap.containsKey(newBranch.Id)){
						toTransferBranchMap.put(newBranch.Id, newBranch);
					}
				}
			}
		}
		
		//Start handling the records
		if(toCopyBranchMap == null || toCopyBranchMap.values().size()==0){
			return;
		}
		
		//Copy the Branch metric info to the BoM Plan when branch is updated
		//system.debug('*** Start copyToBoMPlanAndSave: ' + toCopyBranchMap.values());
		copyToBoMPlanAndSave(toCopyBranchMap.values());
		
		//Transfer the FA Goals to the assosicated plan when the branch is updated to another main branch. 
		system.debug('*** Start transferFAGoals');
		transferFAGoals(toTransferBranchMap.values());
	}
	
	
	//Transfer FA Goals when the Branch is updated to another main branch
	public static void transferFAGoals(list<Account> branchList){
		set<Id> branchIdSet = new set<Id>();
		for(Account branch : branchList){
			branchIdSet.add(branch.Id);
		}
		
		Map<Id, Contact> toUpdateFAMap = new Map<Id, Contact>([
			Select Id, 
				Name,
				AccountId
			From Contact
			Where AccountId in :branchIdSet
		]);
		//Get the FA to be transferred based on the branchlist
		
		CustomerUtil.transferFAGoalList(toUpdateFAMap);
	}
	
	//Copy the Goals (Sum up from Branch Level) of the metrics to the BoM Plan (Main Branch Level) and DML.
	public static void copyToBoMPlanAndSave(list<Account> fromBranchList){
		String mostRecentYear = getMostRecentYear();
		set<Id> mainBranchIdSet = getMainBranchIdSet(fromBranchList);
		list<BoM_Plan__c> bomPlanList = getBoMPlanList(mostRecentYear, mainBranchIdSet);
		
		list<BoM_Plan__c> toUpdateBoMPlanList = copyToBoMPlan(mainBranchIdSet, mostRecentYear, bomPlanList);
		
		update toUpdateBoMPlanList;
	}
	
	//Copy the Goals (Sum up from Branch Level) of the metrics to the BoM Plan (Main Branch Level).
	public static list<BoM_Plan__c> copyToBoMPlan(set<Id> mainBranchIdSet, String year, list<BoM_Plan__c> bomPlanList){
		
		list<BoM_Plan__c> toUpdateBoMPlanList = new list<BoM_Plan__c>();
		map<String, AggregateResult> groupedResultMap = getGroupedBranchMap(mainBranchIdSet);
		
		for(BoM_Plan__c bomPlan : bomPlanList){
			String comboId = bomPlan.Main_Branch__c;
			if(groupedResultMap.containsKey(comboId)){
				AggregateResult ar = groupedResultMap.get(comboId);
				bomPlan.Tonnage_Goal_Advisory_Net_Flows__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalNetFlows'));
				bomPlan.Tonnage_Goal_New_Key_HHs__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalNewKeyHHs'));
				bomPlan.Tonnage_Goal_Lending__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalLending'));
				
				//Recruiting
				bomPlan.Prior_Year_T12_Attrited__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalPriorAttrited'));
				bomPlan.Prior_Year_T12_Recruited__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalPriorRecruited'));
				bomPlan.X3_Year_Avg_T12_Recruited__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('total3YearRecruited'));
				bomPlan.X3_Year_Avg_T12_Attrited__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('total3YearAttrited'));
				
				//Net Income
				Decimal totalYTDNetIncome = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalYTDNetIncome'));
				Decimal totalYTDRevenue = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalYTDRevenue'));
				
				bomPlan.Prior_Net_Income__c = BPCommonUtil.getDefaultNumberFormat((Decimal) ar.get('totalPriorNetIncome'));
				bomPlan.YTD_Net_Income__c = totalYTDNetIncome;
				bomPlan.Annualized_Net_Income__c = BPCommonUtil.getDefaultNumberFormat((Decimal) ar.get('totalAnlzdNetIncome'));
				bomPlan.Tonnage_Goal_Net_Income__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalNetIncome'));

				if(totalYTDRevenue == 0){
					bomPlan.YTD_Profit_Margin__c = 0;
				}
				else{
					bomPlan.YTD_Profit_Margin__c = 100 * totalYTDNetIncome/totalYTDRevenue;
				}
				
				//Profit Margin & Revenue
				Decimal totalPriorNetIncome = BPCommonUtil.getDefaultNumberFormat((Decimal) ar.get('totalPriorNetIncome'));
				Decimal totalPriorRevenue = BPCommonUtil.getDefaultNumberFormat((Decimal) ar.get('totalPriorRevenue'));
				bomPlan.Allocated_Revenue__c = BPCommonUtil.getDefaultNumberFormat((Decimal) ar.get('totalAllocatedRevenue'));
				bomPlan.Other_Revenue__c = BPCommonUtil.getDefaultNumberFormat((Decimal)ar.get('totalOtherRevenue'));
				if(totalPriorRevenue == 0){
					bomPlan.Prior_Year_Profit_Margin__c = 0;
				}
				else{
					bomPlan.Prior_Year_Profit_Margin__c = 100 * totalPriorNetIncome/totalPriorRevenue;
				}
				
				toUpdateBoMPlanList.add(bomPlan);
			}
		}
		return toUpdateBoMPlanList;
	}
	
	
	
	public static list<BoM_Plan__c> getBoMPlanList(String year, set<Id> mainBranchIdSet){
		list<BoM_Plan__c> bomPlanList = [Select 
											Id, 
											Name,
											Main_Branch__c,
											Year_Text__c
											From BoM_Plan__c
											Where Year_Text__c = :year
											And Main_Branch__c in :mainBranchIdSet];
		return bomPlanList;
	}
	
	
	//Retrive the branch summary info grouped by as of date and main branch. Then convert it into a Map with AsOfDate + MainBranchId as Id
	public static map<String, AggregateResult> getGroupedBranchMap(set<Id> mainBranchIdSet){
		map<String, AggregateResult> groupedResultMap = new map<String, AggregateResult>();
		list<AggregateResult> groupedResultList = getGroupedBranchList(mainBranchIdSet);
		for(AggregateResult aggBranch : groupedResultList){
			String comboId = String.valueOf(aggBranch.get('mainBranch'));
			if(!groupedResultMap.containsKey(comboId)){
				groupedResultMap.put(comboId, aggBranch);
			}
		}
		return groupedResultMap;
	}
	
	public static list<AggregateResult> getGroupedBranchList(set<Id> mainBranchIdSet){
		list<AggregateResult> groupedResultList = [
			Select 
				Main_Branch__c mainBranch,
				SUM(X2013_Tonnage_Goal_Advisory_Flows__c) totalNetFlows,
				SUM(X2013_Tonnage_Goal_New_Key_Households__c) totalNewKeyHHs,
				SUM(X2013_Tonnage_Goal_Lending__c) totalLending,
				
				SUM(Prior_Year_T12_Recruited__c) totalPriorRecruited,
				SUM(Prior_Year_T12_Attrited__c) totalPriorAttrited,
				//SUM(YTD_T12_Recruited__c) totalYTDRecruited,
				//SUM(YTD_T12_Attrited__c) totalYTDAttrited,
				SUM(X3_Year_Avg_T12_Hired__c) total3YearRecruited,
				SUM(X3_Year_Avg_T12_Attrited__c) total3YearAttrited,
				//SUM(Prior_Year_Sales_Revenue__c) totalPriorSales,
				//SUM(Annualized_Sales_Revenue__c) totalAnlizedSales
				
				//Net Income
				SUM(PriorYearNetIncome__c) totalPriorNetIncome,
				SUM(YTD_Net_Income__c) totalYTDNetIncome,
				SUM(Anlzd_Net_Income__c) totalAnlzdNetIncome,
				SUM(X2013_Tonnage_Goal_NetIncome__c) totalNetIncome,
				SUM(YTD_Net_Revenue__c) totalYTDRevenue,
				
				//Profit Margin & Net Income
				SUM(Allocated_Revenue__c) totalAllocatedRevenue,
				SUM(Other_Revenue__c) totalOtherRevenue,
				SUM(PriorYearNetRevenue__c) totalPriorRevenue
				
			From Account
			Where Main_Branch__c in :mainBranchIdSet
			And Active__c = true
			Group By Main_Branch__c];
		
		return groupedResultList;
	}
	
	//Get the most recent year from all BoM Plans
	public static String getMostRecentYear(){
		String mostRecentYear = '';
		list<AggregateResult> aggList = [
			Select MAX(Year__c) year
			From BoM_Plan_Group__c
		];
		
		for(AggregateResult ar : aggList){
			mostRecentYear = String.valueOf(ar.get('year'));
		}
		
		return mostRecentYear;
	}
	
	//Get an Id Set from branchList
	public static set<Id> getMainBranchIdSet(list<Account> branchList){
		set<Id> mainBranchIdSet = new set<Id>();
		for(Account branch : branchList){
			mainBranchIdSet.add(branch.Main_Branch__c);
		}
		return mainBranchIdSet;
	}
	
	//****************************** Start Testing ********************************************************************
	
	private static Channel__c mChannel;
	public static Channel__c createPCGChannel(){
		//Creating channel exceeding the limit. So create outside.
		return null;
		
		if(mChannel == null){
			BPCommonUtil.log('Start creating channel');
			mChannel = new Channel__c();
			mChannel.Name = 'PCG';
			insert mChannel;
			BPCommonUtil.log('End creating channel');
		}
		
		return mChannel;
	}
	
	
	/* For testing */
	public static list<Account> getSampleBranchList(Integer branchCount, Main_Branch__c mainBranch, Channel__c channel){
		list<Account> branchList = new list<Account>();
		Account branch;
		
		//Id pcgRecordType = getRecordType('PCG');
		
		
		Integer maxCount = branchCount;
		for(Integer i = 0; i<=maxCount; i++){
			branch = new Account();
			branch.Name = 'Branch' + i;
			branch.PRIORYEARNETINCOME__C = 1900139;
			branch.YTD_NET_INCOME__C = 1900140;
			branch.ANLZD_NET_INCOME__C = 1900141;
			branch.X2013_TONNAGE_GOAL_NETINCOME__C = 1900142;
			branch.X2013_TONNAGE_GOAL_LENDING__C = 1900143;
			branch.X2013_TONNAGE_GOAL_NEW_KEY_HOUSEHOLDS__C = 31;
			branch.X2013_TONNAGE_GOAL_ADVISORY_FLOWS__C = 1900145;
			//branch.RecordTypeId = pcgRecordType;
			if(channel != null){
				branch.Channel_Branch__c = channel.Id;
			}
			
			branch.Main_Branch__c = mainBranch.Id;
			branchList.add(branch);
		}
		
		return branchList;
	}
	
	/* For testing */
	public static list<Account> createMassSampleBranchWithFAs(Main_Branch__c mainBranch){
		Channel__c channel = createPCGChannel();
		
		list<Account> branchList = getSampleBranchList(200, mainBranch, channel);
		system.debug('*** Start insert Branches.');
		insert branchList;
		
		system.debug('*** Finished insert Branches.');
		list<Contact> faList = new list<Contact>();
		Integer i = 0;
		for(Account branch : branchList){
			if(i==0){
				faList.addAll(CustomerUtil.getSampleFAList(210, branch)); 
				i++;
			}
			else{
				faList.addAll(CustomerUtil.getSampleFAList(1, branch)); 
			}
		}
		
		system.debug('*** Start inserting FAs.');
		insert faList;
		system.debug('*** Finished inserting FAs.');
		
		list<Ranking__c> rankingList = new list<Ranking__c>();
		for(Contact fa : faList){
			rankingList.addAll(RankingUtil.getSampleRankingList(1, fa));
		}
		
		system.debug('*** Start inserting Ranking');
		insert rankingList;
		system.debug('*** Finished inserting Ranking');
		
		return branchList;
	}
	
	/* For testing */
    public static list<Account> createSampleBranchWithFAs_BK(Main_Branch__c mainBranch){
		Channel__c channel = createPCGChannel();
		list<Account> branchList = getSampleBranchList(3, mainBranch, channel);
		system.debug('*** Start insert Branches.');
		insert branchList;
		BPCommonUtil.logProfiling('getSampleBranchList');
        
		system.debug('*** Finished insert Branches.');
		list<Contact> faList = new list<Contact>();
		
		Integer i = 0;
		for(Account branch : branchList){
			if(i==0){
				list<Contact> createdFAList = CustomerUtil.getSampleFAList(30, branch);
				faList.addAll(createdFAList); 
				branch.Manager_Branch__c = createdFAList[0].Id;
				i++;
			}
			else{
				list<Contact> createdFAList = CustomerUtil.getSampleFAList(1, branch);
				faList.addAll(createdFAList); 
				branch.Manager_Branch__c = createdFAList[0].Id;
			}
		}
        
		
		system.debug('*** Start inserting FAs.');
		insert faList;
        BPCommonUtil.logProfiling('Add faList');
		update branchList;
        BPCommonUtil.logProfiling('Update Branch Manager');
		
		mainBranch.Manager_Main_Branch__c = faList[0].Id;
		update mainBranch;
		system.debug('*** Finished inserting FAs.');
		BPCommonUtil.logProfiling('Update Main Branch Manager');
        
		list<Ranking__c> rankingList = new list<Ranking__c>();
		for(Contact fa : faList){
			rankingList.addAll(RankingUtil.getSampleRankingList(1, fa));
		}
		
		system.debug('*** Start inserting Ranking');
		insert rankingList;
		system.debug('*** Finished inserting Ranking');
		BPCommonUtil.logProfiling('Insert rankingList');
        
		return branchList;
	}
    
	public static list<Account> createSampleBranchWithFAs(Main_Branch__c mainBranch){
		Channel__c channel = createPCGChannel();
		list<Account> branchList = getSampleBranchList(3, mainBranch, channel);
		system.debug('*** Start insert Branches.');
		insert branchList;
		BPCommonUtil.logProfiling('getSampleBranchList');
        
		system.debug('*** Finished insert Branches.');
		list<Contact> faList = new list<Contact>();
		
		Integer i = 0;
		for(Account branch : branchList){
			if(i==0){
				list<Contact> createdFAList = CustomerUtil.getSampleFAList(30, branch);
				faList.addAll(createdFAList); 
				branch.Manager_Branch__c = createdFAList[0].Id;
				i++;
			}
			else{
				list<Contact> createdFAList = CustomerUtil.getSampleFAList(1, branch);
				faList.addAll(createdFAList); 
				branch.Manager_Branch__c = createdFAList[0].Id;
			}
		}
        
		
		system.debug('*** Start inserting FAs.');
		insert faList;
        BPCommonUtil.logProfiling('Add faList');
		update branchList;
        BPCommonUtil.logProfiling('Update Branch Manager');
		
		mainBranch.Manager_Main_Branch__c = faList[0].Id;
		update mainBranch;
		system.debug('*** Finished inserting FAs.');
		BPCommonUtil.logProfiling('Update Main Branch Manager');
        
		list<Ranking__c> rankingList = new list<Ranking__c>();
		for(Contact fa : faList){
			rankingList.addAll(RankingUtil.getSampleRankingList(1, fa));
		}
		
		system.debug('*** Start inserting Ranking');
		insert rankingList;
		system.debug('*** Finished inserting Ranking');
		BPCommonUtil.logProfiling('Insert rankingList');
        
		return branchList;
	}
	
	
	/* For testing */
	public static list<Account> createSampleBranchWithFAs(list<Main_Branch__c> mainBranchList){
		
		list<Account> branchList = new list<Account>();
		
		for(Main_Branch__c mainBranch : mainBranchList){
			branchList.addAll(createSampleBranchWithFAs(mainBranch));
		}
		
		return branchList;
	}
	
	/* For testing */
	public static list<BoM_Plan__c> createSamplePlanWithGoals(list<Main_Branch__c> mainBranchList){
		BoM_Plan_Group__c planGroup = BPBranchBusinessPlanUtil.createSampleBoMPlanGroup();
		
		list<BoM_Plan__c> bomPlanList  = new list<BoM_Plan__c>();
		
		for(Main_Branch__c mainBranch : mainBranchList){
			bomPlanList.addAll(BPBranchBusinessPlanUtil.getSampleBoMPlanList(1, mainBranch, planGroup));
		}
		insert bomPlanList;
		
		list<Contact> faList =[Select Id, Name From Contact];
		list<FA_Goal__c> goalList = new list<FA_Goal__c>();
		for(Contact fa : faList){
			goalList.addAll(FAGoalUtil.getSampleFAGoalList(1, bomPlanList[0], fa));
		}
		insert goalList;
		
		return bomPlanList;
	}
	
	/* For testing */
	public static list<Account> createSampleBranchWithFAsMainBranchAndPlan(){
		
		list<Main_Branch__c> mainBranchList = MainBranchUtil.getSampleMainBranchList(0);
		insert mainBranchList;
        BPCommonUtil.logProfiling('getSampleMainBranchList');
		
		list<Account> branchList = createSampleBranchWithFAs(mainBranchList);
        BPCommonUtil.logProfiling('createSampleBranchWithFAs');
        
		list<BoM_Plan__c> bomPlanList = createSamplePlanWithGoals(mainBranchList);
        BPCommonUtil.logProfiling('createSamplePlanWithGoals');
		
		return branchList;
	}
	
	/* For testing */
	public static Id getRecordType(String recordTypeName){
		list<RecordType> rtList = [select Id from RecordType where Name = 'PCG' and SobjectType = 'Account'];
		return rtList[0].Id;
	}
	
	/* For testing */
	public static List<Branch_Business_Plan_Help__c> createBranchBusinessPlanHelp() {
		Branch_Business_Plan_Help__c plan1 = new Branch_Business_Plan_Help__c(Name='Plan1', Category__c='New Key HHs', Help_Link__c='www.google.com');
		Branch_Business_Plan_Help__c plan2 = new Branch_Business_Plan_Help__c(Name='Plan2', Category__c='Advisory', Help_Link__c='www.google.com');
		Branch_Business_Plan_Help__c plan3 = new Branch_Business_Plan_Help__c(Name='Plan2', Category__c='Lending', Help_Link__c='www.google.com');
		Branch_Business_Plan_Help__c plan4 = new Branch_Business_Plan_Help__c(Name='Plan2', Category__c='Net Income', Help_Link__c='www.google.com');
		List<Branch_Business_Plan_Help__c> planList = new List<Branch_Business_Plan_Help__c>();
		planList.add(plan1);
		planList.add(plan2);
		planList.add(plan3);
		planList.add(plan4);
		insert planList;
		return planList;
	}
	//Get sample complex list
	public static list<Sub_Supl_Complex__c> getComplexList(Market_Complex__c market, Contact manager){
		list<Sub_Supl_Complex__c> complexList = new list<Sub_Supl_Complex__c>();
		Sub_Supl_Complex__c complex;
		
		complex = new Sub_Supl_Complex__c();
		complex.Market_Complex__c = market.Id;
		complex.Name = 'Test Complex 1';
		complex.Manager_Sub_Supl_Complex__c = manager.Id;
		complexList.add(complex);
		
		complex = new Sub_Supl_Complex__c();
		complex.Market_Complex__c = market.Id;
		complex.Name = 'Test Complex 2';
		complex.Manager_Sub_Supl_Complex__c = manager.Id;
		complexList.add(complex);
		
		return complexList;
	}
	//Get sample market list
	public static list<Market_Complex__c> getMarketList(Region__c region, Contact manager){
		list<Market_Complex__c> marketList = new list<Market_Complex__c>();
		Market_Complex__c market;
		
		market = new Market_Complex__c();
		market.Region2__c = region.Id;
		market.Name = 'Test market 1';
		market.Manager_Market_Complex__c = manager.Id;
		marketList.add(market);
		
		market = new Market_Complex__c();
		market.Region2__c = region.Id;
		market.Name = 'Test market 2';
		market.Manager_Market_Complex__c = manager.Id;
		marketList.add(market);
		
		return marketList;
	}
	
	//Get sample region list
	public static list<Region__c> getRegionList(Contact manager){
		list<Region__c> regionList = new list<Region__c>();
		Region__c region;
		
		region = new Region__c();
		region.Name = 'Test market 1';
		region.Regional_President__c = manager.Id;
		regionList.add(region);
		
		region = new Region__c();
		region.Name = 'Test market 2';
		region.Regional_President__c = manager.Id;
		regionList.add(region);
		
		return regionList;
	}
	//Create sample branches with FAs, Main Branch, Complex, Market and Region setup
	public static list<Account> createSampleBranchWithFAsMainBranchComplexMarketAndRegion(){
		BPCommonUtil.log('Start createSampleBranchWithFAsMainBranchAndPlan');
		
		list<Account> branchList = createSampleBranchWithFAsMainBranchAndPlan();
		list<Main_Branch__c> mbList = [Select Manager_Main_Branch__r.Id From Main_Branch__c];
		Contact mbManager = mbList[0].Manager_Main_Branch__r;
		
		BPCommonUtil.logProfiling('createSampleBranchWithFAsMainBranchAndPlan');
		BPCommonUtil.log('Done createSampleBranchWithFAsMainBranchAndPlan');
		
		list<Region__c> regionList = getRegionList(mbManager);
		insert regionList;
		BPCommonUtil.logProfiling('insert regionList');
		
		list<Market_Complex__c> marketList = getMarketList(regionList[0],mbManager);
		insert marketList;
		BPCommonUtil.logProfiling('insert marketList');
		
		list<Sub_Supl_Complex__c> complexList = getComplexList(marketList[0], mbManager);
		insert complexList;
		BPCommonUtil.logProfiling('insert complexList');
		
		for(Account branch : branchList){
			branch.Sub_Supl_Complex_Branch__c = complexList[0].Id;
			branch.Market_Complex_Branch__c = marketList[0].Id;
			branch.Region_Branch__c = regionList[0].Id;
		}
		update branchList;
		
		BPCommonUtil.logProfiling('update branchList');
		
		return branchList;
	}
	
    //****************************** End Testing ********************************************************************

}