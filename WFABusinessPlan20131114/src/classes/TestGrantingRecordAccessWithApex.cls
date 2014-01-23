@isTest
Public Class TestGrantingRecordAccessWithApex {

static testMethod void testManagersAccess() {
    
    Account[] Branches = new Account[]{
                            new Account(Name = 'PCG Branch 1', Active__c=True),
                            new Account(Name = 'PCG Branch 2', Active__c=True),
                            new Account(Name = 'PCG Branch 3', Active__c=True),                            
                            new Account(Name = 'PCG Branch PF', Active__c=True),
                            new Account(Name = 'WBS Branch', Active__c=True)                            
                            };
        
    insert Branches;
    

    
    List<Id> BranchIDs = new List<ID>();
    
    For (Account b : Branches) {
        System.debug('Test class branch name and id -------- ' + b.Name + ' ' + b.id);
        BranchIDs.add(b.id);
    }

    //get the user id for the altoona main branch manager
    
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
    userMBM.ProfileId = '00e50000000z2sU'; //PCG Branch manager Profile
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
    
    //stage user: SDBK
    User userSDBK = new User();
    userSDBK.Username = 'Test_user_SDBK@test.com';
    userSDBK.LastName = 'Test_SDBK_name';
    userSDBK.ProfileId = '00e50000000z6nI'; //sandbox WBS RBM & SDBK Profile '00eP0000000QOS1' //production WBS RBM & SDBK Profile '00e50000000z6nI'
    userSDBK.Alias = 'tstSDBK';
    userSDBK.Email = 'Test_SDBK@email.com';
    userSDBK.CommunityNickname = 'Test_SDBK_nickname';
    userSDBK.TimeZoneSidKey = 'GMT';
    userSDBK.LocaleSidKey = 'en_US';
    userSDBK.LanguageLocaleKey = 'en_US';
    userSDBK.EmailEncodingKey = 'ISO-8859-1';
    userSDBK.MobilePhone = '+1 999-999-9999';
    userSDBK.AU__c = '0034567';
    userSDBK.EmployeeNumber = '3456789';
    
    insert userSDBK;     
      
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
                                    AccountID = Branches[2].id,
                                    Type__c = 'Branch Manager',
                                    A_Number__c = 'A876543'),
                        new contact(FirstName = 'Market',
                                    LastName = 'Manager',
                                    Email = 'Test_MM@email.com',
                                    AccountID = Branches[3].id,
                                    Type__c = 'Market Manager',
                                    A_Number__c = 'A765432'),
                        new contact(FirstName = 'Tester',
                                    LastName = 'FA',
                                    Email = 'tester.FA@wellsfargoadvisors.com',
                                    AccountID = Branches[1].id,
                                    Type__c = 'FA',
                                    A_Number__c = 'A987654'),
                        new contact(FirstName = 'Tester',
                                    LastName = 'SDBK',
                                    Email = 'Test_SDBK@email.com',
                                    AccountID = Branches[4].id,
                                    Type__c = 'SDBK',
                                    A_Number__c = 'A654321')                                    
    
                        };                                                                                                        
                                    
    
    insert Managers;
    
    
    
    Main_Branch__c[] MainBranches = new Main_Branch__c[] {
                                       new Main_Branch__c(Name = 'PCG Main Branch1'),
                                       new Main_Branch__c(Name = 'PCG Main Branch2'),
                                       new Main_Branch__c(Name = 'WBS Main Branch1')                                       
                                       };
                                       
    insert MainBranches;
    
    List<Id> MainBranchIDs = new List<ID>();
    
    For (Main_Branch__c mb : MainBranches) {
        System.debug('Test class main branch name and id -------- ' + mb.Name + ' ' + mb.id);
        MainBranchIDs.add(mb.id);
    }
    
    Market_Complex__c MktComplex = new Market_Complex__c (Name = 'Test Market Complex');
    
    insert MktComplex;
    
    Sub_Supl_Complex__c SubComplex = new Sub_Supl_Complex__c(Name = 'Test Sub Complex');
    
    insert SubComplex;
    
    
    test.startTest();

    //assigning managers to branches
    Branches[0].Manager_Branch__c = Managers[0].id; //SF User PCG Branch Manager
    Branches[1].Manager_Branch__c = Managers[0].id; //SF User PCG Branch Manager
    Branches[2].Manager_Branch__c = Managers[1].id; //SF User PCG Main Branch Manager
    Branches[3].Manager_Branch__c = Managers[3].id; //Not a SF User
    //Branches[4].Manager_Branch__c = Managers[4].id; //Not a SF User
    
    update Branches; //this should create sharing records on branches for their managers if the manager is a SF user
    
    //should be 3 branch sharing records. 2 for Manager[0] on Branch[0 & 1], 1 for Manager[1] on Branch[2]
    //AccountShare[] branchShares = [SELECT AccountID, UserOrGroupID FROM AccountShare WHERE AccountID IN: BranchIDs AND UserOrGroupID IN: ManagerUserIDs];
                 
    //system.assertequals(branchShares.size(),3);
    
    //assigning branches main branches without main branch managers
    Branches[0].Main_Branch__c = MainBranches[0].id;
    Branches[1].Main_Branch__c = MainBranches[0].id;
    Branches[2].Main_Branch__c = MainBranches[1].id;
    //Branches[4].Main_Branch__c = MainBranches[2].id;
    
    System.debug('Test class assigning branches main branches ----------- ');
    
    update Branches; //this should create sharing records on the main branches for the 3 managers who are SF users
    
    
    //----------assign main branch managers
    MainBranches[0].Manager_Main_Branch__c = Managers[0].id;
    MainBranches[1].Manager_Main_Branch__c = Managers[1].id;
    MainBranches[2].Manager_Main_Branch__c = Managers[4].id;
    
    update MainBranches; //this should create main branch and branch sharing records
    
    
    //reassign manager of main branch 2;
    MainBranches[2].Manager_Main_Branch__c = Managers[3].id;
    
    update MainBranches[0];
    
    //assign all branches a sub complex
    Branches[0].Sub_Supl_Complex_Branch__c = SubComplex.id;
    Branches[1].Sub_Supl_Complex_Branch__c = SubComplex.id;
    Branches[2].Sub_Supl_Complex_Branch__c = SubComplex.id;
    
    update Branches; //nothing happens because sub complex doesn't have a manager yet
    
    //assign sub complex a manager who is a sf user
    SubComplex.Manager_Sub_Supl_Complex__c = Managers[0].id;
    
    update SubComplex;

    //every branch and main branch under the sub complex can be accessed by the sub complex manager
    //there should be 4 branch share records
    //branchShares = [SELECT AccountID, UserOrGroupID FROM AccountShare WHERE UserOrGroupID =: ManagerUserIDs[1]];
    
    //System.debug('Test class branch shares ----------- ' + branchShares);
    
    //system.assertequals(branchShares.size(),3);
    
    //there should be 3 main branch share records
    //Main_Branch__Share[] MainbranchShares = [SELECT ParentID, UserOrGroupID FROM Main_Branch__Share WHERE UserOrGroupID =: ManagerUserIDs[1]];
    
    //System.debug('Test class Main branch shares ----------- ' + MainbranchShares); 
    
    //system.assertequals(mainbranchShares.size(),2);
    
    //assign all branches a Mkt complex
    Branches[0].Market_Complex_Branch__c = MktComplex.id;
    Branches[1].Market_Complex_Branch__c = MktComplex.id;
    Branches[2].Market_Complex_Branch__c = MktComplex.id;

    
    update Branches;
    
    //assign mkt complex a manager who is a sf user
    MktComplex.Manager_Market_Complex__c = Managers[2].id;
    
    update MktComplex;
    
    //AccountShare[] branchShares = [SELECT AccountID, UserOrGroupID FROM AccountShare WHERE UserOrGroupID =: ManagerUserIDs[0]];
    
    //system.assertequals(branchShares.size(),3);

    test.StopTest();

  }
  
