public with sharing class vfFAProfilesCtrlr {
    
    //a1XW0000000PrOQ test FA's profile record id
    
    public ID ProfileRecID {get;set;}
    //public boolean ProfileRetrieved {get;set;}
    public boolean ProfileSaved {get;set;}
    public ID FAId;
    public String ANumber {get;set;}
    //public String EnteredANumber {get;set;}
    public String Channel {get;set;}
    public Hobbies_Charities__c ProfileRecord {get;set;}
    //public Boolean IsVeteran {get;set;}
    public List<Child__c> Children {get;set;}
    public List<Child__c> NewChildren {get {if (NewChildren == NULL) {NewChildren = new List<Child__c>(); } return NewChildren; } set;}
    public Integer NumOfNewChildren {get {if (NumOfNewChildren == NULL) {NumOfNewChildren = 3; } return NumOfNewChildren; } set;}
    //public Integer TotalChildren {get;set;}
    public String SelectedChildID{get;set;}
    public transient String AddOrRemove{get;set;}
    
    
    
    public vfFAProfilesCtrlr(ApexPages.StandardController controller) {
        
        ProfileRecID = Controller.getRecord().ID;
        
        ProfileRecord = [SELECT Name, Name__c, Status__c, First_Name__c, Last_Name__c, Preferred_Formal_Name__c, CFP__c, Familiar_Name__c, Professional_Designations__c, Hometown_City__c, Hometown_State__c,
        Veteran__c, Branch_Of_Service__c, College_s_Attended__c, College_Major_s__c, Spouse_Partner_Birthdate__c, Spouse_Partner_First_Name__c, Spouse_Partner_Last_Name__c, 
        Wedding_Anniversary__c, Assistant_Full_Name__c, Assistant_Email__c, Assistant_Phone__c, Team_Member_1__c, Team_Member_2__c,Team_Member_3__c,Team_Member_4__c,Team_Member_5__c,
        Team_Member_6__c, Financial_Consultant_s_name__c, Rank_1__c, Rank_2__c, Rank_3__c,Rank_4__c, Other_Interest_1__c, Other_Interest_2__c, Other_Interest_3__c, 
        Additional_Interests_Details__c, Charities_Community_Service_Grps_Prgms__c, Clubs_Boards_or_Associations__c, Future_Charities_Clubs_Boards_Assoc__c, What_Drives_Success__c,
        Additional_Information__c, Additional_Comments_from_Manager__c, Advisor_Profile_Completed__c, No_Changes_Made__c, Date_Time_Profile_Completed__c FROM Hobbies_Charities__c
        WHERE ID =: ProfileRecID];
        
        system.debug('Profile Record ------------- ' + ProfileRecord);
        
        Contact FA = [SELECT ID, A_Number__c, Channel__c FROM Contact WHERE ID =: ProfileRecord.Name__c];
        
        FAId = FA.ID;
        
        system.debug('FA id ----------- ' + FAId);
        ANumber = FA.A_Number__c;
        Channel = FA.Channel__c;
        
        getChildren();
        
        StoreNewChildren();

    }

    public void getChildren() {
    
        Children = [SELECT ID, Name, Child_Last_Name__c, Child_Address_1__c, Child_Address_2__c, Child_Birthdate__c, Child_City__c, Child_State__c, Child_Zip__c, 
        Child_School_College__c, Gender__c, Relationship_Type__c FROM Child__c WHERE Parent__c =: FAId ORDER BY Child_Age__c DESC];
        
    }
    

    public void SetNumOfNewChildren() {
        
        If (AddOrRemove == Null) {
            return;
        } else if (AddOrRemove == 'Add') {
            NumOfNewChildren = NumOfNewChildren + 1;
        }
        
        system.debug('Num of New Children --------- ' + NumOfNewChildren);
        
        StoreNewChildren();

    }
    
    public void StoreNewChildren() {
        list<Child__c> ncs = NewChildren;
        for (integer i=0;i<NumOfNewChildren;i++) {
            Child__c c = new Child__c();
            c.Parent__c = FAId;
            ncs.add(c);
            
        }
        
        NewChildren = ncs;
        system.debug('list of new children ---------- ' + NewChildren);
    }
    
    

    public void ProcessNewChildren() {
        
        //loop through NewChildren list and remove any children that do not have a first name, which indicates the record was accidentally added
        for (integer i =0;i<NewChildren.size();) {
            if (NewChildren[i].Name == '' || NewChildren[i].Name == Null) {
                NewChildren.remove(i);
            } else {
                i= i + 1;
            }
        }
        
        
    }
    public PageReference SaveProfile() {
        ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error occurred while saving your updates. ' +
        'An email has been sent to your Salesforce Administrators, and you will be notified of a solution shortly. ' +
        'If you have any questions please email PremierAdvisors@wfadvisors.com');
        
        try { //save changes to profile
        
            ProfileRecord.Date_Time_Profile_Completed__c = system.now();
            ProfileRecord.Advisor_Profile_Completed__c = True;
            update ProfileRecord;
            
        } catch (exception e) {
            if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                ApexPages.addmessage(ErrorMsg);
                
                SendErrorEmail(e.getMessage());
                
                system.debug('Profile save error ------------- ' + e.getMessage());
            }
            return null;
        }
        
        try { //save changes to children
        
            update Children;
            
        } catch (exception e) {
            if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                ApexPages.addmessage(ErrorMsg);
            
                SendErrorEmail(e.getMessage());
                system.debug('Profile save error ------------- ' + e.getMessage());
            }
            return null;
        }
        
        try { //insert any new children
        
            ProcessNewChildren();//make sure not to insert blank children records
            
            if (NewChildren.size() > 0) {
                insert NewChildren;
            }
        } catch (exception e) {
            if (!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {     
                ApexPages.addmessage(ErrorMsg);
                
                SendErrorEmail(e.getMessage());
                
                system.debug('Profile save error ------------- ' + e.getMessage());
            }
            return null;
        
        }
        
        ProfileSaved = True;
        
        system.debug('Profile Saved? -------- ' + ProfileSaved);
        
        return null;
    }
    
    public void SendErrorEmail(String ErrorMsg) {
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
       //send error email to premier services
       String[] toAddresses = new String[] {'jerry.yu@wellsfargoadvisors.com'}; //premieradvisors
       mail.setToAddresses(toAddresses);
       mail.setSubject('Error Occurred On Advisor Profile');
       mail.setPlainTextBody
       ('The following error occurred when ' + ProfileRecord.Name + '\'s profile was being saved: \n \n' + ErrorMsg);
              
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
       
    }
    
    
    public void DeleteChild() {
        
        if (SelectedChildID == null) {
            return;
        }
        
        Child__c toBeDeleted = null;
        for (Child__c c: Children) {
            if (c.id == SelectedChildID) {
                toBeDeleted = c;
                break;
            }
        }
        
        if (toBeDeleted != null) {
            Delete toBeDeleted;
        }
        
        getChildren();
    }
    
      
    public void GetProfileInfo() {
        
        //EnteredANumber = Apexpages.currentPage().getParameters().get('EnteredANumber');
        
        //system.debug('Entered A Number ------------ ' + EnteredANumber);
        
        
        //getProfileRecord();
        
    }
    

    
}