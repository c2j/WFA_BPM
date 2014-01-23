@isTest
private class TestCountCABOODCases {

    static testMethod void CountFAsCABOODCases() {
    
        Account branch = new Account();
        branch.name = 'Test Branch';
        
        insert branch;
        
        contact fa = new contact();
        fa.FirstName = 'Test';
        fa.LastName = 'FA';
        fa.AccountID = branch.id;
        fa.Type__c = 'FA';
        
        insert fa;
        
        contact fa2 = new contact();
        fa2.FirstName = 'Test';
        fa2.LastName = 'FA2';
        fa2.AccountID = branch.id;
        fa2.Type__c = 'FA';
        
        insert fa2;

        contact fa3 = new contact();
        fa3.FirstName = 'Test';
        fa3.LastName = 'FA3';
        fa3.AccountID = branch.id;
        fa3.Type__c = 'FA';
        
        insert fa3;
        
        system.debug('Count CABO Cases Test FA IDs --------------- ' + FA.id + ' / ' + FA2.id);
        
        List<Case> ExsitingCABOODCases = new List<Case>();
        
        // create a list of existing cabo on demand cases
        //012500000005K7J use in sandbox; 01250000000UKbR use in production
        
        //FA 1's existing cabo cases
        for (integer i = 1; i < 11; i++) {
            case cs = new case();
            cs.RecordTypeID = '01250000000UKbR';
            cs.ContactID = fa.id;
            cs.Client_Name__c = 'Test FA';
            cs.Which_Product__c = 'Asset Advisor';
            cs.Case_Created_Date__c = date.newinstance(system.today().year(), system.now().month()-1,math.min(i+1,30));
            
            ExsitingCABOODCases.add(cs);
        }
        
        //FA 2's existing cabo cases
        for (integer i = 1; i < 11; i++) {
            case cs = new case();
            cs.RecordTypeID = '01250000000UKbR';
            cs.ContactID = fa2.id;
            cs.Client_Name__c = 'Test FA2';
            cs.Which_Product__c = 'Asset Advisor';
            cs.Case_Created_Date__c = date.newinstance(system.today().year(), system.now().month()-1,math.min(i+1,30));
            
            ExsitingCABOODCases.add(cs);
        }
        
        
        
        test.startTest();
   
        insert ExsitingCABOODCases;

        Contact FA1CABOCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c, Yesterday_s_CABO_on_Demand_Cases__c FROM
                                      Contact WHERE ID =: FA.id];

        system.assertequals(FA1CABOCases.YTD_CABO_on_Demand_Cases__c, 10);
        
        if (system.now().day() == 1) {
            system.assertequals(FA1CABOCases.MTD_CABO_on_Demand_Cases__c, null);
        } else {
            system.assertequals(FA1CABOCases.MTD_CABO_on_Demand_Cases__c, 10);
        }
        
        system.assertequals(FA1CABOCases.Yesterday_s_CABO_on_Demand_Cases__c, 10);
        
        Contact FA2CABOCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c, Yesterday_s_CABO_on_Demand_Cases__c FROM
                                      Contact WHERE ID =: FA2.id];                                      
        
        system.assertequals(FA2CABOCases.YTD_CABO_on_Demand_Cases__c, 10);
        
        if (system.now().day() == 1) {
            system.assertequals(FA2CABOCases.MTD_CABO_on_Demand_Cases__c, null);
        } else {
            system.assertequals(FA2CABOCases.MTD_CABO_on_Demand_Cases__c, 10);
        }
        
        system.assertequals(FA2CABOCases.Yesterday_s_CABO_on_Demand_Cases__c, 10);

        FA1CABOCases.YTD_CABO_on_Demand_Cases__c = 0;
        FA1CABOCases.MTD_CABO_on_Demand_Cases__c = 0;
        FA1CABOCases.Yesterday_s_CABO_on_Demand_Cases__c = 0;
        
        FA2CABOCases.YTD_CABO_on_Demand_Cases__c = 0;
        FA2CABOCases.MTD_CABO_on_Demand_Cases__c = 0;
        FA2CABOCases.Yesterday_s_CABO_on_Demand_Cases__c = 0;
    
        update FA1CABOCases;
        update FA2CABOCases;
        
        Case testCase = new case();
        
        testCase.RecordTypeID = '01250000000UKbR';
        testCase.ContactID = fa3.id;
        testCase.Description = 'Backfill FA CABO On Demand Case Count';
        testCase.Which_Product__c = 'Asset Advisor';
        
        system.debug('inserting dummy cabo od case');
        
        insert testCase;
        
        FA1CABOCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c, Yesterday_s_CABO_on_Demand_Cases__c FROM
                                      Contact WHERE ID =: FA.id];
        
        system.assertequals(FA1CABOCases.YTD_CABO_on_Demand_Cases__c, 10);
        
        if (system.now().day() == 1) {
            system.assertequals(FA1CABOCases.MTD_CABO_on_Demand_Cases__c, 0);
        } else {
            system.assertequals(FA1CABOCases.MTD_CABO_on_Demand_Cases__c, 10);
        }
        
        system.assertequals(FA1CABOCases.Yesterday_s_CABO_on_Demand_Cases__c, 10);
        
        FA2CABOCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c, Yesterday_s_CABO_on_Demand_Cases__c FROM
                                      Contact WHERE ID =: FA2.id];                                      
        
        system.assertequals(FA2CABOCases.YTD_CABO_on_Demand_Cases__c, 10);
        
        if (system.now().day() == 1) {
            system.assertequals(FA2CABOCases.MTD_CABO_on_Demand_Cases__c, 0);
        } else {
            system.assertequals(FA2CABOCases.MTD_CABO_on_Demand_Cases__c, 10);
        }
        
        system.assertequals(FA2CABOCases.Yesterday_s_CABO_on_Demand_Cases__c, 10);
        
        test.StopTest();
    
    }
}