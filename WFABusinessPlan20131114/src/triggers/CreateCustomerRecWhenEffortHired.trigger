trigger CreateCustomerRecWhenEffortHired on Opportunity (After Update) {

List<String> ANumbers = new List<String>();
List<ID> HiredEffortIDs = new List<ID>();
List<ID> BranchIDs = new List<ID>();
List<ID> MainBranchMgrIDs = new List<ID>();
List<Opportunity> AllNewHiredEfforts = new List<Opportunity>();
List<Opportunity> NewHiredPCGEfforts = new List<Opportunity>();
List<Opportunity> NewHiredWBSEfforts = new List<Opportunity>();
List<Opportunity> NewHiredFiNetEfforts = new List<Opportunity>();
List<Contact> AllNewHiredContacts = new List<Contact>();
List<Contact> ExistingContacts = new List<Contact>();
Map<ID, ID> ExistingFAToEffort = new Map<ID, ID>();
Map<ID, Contact> FAtoMgr = new Map<ID, Contact>();
Map<ID, Account> BranchesMap;
Map<ID, Main_Branch__c> MainBranchesMap;

Opportunity effort = trigger.new[0];
Opportunity oldEffort = trigger.oldmap.get(effort.id);

    
if (
    (effort.FA_Talent_Hired__c == system.now().date() &&
    (((oldEffort.StageName != 'Hired' && oldEffort.StageName != 'Hired - S7 Licensed') && 
    (effort.StageName == 'Hired' || effort.StageName == 'Hired - S7 Licensed')) 
    ||
    ((oldEffort.StageName != 'RPL-4' && oldEffort.StageName != 'Graduate/Affiliate') && 
    (effort.StageName == 'RPL-4' || effort.StageName == 'Graduate/Affiliate')))
    )
    || 
    (effort.FA_Talent_Hired__c == system.now().date() && oldEffort.FA_Talent_Hired__c == Null && 
    (effort.StageName == 'Hired' || effort.StageName == 'Hired - S7 licensed' ||
    effort.StageName == 'RPL-4' || effort.StageName == 'Graduate/Affiliate'))

    ) {
    
    For (Opportunity ef: trigger.new) {
        if (ef.AccountID != null) {
            BranchIDs.add(ef.AccountID);
        }
    }
    
    if (BranchIDs.size() > 0 ){
    
        //map of active branches with managers and main branches
        BranchesMap = new Map<ID, Account>([SELECT Name, Main_Branch__c, Active__c, Manager_Branch__c
        FROM Account WHERE ID IN: BranchIDs]); // Main_Branch__c != null AND Active__c = True AND Manager_Branch__c != null]); 
        
        List<ID> MainBranchIDs = new List<ID>();
        
        for (account b: BranchesMap.values()) {
            if (b.Main_Branch__c != null) {
                MainBranchIDs.add(b.Main_Branch__c);
            }
        }
        
        if (MainBranchIDs.size() >0) {    
            //Map of Main Branches with a main branch manager
            MainBranchesMap = new Map<ID, Main_Branch__c>([SELECT Manager_Main_Branch__c FROM Main_Branch__c WHERE ID IN: MainBranchIDs]);
        }
        
    }
    BranchIDs.clear();
    

    for (Opportunity ef : trigger.new) {
        Opportunity oldEf = trigger.oldmap.get(ef.id);
        
        system.debug('New Stage: ' + ef.StageName);
        system.debug('Old Stage: ' + oldEf.StageName);
        system.debug('FA talent Hired?: ' + ef.FA_Talent_Hired__c);
        system.debug('Old FA talent Hired?: ' + oldEf.FA_Talent_Hired__c);   
           
        if (
        (ef.FA_Talent_Hired__c == system.now().date() &&
        (((oldEf.StageName != 'Hired' && oldEf.StageName != 'Hired - S7 Licensed') && 
        (ef.StageName == 'Hired' || ef.StageName == 'Hired - S7 Licensed')) 
        ||
        ((oldEf.StageName != 'RPL-4' && oldEf.StageName != 'Graduate/Affiliate') && 
        (ef.StageName == 'RPL-4' || ef.StageName == 'Graduate/Affiliate')))
        )
        || 
        (ef.FA_Talent_Hired__c == system.now().date() && oldEf.FA_Talent_Hired__c == Null && 
        (ef.StageName == 'Hired' || ef.StageName == 'Hired - S7 licensed' ||
        ef.StageName == 'RPL-4' || ef.StageName == 'Graduate/Affiliate'))

        ) { //create contact only for newly hired fas marked hired for the first time
          
          system.debug('Date Effort Marked Hired -------------- ' + ef.FA_Talent_Hired__c);
          
          system.debug('Hired Effort\'s branch id ----------- ' + ef.AccountID);
          
          if (ef.AccountID != '0015000000dJlEQ') {   //not FARS branch
                     
                BranchIDs.add(ef.AccountID); //store branch ids of hired efforts for query
                
                system.debug('Channel------ ' + ef.Channel__c);
                
                if (ef.Channel__c == 'PCG') { //main branch only applies to pcg efforts for now 
                    
                    system.debug('Account id --------- ' + BranchesMap.get(ef.accountid));
                    
                    if (BranchesMap.get(ef.AccountID) == null) { //effort not being hired into active branches with manager and main branch       
                        system.debug('Error -------- branch does not have main branch');
                        throw new sfException('Effort being hired into branch that is either inactive, has no manager or has no main branch');
                    
                    } else { //effort's branch is active, has a manager and a main branch
                        
                        ID BranchMgrID = BranchesMap.get(ef.AccountID).Manager_Branch__c;
                            
                        ID MainBranchID = BranchesMap.get(ef.AccountID).Main_Branch__c; //store main branch id
                    
                        ID MainBranchMgrID = MainBranchesMap.get(MainBranchID).Manager_Main_Branch__c; //store main branch manager id
                            
                        if (MainBranchMgrID == null) { //main branch has no manager
                            throw new sfException('Main branch does not have a manager');
                        } else if (MainBranchMgrID != BranchMgrID) {
                            throw new sfException('Branch manager not the same as main branch manager');                     
                        } else {
                            MainBranchMgrIds.add(MainBranchMgrId);
                        }
                    
                    }
                }
                        
                if (ef.A_Number__c == '' || ef.A_Number__c == null) {
                    trigger.newmap.get(ef.id).adderror('FA must have an A Number');
                }
                
                ANumbers.add(string.valueof(ef.A_Number__c).trim().deletewhitespace()); //store a numbers to see if any contact records have the same number
                AllNewHiredEfforts.add(ef);
           }
                
        }
        
    }
    
    if (!AllNewHiredEfforts.isEmpty()) {
        
        system.debug('Hired Efforts before A# check: ' + AllNewHiredEfforts.size()); 
        
        //check to see if the fa being hired already has a contact record. based on if his or her a number already exists on a contact record
        Contact[] existingFAs = [SELECT FirstName, LastName, ID, A_Number__c FROM Contact WHERE A_Number__c IN: ANumbers];
        
        for (integer ie = 0; ie<AllNewHiredEfforts.size();ie++) {
            for (integer c = 0; c<existingFAs.size(); c++) {
                if (string.valueof(AllNewHiredEfforts[ie].A_Number__c).trim().deletewhitespace() 
                == string.valueof(existingFAs[c].A_Number__c).trim().deletewhitespace()) {
                    system.debug('----------Contact rec for fa exists--------------');
                    ExistingContacts.add(ExistingFAs[c]); //add to list to be emailed to Amy
                    ExistingFAToEffort.put(ExistingFAs[c].id, AllNewHiredEfforts[ie].id); //map FA's existing contact record to new effort
                    AllNewHiredEfforts.remove(ie); //Remove the effort that already has a contact record  
                    BranchIDs.remove(ie);   
                    ie--;      
                    Break;
                }
            }
        }
    
        system.debug('Hired Efforts after A# check: ' + AllNewHiredEfforts.size());  
           
        if (AllNewHiredEfforts.size()>0) {   //there are still efforts after checking for duplicate a numbers
        
            for (Opportunity ef : AllNewHiredEfforts) {
                system.debug('effort channel: ' + ef.channel__c + ' / ' + ef.ChannelText__c);
                if (ef.Channel__c == 'PCG' || ef.ChannelText__c == 'PCG') {
                    NewHiredPCGEfforts.add(ef); //store the hire efforts themselves
                } else if (ef.Channel__c == 'WBS' || ef.ChannelText__c == 'WBS') {
                    NewHiredWBSEfforts.add(ef);
                } else if (ef.Channel__c == 'FiNet' || ef.ChannelText__c == 'FiNet') {
                    NewHiredFiNetEfforts.add(ef);
                }
            }
         
         } 
        
         if (NewHiredPCGEfforts.size() > 0) {
        
            //Map of main branch managers       
            Map<ID, Contact> MainBranchMgrMap = new map<ID, Contact>([SELECT AccountID, IBDC__c, 
            National_Sales_Territory__c, Productivity_Consultant__c, Regional_Sales_Manager__c FROM Contact 
            WHERE ID IN: MainBranchMgrIDs]);
            
            //map each hired effort (id) to a manager (record)
            for (integer e = 0; e < NewHiredPCGEfforts.size(); e++) {//loop thru efforts
            
                system.debug('Efforts Branch ID: ' + NewHiredPCGEfforts[e].AccountID);
                ID MainBranchID = BranchesMap.get(NewHiredPCGEfforts[e].AccountID).Main_Branch__c;
                ID MainBranchMgrID = MainBranchesMap.get(MainBranchID).Manager_Main_Branch__c;
                
                FAtoMgr.put(NewHiredPCGEfforts[e].id, MainBranchMgrMap.get(MainBranchMgrID));
                
            
            }
                   
            AllNewHiredContacts = CreatingCustomerRecords.CreatePCGCustomerRecords(NewHiredPCGEfforts, FAtoMgr, AllNewHiredContacts);
         }    
            
         if (NewHiredWBSEfforts.size() > 0) {
            AllNewHiredContacts = CreatingCustomerRecords.CreateWBSCustomerRecords(NewHiredWBSEfforts, AllNewHiredContacts);
         }
            
         if (NewHiredFiNetEfforts.size() > 0) {
            AllNewHiredContacts = CreatingCustomerRecords.CreateFiNetCustomerRecords(NewHiredFiNetEfforts, AllNewHiredContacts);
         }
            
         if (AllNewHiredContacts.size()>0) {
            
           system.debug('All New Hired Contacts ------------- ' + AllNewHiredContacts);
            
           try{
                insert AllNewHiredContacts;
           } catch (DMLException e){
                for (Contact cons : AllNewHiredContacts) {
                     throw new SFException('Error Occurred on Record: ' + cons.LastName + ' : ' + e.getMessage() + ' : Contact Record Not Created');
                }
           }
         }
    
    }
           
    if (ExistingContacts.size() > 0) { //send email notification if there are efforts marked hired who have contact records already   
    
       system.debug('Contacts that already exist --------- ' + ExistingContacts);
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String EmailBody = '';
       
       for (Contact c: ExistingContacts) {
           c.Date_Effort_Marked_Hired__c = system.now().date();//trigger.newmap.get(ExistingFAToEffort.get(c.id)).closedate; //update new effort hired date on existing contact record
           c.Effort__c = ExistingFAToEffort.get(c.id); //update the existing contact to relate to the new effort
           EmailBody += c.FirstName + ' ' + c.LastName + '; ' + c.ID + '; ' + c.A_Number__c + '\n';
       }
       
       String[] toAddresses = new String[] {'Amy.Palatnick@wellsfargoadvisors.com','zach.bodine@wellsfargoadvisors.com','jerry.yu@wellsfargoadvisors.com','Matthew.Kane@wellsfargoadvisors.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Newly hired FAs with existing contact records');
       mail.setPlainTextBody
       ('The following FAs were marked hired but already have contact records: \n \n' + EmailBody);
       
       system.debug('email of existing contacts --------- ' + EmailBody);
       
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
       
       try {
           update ExistingContacts;
       } catch (Exception e) {
           for (Contact c: existingContacts) {
               trigger.newmap.get(ExistingFAtoEffort.get(c.id)).adderror('Error occurred: ' + e.getmessage() + ':FA\'s existing contact record not updated with new hired effort info');
           }
       }
    }
    }
    
    
}