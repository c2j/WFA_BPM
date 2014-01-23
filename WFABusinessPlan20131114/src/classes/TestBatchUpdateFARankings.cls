@isTest

private class TestBatchUpdateFARankings {


    static testMethod void testFARankings() {
        
        Channel__c PCG = new Channel__c(name='PCG');
        
        insert PCG;
        
        Account branch = new Account();
        branch.Name = 'Test Branch';
        branch.Channel_Branch__c = PCG.id;
        
        insert branch;
        
        Contact FA1 = new Contact();
        FA1.FirstName = 'Test';
        FA1.LastName = 'FA';
        FA1.AccountID = branch.id;
        FA1.Type__c = 'Branch Manager';
        FA1.IBDC__c = 'David Phan';
        FA1.Production_YTD__c = 100000;
        FA1.Production_MTD__c = 1000;
        FA1.Production_Yesterday__c = 100;
        FA1.Annualized_Production__c = 150000;
        
        insert FA1;   

        Contact FA2 = new Contact();
        FA2.FirstName = 'Test';
        FA2.LastName = 'FA';
        FA2.Type__c = 'FA';
        FA2.AccountID = branch.id;
        FA2.IBDC__c = 'David Phan';
        FA2.Production_YTD__c = 200000;
        FA2.Production_MTD__c = 2000;
        FA2.Production_Yesterday__c = 200;
        FA2.Annualized_Production__c = 250000;
        
        insert FA2;   
    
        Ranking__c FA1Rank = new Ranking__c();
        FA1Rank.Contact__c = FA1.id;
        
        insert FA1Rank;
        
        Ranking__c FA2Rank = new Ranking__c();
        FA2Rank.Contact__c = FA2.id;
        
        insert FA2Rank;
        
        
        test.StartTest();
        
        BatchToUpdateFARankings objBatchToUpdateFARankings = new BatchToUpdateFARankings();

        objBatchToUpdateFARankings.strqry ='SELECT ID, Contact__c, Current_YTD_Production_Rank__c, Prior_YTD_Production_Rank__c, ' +
        'Current_MTD_Production_Rank__c, Prior_MTD_Production_Rank__c, ' +
        'Current_Yesterday_s_Production_Rank__c, Prior_Yesterday_s_Production_Rank__c, ' +
        'Current_Annualized_Production_Rank__c, Prior_Annualized_Production_Rank__c ' +
        'FROM Ranking__c WHERE Terminated__c != \'Yes\'' + ' Limit 200';
        
        ID batchprocessid = Database.executeBatch(objBatchToUpdateFARankings);        
     
        test.StopTest();
         
    }
    
}