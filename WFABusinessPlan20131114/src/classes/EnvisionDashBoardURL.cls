public class EnvisionDashBoardURL
{
public String view{get; set;}
public String title1{get; set;}
public List<Contact> title{get; set;}
public EnvisionDashboardURL(ApexPages.StandardController controller) {

system.debug('Controller: ' + controller);

view=system.currentpagereference().getparameters().get('id');
system.debug('View: ' + view);

title=[select A_Number__c from Contact where Id=:view];
title1=title[0].A_Number__c;
    }
    


}