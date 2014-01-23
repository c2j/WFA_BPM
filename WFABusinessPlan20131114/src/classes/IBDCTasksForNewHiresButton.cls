global class IBDCTasksForNewHiresButton {

    webservice static string AssignIBDCTasksOnClick(Date DateEffortMarkedHired) {
        
        String Result = IBDCTasksForNewHires.AssignIBDCTasksOnClick(DateEffortMarkedHired);
        
        return Result;
    }
}