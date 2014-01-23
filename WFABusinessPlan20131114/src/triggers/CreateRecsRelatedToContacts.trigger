trigger CreateRecsRelatedToContacts on Contact (After Insert) {

//List<sObject> NewRelRecs = new List<sObject>();
List<Ranking__c> NewRankingRecs = new List<Ranking__c>();
List<Qualification_Tracking__c> NewQTRecs = new List<Qualification_Tracking__c>();
List<Ramp_Metrics__c> NewRampMetRecs = new List<Ramp_Metrics__c>();
List<Marketing__c> NewMktingRecs = new List<Marketing__c>();
List<Envision__c> NewEnvisionRecs = new List<Envision__c>();
List<Areas_Of_Interest__c> NewAOIRecs = new List<Areas_Of_Interest__c>();
List<Capital_Markets__c> NewCapMktRecs = new List<Capital_Markets__c>();
List<Hobbies_Charities__c> NewProfInfoRecs = new List<Hobbies_Charities__c>();
List<National_Sales_Scorecard_Data__c> NewNatSalesScorecard = new List<National_Sales_Scorecard_Data__c>();

for (Contact c: Trigger.new) {
    if ((c.Type__c == 'FA' || c.Type__c == 'FA in Training' || c.Type__c == 'Licensee' ||
    c.Type__c == 'Branch Manager') && 
    (c.channel__c == 'PCG' || c.Channel__c == 'WBS' || c.Channel__c == 'FiNet' || c.Channel__c == 'Latin America')) {
    
        //insert ranking rec
        Ranking__c rk = new Ranking__c(
        Name = c.FirstName + ' ' + c.LastName,
        Contact__c = c.ID);
        
        NewRankingRecs.add(rk);
        
        //insert ramp metric rec
        Ramp_Metrics__c rm = new Ramp_Metrics__c(
        FA_Name__c = c.ID);
        
        NewRampMetRecs.add(rm);
        
        //insert qualification tracking rec
        Qualification_Tracking__c qt = new Qualification_Tracking__c(
        Name__c = c.ID,
        Name = c.FirstName + ' ' + c.LastName);
        
        NewQTRecs.add(qt);
        
        //insert marketing rec
        Marketing__c m = new Marketing__c(
        Contact__c = c.ID,
        Name = c.LastName + ', ' + c.FirstName);
        
        NewMktingRecs.add(m);
        
        //insert envision rec
        Envision__c e = new Envision__c(
        Contact__c = c.ID,
        Name = c.LastName + ', ' + c.FirstName);
        
        NewEnvisionRecs.add(e);
        
        //insert areas of interest rec
        Areas_Of_Interest__c a = new Areas_Of_Interest__c(
        Name__c = c.ID,
        Name = c.LastName + ', ' + c.FirstName);
        
        NewAOIRecs.add(a);
        
        //insert capital markets rec
        Capital_Markets__c cm = new Capital_Markets__c(
        Contact_Name__c = c.ID,
        Name = c.LastName + ', ' + c.FirstName);
        
        NewCapMktRecs.add(cm);
        
        //Insert profiling info rec
        Hobbies_Charities__c p = new Hobbies_Charities__c(
        Name__c = c.ID,
        Name = c.FirstName + ' ' + c.LastName,
        First_Name__c = c.FirstName,
        Last_Name__c = c.LastName);
        
        NewProfInfoRecs.add(p);
        
        
        //Insert National Sales Scorecard Data rec
        National_Sales_Scorecard_Data__c NSSC = new National_Sales_Scorecard_Data__c (
        Name = c.LastName + ', ' + c.FirstName + ' - NS Scorecard Data',
        FA_Name__c = c.ID);
        
        NewNatSalesScorecard.add(NSSC);
             
    }
}

   
//insert new ranking records for the newly hired FAs
try{
//system.debug('New Ranking Recs -------------- ' + NewRankingRecs);
    if (NewRankingRecs.size() > 0) {
        insert NewRankingRecs;
        Insert NewQTRecs;
        Insert NewRampMetRecs;
        Insert NewMktingRecs;
        Insert NewEnvisionRecs;
        Insert NewAOIRecs;
        Insert NewCapMktRecs;
        Insert NewProfInfoRecs;
        Insert NewNatSalesScorecard;
    
    }
} catch (DMLException e){
    for (contact c: trigger.new) {
         c.addError('Error occurred when creating records related to new Contact. Contact your administrator' + e);
         system.debug('Error occurred when creating records related to new Contact ------------- ' + e.getCause());
    }
}

}