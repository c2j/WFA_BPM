trigger UpdateDialInfoOnFATalent on Task (before insert, before update) {

/*When a FARS or RBC/RBD team member completes an activity on an FA talent or Effort, the Dial, Dialer, and Last Modified
AV2/LM) Date needs to be updated. Dial should increase by the number of completed activities, the Dialer should
equal the person logging the completed activity, and the Last Modified Date should be the current date.*/

List<ID> FATalentIDs = new List<ID>();
List<ID> EffortIDs = new List<ID>();
List<ID> UserIDs = new List<ID>();
List<ID> roleIds = new List<Id>();
//User[] users;
//UserRole[] roles;
Boolean RunTrigger = FALSE;
FA_Talent__c[] FATalents;
String OppPrefix = Schema.SObjectType.Opportunity.getKeyPrefix();
String FATalentPrefix = Schema.SObjectType.FA_Talent__c.getKeyPrefix();

//FARS activity recid 01250000000UJQA in production
//WSI FAI task activity recid 01250000000UIqp in production

for (Task t :Trigger.new) {
    
    
if (t.WhatID != NULL) {
    If (Trigger.isInsert) {
        RunTrigger = True;
    } else if (Trigger.isUpdate) {
        if ((t.Type != trigger.oldmap.get(t.id).Type)||(t.Status != trigger.oldmap.get(t.id).Status)) {
            if (t.Activity_Type_2__c == trigger.oldmap.get(t.id).Activity_Type_2__c) {
                system.debug('---------------Update Dial Info Trigger------------');
                system.debug('Old Activity Type 2: ' + trigger.oldmap.get(t.id).activity_Type_2__c);
                system.debug('New Activity Type 2: ' + t.activity_Type_2__c);
                system.debug('Old Type: ' + trigger.oldmap.get(t.id).type);
                system.debug('New Type: ' + t.type);
                system.debug('Old Status: ' + trigger.oldmap.get(t.id).Status);
                system.debug('New Type: ' + t.Status);            
                               
                RunTrigger = True;
            }
        } else {
            RunTrigger = False;
        }
    }
    
    if (RunTrigger) {
    String RelatedToID = String.Valueof(t.WhatID); //get string version of task What (related to) ID
    
    if ((t.Recordtypeid == '01250000000UJQA' || t.RecordTypeid == '01250000000UIqp') && 
    (t.Type.contains('Call') || t.Type.contains('Phone')) && t.Status == 'Complete') {
    
        if (RelatedToID.startsWith(FATalentPrefix)) { //activity on FATalent
            //System.debug('FA talent ID ----------> ' + t.WhatID);
            FATalentIDs.add(t.WhatID);
        } else if (RelatedToID.startsWith(OppPrefix)) { //activity on Effort
            EffortIDs.add(t.WhatID);
            //System.debug('Effort ID ----------> ' + t.WhatID);        
        }
    
        UserIDs.add(t.OwnerID);
    }
    }
}
}

If (EffortIDs.size() > 0) { //extract all the related FA talent ids from each effort

Opportunity[] FARSEfforts = [SELECT FA_Talent_Name__c FROM OPPORTUNITY WHERE ID IN: EffortIDs];

for (Integer i = 0; i<FARSEfforts.Size(); i++) {
    FATalentIDS.add(FARSEfforts[i].FA_Talent_Name__c); //append the FA talent ids to the list of fa talent ids
}
}       
    system.debug('FA Talent IDS ----------> ' + FATalentIDs);
    system.debug('User IDS ----------> ' + UserIDs);
    
If (FATalentIDs.size() > 0) {

    Map<ID, User> users = new Map<ID, User>([SELECT ID, Name, UserRoleId FROM USER WHERE IsActive = True]);
    Map<ID, UserRole> userRoles = new Map<ID, UserRole>([SELECT ID, Name FROM UserRole]);
        
    Map<ID, String> FaTalDialer = new Map<ID, String>();
    Map<ID, String> FaTalDialerRole = new Map<ID, String>();

    system.debug('FATalentIDs size: ' + FATalentIDs.size());
    system.debug('UserIDs size: ' + UserIDs.size());
    system.debug('Users size: ' + users.values().size());
    system.debug('Roles size: ' + userRoles.values().size());  
    
    //Map each FAtalentID to a User and user role
    for (integer f = 0; f<FATalentIDs.size(); f++){
    for (integer u = 0; u<UserIDs.size(); u++){
        
           
         //   if (UserIds[i] == u.id) {
                FaTalDialer.put(FaTalentIds[f], users.get(UserIDs[u]).name);
                FATalDialerRole.put(FaTalentIds[f], userRoles.get(users.get(UserIDs[u]).UserRoleID).Name);
          //  }
        }
    }


    FATalents = [SELECT ID, Name, Dials__c, Dialer__c, Dialer_Role__c, AV2_Date__c FROM FA_Talent__c WHERE ID IN: FATalentIDs];
    
    system.debug('FATalents --------------> ' + FATalents);
    
    //FATalents.size < FATalentIDs.size, because the former contains unique values. So need to loop through both
    //to account for FA talents are affected by activites on both the talent and effort records 
    for (Integer i = 0;i<FATalentIDs.size();i++) {
        for (Integer j = 0; j<FATalents.size();j++) {
            If (FATalentIDs[i] == FATalents[j].id) {
   
                //system.debug('User -----------> ' + users[j].name);
                //system.debug('FT Name -----------> ' + FATalents[j].Name);
                
                if (System.now().date() != FATalents[j].AV2_Date__c) {
                    FATalents[j].Dials__c = 0; //reset number of dials to 0 at start of each day
                }
                FATalents[j].Dials__c++;
                FATalents[j].Dialer__c = FATalDialer.get(FATalentIDS[i]); //user name
                FATalents[j].Dialer_Role__c = FATalDialerRole.get(FATalentIDS[i]); //user's role
                FATalents[j].AV2_Date__c = System.now().date();

                break;
                /*system.debug('Dials -----------> ' + FATalents[j].Dials__c);
                system.debug('Dialer -----------> ' + FATalents[j].Dialer__c);
                system.debug('Dialer Role -----------> ' + FATalents[j].Dialer_Role__c);                
                system.debug('Last Modified Date -----------> ' + FATalents[j].AV2_Date__c);*/
            }
        }
    }
    Update FATalents;

for (Integer f = 0; f<FAtalents.size(); f++){
    system.debug('FT Name = ' + FATalents[f].Name + ' Dials = ' + FATalents[f].Dials__c + 
    ' Dialer = ' + FATalents[f].Dialer__c + ' Dialer Role = ' + FATalents[f].Dialer_Role__c + 
    ' AV2 Date = ' + FATalents[f].AV2_Date__c);
}

}




}