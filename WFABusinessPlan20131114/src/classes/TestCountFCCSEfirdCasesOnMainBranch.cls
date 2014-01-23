@isTest

public class TestCountFCCSEfirdCasesOnMainBranch {

    static testMethod void testCountEfirdCasesOnMB() {
    
    //012W0000000Cry8 use in sandbox; 01250000000ULV4 use in production
    ID EfirdCaseRecTypeID = '01250000000ULV4';
    
    //Create FCCS Firm Main Branch Record
    
    Main_Branch__c FCCSFirm = new Main_Branch__c();
    FCCSFirm.name = 'Test FCCS Firm';
    FCCSFirm.RecordTypeID = '01250000000UGdP';
    
    insert FCCSFirm;
    
    //create list of FCCS Efird Cases
    List<Case> EfirdCases = new List<Case>();
    
    For (integer i = 0; i <5; i++) {
        Case c = new Case();
        c.RecordTypeID = EfirdCaseRecTypeID; 
        c.FCCS_Firm__c = FCCSFirm.ID;
        c.Type = 'Inquiry';
        c.Origin = 'Call';
        c.Subject__c = 'Finance';
        c.Category__c = 'Audit';
        c.Reason = 'Conflicting Information';
        c.Status = 'Working';
        c.Description = 'test Efird Cases';
        
        EfirdCases.add(c);
    }
    
    test.startTest();
    
    insert EfirdCases;
    
    Main_Branch__c FCCSFirms = [SELECT ID, Number_Of_FCCS_Efird_Cases__c FROM Main_Branch__c WHERE ID =: FCCSFirm.ID];
    
    system.assertequals(FCCSFirms.Number_Of_FCCS_Efird_Cases__c, 5);
    
    //clear the number of fccs efird cases field on the main branch, so the code below can simulate back filling this field
    FCCSFirms.Number_Of_FCCS_Efird_Cases__c = 0;
    
    update FCCSFirms;
    
    //insert new dummy case to back fill the number of fccs efird cases field on the main branch
    
    Case newEfirdCase = new case();
    
    newEfirdCase.RecordTypeID = EfirdCaseRecTypeID;
    newEfirdCase.FCCS_Firm__c = FCCSFirm.ID;
    newEfirdCase.Type = 'Inquiry';
    newEfirdCase.Origin = 'Call';
    newEfirdCase.Subject__c = 'Finance';
    newEfirdCase.Category__c = 'Audit';
    newEfirdCase.Reason = 'Conflicting Information';
    newEfirdCase.Status = 'Working';
    newEfirdCase.Description = 'Back Fill FCCS Efird Cases Count on Main Branch';
    
    insert newEfirdCase;
    
    FCCSFirms = [SELECT ID, Number_Of_FCCS_Efird_Cases__c FROM Main_Branch__c WHERE ID =: FCCSFirm.ID];
    
    system.assertequals(FCCSFirms.Number_Of_FCCS_Efird_Cases__c, 6);
    
    Case newEfirdCase2 = new case();
    
    newEfirdCase2.RecordTypeID = EfirdCaseRecTypeID; 
    newEfirdCase2.FCCS_Firm__c = FCCSFirm.ID;
    newEfirdCase2.Type = 'Inquiry';
    newEfirdCase2.Origin = 'Call';
    newEfirdCase2.Subject__c = 'Finance';
    newEfirdCase2.Category__c = 'Audit';
    newEfirdCase2.Reason = 'Conflicting Information';
    newEfirdCase2.Status = 'Working';
    
    insert newEfirdCase2;
    
    FCCSFirms = [SELECT ID, Number_Of_FCCS_Efird_Cases__c FROM Main_Branch__c WHERE ID =: FCCSFirm.ID];
    
    system.assertequals(FCCSFirms.Number_Of_FCCS_Efird_Cases__c, 7);
    
    test.stopTest();
        
    }
}