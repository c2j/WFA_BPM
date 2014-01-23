@isTest

Private Class TestCreateFAIRBCLeadSources {


Static testMethod void TestCreatingFAIRBCLS () {

    User RBC = [SELECT ID FROM User WHERE UserRoleID = '00E500000013nin' AND AU__c != Null AND EmployeeNumber != Null 
    AND MobilePhone = '+1 999-999-9999' AND IsActive = True Limit 1];
    
    Channel__c FiNet = new Channel__c(Name='FiNet');
    Channel__c PCG = new Channel__c(Name='PCG');
    
    insert FiNet;
    insert PCG;
        
    Account PCGBranch = new Account();
    PCGBranch.Name = 'PCG Branch';
    PCGBranch.Channel_Branch__c = PCG.ID;
    
    insert PCGBranch;

    Account FiNetBranch = new Account();
    FiNetBranch.Name = 'FiNet Branch';
    FiNetBranch.Channel_Branch__c = FiNet.ID;
    
    insert FiNetBranch;
        
    AccountShare RBCPCGBranchShare = new AccountShare(); 
                
    //create sharing record on test branch for RBC
    RBCPCGBranchShare.AccountID = PCGBranch.ID;
                
    RBCPCGBranchShare.UserOrGroupID = RBC.ID;
    
    //grant managers read only access
    RBCPCGBranchShare.AccountAccessLevel = 'Edit';
    RBCPCGBranchShare.ContactAccessLevel = 'read';
    RBCPCGBranchShare.OpportunityAccessLevel = 'edit';
    RBCPCGBranchShare.CaseAccessLevel = 'edit';
                
    insert RBCPCGBranchShare;
    
    AccountShare RBCFiNetBranchShare = new AccountShare(); 
                
    //create sharing record on test branch for RBC
    RBCFiNetBranchShare.AccountID = FiNetBranch.ID;
                
    RBCFiNetBranchShare.UserOrGroupID = RBC.ID;
    
    //grant managers read only access
    RBCFiNetBranchShare.AccountAccessLevel = 'Edit';
    RBCFiNetBranchShare.ContactAccessLevel = 'read';
    RBCFiNetBranchShare.OpportunityAccessLevel = 'edit';
    RBCFiNetBranchShare.CaseAccessLevel = 'edit';
                
    insert RBCFiNetBranchShare;
   

    test.StartTest();
    
    system.runAs(RBC) {
    
    Opportunity PCGEffort = new Opportunity(Name = 'Test FA Effort', RecordTypeID = '01250000000UISS', AccountID = PCGBranch.id, 
    StageName = 'Introduced Hiring Manager', CloseDate = date.newinstance(system.now().year(), 12,31),
    Recruiting_Responsibility__c = 'Marketing Manager');
    
    insert PCGEffort;
    
    Opportunity FiNetEffort = new Opportunity(Name = 'Test FA FiNet Effort', RecordTypeID = '01250000000UISQ',
    AccountID = FiNetBranch.id, 
    StageName = 'BDC-1', CloseDate = date.newinstance(system.now().year(), 12,31));
    
    insert FiNetEffort;
    
    
    
    test.StopTest();
    
    Lead_Source__c[] PCGLeadSource = [SELECT Effort__c, Lead_Accepted_Date__c, Lead_Source__c FROM Lead_Source__c WHERE Effort__c =: PCGEffort.id];
    
    system.assertequals(PCGLeadSource.size(), 0);
    
    Lead_Source__c FiNetLeadSource = [SELECT Effort__c, Lead_Accepted_Date__c, Lead_Source__c FROM Lead_Source__c WHERE Effort__c =: FiNetEffort.id];
    
    system.assertequals(FiNetLeadSource.Lead_Accepted_Date__c, system.today());    
    system.assertequals(FiNetLeadSource.Lead_Source__c, 'FAI RBC');    
    
    }
    
}
}