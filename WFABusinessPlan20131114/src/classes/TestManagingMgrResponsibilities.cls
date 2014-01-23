@isTest

Public Class TestManagingMgrResponsibilities {

    
    static testMethod void TestAssignMgrResponsibilities() {
        
        //create user records for contacts
        
        User[] MgrUsers = new User[]{
        new User(Username = 'Test_user_BM1@test.com', LastName = 'Test_BM1_Name',ProfileId = '00e50000000z2sU',Alias = 'tstBM1',
        Email = 'Test_BM1@email.com',CommunityNickname = 'Test_BM1_nickname',TimeZoneSidKey = 'GMT',LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',MobilePhone = '+1 999-999-9999', AU__c = '0012345',
        EmployeeNumber = '1234567'),

        new User(Username = 'Test_user_BM2@test.com', LastName = 'Test_BM2_Name',ProfileId = '00e50000000z2sU',Alias = 'tstBM2',
        Email = 'Test_BM2@email.com',CommunityNickname = 'Test_BM2_nickname',TimeZoneSidKey = 'GMT',LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',MobilePhone = '+1 999-999-9999', AU__c = '0023456',
        EmployeeNumber = '2345678'),    
        
        new User(Username = 'Test_user_SCM@test.com', LastName = 'Test_SCM_Name',ProfileId = '00e50000000z2sU',Alias = 'tstSCM',
        Email = 'Test_SCM@email.com',CommunityNickname = 'Test_SCM_nickname',TimeZoneSidKey = 'GMT',LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',MobilePhone = '+1 999-999-9999', AU__c = '0034567',
        EmployeeNumber = '3456789'),    
        
        new User(Username = 'Test_user_MktMgr@test.com', LastName = 'Test_MktMgr_Name',ProfileId = '00e50000000z2sU',Alias = 'tstMktM',
        Email = 'Test_MktMgr@email.com',CommunityNickname = 'Test_MktMgr_nickname',TimeZoneSidKey = 'GMT',LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',MobilePhone = '+1 999-999-9999', AU__c = '0045678',
        EmployeeNumber = '4567890')
        
        };                    
        
        insert MgrUsers;
        
        
        //create branches, sub complex, and market
        Account branch = new Account(name='PCG Branch');
        insert branch;
        
        Sub_Supl_Complex__c sc = new Sub_Supl_Complex__c(name='PCG Sub Complex');
        insert sc;
        
        Market_Complex__c mc = new Market_Complex__c(name='PCG Mkt Complex');
        insert mc;
        
        Contact[] FAsAndMgrs = new Contact[] {
        new Contact(FirstName = 'Test', LastName ='BM1', Type__c='Branch Manager', Email='Test_BM1@email.com', AccountID=branch.id),
        new Contact(FirstName = 'Test', LastName ='BM2', Type__c='Branch Manager', Email='Test_BM2@email.com', AccountID=null),
        new Contact(FirstName = 'Test', LastName ='SCMgr', Type__c='Complex Manager', Email='Test_SCM@email.com', AccountID=branch.id),
        new Contact(FirstName = 'Test', LastName ='MktMgr', Type__c='Complex Manager', Email='Test_MktMgr@email.com', AccountID=branch.id),
        new Contact(FirstName = 'Test', LastName ='FAIT 1', Type__c='FA in Training', Min_Testing_TT__c = 0, TPM__c = 0, AccountID=branch.id),
        new Contact(FirstName = 'Test', LastName ='FAIT 2', Type__c='FA in Training', Min_Testing_TT__c = 0, TPM__c = 0, AccountID=branch.id)
        };
        
        insert FAsAndMgrs;

        
        //Update managers on branch, sub complex and market
        Main_Branch__c mb = new Main_Branch__c();
        mb.Manager_Main_Branch__c = FAsAndMgrs[0].id;
        insert mb;


        branch.manager_branch__c = FAsAndMgrs[0].id;
        branch.Market_Complex_Branch__c = mc.id;
        branch.Sub_Supl_Complex_Branch__c = sc.id;
        branch.Main_Branch__c = mb.id;
        
        update branch;
        
        sc.Manager_Sub_Supl_Complex__c = FAsAndMgrs[2].id;
        sc.Market_Complex__c = mc.id;
        
        update sc;
        
        mc.Manager_Market_Complex__c = FAsAndMgrs[3].id;
        
        update mc;
        
        
        test.startTest();
        
        //mark trainees below minimum
        FAsAndMgrs[4].TPM__c = 6;
        FAsAndMgrs[4].Min_Testing_TT__c = -100;
        FAsAndMgrs[4].Trainee_Segment__c = 'Below Minimum';
        
        FAsAndMgrs[5].TPM__c = 6;
        FAsAndMgrs[5].Min_Testing_TT__c = -100;
        FAsAndMgrs[5].Trainee_Segment__c = 'Below Minimum';
        
        update FAsAndMgrs;
        
        //test inserting responsibilities records for the first time
        Responsibilities__c[] r = [SELECT ID, Branch__c, FA_Name__c, OwnerID FROM Responsibilities__c WHERE Branch__c =: branch.id];
        
        system.assertequals(r.size(),2);
        system.assertequals(r[0].OwnerID, MgrUsers[0].id);
        
        //test updating fait trainee month when there are still outstanding responsibilities. Nothing should change with responsibilities
        FAsAndMgrs[4].TPM__c = 9;
        FAsAndMgrs[5].TPM__c = 9;
        
        update FAsAndMgrs;
        
        r = [SELECT ID, Branch__c, FA_Name__c, OwnerID FROM Responsibilities__c WHERE Branch__c =: branch.id];
        
        system.assertequals(r.size(),2); //no new responsibilities created
        system.assertequals(r[0].OwnerID, MgrUsers[0].id); //responsibilities still owned by branch manager
        
        //Test marking branch manager termed. responsibilities should be moved to sub complex manager
        FAsAndMgrs[0].termination_date__c = system.today();
        update FAsAndMgrs;
                
        r = [SELECT ID, Branch__c, FA_Name__c, OwnerID FROM Responsibilities__c WHERE Branch__c =: branch.id];
        
        system.assertequals(r.size(),2);
        system.assertequals(r[0].OwnerID, MgrUsers[2].id); //responsibilities owned by sub complex mgr now        
        
        system.debug('Sub complex mgr user id --------------- ' + mgrUsers[2].id);
        system.debug('Responsibilities owner id --------------- ' + r[0].OwnerId);
        system.debug('Mkt Mgr User id --------------- ' + MgrUsers[3].id);
        system.debug('BM1 User id --------------- ' + MgrUsers[0].id);
        system.debug('BM2 Mgr User id --------------- ' + MgrUsers[1].id);

        //test remove sub complex from branch. responsibilities should be reassigned to market mgr
        branch.Sub_Supl_Complex_Branch__c = null;
        branch.Manager_Branch__c = null;
        
        Update branch;
        
        r = [SELECT ID, Branch__c, FA_Name__c, OwnerID FROM Responsibilities__c WHERE Branch__c =: branch.id];
          
        system.assertequals(r.size(),2);
        system.assertequals(r[0].OwnerID, MgrUsers[3].id); //responsibilities owned by market mgr now           
        
        //test replace termed branch manager with new branch manger
        branch.Manager_Branch__c = FAsAndMgrs[1].id;
        update branch;
        
        r = [SELECT ID, Branch__c, FA_Name__c, OwnerID FROM Responsibilities__c WHERE Branch__c =: branch.id];
        
        system.assertequals(r.size(),2);
        system.assertequals(r[0].OwnerID, MgrUsers[1].id); //responsibilities owned by new branch mgr now     
        
        
        
        test.stopTest();
        
        }
        
}