public with sharing class vfFAsProfileCtrlr {

    public ID ContactID{get;set;}
    public ID profRecID{get;set;}
    public Hobbies_Charities__c profInfoRec{get;set;}
    public List<Child__c> children{get;set;}
    public Integer PageSize{get;set;}
    public boolean AllowShowMore{get;set;}  
    public boolean HasChildren{get;set;}
    public String SelectedChildID{get;set;}
    public String ParentName {get;set;}
    
    public vfFAsProfileCtrlr(ApexPages.StandardController controller) {
        
        profRecID = ApexPages.currentPage().getParameters().get('id');
        
        profInfoRec = [SELECT NAME__c, First_Name__c, Last_Name__c, Advisor_Profile_Completed__c, Status__c From Hobbies_Charities__c WHERE ID =: profRecID Limit 1];
        
        system.debug('profile rec id------------- ' + profRecId);
        
        ContactID = profInfoRec.Name__c;
        
        system.debug('Contact Id ---------------- ' + ContactID);
        
        getChildren();
        
        ParentName = [SELECT Name FROM Contact WHERE ID =: ContactID].Name;
        ParentName = ParentName.replace(' ','+');
        
        PageSize = Math.Min(5, Children.size());
        
        if (Children.size() > 0) {
            HasChildren = True;
            
        }
    }
        
    public void getChildren() {
        
        children = [SELECT Name, Child_Last_Name__c,  Child_Address_1__c, Child_City__c, Child_State__c, Child_Zip__c, Child_Age__c, 
                    Child_Birthdate__c, Child_School_College__c, Relationship_Type__c,Gender__c FROM Child__c WHERE Parent__c =: ContactID 
                    ORDER BY Child_Age__c DESC NULLS LAST];
    }    
    
    public void showMore() {
        PageSize += 5;
    }    
    
    public void SetAllowShowMore() {
        
        system.debug('Page Size ------------ ' + PageSize);
        system.debug('# of Children ------------ ' + Children.Size());
        
        if (Children.size() < 5  ) {
            AllowShowMore = False;
        } else {
            AllowShowMore = True;
        }
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
     
    public PageReference GoToFullList() {
        
        PageReference FullListOfChildren = new PageReference('/a0O?rlid=00N50000002OMzD&id='+ContactID);

        return FullListOfChildren;
    }
    
    public PageReference AddNewChild() {
        
        PageReference NewChild = new PageReference('/a0O/e?CF00N50000002OMzD='+ParentName+'&CF00N50000002OMzD_lkid='+ContactID+'&retURL=%2F'+profRecID+'&saveURL=%2F'+profRecID);
        
        return NewChild;
    }
    
    /*public PageReference LoadEditMode() {
        
        PageReference EditProfile = new PageReference('/'+profRecID+'/e?retURL=%2F'+ContactID);
        
        return EditProfile;
        
    }*/

}