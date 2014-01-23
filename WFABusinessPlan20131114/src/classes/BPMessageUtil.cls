/**************************************************************************************************
 * Purpose: Add message to the visual force page
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-10-28
 * Modify History:
 * Keen    2013-10-28    Created
***************************************************************************************************/
global class BPMessageUtil {

	//Create Message object with Severity = INFO
    private static ApexPages.Message getInfoMessage(String message){
        return new ApexPages.Message(ApexPages.severity.INFO, message);
    }
    //Create Message object with Severity = ERROR
    private static ApexPages.Message getErrorMessage(String message){
        return new ApexPages.Message(ApexPages.severity.ERROR, message);
    }
    
    //Add INFO message to the page
    public static void addInfoMessage(String message){
        ApexPages.addMessage(getInfoMessage(message));
    }
    
    //Add ERROR message to the page
    public static void addErrorMessage(String message){
        ApexPages.addMessage(getErrorMessage(message));
    }

}