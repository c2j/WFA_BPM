trigger GetContactForWebCases on Case (after insert) {

//applies to web submitted cases
Map<ID, string> aNumbers = new Map<ID,String>();
Map<ID, ID> RecIDToCon = new Map<ID, ID>();
String ANum;


Case[] webCases = [SELECT ContactID, Subject, A_Number__c, Origin FROM Case Where Origin = 'Web' AND ContactID = NULL ORDER BY
CreatedDate DESC];

system.debug('New WebCases ----------- ' + webCases);

if (webCases.size() > 0) {
    For (Case c : webCases) {
    system.debug('Case A Number ------------ ' + c.A_Number__c);
        if (c.A_Number__c != NULL && c.A_Number__c != '') {
            aNumbers.put(c.id, c.A_Number__c);
        }
    }
    
    if (aNumbers.size()>0) {
    
        RecIDToCon = GetContactBasedOnANumbers.formatANumber(aNumbers);
        
        system.debug('Record Id to Contact id ------------- ' + RecIDToCon);
                    
        For (Case cs: webCases) {
            cs.ContactID = RecIDToCon.get(cs.id);
        }
    }
     
    try {    
        update webCases;
    } catch (DMLException e) {
        for (case cs: webCases) {
            cs.addError('Contact not updated on case');
        }
    }
}

}