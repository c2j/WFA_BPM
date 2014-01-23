/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest()
private class TestLeadRoutingAssignment {

	static Lead ext;

    static testMethod void myUnitTest() {
             
      
        //stage channel
        Channel__c chnl = new Channel__c();
        chnl.Name = 'PCG';
        
        insert chnl;
      
        //stage branches
        Account branch = new Account();
        branch.Name = 'Test Branch 1';
        branch.Branch_AddressZip__c = '55431';
        branch.Channel_Branch__c = chnl.Id;
        
        insert branch;
        
        //stage fa
        Contact fa1 = new Contact();
        fa1.FirstName = 'Test';
        fa1.LastName = 'FA1';
        fa1.AccountId = branch.Id;
        fa1.Type__c = 'Financial Consultant';
        fa1.Professional_Designation_s__c = 'Top Performer';
        fa1.Premier_Advisor__c = 'Yes';
        fa1.Allocation_Advisors_Rank__c = 1;
        fa1.X2011_Business_Plan_Submitted__c = 'Yes';
        fa1.Termination_Date__c = null;
        fa1.X2011_FA_Selection_BPs__c = 3;
        fa1.A_Number__c = '1';
        
        insert fa1; 
        
        System.Debug('MAX BP 1: ' + fa1.Max_PCG_FA_Selection_BPs__c);
            
        Contact fa2 = new Contact();
        fa2.FirstName = 'Test';
        fa2.LastName = 'FA2';
        fa2.AccountId = branch.Id;
        fa2.Type__c = 'Financial Consultant';
        fa2.Professional_Designation_s__c = 'Top Performer';
        fa2.Premier_Advisor__c = 'Yes';
        fa2.Allocation_Advisors_Rank__c = 1;
        fa2.X2011_Business_Plan_Submitted__c = 'Yes';
        fa2.Termination_Date__c = null;
        fa2.X2011_FA_Selection_BPs__c = 3;
        fa2.A_Number__c = '2';
        
        insert fa2;
        
        System.Debug('MAX BP 2: ' + fa2.Max_PCG_FA_Selection_BPs__c);
        
        Contact fa3 = new Contact();
        fa3.FirstName = 'Test';
        fa3.LastName = 'FA3';
        fa3.AccountId = branch.Id;
        fa3.Type__c = 'Financial Consultant';
        fa3.Professional_Designation_s__c = 'Top Performer';
        fa3.Premier_Advisor__c = 'Yes';
        fa3.Allocation_Advisors_Rank__c = 1;
        fa3.X2011_Business_Plan_Submitted__c = 'Yes';
        fa3.Termination_Date__c = null;
        fa3.X2011_FA_Selection_BPs__c = 3;
        fa3.A_Number__c = '3';
        
        insert fa3;
        
        System.Debug('MAX BP 3: ' + fa3.Max_PCG_FA_Selection_BPs__c);
                   
        WBS_Store__c st1 = new WBS_Store__c();
        st1.Name = 'Test Store';
        st1.Store_AU__c = '9514';
        st1.Store_City__c = 'Minneapolis';
        st1.Store_State__c = 'MN';
        st1.Store_ZIP__c = '55407';
        
        insert st1;
        
        WBS_Store_Member__c stm1 = new WBS_Store_Member__c();
        stm1.WBS_Store__c = st1.Id;
        stm1.FA_Name__c = fa1.Id;

        insert stm1;     
        
        WBS_Store__c st2 = new WBS_Store__c();
        st2.Name = 'Test Store 2';
        st2.Store_AU__c = '';
        st2.Store_City__c = 'Bloomington';
        st2.Store_State__c = 'MN';
        st2.Store_ZIP__c = '55431';
        
        insert st2;
        
        WBS_Store_Member__c stm2 = new WBS_Store_Member__c();
        stm2.WBS_Store__c = st2.Id;
        stm2.FA_Name__c = fa2.Id;

        insert stm2;  
        
        WBS_Store__c st3 = new WBS_Store__c();
        st3.Name = 'Test Store 3';
        st3.Store_AU__c = '';
        st3.Store_City__c = 'Bloomington';
        st3.Store_State__c = 'MN';
        st3.Store_ZIP__c = '55431';
        
        insert st3;
        
        WBS_Store_Member__c stm3 = new WBS_Store_Member__c();
        stm3.WBS_Store__c = st3.Id;
        stm3.FA_Name__c = fa3.Id;

        insert stm3;    
        
        //stage geopointe functionality=================================
        //pcg geolocation staging=======================================
        geopointe.API.radialSearchResult testResultObjectPCG = new geopointe.API.radialSearchResult();        
                     
        List<string> tmpListPCG = new list<string>();
            tmpListPCG.add(fa1.id);
            tmpListPCG.add(fa2.id);
            tmpListPCG.add(fa3.id);
            
        testResultObjectPCG.recordsInDistanceOrder = tmpListPCG;
        
        Map<string, double> tmpMapPCG = new Map<string, double>();
            tmpMapPCG.put(fa1.id, 20);
            tmpMapPCG.put(fa2.id, 45);
            tmpMapPCG.put(fa3.id, 90);
        
        testResultObjectPCG.recordsByDistance = tmpMapPCG; 
        
        testResultObjectPCG.recordCount = 3;  
        
        LeadRoutingAssignmentPCG.resultRadialSearch = testResultObjectPCG; 
        
        //wbs geolocation staging=======================================
        geopointe.API.radialSearchResult testResultObjectWBS = new geopointe.API.radialSearchResult();
        
        List<string> tmpListWBS = new list<string>();
            tmpListWBS.add(stm1.id);
            tmpListWBS.add(stm2.id);
            tmpListWBS.add(stm3.id);
            
        testResultObjectWBS.recordsInDistanceOrder = tmpListWBS;
        
        Map<string, double> tmpMapWBS = new Map<string, double>();
            tmpMapWBS.put(stm1.id, 20);
            tmpMapWBS.put(stm2.id, 45);
            tmpMapWBS.put(stm3.id, 90);
        
        testResultObjectWBS.recordsByDistance = tmpMapWBS; 
        
        testResultObjectWBS.recordCount = 3; 
        
        LeadRoutingAssignmentWBS.resultRadialSearch = testResultObjectWBS;
        //==============================================================
        
        //stage arrowpointe geolocation record: FA
        geopointe__Geocode__c geoFA1 = new geopointe__Geocode__c();
        geoFA1.geopointe__Parent_Record_ID__c = fa1.id;
        
        insert geoFA1;
        
        geopointe__Geocode__c geoFA2 = new geopointe__Geocode__c();
        geoFA2.geopointe__Parent_Record_ID__c = fa2.id;
        
        insert geoFA2;
        
        geopointe__Geocode__c geoFA3 = new geopointe__Geocode__c();
        geoFA3.geopointe__Parent_Record_ID__c = fa3.id;
        
        insert geoFA3;
            
        //pcg channel==================================================   
        //stage pcg lead / lead assignment history
        Lead ldpcg = new Lead();
        ldpcg.LastName = 'Test';
        ldpcg.Company = 'Test Co';
        ldpcg.Status = 'Open';
        ldpcg.Response_Want_Offer__c = TRUE; 
        ldpcg.Remove_From_Future_Mailings__c = FALSE;
        ldpcg.Response_No_FA_Call__c = FALSE;      
        ldpcg.Channel__c = 'PCG';     
        
        insert ldpcg;        
        
        //stage arrowpointe geolocation record: FA
        geopointe__Geocode__c geoLdpcg = new geopointe__Geocode__c();
        geoLdpcg.geopointe__Parent_Record_ID__c = ldpcg.id;
        
        insert geoLdpcg;         
        
        //update lead - geocode
        ldpcg.geopointe__Geocode__c = geoLdpcg.id;
        ldpcg.Assigned_FA__c = fa1.Id;
        
        update ldpcg;        
        
        Lead_Assignment_History__c lah1 = new Lead_Assignment_History__c();
        lah1.Lead__c = ldpcg.Id;
        lah1.Assigned_FA__c = fa1.Id;
        
        insert lah1;
                      
        //update lead - reassign
        ldpcg.Reassign_Lead__c = TRUE;
        ldpcg.Reason_for_Reassignment__c = 'Test';
        //ldpcg.Assigned_FA__c = fa1.Id;
        
        update ldpcg;
        
        
        Lead_Assignment_History__c lah2 = new Lead_Assignment_History__c();
        lah2.Lead__c = ldpcg.Id;
        lah2.Assigned_FA__c = fa2.Id;
        
        insert lah2;
        
        lah1.Reason_for_Reassignment__c = 'Test';
        
        update lah1;
        
        //wbs channel==================================================
        //stage wbs lead / lead assignment history
        Lead ldwbs = new Lead();
        ldwbs.LastName = 'Test';
        ldwbs.Company = 'Test Co';
        ldwbs.Status = 'Open';
        ldwbs.Response_Want_Offer__c = TRUE;
        ldwbs.Store_of_Patronage_ID__c = '9514';
        ldwbs.Channel__c = 'WBS';
                    
        insert ldwbs;  
        
        //stage arrowpointe geolocation record: FA
        geopointe__Geocode__c geoLdwbs = new geopointe__Geocode__c();
        geoLdwbs.geopointe__Parent_Record_ID__c = ldwbs.id;
        
        insert geoLdwbs;
                
        //update lead - geocode
        ldwbs.geopointe__Geocode__c = geoLdwbs.id; 
        ldwbs.Assigned_FA__c = fa1.Id;
        
        update ldwbs;         
        
        Lead_Assignment_History__c lah3 = new Lead_Assignment_History__c();
        lah3.Lead__c = ldwbs.Id;
        lah3.Assigned_FA__c = fa1.Id;
        
        insert lah3;
        
        //update lead - reassign
        ldwbs.Reassign_Lead__c = TRUE;
        ldwbs.Reason_for_Reassignment__c = 'Test';
                        
        update ldwbs;        
        
        Lead_Assignment_History__c lah4 = new Lead_Assignment_History__c();
        lah4.Lead__c = ldwbs.Id;
        lah4.Assigned_FA__c = fa2.Id;
        
        insert lah4;
        
        lah3.Reason_for_Reassignment__c = 'Test';
        
        update lah3;  
        
    }

}