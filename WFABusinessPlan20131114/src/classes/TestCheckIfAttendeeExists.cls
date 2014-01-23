@isTest 
private class TestCheckIfAttendeeExists { 

static testMethod void testAttendeeCheck() { 
    
//create PCG Channel
Channel__c p = new Channel__c();
p.Name = 'PCG';

insert p;


//create WBS Channel
Channel__c w = new Channel__c();
w.Name = 'WBS';

insert w;

//create PCG Branch
Account pb = new Account();
pb.Name = 'PCG Branch';
pb.Channel_Branch__c = p.ID;

Insert pb;


//create WBS Branch
Account wb = new Account();
wb.Name = 'WBS Branch';
wb.Channel_Branch__c = w.ID;

Insert wb;

//create employing firm
Employing_Firm__c ef = new Employing_Firm__c();
ef.recordtypeid = '01250000000UIS9';
ef.Name = 'Test EF';

insert ef;

//create fa talent
FA_Talent__c fat = new FA_Talent__c();
fat.Name = 'Test Person 654321';
fat.FAI_Status__c = 'AV';
fat.Gender__c = 'F';
fat.Employing_Firm__c = ef.id;
fat.First_Name__c = 'Test';
fat.Last_Name__c = 'Person';
fat.At_Firm_Since__c = date.today() - 100;
fat.Broker_Since__c = date.today();
fat.CRD_Number__c = '654321';

insert fat;       

//create fa talent
FA_Talent__c fat2 = new FA_Talent__c();
fat.Name = 'Test Person2 123456';
fat.FAI_Status__c = 'AV';
fat.Gender__c = 'F';
fat.Employing_Firm__c = ef.id;
fat.First_Name__c = 'Test';
fat.Last_Name__c = 'Person2';
fat.At_Firm_Since__c = date.today() - 100;
fat.Broker_Since__c = date.today();
fat.CRD_Number__c = '123456';

insert fat2;  

//Create PCG Effort
Opportunity effort1 = new Opportunity();
effort1.recordtypeid = '01250000000UISS'; //FAI effort
effort1.Name = 'Test Person 654321 Q112';
effort1.FA_Talent_Name__c = fat.id;
effort1.StageName = 'Introduced CO';
effort1.CloseDate = date.newinstance(2012,12,31);
effort1.Accountid = pb.ID; //PCG Branch
effort1.Inactive__c = false;

insert effort1;

//Create 2nd PCG Effort
Opportunity effort2 = new Opportunity();
effort2.recordtypeid = '01250000000UISS'; //FAI effort
effort2.Name = 'Test Person2 123456 Q112';
effort2.FA_Talent_Name__c = fat2.id;
effort2.StageName = 'Introduced CO';
effort2.CloseDate = date.newinstance(2012,12,31);
effort2.Accountid = pb.ID; //PCG Branch
effort2.Inactive__c = false;

insert effort2;

//Create Contact
Contact Tester = new Contact(lastName = 'Testing', Phone = '(314) 875-7358');

insert Tester;

Contact Tester2 = new Contact(lastName = 'Tester', Phone = '(314) 875-7368');

insert Tester2;

// Non DD Special events
SFDC_Special_Event__c WBR = new SFDC_Special_Event__c 
(Category__c = 'Events', ME_Status__c = 'In Progress', Type__c = 'Workshop', 
Name = 'WBR Analyst Workshop');

insert WBR;

SFDC_Special_Event__c Dreamforce = new SFDC_Special_Event__c 
(Category__c = 'Events', ME_Status__c = 'In Progress', Type__c = 'Workshop', 
Name = 'DreamForce');

insert Dreamforce;


//DD Meetings     
SFDC_Special_Event__c DDMtg = new SFDC_Special_Event__c 
(RecordTypeID = '01250000000UJNk', 
Category__c = 'Events', ME_Status__c = 'In Progress', Type__c = 'Recruiting', 
Name = 'FAI DD Meeting', Start_Date__c = date.newinstance(2012,4,4), End_Date__c = date.newinstance(2012,4,5));

insert DDMtg;

SFDC_Special_Event__c DDMtgTwo = new SFDC_Special_Event__c 
(RecordTypeID = '01250000000UJNk', 
Category__c = 'Events', ME_Status__c = 'In Progress', Type__c = 'Recruiting', 
Name = 'FAI DD Meeting Two', Start_Date__c = date.newinstance(2012,6,4), End_Date__c = date.newinstance(2012,6,5));

insert DDMtgTwo;

    
//Contact Attendee        
SFDC_Attendance__c wbranalyst = new SFDC_Attendance__c(attendee__c = Tester.ID, Special_Event__c = WBR.ID);
insert wbranalyst;

SFDC_Attendance__c wbranalysttwo = new SFDC_Attendance__c(attendee__c = Tester2.ID, 
Special_Event__c = DreamForce.ID);
insert wbranalysttwo;


//Effort Attendee
SFDC_Attendance__c DDMtgAttendee = new SFDC_Attendance__c(Effort_Name__c = Effort1.ID, 
Special_Event__c = DDMtg.ID);
insert DDMtgAttendee;

SFDC_Attendance__c DDMtgAttendeetwo = new SFDC_Attendance__c(Effort_Name__c = Effort2.ID, 
Special_Event__c = DDMtgTwo.ID);

insert DDMtgAttendeeTwo;

//test for multiple attendees being inserted at once;
    SFDC_Attendance__c[] ContactAttendees = new SFDC_Attendance__c[] {
    new SFDC_Attendance__c(attendee__c = Tester.ID, Special_Event__c = Dreamforce.ID),
    new SFDC_Attendance__c(Effort_Name__c = Effort1.ID, Special_Event__c = DDMtgTwo.ID),
    new SFDC_Attendance__c(attendee__c = Tester2.ID, Special_Event__c = WBR.ID),
    new SFDC_Attendance__c(Effort_Name__c = Effort2.ID, Special_Event__c = DDMtg.ID)
    }; 
    

    Test.startTest();
    //insert wbranalyst;
    //insert DDMtgAttendee; 
    //insert wbrAnalysttwo; //This contact shouldn't be allowed to be inserted
    //insert DDMtgAttendeetwo; //This contact should be allowed to be inserted
    insert ContactAttendees;
    //Insert EffortAttendees;
    Test.stopTest();
    
    //query for attendees list for a particular contact id and event id
    SFDC_Attendance__c[] ContactAttendeesList = [SELECT attendee__c, Special_Event__c
     FROM SFDC_Attendance__c WHERE attendee__c = :Tester.ID AND Special_Event__c = :WBR.ID];

    //query for attendees list for a particular effort id and event id
     SFDC_Attendance__c[] EffortAttendeesList = [SELECT Effort_Name__c, Special_Event__c
     FROM SFDC_Attendance__c WHERE Effort_Name__c = :Effort1.ID AND Special_Event__c = :DDMtg.ID];


    system.assert(ContactAttendeesList.size() == 1);
    system.assert(EffortAttendeesList.size() == 1);
} 

}