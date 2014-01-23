@isTest 
private class TestIBDCWhenTaskLogged { 

static testMethod void testIBDCofContact() { 

//select preexisting contact Jerry Yu
Contact c = new Contact(LastName = 'Test', Phone = '(314) 123-1234', IBDC__c = 'Open - St. Louis');
insert c;


System.debug('contact -------------------> ' + c);

//Create Internal Task record type
Task t = new Task(RecordTypeID = '012300000000V1J', WhoID = c.ID, Subject = 'Advisory',
Category__c = 'Advisory-Allocation Advisor', Communication_Type__c = 'Inbound');

Insert t;

Task nt = new Task(RecordTypeID = '012300000000V1J', WhoID = c.ID, Subject = 'Advisory',
Category__c = 'Advisory-Allocation Advisor', Communication_Type__c = 'Outbound');

System.debug('task -------------------> ' + t);

//change the IBDC on the Contact after an activity has been logged
c.IBDC__c = 'Matt Kane';
Test.StartTest();
update c;
Insert nt;
Test.StopTest();

Task tsk = [SELECT WhoID, RecordTypeID, IBDC_When_Activity_Created__c, Communication_Type__c FROM Task WHERE 
RecordTypeID = '012300000000V1J' AND WhoID IN : [SELECT ID FROM Contact] AND Communication_Type__c = 'Inbound'];

System.assertEquals('Open - St. Louis', tsk.IBDC_When_Activity_Created__c);


Task ntsk = [SELECT WhoID, RecordTypeID, IBDC_When_Activity_Created__c, Communication_Type__c FROM Task WHERE 
RecordTypeID = '012300000000V1J' AND WhoID IN : [SELECT ID FROM Contact] AND Communication_Type__c = 'Outbound'];

System.assertEquals('Matt Kane', ntsk.IBDC_When_Activity_Created__c);

}
}