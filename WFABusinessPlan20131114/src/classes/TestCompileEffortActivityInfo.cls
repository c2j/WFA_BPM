@isTest
Private Class TestCompileEffortActivityInfo {

static testMethod void testAggregateActivityInfo() {

Employing_Firm__c ef = new Employing_Firm__c(Name = 'Employer');
insert ef;

Channel__c PCG = new Channel__c(Name = 'PCG');
insert PCG;
Channel__c WBS = new Channel__c(Name = 'WBS');
insert WBS;

Region__c region = new Region__c(name='Region');
insert region;

Account a = new account(name = 'Branch', Region_Branch__c = region.Id, Channel_Branch__c = pcg.id);

insert a;

Account wB = new account(name = 'wbs Branch', Region_Branch__c = region.Id, Channel_Branch__c = wbs.id);

insert wB;

Contact[] manager = new Contact[] {
new Contact(FirstName = 'Manager', LastName = 'FA', AccountID = a.id, Type__c = 'Branch Manager', IBDC__c = 'Adrian Vega',
Hire_Date__c = date.newinstance(2012,7,25)),
new Contact(FirstName = 'Manager 1', LastName = 'FA', AccountID = wb.id, Type__c = 'Branch Manager',
Hire_Date__c = date.newinstance(2012,7,25))
};

insert manager;

Main_Branch__c[] mainBranch = new Main_Branch__c[] {new Main_Branch__c(Name = 'Main Branch',Manager_Main_Branch__c=manager[0].id),
new Main_Branch__c(Name = 'Main Branch 1',Manager_Main_Branch__c=manager[1].id)};

insert mainBranch;

a.Main_Branch__c = mainBranch[0].id;
a.Manager_Branch__c = manager[0].id;
update a;
wB.Main_Branch__c = mainBranch[1].id;
wB.Manager_Branch__c = manager[1].id;
update wB;

FA_Talent__c[] FTals = new FA_Talent__c[] {
    new FA_Talent__c(Name = 'Test FA 1', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 1', A_Number__c = 'A222222'),
    
    new FA_Talent__c(Name = 'Test FA 2', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 2', A_Number__c = 'A111111')
    }; 

insert FTals;

User[] RBC = [SELECT ID FROM User WHERE UserRoleID = '00E500000013nin' AND AU__c != Null AND EmployeeNumber != Null 
AND MobilePhone = '+1 999-999-9999' AND IsActive = True Limit 2];

Opportunity[] Efforts = new Opportunity[] {
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 1 Q212', FA_Talent_Name__c = FTals[0].id, StageName = 'Introduced CO', 
    CloseDate = date.newinstance(2012,12,31), AccountId = a.id, Recent_Activities_Information__c = NULL, OwnerID = RBC[0].id, inactive__c = true),
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 2 Q212', FA_Talent_Name__c = FTals[1].id, StageName = 'Deal Offered',
    CloseDate = date.newinstance(2011,7,31),AccountId = a.id,Recent_Activities_Information__c = NULL,OwnerID = RBC[0].id),
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 2 Q212', FA_Talent_Name__c = FTals[0].id, StageName = 'Introduced Co',
    CloseDate = date.newinstance(2011,7,31),AccountId = wb.id,Recent_Activities_Information__c = NULL,OwnerID = RBC[0].id)
    }; 

insert Efforts;

test.StartTest();

system.debug('Effort 0 ID----------- ' + Efforts[0].ID);
List<Task> FAITasks = new List<Task>();

Task t;
for (integer i = 0; i < 201; i++) {
if (Math.mod(i,2)==0) {
t = new Task(RecordTypeID = '01250000000UIqp', OwnerId = RBC[0].ID, Type = 'Meeting',
    Subject = 'Coaching', Category__c = 'Coaching-Integration Best Practices', 
    Communication_Type__c = 'FA', Status = 'Complete', WhatID = Efforts[0].id, Description = 'Test',
    ActivityDate=date.newinstance(2012,7,26));
} else {
t = new Task(RecordTypeID = '01250000000UIqp', OwnerId = RBC[1].id, Type = 'Meeting',
    Subject = 'Coaching', Category__c = 'Coaching-Integration Best Practices', 
    Communication_Type__c = 'FA', Status = 'Complete', WhatID = Efforts[1].id, Description = 'Test',
    ActivityDate=date.newinstance(2012,7,26));
}

FAITasks.add(t);                 
}


insert FAItasks;

FAITasks[0].Description = 'Testing Trigger';
update FAITasks;



test.StopTest();


Opportunity[] EffortsWithActivities = [SELECT Recent_Activities_Information__c FROM Opportunity WHERE ID = : Efforts[0].id];
string RecentActInfo = EffortsWithActivities[0].Recent_Activities_Information__c;

system.debug('Recent Activities Information -------------- ' + RecentActInfo);
system.assert(RecentActInfo != NULL);  
//system.assertequals(RecentActInfo.contains('Lisa Stumpf'),True);  
//system.assertequals(RecentActInfo.contains('Testing Trigger'),True);  
}
}