trigger ReshiftChildFieldParts on Contact (after update) {
/* trigger no longer needed since managers have access to profiling information record


//if a child is deleted, that Childfieldpart field on the contact that store that child's information for the survey will be cleared
//this trigger needs to reshift the placement of the childfieldpart values so that there is no gap between any two fields
//the numbering of the questions must also change accordingly

List<ID> conIDs = new List<ID>();
Contact oldc;

//System.debug('-----------------Trigger Fired-------------------------');

for (Contact c: trigger.new) {
    oldc = trigger.oldmap.get(c.id);
    if (c.ChildFieldsPart1__c != oldc.ChildFieldsPart1__c || c.ChildFieldsPart2__c != oldc.ChildFieldsPart2__c ||
    c.ChildFieldsPart3__c != oldc.ChildFieldsPart3__c || c.ChildFieldsPart4__c != oldc.ChildFieldsPart4__c ||
    c.ChildFieldsPart5__c != oldc.ChildFieldsPart5__c || c.ChildFieldsPart6__c != oldc.ChildFieldsPart6__c ||
    c.ChildFieldsPart7__c != oldc.ChildFieldsPart7__c || c.ChildFieldsPart8__c != oldc.ChildFieldsPart8__c ||
    c.ChildFieldsPart9__c != oldc.ChildFieldsPart9__c || c.ChildFieldsPart10__c != oldc.ChildFieldsPart10__c ||
    c.ChildFieldsPart11__c != oldc.ChildFieldsPart11__c || c.ChildFieldsPart12__c != oldc.ChildFieldsPart12__c) {

/*System.debug('New CF1: ' + c.ChildFieldsPart1__c + ' ' + 'Old CF1: ' + oldc.ChildFieldsPart1__c);
System.debug('New CF2: ' + c.ChildFieldsPart2__c + ' ' + 'Old CF2: ' + oldc.ChildFieldsPart2__c);
System.debug('New CF3: ' + c.ChildFieldsPart3__c + ' ' + 'Old CF3: ' + oldc.ChildFieldsPart3__c);
System.debug('New CF4: ' + c.ChildFieldsPart4__c + ' ' + 'Old CF4: ' + oldc.ChildFieldsPart4__c);
System.debug('New CF5: ' + c.ChildFieldsPart5__c + ' ' + 'Old CF5: ' + oldc.ChildFieldsPart5__c);
System.debug('New CF6: ' + c.ChildFieldsPart6__c + ' ' + 'Old CF6: ' + oldc.ChildFieldsPart6__c);
System.debug('New CF7: ' + c.ChildFieldsPart7__c + ' ' + 'Old CF7: ' + oldc.ChildFieldsPart7__c);
System.debug('New CF8: ' + c.ChildFieldsPart8__c + ' ' + 'Old CF8: ' + oldc.ChildFieldsPart8__c);
System.debug('New CF9: ' + c.ChildFieldsPart9__c + ' ' + 'Old CF9: ' + oldc.ChildFieldsPart9__c);
System.debug('New CF10: ' + c.ChildFieldsPart10__c + ' ' + 'Old CF10: ' + oldc.ChildFieldsPart10__c);
System.debug('New CF11: ' + c.ChildFieldsPart11__c + ' ' + 'Old CF11: ' + oldc.ChildFieldsPart11__c);
System.debug('New CF12: ' + c.ChildFieldsPart12__c + ' ' + 'Old CF12: ' + oldc.ChildFieldsPart12__c);

        conIDs.add(c.id);
    }
}

//system.debug('conIDs size : ' + conids.size());

if (conIDs.size() > 0) {

Contact[] cons = [SELECt ChildFieldsPart1__c, ChildFieldsPart2__c, ChildFieldsPart3__c, ChildFieldsPart4__c, ChildFieldsPart5__c,
                  ChildFieldsPart6__c, ChildFieldsPart7__c, ChildFieldsPart8__c, ChildFieldsPart9__c, ChildFieldsPart10__c,
                  ChildFieldsPart11__c, ChildFieldsPart12__c FROM CONTACT WHERE ID IN: conIDs];
                  
       ReshiftChildFieldParts.ReshiftChildFields(cons); //, 4);
}
*/
}