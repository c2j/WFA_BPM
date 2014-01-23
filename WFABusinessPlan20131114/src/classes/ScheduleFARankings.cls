global class ScheduleFARankings implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        BatchToUpdateFARankings objBatchToUpdateFARankings = new BatchToUpdateFARankings();
        
        objBatchToUpdateFARankings.strqry ='SELECT ID, Contact__c, Current_YTD_Production_Rank__c, Prior_YTD_Production_Rank__c, ' +
        'Current_MTD_Production_Rank__c, Prior_MTD_Production_Rank__c, ' +
        'Current_Yesterday_s_Production_Rank__c, Prior_Yesterday_s_Production_Rank__c, ' +
        'Current_Annualized_Production_Rank__c, Prior_Annualized_Production_Rank__c ' +
        'FROM Ranking__c WHERE Terminated__c != \'Yes\'';
        
        ID BatchProcessID = Database.executeBatch(objBatchToUpdateFARankings);
        
    }
    
}