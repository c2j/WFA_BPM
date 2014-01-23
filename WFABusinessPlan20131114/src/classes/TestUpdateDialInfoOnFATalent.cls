@isTest 

private class TestUpdateDialInfoOnFATalent { 

static testMethod void testUpdateDialInfo() { 

Employing_Firm__c ef = new Employing_Firm__c(Name = 'Employer');
insert ef;

Channel__c PCG = new Channel__c(Name = 'PCG');
insert PCG;
Channel__c WBS = new Channel__c(Name = 'WBS');
insert WBS;

Region__c region = new Region__c(name='Region');
insert region;

Account a = new account(name = 'Branch', Region_Branch__c = region.Id,Channel_Branch__c = pcg.id);

insert a;

Account wB = new account(name = 'wbs Branch', Channel_Branch__c = wbs.id);

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

Opportunity[] Efforts = new Opportunity[] {
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 1 Q212', FA_Talent_Name__c = FTals[0].id, StageName = 'Introduced CO', 
    CloseDate = date.newinstance(2012,12,31), AccountId = a.id, Recent_Activities_Information__c = NULL),
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 2 Q212', FA_Talent_Name__c = FTals[1].id, StageName = 'Deal Offered', 
    CloseDate = date.newinstance(2011,7,31),AccountId = a.id,Recent_Activities_Information__c = NULL),
    new Opportunity(RecordTypeID = '01250000000UISS', Name = 'Test FA 2 Q212', FA_Talent_Name__c = FTals[0].id, StageName = 'Introduced Co',
    CloseDate = date.newinstance(2011,7,31),AccountId = wb.id,Recent_Activities_Information__c = NULL)
    }; 

insert Efforts;

/*Efforts[1].StageName = 'Hired';
Efforts[2].StageName = 'Hired';
update Efforts;

FTals[0].FAI_Status__c = 'HIRED';
FTals[1].FAI_Status__c = 'HIRED';
update FTals;

Manager[0].Termination_Date__c = date.newinstance(2012,1,5);
update manager;

Manager[0].Firm_History__c = 'Transfered job title';
Manager[0].Termination_Date__c = NULL;
update manager;*/

User u1 = [SELECT id, name FROM User WHERE Name = 'Jerry Yu'];
User u2 = [SELECT id, name FROM User WHERE ProfileID ='00e50000000z2Gt' AND IsActive = True Limit 1];

system.debug('u1 -------> = ' + u1.id + ', ' + u1.Name);
system.debug('u2 -------> = ' + u2.id + ', ' + u2.Name);

Task[] FARStasks = new Task[] {
    new Task(RecordTypeId = '01250000000UJQA', OwnerId = u1.id, Subject = 'Dial', 
    Type = 'Call-Conference', Status = 'Complete', WhatID = FTals[0].id, ActivityDate = date.newinstance(2012,7,25)),
    
    new Task(RecordTypeId = '01250000000UJQA', OwnerId = u1.id, Subject = 'Dial', 
    Type = 'Call-Conference', Status = 'Incomplete', WhatID = Efforts[0].id,ActivityDate = date.newinstance(2012,7,25)),
    
    new Task(RecordTypeId = '01250000000UIqp', OwnerId = u1.id, Subject = 'Coaching', Category__c = 'Coaching-Integration Best Practices',
    Type = 'Contact-Phone', Status = 'Complete', WhatID = Efforts[0].id,ActivityDate = date.newinstance(2012,7,25)),
    
    new Task(RecordTypeId = '01250000000UJQA', OwnerId = u2.id, Subject = 'Dial', 
    Type = 'Call - LM', Status = 'Complete', WhatID = FTals[1].id,ActivityDate = date.newinstance(2012,7,25)),
    
    new Task(RecordTypeId = '01250000000UJQA', OwnerId = u2.id, Subject = 'Call', 
    Type = 'Meeting', Status = 'Complete', WhatID = Efforts[1].id,ActivityDate = date.newinstance(2012,7,25)),    
    
    new Task(RecordTypeId = '01250000000UBOX', OwnerId = u2.id, Subject = 'Branding', //marketing activity
    Category__c = 'Branding-Brand Review', Type = 'Live Meeting', Live_Meeting_Names__c = 'E-mail Express', 
    Status = 'Complete', WhatID = Efforts[0].id,ActivityDate = date.newinstance(2012,7,25)),   
    
    new Task(RecordTypeId = '012300000000V1J', OwnerId = u2.id, Subject = 'Advisory', //internal activity
    Category__c = 'Advisory-CABO', Type = 'Email', Status = 'Complete', WhatID = Efforts[1].id,ActivityDate = date.newinstance(2012,7,25))   
    };
    
    insert FARStasks;

Test.startTest();

//insert FARStasks;
FARStasks[1].status = 'Complete';
FARStasks[1].Activity_Type_2__c = 'Call-Conference';
System.debug('FARSTask 1: ' + FARSTasks[1]);
Update FARStasks;

Test.StopTest();

FA_Talent__c[] ft = [SELECT Name, Dials__c, Dialer__c, AV2_Date__c FROM FA_TALENT__c WHERE Dials__c >0];


System.assertequals(ft.size(), 2);

/*System.assertequals(FTals[0].Dials__c, 1);
System.assertequals(FTals[0].Dialer__c, u1.Name);
System.assertequals(FTals[0].AV2_Date__c, date.newinstance(2012,4,13));
    
System.assertequals(FTals[1].Dials__c, 2);
System.assertequals(FTals[1].Dialer__c, u2.Name);
System.assertequals(FTals[1].AV2_Date__c, date.newinstance(2012,4,13));*/


}
}