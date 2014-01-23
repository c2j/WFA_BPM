@isTest 
private class TestPopulateChildFieldsForFAProfile { 
 /*  class no longer needed since managers have access to profiling information record
 
static testMethod void testPopulateChildFields() { 


//UpdateDialInfo Test info------------------------------

Employing_Firm__c f = new Employing_Firm__c (name = 'Employer');
Account b = new Account(name = 'Branch');

FA_Talent__c[] FTals = new FA_Talent__c[] {
    new FA_Talent__c(Name = 'Test FA 1', Employing_Firm__c=f.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 1'),
    
    new FA_Talent__c(Name = 'Test FA 2', Employing_Firm__c=f.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 2')
    }; 

insert FTals;


Opportunity[] Efforts = new Opportunity[] {
    new Opportunity(Name = 'Test FA 1 Q212', FA_Talent_Name__c = FTals[0].id, StageName = 'Introduced CO', 
    CloseDate = date.newinstance(2012,12,31), AccountId = b.id),
    new Opportunity(Name = 'Test FA 2 Q212', FA_Talent_Name__c = FTals[1].id, StageName = 'Introduced CO', 
    CloseDate = date.newinstance(2012,12,31),AccountId = b.id)
    }; 

insert Efforts;

User u1 = [SELECT id, name FROM User WHERE Name = 'Jerry Yu'];
User u2 = [SELECT id, name FROM User WHERE Name = 'Lee Polidoro'];


Task[] FARStasks = new Task[] {
    new Task(RecordTypeId = '01250000000UJQA', OwnerId = u1.id, Subject = 'Dial', 
    Type = 'Call-Conference', Status = 'Complete', WhatID = FTals[0].id),
    
    new Task(RecordTypeId = '01250000000UBOX', OwnerId = u2.id, Subject = 'Branding', //marketing activity
    Category__c = 'Branding-Brand Review', Type = 'Live Meeting', Live_Meeting_Names__c = 'E-mail Express', 
    Status = 'Complete', WhatID = Efforts[0].id)   
  
};

insert FARStasks;

//----------------------------


//IBDC tasks on new hires test info

Contact[] c1 = new Contact[] {
new Contact(LastName = 'Test', Phone = '(314) 123-1234', Type__c = 'FA', 
Hire_Date__c = Date.newinstance(2012, 3,25), IBDC__c = 'Adrian Vega')
};

insert c1;

//--------------------------------


//Count MOD Live meeting test info---------------------------------
Contact cm = new Contact(LastName = 'Test', Phone = '(314) 123-1234');
insert cm;

Marketing__c m = new Marketing__c(Name = 'Mkting', Contact__c = cm.ID);
insert m;

Task[] t = new Task[]{new Task(RecordTypeID = '01250000000UBOX', WhoID = cm.ID, ActivityDate = date.newInstance(2012, 2, 20),
Subject = 'Branding', Category__c = 'Branding-Brand Review', Type = 'Live Meeting',
Live_Meeting_Names__c = 'E-Mail Express')
};

insert t;

//----------------------------------------

//Populate Child Fieds Test Info-------------------------------------
Contact[] c = new contact[] {
new contact(lastname = 'Test1', Phone = '(314) 123-1234'),
new contact(lastname = 'Test2', Phone = '(314) 123-1235')
}; 

insert c;

Child__c[] ch1 = new child__c[] {
new child__c(name = 'Child1', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child2', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child3', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child4', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child5', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child6', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child7', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child8', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child9', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child10', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child11', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School'),
new child__c(name = 'Child11', Parent__c = c[0].id,Child_Last_Name__c = 'test1', Child_Address_1__c = '123 Main Street', Child_Zip__c = '63130', Child_School_College__c = 'School')
};

insert ch1;

Child__c[] ch2 = new child__c[] {
new child__c(name = 'Child1', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child2', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child3', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child4', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child5', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child6', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child7', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child8', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child9', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child10', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child11', Parent__c = c[1].id,Child_Last_Name__c = 'test2'),
new child__c(name = 'Child11', Parent__c = c[1].id,Child_Last_Name__c = 'test2')
};


test.starttest();

insert ch2;

ch2[0].Relationship_Type__c = 'Child';
update ch2;

delete ch1[0];
delete ch1[4];
delete ch2[2];
delete ch2[6];

test.stoptest();

Contact[] cons = [SELECT name, ChildFieldsPart1__c FROM Contact WHERE ChildFieldsPart1__c != NULL];

for (integer i = 0; i <cons.size(); i++) {
    system.debug('Contact Name ----------------> ' + cons[i].name);
}

system.assertequals(cons.size(), 2);

}
*/
}