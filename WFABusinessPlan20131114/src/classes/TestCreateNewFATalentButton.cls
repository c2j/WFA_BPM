@isTest

private class TestCreateNewFATalentButton {

/* ********DEPRECATED*********
    static testMethod void testCreateNewFATalentFromCaseButton() {
    
        Employing_Firm__c firm = new Employing_Firm__c();
        firm.Name = 'Test Firm';
        
        insert firm;
        
        Employing_Firm__c newFirm = new Employing_Firm__c();
        newFirm.Name = 'New Test Firm';
        
        insert newFirm;
        
        FA_Talent__c FATal = new FA_Talent__c();
        FATal.Name = 'Test FATalent 816168';
        FATal.FAI_Status__c = 'AV';
        FATal.Employing_Firm__c = firm.id;
        FATal.CRD_Number__c = '816168';
        FATal.First_Name__c = 'Test';
        FATal.Last_Name__c = 'FATalent';
        FATal.At_Firm_Since__c = date.newinstance(2012,4,6);
        FATal.Broker_Since__c = date.newinstance(2005,7,3);
        
        insert FATal;
        
        Case FAICase = new Case();
        FAICase.RecordTypeID = '01250000000UIsC';
        FAICase.Type = 'Add FA to System';
        FAICase.Status = 'New';
        FAICase.Origin = 'Email';
        FAICase.FA_First_Name__c = 'Test';
        FAICase.FA_Last_Name__c = 'FATalent';
        FAICase.CRD_Number__c = '816168';
        FAICase.Employing_Firm__c = newFirm.Id;
        FAICase.At_Firm_Since__c = date.newinstance(2013,1,1);
        FAICase.Series_7_Received_Date__c = date.newinstance(2005,7,3);
        
        insert FAICase;
        
        test.StartTest();
        
        FAICase = [SELECT ID FROM Case WHERE CRD_Number__c = '816168' Limit 1];
        
        CreateNewFATalentButton.CreateNewFATalentFromCaseOnClick(FAICase.id);
        
        test.StopTest();
        
        FA_Talent__c[] oldFT = [SELECT Name, CRD_Number__c FROM FA_Talent__c WHERE Name = 'Test FATalent 816168H' AND CRD_Number__c = '816168H'];
        
        System.assertequals(oldFT.size(), 1);
        
        FA_Talent__c[] newFT = [SELECT Name, CRD_Number__c FROM FA_Talent__c WHERE Name = 'Test FATalent 816168' AND CRD_Number__c = '816168'];        

        System.assertequals(oldFT.size(), 1);
        
    }
    */
}