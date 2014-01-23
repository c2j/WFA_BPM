@isTest 
private class TestUpdateEffortInfoOnProspect { 

/*static testMethod void testProspectEffortInfo() { 

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

//list of efforts
Opportunity[] opps;

//Create PCG Effort
Opportunity effort1 = new Opportunity();
effort1.recordtypeid = '01250000000UISO'; //trainee effort
effort1.Name = 'Test Person 654321 Q112';
//effort1.FA_Talent_Name__c = fat.id;
effort1.Occupation__c = 'Analyst';
effort1.StageName = 'Phone Screen';
effort1.FA_Trainee_Status__c = 'Pending';
effort1.CloseDate = date.newinstance(2012,12,31);
effort1.Accountid = pb.ID; //PCG Branch
effort1.Inactive__c = false;

opps.add(effort1);
//insert effort1;

//Create WBS Effort
Opportunity effort2 = new Opportunity();
effort2.recordtypeid = '01250000000UISO'; //trainee effort
effort2.Name = 'Test Person 654321 Q112';
effort2.FA_Talent_Name__c = fat.id;
effort2.Occupation__c = 'Analyst';
effort2.StageName = 'Assessment Stage';
effort2.FA_Trainee_Status__c = 'Active';
effort2.CloseDate = date.newinstance(2012,12,31);
effort2.AccountId = wb.ID; //WBS Branch
effort2.Inactive__c = false;

//insert effort2;

opps.add(effort2);


//Create Prospect
Prospect__c prospect1 = new Prospect__c();
prospect1.Name = 'Test Person';

insert prospect1;

Test.startTest();

insert opps;

opps[0].Prospect__c = prospect1.ID;//link Prospect to pcg effort
opps[1].Prospect__c = prospect1.ID;//link Prospect to wbs effort
//effort2.Inactive__c = True;

update opps;

//Update effort1;
//Update effort2;


Test.stopTest();

//Opportunity[] o = [SELECT Name, FA_Talent_Name__c FROM Opportunity WHERE Name = 'Test Person 654321 Q112'];

//system.debug('o name = ' + o[0].name);
//System.assertequals(o[0].FA_Talent_Name__c, null);
//System.assertequals(o[1].FA_Talent_Name__c, fat.id);


Prospect__c[] pspct = [SELECT Name, PCG_Effort_Stage__c, PCG_Effort_Status__c, PCG__c,
WBS_Effort_Stage__c, WBS_Effort_Status__c, WBS__c FROM Prospect__c 
WHERE Name = 'Test Person'];

system.debug('pspct status ------------------------------> ' + pspct[0].PCG_Effort_Stage__c); 
System.debug('pspct PCG Effort Status------------------------> ' + pspct[0].PCG_Effort_Status__c);
System.Debug('pspct PCG check box----------------------------> ' + pspct[0].PCG__c);


System.assertequals(pspct[0].PCG_Effort_Stage__c, 'Phone Screen');
System.assertequals(pspct[0].PCG_Effort_Status__c, 'Pending');
System.assertequals(pspct[0].PCG__c, True);

System.assertequals(pspct[0].WBS_Effort_Stage__c, 'Assessment Stage');
System.assertequals(pspct[0].WBS_Effort_Status__c, 'Active');
System.assertequals(pspct[0].WBS__c, True);

}*/
}