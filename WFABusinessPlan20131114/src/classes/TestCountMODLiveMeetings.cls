@isTest 
private class TestCountMODLiveMeetings { 

static testMethod void testLiveMeetingCount() { 

Contact c = new Contact(LastName = 'Test', Phone = '(314) 123-1234');
insert c;

Marketing__c m = new Marketing__c(Name = 'Mkting', Contact__c = c.ID);
insert m;

Task[] t = new Task[]{new Task(RecordTypeID = '01250000000UBOX', WhoID = c.ID, ActivityDate = date.newInstance(2012, 2, 20),
Subject = 'Branding', Category__c = 'Branding-Brand Review', Type = 'Live Meeting',
Live_Meeting_Names__c = 'E-Mail Express', Status='Complete'),

new Task(RecordTypeID = '01250000000UBOX', WhoID = c.ID, ActivityDate = date.newInstance(2012, 3, 30),
Subject = 'Branding', Category__c = 'Branding-Custom Logo', Type = 'Live Meeting',
Live_Meeting_Names__c = 'Tap Into Your Marketing Resources', Status='Complete') };

test.startTest();

insert t;

Marketing__c[] mkt = [SELECT Contact__c, Number_Of_Live_Meetings_Attended__c, Most_Recent_Live_Meeting__c,
Most_Recent_Live_Meeting_Date__c FROM Marketing__c WHERE Contact__c in :[SELECT ID From Contact]];

System.assertequals(2,mkt[0].Number_Of_Live_Meetings_Attended__c);
System.assertequals('Tap Into Your Marketing Resources',mkt[0].Most_Recent_Live_Meeting__c);
System.assertequals(date.newinstance(2012,3,30),mkt[0].Most_Recent_Live_Meeting_Date__c);

t[0].ActivityDate = date.NewInstance(2012,4,8);


update t;

Test.StopTest();

Marketing__c[] mkting = [SELECT Contact__c, Number_Of_Live_Meetings_Attended__c, Most_Recent_Live_Meeting__c,
Most_Recent_Live_Meeting_Date__c FROM Marketing__c WHERE Contact__c in :[SELECT ID From Contact]];

System.assertequals(2,mkting[0].Number_Of_Live_Meetings_Attended__c);
System.assertequals('E-Mail Express',mkting[0].Most_Recent_Live_Meeting__c);
System.assertequals(date.NewInstance(2012,4,8),mkting[0].Most_Recent_Live_Meeting_Date__c);


}
}