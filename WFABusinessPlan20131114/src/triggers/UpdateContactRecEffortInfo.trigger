trigger UpdateContactRecEffortInfo on Opportunity (after update) {

List<Opportunity> OppRecs = new List<Opportunity>();
List<ID> OppIds = new List<ID>();

    for (Opportunity o : trigger.new) {
        Opportunity oldEffort = trigger.oldmap.get(o.id);
        if ( (o.StageName == 'Hired' ||
        o.StageName == 'RPL-4' || o.StageName == 'Graduate/Affiliate') &&
        (o.Amount != oldEffort.Amount || o.AUM__c != oldEffort.AUM__c || o.CloseDate != oldEffort.CloseDate) ) {
            OppRecs.add(o);  
            OppIds.add(o.id);          
        }
    }

if (OppIds.size()>0) {

Contact[] cons = [SELECT Pre_Hire_T12_Production__c, Pre_Hire_AUM__c, Hire_Date__c, Effort__c FROM Contact WHERE Effort__c IN: OppIds];

    if (cons.size()>0) {
        for (Integer i = 0; i < OppRecs.Size(); i++) {
            for (Contact c : cons) {
                if (c.Effort__c == OppRecs[i].id) {
                    if (OppRecs[i].Amount != trigger.oldmap.get(OppRecs[i].id).Amount) {//if t12 is changed on effort
                        c.Pre_Hire_T12_Production__c = OppRecs[i].Amount; //update pre hire t12 on related contact
                    }
                    if (OppRecs[i].AUM__c != trigger.oldmap.get(OppRecs[i].id).AUM__c) {//if aum is changed on effort
                        c.Pre_Hire_AUM__c = OppRecs[i].AUM__c; //update pre hire aum on related contact
                    }
                    if (OppRecs[i].CloseDate != trigger.oldmap.get(OppRecs[i].id).CloseDate) {//if hire date is changed on effort
                        c.Hire_Date__c = OppRecs[i].CloseDate;  //update Hire Date on related contact                              
                    }
                    
                    break;
                }
                
            }
        }
        
        try {
            update cons;
        } catch (System.DmLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                e.setMessage('Error occured while updating T12, AUM or Hire Date. Related Contact Record not Updated');
            }
        }
    }
                
}

}