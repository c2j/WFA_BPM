global class BatchToUpdateFARankings implements Database.Batchable<sObject>, Database.stateful
{
    global string strqry;
    /*global BatchToUpdateFARankings (String q)
    {
        system.debug('query string q -------- ' + q);
        strqry=q;
    }*/
    
    global Database.Querylocator start (Database.Batchablecontext BC)
    {
        system.debug('-----------starting batch fa ranking-------------');
        
        system.debug('Query String strqry ------------ ' + strqry);
        system.debug('Queried FA Ranking rec ----------- ' + Database.getQueryLocator(strqry));
        
        return Database.getQueryLocator(strqry);
    }
    
    global static Map<ID, Integer> Rankby(String RankVal) {
    
    Map<ID, Integer> RankMap = new Map<ID, Integer>();
    Integer Rank = 1;
    //String yesterday = string.valueof(system.now().date().year()) + '-' + string.valueof(system.now().date().month()) + '-' + string.valueof(system.now().date().adddays(-1).day())
    
    String QueryString = 'SELECT ID, ' + RankVal + ' FROM Contact WHERE Channel__c = \'PCG\' AND Termination_Date__c = NULL ' + 
   'AND (Type__c = \'FA\' OR Type__c = \'FA in Training\' OR Type__c = \'Branch Manager\' OR Type__c = \'Branch Supervisor\' OR ' +
   'Type__c = \'Assistant Branch Manager\' OR Type__c = \'Complex Manager\') AND ' + RankVal + ' > 0 ' + 'ORDER BY ' + RankVal + ' DESC';

       
    Contact[] ProdFAs = Database.Query(QueryString);
    
    System.debug('Producing FAs to Rank ------------ ' + ProdFAs.size() + ' / ' + ProdFAs);
    
    RankMap.put(ProdFAs[0].ID, 1);
    
    
    For (Integer i = 1; i < ProdFAs.size(); i++) {

        if (RankVal == 'Production_YTD__c') {
            if (ProdFAs[i].Production_YTD__c < ProdFAs[i-1].Production_YTD__c) {
               Rank = i+1; 
            } 
        } else if (RankVal == 'Production_Yesterday__c') {
            if (ProdFAs[i].Production_Yesterday__c < ProdFAs[i-1].Production_Yesterday__c) {
                Rank = i+1;   
            }
        } else if (RankVal == 'Production_MTD__c') {
            if (ProdFAs[i].Production_MTD__c < ProdFAs[i-1].Production_MTD__c) {
                Rank = i+1;
            }
        } else if (RankVal == 'Annualized_Production__c') {
            if (ProdFAs[i].Annualized_Production__c < ProdFAs[i-1].Annualized_Production__c) {
                Rank = i+1;
            }
        }
                  
        RankMap.put(ProdFAs[i].ID, Rank); //map contact id to its rank  

    }

    return RankMap;
    }
    
    global void execute (Database.Batchablecontext BC, list<sObject> scope)
    {
    
    system.debug('-----------executing batch fa ranking-------------');
    
    Map<ID, Integer> YTDProdRank = new Map<ID, Integer>();
    Map<ID, Integer> MTDProdRank = new Map<ID, Integer>();
    Map<ID, Integer> YestProdRank = new Map<ID, Integer>();
    Map<ID, Integer> AnnProdRank = new Map<ID, Integer>();
    
    YTDProdRank = RankBy('Production_YTD__c');
    YestProdRank = RankBy('Production_Yesterday__c');
    AnnProdRank = RankBy('Annualized_Production__c');
    MTDProdRank = RankBy('Production_MTD__c');
    
    
    List<Ranking__c> FARanks = (List<Ranking__c>)scope;
    
    system.debug('FA Ranking records --------- ' + FARanks.size());
     
    for (integer i = 0; i < FARanks.size();i++) {
        
        FARanks[i].Prior_YTD_Production_Rank__c = FARanks[i].Current_YTD_Production_Rank__c;
        FARanks[i].Current_YTD_Production_Rank__c = YTDProdRank.get(FARanks[i].contact__c);
        
        FARanks[i].Prior_MTD_Production_Rank__c = FARanks[i].Current_MTD_Production_Rank__c;
        FARanks[i].Current_MTD_Production_Rank__c = MTDProdRank.get(FARanks[i].contact__c);
        
        FARanks[i].Prior_Yesterday_s_Production_Rank__c = FARanks[i].Current_Yesterday_s_Production_Rank__c;
        FARanks[i].Current_Yesterday_s_Production_Rank__c = YestProdRank.get(FARanks[i].contact__c);
        
        FARanks[i].Prior_Annualized_Production_Rank__c = FARanks[i].Current_Annualized_Production_Rank__c;
        FARanks[i].Current_Annualized_Production_Rank__c = AnnProdRank.get(FARanks[i].contact__c);
        
        YTDProdRank.remove(FARanks[i].Contact__c);
        MTDProdRank.remove(FARanks[i].Contact__c);
        YestProdRank.remove(FARanks[i].Contact__c);
        AnnProdRank.remove(FARanks[i].Contact__c);  
    
    }    
    
    update FARanks;
    //List<Database.SaveResult> UpdateRanks = Database.update(FARanks, false); //updates 10000 records
    
    }         

    global void finish(Database.Batchablecontext BC)
    {
     AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion. 
        
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('FA Rankings ' + a.Status);
       mail.setPlainTextBody
       ('The FA Rankings Job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    }
}