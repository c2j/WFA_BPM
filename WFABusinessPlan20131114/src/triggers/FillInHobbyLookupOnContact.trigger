trigger FillInHobbyLookupOnContact on Hobbies_Charities__c (After insert, Before Update) {    
/*
//whenever a hobby record is inserted for an FA, update the Hobbies Record lookup field
//on the FA's contact page with the hobby record's id

map<id,id> ConHobIds = new map<id,id>();
List<id> ConIds = new list<id>();
Contact[] c;

for (Hobbies_Charities__c h :Trigger.new) {
    conHobids.put(h.Name__c, h.ID); //map contact ids and hobby ids
    conids.add(h.Name__c); //storing Contact IDs again to use in soql. is there a way to not have to store this?
}

c = [SELECT ID, Number_Of_Hobby_Records__c, Hobbies_Charities_Record__c FROM Contact WHERE ID IN: conIds]; //select all contacts who are affected by  trigger

//prevent multiple hobby records from being inserted per FA
if (Trigger.isInsert) {
    for (Hobbies_Charities__c hob: Trigger.new) {
        for (Contact con : c) {
            If (hob.name__c == con.id && con.Number_Of_Hobby_Records__c == 1) { 
                hob.adderror('Each Contact can only have one hobby record');
            }
        }
    }
}


if (c.size() > 0) {
    for (integer i = 0; i < c.size(); i++) {
        if ( c[i].Hobbies_Charities_Record__c == Null) {
            c[i].Hobbies_Charities_Record__c = conhobids.get(c[i].Id); //set the hobby record lookupfield equal to related hobby record id
    }   }

    update c;

}    
    
*/    
}