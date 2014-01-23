public with sharing class clsFATalentHistory {
	
	public string strAccountId {get;set;}
	
                public clsFATalentHistory() {}
                
                public List<Opportunity> getOpportunityHistory() {
                	List<Opportunity> OpportunityHistory = new List<Opportunity>();
                	OpportunityHistory = [SELECT channel__c, Id, Name, (SELECT Id, WhatId, Owner.Name, ActivityDate, ActivityType, CreatedBy.Name, CreatedDate, LastModifiedDate, Subject, Status, What.Name, Who.Name, Description FROM ActivityHistories ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 500) FROM Opportunity where fa_talent_name__c = :strAccountId ORDER BY CREATEDDATE DESC];
                	return OpportunityHistory;
                }

}