public with sharing class vfOtherActiveEffortsCtrlr {

    public ID CrntEffortID {get;set;}
    public ID FATalentID {get;set;}
    public String CrntEffortChannel {get;set;}
    public List<Opportunity> ActiveEfforts{get;set;}
    public String EffortCmts {get;set;}
    
    public vfOtherActiveEffortsCtrlr() {
        ID CrntEffortID =  ApexPages.currentPage().getParameters().get('id');
        
        Opportunity e = [SELECT FA_Talent_Name__c, Channel__c FROM Opportunity WHERE ID =: CrntEffortID];
        
        FATalentID = e.FA_Talent_Name__c;

        ActiveEfforts = [SELECT Name, CloseDate, StageName, Branch_Name__c, Channel__c, Amount, AUM__c, Recent_Activities_Information__c FROM Opportunity WHERE FA_Talent_Name__c =: FATalentID AND 
                            Inactive__c = False AND Inactive_FiNet__c = 'False' AND Channel__c !=: e.Channel__c];
        
                    
        system.debug('Active Efforts ------- ' + ActiveEfforts);
        
    }


}