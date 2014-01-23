global Class ScheduleIBDCTasksForNewHires implements Schedulable {
    
    //schedule IBDC tasks to be assigned on Tuesdays at 6 pm
    //class will check for all efforts marked hired that tuesday or the Monday before
    
    global void execute(SchedulableContext sc) {

        system.debug('----------Schedule IBDC Intro Tasking on New FAs--------------');
        
        Date DateEffortMarkedHired = system.today().adddays(-7);
        
        system.debug('DateEffortMarkedHired var ---------- ' + DateEffortMarkedHired);
        
        IBDCTasksForNewHires.AssignIBDCTasksOnClick(DateEffortMarkedHired);
        
    
    }
}