/**************************************************************************************************
 * Purpose: Main Branch Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-06
 * Modify History:
 * Keen    2013-11-06    Created
***************************************************************************************************/
global class MainBranchUtil {
	
	//****************************** Start Testing ********************************************************************
	/* For testing */
	public static list<Main_Branch__c> getSampleMainBranchList(Integer nCount){
		list<Main_Branch__c> mainBranchList = new list<Main_Branch__c>();
		Main_Branch__c mainBranch;
		
		Integer maxCount = nCount;
		for(Integer i = 0; i<=maxCount; i++){
			mainBranch = new Main_Branch__c();
			mainBranch.Name = 'MainBranchTest' + i;
			mainBranchList.add(mainBranch);
		}
		
		return mainBranchList;
	}
	//****************************** End Testing ********************************************************************
}