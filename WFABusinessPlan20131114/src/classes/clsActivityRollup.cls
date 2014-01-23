public with sharing class clsActivityRollup {
        
        //public string strAccountId {get;set;}
        public Set<String> OppIds = new Set<String>();
        public List<Opportunity> lstOpps = new List<Opportunity>();
        public Boolean UserIsNotManager {get;set;}
        public string sfdcRecId {get;set;}
        public ID UserId{get;set;}
        
        
                public clsActivityRollup(ApexPages.StandardController controller) {
                
                sfdcRecId = controller.getRecord().Id;
                
                UserID = UserInfo.getUserID();
                User u = [SELECT ProfileID FROM User WHERE ID =: UserID];
                
                If (u.ProfileID == '00e50000000vLe3' || u.ProfileID == '00e50000000z2sU') {//market managers and pcg branch managers can't see legacy comments
                    UserIsNotManager = False;
                } else {
                    UserIsNotManager = True;
                }
                
                
                }

                public void fillOpportunities() {
                        
                        lstOpps.clear();
                        
                        lstOpps = [SELECT Id, Name FROM Opportunity where fa_talent_name__c = :sfdcRecId];
                        
                        OppIds.clear();
                        
                        for (Opportunity o: lstOpps){
                                OppIds.add(o.Id);
                        }
                        
                        
                        
                }
                
                
                public List<hClsActivity> getOpportunityHistory() {

                        // Define Holder Object
                        List<hClsActivity> lstActivities = new List<hClsActivity>();
                        
                        // define a map of task id to legacy comments
                        Map<String,String> TaskIDToLegacyCmnts = new Map<String,String>();
                        
                        // Get all Opportunities First
                        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT Id, Channel__c FROM Opportunity WHERE Id IN :OppIds]);
                        
                        //map task id to legacy comments
                        for (Legacy_Comments__c LC :[SELECT ID, Task_ID__c, Comments__c, Effort__c FROM Legacy_Comments__c WHERE Effort__c IN: OppIds]) {
                            
                            TaskIDToLegacyCmnts.put(LC.Task_ID__c, LC.Comments__c);
                        
                        }
                        
                        system.debug('Task id to Legacy Comments map ---------- ' + TaskIDToLegacyCmnts.values().size() + ' / ' + TaskIDToLegacyCmnts);
                        
                        // Get all Tasks
                        for(Task t : [SELECT Id, WhatId, Owner.Name, ActivityDate, CreatedBy.Name, Subject, Description, Status FROM Task WHERE WhatId IN :mapOpp.keySet() AND Status = 'Complete' ORDER BY ActivityDate DESC]) {
                                
                                hClsActivity clsActivity = new hClsActivity(t);
                                clsActivity.o = mapOpp.get(t.WhatId);                                
                                clsActivity.strLegacyComments = TaskIDToLegacyCmnts.get(t.Id);
                                
                                system.debug('legacy comment from map------ ' + TaskIDToLegacyCmnts.get(t.Id));
                                system.debug('task record\'s legacy comment ------ ' + clsActivity.strLegacyComments);
                                lstActivities.add(clsActivity);
                                
                        }
                        
                        // Get all Events
                        for(Event e : [SELECT Id, WhatId, Owner.Name, StartDateTime, CreatedBy.Name, Subject, Description FROM Event WHERE WhatId IN :mapOpp.keySet() ORDER BY StartDateTime DESC]) {
                                
                                hClsActivity clsActivity = new hClsActivity(e);
                                clsActivity.o = mapOpp.get(e.WhatId);
                                clsActivity.strLegacyComments = TaskIDToLegacyCmnts.get(e.Id);
                                
                                lstActivities.add(clsActivity);
                                
                        }
                        
                        if (lstActivities.size() == 0)
                                {
                                        return null;
                                }
                        
                        return lstActivities;
                        
                }
                
                
                public List<Opportunity> getOpportunityInfo() {
                        List<Opportunity> getOpportunityInfo = new List<Opportunity>();
                        getOpportunityInfo = [SELECT Name FROM Opportunity where Id in :OppIds];
                        return getOpportunityInfo;
                }
                
                
                public class hClsActivity {
                        
                        public Id idRecord {get;set;}
                        public Id idWhat {get;set;}
                        public String strOwner {get;set;}
                        public Date dteActivityDate {get;set;}
                        public String strActivityType {get;set;}
                        public String strSubject {get;set;}
                        public String strDescription {get;set;}
                        
                        public String strLegacyComments {get;set;}
                        public Opportunity o {get;set;}
                        
                        public hClsActivity(Task t) {
                                
                                idRecord = t.Id;
                                idWhat = t.WhatId;
                                strOwner = t.Owner.Name;
                                dteActivityDate = t.ActivityDate;
                                strActivityType = 'Task';
                                strSubject = t.Subject;
                                strDescription = t.Description;

                        }
                        
                        public hClsActivity(Event e) {
                                
                                idRecord = e.Id;
                                idWhat = e.WhatId;
                                strOwner = e.Owner.Name;
                                dteActivityDate = e.StartDateTime.Date();
                                strActivityType = 'Event';
                                strSubject = e.Subject;
                                strDescription = e.Description;
                                
                        }
                        
                }                

}