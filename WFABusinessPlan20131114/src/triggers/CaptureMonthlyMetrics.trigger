/**************************************************************************************************
 * Name: CaptureMonthlyMetrics
 * Object: Contact
 * Purpose: Capture the monthly production, MBO, Trainee metrics into Performance History and Performance History Detail
 * Author: Keen Xu
 * Create Date: 2013-05-31
 * Modify History: 
 * 2013-05-31    Keen	Created
***************************************************************************************************/
trigger CaptureMonthlyMetrics on Contact (after insert, after update) {
	
	if(trigger.isAfter)
	{
		if(trigger.isUpdate || trigger.isInsert){
			//Create the list for DML operation
			Map<String, Performance_History__c> phToUpdateMap = new Map<String, Performance_History__c>();
			Map<String, Performance_History__c> phToInsertMap = new Map<String, Performance_History__c>();
			List<Performance_History_Detail__c> phDetailToUpdateList = new List<Performance_History_Detail__c>();
			List<Performance_History_Detail__c> phDetailToInsertList = new List<Performance_History_Detail__c>();
			
			List<Contact> newContactList = trigger.new;

			if(newContactList.isEmpty()){
				system.debug('*** the contact list is empty.');
				return;
			}
			
			//Get all the contacts that needs to capture their performance data
			Map<Id, Contact> affectedContactSet = new Map<Id, Contact>();
			Set<String> asofDateMonthSet = new Set<String>();
			Set<String> asofDateYearSet = new Set<String>();
			if(trigger.isUpdate){
				for(Contact newContact:newContactList){
					Contact oldContact = trigger.oldMap.get(newContact.Id);
					//Check to see if the data we'd like to capture has been changed
					//1. Production Metrics
					if(newContact.Production_Data_As_Of_Date__c != oldContact.Production_Data_As_Of_Date__c 
					|| newContact.Production_YTD__c != oldContact.Production_YTD__c 
					|| newContact.Production_MTD__c != oldContact.Production_MTD__c
					//2. MBO Metrics
					|| newContact.MBO_Metrics_As_of_Date__c != oldContact.MBO_Metrics_As_of_Date__c
					|| newContact.New_Key_HHs__c != oldContact.New_Key_HHs__c
					|| newContact.Compensable_Loans_YTD__c != oldContact.Compensable_Loans_YTD__c
					|| newContact.Net_Asset_Flows__c != oldContact.Net_Asset_Flows__c
					|| newContact.Advisory_Revenue_Perc_YTD__c != oldContact.Advisory_Revenue_Perc_YTD__c
					|| newContact.MTD_Net_New_Advisory_Sales__c != oldContact.MTD_Net_New_Advisory_Sales__c
					|| newContact.of_Key_HHs_w_Env_POR2__c != oldContact.of_Key_HHs_w_Env_POR2__c
					//3. Trainee Metrics
					|| newContact.Trainee_Data_As_of_Date__c != oldContact.Trainee_Data_As_of_Date__c
					|| newContact.Official_Trainee_T12__c != oldContact.Official_Trainee_T12__c
					|| newContact.TPM__c != oldContact.TPM__c
					|| newContact.Trainee_Segment__c != oldContact.Trainee_Segment__c
					|| newContact.Minimum_Trainee_T12__c != oldContact.Minimum_Trainee_T12__c
					|| newContact.Target_Trainee_T12__c != oldContact.Target_Trainee_T12__c){
						affectedContactSet.put(newContact.Id, newContact);
						
						if(newContact.Production_Data_As_Of_Date__c != null){
							asofDateMonthSet.add(ClsCaptureMonthlyMetricsHelper.getMonthStr(newContact.Production_Data_As_Of_Date__c));
							asofDateYearSet.add(ClsCaptureMonthlyMetricsHelper.getYearStr(newContact.Production_Data_As_Of_Date__c));
						}
						
						if(newContact.MBO_Metrics_As_of_Date__c != null){
							asofDateMonthSet.add(ClsCaptureMonthlyMetricsHelper.getMonthStr(newContact.MBO_Metrics_As_of_Date__c));
							asofDateYearSet.add(ClsCaptureMonthlyMetricsHelper.getYearStr(newContact.MBO_Metrics_As_of_Date__c));
						}
						
						if(newContact.Trainee_Data_As_of_Date__c != null){
							asofDateMonthSet.add(ClsCaptureMonthlyMetricsHelper.getMonthStr(newContact.Trainee_Data_As_of_Date__c));
							asofDateYearSet.add(ClsCaptureMonthlyMetricsHelper.getYearStr(newContact.Trainee_Data_As_of_Date__c));
						}
					}
				}
			}
			else if(trigger.isInsert){
				for(Contact newContact:newContactList){
					affectedContactSet.put(newContact.Id, newContact);
					
					if(newContact.Production_Data_As_Of_Date__c != null){
						asofDateMonthSet.add(ClsCaptureMonthlyMetricsHelper.getMonthStr(newContact.Production_Data_As_Of_Date__c));
						asofDateYearSet.add(ClsCaptureMonthlyMetricsHelper.getYearStr(newContact.Production_Data_As_Of_Date__c));
					}
					
					if(newContact.MBO_Metrics_As_of_Date__c != null){
						asofDateMonthSet.add(ClsCaptureMonthlyMetricsHelper.getMonthStr(newContact.MBO_Metrics_As_of_Date__c));
						asofDateYearSet.add(ClsCaptureMonthlyMetricsHelper.getYearStr(newContact.MBO_Metrics_As_of_Date__c));
					}
					
					if(newContact.Trainee_Data_As_of_Date__c != null){
						asofDateMonthSet.add(ClsCaptureMonthlyMetricsHelper.getMonthStr(newContact.Trainee_Data_As_of_Date__c));
						asofDateYearSet.add(ClsCaptureMonthlyMetricsHelper.getYearStr(newContact.Trainee_Data_As_of_Date__c));
					}
				}
			}
		
			Set<Id> affectedContactIdSet = affectedContactSet.keySet();
			//system.debug('*** Contact Id Set: ' + affectedContactIdSet);
			List<Contact> affectedContactList = affectedContactSet.values();
			//system.debug('*** Contact List: ' + affectedContactList); 
			//system.debug('*** As of Date Month Set: ' + asofDateMonthSet);
			//system.debug('*** As of Date Year Set: ' + asofDateYearSet);
			
			//Get the Performance History and the details 
			List<Performance_History__c> phList = new List<Performance_History__c>([SELECT Contact__r.Id, Id, Name, Production_Year__c, 
						(SELECT Id, Name, Production_MTD__c, Production_YTD__c FROM Performance_History_Details__r WHERE Name in :asofDateMonthSet) 
						FROM Performance_History__c 
						WHERE Contact__r.Id in :affectedContactIdSet AND Production_Year__c in :asofDateYearSet]);
			system.debug('*** Performance history List for Production Metrics: ' + phList);
			
			//Make this a map so that It could be easy to search
			Map<String, Performance_History__c> phMap = new Map<String, Performance_History__c>();
			for(Performance_History__c tmpPh:phList){
				phMap.put(tmpPh.Contact__r.Id + '_' + tmpPh.Production_Year__c, tmpPh); 
			}
			
			//Start to loop all the affected contacts and capture their performance data
			for(Contact newContact:affectedContactList){
				ClsCaptureMonthlyMetricsHelper.captureMonthlyMetrics(newContact, phMap, phToUpdateMap, phToInsertMap, phDetailToUpdateList, phDetailToInsertList);
			}
			
			system.debug('*** phToUpdateMap: ' + phToUpdateMap);
			system.debug('*** phToInsertMap: ' + phToInsertMap); 
			system.debug('*** phDetailToUpdateList: ' + phDetailToUpdateList);
			system.debug('*** phDetailToInsertList: ' + phDetailToInsertList);
			
			//Save into SFDC
			update phToUpdateMap.values();
			insert phToInsertMap.values();	
			update phDetailToUpdateList;
			insert phDetailToInsertList;
		}
	}
}