static testMethod void testManagersAccess2() {

    Account[] Branches = new Account[]{
                            new Account(Name = 'PCG Branch 1', Active__c=True),
                            new Account(Name = 'PCG Branch 2', Active__c=True),
                            new Account(Name = 'PCG Branch 3', Active__c=True),                            
                            new Account(Name = 'PCG Branch PF', Active__c=True),
                            new Account(Name = 'WBS Branch', Active__c=True)                            
                            };
        
    insert Branches;
    

    
    List<Id> BranchIDs = new List<ID>();
    
    For (Account b : Branches) {
        System.debug('Test class branch name and id -------- ' + b.Name + ' ' + b.id);
        BranchIDs.add(b.id);
    }

    //get the user id for the altoona main branch manager
    
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
    userMBM.ProfileId = '00e50000000z2sU'; //PCG Branch manager Profile
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
    
    //stage user: SDBK
    User userSDBK = new User();
    userSDBK.Username = 'Test_user_SDBK@test.com';
    userSDBK.LastName = 'Test_SDBK_name';
    userSDBK.ProfileId = '00e50000000z6nI'; //sandbox WBS RBM & SDBK Profile '00eP0000000QOS1' //production WBS RBM & SDBK Profile '00e50000000z6nI'
    userSDBK.Alias = 'tstSDBK';
    userSDBK.Email = 'Test_SDBK@email.com';
    userSDBK.CommunityNickname = 'Test_SDBK_nickname';
    userSDBK.TimeZoneSidKey = 'GMT';
    userSDBK.LocaleSidKey = 'en_US';
    userSDBK.LanguageLocaleKey = 'en_US';
    userSDBK.EmailEncodingKey = 'ISO-8859-1';
    userSDBK.MobilePhone = '+1 999-999-9999';
    userSDBK.AU__c = '0034567';
    userSDBK.EmployeeNumber = '3456789';
    
    insert userSDBK;     
      
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
                                    AccountID = Branches[2].id,
                                    Type__c = 'Branch Manager',
                                    A_Number__c = 'A876543'),
                        new contact(FirstName = 'Market',
                                    LastName = 'Manager',
                                    Email = 'Test_MM@email.com',
                                    AccountID = Branches[3].id,
                                    Type__c = 'Market Manager',
                                    A_Number__c = 'A765432'),
                        new contact(FirstName = 'Tester',
                                    LastName = 'FA',
                                    Email = 'tester.FA@wellsfargoadvisors.com',
                                    AccountID = Branches[1].id,
                                    Type__c = 'FA',
                                    A_Number__c = 'A987654'),
                        new contact(FirstName = 'Tester',
                                    LastName = 'SDBK',
                                    Email = 'Test_SDBK@email.com',
                                    AccountID = Branches[4].id,
                                    Type__c = 'SDBK',
                                    A_Number__c = 'A654321')                                    
    
                        };                                                                                                        
                                    
    
    insert Managers;
    

    Main_Branch__c[] MainBranches = new Main_Branch__c[] {
                                       new Main_Branch__c(Name = 'PCG Main Branch1'),
                                       new Main_Branch__c(Name = 'PCG Main Branch2'),
                                       new Main_Branch__c(Name = 'WBS Main Branch1')                                       
                                       };
                                       
    insert MainBranches;
    
    List<Id> MainBranchIDs = new List<ID>();
    
    For (Main_Branch__c mb : MainBranches) {
        System.debug('Test class main branch name and id -------- ' + mb.Name + ' ' + mb.id);
        MainBranchIDs.add(mb.id);
    }
    
    test.startTest();
    
    //assigning managers to branches
    Branches[0].Manager_Branch__c = Managers[0].id; //SF User PCG Branch Manager
    Branches[1].Manager_Branch__c = Managers[0].id; //SF User PCG Branch Manager
    Branches[2].Manager_Branch__c = Managers[1].id; //SF User PCG Main Branch Manager
    Branches[3].Manager_Branch__c = Managers[3].id; //Not a SF User
    Branches[4].Manager_Branch__c = Managers[4].id; //Not a SF User
    
    update Branches; //this should create sharing records on branches for their managers if the manager is a SF user
    
    //should be 3 branch sharing records. 2 for Manager[0] on Branch[0 & 1], 1 for Manager[1] on Branch[2]
    //AccountShare[] branchShares = [SELECT AccountID, UserOrGroupID FROM AccountShare WHERE AccountID IN: BranchIDs AND UserOrGroupID IN: ManagerUserIDs];
                 
    //system.assertequals(branchShares.size(),3);
    
    //assigning branches main branches without main branch managers
    Branches[0].Main_Branch__c = MainBranches[0].id;
    Branches[1].Main_Branch__c = MainBranches[0].id;
    Branches[2].Main_Branch__c = MainBranches[1].id;
    Branches[4].Main_Branch__c = MainBranches[2].id;
    
    System.debug('Test class assigning branches main branches ----------- ');
    
    update Branches; //this should create sharing records on the main branches for the 3 managers who are SF users
    
    //----------assign main branch managers
    MainBranches[0].Manager_Main_Branch__c = Managers[0].id;
    MainBranches[1].Manager_Main_Branch__c = Managers[1].id;
    MainBranches[2].Manager_Main_Branch__c = Managers[4].id;
    
    update MainBranches; //this should create main branch and branch sharing records
        
    Region__c Region = new Region__c (Name = 'Test Region');
    
    insert Region;

    //assign wbs branch a region with SDBK
    Branches[4].Region_Branch__c = Region.ID;    
    
    update Branches[4];
        
    Region.Senior_Director_of_Brokerage_SDBK__c = Managers[4].id;
    Region.Senior_Director_of_Brokerage_Email__c = Managers[4].Email;
    
    update Region;
    
    //assign sub complex a manager who is a sf user
    Region.Senior_Director_of_Brokerage_SDBK__c = Managers[3].id;
    Region.Senior_Director_of_Brokerage_Email__c = Managers[3].Email;
    
    update Region;
    
    ApexBasedSharingCls.GetManagerIDsOnBranch(Branches[0].id);
    ApexBasedSharingCls.GetManagerIDsOnMainBranch(MainBranches[0].id);
}
}