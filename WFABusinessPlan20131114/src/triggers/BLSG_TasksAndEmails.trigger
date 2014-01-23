trigger BLSG_TasksAndEmails on Task (before update) {

//this trigger will create follow up second pass tasks, email overdue task alerts, and initial inquiry emails
    
list<Task> ReminderTasks = new List<Task>();
Map<Task, ID> TaskToOwner = new Map<Task, ID>();
Set<ID> ReferralIds = new Set<ID>();
Set<ID> FAIds = new Set<ID>();
String TaskRecTypeID = '01250000000UMv5'; //Production BLSG Task Rec Type ID 01250000000UMv5; sandbox BLSG Task Rec Type ID 012P0000000Cvxv
string PCGEmailTempID = '00X50000001VSyw'; //PCG (production id 00X50000001VSyw; sandbox id 00XP0000000I9s4)
string FiNetEmailTempID = '00X50000001VSyt'; //FiNet (production id 00X50000001VSyt; sandbox id 00XP0000000I9tq)

//system.debug('BLSG Recurring Reminder Tasks Trigger fired? ------ ' + Validator_cls.hasAlreadyDone());

//if (!Validator_cls.hasAlreadyDone()) {//prevents workflows from firing trigger twice

    For (task t: trigger.new) {
        
        Task oldT = trigger.oldmap.get(t.id);

        if (t.RecordTypeID == TaskRecTypeID) {
            
            //validate task due date
            ApexBasedValidation.TaskValidation(t, oldt);
            
            //update task due date with new activity date
            if (oldt.ActivityDate != t.ActivityDate) {
                
                t.Task_Due_Date__c = t.ActivityDate;
                
            }
            
            if (oldT.Status != 'Complete' && t.status == 'Complete' && 
                (string.valueof(t.Subject).contains('First Pass') || string.valueof(t.Subject).contains('Second Pass') ||
                string.valueof(t.Subject).contains('Follow Up'))) {
                
                
                //populate resolved date on task being marked complete
                t.Resolved_Date__c = System.today(); 
                
                String NewSubject;
                
                system.debug('Old BLSG Task subject ------- ' + t.subject);
                
                if (string.valueof(t.Subject).contains('Second Pass')) {
                    NewSubject = string.valueof(t.Subject).replace('Second Pass','Follow Up');
                } else if (string.valueof(t.Subject).contains('First Pass')) {
                    NewSubject = string.valueof(t.Subject).replace('First Pass','Second Pass');
                } else {
                    NewSubject = t.subject;
                }
                
                system.debug('New BLSG Task subject ------- ' + NewSubject);
                
                Task SPTask = new task();
                SPTask.OwnerID = t.OwnerID;
                SPTask.WhatID = t.WhatID;
                SPTask.WhoID = t.WhoID;
                SPTask.recordTypeID = TaskRecTypeID;
                SPTask.subject = NewSubject;
                SPTask.Type = t.Type;
                SPTask.Product_Type__c = t.Product_Type__c;
                SPTask.Product_Name__c = t.Product_Name__c;
                SPTask.Other__c = t.Other__c;
                SPTask.Status = 'Incomplete';
                SPTask.ActivityDate = UtilityMethods.TaskDueDate(system.today().adddays(30), 'Monday');
                SPTask.Task_Due_Date__c = SPTask.ActivityDate;
                SPTask.Description = 'Continue connecting with Banker for an updated status on referral and ensure banker has updated the FA';
                
                ReminderTasks.add(SPTask);
                
            }
            
            //if the task is overdue - incomplete, or the subject is FA Inquiry Email
            //map task to owner id, to use in emails alerts to task owner and john durninen, or FA            
            if ((oldt.status != 'Overdue - Incomplete' && t.status == 'Overdue - Incomplete') || (t.subject == 'FA Inquiry Email' &&
            t.Status == 'Complete')) {

                TaskToOwner.put(t,t.OwnerId);
                ReferralIDs.add(t.WhatID);
                FAIds.add(t.whoID);
                
            }
            

   
        }   
        
    }
    
    //****create recurring second pass task until the status is marked Complete Series
    
    if (ReminderTasks.size() > 0) {
        
        system.debug('BLSG Recurring First or Second Pass Tasks to insert --------- ' + ReminderTasks.size() + ' / ' + ReminderTasks);
        
        try {
            
            system.debug('Recurring BLSG Reminder Tasks -------- ' + ReminderTasks);
             
            insert ReminderTasks;

        } catch (exception e) {
            throw new SFException('Error occurred while inserting BLSG Second Pass Follow Up Tasks. Contact your administrator.');
            
            //trigger.adderror('Error occurred while inserting BLSG Second Pass Follow Up Tasks. Contact your administrator.');
            system.debug('Error occurred while inserting BLSG Second Pass Follow Up Tasks ---------- ' + e.getMessage());
            
        } 
        //Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again   
    }
    
    
    //******Need to email over due task alerts
    
    if (TaskToOwner.keyset().size() > 0) {
        
        system.debug('Over due BLSG Reminder Tasks & Owners ----------- ' + TaskToOwner.keyset().size() + ' / ' + TaskToOwner);
        //email overdue task alerts to task owner and john durnien
        
        Map<Id, User> BLSGUsersMap = new Map<Id, User>([SELECT Email, Name FROM User WHERE ID IN: TaskToOwner.values() AND IsActive = True]);
        Map<Id, Lending_Referrals__c> ReferralsMap = new Map<ID, Lending_Referrals__c>([SELECT FA_Name__r.Name, FA_Name__r.Channel__c, 
        Borrower_Name__c, Wisdom__c FROM
        Lending_Referrals__c WHERE ID IN: ReferralIds]);
        Map<ID, Contact> FAMap = new Map<ID, Contact>([SELECT FirstName, LastName, Channel__c FROM Contact WHERE ID IN: FAIds]);
        EmailTemplate FAInquiryTemplate;

        
        For (task t : TaskToOwner.keyset()) {
            
            //send inquiry email to FA
            
            if (t.subject == 'FA Inquiry Email') {
                
                if (FAMap.get(t.WhoID).Channel__c == 'PCG') {
                    FAInquiryTemplate = [Select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: PCGEmailTempID]; 
                } else if (FAMap.get(t.WhoID).Channel__c == 'FiNet') {
                    FAInquiryTemplate = [Select Id, Subject, HtmlValue, Body from EmailTemplate where Id =: FiNetEmailTempID];
                }    
                
                if (FAInquiryTemplate != Null) {
                    Contact c = FAMap.get(t.WhoID);
                    
                    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        
                    email.setReplyTo(BLSGUsersMap.get(t.OwnerID).Email);
                    email.setSenderDisplayName(BLSGUsersMap.get(t.OwnerID).name);
                    email.setTargetObjectId(c.id);
                    email.setTemplateID(FAInquiryTemplate.id);
                    email.setSaveAsActivity(false); //do not log email as activity
                
                    Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});              
                }
            
            }
            
            //send overdue task alert to John Durnien and Task Owner
            if (trigger.oldmap.get(t.id).status != 'Overdue - Incomplete' && t.status == 'Overdue - Incomplete') {
            
                String Subject = 'OVERDUE TASK: Referral From ' + ReferralsMap.get(t.WhatID).FA_Name__r.Name + ' For ' + ReferralsMap.get(t.WhatID).Borrower_Name__c;
                String Body = 'Task Due Date: ' + t.activityDate + '\n\n' + 'Subject: ' + t.Subject + '\n\n' + 'Wisdom #: ' + ReferralsMap.get(t.WhatID).Wisdom__c;
                String[] ToAddress = new String[]{'john.durnien@wellsfargoadvisors.com', BLSGUsersMap.get(t.OwnerID).Email};
                                
                UtilityMethods.email(Subject, Body, ToAddress);
            
            }
            
        }
       // Validator_cls.setAlreadyDone(); //prevents workflow update from setting this trigger off again   

    }

//}
}