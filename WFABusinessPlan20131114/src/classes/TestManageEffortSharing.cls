@isTest
Public Class TestManageEffortSharing {

static testMethod void testEffortSharing() {
    
    Account[] Branches = new Account[]{
                            new Account(Name = 'PCG Branch 1', Active__c=True),
                            new Account(Name = 'PCG Branch 2', Active__c=True)
                            };
        
    insert Branches;
    
    Opportunity[] Efforts = new Opportunity[]{
        new Opportunity(Name = 'Test Effort 1', AccountID = Branches[0].id, StageName = 'Introduced Hiring Manager', CloseDate = system.Today(), 
        RecordTypeID = '01250000000UISS'),
        new Opportunity(Name = 'Test Effort 2', AccountID = Branches[0].id, StageName = 'Introduced Hiring Manager', CloseDate = system.Today(), 
        RecordTypeID = '01250000000UISS')
        };
        
    insert Efforts;
    
    List<Id> EffortIDs = new List<ID>();
    
    For (Opportunity o : Efforts) {
        EffortIDs.add(o.id);
    }
    
    //stage user: Market Manager
    User userMM = new User();
    userMM.Username = 'Test_user_MM@test.com';
    userMM.LastName = 'Test_MM_name';
    userMM.ProfileId = '00e50000000vLe3';
    userMM.Alias = 'tstMM';
    userMM.Email = 'Test_MM@email.com';
    userMM.CommunityNickname = 'Test_MM_nickname';
    userMM.TimeZoneSidKey = 'GMT';
    userMM.LocaleSidKey = 'en_US';
    userMM.LanguageLocaleKey = 'en_US';
    userMM.EmailEncodingKey = 'ISO-8859-1';
    userMM.MobilePhone = '+1 999-999-9999';
    userMM.AU__c = '0012345';
    userMM.EmployeeNumber = '1234567';
    insert userMM;
    
    
    //stage user: Branch Manager
    User userBM = new User();
    userBM.Username = 'Test_user_BM@test.com';
    userBM.LastName = 'Test_BM_name';
    userBM.ProfileId = '00e50000000z2sU'; //PCG Branch manager Profile
    userBM.Alias = 'tstBM';
    userBM.Email = 'Test_BM@email.com';
    userBM.CommunityNickname = 'Test_BM_nickname';
    userBM.TimeZoneSidKey = 'GMT';
    userBM.LocaleSidKey = 'en_US';
    userBM.LanguageLocaleKey = 'en_US';
    userBM.EmailEncodingKey = 'ISO-8859-1';
    userBM.MobilePhone = '+1 999-999-9999';
    userBM.AU__c = '0023456';
    userBM.EmployeeNumber = '2345678';
    insert userBM;
    
    //stage user: Main Branch Manager
    User userMBM = new User();
    userMBM.Username = 'Test_user_MBM@test.com';
    userMBM.LastName = 'Test_MBM_name';
    userMBM.ProfileId = '00e50000000vLe3'; //Market manager Profile
    userMBM.Alias = 'tstMBM';
    userMBM.Email = 'Test_MBM@email.com';
    userMBM.CommunityNickname = 'Test_MBM_nickname';
    userMBM.TimeZoneSidKey = 'GMT';
    userMBM.LocaleSidKey = 'en_US';
    userMBM.LanguageLocaleKey = 'en_US';
    userMBM.EmailEncodingKey = 'ISO-8859-1';
    userMBM.MobilePhone = '+1 999-999-9999';
    userMBM.AU__c = '0034567';
    userMBM.EmployeeNumber = '3456789';
    insert userMBM;    
    
    //store manager's user Ids to use in sharing record queries
    List<ID> ManagerUserIDs = new List<ID>();
    
    ManagerUserIDs.add(userMM.id);
    ManagerUserIDs.add(userBM.id);
    ManagerUserIDs.add(userMBM.id);        
    

    //create a contact record for the altoona main branch manager
    Contact[] Managers = new Contact[] {
                        new contact(FirstName = 'Branch',
                                    LastName = 'Manager',
                                    Email = 'Test_BM@email.com',
                                    AccountID = Branches[0].id,
                                    Type__c = 'Complex Manager',
                                    A_Number__c = 'A098765'),                                
                        new contact(FirstName = 'Main Branch',
                                    LastName = 'Manager',
                                    Email = 'Test_MBM@email.com',
                                    AccountID = Branches[1].id,
                                    Type__c = 'Branch Manager',
                                    A_Number__c = 'A876543'),
                        new contact(FirstName = 'Market',
                                    LastName = 'Manager',
                                    Email = 'Test_MM@email.com',
                                    AccountID = Branches[0].id,
                                    Type__c = 'Market Manager',
                                    A_Number__c = 'A765432'),
                        new contact(FirstName = 'Tester',
                                    LastName = 'FA',
                                    Email = 'tester.FA@wellsfargoadvisors.com',
                                    AccountID = Branches[1].id,
                                    Type__c = 'FA',
                                    A_Number__c = 'A987654')                                    
    
                        };                                                                                                        
                                    
    
    insert Managers;
    

    Main_Branch__c[] MainBranches = new Main_Branch__c[] {
                                       new Main_Branch__c(Name = 'PCG Main Branch1', Manager_Main_Branch__c = Managers[0].id),
                                       new Main_Branch__c(Name = 'PCG Main Branch2',Manager_Main_Branch__c = Managers[1].id)
                                       };
                                       
    insert MainBranches;
    
    
    Market_Complex__c MktComplex = new Market_Complex__c (Name = 'Test Market Complex', Manager_Market_Complex__c = Managers[2].id);
    
    insert MktComplex;
    
    Sub_Supl_Complex__c SubComplex = new Sub_Supl_Complex__c(Name = 'Test Sub Complex', Manager_Sub_Supl_Complex__c = Managers[1].id);
    
    insert SubComplex;
    
    
    test.startTest();

    //assigning managers to branches
    Branches[0].Manager_Branch__c = Managers[0].id; //SF User PCG Branch Manager
    Branches[1].Manager_Branch__c = Managers[1].id; //SF User Market Manager

    
    update Branches; //this should create sharing records on branches for their managers if the manager is a SF user
    
    //assigning branches main branches without main branch managers
    Branches[0].Main_Branch__c = MainBranches[0].id;
    Branches[1].Main_Branch__c = MainBranches[1].id;
    
    //assign branch 2 a sub complex and market complex
    Branches[1].Sub_Supl_Complex_Branch__c = SubComplex.id;
    Branches[1].Market_Complex_Branch__c = MktComplex.id;
    
    update Branches; //this should create sharing records on the main branches for the 3 managers who are SF users
        
    OpportunityShare[] EffortShares = [SELECT OpportunityID, UserOrGroupID FROM OpportunityShare WHERE OpportunityID IN: EffortIDs
                                        AND UserOrGroupID IN: ManagerUserIDs];
                                        
                                            
    system.assertequals(EffortShares.size(), 0);
    
    Efforts[0].AccountID = Branches[1].id;
    Efforts[1].AccountID = Branches[1].id;
    
    update Efforts;
    
    EffortShares = [SELECT OpportunityID, UserOrGroupID FROM OpportunityShare WHERE OpportunityID IN: EffortIDs
                                        AND UserOrGroupID IN: ManagerUserIDs];
                                        
                                            
    system.assertequals(EffortShares.size(), 8);    
    
    
    test.StopTest();

  }

}