public with sharing class McLaganChartController {

	private final Account acc;
	List<McLagan__c> MCList = new List<McLagan__c>();
	public String firmList {get{if(firmList==null)firmList = '';return firmList;}set;}

	public McLaganChartController(ApexPages.StandardController stdcontroller) {
		this.acc = (Account)stdcontroller.getRecord();
		getMcLaganData();
	}
	
	public List<McLagan__c> getMcLaganData() {
		// Calculate Period to collect data for last 4 years
		List<String> StrList = new List<String>();
		String str = 'FY';
		Integer intgr = System.today().year() - 4;
		for(Integer i = System.today().year(); i>=intgr; i--){
			StrList.add(str+i.format().substring(i.format().length()-2));
		}
		
        MCList = [Select m.WFA_Branch_Revenue__c, m.WFA_Branch_FA__c, m.WFA_Branch_FAS__c, m.SystemModstamp, m.Related_Branch__c, m.Region__c, m.Region_Name__c, m.Period__c, m.PCT_Of_Other__c, m.PCT_Of_All__c, m.PCT_Of_All_FA__c, m.PCT_Of_All_FAS__c, m.OwnerId, m.Other_Firm_Revenue__c, m.Other_Firm_FA__c, m.Other_Firm_FAS__c, m.Name, m.Market__c, m.Market_Name__c, m.LastModifiedDate, m.LastModifiedById, m.LastActivityDate, m.IsDeleted, m.Id, m.Firm_List__c, m.FA_Rank__c, m.Division__c, m.Division_Name__c, m.CreatedDate, m.CreatedById, m.ConnectionSentId, m.ConnectionReceivedId, m.Complex__c, m.Complex_Name__c, m.Branch__c, m.Branch_Rank__c, m.Branch_Rank_FAS__c, m.Branch_Name__c, m.Branch_Count__c, m.Branch_Count_FA__c, m.Branch_Count_FAS__c, m.All_Firm_Revenue__c, m.All_Firm_FA__c, m.All_Firm_FAS__c From McLagan__c m where m.Related_Branch__c = :acc.id and Period__c IN: StrList ORDER BY Period__c ASC];
        if(MCList.isEmpty())
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'McLagan data is not currently available for this record.'));        
        System.debug('retrieve size list************************** '+MCList.size());
        return MCList;
    }
    
     
    public List<Data> getData() {
        return getChartData();
    }
    
    public List<Data> getChartData() {
    	List<Data> data = new List<Data>();
    	for(McLagan__c mcl: MCList){
    		if(mcl.Firm_List__c != null && mcl.Firm_List__c != '')
    			firmList = mcl.Firm_List__c;
    		data.add(new Data(mcl.Period__c,mcl.PCT_Of_All__c, mcl.PCT_Of_All_FAS__c, mcl.WFA_Branch_FA__c, mcl.Other_Firm_FA__c, mcl.PCT_Of_All_FA__c));
        }
        return data;
    }
    
    
    // Wrapper class 
    
    public class Data {
        public String name { get; set; }
        public Decimal Production_Share { get; set; }
        public Decimal FA_Share { get; set; }
        public Decimal WFA { get; set; }
        public Decimal Other_Firm { get; set; }
        public Decimal PCT_Of_All_FA { get; set; }
        
        
        public Data(String name, Decimal data1, Decimal data2, Decimal data3, Decimal data4, Decimal data5) {
            System.debug('*****************Name: '+name);
            System.debug('*****************Production Share: '+data1);
            System.debug('*****************FA Share: '+data2);
            System.debug('*****************WFA: '+data3);
            System.debug('*****************Other Firm: '+data4);
            System.debug('*****************PCT of All: '+data5);
            this.name = name;
            if(data1 != null){
            	this.Production_Share = data1;
            }else{
            	this.Production_Share = 0;
            }
            if(data2 != null){
            	this.FA_Share = data2;
            }else{
            	this.FA_Share = 0;
            }
            this.WFA = data3;
            if(this.WFA != null){
            	this.WFA = this.WFA/1000;
            }else{
            	this.WFA = 0;
            }
            this.Other_Firm = data4;
            if(this.Other_Firm != null){
            	this.Other_Firm = this.Other_Firm/1000;
            }else{
            	this.Other_Firm = 0;
            }
            this.PCT_Of_All_FA = data5;
        }
    }
}