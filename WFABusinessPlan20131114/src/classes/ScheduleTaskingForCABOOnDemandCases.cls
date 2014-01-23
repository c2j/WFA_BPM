global class ScheduleTaskingForCABOOnDemandCases implements Schedulable {
     
    global void execute(SchedulableContext sc) {
        
        system.debug('----------Schedule CABO Tasking--------------');
        
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
          //              FROM CronTrigger WHERE Id = :sc.getTriggerId()];
                        
        Date CaseCreatedDate = system.Today().adddays(-7);
        
        IBDCTasksForCABOODCases.AssignIBDCCABOTasksOnClick(CaseCreatedDate, null);
        
    }
        
}