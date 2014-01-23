@isTest
private class testEnvisionDashBoardURL {

static testMethod void myUnitTest() {

    //create contact
    contact FA = new Contact(LastName = 'FA', FirstName = 'Test', A_Number__c = 'A123456');
    insert FA;
    
    
    PageReference EnvisionDB = Page.Envision_Dashboard;
    Test.setCurrentPage(EnvisionDB);
    
    ApexPages.currentpage().getParameters().put('id',FA.ID); //maps the contact's id to the label 'id' which is referenced in the controller
    
    
    //create new instance of the Controller extension EnvisionDashBoardURL
    EnvisionDashBoardURL envDB = new EnvisionDashBoardURL(New ApexPages.StandardController(FA));
    
    String DashBoardURL = EnvisionDB.getURL();
    
    system.debug('Dashboard URL: ' + DashBoardURL);
    system.assertequals('/apex/envision_dashboard?id='+FA.ID, DashBoardURL);

}
}