Public Class GetContactBasedOnANumbers {

    Public static Map<ID, ID> formatANumber(Map<ID, String> ANumbers) {
    
    Map<String, ID> ANumToRecID = new Map<String, ID>(); //to store correctly formatted a numbers
    Map<ID, ID> RecIDToCon = new Map<ID, ID>();
    Map<ID, String> anums = ANumbers;
    String anum = '';
    
    system.debug('ANumbers Map ------------- ' + ANumbers);
    
        for (id i: anums.keyset()) {
            //remove any possible non letter or number strings
            anum = anums.get(i);
            
            anum = anum.replaceAll(' ' ,'');
            //anum = anum.replaceAll('/' ,'');
            //anum = anum.replaceAll('-' ,'');
            //anum = anum.replaceAll('.' ,'');
            
            system.debug('anum ----------- ' + anum);
            
            if (anum.startsWith('0') || anum.startsWith('1')|| anum.startsWith('2') || 
            anum.startsWith('3') || anum.startsWith('4') || anum.startsWith('5') ||
            anum.startsWith('6') || anum.startsWith('7') || anum.startsWith('8') ||
            anum.startsWith('9')) {//makes sure the a number does not start with a number
           
                ANumToRecID.put('A'+anum,i); //map a number starting with A to record id
            
                ANumToRecID.put('X'+anum,i); //map a number starting with X to record id                
                
            } else if(anum.substring(0,1).toUpperCase() != 'A' && anum.substring(0,1).toUpperCase() != 'X') {
                
                anum = anum.replace(anum.substring(0,1), '');
                
                ANumToRecID.put('A'+anum,i); //map a number starting with A to record id
            
                ANumToRecID.put('X'+anum,i); //map a number starting with X to record id         
                        
            } else {
                
                ANumToRecID.put(anum.toUpperCase(),i);
            }
                          
        }
        
        system.debug('formatted A numbers map ------- ' + ANumToRecID);
        
        //query contact record where A Number is in the ConByANum map. Since the map contains both A and X versions of the a number
        //the query will cover contacts who submit an a number with a letter but have the X version
        Contact[] cons = [SELECT ID, A_Number__c FROM Contact WHERE A_Number__c IN : ANumToRecID.keyset()]; 
        
        system.debug('Contacts with A Numbers ------------- ' + cons);
        string cANum = '';
        
        if (cons.size()>0) {
            for (contact c : cons) {
                cANum = c.A_Number__c;        
                RecIDToCon.put(ANumToRecID.get(cANum.toUpperCase()), c.id); //match record id to contact id via same A Number
            }
        }
        
    return RecIDToCon;
    }
    
}