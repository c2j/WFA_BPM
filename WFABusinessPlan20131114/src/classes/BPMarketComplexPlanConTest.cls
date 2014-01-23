@isTest
private class BPMarketComplexPlanConTest {
    private static testmethod void testBPMarketComplexPlanCon(){
        
        Test.startTest();
        BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
        Test.stopTest();
        
        delete [Select Id From FA_Goal__c];
        delete [Select Id From BoM_Plan__c];
        
        Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
        
        BPCommonUtil.log('*** Finished createSampleBranchWithFAsMainBranchComplexMarketAndRegion.');
        
        BPAdminCon con = new BPAdminCon ();
        con.selectedYear = con.yearList[0].getValue();
        con.startBoMPlan();
        
        BPCommonUtil.log('*** Finished startBoMPlan');
        
        //Test FA Goal Update
        list<FA_Goal__c> faGoalList = [Select Name From FA_Goal__c];
        for(FA_Goal__c faGoal : faGoalList){
            faGoal.Plan_Advisory_Net_Flows__c = 1000000;
            faGoal.Plan_Lending__c = 2000000;
            faGoal.Plan_Net_Income__c = 3000000;
            faGoal.Plan_New_Key_HHs__c = 50;
        }
        
        update faGoalList;
        
        BPCommonUtil.log('*** Finished updating faGoalList');
        
        BPCommonUtil.log('*** Test Start.');
        
        Id regionPlanRTId = BPBranchBusinessPlanUtil.getRegionPlanRecordTypeId();
        Id branchPlanRTId = BPBranchBusinessPlanUtil.getBranchPlanRecordTypeId();
        list<BoM_Plan__c> bomPlanList = [Select Name, (Select Id, Name, RecordTypeId From Market_Plans__r) From BoM_Plan__c Where RecordTypeId = :regionPlanRTId limit 10];
        Integer nCount = 0;
        
        BPCommonUtil.logJson('bomPlanList', bomPlanList);
        for(BoM_Plan__c plan : bomPlanList){
            Integer nSubPlanCount = 0;
            for(BoM_Plan__c subPlan : plan.Market_Plans__r){
                //Set the approved plan for the first one
                if(nSubPlanCount == 0 && branchPlanRTId == subPlan.RecordTypeId){
                    subPlan.Status__c = 'In Action';
                    nSubPlanCount++;
                }
                
            }
            update plan.Market_Plans__r;
            
            BPMarketComplexPlanCon ext = new BPMarketComplexPlanCon();
            if(nCount != 9){
                ext.planId = plan.Id;
            }
            
            ext.init();
            nCount++;
            
            if(ext.masterPlanWrapper!=null){
                String className = ext.masterPlanWrapper.indentClass;
                for(BPMarketComplexPlanCon.BoMPlanWrapper wrapper : ext.bomPlanWrapperList){
                    className = wrapper.cotentIndentClass;
                }
            }
        }       
    }
}