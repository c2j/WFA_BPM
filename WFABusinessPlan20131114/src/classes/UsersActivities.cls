public with sharing class UsersActivities {

    public ID UserID{get;set;}
    public ID RecordID{get;set;}
    public List<Task> UsersActivities{get;set;}
    public boolean HasActivities{get;set;}
    public integer PageSize {get;set;}
    public boolean AllowShowMore{get;set;}
    public Date StartDate {get;set;}
    public Date EndDate {get;set;}
    public String Keywords {get;set;}
    public Task t;
    public Case c;
    
    public UsersActivities(ApexPages.StandardController controller) {

        UserID = UserInfo.getUserID();
        
        RecordID = controller.getRecord().ID;
        
        system.debug('User\'s id ------------ ' + UserID);
        system.debug('Contact id ------------ ' + RecordID);
        
        
        getProxyTask(); //create proxyTask to store start date in the task activity date field
        
        getProxyCase(); //create proxy case to store end date in the case created date field
        
        SetDates(); //set the activity date ranges if there are no dates inputed
        
        getUsersActivities(); //query the current user's activities on the contact
        
        system.debug('User\'s activities --------------- ' + UsersActivities);
        
        PageSize = Math.min(5, UsersActivities.size()); //limit the table to show 10 activities at a time       
        
        
        SetAllowShowMore();
        
        if (UsersActivities.size() > 0) {
            HasActivities = True;
        }
        
         
    }
    
    public void SetAllowShowMore() {
        
        system.debug('Page Size ------------ ' + PageSize);
        system.debug('users activities size ------------ ' + UsersActivities.Size());
        
        if (UsersActivities.size() < 5 || PageSize >= UsersActivities.size()) {
            AllowShowMore = False;
        } else {
            AllowShowMore = True;
        }
    }
    
       
    public void SetDates() {
    
        if (StartDate == null) { StartDate = date.newinstance(1900,1,1); }
    
        if (EndDate == null) { EndDate = date.today(); }
    
    }
    
    public void showMore() {
        PageSize += 5;
        
        SetAllowShowMore();
    }
        
    
    public Task getProxyTask() {
    
        t = new Task();
        return t; 
        
    }
    
    
    public Case getProxyCase() {
    
        c = new case();
        return c; 
        
    }
    public PageReference ResetFilters() {
        
        PageReference noFilters = new PageReference(system.currentPageReference().getURL());
        noFilters.getParameters().clear();
        noFilters.setRedirect(true);
        noFilters.getParameters().put('id',RecordID);
        return noFilters;
        
    
    }
    
    public void ApplyFilters() {
    
        StartDate = t.ActivityDate;
        EndDate = c.Case_Created_Date__c;
        Keywords = t.CallDisposition;
        
        system.debug('start date ------- ' + startdate);
        system.debug('end date -------- ' + enddate);
        system.debug('keywords -------- ' + keywords);
        
        
        if (Keywords == null) { 
            
            getUsersActivities();
            
        } else {
            Keywords = '*' + Keywords + '*';
            
            //system.debug('keywords -------- ' + keywords);
            
            List<List<SObject>> searchList;
            
            if (string.valueof(RecordID).left(3) == '003' || string.valueof(RecordID).left(3) == '00Q') {
                searchList= [FIND :Keywords IN ALL FIELDS RETURNING Task (id, WhoID, WhatID, ActivityDate, Subject, Category__c, description WHERE WhoID =: RecordID AND OwnerID =: UserID AND ActivityDate >=: StartDate AND ActivityDate <=: EndDate Order By ActivityDate Desc)];
            } else {
                searchList= [FIND :Keywords IN ALL FIELDS RETURNING Task (id, WhoID, WhatID, ActivityDate, Subject, Category__c, description WHERE WhatID =: RecordID AND OwnerID =: UserID AND ActivityDate >=: StartDate AND ActivityDate <=: EndDate Order By ActivityDate Desc)];
            }
            
            UsersActivities = (searchList[0]);
        }
        
        system.debug('User Activities ---------- ' + UsersActivities);
    
    }
    

    public void getUsersActivities() {
        
        system.debug('start date ------- ' + startdate);
        system.debug('end date -------- ' + enddate);
    
        if (string.valueof(RecordID).left(3) == '003' || string.valueof(RecordID).left(3) == '00Q') {
            UsersActivities = [SELECT ID, WhoID, WhatID, Category__c, Subject, Task_Due_Date__c, ActivityDate, Description FROM Task WHERE OwnerID =: UserID AND WhoID =: RecordID AND ActivityDate >=: StartDate AND ActivityDate <=: EndDate Order By ActivityDate DESC];
        } else {
            UsersActivities = [SELECT ID, WhoID, WhatID, Category__c, Subject, Task_Due_Date__c, ActivityDate, Description FROM Task WHERE OwnerID =: UserID AND WhatID =: RecordID AND ActivityDate >=: StartDate AND ActivityDate <=: EndDate Order By ActivityDate DESC];
        }
    }
    
    
    

}