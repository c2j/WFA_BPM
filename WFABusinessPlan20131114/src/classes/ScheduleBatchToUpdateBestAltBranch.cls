/**************************************************************************************************
 * Name: ScheduleBatchToUpdateBestAltBranch
 * Purpose: Schedule the batch to update best alternative branch
 * Author: Keen Xu
 * Create Date: 2013-06-07
 * Modify History: 
 * 2013-06-07    Keen	Created
***************************************************************************************************/
global class ScheduleBatchToUpdateBestAltBranch implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchToFlagContactsBestAltBranch batch = new BatchToFlagContactsBestAltBranch();
        ID BatchProcessID = Database.executeBatch(batch, 10); 
        /*
        BatchToFlagContactsBestAltBranch batch = new BatchToFlagContactsBestAltBranch();
		Database.executeBatch(batch, 10);
		
		BatchToFlagContactsBestAltBranch batch = new BatchToFlagContactsBestAltBranch();
		String sch = '0 40 * * * ?';
		system.schedule('Best Alternative Branch Batch', sch, batch);
        */
    }
}