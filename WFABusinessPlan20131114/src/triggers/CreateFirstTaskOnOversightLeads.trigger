trigger CreateFirstTaskOnOversightLeads on Lead (after insert) {

//Trigger created and named for the leads oversight pilot, but now being reactivated for the client referral sweepstakes

string CompanyName = '';
List<Task> IBDCLeadsTasks = new List<Task>();
Map<Lead, ID> LeadsToFAIds = new Map<Lead, ID>();
Map<ID, ID> ContactToIBDC = new Map<ID,ID>();
List<ID> OversightLeadsID = new List<ID>();
Set<ID> LeadsFAIDs = new Set<ID>();


for (lead l: trigger.new) {
    
    if (l.Assigned_FA__c != NULL && l.Company.toLowerCase() == 'client referral sweepstakes') {
        LeadsToFAIds.put(l, l.Assigned_FA__c);      
    }
}    

if (LeadsToFAIds.values().size()>0) {
    
    LeadsFAIds.addall(LeadsToFAIds.values());
    
    Map<ID, Contact> BranchMgrs = new Map<ID, Contact>([SELECT Account.Manager_Branch__r.Email FROM 
    Contact WHERE ID IN : LeadsFAIds]);
    
    ContactToIBDC = UtilityMethods.GetUserIDMap(LeadsFAIds,'IBDC');
    
    Date DueDate = UtilityMethods.TaskDueDate(System.today().adddays(7),'Monday');
    
    for (ID FAId : LeadsFAIds) {        //lead l :LeadsToFAIds.keyset()
     
        system.debug('Contact\'s ibdc --------- ' + ContactToIBDC.get(FAId));
        
        If (ContactToIBDC.get(FAId) == null) {
            system.debug('------FA does not have an active IBDC--------');
            throw new SFException('FA does not have an active IBDC');
        } else {
            
            task t = new task(RecordTypeId = '012300000000V1J', OwnerID = ContactToIBDC.get(FAId),
            Subject = 'Leads Distribution', Category__c = 'Leads Distribution-Initial Contact', 
            Sales_Strategy_Initiative__c = 'Client Referral Sweepstakes - Leads Follow Up Callout', 
            Lead_Status__c = 'Accepted', Communication_Type__c = 'Outbound', Type = 'Contact-Phone', 
            WhoID = FAId, status= 'Incomplete', ActivityDate = DueDate,
            Task_Due_Date__c = DueDate);
            
            IBDCLeadsTasks.add(t);
            
            //OversightLeadsID.add(l.id); //store leads id to query for oversight leads to update the branch manager email fields on them

        
        }
    }
}
    

if (IBDCLeadsTasks.size() > 0) {
    try {
        insert IBDCLeadsTasks;
    } catch (DMLException e) {
        For (lead l : trigger.new) {
            l.adderror('Error in creating leads tasks : ' + e.getMessage());
            system.debug('Error in creating leads tasks ------------- ' + e.getMessage());
        }
    }       

    /*Map<ID, Lead> OversightLeads = new Map<ID, Lead>([SELECT Branch_Manager_Email__c, Assigned_FA__c 
    FROM Lead WHERE ID IN : OversightLeadsID]);
    
    system.debug('Client Referral Sweepstakes leads --------' + OversightLeads);
    
    Map<ID, Contact> FAToBranchMgr = new Map<ID, Contact>([SELECT Account.Manager_Branch__r.Email FROM 
    Contact WHERE ID IN : LeadContacts]);
    
    system.debug('FA to Branch Mgr --------' + FAToBranchMgr);
    
    for (Lead l : trigger.new) {
        
        if (l.Company == 'Client Referral Sweepstakes') {
    
        system.debug('lead id ----------- ' + l.id);
        system.debug('Oversight Lead Rec ----------- ' + OversightLeads.get(l.id));
        system.debug('lead FA ----------- ' + l.Assigned_FA__c);
        //system.debug('Lead Fa\'s Manager ----------- ' + FAToBranchMgr.get(l.Assigned_FA__c));
        system.debug('Manager Email ----------- ' + FAToBranchMgr.get(l.Assigned_FA__c).Account.Manager_Branch__r.Email);
     
            if (l.Assigned_FA__c == NULL) {
                l.adderror('Lead is not assigned an FA.');
            } else if (FAToBranchMgr.get(l.Assigned_FA__c).Account.Manager_Branch__r.Email == NULL ||
            FAToBranchMgr.get(l.Assigned_FA__c).Account.Manager_Branch__r.Email == '') {
                l.adderror('FA\'s branch manager does not have an email listed or FA\'s branch has no manager.');
            } else if (OversightLeads.get(l.id) == null) {
                l.adderror('Client Referral Sweepstakes Record does not exist');
            } else {
                OversightLeads.get(l.id).Branch_Manager_Email__c = FAToBranchMgr.get(l.Assigned_FA__c).Account.Manager_Branch__r.Email;
            }
        }
    }

    try {
        update OversightLeads.values();
    } catch (DMLException e) {
        for (Lead l : OversightLeads.values()) {
            l.adderror('Error in updating Branch Manager Email: ' + e.getMessage() + ' : ' + 'Emails to Branch Managers not sent');
        }
    }
    */
}

}