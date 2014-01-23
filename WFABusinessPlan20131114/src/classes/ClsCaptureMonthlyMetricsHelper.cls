/**************************************************************************************************
 * Name: ClsCaptureMonthlyMetricsHelper
 * Purpose: Capture the monthly metrics
 * Author: Keen Xu
 * Create Date: 2013-05-31
 * Modify History: 
 * 2013-05-31    Keen	Created
***************************************************************************************************/
public class ClsCaptureMonthlyMetricsHelper {
	//Get the month part and convert it to String
	public static String getMonthStr(Date asOfDate){
		if(asOfDate == null){
			return null;
		}
		 
		if(asofDate.month()<10){
			return '0' + string.valueof(asofDate.month());
		}
		return string.valueof(asofDate.month());
	}
	//Get the year part and convert it to String
	public static String getYearStr(Date asOfDate){
		if(asOfDate == null){
			return null;
		}
		
		return string.valueof(asofDate.year());
	}
	
	//Update the record of the Performance History to link to Contact and assign the year
	public static void updatePerformanceHistory(Performance_History__c ph, Contact newContact, String asOfYearStr){
		if(ph.Contact__c == null){
			ph.Contact__c = newContact.Id;
		}
		ph.Production_Year__c = asOfYearStr;
		ph.Master_Id__c = newContact.Id + '_' + asOfYearStr;
	}
	//Capture all the Metrics (Production, MBO, Trainee) into Performance History and Performance History Detail. 
	//Based on the provided phMap, it will decide whether to insert the performance history and performance history detail.
	//The final result is stored in phToUpdateList, phToInsertList, phDetailToUpdateList, phDetailToInsertList for further DML operation
	public static void captureMonthlyMetrics(Contact newContact, Map<String, Performance_History__c> phMap, 
	Map<String, Performance_History__c> phToUpdateMap, 
	Map<String, Performance_History__c> phToInsertMap, 
	List<Performance_History_Detail__c> phDetailToUpdateList, 
	List<Performance_History_Detail__c> phDetailToInsertList){
		updatePhAndPhDetail4Production(newContact, phMap, phToUpdateMap, phToInsertMap, phDetailToUpdateList, phDetailToInsertList);
		updatePhAndPhDetail4MBO(newContact, phMap, phToUpdateMap, phToInsertMap, phDetailToUpdateList, phDetailToInsertList);
		updatePhAndPhDetail4Trainee(newContact, phMap, phToUpdateMap, phToInsertMap, phDetailToUpdateList, phDetailToInsertList);
	}
	//Capture the Production metrics into Performance History and Performance History Detail. If the As of Date is same, MBO and Trainee are also captured at the same time
	private static void updatePhAndPhDetail4Production(Contact newContact, Map<String, Performance_History__c> phMap,
	Map<String, Performance_History__c> phToUpdateMap, 
	Map<String, Performance_History__c> phToInsertMap, 
	List<Performance_History_Detail__c> phDetailToUpdateList, 
	List<Performance_History_Detail__c> phDetailToInsertList){
		//Production As of Date
		String productionAsOfMonthStr = getMonthStr(newContact.Production_Data_As_Of_Date__c);
		String productionAsOfYearStr = getYearStr(newContact.Production_Data_As_Of_Date__c);
		
		//MBO As of Date
		String mboAsOfMonthStr = getMonthStr(newContact.MBO_Metrics_As_of_Date__c);
		String mboAsOfYearStr = getYearStr(newContact.MBO_Metrics_As_of_Date__c);
		
		//Trainee As of Date
		String traineeAsOfMonthStr = getMonthStr(newContact.Trainee_Data_As_of_Date__c);
		String traineeAsOfYearStr = getYearStr(newContact.Trainee_Data_As_of_Date__c);
		
		/*
		system.debug('*** productionAsOfMonthStr: ' + productionAsOfMonthStr);
		system.debug('*** productionAsOfYearStr: ' + productionAsOfYearStr);
		system.debug('*** mboAsOfMonthStr: ' + mboAsOfMonthStr);
		system.debug('*** mboAsOfYearStr: ' + mboAsOfYearStr);
		system.debug('*** traineeAsOfMonthStr: ' + traineeAsOfMonthStr);
		system.debug('*** traineeAsOfYearStr: ' + traineeAsOfYearStr);
		*/
		
		if(productionAsOfYearStr != null){
			//Find it if the Performance Hisotry already exists
			Performance_History__c ph = findPerformanceHistory(phMap, newContact.Id, productionAsOfYearStr, phToUpdateMap, phToInsertMap);

			//If it doesn't exist, create a new one
			if(ph == null){
				//system.debug('*** Could not find the performance history: ' + newContact.Id);
				ph = new Performance_History__c();
				updatePerformanceHistory(ph, newContact, productionAsOfYearStr);
				phToInsertMap.put(newContact.Id +'_'+ph.Production_Year__c, ph);
				
				//To add the new Performance History Detail as well
				Performance_History_Detail__c phDetail = new Performance_History_Detail__c();
				updatePerformanceHistoryDetail4Production(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
				phDetailToInsertList.add(phDetail);
			}
			//If exists, overwrite it
			else{
				//system.debug('*** Found the performance history: ' + newContact.Id);
				//Update the performance history
				updatePerformanceHistory(ph, newContact, productionAsOfYearStr);
				phToUpdateMap.put(newContact.Id +'_'+ph.Production_Year__c, ph);
				
				//Find the performance detail
				List<Performance_History_Detail__c> phDetailList = ph.Performance_History_Details__r;
				Performance_History_Detail__c phDetail = findPerformanceHistoryDetail(phDetailList, productionAsOfMonthStr, productionAsOfYearStr, newContact.Id);
				
				//If the performance detail is never found, create a new one
				if(phDetail==null){
					//system.debug('*** Could not find the performance history detail: ' + newContact.Id);
					phDetail = new Performance_History_Detail__c();
					updatePerformanceHistoryDetail4Production(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
					phDetailToInsertList.add(phDetail);
				}
				//If it's there, update it
				else{
					//system.debug('*** Found the performance history detail: ' + newContact.Id);
					updatePerformanceHistoryDetail4Production(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
					phDetailToUpdateList.add(phDetail);
				}
			}
		}
	}
	//Capture the Production Metrics into phDetail.  If the As of Date is same, MBO and Trainee are also captured at the same time
	private static void updatePerformanceHistoryDetail4Production(Performance_History_Detail__c phDetail, Performance_History__c ph
		, Contact newContact, String productionAsOfMonthStr, String productionAsOfYearStr, String mboAsOfMonthStr
		, String mboAsOfYearStr, String traineeAsOfMonthStr, String traineeAsOfYearStr){
		
		//Establish the lookup relationship with the external Id because the Performance History has not been created yet
		phDetail.Performance_History__r = new Performance_History__c(Master_Id__c=ph.Master_Id__c);
		phDetail.Name = productionAsOfMonthStr;
						
		//Production Metrics
		updateProductionMetric(phDetail, newContact);
		
		//MBO Metrics - Only update it if it's the same as the Production as of date
		if(mboAsOfMonthStr == productionAsOfMonthStr && mboAsOfYearStr == productionAsOfYearStr){
			updateMBOMetric(phDetail, newContact);
		}
		
		//Trainee Metrics - Only update it if it's the same as the Production as of date
		if(traineeAsOfMonthStr == productionAsOfMonthStr && traineeAsOfYearStr == productionAsOfYearStr){
			updateTraineeMetric(phDetail, newContact);
		}
	}
	//Capture the MBO metrics into Performance History and Performance History Detail. If the As of Date is same, Trainee are also captured at the same time.
	//Note if the as of date is same as Production As of Date, the data will be ignored because it has been captured along with Production metrics
	private static void updatePhAndPhDetail4MBO(Contact newContact, Map<String, Performance_History__c> phMap,
	Map<String, Performance_History__c> phToUpdateMap, 
	Map<String, Performance_History__c> phToInsertMap, 
	List<Performance_History_Detail__c> phDetailToUpdateList, 
	List<Performance_History_Detail__c> phDetailToInsertList){
		//Production As of Date
		String productionAsOfMonthStr = getMonthStr(newContact.Production_Data_As_Of_Date__c);
		String productionAsOfYearStr = getYearStr(newContact.Production_Data_As_Of_Date__c);
		
		//MBO As of Date
		String mboAsOfMonthStr = getMonthStr(newContact.MBO_Metrics_As_of_Date__c);
		String mboAsOfYearStr = getYearStr(newContact.MBO_Metrics_As_of_Date__c);
		
		//Trainee As of Date
		String traineeAsOfMonthStr = getMonthStr(newContact.Trainee_Data_As_of_Date__c);
		String traineeAsOfYearStr = getYearStr(newContact.Trainee_Data_As_of_Date__c);
		/*
		system.debug('*** MBO productionAsOfMonthStr: ' + productionAsOfMonthStr);
		system.debug('*** MBO productionAsOfYearStr: ' + productionAsOfYearStr);
		system.debug('*** MBO mboAsOfMonthStr: ' + mboAsOfMonthStr);
		system.debug('*** MBO mboAsOfYearStr: ' + mboAsOfYearStr);
		system.debug('*** MBO traineeAsOfMonthStr: ' + traineeAsOfMonthStr);
		system.debug('*** MBO traineeAsOfYearStr: ' + traineeAsOfYearStr);
		*/
		
		//If the year and month are the same as Production Data, then the mbo metrics has been updated along with Production Data
		if(mboAsOfYearStr == null || (mboAsOfYearStr == productionAsOfYearStr && mboAsOfMonthStr == productionAsOfMonthStr)){
			//system.debug('*** MBO has already been updated: ' + newContact.Id);
			return;
		}
		
		if(mboAsOfYearStr != null){
			//Find it if the Performance Hisotry already exists
			Performance_History__c ph = findPerformanceHistory(phMap, newContact.Id, mboAsOfYearStr, phToUpdateMap, phToInsertMap);

			//If it doesn't exist, create a new one
			if(ph == null){
				//system.debug('*** MBO Could not find the performance history: ' + newContact.Id);
				ph = new Performance_History__c();
				updatePerformanceHistory(ph, newContact, mboAsOfYearStr);
				
				//If the As of Year are the same, it has been added to the list by Production data
				if(mboAsOfYearStr != productionAsOfYearStr){
					//system.debug('*** MBO Year: ' + productionAsOfYearStr + '; ' + mboAsOfYearStr + '; ' + traineeAsOfYearStr);
					//system.debug('*** MBO added to phToInsertList: ' + ph);
					phToInsertMap.put(newContact.Id +'_'+ph.Production_Year__c, ph);
				}
				
				//To add the new Performance History as well
				Performance_History_Detail__c phDetail = new Performance_History_Detail__c();
				updatePerformanceHistoryDetail4MBO(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
				phDetailToInsertList.add(phDetail);
			}
			//If exists, overwrite it
			else{
				//system.debug('*** MBO Found the performance history: ' + newContact.Id);
				//Update the performance history
				updatePerformanceHistory(ph, newContact, mboAsOfYearStr);
				
				//If the As of Year are the same, it has been added to the list by Production data
				if(mboAsOfYearStr != productionAsOfYearStr){
					//system.debug('*** MBO Year: ' + productionAsOfYearStr + '; ' + mboAsOfYearStr + '; ' + traineeAsOfYearStr);
					//system.debug('*** MBO added to phToUpdateList: ' + ph);
					phToUpdateMap.put(newContact.Id +'_'+ph.Production_Year__c, ph);
				}
				
				//Find the performance detail
				List<Performance_History_Detail__c> phDetailList = ph.Performance_History_Details__r;
				Performance_History_Detail__c phDetail = findPerformanceHistoryDetail(phDetailList, mboAsOfMonthStr, mboAsOfYearStr, newContact.Id);
				
				//If the performance detail is never found, create a new one
				if(phDetail==null){
					//system.debug('*** MBO Could not find the performance history detail: ' + newContact.Id);
					phDetail = new Performance_History_Detail__c();
					updatePerformanceHistoryDetail4MBO(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
					phDetailToInsertList.add(phDetail);
				}
				//If it's there, update it
				else{
					//system.debug('*** MBO Found the performance history detail: ' + newContact.Id);
					updatePerformanceHistoryDetail4MBO(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
					phDetailToUpdateList.add(phDetail);
				}
			}
		}
	}
	//Capture the MBO Metrics into phDetail.  If the As of Date is same, Trainee are also captured at the same time
	private static void updatePerformanceHistoryDetail4MBO(Performance_History_Detail__c phDetail, Performance_History__c ph
		, Contact newContact, String productionAsOfMonthStr, String productionAsOfYearStr, String mboAsOfMonthStr
		, String mboAsOfYearStr, String traineeAsOfMonthStr, String traineeAsOfYearStr){
		
		//Establish the lookup relationship with the external Id because the Performance History has not been created yet
		phDetail.Performance_History__r = new Performance_History__c(Master_Id__c=ph.Master_Id__c);
		phDetail.Name = mboAsOfMonthStr;
						
		//MBO Metrics
		updateMBOMetric(phDetail, newContact);
		
		//Trainee Metrics - Only update it if it's the same as the Production as of date
		if(traineeAsOfMonthStr == mboAsOfMonthStr && traineeAsOfYearStr == mboAsOfYearStr){
			updateTraineeMetric(phDetail, newContact);
		}
	}
	//Capture the Trainee metrics into Performance History and Performance History Detail.
	//Note if the as of date is same as Production/MBO As of Date, the data will be ignored because it has been captured along with Production/Trainee metrics
	private static void updatePhAndPhDetail4Trainee(Contact newContact, Map<String, Performance_History__c> phMap,
	Map<String, Performance_History__c> phToUpdateMap, 
	Map<String, Performance_History__c> phToInsertMap, 
	List<Performance_History_Detail__c> phDetailToUpdateList, 
	List<Performance_History_Detail__c> phDetailToInsertList){
		//Production As of Date
		String productionAsOfMonthStr = getMonthStr(newContact.Production_Data_As_Of_Date__c);
		String productionAsOfYearStr = getYearStr(newContact.Production_Data_As_Of_Date__c);
		
		//MBO As of Date
		String mboAsOfMonthStr = getMonthStr(newContact.MBO_Metrics_As_of_Date__c);
		String mboAsOfYearStr = getYearStr(newContact.MBO_Metrics_As_of_Date__c);
		
		//Trainee As of Date
		String traineeAsOfMonthStr = getMonthStr(newContact.Trainee_Data_As_of_Date__c);
		String traineeAsOfYearStr = getYearStr(newContact.Trainee_Data_As_of_Date__c);
		/*
		system.debug('*** Trainee productionAsOfMonthStr: ' + productionAsOfMonthStr);
		system.debug('*** Trainee productionAsOfYearStr: ' + productionAsOfYearStr);
		system.debug('*** Trainee mboAsOfMonthStr: ' + mboAsOfMonthStr);
		system.debug('*** Trainee mboAsOfYearStr: ' + mboAsOfYearStr);
		system.debug('*** Trainee traineeAsOfMonthStr: ' + traineeAsOfMonthStr);
		system.debug('*** Trainee traineeAsOfYearStr: ' + traineeAsOfYearStr);
		*/
		
		//If the year and month are the same as Production Data or MBO Data, then the trainee metrics has been updated along with them
		if(traineeAsOfYearStr == null || (traineeAsOfYearStr == productionAsOfYearStr && traineeAsOfMonthStr == productionAsOfMonthStr)
			|| (traineeAsOfYearStr == mboAsOfYearStr && traineeAsOfMonthStr == mboAsOfMonthStr)){
			//system.debug('*** Trainee has already been updated: ' + newContact.Id);
			return;
		}
		
		
		if(traineeAsOfYearStr != null){
			//Find it if the Performance Hisotry already exists
			Performance_History__c ph = findPerformanceHistory(phMap, newContact.Id, traineeAsOfYearStr, phToUpdateMap, phToInsertMap);

			//If it doesn't exist, create a new one
			if(ph == null){
				//system.debug('*** Trainee Could not find the performance history: ' + newContact.Id);
				ph = new Performance_History__c();
				updatePerformanceHistory(ph, newContact, traineeAsOfYearStr);
				
				//If the year are the same as Production Data or MBO Data, then the performance history has been updated along with them
				if(traineeAsOfYearStr != mboAsOfYearStr && traineeAsOfYearStr != productionAsOfYearStr){
					//system.debug('*** Trainee Year: ' + productionAsOfYearStr + '; ' + mboAsOfYearStr + '; ' + traineeAsOfYearStr);
					//system.debug('*** Trainee added to phToInsertList: ' + ph);
					phToInsertMap.put(newContact.Id +'_'+ph.Production_Year__c, ph);
				}
				
				//To add the new Performance History as well
				Performance_History_Detail__c phDetail = new Performance_History_Detail__c();
				updatePerformanceHistoryDetail4Trainee(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
				phDetailToInsertList.add(phDetail);
			}
			//If exists, overwrite it
			else{
				//system.debug('*** Trainee Found the performance history: ' + newContact.Id);
				//Update the performance history
				updatePerformanceHistory(ph, newContact, traineeAsOfYearStr);
				
				//If the year are the same as Production Data or MBO Data, then the performance history has been updated along with them
				if(traineeAsOfYearStr != mboAsOfYearStr && traineeAsOfYearStr != productionAsOfYearStr){
					//system.debug('*** Trainee Year: ' + productionAsOfYearStr + '; ' + mboAsOfYearStr + '; ' + traineeAsOfYearStr);
					//system.debug('*** Trainee added to phToUpdateList: ' + ph);
					phToUpdateMap.put(newContact.Id +'_'+ph.Production_Year__c, ph);
				}
				
				//Find the performance detail
				List<Performance_History_Detail__c> phDetailList = ph.Performance_History_Details__r;
				Performance_History_Detail__c phDetail = findPerformanceHistoryDetail(phDetailList, traineeAsOfMonthStr, traineeAsOfYearStr, newContact.Id);
				
				//If the performance detail is never found, create a new one
				if(phDetail==null){
					//system.debug('*** Trainee Could not find the performance history detail: ' + newContact.Id);
					phDetail = new Performance_History_Detail__c();
					updatePerformanceHistoryDetail4Trainee(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
					phDetailToInsertList.add(phDetail);
				}
				//If it's there, update it
				else{
					//system.debug('*** Trainee Found the performance history detail: ' + newContact.Id);
					updatePerformanceHistoryDetail4Trainee(phDetail, ph, newContact, productionAsOfMonthStr, productionAsOfYearStr, mboAsOfMonthStr, mboAsOfYearStr, traineeAsOfMonthStr, traineeAsOfYearStr);
					phDetailToUpdateList.add(phDetail);
				}
			}
		}
	}
	//Capture the Trainee Metrics into phDetail.
	private static void updatePerformanceHistoryDetail4Trainee(Performance_History_Detail__c phDetail, Performance_History__c ph
		, Contact newContact, String productionAsOfMonthStr, String productionAsOfYearStr, String mboAsOfMonthStr
		, String mboAsOfYearStr, String traineeAsOfMonthStr, String traineeAsOfYearStr){
		
		//Establish the lookup relationship with the external Id because the Performance History has not been created yet
		phDetail.Performance_History__r = new Performance_History__c(Master_Id__c=ph.Master_Id__c);
		phDetail.Name = traineeAsOfMonthStr;
						
		//Trainee Metrics
		updateTraineeMetric(phDetail, newContact);
	}
	
	//Copy the production metrics from contact
	private static void updateProductionMetric(Performance_History_Detail__c phDetail, Contact newContact){
		phDetail.Production_MTD__c = newContact.Production_MTD__c;
		phDetail.Production_YTD__c = newContact.Production_YTD__c;
	}
	//Copy the MBO metrics from contact
	private static void updateMBOMetric(Performance_History_Detail__c phDetail, Contact newContact){
		phDetail.New_Key_HHs__c = newContact.New_Key_HHs__c;
		phDetail.Compensable_Loans__c = newContact.Compensable_Loans_YTD__c;
		phDetail.Net_Asset_Flows__c = newContact.Net_Asset_Flows__c;
		phDetail.YTD_Advisory_Revenue__c = newContact.Advisory_Revenue_Perc_YTD__c;
		phDetail.MTD_Net_New_Advisory_Sales__c = newContact.MTD_Net_New_Advisory_Sales__c;
		phDetail.of_Key_HHs_w_Env_POR__c = newContact.of_Key_HHs_w_Env_POR2__c;
	}
	//Copy the trainee metrics from contact
	private static void updateTraineeMetric(Performance_History_Detail__c phDetail, Contact newContact){
		phDetail.Official_Trainee_T12__c = newContact.Official_Trainee_T12__c;
		phDetail.Trainee_Month__c = newContact.TPM__c;
		phDetail.Trainee_Segment__c = newContact.Trainee_Segment__c;
		phDetail.Minimum_T12_Production__c = newContact.Minimum_Trainee_T12__c;
		phDetail.Target_T12_Production__c = newContact.Target_Trainee_T12__c;
	}
	//Find the performance history in the phToUpdateList/phToInsertList/phMap by ContactId and Year.
	//Search in phToUpdateList/phToInsertList is required because the performance history may have been created/updated and added into the update/insert list when capturing other data
	private static Performance_History__c findPerformanceHistory(Map<String, Performance_History__c> phMap, ID contactId, String year,
	Map<String, Performance_History__c> phToUpdateMap, 
	Map<String, Performance_History__c> phToInsertMap){
		Performance_History__c foundPh = phToUpdateMap.get(contactId + '_' + year);
		if(foundPh != null){
			return foundPh;
		}
		foundPh = phToInsertMap.get(contactId + '_' + year);
		if(foundPh != null){
			return foundPh;
		}
		foundPh = phMap.get(contactId + '_' + year);
		return foundPh;
		
		/*
		for(Performance_History__c tmpPh:phToUpdateList){
			if(tmpPh.Contact__r.Id == contactId && tmpPh.Production_Year__c == year){
				return tmpPh;
			}
		}
		
		for(Performance_History__c tmpPh:phToInsertList){
			if(tmpPh.Contact__r.Id == contactId && tmpPh.Production_Year__c == year){
				return tmpPh;
			}
		}*/

		
		/*
		for(Performance_History__c tmpPh:phMap){
			if(tmpPh.Contact__r.Id == contactId && tmpPh.Production_Year__c == year){
				return tmpPh;
			}
		}
		
		return null;
		*/
	}
	//Find the performance history in the phDetailList by Name (month). Make sure the phDetailList only has performance history details for the specified contact
	//No need to search in phDetailToUpdateList/phDetailToInsertList, because when capturing production data, the Trainee/MBO are also captured if they have the same year and month
	//Month and contactId are no use now. Leave it for future use.
	private static Performance_History_Detail__c findPerformanceHistoryDetail(List<Performance_History_Detail__c> phDetailList, String month, String year, ID contactId){		
		for(Performance_History_Detail__c tmpPhDetail:phDetailList){
			//If the performance detail is found
			if(tmpPhDetail.Name == month){
				return tmpPhDetail;
			}
		}
		
		return null;
	}
}