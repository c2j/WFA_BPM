global class UserAccessCheck implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        List<User> usrList = new List<User>();
        List<UserAccessDays__c> uad = UserAccessDays__c.getall().values();
        List<Id> uIds = new List<Id>();
        Integer days = 30; // by default 30 days
        Integer resetDays = 30; // by default 30 days
        String ReplyToEmail = '';
        List<String> PNames = new List<String>();
        if(uad != null)
            PNames = uad[0].Profile_Name__c.split(';');
        List<Profile> PList = [Select id, name from Profile where Name IN: PNames];
        if(uad != null){
            days = Integer.ValueOf(uad[0].Total_Days_LastLogin__c);
            resetDays = Integer.ValueOf(uad[0].Password_Reset_Days__c);
            ReplyToEmail = uad[0].Reply_to_Email__c;
        }
        Date dt = System.today() - days;
        System.debug('Calculated date to collect users for reset: '+dt);
        DateTime lastReset = System.today() - resetDays;
        System.debug('Calculated reset date: '+dt);
        
        usrList =[Select id, Name, Email, LastLoginDate, LastPasswordChangeDate, isActive from User where isActive = true and ProfileId IN: PList and (LastLoginDate < : dt OR LastLoginDate = null) and (LastPasswordChangeDate < : lastReset OR LastPasswordChangeDate = null) order by LastLoginDate ASC limit 100]; 
        // 100 users password reset every day. Governance limit for DML execution 150 
        System.debug('Size of users = '+ usrList.size());
       for(User u : usrList){
       		 try{
            	System.resetPassword(u.id,true);
                uIds.add(u.id);
             }catch(Exception e){
            	System.debug('Exception occured during password reset: '+e.getMessage());
       		 }
        }
        if(uids.size()>0){
            EmailTemplate templateId = [Select id from EmailTemplate where name = 'Salesforce Access And QuickLinks'];
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.setTargetObjectIds(uids);
            mail.setTemplateId(templateId.id);
            mail.setSenderDisplayName('PCG Salesforce Team');
            mail.setReplyTo(ReplyToEmail);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
            System.debug('Email sent to users with login details');
        }
    }
    
}