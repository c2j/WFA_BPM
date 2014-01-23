@isTest
global class BPLeadershipPlanConTest {
    private static testmethod void testBoMPlanTrigger(){
        Test.startTest();
        BranchUtil.createSampleBranchWithFAsMainBranchComplexMarketAndRegion();
        Test.stopTest();
        
        insert CustomerUtil.createTestUser();
        
        Channel__c channel = new Channel__c();
        channel.Name = 'PCG';
        insert channel;
        
        list<Account> branchList = [Select Id, Channel_Branch__c From Account];
        for(Account branch : branchList){
            branch.Channel_Branch__c = channel.Id;
        }
        update branchList;
        
        delete [Select Id From BoM_Plan__c];
        delete [Select Id From Leadership_Plan__c];
        
        BPAdminCon con = new BPAdminCon ();
        con.selectedYear = con.yearList[0].getValue();
        con.startBoMPlan();
        
        BPCommonUtil.log('BoM Plan', [Select Id, Name From BoM_Plan__c ]);
        BPCommonUtil.log('L Plan', [Select Id, BoM_Plan__c, BoM_Plan__r.Name From Leadership_Plan__c]);
        
        Leadership_Plan__c plan = [Select Id, BoM_Plan__c From Leadership_Plan__c Where BoM_Plan__c != null limit 1];
        
        BPLeadershipPlanCon lcon = new BPLeadershipPlanCon();
        lcon.operation = 'Submit';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
        
        lcon.operation = 'BoMPlan';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
        
        lcon.operation = 'BoMPlan';
        lcon.planId = null;
        lcon.bomPlanId = null;
        lcon.execute();
        
        lcon.operation = 'SND';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
        
        lcon.operation = '';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
        
        lcon.gotoBoMPlan();
        lcon.gotoLeadershipPlan();
        
        lcon.planId = null;
        lcon.gotoBoMPlan();
        lcon.gotoLeadershipPlan();
        
        
        plan.Status__c = 'Closed';
        update plan;
        
        plan.Status__c = 'Available';
        update plan;
        
        //Test Submit
        plan.Status__c = 'Available';
        plan.Business_Mission_and_Vision_Statement__c = 'Any Text';
        plan.Risk_Management__c = 'Any Text';
        plan.Team_Member_Engagement__c = 'Any Text';
        plan.Community_Involvement__c= 'Any Text';
        plan.Diversity_and_Inclusion__c = 'Any Test';
        plan.Financial_Performance__c = 'Any Test';
        update plan;
        lcon.operation = 'Submit';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
        
        //Test Submit Status Submitted
        plan.Status__c = 'Submitted';
        plan.Business_Mission_and_Vision_Statement__c = 'Any Text';
        plan.Risk_Management__c = 'Any Text';
        plan.Team_Member_Engagement__c = 'Any Text';
        plan.Community_Involvement__c= 'Any Text';
        update plan;
        lcon.operation = 'Submit';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
        
        //Test Submit Status Closed
        plan.Status__c = 'Closed';
        plan.Business_Mission_and_Vision_Statement__c = 'Any Text';
        plan.Risk_Management__c = 'Any Text';
        plan.Team_Member_Engagement__c = 'Any Text';
        plan.Community_Involvement__c= 'Any Text';
        update plan;
        lcon.operation = 'Submit';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
        
        //Test Submit Status Closed
        plan.Status__c = 'In Action';
        plan.Business_Mission_and_Vision_Statement__c = 'Any Text';
        plan.Risk_Management__c = 'Any Text';
        plan.Team_Member_Engagement__c = 'Any Text';
        plan.Community_Involvement__c= 'Any Text';
        update plan;
        lcon.operation = 'Submit';
        lcon.planId = plan.Id;
        lcon.bomPlanId = plan.BoM_Plan__c;
        lcon.execute();
    }
}