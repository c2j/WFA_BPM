Public Class RankingFAs {


    public static void RankFAs(Set<ID> FAids) {
    
   /* Map<ID, Integer> YTDProdRank = new Map<ID, Integer>();
    Map<ID, Integer> MTDProdRank = new Map<ID, Integer>();
    Map<ID, Integer> YestProdRank = new Map<ID, Integer>();
    Map<ID, Integer> AnnProdRank = new Map<ID, Integer>();
    
    //Set<ID> ContactIDs = FAIds;
    
    Map<ID, Contact> FAsToRank = new Map<ID, Contact>(
    [SELECT Production_YTD__c FROM Contact WHERE ID IN : FAIds]);
    
    //Set<ID> FAids = FAsToRank.keyset();
    
    system.debug('FAsToRank Size -------------- ' + FAsToRank.size());
    
    If (FAsToRank.values().size() > 10000) {
        system.debug('--------------Sent to Batch Class-------------');
    
      string strquery='SELECT ID, Contact__c, Current_YTD_Production_Rank__c, Prior_YTD_Production_Rank__c, ' +
        'Current_MTD_Production_Rank__c, Prior_MTD_Production_Rank__c, ' +
        'Current_Yesterday_s_Production_Rank__c, Prior_Yesterday_s_Production_Rank__c, ' +
        'Current_Annualized_Production_Rank__c, Prior_Annualized_Production_Rank__c ' +
        'FROM Ranking__c WHERE Contact__c IN : FAIds';
        
      BatchToUpdateFARankings objBatchToUpdateFARankings = new BatchToUpdateFARankings(strquery);
      Database.executeBatch(objBatchToUpdateFARankings);
      
    } else {
        
        YTDProdRank = RankBy('Production_YTD__c'); //, FAIds);
        YestProdRank = RankBy('Production_Yesterday__c');//, FAIds);
        AnnProdRank = RankBy('Annualized_Production__c');//, FAIds);
        MTDProdRank = RankBy('Production_MTD__c');//, FAIds);
        
        RecordRankings(YTDProdRank, MTDProdRank, AnnProdRank, YestProdRank);

    }
    */
    }
    
    /*Public static Map<ID, Integer> RankBy(String RankVal) {//, Set<ID> FAIds) {
    
    /*Map<ID, Integer> RankMap = new Map<ID, Integer>();
    Integer Rank = 0;
    
    String QueryString = 'SELECT ID, ' + RankVal + ' FROM Contact WHERE Channel__c = \'PCG\' ' + 'AND Termination_Date__c = NULL ' + 
    'AND ' + RankVal + ' > 0 ' + 'ORDER BY ' + RankVal + ' DESC';
    
    //String QueryString = 'SELECT ID, ' + RankVal + ' FROM Contact WHERE ' + RankVal + ' > 0 ' + 
    //'AND ID IN : FAIds ORDER BY ' + RankVal + ' DESC';
       
    Contact[] ProdFAs = Database.Query(QueryString);
                         
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
        //index++;
        
        //System.debug('Name: Rank: ' + ProdFAs[i].Name + ': ' + Rank);            
        //System.debug('Name: Index: ' + ProdFAs[i].Name + ': ' + Index); 
    }

    //System.debug('Rank Map: ' + RankMap);
    
    return RankMap;
    }*/
    
    
    Public static void RecordRankings(Map<ID, Integer> YTDRank, Map<ID, Integer> MTDRank,
                                    Map<ID, Integer> AnnRank, Map<ID, Integer> YestRank) {

    /*
    //select a list of existing ranking records for the FAs who are being ranked
    Ranking__c[] FARanks = [SELECT ID, Contact__c, Current_YTD_Production_Rank__c, Prior_YTD_Production_Rank__c,
                        Current_MTD_Production_Rank__c, Prior_MTD_Production_Rank__c,
                        Current_Yesterday_s_Production_Rank__c, Prior_Yesterday_s_Production_Rank__c,
                        Current_Annualized_Production_Rank__c, Prior_Annualized_Production_Rank__c
                        FROM Ranking__c WHERE Contact__c IN : YTDRank.keyset() AND Terminated__c != 'Yes'];
    
    system.debug('FARanks size -------------- ' + FARanks.size());
    
    system.debug('Ln 105 Heap size --------------> ' + limits.getheapsize());   
     
    for (integer i = 0; i < FARanks.size();i++) {
    
        FARanks[i].Data_As_Of__c = System.now().date();
        
        FARanks[i].Prior_YTD_Production_Rank__c = FARanks[i].Current_YTD_Production_Rank__c;
        FARanks[i].Current_YTD_Production_Rank__c = YTDRank.get(FARanks[i].contact__c);
        
        FARanks[i].Prior_MTD_Production_Rank__c = FARanks[i].Current_MTD_Production_Rank__c;
        FARanks[i].Current_MTD_Production_Rank__c = MTDRank.get(FARanks[i].contact__c);
        
        FARanks[i].Prior_Yesterday_s_Production_Rank__c = FARanks[i].Current_Yesterday_s_Production_Rank__c;
        FARanks[i].Current_Yesterday_s_Production_Rank__c = YestRank.get(FARanks[i].contact__c);
        
        FARanks[i].Prior_Annualized_Production_Rank__c = FARanks[i].Current_Annualized_Production_Rank__c;
        FARanks[i].Current_Annualized_Production_Rank__c = AnnRank.get(FARanks[i].contact__c);
            
        YTDRank.remove(FARanks[i].Contact__c);
        MTDRank.remove(FARanks[i].Contact__c);
        YestRank.remove(FARanks[i].Contact__c);
        AnnRank.remove(FARanks[i].Contact__c);  
           

    }    
    Integer myDMLLimit = Limits.getLimitDMLRows();
    if (FARanks.size() < myDMLLimit) {
        update FARanks; //updates 10000 records
    }
    */
    }

            
    
   
 

}