/**************************************************************************************************
 * Purpose: Ranking Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-06
 * Modify History:
 * Keen    2013-11-06    Created
***************************************************************************************************/
global class RankingUtil {
	public static void processAfterTrg(){
		List<Ranking__c> newRankingList = trigger.new;
		Map<Id, Ranking__c> toUpdateRankingMap = new Map<Id, Ranking__c>();
		
		//Start picking out the records
		if(trigger.isInsert){
			//Any of the newly inserted ranking records need to be updated into the corresponding FA Goal
			for(Ranking__c newRanking : newRankingList){
				if(!toUpdateRankingMap.containsKey(newRanking.Contact__c)){
					toUpdateRankingMap.put(newRanking.Contact__c, newRanking);
				}
			}
		}
		else if(trigger.isUpdate){
			for(Ranking__c newRanking : newRankingList){
				Ranking__c oldRanking = (Ranking__c)trigger.oldMap.get(newRanking.Id);
				
				//If any fields below to capture are changed, update them into the corresponding FA Goal
				if(BPCommonUtil.defaultNull(newRanking.Prior_Year_Advisory_Flows__c) != BPCommonUtil.defaultNull(oldRanking.Prior_Year_Advisory_Flows__c)
					|| BPCommonUtil.defaultNull(newRanking.Advisory_YTD_Net_Flows__c) != BPCommonUtil.defaultNull(oldRanking.Advisory_YTD_Net_Flows__c)
					|| BPCommonUtil.defaultNull(newRanking.Advisory_as_of_Date__c) != BPCommonUtil.defaultNull(oldRanking.Advisory_as_of_Date__c)
					|| BPCommonUtil.defaultNull(newRanking.FA_Goal_Advisory_Flows__c) != BPCommonUtil.defaultNull(oldRanking.FA_Goal_Advisory_Flows__c)
					
					|| BPCommonUtil.defaultNull(newRanking.Prior_Year_New_Key_HHs__c) != BPCommonUtil.defaultNull(oldRanking.Prior_Year_New_Key_HHs__c)
					|| BPCommonUtil.defaultNull(newRanking.New_Key_HHs__c) != BPCommonUtil.defaultNull(oldRanking.New_Key_HHs__c)
					|| BPCommonUtil.defaultNull(newRanking.New_Key_HHs_as_of_Date__c) != BPCommonUtil.defaultNull(oldRanking.New_Key_HHs_as_of_Date__c)
					|| BPCommonUtil.defaultNull(newRanking.FA_Goal_New_Key_HHs__c) != BPCommonUtil.defaultNull(oldRanking.FA_Goal_New_Key_HHs__c)
					
					//This is lending credits
					|| BPCommonUtil.defaultNull(newRanking.Prior_Year_Lending_YTD__c) != BPCommonUtil.defaultNull(oldRanking.Prior_Year_Lending_YTD__c)
					|| BPCommonUtil.defaultNull(newRanking.Lending_YTD__c) != BPCommonUtil.defaultNull(oldRanking.Lending_YTD__c)
					|| BPCommonUtil.defaultNull(newRanking.Lending_as_of_Date__c) != BPCommonUtil.defaultNull(oldRanking.Lending_as_of_Date__c)
					|| BPCommonUtil.defaultNull(newRanking.FA_Goal_Lending__c) != BPCommonUtil.defaultNull(oldRanking.FA_Goal_Lending__c)
					
					|| BPCommonUtil.defaultNull(newRanking.Production_Data_As_Of_Date__c) != BPCommonUtil.defaultNull(oldRanking.Production_Data_As_Of_Date__c)
					|| BPCommonUtil.defaultNull(newRanking.Prior_Year_Production__c) != BPCommonUtil.defaultNull(oldRanking.Prior_Year_Production__c)
					|| BPCommonUtil.defaultNull(newRanking.Production_YTD__c) != BPCommonUtil.defaultNull(oldRanking.Production_YTD__c)
					|| BPCommonUtil.defaultNull(newRanking.Annualized_Production__c) != BPCommonUtil.defaultNull(oldRanking.Annualized_Production__c)
					|| BPCommonUtil.defaultNull(newRanking.FA_Goal_Revenue__c) != BPCommonUtil.defaultNull(oldRanking.FA_Goal_Revenue__c)
					|| BPCommonUtil.defaultNull(newRanking.Prior_Year_Advisory_Revenue__c) != BPCommonUtil.defaultNull(oldRanking.Prior_Year_Advisory_Revenue__c)
					
					//Action Plan
					|| BPCommonUtil.defaultNull(newRanking.Quadrant__c) != BPCommonUtil.defaultNull(oldRanking.Quadrant__c)
					|| BPCommonUtil.defaultNull(newRanking.Primary_Objective__c) != BPCommonUtil.defaultNull(oldRanking.Primary_Objective__c)
					
					){
					
					//Any of the updates above will result in the update to the FA Goals
					if(!toUpdateRankingMap.containsKey(newRanking.Contact__c)){
						toUpdateRankingMap.put(newRanking.Contact__c, newRanking);
					}
				}
			}
		}
		
		//Start handling the records
		if(trigger.isInsert || trigger.isUpdate) {
			updateFAGoalFromRanking(toUpdateRankingMap);
		}
	}
	
	//Capture the values from ranking object and save into FA Goal
	public static void updateFAGoalFromRanking(Map<Id, Ranking__c> fromRankingMap){
		if(fromRankingMap == null || fromRankingMap.values().size() == 0){
			return;
		}
		set<String> yearSet = getYearSet(fromRankingMap.values());
		
		//Most recent year should be added to capture the Quadrant and BP Goal which do not have as of date
		String mostRecentYear = getMostRecentYear();
		yearSet.add(mostRecentYear);
		
		set<Id> faSet = getFASet(fromRankingMap.values());
		list<FA_Goal__c> faGoalList = getFAGoalList(yearSet, faSet);
		list<FA_Goal__c> toUpdateFAGoalList = new list<FA_Goal__c>();
		for(FA_Goal__c faGoal :faGoalList){
			if(fromRankingMap.containsKey(faGoal.FA__c)){
				Ranking__c newRanking = fromRankingMap.get(faGoal.FA__c);
				system.debug('***newRanking: ' + newRanking);
				
				//Advisory Net Flows
				if(faGoal.BoM_Plan__r.Year_Text__c == BPCommonUtil.getYearString(newRanking.Advisory_as_of_Date__c)){
					faGoal.Prior_Advisory_Net_Flows__c = BPCommonUtil.defaultNull(newRanking.Prior_Year_Advisory_Flows__c);
					faGoal.YTD_Advisory_Net_Flows__c = BPCommonUtil.defaultNull(newRanking.Advisory_YTD_Net_Flows__c);
					faGoal.Annualized_Advisory_Net_Flows__c = BPCommonUtil.defaultNull(newRanking.Advisory_YTD_Net_Flows__c) * BPCommonUtil.defaultNull(newRanking.Anzld__c);
					faGoal.FA_Goal_Advisory_Net_Flows__c = BPCommonUtil.defaultNull(newRanking.FA_Goal_Advisory_Flows__c);
					faGoal.Prior_Year_Advisory_Revenue__c = BPCommonUtil.defaultNull(newRanking.Prior_Year_Advisory_Revenue__c);
				}
				
				//New Key HHs
				if(faGoal.BoM_Plan__r.Year_Text__c == BPCommonUtil.getYearString(newRanking.New_Key_HHs_as_of_Date__c)){
					faGoal.Prior_New_Key_HHs__c = BPCommonUtil.defaultNull(newRanking.Prior_Year_New_Key_HHs__c);
					faGoal.YTD_New_Key_HHs__c = BPCommonUtil.defaultNull(newRanking.New_Key_HHs__c);
					faGoal.Annualized_New_Key_HHs__c = BPCommonUtil.defaultNull(newRanking.New_Key_HHs__c) * BPCommonUtil.defaultNull(newRanking.Anzld__c);
					faGoal.FA_Goal_New_Key_HHs__c = BPCommonUtil.defaultNull(newRanking.FA_Goal_New_Key_HHs__c);
				}
				
				//Lending
				if(faGoal.BoM_Plan__r.Year_Text__c == BPCommonUtil.getYearString(newRanking.Lending_as_of_Date__c)){
					faGoal.Prior_Lending__c = BPCommonUtil.defaultNull(newRanking.Prior_Year_Lending_YTD__c);//This is Lending Credits
					faGoal.YTD_Lending__c = BPCommonUtil.defaultNull(newRanking.Lending_YTD__c);
					faGoal.Annualized_Lending__c = BPCommonUtil.defaultNull(newRanking.Lending_YTD__c) * BPCommonUtil.defaultNull(newRanking.Anzld__c);
					faGoal.FA_Goal_Lending__c = BPCommonUtil.defaultNull(newRanking.FA_Goal_Lending__c);
				}
				
				//Net Income
				if(faGoal.BoM_Plan__r.Year_Text__c == BPCommonUtil.getYearString(newRanking.Production_Data_As_Of_Date__c)){
					faGoal.Prior_Net_Income__c = BPCommonUtil.defaultNull(newRanking.Prior_Year_Production__c);
					faGoal.YTD_Net_Income__c = BPCommonUtil.defaultNull(newRanking.Production_YTD__c);
					faGoal.Annualized_Net_Income__c = BPCommonUtil.defaultNull(newRanking.Annualized_Production__c);
					faGoal.FA_Goal_Net_Income__c = BPCommonUtil.defaultNull(newRanking.FA_Goal_Revenue__c);
				}
				
				//Action Plan
				if(faGoal.BoM_Plan__r.Year_Text__c == mostRecentYear){
					faGoal.BP_Quadrant__c = newRanking.Quadrant__c==null? null : String.valueOf(newRanking.Quadrant__c);
					//Skip copy this field because this is input in the action plan page and could be overwritten
					//faGoal.Primary_Objective__c =BPCommonUtil.defaultNull(newRanking.Primary_Objective__c);
				}
				
				toUpdateFAGoalList.add(faGoal);
			}
		}
		update toUpdateFAGoalList;
	}
	
	//Get Most Recent Year from the existing plans
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
	
	public static list<FA_Goal__c> getFAGoalList(set<String> yearSet, set<Id> contactSet){
		list<FA_Goal__c> faGoalList = [Select Name, FA__c, BoM_Plan__r.Year_Text__c
										From FA_Goal__c
										Where BoM_Plan__r.Year_Text__c in :yearSet
										And FA__c in :contactSet];
		return faGoalList;
	}
	
	//Get the year part of all the as of date and put them together
	public static set<String> getYearSet(list<Ranking__c> rankingList){
		
		set<String> yearSet = new set<String>();
		
		for(Ranking__c ranking : rankingList){
			if(ranking.Net_Asset_Flows_as_of_Date__c!=null){
				yearSet.add(BPCommonUtil.getYearString(ranking.Net_Asset_Flows_as_of_Date__c));
			}
			if(ranking.New_Key_HHs_as_of_Date__c!=null){
				yearSet.add(BPCommonUtil.getYearString(ranking.New_Key_HHs_as_of_Date__c));
			}
			if(ranking.Lending_as_of_Date__c!=null){
				yearSet.add(BPCommonUtil.getYearString(ranking.Lending_as_of_Date__c));
			}
			if(ranking.Production_Data_As_Of_Date__c!=null){
				yearSet.add(BPCommonUtil.getYearString(ranking.Production_Data_As_Of_Date__c));
			}
		}
		
		return yearSet;
	}
	
	
	//Get the Id Set from rankingList
	public static set<Id> getFASet(list<Ranking__c> rankingList){
		
		set<Id> faSet = new set<Id>();
		
		for(Ranking__c ranking : rankingList){
			faSet.add(ranking.Contact__c);
		}
		
		return faSet;
	}
	
	//Re-org a list of rankings into a hierarchical structure by the Year and FA Id
	public static map<String, map<Id, Ranking__c>> getHierarchyRanking(list<Ranking__c> rankingList){
		map<Id, Ranking__c> rankingByFAMap;
		map<String, map<Id, Ranking__c>> rankingByYearAndFAMap = new map<String, map<Id, Ranking__c>>();
		for(Ranking__c ranking : rankingList){
			
			rankingByFAMap = new map<Id, Ranking__c>();
		}
		
		return rankingByYearAndFAMap;
	}
	
	//****************************** Start Testing ********************************************************************
	
	/* For testing */
	public static list<Ranking__c> getSampleRankingList(Integer nCount, Contact fa){
		list<Ranking__c> rankingList = new list<Ranking__c>();
		Ranking__c ranking;
		
		Integer maxCount = nCount;
		for(Integer i = 0; i<=maxCount; i++){
			ranking = new Ranking__c();
			ranking.Name = 'Ranking' + i;
			if(i==0) {
				ranking.Primary_Objective__c = 'All';
			}else {
				ranking.Primary_Objective__c = ActionPlanElementUtil.CLIENT_AND_ASSET_ACQUISTION;
			}
			ranking.Net_Asset_Flows_as_of_Date__c = Date.newInstance(2013, 10, 21);
			ranking.Prior_Year_Advisory_Flows__c = 1900140;
			ranking.Advisory_YTD_Net_Flows__c = 1900141;
			ranking.FA_Goal_Advisory_Flows__c = 1900140;

			ranking.New_Key_HHs_as_of_Date__c = Date.newInstance(2013, 10, 21);
			ranking.Prior_Year_New_Key_HHs__c = 11;
			ranking.New_Key_HHs__c = 12;
			ranking.FA_Goal_New_Key_HHs__c = 10;
			
			ranking.Lending_as_of_Date__c = Date.newInstance(2013, 10, 21);
			ranking.Prior_Year_Lending_YTD__c = 1900140;//This is lending credits
			ranking.Lending_YTD__c = 1900140;
			ranking.FA_Goal_Lending__c = 1900130;
			
			ranking.Prior_Year_Production__c = 1900140;
			ranking.Quadrant__c = 1;
            
			ranking.Contact__c = fa.Id;
			rankingList.add(ranking);
		}
		
		return rankingList;
	}
	//****************************** End Testing ********************************************************************
	
}