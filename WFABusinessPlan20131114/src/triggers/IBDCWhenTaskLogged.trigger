trigger IBDCWhenTaskLogged on Task (before Insert) {

List<ID> TaskContact = new List<ID>();
List<ID> recType = new List<ID>();
RecordType[] InternalRec;
List<Task> InternalsTasks = new List<Task>();
Contact[] cons;

//select the Internal and Internal - FCCS task record types
InternalRec = [SELECT ID FROM RecordType WHERE ID = '012300000000V1J' or ID = '01250000000UGGj'];

//loop through trigger.new to find Internal (- FCCS) task record types
//if there are, then add those tasks to a list and the contactID of those task records
for (Task t: Trigger.new) {

    If (t.RecordTypeID == InternalRec[0].ID || t.RecordTypeID == InternalRec[1].ID) {
        InternalsTasks.add(t);
        TaskContact.add(t.WhoID);
    }
    
}  

//If there are internls tasks, select a list of contacts affected by those tasks,
//loop through the contacts and tasks and set the IBDC When activity Created Field equal to the Contact's
//IBDC at the time. This field will will not change when the Contact's IBDC is changed.

if (!InternalsTasks.IsEmpty()) {

    cons = [SELECT ID, IBDC__c FROM Contact WHERE ID IN :TaskContact];
    
    for (Contact c: cons) {
        for (Task t: InternalsTasks) {
            if (t.WhoID == c.ID) {         
                t.IBDC_When_Activity_Created__c = c.IBDC__c;
            }
        }
    }
}
}