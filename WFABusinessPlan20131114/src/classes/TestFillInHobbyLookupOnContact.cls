@isTest 
private class TestFillInHobbyLookupOnContact { 

/*
static testMethod void testlookupfieldupdate() { 

//------------Test Update Dial info on FA talent--------------------
Employing_Firm__c ef = new Employing_Firm__c(Name = 'Employer');
Account a = new account(name = 'Branch');

FA_Talent__c[] FTals = new FA_Talent__c[] {
    new FA_Talent__c(Name = 'Test FA 1', Employing_Firm__c=ef.id, 
    FAI_Status__c = 'AV', Gender__c = 'M', First_Name__c = 'Test', Last_Name__c = 'FA 1')};

insert FTals;

Opportunity[] Efforts = new Opportunity[] {
    new Opportunity(Name = 'Test FA 1 Q212', FA_Talent_Name__c = FTals[0].id, StageName = 'Introduced CO', 
    CloseDate = date.newinstance(2012,12,31), AccountId = a.id)};

insert Efforts;
User u1 = [SELECT id, name FROM User WHERE Name = 'Jerry Yu'];

Task[] FARStasks = new Task[] {
    new Task(RecordTypeId = '01250000000UJQA', OwnerId = u1.id, Subject = 'Dial', 
    Type = 'Call-Conference', Status = 'Complete', WhatID = FTals[0].id)}
    ;
insert FARStasks;  

//-------------------------------------------------

  
/*IBDC Tasks on New Contact test info */
/*
Contact[] c1 = new Contact[] {
new Contact(LastName = 'Test', Phone = '(314) 123-1234', Type__c = 'FA', 
Hire_Date__c = Date.newinstance(2012, 3,25), IBDC__c = 'Adrian Vega'),
new Contact(LastName = 'Test1', Phone = '(314) 123-1235',Type__c = 'FA in Training', 
Hire_Date__c = Date.newinstance(2012, 2,25), IBDC__c = 'Adrian Vega'),
new Contact(LastName = 'Test2', Phone = '(314) 123-1236',Type__c = 'Licensee', 
Hire_Date__c = Date.newinstance(2012, 1,25), IBDC__c = 'David Phan'),
new Contact(LastName = 'Test3', Phone = '(314) 123-1237',Type__c = 'Branch Manager', 
Hire_Date__c = Date.newinstance(2011, 4,25), IBDC__c = 'David Phan')
};


/*-------------------------*/
/*
Contact[] c = new Contact[] {
new Contact(LastName = 'Test', Phone = '(314) 123-1234'),
new Contact(LastName = 'Test1', Phone = '(314) 123-1235'),
new Contact(LastName = 'Test2', Phone = '(314) 123-1236'),
new Contact(LastName = 'Test3', Phone = '(314) 123-1237')
};

insert c;

Hobbies_Charities__c hb = new hobbies_charities__c(Name = 'Test1hobbies', Name__c = c[0].id);
insert hb;

Hobbies_Charities__c[] h = new hobbies_charities__c[] {
new hobbies_charities__c(Name = 'Test2hobbies', Name__c = c[1].id),
new hobbies_charities__c(Name = 'Test3hobbies', Name__c = c[2].id),
new hobbies_charities__c(Name = 'Test4hobbies', Name__c = c[3].id)
};


Test.startTest();

//------------IBDC Tasks on New Contact test info------------------
insert c1;
//------------IBDC Tasks on New Contact test info End------------------
insert h;

test.Stoptest();

contact[] con = [SELECT Number_Of_Hobby_Records__c FROM Contact where Number_Of_Hobby_Records__c = 2];

System.assertequals(con.size(),0);

}
*/
}