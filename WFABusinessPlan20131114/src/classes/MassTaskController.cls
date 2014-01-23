public with sharing class MassTaskController {
    //Capture the values for the standard Task
    public Task task{set;get;}
        
    //Capture the value for the reminder date/time
    public Contact contact{set;get;}
    public String reminderTime{set;get;}
    
    //Other Form fields
    public Boolean sendNotificationEmailCheckBox{set;get;}
    public Map <Id,String> displayNames{set;get;}
    private Map <Id,Id> ownerIds;
    public Boolean showWhoId{set;get;}
    public Boolean showPage{set;get;}
    public String recordTypeID = null;
    public String usersID = null;    
    public String usersProfile = null;
    public Boolean showInternal{set;get;}
    public Boolean showProdConsultant{set;get;}  
    public Boolean showRBC{set;get;}
    public List<AggregateResult> acctAR = new list<AggregateResult>();
    public Boolean assignToOwner{set;get;}
    
    //Page processing parameters
    private List <Selectoption> selReminderOptions;
    public String [] arrObjIds;
    private String objName = null;
    private Boolean saveStatus;
    private String objPrefix = null;
    

    public MassTaskController(){
        showPage = false;        
        usersID = userinfo.getUserId();
        usersProfile = userinfo.getProfileId();
        showInternal = false;
        showProdConsultant = false;
        showRBC = false;
        
        //set task record type based on users profile
        if(usersProfile == '00e50000000vBn0AAE' || usersProfile == '00e50000000z43RAAQ'){ //internal sales rep profile
            recordTypeID = '012300000000V1JAAU'; //internal record type
            showInternal = true;
        } else if(usersProfile == '00e50000000vBn5AAE' || usersProfile =='00e50000000z43WAAQ'){ //productivity consultant sales rep profile
            recordTypeID = '012500000005CeBAAU'; //productivity consultant record type
            showProdConsultant = true;
        } else if(usersProfile == '00e50000000v97gAAA' || usersProfile == '00e50000000yquBAAQ'){ //regional banking consultants or regional manager - banking profile
            recordTypeID = '012500000005BNKAA2'; //rbc record type
            showRBC = true;
        } else {
            recordTypeID = '012300000000V1JAAU'; //all other users reference internal record type
            showInternal = true;
        } //end of record type if        
        
        task = new Task(recordtypeid = recordTypeID, ownerID = usersID, status = 'Complete', priority = 'Normal');
        contact = new Contact();
        displayNames = new Map<Id,String>();
        ownerIds = new Map<Id,Id>();
        showWhoId = false;
        sendNotificationEmailCheckBox = false;
        saveStatus = false;
        assignToOwner = false;
        
        try{
            //Get the object ids passed as parameter
            Map<String, String> params = ApexPages.currentPage().getParameters();
            String strObjIds = params.get('objIds');
            arrObjIds = strObjIds.split(',');  
                        
            //Identify the object name/type and get the names
            if(arrObjIds != null && !arrObjIds.isEmpty()){
                //Find the object name
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Set<String> keyPrefixSet = gd.keySet();
                String tPrefix = arrObjIds[0].subString(0,3);               
                Set<String> contIds = new Set<String>(arrObjIds);   
                //System.debug('+++++++++++++CONTACT IDS: ' + contIds);
                
                acctAR = [select AccountId, Account.Name AcctName  //obtain list of accounts related to selected fa's
                          from Contact where Id in :contIds
                          group by AccountId, Account.Name];                                    
                
                for(String sObj : keyPrefixSet){
                    Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
                    if(tPrefix.equals(r.getKeyPrefix())){
                        objName = r.getName();
                        objPrefix = tPrefix;
                        break;
                    }
                }
                
                //Query the name for all the objects
                if(objName != null){
                    String strFieldName = 'name';                    
                    String strQuery = 'select id,OwnerId,' + strFieldName + ' from ' + objName + ' ';
                    Boolean bFirst = true;
                    for(String strObjId:arrObjIds){
                        if(bFirst){
                            strQuery += ' where Id in (\'';
                            bFirst = false;
                        }else{
                            strQuery += ',\'';
                        }
                        strQuery += String.escapeSingleQuotes(strObjId) + '\'';
                    }
                    strQuery += ')';
                    
                    try{
                        SObject [] sfdcObjects = Database.query(strQuery);
                        
                        //Generate the name list to populate selected fa's
                        for(SObject sfdcObject:sfdcObjects){
                            displayNames.put((Id)sfdcObject.get('id'),(String)sfdcObject.get(strFieldName));
                            ownerIds.put((Id)sfdcObject.get('id'), (Id)sfdcObject.get('OwnerId'));
                        }
                    }catch(Exception e){
                        strQuery = strQuery.replace(',' + strFieldName, ' ');
                        SObject [] sfdcObjects = Database.query(strQuery);
                        
                        //Generate the Id list instead of name list
                        for(SObject sfdcObject:sfdcObjects){
                            displayNames.put((Id)sfdcObject.get('id'),(Id)sfdcObject.get('id'));
                        }
                    }
                }
            }
            
            showPage = true;

        }catch(Exception e){
            //Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, e.getMessage()));
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Unexpected error has occured. Please try again later.'));
            showPage = false;
        }
        
    }

    public void saveNew(){      
        //Create the new task list
        List <Task> aTask = new LIst<Task>();
        List <Task> lTask = new List<Task>();
        
        //Capture the status for save()
        saveStatus = false;
        
        //create account tasks if accounts are selected
        if(branches.size() > 0){
            try{                
                for(string b:branches){
                    //System.debug('+++++++++++++ACCT IDS: ' + b);
                    Task taskNew = new Task();                  
                
                    taskNew.WhatID = b;
                    taskNew.OwnerId = task.OwnerId;                 
                    taskNew.status = task.status;
                    taskNew.subject = task.subject;                 
                    taskNew.activityDate = task.activityDate;
                    taskNew.priority = task.priority;
                    taskNew.description = task.description;
                    taskNew.type = task.type;
                    
                    //custom fields
                    taskNew.X4front__c = task.X4front__c;
                    taskNew.Category__c = task.Category__c;
                    taskNew.Communication_Type__c = task.Communication_Type__c;
                    taskNew.Discussion_Details__c = task.Discussion_Details__c;
                    taskNew.End_Result__c = task.End_Result__c;
                    taskNew.Envision_Help__c = task.Envision_Help__c;
                    taskNew.Envision_Time__c = task.Envision_Time__c;
                    taskNew.IBDC__c = task.IBDC__c;
                    taskNew.PA_Qualification_Interested__c = task.PA_Qualification_Interested__c;
                    taskNew.Product_Name__c = task.Product_Name__c;
                    taskNew.Product_Type__c = task.Product_Type__c;
                    taskNew.Sales_Strategy_Initiative__c = task.Sales_Strategy_Initiative__c;
                    taskNew.Why_Not_More_Envision__c = task.Why_Not_More_Envision__c;    
                    
                    //If the reminder is set
                    if(task.IsReminderSet){
                        taskNew.IsReminderSet = true;
                        String [] arrReminderTimes = reminderTime.split(':');
                        Time tmpTime = Time.newInstance(Integer.valueOf(arrReminderTimes[0]), Integer.valueOf(arrReminderTimes[1]), 0, 0);
                        Datetime reminderDateTime = Datetime.newInstance(contact.Birthdate, tmpTime);
                        taskNew.ReminderDateTime = reminderDateTime;
                    }
                    aTask.add(taskNew);
                } 
                insert aTask;
            }catch(Exception e){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, e.getMessage()));
                return;
            }// end of try      
        }// end of branch if check

        
        //create contact tasks
        try{
            for(String strObjId:arrObjIds){
                Task taskNew = new Task();
                
                System.debug('+++++++++++++CONTACT SUBJECT: ' + task.subject);
                
                taskNew.WhoId = strObjId;
                taskNew.OwnerId = task.OwnerId;                
                taskNew.status = task.status;
                taskNew.subject = task.subject;
                taskNew.activityDate = task.activityDate;
                taskNew.priority = task.priority;
                taskNew.description = task.description;
                taskNew.type = task.type;
                
                //custom fields
                taskNew.X4front__c = task.X4front__c;
                taskNew.Category__c = task.Category__c;
                taskNew.Communication_Type__c = task.Communication_Type__c;
                taskNew.Discussion_Details__c = task.Discussion_Details__c;
                taskNew.End_Result__c = task.End_Result__c;
                taskNew.Envision_Help__c = task.Envision_Help__c;
                taskNew.Envision_Time__c = task.Envision_Time__c;
                taskNew.IBDC__c = task.IBDC__c;
                taskNew.PA_Qualification_Interested__c = task.PA_Qualification_Interested__c;
                taskNew.Product_Name__c = task.Product_Name__c;
                taskNew.Product_Type__c = task.Product_Type__c;
                taskNew.Sales_Strategy_Initiative__c = task.Sales_Strategy_Initiative__c;
                taskNew.Why_Not_More_Envision__c = task.Why_Not_More_Envision__c;                
                
                //If the reminder is set
                if(task.IsReminderSet){
                    taskNew.IsReminderSet = true;
                    String [] arrReminderTimes = reminderTime.split(':');
                    Time tmpTime = Time.newInstance(Integer.valueOf(arrReminderTimes[0]), Integer.valueOf(arrReminderTimes[1]), 0, 0);
                    Datetime reminderDateTime = Datetime.newInstance(contact.Birthdate, tmpTime);
                    taskNew.ReminderDateTime = reminderDateTime;
                }
                lTask.add(taskNew);
            }
            //Insert the new tasks
            insert lTask;
        }catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return;
        }
        
        saveStatus = true;
        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.CONFIRM, 'Task(s) successfully created.'));
       
        //Send email
        if(sendNotificationEmailCheckBox){
            sendMail(lTask);
        }
    }

    public Pagereference save(){
        saveNew();
        if(saveStatus){
            return back();
        }
        return null;
    }   
    /**
    * Send email to the assigned engineer
    */
    private void sendMail(List <Task> lTask){
        try{
            //Set mail parameters
            //Query the assigned user
            User assignedUser = [Select u.Name, u.Email From User u where u.Id =: task.OwnerId];
            //Prepare the mail message
            Messaging.Singleemailmessage singleMail = new Messaging.Singleemailmessage();
            singleMail.setToAddresses(new String[]{ assignedUser.Email });
            singleMail.setSubject(task.subject);
            //Generate the HTML body and the plain text body
            String strText = 'To: ' + assignedUser.Name + '<br/><br/>';
            strText += System.Userinfo.getName() + ' has assigned you the following task(s):<br/><br/>';
            strText += 'Subject: ' + task.subject + '<br/><br/>';
            strText += objName + ':<br/>';
            
            String strPlainText = 'To: ' + assignedUser.Name + '/n/n';
            strPlainText += System.Userinfo.getName() + ' has assigned you the following task(s):/n/n';
            strPlainText += 'Subject: ' + task.subject + '/n/n';
            strPlainText += objName + ':/n';
            
            //Put the tasks with objects ids
            Map <Id,Id> mObjectTask = new Map<Id,Id>();
            for(Task newTasks:lTask){
                if(showWhoId){
                    mObjectTask.put(newTasks.WhatId, newTasks.Id);
                }else{
                    mObjectTask.put(newTasks.WhoId, newTasks.Id);
                }
            }
            for(Id displayKey:displayNames.keySet()){
                String displayName = displayNames.get(displayKey);
                Id taskId = mObjectTask.get(displayKey);
                strText += '-' + displayName;
                strText += ' (<a href=\'http://na1.salesforce.com/' + taskId  + '\'>';
                strText += 'http://na1.salesforce.com/' + taskId  + '</a>)';
                strText += '<br/>';
                
                strPlainText += '-' + displayName;
                strPlainText += ' (http://na1.salesforce.com/' + taskId  + ')';
                strPlainText += '/n';
            }
            strText += '<br/>Priority: ' + task.Priority + '<br/><br/>';
            
            strPlainText += '/nPriority: ' + task.Priority + '/n/n';
            
            //Set the test message to the mail
            singleMail.setHtmlBody(strText);
            singleMail.setPlainTextBody(strPlainText);
            //Send the mail
            Messaging.sendEmail(new Messaging.Singleemailmessage [] { singleMail });
        }catch(Exception e){
            //Capture if unexpected error occurs - such as Salesforce mail limit
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Task(s) added. Mail not sent.'));
        }   
    }
    
    /**
    * Insert in the ReminderDate List the Time : Hours:Min
    */ 
    public List<SelectOption> getselReminderOptions(){
        selReminderOptions = new List<SelectOption>();
        String val = '' ; 
        for (Integer i = 0 ; i < 24 ; i++){
            // Draw the options to add to the reminder picklist 
            val = i+':'+'00';           
            selReminderOptions.add(new SelectOption(val,val));
            val = i+':'+'30';
            selReminderOptions.add(new SelectOption(val,val));
        }
        return selReminderOptions;    
    } 
    /**
    * Go to the previous page
    */
    public Pagereference back(){
        Pagereference pageRef = new Pagereference('/' + objPrefix);
        pageRef.setRedirect(true);
        return pageRef;
    }
    /**
    * Display the selected object names in front end
    */
    public List <String> getTableDisplayNames(){
        List <String> rtnList = new List<String>();
        
        for(String displayName:displayNames.values()){
            rtnList.add('-' + displayName);
        }
        return rtnList;
    }         
    
    /**
    * FA branch selection
    */
    String[] branches = new String[]{}; 
    
    public String[] getBranch() {
        return branches;
    }

    public void setBranch(String[] branches) {
        this.branches = branches;
    }
    
    public List<SelectOption> getBranches() {
        List<SelectOption> optionList = new List<SelectOption>();

        for(AggregateResult ar:acctAR){
            optionList.add(new SelectOption((String)ar.get('AccountID'), (String)ar.get('AcctName'))); 
        }
  
        return optionList;     
    }

}// end of class