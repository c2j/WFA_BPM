@isTest 
private class TestIBDCTasksOnNewContacts { 

//Trigger Replaced with scheduled apex class ScheduleIBDCTasksOnNewHires

/*
static testMethod void testIBDCTask() { 

//----------------------------

Channel__c PCG = new Channel__c(name = 'PCG');
Channel__c WBS = new Channel__c(name = 'WBS');
Channel__c FiNet = new Channel__c(name = 'FiNet');
insert PCG;
insert WBS;
insert FiNet;

Account branch = new Account(name = 'PCGBranch', channel_Branch__c = PCG.id);
Account branch2 = new Account(name = 'WBSBranch', channel_Branch__c = WBS.id);
Account branch3 = new Account(name = 'FiNetBranch', channel_Branch__c = FiNet.id);
insert branch;
insert branch2;
insert branch3;

Contact[] c1 = new Contact[] {
new Contact(LastName = 'Tester', AccountID=branch2.id, Type__c = 'FA', 
Hire_Date__c = Date.newinstance(2012, 3,25), IBDC__c = 'Adrian Vega'),
new Contact(LastName = 'Tester1',  AccountID=branch2.id,Type__c = 'FA in Training', 
Hire_Date__c = Date.newinstance(2012, 2,25), IBDC__c = 'Adrian Vega'),
new Contact(LastName = 'Tester2',  AccountID=branch3.id,Type__c = 'Licensee', 
Hire_Date__c = Date.newinstance(2012, 1,25), IBDC__c = 'David Phan'),
new Contact(LastName = 'Tester3',  AccountID=branch.id,Type__c = 'Branch Manager', 
Hire_Date__c = Date.newinstance(2011, 4,25), IBDC__c = 'David Phan')
};


Contact c2 = new Contact(LastName = 'Tester4',  AccountID=branch.id,Type__c = 'Complex Manager', 
Hire_Date__c = Date.newinstance(2010, 1,25), IBDC__c = 'Matt Hill', Firm_History__c = '');

insert c2;

Contact c3 = new Contact(LastName = 'Tester5',  AccountID=branch.id,Type__c = 'Associate Manager', 
Hire_Date__c = Date.newinstance(2010, 1,25), IBDC__c = 'Matt Hill', Firm_History__c = '');

insert c3;

c3.Termination_Date__c = Date.newinstance(2011,5,2);
update c3;

Task[] t = [SELECT OwnerID FROM Task WHERE Status = 'Incomplete' AND OwnerID = '00550000001fh1m']; //Matt Hill

System.debug('Matt Hills tasks ----------------> ' + t.size());

test.starttest();

system.debug('-------creating contact c1--------');
insert c1;


c2.Type__c = 'Branch Manager';
c2.Firm_History__c = 'Transferred from WBS'; //channel transfers to not get tasks

system.debug('-------updating contact c2--------');
Validator_cls.resetAlreadyDone();

update c2;


c3.Termination_Date__c = NULL;
c3.Type__c = 'FA';
c3.Firm_History__c = 'Rehired';

system.debug('-------updating contact c3--------');
Validator_cls.resetAlreadyDone();

update c3; //should assign 3 tasks

c3.Termination_Date__c = NULL;
c3.Type__c = 'Branch Manager';
c3.Firm_History__c = 'Rehired as Branch Manager';

Validator_cls.resetAlreadyDone();
update c3; //this update should not assign another set of tasks

test.stoptest();

task[] a = [SELECT OwnerID FROM Task WHERE Status = 'Incomplete' AND OwnerID = '00550000001mtxN']; //adrian vega

System.assertequals(a.size(), 6);

task[] d = [SELECT OwnerID FROM Task WHERE Status = 'Incomplete' AND OwnerID = '00550000000oGE5']; //david phan

System.assertequals(d.size(), 6);

task[] m = [SELECT OwnerID FROM Task WHERE Status = 'Incomplete' AND OwnerID = '00550000001fh1m']; //Matt Hill

System.assertequals(m.size(), 3);

}*/
}