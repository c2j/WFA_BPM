@isTest 
private class TestCreatingLeadsFollowUpTasks { 

//Trigger created and named for the leads oversight pilot, but now being reactivated for the client referral sweepstakes

static testMethod void testLeadsTasks() { 

User[] IBDCS = [SELECT ID, Name FROM User WHERE ProfileID = '00e50000000vBn0' AND isActive = True Limit 2];
User[] PCS = [SELECT ID, Name FROM User WHERE ProfileID = '00e50000000vBn5' AND isActive = True Limit 2];

Account b = new Account(Name='Branch');
insert b;

Contact c = new Contact(FirstName='Test', LastName = 'FA', Type__c='FA', IBDC__c=IBDCS[0].Name, AccountID=b.id,
Productivity_Consultant__c = PCS[0].Name);

insert c;

Contact c2 = new Contact(FirstName='Test', LastName = 'FA2', Type__c='FA', IBDC__c=IBDCS[1].Name, AccountID=b.id,
Productivity_Consultant__c = PCS[1].Name);

insert c2;

Contact mgr = new Contact(FirstName='Test', LastName = 'Mgr', Type__c='Branch Manager', IBDC__c=IBDCS[0].Name, AccountID=b.id,
Productivity_Consultant__c = 'PCS[0].Name', email = 'jerry.yu@wellsfargoadvisors.com');

insert mgr;

b.Manager_Branch__c = mgr.id;
update b;

list<Lead> Leads = new List<Lead>();

for (integer i = 1;i<11;i++) {
lead l = new Lead(LastName='Test Lead ' + i, Company='Client Referral Sweepstakes', Assigned_FA__c = c.id);

Leads.add(l);

}

for (integer i = 11;i<21;i++) {
lead l = new Lead(LastName='Test Lead ' + i, Company='Client Referral Sweepstakes', Assigned_FA__c = c2.id);

Leads.add(l);

}


test.StartTest();

insert Leads;

//Lead[] Leads = [SELECT Branch_Manager_Email__c FROM Lead WHERE LastName = 'Test Lead 1'];

//System.assertequals(OversightLeads[0].Branch_Manager_Email__c, 'jerry.yu@wellsfargoadvisors.com');

Task[] t1 = [SELECT ID FROM Task WHERE Subject = 'Leads Distribution' AND WhoID =: c.ID AND OwnerID = : IBDCS[0].ID AND Status = 'Incomplete'];
Task[] t2 = [SELECT ID FROM Task WHERE Subject = 'Leads Distribution' AND WhoID =: c2.ID AND OwnerID = : IBDCS[1].ID AND Status = 'Incomplete'];

System.assertequals(t1.size(), 1); //10
System.assertequals(t2.size(), 1); //10

//Task[] tsk = [SELECT ID FROM Task WHERE Subject = 'Leads Distribution' AND OwnerID = : IBDCS[0].ID AND WhoID = : c.id ];

//for (task t: tsk) {
//t.Lead_Rating__c = 'Follow Up Needed';
//t.Lead_Outcome__c = 'Lead Contacted-no response, still pursuing';
//t.Status = 'Complete'; //mark first task complete
//}

//mark initial contact task complete, with a need to follow up

t1[0].Lead_Rating__c = 'Follow Up Needed';
t1[0].Lead_Outcome__c = 'Lead Contacted-no response, still pursuing';
t1[0].Status = 'Complete';
t1[0].Type = 'Call-Individual';

Validator_cls.resetAlreadyDone();

update t1;

task[] closedTask = [SELECT ID FROM Task WHERE WhoID = : c.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[0].ID AND Status = 'Complete'];

task[] openTask = [SELECT ID, Subject, Category__c  FROM Task WHERE WhoID =: c.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[0].ID AND Status = 'Incomplete'];

system.assertequals(closedTask.size(),1); //10
system.assertequals(openTask.size(),1); //10

system.debug('Open Task---------- ' + openTask[0].subject + '/' + opentask[0].category__c);

opentask[0].Lead_Rating__c = 'No Follow Up Needed'; 
opentask[0].Lead_Outcome__c  = 'Lead Contacted - Not Interested'; //new outcome for second follow up
opentask[0].Status = 'Complete'; //mark second task complete

Validator_cls.resetAlreadyDone();

Update Opentask;


closedTask = [SELECT ID FROM Task WHERE WhoID = : c.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[0].ID AND Status = 'Complete'];

openTask = [SELECT ID,Subject, Category__c  FROM Task WHERE WhoID =: c.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[0].ID AND Status = 'Incomplete'];


system.assertequals(closedTask.size(),2);//11
system.assertequals(openTask.size(),0);//10

//mark initial lead follow up task for FA 2. No follow up should be created
t2[0].Lead_Rating__c = 'No Follow Up Needed';
t2[0].Lead_Outcome__c = 'Lead Contacted-not interested';
t2[0].Status = 'Complete';

Validator_cls.resetAlreadyDone();

update t2;

closedTask = [SELECT ID FROM Task WHERE WhoID = : c2.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[1].ID AND Status = 'Complete'];

openTask = [SELECT ID, Subject, Category__c  FROM Task WHERE WhoID =: c2.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[1].ID AND Status = 'Incomplete'];

system.assertequals(closedTask.size(),1); //10
system.assertequals(openTask.size(),0); //10


//system.debug('Open Task---------- ' + openTask[0].subject + '/' + opentask[0].category__c);

/*
openTask[0].status='Complete'; //mark third task complete

Update Opentask;

closedTask = [SELECT ID FROM Task WHERE WhoID = : c.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[0].ID AND Status = 'Complete'];

openTask = [SELECT ID, Subject, Category__c FROM Task WHERE WhoID =: c.id AND 
Subject = 'Leads Distribution' AND OwnerID = : IBDCS[0].ID AND Status = 'Incomplete'];


system.assertequals(closedTask.size(),12);

//system.debug('Open Task---------- ' + openTask[0].subject + '/' + opentask[0].category__c);

system.assertequals(openTask.size(),10);

*/

test.StopTest();
}

}