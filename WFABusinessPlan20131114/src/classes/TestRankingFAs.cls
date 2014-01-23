@isTest
private class TestRankingFAs {

Static testMethod void TestRankFAs() {
/*
Channel__c pcg = new Channel__c(name = 'PCG');
insert pcg;

Account branch = new Account (name = 'PCGBr', Channel_Branch__c = pcg.id);
insert branch;

List<Contact> FAs = new list<Contact>();

For (integer i = 0; i < 200; i++) {
    Contact c = new contact(LastName ='FA' + i, FirstName = 'Tester', Type__c = 'FA', Accountid=branch.id,
    production_ytd__c = (i*20)+1, production_yesterday__c = (i*10)+5 , production_mtd__c = 250-i , 
    annualized_production__c = (i*50)+10, Dummy_production_data_date__c = date.newinstance(2012,8,1));

    FAs.add(c);
}

insert FAs;



List<Ranking__c> FARanks = new list<Ranking__c>();

Contact[] FAsToRank = [SELECT ID, Production_YTD__c, Production_Yesterday__c, Production_MTD__c,
Annualized_Production__c, Production_Data_As_Of_Date__c FROM Contact WHERE FirstName = 'Tester'
ORDER BY Production_YTD__c DESC];

for (integer i = 0; i<FAsToRank.size();i++) {
    Ranking__c r = new Ranking__c(Contact__c = FAsToRank[i].id);
    FARanks.add(r);
    FAsToRank[i].Dummy_Production_Data_Date__c = date.newinstance(2012,8,2);
}

insert FARanks;



test.StartTest();

update FAsToRank;

test.StopTest();

Ranking__c[] ranks = [SELECT Contact__c, Current_YTD_Production_Rank__c, 
                    Prior_YTD_Production_Rank__c FROM Ranking__c WHERE Current_YTD_Production_Rank__c > 0
                        ORDER BY Current_YTD_Production_Rank__c ASC];

system.assertequals(ranks[0].Prior_YTD_Production_Rank__c, NULL);
system.assertequals(ranks[0].contact__c, FAsToRank[0].id);
*/
}
}