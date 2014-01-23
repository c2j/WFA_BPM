trigger AssignMgrResponsibilities on Contact (after update) {

//if a trainee's contact page is updated so that the Trainee month >= 6 and is a multiple of 3,
//and if trainee segment = Below Minimum, create a trainee review responsibilities record related
//to the trainee and the branch he or she works at, and assign the responsibility record to one of the managers
//at the branch (the lowest level manager that is also an active salesforce user). If the trainee already
//has a trainee review responsibility record attached, don't create a new one

ID RecTypeID = '01250000000ULyC'; 

system.debug('Has AssignFAITReviewResponsibility trigger run? ------- ' + Validator_cls.hasAlreadyDone());

if (!Validator_cls.hasAlreadyDone()) {//prevents workflows from firing trigger twice
    
    
    Set<ID> BranchIDs = new Set<ID>();
    List<Contact> FAITsBelowMin = new list<Contact>();

    for (contact c : trigger.new) {
        contact oldc = trigger.oldmap.get(c.id);
        
        system.debug('old trainee segmentation --------- ' + oldc.trainee_segmentation__c);
        system.debug('new trainee segmentation --------- ' + c.trainee_segmentation__c);
        
        system.debug('old trainee segment--------- ' + oldc.trainee_segment__c);
        system.debug('new trainee segment--------- ' + c.trainee_segment__c);
        
        if ((c.TPM__c != oldc.TPM__c) && c.TPM__c >= 6 && c.TPM__c <= 48 && Math.MOD(integer.valueof(c.TPM__c), 3) == 0 &&
             c.Trainee_Segment__c == 'Below Minimum') {
                
                FAITsBelowMin.add(c);
                BranchIDs.add(c.AccountID);
        }
    }
        
    if (FAITsBelowMin.size() > 0) {
    
        Map<ID, Account> BranchMap = new Map<ID, Account>([SELECT ID, Manager_Branch__c,Sub_Complex_Manager_ID__c,
        Mkt_Cmplx_Manager_ID__c FROM Account WHERE ID IN: BranchIDs]);
        
        Map<ID, Responsibilities__c> ExistingResponsibilities = new Map<ID, Responsibilities__c>();
        
        //map faits below minimum to existing incomplete responsibility records    
        For (Responsibilities__c r : [SELECT ID, Branch__c, FA_Name__c FROM 
        Responsibilities__c WHERE RecordTypeID =: RecTypeID AND FA_Name__c IN: FAITsBelowMin AND Status__c != 'Completed']) {
            
            ExistingResponsibilities.put(r.FA_Name__c, r);
            
        }
        

        //Map<ID, ID> ContactIDToUserIDMap = new Map<ID, ID>();
        
        //map out each Manager to his or her user id
        //ContactIDToUserIDMap = MappingUserIDs.MapMgrToUserUsingBranch(BranchMap.keyset());
        
        List<Responsibilities__c> FAITResponsibilities = new List<Responsibilities__c>();
        
        for (contact c : FAITsBelowMin) {
            
            if (ExistingResponsibilities.get(c.id) == Null) {//fa should not already have an incomplete responsibility record
                
                Responsibilities__c r = new Responsibilities__c();
                r.Name = c.LastName + ', ' + c.FirstName + ' - Trainee Review';
                r.Branch__c = BranchMap.get(c.AccountID).id;
                r.FA_Name__c = c.ID;
                
                r.RecordTypeID = RecTypeID;
                r.Status__c = 'Assigned';
                                        
                FAITResponsibilities.add(r);
                
            }
            
        }
                
        try {
            system.debug('FAIT Responsibilities ------- ' + FAITResponsibilities);
            insert FAITResponsibilities;
            Validator_cls.setAlreadyDone();
        } catch (Exception e) {
            for (Contact c : FAITsBelowMin) {
                c.adderror(' Error occurred when inserting Trainee Review Responsibilities. Contact your system administrator');
                system.debug('Error inserting Trainee Review Responsibilites ------- ' + e.getmessage());
            }
        }
    }
    
}
}