@isTest

Private Class TestAssigningCABOFollowUpTasks {

//Trigger has been replaced by scheduled apex class ScheduleTaskingForCABOOnDemandCases


Static testMethod void TestAssigningIBDCAndPCCABOTasks () {
//test two fas each submitting a batch of 5 cases

Account branch = new Account(Name='Branch');

insert branch;

User[] Internals = [SELECT ID, Name From User WHERE ProfileID = '00e50000000vBn0' AND IsActive = True Limit 2]; //internal sales rep user
User[] PCs = [SELECT ID, Name From User WHERE ProfileID = '00e50000000vBn5' AND IsActive = True Limit 2]; //PC user


Contact FA1 = new Contact(LastName='FA1', FirstName = 'Test', Type__c = 'FA', AccountID = branch.id,
IBDC__c = Internals[0].Name, Productivity_Consultant__c = PCs[0].Name);

insert FA1;

Contact FA2 = new Contact(LastName='FA2', FirstName = 'Test', Type__c = 'FA', AccountID = branch.id,
IBDC__c = Internals[1].Name, Productivity_Consultant__c = PCs[1].Name);

insert FA2;



/*
List<Case> CaboCases = new List<Case>();
List<Case> CaboCases1 = new List<Case>();
//cabo case record type '012500000005K7J' ; use this in sandbox
//Cabo on demand record type '01250000000UKbR'; use this in production

 //This Negative test Case---SFDC
 
for (Integer i=0;i<5;i++) {
    Case CABO1 = new Case(
                RecordTypeID = '01250000000UKbR',
                ContactID = FA1.ID,
                Client_Name__c = 'Test123',
                Account_Number_s__c = '1234567' + i,
                Which_Product__c = 'Asset Advisor',
                Subject = 'Assigning CABO Tasks',
                Case_Created_Date__c = date.newinstance(2012,11,9)
                );
    CaboCases1.add(CABO1);
}
for (Integer i=5;i<10;i++) {
    Case CABO1 = new Case(
                RecordTypeID = '01250000000UKbR',
                ContactID = FA2.ID,
                Client_Name__c = 'Test123',
                Account_Number_s__c = '2345678' + i,
                Which_Product__c = 'Allocation Advisors',
                Subject = 'Assigning CABO Tasks',
                Case_Created_Date__c = date.newinstance(2012,11,9)
                );
                
    CaboCases1.add(CABO1);
}
 
  Case CABO2 = new Case(
                RecordTypeID = '01250000000UKbR',
                ContactID = fa2.id,
                Client_Name__c = 'Test123',
                Account_Number_s__c = '23145678',
                Which_Product__c = 'Allocation Advisors',
                Subject = 'Assigning CABO Tasks',
                Case_Created_Date__c = date.newinstance(2012,11,9)
                );
         CaboCases1.add(CABO2);
                       


test.startTest();

insert CaboCases1;

Task[] InitialIBDCTasks = [SELECT First_CABO_Follow_Up__c, Assign_IBDC_CABO_Follow_Up__c, Status FROM Task 
WHERE Status = 'Incomplete' AND Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task'];

system.assertequals(InitialIBDCTasks.size(),0); //there should be no tasks inserted since there haven't been cabo on demand cases
                                                //inserted in the 7 days before CABOCases1 were inserted.




//Going to simulate FAs submitting another batch of Cases. Since the initial PC tasks are not closed, there should be
//no PC tasks created this round.

  //This Positive test Case---SFDC
       
for (Integer i=0;i<5;i++) 
{
Case CABO = new Case(
            RecordTypeID = '01250000000UKbR',
            ContactID = FA1.ID,
            Client_Name__c = 'Test FA1',
            Account_Number_s__c = '1234567' + i,
            Which_Product__c = 'Asset Advisor',
            Subject = 'Assigning CABO Tasks',
            Case_Created_Date__c = date.newinstance(2012,11,16)
            );
            
CaboCases.add(CABO);
}

for (Integer i=5;i<10;i++) 
{
    Case CABO = new Case(
                RecordTypeID = '01250000000UKbR',
                ContactID = FA2.ID,
                Client_Name__c = 'Test FA1',
                Account_Number_s__c = '2345678' + i,
                Which_Product__c = 'Allocation Advisors',
                Subject = 'Assigning CABO Tasks',
                Case_Created_Date__c = date.newinstance(2012,11,16)
                );
                
    CaboCases.add(CABO);
}

system.debug('-----------inserting second batch of cabo cases------------');

Validator_cls.resetAlreadyDone();

insert CaboCases; //this should query the cases created in the past 7 days from 11/16/2012

InitialIBDCTasks = [SELECT First_CABO_Follow_Up__c, Assign_IBDC_CABO_Follow_Up__c, Status FROM Task 
WHERE Status = 'Incomplete' AND Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task'];

system.assertequals(InitialIBDCTasks.size(),2);

For (task t: InitialIBDCTasks) {
    t.First_CABO_Follow_Up__c = 'FA not available (PC Follow Up)';
    //t.Assign_IBDC_CABO_Follow_Up__c = True;
    t.Status = 'Complete'; //marking the tasks complete
}

Update InitialIBDCTasks; //closing out the initial ibdc tasks. Two PC Tasks should be assigned


Task[] PCTasks = [SELECT First_CABO_Follow_Up__c, Third_CABO_Follow_Up__c, 
Assign_IBDC_CABO_Follow_Up__c, Status FROM Task 
WHERE Status = 'Incomplete' AND Sales_Strategy_Initiative__c = 'PC CABO Follow Up Task' AND
First_CABO_Follow_Up__c = 'FA not available (PC Follow Up)'];

system.assertequals(PCTasks.size(),1);


Case CABOForFA1 = new Case(
                RecordTypeID = '01250000000UKbR',
                ContactID = FA1.ID,
                Client_Name__c = 'Test FA1',
                Account_Number_s__c = '68238593',
                Which_Product__c = 'Allocation Advisors',
                Subject = 'Assigning CABO Tasks',
                Case_Created_Date__c = date.newinstance(2012,11,23)
                );


Validator_cls.resetAlreadyDone();
insert CABOForFA1; //this should create another ibdc task for FA1


InitialIBDCTasks = [SELECT First_CABO_Follow_Up__c, Assign_IBDC_CABO_Follow_Up__c, Status FROM Task 
WHERE Status = 'Incomplete' AND Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task'];

system.assertequals(InitialIBDCTasks.size(),2); //still 1 for FA1 and 1 for FA2
*/

List<Task> InitialIBDCTasks = new List<Task>();

task t1 = new Task(RecordTypeID='012300000000V1J',OwnerID=Internals[0].id, WhoID = FA1.ID,
                Subject='CABO', Category__c = 'CABO-Follow Up Task', Type = 'Contact-Phone', 
                Communication_Type__c = 'Outbound', Status = 'Incomplete', 
                Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task', 
                ActivityDate = date.newinstance(2013,1,30),
                Task_Due_Date__c = date.newinstance(2013,1,30));
                
task t2 = new Task(RecordTypeID='012300000000V1J',OwnerID=Internals[1].id, WhoID = FA2.ID,
                Subject='CABO', Category__c = 'CABO-Follow Up Task', Type = 'Contact-Phone', 
                Communication_Type__c = 'Outbound', Status = 'Incomplete', 
                Sales_Strategy_Initiative__c = 'IBDC CABO Follow Up Task', 
                ActivityDate = date.newinstance(2013,1,30),
                Task_Due_Date__c = date.newinstance(2013,1,30));
                 
InitialIBDCTasks.add(t1);
InitialIBDCTasks.add(t2);

insert InitialIBDCTasks;

test.startTest();

InitialIBDCTasks[0].First_CABO_Follow_Up__c = 'FA has already sent proposals to the clients (PC Follow Up)';
InitialIBDCTasks[0].Status = 'Complete';

InitialIBDCTasks[1].First_CABO_Follow_Up__c = 'FA not available (PC Follow Up)';
InitialIBDCTasks[1].Status = 'Complete';

Update InitialIBDCTasks; //closing out the ibdc tasks. There should be no new PC Tasks assigned since 
                        //the ones from the previous set of cases are still incomplete

Task[] PCTasks = [SELECT First_CABO_Follow_Up__c, Third_CABO_Follow_Up__c, 
Assign_IBDC_CABO_Follow_Up__c, Status FROM Task 
WHERE Status = 'Incomplete' AND Sales_Strategy_Initiative__c = 'PC CABO Follow Up Task'];

system.assertequals(PCTasks.size(),2); //1

PCTasks = [SELECT First_CABO_Follow_Up__c, Third_CABO_Follow_Up__c, 
Assign_IBDC_CABO_Follow_Up__c, Status FROM Task 
WHERE Status = 'Incomplete' AND Sales_Strategy_Initiative__c = 'PC CABO Follow Up Task' AND
First_CABO_Follow_Up__c = 'FA has already sent proposals to the clients (No PC Follow Up)']; //the PC tasks for FA1 and FA2 should now have FA Not Available for the ibdc follow up'

system.assertequals(PCTasks.size(),0);

PCTasks = [SELECT First_CABO_Follow_Up__c, Third_CABO_Follow_Up__c, 
Assign_IBDC_CABO_Follow_Up__c, Status FROM Task 
WHERE Status = 'Incomplete' AND Sales_Strategy_Initiative__c = 'PC CABO Follow Up Task' AND
First_CABO_Follow_Up__c = 'FA has serious plans to send proposals to the clients']; //the PC tasks for FA1 and FA2 should now have FA Not Available for the ibdc follow up'

system.assertequals(PCTasks.size(),0);

//}

test.StopTest();
}

}
/*
       /* for (Case c1: CaboCases1) 
        {
             c1.Assign_IBDC_Task__c = True;
        }
        try
        {
          update CaboCases1;
        }
        Catch (DmlException e) 
        {
              Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
               System.AssertEquals(expectedExceptionThrown, true);
              CaboCases1.clear();
        }
 */
    

/*
            for (Case c: CaboCases) 
            {
           c.Assign_IBDC_Task__c = True;
            }
      
      try
          {  
            update CaboCases; 
          }
      Catch(DMLException e)
          {
                Boolean expectedExceptionThrown =  e.getMessage().contains('FA has an inactive IBDC') ? true : false;
                System.debug('%%%%%%%%%'+expectedExceptionThrown);
          }
*/
 

//if(CaboCases.Size()>0)
//{*/