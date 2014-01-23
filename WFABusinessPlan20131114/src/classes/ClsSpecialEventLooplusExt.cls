/**************************************************************************************************
 * Name: ClsSpecialEventLooplusExt
 * Object: Contact
 * Author: Keen Xu
 * Create Date: 2013-06-17
 * Modify History: 
 * 2013-06-17    Keen	Created
***************************************************************************************************/
public class ClsSpecialEventLooplusExt {
	SFDC_Special_Event__c sp;
	
	public ClsSpecialEventLooplusExt(ID specialEventId){
        this.sp = [SELECT Id FROM SFDC_Special_Event__c WHERE Id = :specialEventId LIMIT 1]; 
	}
	public ClsSpecialEventLooplusExt(ApexPages.StandardController controller){
		system.debug('*** Start ClsSpecialEventLooplusExt');
        this.sp = (SFDC_Special_Event__c)controller.getRecord(); 
        system.debug('*** End ClsSpecialEventLooplusExt');
	}
	
	public PageReference looplus(){
		upsertAttendanceChildren();
		return new PageReference('/apex/loop__looplus?eid=' + sp.Id + '&sessionid=' + UserInfo.getSessionId());
	}
	//Create a mapping with all the existing Attendance_Child__c. Then loop all the Child records to find that those that have not been created. 
	//Create those missing ones
	//The key is the combination of Attendance Id and Child Id which is unique
	private void upsertAttendanceChildren(){
		
		system.debug('*** Start upsertAttendanceChildren');
		if(sp == null){
			system.debug('*** Null Special Event');
			return;
		}
		
		Map<Id, SFDC_Attendance__c> attendanceMap = new Map<Id, SFDC_Attendance__c>([
			SELECT Id, Attendee__c
			, (SELECT Id, Name, Child__c FROM Attendance_Children__r) 
			FROM SFDC_Attendance__c 
			WHERE Special_Event__c = :sp.Id
		]);
		
		Map<String, Attendance_Child__c> attChildMap = new Map<String, Attendance_Child__c>();
		Set<Id> attendeeIdSet = new Set<Id>();
		for(SFDC_Attendance__c tmpAtt : attendanceMap.values()){
			attendeeIdSet.add(tmpAtt.Attendee__c);
			for(Attendance_Child__c tmpAttChild : tmpAtt.Attendance_Children__r){//No worry about the limit because the Children should usually be 2 to 3
				//Create a map of the existing Attendance Children records. The key is the combination of Attendance Id and Child Id
				attChildMap.put(tmpAtt.Id + '_' + tmpAttChild.Child__c, tmpAttChild);
			}
		}
		system.debug('*** attChildMap: ' + attChildMap);
		system.debug('*** attendeeIdSet: ' + attendeeIdSet);
		
		Map<Id, Contact> conMap = new Map<Id, Contact>([
			SELECT Id, (SELECT Id FROM Attendances__r WHERE Special_Event__c = :sp.Id), (SELECT Id FROM Children__r) FROM Contact WHERE Contact.Id in :attendeeIdSet
		]);
		system.debug('*** conMap: ' + conMap);
		
		List<Contact> conList = conMap.values();
		List<Attendance_Child__c> attChildInsertList = new List<Attendance_Child__c>();
		Map<String, Child__c> childMap = new Map<String, Child__c>();
		for(Contact tmpCon : conList){
			for(SFDC_Attendance__c tmpAtt : tmpCon.Attendances__r){//No worry about the limit because Attendances__r contains 1 record usually 
				for(Child__c tmpChild : tmpCon.Children__r){//No worry about the limit because the Children should usually be 2 to 3
					//Check if the combination of Attendance Id and Child Id exists in the existing Attendance Children records.
					if(!attChildMap.containsKey(tmpAtt.Id + '_' + tmpChild.Id)){
						//If it doesn't exist, we should insert the Attendance_Child__c
						Attendance_Child__c attChildInsert = new Attendance_Child__c();
						attChildInsert.Attendance__c = tmpAtt.Id;
						attChildInsert.Child__c = tmpChild.Id;
						attChildInsertList.add(attChildInsert);
					}
				}
			}
		}
		
		system.debug('*** attChildInsertList' + attChildInsertList);
		insert attChildInsertList;
	}
}