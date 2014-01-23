global class IBDCTasksForCABOODCasesButton {

    webservice static string AssignIBDCCABOTasksOnClick(Date CaseCreatedDate, Date EndDate) {
    
        String Result = IBDCTasksForCABOODCases.AssignIBDCCABOTasksOnClick(CaseCreatedDate, EndDate);
        
        return Result;
    }
   
}