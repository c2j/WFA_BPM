global class CreateNewFATalentButton {
/* *******DEPRECATED*******


    webservice static string CreateNewFATalentFromCaseOnClick(String caseID) {
    
    Case AddFACase = [SELECT FA_First_Name__c, FA_Last_Name__c, Employing_Firm__c, At_Firm_Since__c, Series_7_Received_Date__c,
                     CRD_Number__c FROM Case WHERE ID =: caseID];
     
    FA_Talent__c[] ExistingFATalent = [SELECT ID, Name, CRD_Number__c, A_Number__c FROM FA_Talent__c WHERE CRD_Number__c =: AddFACase.CRD_Number__c];
    
    //Check if CRD number already exists on an FA Talent
    //If FA Talent already exists with the submitted CRD Number. This case is for a rehire, so add an 'H' after FA Talent's name,
    //CRD Number and A Number
    
    If (ExistingFAtalent.size() > 0) {
        
        system.debug('Exsiting FA Talent ---------- ' + ExistingFATalent.size() + ' / ' + ExistingFATalent);
        
        ExistingFATalent[0].Name = ExistingFATalent[0].Name + 'H';
        ExistingFATalent[0].CRD_Number__c = ExistingFATalent[0].CRD_Number__c + 'H';
        
        if (ExistingFATalent[0].A_Number__c != Null) {
            ExistingFATalent[0].A_Number__c = ExistingFATalent[0].A_Number__c + 'H';
        }
        
        try {
            update ExistingFATalent;
        } catch (Exception e) {
            system.debug('Error occured updating an existing FA Talent for case --------- ' + e.getMessage());
            return 'Error occurred while updating this FA\'s old FA Talent Record. Contact your system administrator.';
            
        }
    }
    
    //Create the new FA talent record
    FA_Talent__c NewFATalent = new FA_Talent__c();
    NewFATalent.Name = AddFACase.FA_First_Name__c + ' ' + AddFACase.FA_Last_Name__c + ' ' + AddFACase.CRD_Number__c;
    NewFATalent.FAI_Status__c = 'AV';
    NewFATalent.Employing_Firm__c = AddFACase.Employing_Firm__c;
    NewFATalent.First_Name__c = AddFACase.FA_First_Name__c;
    NewFATalent.Last_Name__c = AddFACase.FA_Last_Name__c;
    NewFATalent.At_Firm_Since__c = AddFACase.At_Firm_Since__c;
    NewFATalent.Broker_Since__c = AddFACase.Series_7_Received_Date__c;
    NewFATalent.CRD_Number__c = AddFACase.CRD_Number__c;
    
    try {
        insert NewFATalent;
        
    } catch (Exception e) {
        
        system.debug('Error occurred inserting new FA Talent for case --------- ' + e.getMessage());
        return 'Error occurred while inserting this FA\'s new FA Talent Record. Contact your system administrator.';
    }
    
    AddFACase.Status = 'Closed';
    AddFACase.Reason = 'Completed Request';
    
    try {
        update AddFACase;
        
    } catch (Exception e) {
        
        system.debug('Error occurred closing Add New FA Case ------------ ' + e.getMessage());
        return 'Error occurred while closing this case. Contact your system administrator.';
    }
    
    
    return 'New FA Talent record inserted and case is closed';
    
    }
 */   
}