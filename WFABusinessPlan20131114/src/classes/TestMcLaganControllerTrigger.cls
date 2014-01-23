@isTest
public class TestMcLaganControllerTrigger {
	static testMethod void myUnitTest() {
		Account branch = new Account(Name='Branch', AU__c = '72013');
		insert branch;
		McLagan__c ml = new McLagan__c();
		ml.All_Firm_FA__c = 12345;
		ml.All_Firm_FAS__c = 12345;
		ml.All_Firm_Revenue__c = 12345;
		ml.Branch__c = '72013';
		ml.Branch_Count__c = 1;
		ml.Branch_Count_FA__c = 2;
		ml.Branch_Count_FAS__c = 3;
		ml.Branch_Name__c = 'St louis';
		ml.Branch_Rank__c = 1;
		ml.Branch_Rank_FAS__c = 2;
		ml.Complex__c = 'testcomplex';
		ml.Complex_Name__c = 'test name';
		ml.Division__c = 'test division';
		ml.Division_Name__c = 'division name';
		ml.FA_Rank__c = 2;
		ml.Firm_List__c ='firm1,firm2,firm3';
		ml.Market__c = 'test market';
		ml.Market_Name__c = 'market name';
		ml.Other_Firm_FA__c = 12345;
		ml.Other_Firm_FAS__c = 12345;
		ml.PCT_Of_All__c = 25.5;
		ml.PCT_Of_All_FA__c = 35.5;
		ml.PCT_Of_All_FAS__c = 45.5;
		ml.PCT_Of_Other__c = 55.5;
		ml.Period__c = 'FY12';
		ml.Region__c = 'test region';
		ml.Region_Name__c = 'test region 1';
		ml.WFA_Branch_FA__c = 12345;
		ml.WFA_Branch_FAS__c = 12345;
		ml.WFA_Branch_Revenue__c = 12345;
		insert ml;
		
		ApexPages.Standardcontroller stdctr = new ApexPages.Standardcontroller(branch);
		McLaganChartController MLController = new McLaganChartController(stdctr);
		System.assertNotEquals(MLController.getData(), null);
	}
}