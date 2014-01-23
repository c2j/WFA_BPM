public with sharing class ReshiftChildFieldParts {
 /*  class no longer needed since managers have access to profiling information record
 
    Public static String ReformatQuestionNumbers(String ChildField, integer cqNum) {
  
    integer q1pos;
    integer q2pos;
    integer q3pos;
    integer q4pos;
    String FieldVal;
    String q1;
    String q2;
    String q3;
    String q4; 
   
    FieldVal = ChildField;
    
    //system.debug('Field Value : ' + fieldval);
    
    //get the positions of the question numbers
    q1Pos = FieldVal.indexof('=');
   // system.debug('q1pos : ' + q1Pos);
    
    if (q1Pos < 15) {
        q2Pos = FieldVal.indexof('=', q1Pos+1);         
        q3Pos = FieldVal.indexof('=', q2Pos+1);
        q4Pos = FieldVal.indexof('=', q3Pos+1);                    
        

   //     system.debug('q2pos : ' + q2Pos);
   //     system.debug('q3pos : ' + q3Pos);
   //     system.debug('q4pos : ' + q4Pos);
        
        q1 = FieldVal.substring(q1Pos - 4, q1Pos+1); //this extracts the first question number, &qXX=. assumes all child question numbers are two digits
         system.debug('q1 : ' + q1);
        
        q2 = FieldVal.substring(q2Pos - 4, q2Pos+1);
        system.debug('q2 : ' + q2);
            
        q3 = FieldVal.substring(q3Pos - 4, q3Pos+1);
        system.debug('q3 : ' + q3);    
        
        q4 = FieldVal.substring(q4Pos - 4, q4Pos+1);
        system.debug('q4 : ' + q4);    
    
     //   System.debug('cqNum : ' + cqNum);
                

            FieldVal = FieldVal.replace(q1, '&q' + string.valueof(cqNum) + '=');
            System.debug('Updated q1 Field Val : ' + fieldval);

         
        FieldVal = FieldVal.replace(q2, '&q' + string.valueof(cqNum + 1) + '=');
        System.debug('Updated q2 Field Val : ' + fieldval);
        FieldVal = FieldVal.replace(q3, '&q' + string.valueof(cqNum + 2) + '=');
        System.debug('Updated q3 Field Val : ' + fieldval);
        FieldVal = FieldVal.replace(q4, '&q' + string.valueof(cqNum + 3) + '=');    
        
        System.debug('Updated q4 Field Val : ' + fieldval);
    }
    return FieldVal;  
    
    }
   
   Public static void ReshiftChildFields(Contact[] cons) { //, Integer FirstChangedField) {
       Integer cqNum = 21;
       Integer NumOfQs = 5;
       List<String> chFields = new List<String>();
             
   for (contact c :cons) {    

       if (c.ChildFieldsPart1__c != NULL) {
           c.ChildFieldsPart1__c = ReformatQuestionNumbers(c.ChildFieldsPart1__c, cqNum);
           
       } 
       if (c.ChildFieldsPart2__c != NULL) {
           c.ChildFieldsPart2__c = ReformatQuestionNumbers(c.ChildFieldsPart2__c, cqNum + NumOfQs);
           
       }
       if (c.ChildFieldsPart3__c != NULL) {
           c.ChildFieldsPart3__c = ReformatQuestionNumbers(c.ChildFieldsPart3__c, cqNum + (NumOfQs*2));
           
       }
       if (c.ChildFieldsPart4__c != NULL) {
           c.ChildFieldsPart4__c = ReformatQuestionNumbers(c.ChildFieldsPart4__c, cqNum + (NumOfQs*3));
           
       }
       if (c.ChildFieldsPart5__c != NULL) {
           c.ChildFieldsPart5__c = ReformatQuestionNumbers(c.ChildFieldsPart5__c, cqNum + (NumOfQs*4));
           
       }
       if (c.ChildFieldsPart6__c != NULL) {
           c.ChildFieldsPart6__c = ReformatQuestionNumbers(c.ChildFieldsPart6__c, cqNum + (NumOfQs*5));
           
       }
       if (c.ChildFieldsPart7__c != NULL) {
           c.ChildFieldsPart7__c = ReformatQuestionNumbers(c.ChildFieldsPart7__c, cqNum + (NumOfQs*6));
           
       }
       if (c.ChildFieldsPart8__c != NULL) {
           c.ChildFieldsPart8__c = ReformatQuestionNumbers(c.ChildFieldsPart8__c, cqNum + (NumOfQs*7));
           
       }
       if (c.ChildFieldsPart9__c != NULL) {
           c.ChildFieldsPart9__c = ReformatQuestionNumbers(c.ChildFieldsPart9__c, cqNum + (NumOfQs*8));

       }
       if (c.ChildFieldsPart10__c != NULL) {
           c.ChildFieldsPart10__c = ReformatQuestionNumbers(c.ChildFieldsPart10__c, cqNum + (NumOfQs*9));                                                                 
           
       }
       if (c.ChildFieldsPart11__c != NULL) {
           c.ChildFieldsPart11__c = ReformatQuestionNumbers(c.ChildFieldsPart11__c, cqNum + (NumOfQs*10));

       }
       if (c.ChildFieldsPart12__c != NULL) {
           c.ChildFieldsPart12__c = ReformatQuestionNumbers(c.ChildFieldsPart12__c, cqNum + (NumOfQs*11));
       }                                                                                                                
   }
       //update cons;
   }           
*/
}