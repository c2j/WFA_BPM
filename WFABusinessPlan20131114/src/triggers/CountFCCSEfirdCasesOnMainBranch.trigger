trigger CountFCCSEfirdCasesOnMainBranch on Case (After Insert) {

//counts Efird cases created on main branch record in current month

//012W0000000Cry8 FCCS Efird Rec Type ID in Sandbox
//01250000000ULV4 FCCS Efird Rec Type ID in Production

ID EfirdCaseRecTypeID = '01250000000ULV4';

Map<ID,Integer> EfirdCasesCntMap = new Map<ID,Integer>();
Map<ID,Case> MainBranchToEfirdCase = new Map<ID,Case>();
List<Case> EfirdCases = new List<Case>();
Set<ID> MainBranchIDs = new Set<ID>();
Boolean QueryAllCases = False;
Date FirstOfCrntMonth;
Date FirstOfNextMonth;



for (case c: trigger.new) {
    //012W0000000Cry8 use in sandbox; 01250000000ULV4 use in production
    
    if (c.Description == 'Back Fill FCCS Efird Cases Count on Main Branch') {
        QueryAllCases = True;
        break;
    } else if (c.RecordTypeId == EfirdCaseRecTypeID && c.FCCS_Firm__c != null ) {//FCCS Efird Case record type where FCCS Firm is not blank
        
        //EfirdCases.add(c);
        
        MainBranchIDs.add(c.FCCS_Firm__c);
        

    }

}

if (MainBranchIDs.size() > 0 || QueryAllCases) {
    
    FirstOfCrntMonth = date.newinstance(system.now().year(),system.now().month(),1);
    
    if (system.now().month() == 12) {
        FirstOfNextMonth= date.newinstance(system.now().year()+1,1,1);
    } else {
        FirstOfNextMonth= date.newinstance(system.now().year(),system.now().month()+1,1);    
    }
    
    
    Main_Branch__c[] MainBranchesWithEfirdCases;
    
    if (QueryAllCases == False) {
    
        EfirdCases = [SELECT FCCS_Firm__c, CreatedDate FROM Case WHERE RecordTypeID =: EfirdCaseRecTypeID AND FCCS_Firm__c IN : MainBranchIDs
                       AND CreatedDate >=: FirstOfCrntMonth AND CreatedDate <: FirstOfNextMonth ORDER BY FCCS_Firm__c ASC];
   
    
    } else {//back fill number of fccs efird cases on main branches
        

        EfirdCases = [SELECT FCCS_Firm__c, CreatedDate FROM Case WHERE RecordTypeID =: EfirdCaseRecTypeID AND FCCS_Firm__c != Null
                        AND CreatedDate >=: FirstOfCrntMonth AND CreatedDate <: FirstOfNextMonth ORDER BY FCCS_Firm__c ASC];
        
    }  
    
    
    //loop through all FCCS Efird Cases where FCCS Firm field is not blank
    for (Case c : EfirdCases) {
    
        MainBranchIDs.add(c.FCCS_Firm__c);        
        
        if (!EfirdCasesCntMap.keyset().contains(c.FCCS_Firm__c)) {        
            EfirdCasesCntMap.put(c.FCCS_Firm__c, 1);
        } else {
            EfirdCasesCntMap.put(c.FCCS_Firm__c, EfirdCasesCntMap.get(c.FCCS_Firm__c) + 1);
        }
        
        
    }
    
    //select all FCCS Firm Main Branches
    MainBranchesWithEfirdCases = [SELECT ID, Number_Of_FCCS_Efird_Cases__c, Last_Date_Case_Logged__c FROM Main_Branch__c WHERE ID IN: MainBranchIDs ];                 

    for (Case c: EfirdCases ) {
        if (!MainBranchToEfirdCase.keyset().contains(c.FCCS_Firm__c)) {
            MainBranchToEfirdCase.put(c.FCCS_Firm__c, c);
            
        //map the main branch to the most recent efird case logged on it
        } else if (c.CreatedDate > MainBranchToEfirdCase.get(c.FCCS_Firm__c).CreatedDate) {
            MainBranchToEfirdCase.put(c.FCCS_Firm__c, c);
        }
    }
    
    system.debug('newly created FCCS Efird cases ----------- ' + EfirdCasesCntMap.values().size() + ' / ' + EfirdCasesCntMap.values());
    
    
    system.debug('FAs with new FCCS Efird cases before case count update--------- ' + MainBranchesWithEfirdCases.size() + ' / ' + MainBranchesWithEfirdCases);
    
    //update on the Main branch the number of FCCS Efird Cases associated with it
    for (Main_Branch__c mb: MainBranchesWithEfirdCases) {
        if (EfirdCasesCntMap.get(mb.id) != null) {
            mb.Number_Of_FCCS_Efird_Cases__c = EfirdCasesCntMap.get(mb.id);
            
            //update the date when the most recent case was logged on main branch
            if (mb.Last_Date_Case_Logged__c == null || MainBranchToEfirdCase.get(mb.id).CreatedDate > mb.Last_Date_Case_Logged__c) {
                mb.Last_Date_Case_Logged__c = MainBranchToEfirdCase.get(mb.id).CreatedDate;
            }
        }
    }
    
    
    try {
        system.debug('FAs with new FCCS Efird cases after case count update--------- ' + MainBranchesWithEfirdCases.size() + ' / ' + MainBranchesWithEfirdCases);
        
        update MainBranchesWithEfirdCases;
        
    } catch (Exception e) {
        system.debug('Error occurred updating FCCS Efird cases count on main branch records --------------- ' + e.getMessage());
        throw new SFException('Error occurred updating FCCS Efirdcases count on Main Branch records. Please contact your system administrator.');
    }
    
}

}