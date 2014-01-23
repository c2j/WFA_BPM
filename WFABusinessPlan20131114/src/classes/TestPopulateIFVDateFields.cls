@isTest

public class TestPopulateIFVDateFields {

    static testMethod void TestPopulateIFVDates() {
    
        User RBC = [SELECT ID FROM User WHERE UserRoleID = '00E500000013nin' AND AU__c != Null AND EmployeeNumber != Null 
        AND MobilePhone = '+1 999-999-9999' AND IsActive = True Limit 1];
        
        User IS = [SELECT ID FROM User WHERE UserRoleID = '00E500000013niE' AND AU__c != Null AND EmployeeNumber != Null
        AND MobilePhone = '+1 999-999-9999' AND IsActive = True Limit 1];
        
        Account Branch = new Account();
        Branch.Name = 'Test Branch';
        
        insert Branch;
        
        Opportunity Effort = new Opportunity();
        Effort.RecordTypeID = '01250000000UISS';
        Effort.Name = 'Test Effort';
        Effort.AccountID = Branch.id;
        Effort.StageName = 'Introduced Hiring Manager';
        Effort.CloseDate = date.newinstance(system.now().year(), 12,31);
        
        insert Effort;

        
        test.startTest();
        
        Task IS_Task = new Task(RecordTypeID = '01250000000UIqp', OwnerID = IS.ID, WhatID = Effort.ID, Status = 'Complete', 
        Subject = 'IFV Scheduled', ActivityDate = system.today());
        
        //task owner has integration specialist role, so nothing should happen on the effort;
        insert IS_Task;
        
        Opportunity IFVEffort = [SELECT IFV_Qualifying_Call__c, IFV_Scheduled__c, IFV_Confirmed__c, IFV_Completed__c, IFV_Cancelled__c
                                FROM Opportunity WHERE ID =: Effort.ID];
                                
        System.assertEquals(IFVEffort.IFV_Qualifying_Call__c, null);
        System.assertEquals(IFVEffort.IFV_Scheduled__c, null);
        System.assertEquals(IFVEffort.IFV_Confirmed__c, null);
        System.assertEquals(IFVEffort.IFV_Completed__c, null);
        System.assertEquals(IFVEffort.IFV_Cancelled__c, null);
        
        
        //Tasks owned by user with Regional Business Consultant role, so effort should be updated
        Task[] RBC_Tasks = new Task[] {
        
        new Task(RecordTypeID = '01250000000UIqp', OwnerID = RBC.ID, WhatID = Effort.ID, Status = 'Incomplete', 
        Subject = 'IFV Qualifying Call', ActivityDate = system.today()),
        new Task(RecordTypeID = '01250000000UIqp', OwnerID = RBC.ID, WhatID = Effort.ID, Status = 'Complete', Subject = 'IFV Scheduled', ActivityDate = system.today()),
        new Task(RecordTypeID = '01250000000UIqp', OwnerID = RBC.ID, WhatID = Effort.ID, Status = 'Complete', Subject = 'IFV Confirmed', ActivityDate = system.today()),
        new Task(RecordTypeID = '01250000000UIqp', OwnerID = RBC.ID, WhatID = Effort.ID, Status = 'Complete', Subject = 'IFV Completed', ActivityDate = system.today()),
        new Task(RecordTypeID = '01250000000UIqp', OwnerID = RBC.ID, WhatID = Effort.ID, Status = 'Complete', Subject = 'IFV Cancelled', ActivityDate = system.today())
        };
        
        insert RBC_Tasks;
        
        IFVEffort = [SELECT IFV_Qualifying_Call__c, IFV_Scheduled__c, IFV_Confirmed__c, IFV_Completed__c, IFV_Cancelled__c
                                FROM Opportunity WHERE ID =: Effort.ID];
                                
        System.assertEquals(IFVEffort.IFV_Qualifying_Call__c, null);
        System.assertEquals(IFVEffort.IFV_Scheduled__c, system.today());
        System.assertEquals(IFVEffort.IFV_Confirmed__c, system.today());
        System.assertEquals(IFVEffort.IFV_Completed__c, system.today());
        System.assertEquals(IFVEffort.IFV_Cancelled__c, system.today());
        
        RBC_Tasks[0].status = 'Complete';
        
        update RBC_Tasks;
        
        IFVEffort = [SELECT IFV_Qualifying_Call__c, IFV_Scheduled__c, IFV_Confirmed__c, IFV_Completed__c, IFV_Cancelled__c
                                FROM Opportunity WHERE ID =: Effort.ID];
                                
        System.assertEquals(IFVEffort.IFV_Qualifying_Call__c, system.today());
        
        test.StopTest();

    }
}