trigger BLSG_ManagePassTasksOnReferral on Lending_Referrals__c (before insert, after insert, after update) {

    Map<Lending_Referrals__c, ID> BLSGReferralsToFAMap = new Map<Lending_Referrals__c, ID>();
    Set<ID> DeadReferralIds = new Set<ID>();
    Set<ID> ActiveReferralIds = new Set<ID>();
    Map<ID, String> ReferralToWisdom = new Map<ID, String>();
    
    Map<ID,Map<ID,ID>> ReferralToBLCsMAP = new Map<ID,Map<ID,ID>>(); //map blsg referral id to a map of old blc (business lending consultant) to new blc
    Task[] BLSGReminderTasks;
    String RefRecTypeID = '01250000000UNIi'; //BLSG Production Referral Record Type ID '01250000000UNIi'//Sandbox '012P0000000Cvrx';
    String TaskRecTypeID = '01250000000UMv5'; //Production BLSG Task Rec Type ID 01250000000UMv5; sandbox BLSG Task Rec Type ID 012P0000000Cvxv
    
    for (Lending_Referrals__c rf : Trigger.new) {
        
        //only proceed if referral record type is the BLSG one
        if (rf.recordtypeid == RefRecTypeID) { 
        
            if (trigger.isInsert) { //new blsg referral being created
                
                system.debug('BLSG Referral being created');
                
                BLSGReferralsToFAMap.put(rf,rf.FA_Name__c);
                
            } else if (trigger.isUpdate) { //blsg referral being updated
            
                system.debug('BLSG Referral being updated');
                
                Lending_Referrals__c oldRf = trigger.oldmap.get(rf.id);
                
                system.debug('Old referral status --------- ' + oldrf.referral_status__c);
                system.debug('New referral status --------- ' + rf.referral_status__c);
            
                if(oldRF.Referral_Status__c != 'Referral Dead' && rf.Referral_Status__c == 'Referral Dead') {
                    
                    DeadReferralIds.add(rf.ID);
                
                } else if (oldRF.Referral_Status__c == 'Referral Dead' && rf.Referral_Status__c != 'Referral Dead') {
                
                    ActiveReferralIds.add(rf.ID);
                    
                }
                
                //Business Lending Consultant has changed, so reassign all incomplete tasks
                system.debug('old blc ---------- ' + oldRF.Business_Lending_Consultant__c);
                system.debug('new blc ---------- ' + RF.Business_Lending_Consultant__c); 
                               
                if(oldRF.Business_Lending_Consultant__c != rf.Business_Lending_Consultant__c) {    
                    Map<ID,ID> OldBLCToNewBLC = new Map<ID, ID>();
                    OldBLCToNewBLC.put(oldRF.Business_Lending_Consultant__c, rf.Business_Lending_Consultant__c);
                    
                    ReferralToBLCsMap.put(rf.id,OldBLCToNewBLC);
                }
                
                //wisdom has updated, so update task subjects to include wisdom number
                if(rf.Wisdom__c != null && rf.Wisdom__c != oldrf.Wisdom__c) {
                    
                    ReferralToWisdom.put(rf.id, rf.Wisdom__c);
                    
                }
                    
            }
        }
 
    }
    
    //--------Create First or Second Pass Tasks on newly created BLSG Referral-----------//
    
    if (BLSGReferralsToFAMap.keyset().size() > 0) {
        
        System.debug('BLSGReferralsToFAMap ------------ ' + BLSGReferralsToFAMap);
        
        Map<ID, ID> FAtoBLC = new Map<ID, ID>();       
        Map<ID, ID> FAtoRBC = new Map<ID, ID>();
        Set<String> BLSGUsers = new Set<String>();
        if (trigger.isInsert && trigger.isBefore) {         
            for (Contact c: [SELECT Account.Business_Lending_Consultant__c, 
            Account.Regional_Banking_Consultant__c FROM Contact Where ID In: BLSGReferralsToFAMap.Values()]) {
                
                if (c.Account.Business_Lending_Consultant__c != null) {
                    BLSGUsers.add(c.Account.Business_Lending_Consultant__c);
                } 
                if (c.Account.Regional_Banking_Consultant__c != null) {
                    BLSGUsers.add(c.Account.Regional_Banking_Consultant__c);
                } 
            }
            
            for (Contact c: [SELECT Account.Business_Lending_Consultant__c, 
            Account.Regional_Banking_Consultant__c FROM Contact Where ID In: BLSGReferralsToFAMap.Values()]) {
                for (user u : [SELECT Name, ID FROM User WHERE Name IN: BLSGUsers]) {
                    
                    if (c.Account.Business_Lending_Consultant__c == u.Name) {
                        
                        FAtoBLC.put(c.id, u.id);
                        
                    } else if (c.Account.Regional_Banking_Consultant__c == u.Name) {
                    
                        FAtoRBC.put(c.id, u.id);
                        
                    } else if (FAtoBLC.get(c.id) != null && FAtoRBC.get(c.id) != null) {
                    
                        break;
                        
                    }
                }
            }
        }    
        List<Task> BLSGReferralPassTasks = new List<Task>(); //create list to store all the FirstPassTask for insert
        
        for (Lending_Referrals__c Referral : BLSGReferralsToFAMap.keyset()) {
            
            if (trigger.isBefore) {
                
                if (FAtoBLC!= null && FAtoBLC.get(Referral.FA_Name__c) != Null) {
                    Referral.Business_Lending_Consultant__c = FAtoBLC.get(Referral.FA_Name__c);
                } else {
                    Referral.Business_Lending_Consultant__c = '00550000000o9hB'; //blc defaults to pat wrischnik
                }
                
                system.debug('BLSG Referral FA to RBC ---------- ' + FAtoRBC);
                
                if (FAtoRBC!= null && FAtoRBC.get(Referral.FA_Name__c) != Null) {
                    Referral.Regional_Banking_Consultant__c = FAtoRBC.get(Referral.FA_Name__c);
                }
            }
            
            if (trigger.isInsert && trigger.isAfter) {
                        
                Task FPTask = new Task();
                Task SPTask = new Task();
                
                if (Referral.Business_Lending_Consultant__c != null) {
                    FPTask.OwnerID = Referral.Business_Lending_Consultant__c;
                    SPTask.OwnerID = Referral.Business_Lending_Consultant__c;
                } else {
                    FPTask.OwnerID = '00550000000o9hB'; //default to pat wrischnik
                    SPtask.OwnerID = '00550000000o9hB';
                }
                
                if (Referral.Deal_Already_Channeled__c == 'No') {
                    
                    system.debug('blsg referral NOT already channeled');
                    
                    FPTask.WhatID = Referral.id; //link to lending referral record
                    FPTask.WhoID = Referral.FA_Name__c; //link to contact record
                    FPTask.recordTypeID = TaskRecTypeID; 
                    FPTask.subject = 'First Pass - ' + Referral.Borrower_Name__c + ' - ' + Referral.Loan_Amount__c;
                    FPTask.Type = 'Call';
                    FPTask.Status = 'Incomplete';
                    FPTask.ActivityDate = UtilityMethods.TaskDueDate(system.today().adddays(10), 'Monday');
                    FPTask.Task_Due_Date__c = FPTask.ActivityDate;
                    FPTask.Description = '1. Banker Assigned to Referral \n2. Banker Acceptance of Referral in Planetwholesale \n3. Confirm Banker contacted FA';
                    
                    BLSGReferralPassTasks.add(FPTask);
    
                } else {
                    
                    system.debug('blsg referral already channeled');
                    
                    SPTask.WhatID = Referral.id; //link to lending referral record
                    SPTask.WhoID = Referral.FA_Name__c; //link to contact record
                    SPTask.recordTypeID = TaskRecTypeID;
                    SPTask.subject = 'Second Pass - ' + Referral.Borrower_Name__c + ' - ' + Referral.Loan_Amount__c;
                    SPTask.Type = 'Call';
                    SPTask.Status = 'Incomplete';
                    SPTask.ActivityDate = UtilityMethods.TaskDueDate(system.today().adddays(30), 'Monday');
                    SPTask.Task_Due_Date__c = SPTask.ActivityDate;
                    SPTask.Description = 'Connect with Banker for an updated status on referral and ensure banker has updated the FA';
                
                    BLSGReferralPassTasks.add(SPTask);
                }
    
                try {
                    
                    system.debug('Referral Pass Tasks -------------- ' + BLSGReferralPassTasks);
                    
                    insert BLSGReferralPassTasks;
                    
                } catch (exception e) {
                    for (Lending_Referrals__c rf : trigger.new) {
                        rf.adderror('Error occurred while creating BLSG reminder tasks on Lending Referral. Contact your administrator.');
                        system.debug('Error occurred while creating BLSG reminder tasks on Lending Referral ------------ ' + e.getMessage());
                    }
                }
            }
         }
    }
    
    
    //--------Close or re-open pass tasks based on the referral status being changed to and from Referral Dead-----------//
    system.debug('Referral to BLCs Map ---------- ' + ReferralToBLCsMap);
    
    if (DeadReferralIds.size() > 0 || ActiveReferralIds.size() > 0 || ReferralToBLCsMap.keyset().size() > 0) {
    
        BLSGReminderTasks = [SELECT Status, Subject, WhatID, OwnerID, Description FROM Task WHERE (WhatID IN: DeadReferralIds OR WhatID IN: 
        ActiveReferralIds OR WhatID IN: ReferralToBLCsMap.keyset()) AND 
        (Subject LIKE 'First Pass%' OR Subject LIKE 'Second Pass%' OR Subject LIKE 'Follow Up%')
                            AND (Status != 'Complete' OR Status = 'Complete - Referral Dead')];
                                    
    }                            
             
    if (BLSGReminderTasks != Null && BLSGReminderTasks.size() > 0) {   
    
        system.debug('BLSG Reminder Tasks ------- ' + BLSGReminderTasks.size() + ' / ' + BLSGReminderTasks);
        
        for (Task t : BLSGReminderTasks) {
            
            if (trigger.oldmap.get(t.WhatId).Referral_Status__c != 'Referral Dead' && trigger.newmap.get(t.whatID).Referral_Status__c == 'Referral Dead') {
                t.Status = 'Complete - Referral Dead';
            } else if (trigger.oldmap.get(t.WhatId).Referral_Status__c == 'Referral Dead' && trigger.newmap.get(t.whatID).Referral_Status__c != 'Referral Dead') {
                t.Status = 'Incomplete';
                
                if (string.valueof(t.Subject).contains('First Pass')) {
                    t.ActivityDate = UtilityMethods.TaskDueDate(system.today().adddays(10), 'Monday');
                } else if (string.valueof(t.Subject).contains('Second Pass') || string.valueof(t.Subject).contains('Follow Up')) {
                    t.ActivityDate = UtilityMethods.TaskDueDate(system.today().adddays(30), 'Monday');
                }
                
                t.Task_Due_Date__c = t.ActivityDate;
            }
            
            //switching the owners of the incomplete blsg reminder tasks
            if (trigger.oldmap.get(t.WhatId).Business_Lending_Consultant__c != trigger.newmap.get(t.WhatId).Business_Lending_Consultant__c) {
                
                //system.debug('Old blc to new blc map ------------ ' + ReferralToBLCsMap.get(t.WhatID));
                //system.debug('task owner ------------ ' + t.ownerid);
                if (ReferralToBLCsMap.get(t.WhatID) != null && ReferralToBLCsMap.get(t.WhatID).get(t.OwnerID) != null) {
                    t.OwnerID = ReferralToBLCsMap.get(t.WhatID).get(t.OwnerID);
                    system.debug('New blsg Task owner ----------- ' + t.OwnerID);
                }
            }
            
        }
        
        try {
            update BLSGReminderTasks;
        } catch (exception e) {
            throw new SFException('Error occurred when updating BLSG Referral Reminder Task Statuses. Contact your system administrator');
            
            system.debug('Error occurred when updating BLSG Referral Reminder Task Statuses ------------ ' + e.getMessage());
            
        }
    
    }
    
    //there are referrals that have an updated wisdom #
    if (ReferralToWisdom.keyset().size() > 0) {
        
        system.debug('blsg referral wisdom number updated');
        
        Task[] tasks = [SELECT Subject, WhatID FROM Task WHERE WhatID IN: ReferralToWisdom.keyset()];
        
        if (tasks.size() > 0) {
        
            for (task t: tasks) {
                
                if (string.valueof(t.subject).contains('-') && string.valueof(t.subject).indexof('-',14) != -1) {
                    
                    system.debug('custom subject detected');
                    
                    integer secondDash = string.valueof(t.subject).indexof('-',14);
                    t.Subject = string.valueof(t.subject).substring(0,secondDash) + ' - W# ' + ReferralToWisdom.get(t.WhatID);
                
                } else if (!string.valueof(t.subject).contains('-')) { //if blsg task subject is not custom (first pass, second pass) but a standard one like "Referral", just append wisdom number after subject
                
                    t.Subject = string.valueof(t.subject) + ' - W# ' + ReferralToWisdom.get(t.WhatID);
                
                }
            }
        
            try {
            
                system.debug('blsg task subjects updating with wisdom numbers ---------- ' + tasks.size() + ' / ' + tasks);
            
                update tasks;
            } catch (exception e) {

                system.debug('Error occurred while updating BLSG Task subjects with wisdom number ----------- ' + e.getMessage());
                
                throw new SFException('Error occurred while updating BLSG Task subjects with wisdom number. Contact your administrator.');
            }
            
        }
    }       
               
        

}