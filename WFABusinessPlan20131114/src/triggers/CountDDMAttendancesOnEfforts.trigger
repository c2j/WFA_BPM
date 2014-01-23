trigger CountDDMAttendancesOnEfforts on SFDC_Attendance__c (after insert, after update) {

//counting Due Diligence attendances on efforts

Map<ID,Integer> DDMAttendanceCntMap = new Map<ID,Integer>();
List<SFDC_Attendance__c> DDMAttendances = new List<SFDC_Attendance__c>();
Set<ID> EffortIDs = new Set<ID>();
Set<ID> FATalentIDs = new Set<ID>();


for (SFDC_Attendance__c a: trigger.new) {
    
    if (a.RecordTypeId == '01250000000UJNp' && a.Effort_Name__c != null && a.Special_Event_Type__c == 'Recruiting' &&
    (trigger.isInsert || (trigger.isUpdate && a.status__c == 'Attended' && trigger.oldmap.get(a.id).status__c != 'Attended') ||
    (trigger.isUpdate && a.status__c != 'Attended' && trigger.oldmap.get(a.id).status__c == 'Attended'))) {
        
        //DDMAttendances.add(a);
        
        EffortIDs.add(a.Effort_Name__c);

    }

}

if (EffortIds.size() > 0) {
    
    Opportunity[] EffortsWithDDMAttendances;
    
    DDMAttendances = [SELECT ID, Effort_Name__c, Status__c FROM SFDC_Attendance__c WHERE RecordTypeID = '01250000000UJNp' 
                    AND Effort_Name__c IN : EffortIDs
                   ORDER BY Effort_Name__c ASC];
                   
   system.debug('DDM Attendances for trigger efforts ------------ ' + DDMAttendances.size() + ' / ' + DDMAttendances);


    //loop through all DDM Attendances where Effort Name field is not blank
    for (SFDC_Attendance__c a : DDMAttendances) {
        
        EffortIDs.add(a.Effort_Name__c);        
        
        if (!DDMAttendanceCntMap.keyset().contains(a.Effort_Name__c)) {
            if (a.Status__c == 'Attended') {        
                DDMAttendanceCntMap.put(a.Effort_Name__c, 1);
            } else {
                DDMAttendanceCntMap.put(a.Effort_Name__c, 0);
            }
            
        } else {
            DDMAttendanceCntMap.put(a.Effort_Name__c, DDMAttendanceCntMap.get(a.Effort_Name__c) + 1);
  
        }
    }
    
    //select all Efforts With Attendances being affected by trigger
    EffortsWithDDMAttendances = [SELECT ID, Fa_Talent_Name__c, Total_Number_of_DDM_Attendances__c FROM Opportunity WHERE ID IN: EffortIDs ];                 

    system.debug('newly created or update ddm attendances ----------- ' + DDMAttendanceCntMap.values().size() + ' / ' + DDMAttendanceCntMap.values());
    
    system.debug('Efforts with DDM Attendances before attendance count update--------- ' + EffortsWithDDMAttendances.size() + ' / ' + EffortsWithDDMAttendances);
    
    //update on the Effort the number of DDM Attendances associated with it
    for (Opportunity e: EffortsWithDDMAttendances) {
        if (DDMAttendanceCntMap.get(e.id) != null) {
            e.Total_Number_of_DDM_Attendances__c = DDMAttendanceCntMap.get(e.id);
        }
    
        //store FA Talent IDs
        FATalentIDs.add(e.Fa_Talent_Name__c);
   }
    
    //update efforts with new total ddm attendances count
    
    try {
        system.debug('FAs with DDM Attendances after attendance count update--------- ' + EffortsWithDDMAttendances.size() + ' / ' + EffortsWithDDMAttendances);
        
        update EffortsWithDDMAttendances;
        
    } catch (Exception e) {
        system.debug('Error occurred updating Effort DDM Attendances count on effort records --------------- ' + e.getMessage());
        throw new SFException('Error occurred updating Effort DDM Attendances count on Effort records. Please contact your system administrator.');
    }

    
    system.debug('IDs of FA Talents attending DDMs -------- ' + FATalentIDs.size() + ' / ' + FATalentIDs);
    
    Map<ID,FA_Talent__c> FATalents = new Map<ID,FA_Talent__c>([SELECT Total_Number_Of_DDM_Attendances__c FROM FA_Talent__c 
                                                                WHERE ID IN: FATalentIDs]);
    Set<ID> FATIds = new Set<ID>();
                   
    for (Opportunity e : [SELECT id, FA_Talent_Name__c, Total_Number_Of_DDM_Attendances__c FROM Opportunity WHERE FA_Talent_Name__c IN: FATalentIDs AND
                        Total_Number_Of_DDM_Attendances__c <> 0 AND Total_Number_Of_DDM_Attendances__c <> null ORDER BY FA_Talent_Name__c]) {
        
        system.debug('Current effort\'s ddm attendances count ---------- ' + e.id + ' / ' + e.Total_Number_Of_DDM_Attendances__c);
        
        if (!FATIds.contains(e.FA_Talent_Name__c)) {
            FATIds.add(e.FA_Talent_Name__c);
            FATalents.get(e.FA_Talent_Name__c).Total_Number_Of_DDM_Attendances__c = e.Total_Number_of_DDM_Attendances__c;
        } else {
            FATalents.get(e.FA_Talent_Name__c).Total_Number_Of_DDM_Attendances__c += e.Total_Number_of_DDM_Attendances__c;        
        }
        
        system.debug('Current FA Talent\'s ddm attendances count ---------- ' + FATalents.get(e.FA_Talent_Name__c).Total_Number_Of_DDM_Attendances__c);
    }        

    
    //update FA Talents with total DDM Attendances Count
    try {
        system.debug('FA Talents to update with DDM Attendances count --------- ' + FATalents.values().size() + ' / ' + FATalents.values());
        
        update FATalents.values();
        
    } catch (Exception e) {
        system.debug('Error occurred updating DDM Attendances Count on FA Talents --------------- ' + e.getMessage());
        throw new SFException('Error occurred updating DDM Attendances Count on FA Talents. Please contact your system administrator.');
    }
     
}

}