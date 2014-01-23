trigger CheckIfAttendeeExists on SFDC_Attendance__c (before Insert) {

//this trigger will fire before any attendance record is created. It will check to see if 
//an attendance record for the contact or effort on the new attendance record already exists for the event

    Set <ID> Attendees = new Set <ID>();
    Set <ID> SpecEventID = new Set <ID>();
 
    List <SFDC_Attendance__c> attendeeList = new List <SFDC_Attendance__c>();
    
    For (SFDC_Attendance__c a : trigger.new) {//loop through trigger
 
        //if (a.RecordTypeID == '01250000000UIbu'){//don't include Diversity Pilot Record Types
            //}
            
            SpecEventID.Add(a.Special_Event__c);
            
            if (a.attendee__c != null) {//if the attendee field is filled attendance must be for contact
                
                Attendees.add(a.attendee__c);
                
            } else if (a.Effort_Name__c != null) {// if effort name field is filled attendance must be for effort
                
                Attendees.add(a.Effort_Name__c);
                
            } else if (a.Prospect__c != null) {
            
                Attendees.add(a.Prospect__c);
            
            }
        
    }
             
    system.debug('Attendees ' + attendees);
    system.debug('Events ' + SpecEventID);
    
    If (Attendees.size() > 0) { 
        //query a list of all attendance records that have the same event id
        AttendeeList = [SELECT  Special_Event__c, Prospect__c, Attendee__c, Effort_Name__c FROM SFDC_Attendance__c 
        WHERE Special_Event__c IN: SpecEventID AND (Attendee__c In: Attendees OR Effort_Name__c In: Attendees OR Prospect__c In: Attendees)]; 
        
    } 

    if (Attendeelist.size() > 0) {
        For (SFDC_Attendance__c a : trigger.new) {
            For (SFDC_Attendance__c att : AttendeeList) {
                If (a.Special_Event__c == att.Special_Event__c && (( a.Attendee__c != null && att.Attendee__c != null
                && a.Attendee__c == att.Attendee__c) || (a.Effort_Name__c != null && att.Effort_Name__c != null
                && a.Effort_Name__c == att.Effort_Name__c) || (a.Prospect__c != null && att.Prospect__c != null
                && a.Prospect__c == att.Prospect__c)) ){
                    a.addError('This FA is Already Attending');
                }
            }
        }
    }


}