trigger CreateRPCSerivcesResponseString on RPC_Consulting_Contract__c (after insert, after update) {

/*when a rpc contract is created or updated with checked services marked, this trigger will generate
the string that will be stored in the Services_Provided_Response_String__c field
and then attached to the clicktools form url to prepopulate the attestation form with
the correct services checked*/

List<ID> UpdatedRPCContractIDs = new List<ID>();
String ResponseString = '';

for (RPC_Consulting_Contract__c rpc : trigger.new) {
    
    if (trigger.isUpdate) {
        RPC_Consulting_Contract__c oldRPC = trigger.oldmap.get(rpc.id);
        
        if (
        (rpc.Investment_Policy_Review__c != oldrpc.Investment_Policy_Review__c) ||
        (rpc.Diversified_Review__c != oldrpc.Diversified_Review__c) ||
        (rpc.Vendor_Investment_Option_Review__c != oldrpc.Vendor_Investment_Option_Review__c) ||
        (rpc.Vendor_Search_and_Review__c != oldrpc.Vendor_Search_and_Review__c) ||
        (rpc.Participant_Education__c != oldrpc.Participant_Education__c)
        ) {
        
            UpdatedRPCContractIDs.add(rpc.id);
            
        }
        
    } else if (trigger.isInsert) {
        
        UpdatedRPCContractIDs.add(rpc.id);
            
    }
        
}

if (UpdatedRPCContractIDs.size() > 0) {
    
    Map<ID, RPC_Consulting_Contract__c> RPCContracts = new Map<ID, RPC_Consulting_Contract__c>(
    [SELECT Effective_Date__c, Investment_Policy_Review__c,
    Diversified_Review__c, Vendor_Investment_Option_Review__c, Vendor_Search_and_Review__c, 
    Participant_Education__c, Services_Provided_Response_String__c FROM RPC_Consulting_Contract__c WHERE
    ID IN : UpdatedRPCContractIDs]);
    
    
    for (RPC_Consulting_Contract__c rpc : RPCContracts.Values()) {
            
        if (rpc.Investment_Policy_Review__c == True) { ResponseString = '1|';
        } else { ResponseString = '|'; } 
        
        if (rpc.Diversified_Review__c == True) { ResponseString += '2|';
        } else { ResponseString += '|'; } 
        
        if (rpc.Vendor_Investment_Option_Review__c == True) { ResponseString += '3|';
        } else { ResponseString += '|'; } 
        
        if (rpc.Vendor_Search_and_Review__c == True) { ResponseString += '4|';
        } else { ResponseString += '|'; } 
        
        if (rpc.Participant_Education__c == True) { ResponseString += '5|';
        } else { ResponseString += '|'; } 
        
        rpc.Services_Provided_Response_String__c = ResponseString;
        
       
    }

    
    try {
        update RPCContracts.Values();

    } catch (Exception e) {
        for (RPC_Consulting_Contract__c rpc : RPCContracts.Values()) {
            trigger.newmap.get(rpc.id).adderror('Error Occurred: ' + e.getMessage() + ' : Contact your administrator');
        }
    }
    

}
        
}