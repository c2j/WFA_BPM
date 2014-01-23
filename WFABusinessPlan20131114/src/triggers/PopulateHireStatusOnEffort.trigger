trigger PopulateHireStatusOnEffort on FA_Talent__c (after update) {

//when a FA Talent is marked hired, locate the related active hired effort and update the Effort Marked Hired Date field to equal to the current date

List<ID> FTIds = new List<ID>();
List<ID> BranchIDs = new List<ID>();
Map<ID, Account> BranchesMap;
Map<ID, Main_Branch__c> MainBranchesMap;


for (FA_Talent__c ft : trigger.new) {
   
    FA_Talent__c oldFt = trigger.oldmap.get(ft.id);

    if ((oldFt.FAI_Status__c != 'HIRED' && oldFT.FAI_Status__c != 'HIRED Trainee') && (ft.FAI_Status__c == 'HIRED' || ft.FAI_Status__c == 'HIRED Trainee') ) {//only consider FA talents who are newly marked Hired
        //if (ft.A_Number__c == '' || ft.A_Number__c == null) {
        //    ft.adderror('Non FARS FAs need to have an A Number to be marked hired');
        //} else {
            FTIds.add(ft.id);
        //}

    }
}

system.debug('Hired FA Talents: ' + FTIDs.size());

if (FTIds.size() > 0) {

    //only select the hired effort of the FA. NO FARS FAs
    Opportunity[] efforts = [SELECT FA_Talent_Hired__c, FA_Talent_Name__c, Channel__c, AccountID FROM OPPORTUNITY WHERE 
    FA_Talent_Name__c IN: FTIds AND Probability = 100 AND FA_Talent_Hired__c = NULL AND AccountID !='0015000000dJlEQ'];
   
    //if fa talent is marked hired first, look for the active effort. 
    //validation rule will make sure fa talent can't be marked hired with multiple active efforts
    
    if (efforts.size() == 0) { 
        efforts = [SELECT FA_Talent_Hired__c, FA_Talent_Name__c, Channel__c, AccountID FROM OPPORTUNITY WHERE 
        FA_Talent_Name__c IN: FTIds AND Inactive__c = False AND FA_Talent_Hired__c = NULL AND Probability != 100
        AND AccountID !='0015000000dJlEQ']; //NO FARS FAs
     }
    
    if (efforts.size()>0) {
    
        For (Opportunity ef: efforts) {
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
        
        
        For (Opportunity ef :efforts) {
        
            if (ef.Channel__c == 'PCG') { //checking for main branch and main branch mgr only applies to pcg efforts for now 
                
                system.debug('Account id --------- ' + BranchesMap.get(ef.accountid));
                
                if (BranchesMap.get(ef.AccountID) == null) { //effort not being hired into active branches with manager and main branch       
                    system.debug('Error -------- branch does not have main branch');
                    trigger.newmap.get(ef.Fa_Talent_Name__c).adderror('Effort being hired into branch that is either inactive, has no manager or has no main branch');
                
                } else { //effort's branch is active, has a manager and a main branch
                    
                    ID BranchMgrID = BranchesMap.get(ef.AccountID).Manager_Branch__c;
                        
                    ID MainBranchID = BranchesMap.get(ef.AccountID).Main_Branch__c; //store main branch id
                
                    if (MainBranchesMap.get(MainBranchID) == null) {
                        trigger.newmap.get(ef.Fa_Talent_Name__c).adderror('Main branch does not have a manager');
                    } else {
                        ID MainBranchMgrID = MainBranchesMap.get(MainBranchID).Manager_Main_Branch__c; //store main branch manager id
                    
                        if (MainBranchMgrID != BranchMgrID) {
                            trigger.newmap.get(ef.Fa_Talent_Name__c).adderror('Branch manager not the same as main branch manager');                     
                        } else {
                            ef.FA_Talent_Hired__c = system.now().date();
                        }
                    }
                
                }
            } else { //non fars and pcg fas do not need the main branch check currently
                ef.FA_Talent_Hired__c = system.Today();
            }

        }
        
        try{
            update efforts;
        } catch (DMLException e) {
            for (opportunity ef: efforts) {
                throw new sfexception('Error occurred: ' + e.getmessage() + ' : Contact your system administrator');
            }
        }
    }
    
}

}