public with sharing class UtilityMethods{
 
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getUpdateableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isUpdateable()){ // field is updateable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
    Public Static Integer getDaysBetweenDateTimes(DateTime DT1, DateTime DT2) {
    
        return Integer.valueOf((DT1.getTime() - DT2.getTime())/(1000*60*60*24));
    }
    
    Public Static Date TaskDueDate(Date DueDate, String FriOrMon) {

        If (Math.MOD(Date.newinstance(1900,1,7).daysbetween(DueDate), 7) == 6){//due date is a saturday
            If (FriOrMon == 'Friday') {
                DueDate = DueDate.adddays(-1); //make task due date a friday
            } else if (FriOrMon == 'Monday') {
                DueDate = DueDate.adddays(2); //make task due date a Monday
            }
  
        } else if (Math.MOD(Date.newinstance(1900,1,7).daysbetween(DueDate), 7) == 0){//due date is a Sunday
            If (FriOrMon == 'Friday') {
                DueDate = DueDate.adddays(-2); //make task due date a friday
            } else if (FriOrMon == 'Monday') { 
                DueDate = DueDate.adddays(1); //make task due date a Monday
            }                
        }
        Return DueDate;

    }

    Public static Map<ID, ID> GetUserIDMap (Set<ID> ConIDs, String UserType) {
        
        system.debug('Tracking new contact\'s id --------------- ' + ConIds);
        
        Contact[] Contacts = [SELECT IBDC__c, Productivity_Consultant__c, Regional_Banking_Consultant__c 
        FROM Contact WHERE ID IN: ConIDs];
        
        Set<String> Names = new Set<String>();
        Map<ID, ID> ConIDToUserID = new Map<ID, ID>();
        
        for (contact c: contacts) {
            
            if (UserType == 'IBDC') {
                Names.add(c.IBDC__c);
            } else if (UserType == 'PC') {
                Names.add(c.Productivity_Consultant__c);
            } else If (UserType == 'RBC') {
                Names.add(c.Regional_Banking_Consultant__c);
            }
        }
        
        User[] users = [SELECT ID, Name, ProfileID FROM User WHERE Name IN : Names AND IsActive = True];
        
        if (users.size()>0) {
            For (contact c: contacts) {
                For (User u : users) {
                    if (UserType == 'IBDC') {
                        If (c.IBDC__c == u.Name && (u.ProfileID == '00e50000000vBn0' || u.ProfileID == '00e50000000z2xo' || 
                        u.ProfileID == '00e50000000z43R' || u.ProfileID == '00e50000000yyAq')) {
                            ConIDToUserID.put(c.ID, u.ID);
                            Break;
                        }
                    } else if (UserType =='PC') {
                        If (c.Productivity_Consultant__c == u.Name && (u.ProfileID == '00e50000000vBn5' 
                        || u.ProfileID == '00e50000000z43W')) {
                            ConIDToUserID.put(c.ID, u.ID);
                            Break;
                        }
                    } else if (UserType =='RBC') {
                        If (c.Regional_Banking_Consultant__c == u.Name && u.ProfileID == '00e50000000v97g') {
                            ConIDToUserID.put(c.ID, u.ID);
                            Break;
                        }
                    }                    
                }
            }
        }
        
        return ConIdToUserID;
            
    }
    
    Public static Map<Id,Id> GetContactIDToUserIDMap(List<Contact> contacts, List<User> Users) {
    
        Map<ID, ID> ContactIDToUserIDMap = new Map<ID, ID>();
        
        for (integer ic = 0; ic < Contacts.size();) {
            for (user u : Users) {
                if (contacts[ic].Email == u.Email) {//contact's email equals user's email means the contact is the user
                    
                    system.debug('Contact ID to map to user ------ ' + contacts[ic].id);
                    system.debug('Contact\'s user id -------- ' + u.id);
                    
                    ContactIDToUserIDMap.put(contacts[ic].ID, u.ID);
                    break;
                    
                }
            }
            contacts.remove(ic);
            //system.debug('remaining contacts to map to users -------- ' + contacts);
        }
        
        return ContactIDToUserIDMap;
        
    }    
    public static String GetPCGContactOwner(String RegionID) {
    
        Map<String, string> ContactOwner = new Map<String,String>();
         
        ContactOwner.put('a1550000000JZoZ', '00530000000lcgO'); //central
        ContactOwner.put('a1550000000JZoa', '00550000000mubA'); //eastern
        ContactOwner.put('a1550000000cgRd', '00550000000meXV'); //gulf coast
        ContactOwner.put('a1550000000JZpA', '00550000000muav'); //Great Lakes
        ContactOwner.put('a1550000000JZpF', '00550000000lvBZ'); //home  Production Home Region ID a1550000000JZpF
        ContactOwner.put('a1550000000JZoc', '00550000000mubF'); //mid atlantic
        ContactOwner.put('a1550000000JZpC', '00550000000mub5'); //northeast
        ContactOwner.put('a1550000000JZpD', '00550000000muaW'); //PacNorth
        ContactOwner.put('a1550000000JZpL', '00550000001BwwR'); //PacSouth
        ContactOwner.put('a15500000017u0Z', '00550000001vELs'); //IPCS
        
        if (ContactOwner.get(RegionID) == null) {
            return 'region does not exist in PCG';
        } else {
            return ContactOwner.get(regionid);
        }
    
    }
    
    public static void Email(String Subject, String Body, List<String> ToAddresses) {
    
        Messaging.SingleEmailMessage Mail = new Messaging.SingleEmailMessage();

        //String[] ToAddresses = new String[] {'jerry.yu@wellsfargoadvisors.com'};
        if (ToAddresses == null) {
            ToAddresses = new String[] {'jerry.yu@wellsfargoadvisors.com'};
        }
        
        system.debug('To Address ---------- ' + ToAddresses);
        system.debug('Subject ---------- ' + Subject);
        system.debug('Body ---------- ' + Body);
        
        Mail.setToAddresses(ToAddresses);
        Mail.setSubject(Subject);
        Mail.setPlainTextBody(Body);
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { Mail });
        
        system.debug('email should have been sent');
        
    }
    
    
    
}