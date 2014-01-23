public with sharing class FormatChildrenDataForSurvey {
 /*  class no longer needed since managers have access to profiling information record
 
   Public static String ConstructAnswer(Child__c ch, Integer cqNum, String Birthdate, String DuplicateInfo) {
       String CF;
       
           CF = '&q' + string.valueof(cqNum) + '=' + ch.ID + '&q' + string.valueof(cqNum + 1) + '=' + ch.Relationship_Type__c + 
           '&q' + string.valueof(cqNum + 2) + '=' + ch.Gender__c + '&q' + string.valueof(cqNum + 3) + '=' + DuplicateInfo + 
           '&q' + string.valueof(cqNum + 4) + '=' + ch.Child_Last_Name__c + '|' + ch.Name + '|' + Birthdate + '|' + 
           ch.Child_Address_1__c + '|' + ch.Child_Address_2__c + '|' + ch.Child_City__c + '|' + ch.Child_State__c + '|' + 
           ch.Child_Zip__c + '|' + ch.Child_School_College__c + '|';

            CF = CF.replace('=null&','=&');
            CF = CF.replace('null|','|');           
       
       system.debug('Constructed CF: ' + CF);
       
       return CF;
   }
       
   public static void PopulateChildFields (Child__c[] children, Contact[] cons, String TriggerType) {

       Integer cqNum = 21; //the position of the first child info question in the profile   
       Integer NumOfQs = 5; //number of questions needed per child
       Integer ChildNum;
       String Birthdate;
       String CF;
       String CiD; //child record's id
      
      //System.debug('Cons Size --------------> ' + cons.Size());
      //System.debug('Children Size --------------> ' + Children.Size());

       For (Child__c ch : children) {       //loop through each parent
          
           For (contact co :cons) { //loop through each child
               if (ch.Parent__c == co.id) { //if the child belongs to the parent
                   
                 //  System.debug('Parent -----------------> ' + co.Name);
                 //  System.debug('Child -----------------> ' + ch.Name);
                   
                   //format the Birthdate to only show the date
                   if (ch.Child_Birthdate__c != Null) {
                       Birthdate = string.valueof(ch.Child_Birthdate__c);
                       Birthdate = BirthDate.replace(' 00:00:00', '');
                   } else {
                       Birthdate = NULL;
                   }
                   
                   CiD = ch.ID;
                   CiD = CiD.substring(0,15);
                   
               //    system.debug('trigger type ---------------> ' + triggertype);
                   system.debug('child id 18---------------> ' + ch.id);
                   system.debug('child id 15 ---------------> ' + CiD);
               //    system.debug('child field 1 -------------------> ' + co.childfieldspart1__c);
                   
                   //Child Field 1 ------------------------
                   //fill in childfieldpart1 if either the trigger is an insert and the field is blank, or if the trigger 
                   //is an update and the field contains the child record's id
                                                      
                   if ((TriggerType == 'Insert' && co.ChildFieldsPart1__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart1__c).contains(CiD))) {
                   
               //    System.debug('Field 1');

                   co.ChildFieldsPart1__c = ConstructAnswer(ch, cqNum, Birthdate, '');
                   
                   //Child Field 2 ------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart2__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart2__c).contains(CiD))) {
                   
                   co.Childfieldspart2__c = ConstructAnswer(ch, cqNum + NumOfQs, Birthdate, '');
                   
                   //Child Field 3 ------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart3__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart3__c).contains(CiD))) {
                   
                   co.Childfieldspart3__c = ConstructAnswer(ch, cqNum + (NumOfQs*2), Birthdate, '');
                   
                   //Child Field 4 ------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart4__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart4__c).contains(CiD))) {
                   
                   co.Childfieldspart4__c = ConstructAnswer(ch, cqNum + (NumOfQs*3), Birthdate, '');
                   
                   //Child Field 5 --------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart5__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart5__c).contains(CiD))) {
                   
                   co.Childfieldspart5__c = ConstructAnswer(ch, cqNum + (NumOfQs*4), Birthdate, '');
                                      
                   //Child Field 6 --------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart6__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart6__c).contains(CiD))) {
                   
                   co.Childfieldspart6__c = ConstructAnswer(ch, cqNum + (NumOfQs*5), Birthdate, '');
                   
                   //Child Field 7 --------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart7__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart7__c).contains(CiD))) {
                   
                   co.Childfieldspart7__c = ConstructAnswer(ch, cqNum + (NumOfQs*6), Birthdate, '');
                   
                   //Child Field 8--------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart8__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart8__c).contains(CiD))) {
                   
                   co.Childfieldspart8__c = ConstructAnswer(ch, cqNum + (NumOfQs*7), Birthdate, '');
                   
                   //Child Field 9--------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart9__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart9__c).contains(CiD))) {
                   
                   co.Childfieldspart9__c = ConstructAnswer(ch, cqNum + (NumOfQs*8), Birthdate, '');
                   
                   //Child Field 10--------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart10__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart10__c).contains(CiD))) {
                   
                   co.Childfieldspart10__c = ConstructAnswer(ch, cqNum + (NumOfQs*9), Birthdate, '');
                   
                   //Child Field 11--------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart11__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart11__c).contains(CiD))) {
                   
                   co.Childfieldspart11__c = ConstructAnswer(ch, cqNum + (NumOfQs*10), Birthdate, '');
                   
                   //Child Field 12--------------------------
                   } else if ((TriggerType == 'Insert' && co.ChildFieldsPart12__c == NULL) || 
                   (TriggerType == 'Update' && String.valueof(co.ChildFieldsPart12__c).contains(CiD))) {
                   
                   co.Childfieldspart12__c = ConstructAnswer(ch, cqNum + (NumOfQs*11), Birthdate, '');                                                          
                           
                   }
               }
           }
           
       }
       
       //update cons;
       
       RemoveDuplicateChildInfo(Children, Cons);
    }
    
    public static void ClearChildFields (Child__c[] children, Contact[] cons, String TriggerType) {
       
       String CiD;
       List<String> chFields = new List<string>();
       Integer FieldDeleted;
       
       For (child__c ch: children) {       //loop through each parent
          
           For (contact co: cons) { //loop through each child
               if (ch.Parent__c == co.id) { //if the child belongs to the parent
               
                chFields.clear(); //clear list to store the childfieldparts values for the next contact
                chFields.add(co.ChildFieldsPart1__c);    
                chFields.add(co.ChildFieldsPart2__c);
                chFields.add(co.ChildFieldsPart3__c);
                chFields.add(co.ChildFieldsPart4__c);
                chFields.add(co.ChildFieldsPart5__c);
                chFields.add(co.ChildFieldsPart6__c);
                chFields.add(co.ChildFieldsPart7__c);
                chFields.add(co.ChildFieldsPart8__c);
                chFields.add(co.ChildFieldsPart9__c);
                chFields.add(co.ChildFieldsPart10__c);
                chFields.add(co.ChildFieldsPart11__c);

               
               CiD = ch.id;
               CiD = CiD.substring(0,15);
                   
               if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart1__c).contains(CiD)) {                                                                                                                                            
                    FieldDeleted = 0; //co.ChildFieldsPart1__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart2__c).contains(CiD)) {
                    FieldDeleted = 1; //co.ChildFieldsPart2__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart3__c).contains(CiD)) {
                    FieldDeleted = 2; //co.ChildFieldsPart3__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart4__c).contains(CiD)) {
                    FieldDeleted = 3; //co.ChildFieldsPart4__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart5__c).contains(CiD)) {
                    FieldDeleted = 4; //co.ChildFieldsPart5__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart6__c).contains(CiD)) {
                    FieldDeleted = 5; //co.ChildFieldsPart6__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart7__c).contains(CiD)) {
                    FieldDeleted = 6; //co.ChildFieldsPart7__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart8__c).contains(CiD)) {
                    FieldDeleted = 7; //co.ChildFieldsPart8__c = '';
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart9__c).contains(CiD)) {
                    FieldDeleted = 8; //co.ChildFieldsPart9__c = '';                                                                                                                                            
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart10__c).contains(CiD)) {
                    FieldDeleted = 9; //co.ChildFieldsPart10__c = '';                                       
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart11__c).contains(CiD)) {
                    FieldDeleted = 10; //co.ChildFieldsPart11__c = '';                                       
               } else if (TriggerType == 'Delete' && String.valueof(co.ChildFieldsPart12__c).contains(CiD)) {
                    co.ChildFieldsPart12__c = ''; //if the child info in the last field is deleted, no need to shift anything into it
               }
               
               
               if (FieldDeleted <=10) {
               system.debug('FieldDeleted: ' + chFields[fieldDeleted]);
               
               for (integer i = fieldDeleted; i < chFields.size()-1; i++) {
                   system.debug('Field After: ' + chFields[i]);
                   if (chFields[i+1] == NULL) {
                       chFields[i] = NULL;
                       break;
                   } else {
                       chFields[i] = chFields[i+1];
                       chFields[i+1] = NULL;
                   }
               }
               }
                co.ChildFieldsPart1__c = chFields[0];    
                co.ChildFieldsPart2__c = chFields[1]; 
                co.ChildFieldsPart3__c = chFields[2]; 
                co.ChildFieldsPart4__c = chFields[3]; 
                co.ChildFieldsPart5__c = chFields[4]; 
                co.ChildFieldsPart6__c = chFields[5]; 
                co.ChildFieldsPart7__c = chFields[6]; 
                co.ChildFieldsPart8__c = chFields[7]; 
                co.ChildFieldsPart9__c = chFields[8]; 
                co.ChildFieldsPart10__c = chFields[9]; 
                co.ChildFieldsPart11__c = chFields[10]; 

                                                                                                               
           }
       }
   }
       update cons;
       //RemoveDuplicateChildInfo(Children, Cons);       
   }
   
   Public Static Void RemoveDuplicateChildInfo(Child__c[] Children, Contact[] Parents) {
        Integer cqNum = 21;
        Integer NumOfQuest = 5;
        Integer questNum;
        Set<ID> ParentIDs = new Set<ID>();
        List<String> chFields = new List<string>();
        String DuplicateInfo;
        String CiD;   
        String Birthdate;
                        
        For (Child__c ch :Children) {
                                             
            CiD = ch.id;
            CiD = CiD.substring(0,15);
        
        
           //format the Birthdate to only show the date
           if (ch.Child_Birthdate__c != Null) {
               Birthdate = string.valueof(ch.Child_Birthdate__c);
               Birthdate = BirthDate.replace(' 00:00:00', '');
           } else {
               Birthdate = NULL;
           }
           
           DuplicateInfo = '|'; //reset duplicate child string for every child
           
            For (Contact p :Parents) {
                
                if (ch.Parent__c == p.id) {
                Integer CFNum = -1;
                Integer AddressMatch = -1;
                Integer SchoolMatch = -1;

                chFields.clear(); //clear list to store the childfieldparts values for the next contact
                chFields.add(p.ChildFieldsPart1__c);    
                chFields.add(p.ChildFieldsPart2__c);
                chFields.add(p.ChildFieldsPart3__c);
                chFields.add(p.ChildFieldsPart4__c);
                chFields.add(p.ChildFieldsPart5__c);
                chFields.add(p.ChildFieldsPart6__c);
                chFields.add(p.ChildFieldsPart7__c);
                chFields.add(p.ChildFieldsPart8__c);
                chFields.add(p.ChildFieldsPart9__c);
                chFields.add(p.ChildFieldsPart10__c);
                chFields.add(p.ChildFieldsPart11__c);
                chFields.add(p.ChildFieldsPart12__c);   
                
                    
                for (integer i = 0; i<chFields.size(); i++) {//loop through each childfieldpart field
                    if (chFields[i] == NULL) {
                        Break;
                    } else {
                        if (chFields[i] != NULL) {
                        
                        system.debug('Child Field ' + string.valueof(i+1) + '----------: ' + chFields[i]);
                        System.debug('Child ID-------: ' + CiD);
                        system.debug('AddressMatch-----------: ' + AddressMatch);
                        system.debug('CF Num-----------: ' + CFNum);
                        system.debug('SchoolMatch: ' + SchoolMatch);
                        
                            if (chFields[i].contains(CiD)) {//check if the field contains the child's id
                                CFNum = i+1;
                                
                                questNum = cqNum + (NumOfQuest*i);
                                
                                system.debug('----------CF contains child id');
                                system.debug('CF Num-----------: ' + CFNum);
                            }    
                            
                            system.debug('Address: ' + ch.Child_Address_1__c);

                            if (AddressMatch < 0 && ch.Child_Address_1__c != NULL && string.valueof(ch.Child_Address_1__c).length() > 12 && 
                            chFields[i].contains(ch.Child_Address_1__c)) {
                                AddressMatch = i+1;
                                
                                system.debug('---------CF contains Address');
                                system.debug('AddressMatch-----------: ' + AddressMatch);
                            } else if (AddressMatch < 0 && ch.Child_Address_1__c == NULL && ch.Child_City__c != NULL && string.valueof(ch.Child_City__c).length() > 12 &&
                             chFields[i].contains(ch.Child_City__c)) { //only replace the city if it is longer than 12 characters, which is the length of 'See Child 11'
                                system.debug('---------CF contains city');
                                AddressMatch = i+1;
                            }
                            
                            system.debug('School: ' + ch.Child_School_College__c);                            
                            
                            if (SchoolMatch < 0 && ch.Child_School_College__c != NULL && string.valueof(ch.Child_School_College__c).length() > 12
                            && chFields[i].contains(ch.Child_School_College__c)) {
                                SchoolMatch = i+1;
                                
                                system.debug('CF contains School');
                                system.debug('SchoolMatch: ' + SchoolMatch);
                            }

                       }
                    }
                 }    
                 system.debug('AddressMatch & CFNum ------------ ' + AddressMatch + ' ' + CFNum);
                 
                if (addressMatch > 0 && addressMatch != CFNum) {
                    if (ch.Child_Address_1__c != NULL) {

                        DuplicateInfo = '1' + DuplicateInfo;
                        chFields[CFNum-1] = ConstructAnswer(ch,questNum, Birthdate, DuplicateInfo);                    
                        chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_Address_1__c, 'See Child ' + string.valueof(addressMatch));    
                        system.debug('Address Replace: ' + chFields[CFNum-1]);
                    } 
                    if (ch.Child_Address_2__C != NULL) {
                        chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_Address_2__c, '');
                        system.debug('Address Replace: ' + chFields[CFNum-1]);    
                    }
                    if (ch.Child_City__c != NULL) {
                        if (ch.Child_Address_1__c == NULL) {
                            DuplicateInfo = '1' + DuplicateInfo;
                            chFields[CFNum-1] = ConstructAnswer(ch,questNum, Birthdate, DuplicateInfo);                    
                            chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_City__c, 'See Child ' + string.valueof(addressMatch));    

                        } else {
                            chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_City__c, '');        
                        }
                        system.debug('Address Replace: ' + chFields[CFNum-1]);
                    }
                    if (ch.Child_State__c != NULL) {
                        chFields[CFNum-1] = chFields[CFNum-1].replace('|' + ch.Child_State__c + '|', '||');    
                        system.debug('Address Replace: ' + chFields[CFNum-1]);
                    }
                    if (ch.Child_Zip__c != NULL) {
                        chFields[CFNum-1] = chFields[CFNUm-1].replace(ch.Child_Zip__c, '');
                        system.debug('Address Replace: ' + chFields[CFNum-1]);
                    }
                }
                
                system.debug('SchoolMatch & CFNum ------------ ' + SchoolMatch + ' ' + CFNum);
                if (SchoolMatch >0 && SchoolMatch != CFNum) {
                    system.debug('School to Replace: ' + chFields[CFNum-1]);
                    if (ch.Child_School_College__C != NULL) {
                    DuplicateInfo = DuplicateInfo + '2|';
                    chFields[CFNum-1] = ConstructAnswer(ch,questNum, Birthdate, DuplicateInfo);
                    chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_School_College__c, 'See Child ' + string.valueof(schoolMatch));
                    if (DuplicateInfo == '1|2|') {
                        chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_Address_1__c, 'See Child ' + string.valueof(addressMatch));
                        chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_City__c, '');
                        chFields[CFNum-1] = chFields[CFNum-1].replace('|' + ch.Child_State__c + '|', '||');
                        chFields[CFNum-1] = chFields[CFNum-1].replace(ch.Child_Zip__c, '');

                    }
                    
                    }
                }
               
                p.ChildFieldsPart1__c = chFields[0];   
                p.ChildFieldsPart2__c = chFields[1]; 
                p.ChildFieldsPart3__c = chFields[2]; 
                p.ChildFieldsPart4__c = chFields[3]; 
                p.ChildFieldsPart5__c = chFields[4]; 
                p.ChildFieldsPart6__c = chFields[5]; 
                p.ChildFieldsPart7__c = chFields[6]; 
                p.ChildFieldsPart8__c = chFields[7]; 
                p.ChildFieldsPart9__c = chFields[8]; 
                p.ChildFieldsPart10__c = chFields[9]; 
                p.ChildFieldsPart11__c = chFields[10]; 
                p.ChildFieldsPart12__c = chFields[11];
                
                system.debug('p.CF1: ' + p.ChildFieldsPart1__c);
                system.debug('p.CF2: ' + p.ChildFieldsPart2__c);
                system.debug('p.CF3: ' + p.ChildFieldsPart3__c);
                system.debug('p.CF4: ' + p.ChildFieldsPart4__c);
                system.debug('p.CF5: ' + p.ChildFieldsPart5__c);
                system.debug('p.CF6: ' + p.ChildFieldsPart6__c);
                system.debug('p.CF7: ' + p.ChildFieldsPart7__c);
                system.debug('p.CF8: ' + p.ChildFieldsPart8__c);
                system.debug('p.CF9: ' + p.ChildFieldsPart9__c);
                system.debug('p.CF10: ' + p.ChildFieldsPart10__c);
                system.debug('p.CF11: ' + p.ChildFieldsPart11__c);
                system.debug('p.CF12: ' + p.ChildFieldsPart12__c);

                }
                
            }
            

        }

        update Parents; 
        for (integer i = 0; i<parents.size();i++) {
            system.debug('parents.CF1: ' + parents[i].ChildFieldsPart1__c);
            system.debug('parents.CF2: ' + parents[i].ChildFieldsPart2__c);
            system.debug('parents.CF3: ' + parents[i].ChildFieldsPart3__c);
            system.debug('parents.CF4: ' + parents[i].ChildFieldsPart4__c);
            system.debug('parents.CF5: ' + parents[i].ChildFieldsPart5__c);
            system.debug('parents.CF6: ' + parents[i].ChildFieldsPart6__c);
            system.debug('parents.CF7: ' + parents[i].ChildFieldsPart7__c);
            system.debug('parents.CF8: ' + parents[i].ChildFieldsPart8__c);
            system.debug('parents.CF9: ' + parents[i].ChildFieldsPart9__c);
            system.debug('parents.CF10: ' + parents[i].ChildFieldsPart10__c);
            system.debug('parents.CF11: ' + parents[i].ChildFieldsPart11__c);
            system.debug('parents.CF12: ' + parents[i].ChildFieldsPart12__c);
        }
    }
   */
}