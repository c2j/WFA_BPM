/**************************************************************************************************
 * Name: ClsPerformanceSummaryExt
 * Object: Contact
 * Author: Keen Xu
 * Create Date: 2013-05-31
 * Modify History: 
 * 2013-05-31    Keen	Created
***************************************************************************************************/
public class ClsPerformanceSummaryExt { 
	public Contact contact {get;set;}
	
	public ClsPerformanceSummaryExt(){
	}
	
	public ClsPerformanceSummaryExt(ApexPages.StandardController controller){
        this.contact = (Contact)controller.getRecord();
        getPerformanceSummaryList();
	}
	
	public List<ClsPerformanceSummaryEntity> psList {get;set;}
	
	//Return a list of Performance Summary associated with the contact
	public void getPerformanceSummaryList(){
		psList = new List<ClsPerformanceSummaryEntity>();
		//Get the Performance History and the details 
		List<Performance_History__c> phList = new List<Performance_History__c>([SELECT Contact__r.Id, Id, Name, Production_Year__c, Production_YTD__c, 
			(SELECT Id, Name, Production_MTD__c, Production_YTD__c FROM Performance_History_Details__r) 
			FROM Performance_History__c 
			WHERE Contact__r.Id =:contact.Id ORDER BY Production_Year__c DESC LIMIT 2]);
		system.debug('*** Performance history List for Production Metrics: ' + phList);
		
		for(Performance_History__c ph:phList){
			//Create the ClsPerformanceSummaryEntity
			ClsPerformanceSummaryEntity entity = new ClsPerformanceSummaryEntity();
			entity.year = Integer.valueOf(ph.Production_Year__c);
			entity.totalProduction = ph.Production_YTD__c;
			entity.id = ph.Id;
			
			List<Performance_History_Detail__c> phDetailList = ph.Performance_History_Details__r;
			for(Performance_History_Detail__c phDetail:phDetailList){
				if(phDetail.Name == '1'|| phDetail.Name == '01'){
					entity.janProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '2' || phDetail.Name == '02'){
					entity.febProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '3' || phDetail.Name == '03'){
					entity.marProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '4' || phDetail.Name == '04'){
					entity.aprProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '5' || phDetail.Name == '05'){
					entity.mayProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '6' || phDetail.Name == '06'){
					entity.junProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '7' || phDetail.Name == '07'){
					entity.julProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '8' || phDetail.Name == '08'){
					entity.augProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '9' || phDetail.Name == '09'){
					entity.sepProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '10'){
					entity.octProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '11'){
					entity.novProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
				else if(phDetail.Name == '12'){
					entity.decProduction = getDefaultIfNull(phDetail.Production_MTD__c);
				}
			}
			
			psList.add(entity);
		}
		psList.sort();
	}
	
	//Return 0 if it's null
	private Decimal getDefaultIfNull(Decimal data){
		if(data == null){
			return 0;
		}
		else{
			return data;
		}
	}
}