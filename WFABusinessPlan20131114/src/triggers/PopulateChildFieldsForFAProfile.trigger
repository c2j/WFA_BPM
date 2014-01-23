trigger PopulateChildFieldsForFAProfile on Child__c (after insert, before update, before delete) {
/* trigger no longer needed since managers have access to profiling information record

   // System.debug('-----------Trigger Fired-----------');
    
    String TriggerType;
    
    List<ID> conIds = new List<ID>();
      
    
    if (trigger.isDelete) {
       //select a list of the contacts related to each child
       For (Child__c c :trigger.old) {
           conIds.add(c.Parent__c); //store the contact ids for querying
       }
       
       //query a list of contacts who are the parents of the children records in the trigger       
       Contact[] cons = [SELECT Name, ID, ChildFieldsPart1__c, ChildFieldsPart2__c,ChildFieldsPart3__c,ChildFieldsPart4__c,
       ChildFieldsPart5__c,ChildFieldsPart6__c,ChildFieldsPart7__c,ChildFieldsPart8__c,ChildFieldsPart9__c,
       ChildFieldsPart10__c,ChildFieldsPart11__c,ChildFieldsPart12__c FROM Contact WHERE ID in: conIds];
       
       FormatChildrenDataForSurvey.ClearChildFields(trigger.old, cons, 'Delete');
       
    } else {
    
           //select a list of the contacts related to each child
       For (Child__c c :trigger.new) {
           conIds.add(c.Parent__c); //store the contact ids for querying
       }

       //query a list of contacts who are the parents of the children records in the trigger       
       Contact[] cons = [SELECT Name, ID, ChildFieldsPart1__c, ChildFieldsPart2__c,ChildFieldsPart3__c,ChildFieldsPart4__c,
       ChildFieldsPart5__c,ChildFieldsPart6__c,ChildFieldsPart7__c,ChildFieldsPart8__c,ChildFieldsPart9__c,
       ChildFieldsPart10__c,ChildFieldsPart11__c,ChildFieldsPart12__c FROM Contact WHERE ID in: conIds];
              
        if (trigger.isInsert) {
            TriggerType = 'Insert';
        } else if (trigger.isUpdate) {
            TriggerType = 'Update';   
        }
        
        FormatChildrenDataForSurvey.PopulateChildFields(trigger.new, cons, TriggerType);
    }
    
*/
}