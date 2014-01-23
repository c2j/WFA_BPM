public with sharing class TaskLegacyCommentPopulation {

	public string taskID = null;
	public List<Legacy_Comments__c> taskLegacyCommentData;
	public List<Legacy_Comments__c> taskLegacyCommentDataDisplay = new Legacy_Comments__c[]{};	
		
	public TaskLegacyCommentPopulation (ApexPages.StandardController sc) {

		//obtain task id: note that 15 char id is obtained
		this.taskID = ApexPages.currentPage().getParameters().get('id'); 
		
		System.Debug('TASK ID: ' + this.taskID);

	}	
	
	//obtain related legacy comment data
	public List<Legacy_Comments__c> getCommentData() {

		//NOTE: soql comparisons are case insensitive (taskid in this case).  being we are using the 15 char id there is the potential for multipe records to be returned
		taskLegacyCommentData = [select Comments__c, Task_ID_15_Char__c from Legacy_Comments__c where Task_ID_15_Char__c = :this.taskID];
		
		System.Debug('LEGACYCOMMENTDATASIZE: ' + taskLegacyCommentData.size());
		
		//the following loop filters the returned data so as to isolate the correct comment data to display
		for(Legacy_Comments__c lc : taskLegacyCommentData){
			System.Debug('THIS.TASKID IN DATA LOOP: ' + this.taskID);	
			System.Debug('15 CHAR ID IN DATA LOOP: ' + lc.Task_ID_15_Char__c);		

			if(this.taskID.equals(lc.Task_ID_15_Char__c)){  //equals() method performs a case sensitive comparison between two strings
				System.Debug('COMMENT DATA TO DISPLAY: ' + lc.Comments__c);				
				
				taskLegacyCommentDataDisplay.add(lc);  //add filtered comment data to list to be passed to vf page			
			}// end of id comparison if
		}// end of lc loop					

		System.Debug('COMMENTTODISPLAY: ' + taskLegacyCommentDataDisplay);

		return taskLegacyCommentDataDisplay;		
		
	}// end of getCommentData method
}// end of class