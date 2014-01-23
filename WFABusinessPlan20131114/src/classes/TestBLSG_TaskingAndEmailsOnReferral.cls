@isTest
public class TestBLSG_TaskingAndEmailsOnReferral {

    static testMethod void TestManageBLSGTaskAndEmailsOnReferral() {
    
        string ReferralRecType = '01250000000UNIi'; //BLSG Production Referral Record Type ID '01250000000UNIi'//Sandbox '012P0000000Cvrx';
        string TaskRecType = '01250000000UMv5'; //Production BLSG Task Rec Type ID 01250000000UMv5; sandbox BLSG Task Rec Type ID 012P0000000Cvxv
        
        Channel__c PCG = new Channel__c(Name = 'PCG');
        
        Account branch = new Account();
        branch.name = 'Test Branch';
        branch.Business_Lending_Consultant__c = '';
        branch.Channel_Branch__c = PCG.id;
        
        insert branch;
        
        Contact FA = new Contact();
        FA.FirstName = 'Test';
        FA.LastName = 'FA';
        FA.AccountID = branch.id;
        FA.Type__c = 'FA';
        
        insert FA;
        
        Lending_Referrals__c Referral = new Lending_Referrals__c();
        Referral.recordtypeid = ReferralRecType;
        Referral.FA_Name__c = FA.Id;
        Referral.Client_Name__c = 'Test Client';
        Referral.Borrower_Name__c = 'Test Borrower';
        Referral.Loan_Amount__c = 1000000;
        Referral.Deal_Already_Channeled__c = 'No';
        Referral.Client_Phone_Number__c = '(123) 456-7890';
        Referral.Business_Lending_Consultant__c = '00550000000o9hB'; //patrick wrischnik
             
        test.StartTest();
        
        Task InquiryTask = new Task();
        InquiryTask.recordtypeid = TaskRecType;
        InquiryTask.subject = 'FA Inquiry Email';
        InquiryTask.WhoID = FA.id;
        InquiryTask.Status = 'Complete';
        InquiryTask.Description = 'Sent FA inquiry Email';
        
        //sends fa inquiry email
        insert InquiryTask;
        
        insert Referral;
            
        Task[] FirstPassTask = [SELECT OwnerID, WhoID, WhatID, Status FROM Task WHERE Subject LIKE 'First Pass %' AND
        WhoID =: FA.id];
        
        System.assertequals(FirstPassTask.size(),1);
        System.assertequals(FirstPassTask[0].OwnerID, Referral.Business_Lending_Consultant__c);
        System.assertequals(FirstPassTask[0].WhatID, Referral.ID);
        
        
        //Test Sending out task overdue email
        FirstPassTask[0].status = 'Overdue - Incomplete';
        
        update FirstPassTask;
        
        //complete first pass task, which will create another task
        FirstPassTask[0].description = 'Completed First Pass';
        FirstPassTask[0].status = 'Complete';
        
        update FirstPassTask;    

        //create referral 2
        Lending_Referrals__c Referral2 = new Lending_Referrals__c();
        Referral2.recordtypeid = ReferralRecType;
        Referral2.FA_Name__c = FA.Id;
        Referral2.Client_Name__c = 'Test Client 2';
        Referral2.Borrower_Name__c = 'Test Borrower 2';
        Referral2.Loan_Amount__c = 3000000;
        Referral2.Client_Phone_Number__c = '(123) 456-7890';
        Referral2.Deal_Already_Channeled__c = 'Yes';
        Referral2.Business_Lending_Consultant__c = '00550000000o9hB'; //patrick wrischnik
     
        //insert referral 2 
        insert Referral2;
        
        Task[] SecondPasstask = [SELECT OwnerID, Subject, WhatID, Status FROM Task WHERE Subject LIKE 'Second Pass %' AND
        WhoID =: FA.id];
        
        system.debug('Second Pass tasks --------- ' + SecondPasstask);
                
        System.assertequals(SecondPasstask.size(),2); //should be 2 second pass tasks, 1 for referral 1, and 1 for referral 2
        System.assertequals(SecondPasstask[1].OwnerID, Referral.Business_Lending_Consultant__c);
        //System.assertequals(SecondPasstask[1].WhatID, Referral2.ID);
        
        Referral2.wisdom__c = '123456';
        
        update Referral2;
        
        Task[] TaskWithWisdom = [SELECT Subject FROM Task WHERE Subject LIKE '% 123456' AND WhatID =:Referral2.id];
        
        system.assertequals(TaskWithWisdom.size(),1);
        
        SecondPasstask[0].description = 'Followed up with banker';
        SecondPassTask[0].status = 'Complete';
        
        update SecondPassTask[0];
               
        //mark referral 2 as dead;
        Referral2.Referral_Status__c = 'Referral Dead';
        
        update Referral2;
        
        Task[] DeadTask = [SELECT OwnerID, WhoID, WhatID, Status FROM Task WHERE Status = 'Complete - Referral Dead' AND
        WhoID =: FA.id];
        
        System.assertequals(DeadTask.size(),1);
        
        Referral2.Referral_Status__c = 'Gathering Financials'; //reopen a dead referral
        Referral2.Business_Lending_Consultant__c = '00550000002OKxJ'; // change blc from pat to shawn haider
        
        update Referral2;
        
        
        test.StopTest();
        
    }
    
}