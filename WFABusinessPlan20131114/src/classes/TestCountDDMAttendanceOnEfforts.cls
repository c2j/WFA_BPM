@isTest

public class TestCountDDMAttendanceOnEfforts {

    static testMethod void testCountDDMAttendances() {
    
    Account branch = new Account();
    branch.Name = 'Test Branch';
    
    insert branch;
    
    Employing_Firm__c EF = new Employing_Firm__c();
    EF.Name = 'Test EF';
    
    insert EF;
    
    FA_Talent__c FT = new FA_talent__c();
    FT.Name = 'Test FA Talent';
    FT.FAI_Status__c = 'AV';
    FT.First_Name__c = 'Test';
    FT.Last_Name__c = 'FA Talent';
    FT.Employing_Firm__c = ef.id;
    FT.Total_Number_Of_DDM_Attendances__c = null;
    
    insert FT;
    
        //Create Effort
    
    Opportunity effort = new Opportunity();
    effort.name = 'Test Firm';
    effort.RecordTypeID = '01250000000UISS';
    effort.AccountID = branch.id;
    effort.closedate = date.newinstance(system.now().year(), 12,31);
    effort.stagename = 'Introduced Hiring Manager';
    effort.FA_Talent_Name__c = FT.Id;
    
    insert effort;
    
    //create 4 DDM event records
    List<SFDC_Special_Event__c> DDMs = new List<SFDC_Special_Event__c>();
    
    for (integer i = 0; i <4; i++) {
        SFDC_Special_Event__c DDM = new SFDC_Special_Event__c();
        DDM.Name = 'Test Due Diligence Meeting';
        DDM.RecordTypeID = '01250000000UJNk';
        DDM.Start_Date__c = date.newinstance(system.now().year(), 5,1);
        DDM.End_Date__c = date.newinstance(system.now().year(), 5,2);
        DDM.Type__c = 'Recruiting';
        
        DDMs.add(DDM);
    }
    
    insert DDMs;
    
    //create list of DDM Attendances
    List<SFDC_Attendance__c> DDMAttendances = new List<SFDC_Attendance__c>();
    
    ID DDMRecID;
    
    For (integer i = 0; i <2; i++) {
        if (i == 0) {
            DDMRecID = DDMs[0].id;
        } else { 
            DDMRecID = DDMS[1].id;
        }        
        SFDC_Attendance__c a = new SFDC_Attendance__c();
        a.RecordTypeID = '01250000000UJNp'; 
        a.Special_Event__c = DDMRecId;
        a.Status__c = 'Attended';
        a.Will_Spouse_Attend__c = 'No';
        a.Effort_Name__c = effort.id;
        
        DDMAttendances.add(a);
    }
    
    test.startTest();
    
    insert DDMAttendances;
    
    Opportunity Efforts = [SELECT ID, FA_Talent_Name__c, Total_Number_of_DDM_Attendances__c FROM Opportunity WHERE ID =: Effort.ID];
    
    system.assertequals(Efforts.Total_Number_of_DDM_Attendances__c, 2);
    
    FA_Talent__c FATalent = [SELECT Total_Number_Of_DDM_Attendances__c FROM FA_Talent__c WHERE ID =: Efforts.FA_talent_Name__c];
    
    system.assertequals(FATalent.Total_Number_of_DDM_Attendances__c, 2);  
        

    //change one of the attendances's status to Accepted, which should decrease the Total DDM count on the effort and fa talent
    DDMAttendances[0].status__c = 'Accepted';
  
    update DDMAttendances;
    
    Efforts = [SELECT ID, FA_Talent_Name__c, Total_Number_of_DDM_Attendances__c FROM Opportunity WHERE ID =: Effort.ID];
    
    system.assertequals(Efforts.Total_Number_of_DDM_Attendances__c, 1);
    
    FATalent = [SELECT Total_Number_Of_DDM_Attendances__c FROM FA_Talent__c WHERE ID =: Efforts.FA_talent_Name__c];
    
    system.assertequals(FATalent.Total_Number_of_DDM_Attendances__c, 1);  
    
    test.stopTest();
        
    }
}