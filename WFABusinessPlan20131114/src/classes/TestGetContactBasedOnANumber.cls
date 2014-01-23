@isTest
private class TestGetContactBasedOnANumber { 

static testMethod void testGetContact() { 

Employing_Firm__c f = new Employing_Firm__c (name = 'Employer');
Account b = new Account(name = 'Branch');


Account a = new account(name = 'St. Louis');
insert a;

contact c = new Contact(
FirstName = 'Test',
LastName = 'FA',
Accountid = a.id,
A_Number__c = 'A123456',
Type__c = 'FA',
Hire_Date__c = Date.newinstance(2012,3,25),
IBDC__c = 'Adrian Vega');

insert c;


Contact c2 = new Contact(LastName = 'Test4', Phone = '(314) 123-1238',Type__c = 'Complex Manager', 
Hire_Date__c = Date.newinstance(2010, 1,25), IBDC__c = 'Matt Hill');

insert c2;

c2.Type__c = 'Branch Manager';
c2.Firm_History__c = 'Transferred from WBS'; //channel transfers to not get tasks

update c2;

Case webCase = new case(
Origin = 'Web',
Recordtypeid = '01250000000UIKU',
A_Number__c = 'A123456');

test.startTest();

insert webCase;

test.stopTest();

Case[] wc = [SELECT ID FROM Case WHERE Origin = 'WEB' AND  RecordTypeID = '01250000000UIKU' AND A_Number__c = 'A123456' AND ContactID != Null];

System.assertequals(wc.size(), 1);


}
}