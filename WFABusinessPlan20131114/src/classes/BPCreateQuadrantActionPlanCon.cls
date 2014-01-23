/**************************************************************************************************
 * Purpose: Controller of the Action Plan creation page
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-06
 * Modify History:
 * Keen    2013-11-06    Created
***************************************************************************************************/
public class BPCreateQuadrantActionPlanCon {
	public String msgStr;
	public BoM_Plan__c bomPlan {get;set;}
    public List<ActionElementWrapper> q1Action1List {get;set;}
    public List<ActionElementWrapper> q1Action2List {get;set;}
    public List<ActionElementWrapper> q1Action3List {get;set;}
    public List<ActionElementWrapper> q1Action4List {get;set;}
    
    public List<ActionElementWrapper> q2Action1List {get;set;}
    public List<ActionElementWrapper> q2Action2List {get;set;}
    public List<ActionElementWrapper> q2Action3List {get;set;}
    public List<ActionElementWrapper> q2Action4List {get;set;}
    
    public List<ActionElementWrapper> q3Action1List {get;set;}
    public List<ActionElementWrapper> q3Action2List {get;set;}
    public List<ActionElementWrapper> q3Action3List {get;set;}
    public List<ActionElementWrapper> q3Action4List {get;set;}
    
    public List<ActionElementWrapper> q4Action1List {get;set;}
    public List<ActionElementWrapper> q4Action2List {get;set;}
    public List<ActionElementWrapper> q4Action3List {get;set;}
    public List<ActionElementWrapper> q4Action4List {get;set;}
    
	public BPCreateQuadrantActionPlanCon (){
        String bomPlanId = ApexPages.currentPage().getParameters().get('pid');
		if(bomPlanId == null || bomPlanId == ''){
            msgStr = 'Invalid BoM Plan Id.';
            BPMessageUtil.addInfoMessage(msgStr);
        }
        else {
        	initActionElements();
        }
    }
    
    public void initActionElements(){
    	List<SFDC_Special_Event__c> spList = BPBranchBusinessPlanUtil.getQuadrantSpecialEvents();
    	q1Action1List = new List<ActionElementWrapper>();
    	q1Action2List = new List<ActionElementWrapper>();
    	q1Action3List = new List<ActionElementWrapper>();
    	q1Action4List = new List<ActionElementWrapper>();
    	
    	for(SFDC_Special_Event__c sp : spList){
    		ActionElementWrapper ae = null;
    		ae = new ActionElementWrapper();
    		ae.specialEvent = sp;
    		
    		if(sp.Quadrant__c == '1'){
	    		ae.isSelect = true;
	    		q1Action1List.add(ae);
    		}
    		else if(sp.Quadrant__c == '2'){
	    		q1Action2List.add(ae);
    		}
    		else if(sp.Quadrant__c == '3'){
	    		q1Action3List.add(ae);
    		}
    		else if(sp.Quadrant__c == '4'){
	    		q1Action4List.add(ae);
    		}
    	}
    	

    }
    
    public PageReference createActionPlans(){
    	return null;
    }
    
    public class ActionElementWrapper implements Comparable {
    	public ActionElementWrapper(){
    		isSelect = false;
    	}
    	public boolean isSelect {get;set;}
    	public SFDC_Special_Event__c specialEvent {get;set;}
    	public Integer compareTo(Object compareTo) 
	    {
	        ActionElementWrapper wrapper = (ActionElementWrapper) compareTo;
	        if (specialEvent.Name == wrapper.specialEvent.Name) return 0;
	        if (specialEvent.Name > wrapper.specialEvent.Name) return 1;
	        return -1;        
	    }
    }
}