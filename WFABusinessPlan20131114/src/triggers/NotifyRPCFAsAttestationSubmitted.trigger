trigger NotifyRPCFAsAttestationSubmitted on RPC_Consulting_Contract_Members__c (after update) {

/*on a rpc contract with multiple FAs, after 1 FA submits his form, a notification goes out to 
all the members notifying them of the submission, and that the other members do not need to submit theirs*/

//multiple FAs = Total Contract Members > 1
//submission = when fa signature, date, and attestation submitted are populated
//first submission = when Total Attestation Received (after update) = 1


List<List<string>> AllFAEmails = new List<List<string>>();
List<string> FAEmails = new List<string>();
Set<ID> RPCContractIDs = new Set<ID>();
List<ID> ContactIDs = new List<ID>();

Map<ID, RPC_Consulting_Contract__c> RPCContractMap = new Map<ID, RPC_Consulting_Contract__c>([SELECT
Total_Contract_Members__c, Total_Attestations_Received__c FROM RPC_Consulting_Contract__c WHERE
Effective_Date__c != null AND Status__c = 'Active' AND Total_Contract_Members__c > 1 
AND Total_Attestations_Received__c = 0]); //map of Active RPC contracts with multiple members and just had 1 submit attestation

system.debug('Mult Member RPC Contracts -------------- ' + RPCContractMap);

for (RPC_Consulting_Contract_Members__c rpcm : trigger.new) {
    RPC_Consulting_Contract_Members__c oldrpcm = trigger.oldmap.get(rpcm.id);
    
    system.debug('Get RPC FA contract ----------- ' + RPCContractMap.get(rpcm.RPC_Consulting_Contract__c));
    
    if (rpcm.Attestation_Submitted__c == True && oldrpcm.Attestation_Submitted__c == False &&
    RPCContractMap.get(rpcm.RPC_Consulting_Contract__c) <> null) {//if FA has submitted his form on a multi member contract
        
        RPCContractIDs.add(rpcm.RPC_Consulting_Contract__c); //store ids of contracts that have received its first attestation submission        
        
    }
}
    
if (RPCContractIDs.size()>0) {
    system.debug('RPC Contact IDs ----------- ' + RPCContractIDs);
    
    //select list of fas with emails from multi member rpc contracts. order list by contract id, which essentially groups the rpc member records by contract id
    RPC_Consulting_Contract_Members__c[] RPCMembers = [SELECT FA_Email__c,
    RPC_Consulting_Contract__c, Notify_Of_Attestation_Submission__c FROM RPC_Consulting_Contract_Members__c WHERE
    FA_Email__c != null AND RPC_Consulting_Contract__c IN : RPCContractIDs ORDER BY RPC_Consulting_Contract__c ASC];
    
    if (RPCMembers.size() > 0) {
        
        system.debug('RPC Contract Members ----------- ' + RPCMembers);
        
        for (RPC_Consulting_Contract_Members__c rpcm : RPCMembers) {
            
            rpcm.Notify_Of_Attestation_Submission__c = True; //this will fire a workflow to notify member that someone on their team has submitted the attestation
        
        }
        
        try {
            update RPCMembers;
        } catch (Exception e) {
            for (RPC_Consulting_Contract_Members__c rpcm : RPCMembers) {
                rpcm.adderror('Error occurred: ' + e.getMessage() + ' - Notification of Attestation Submission did not go to FA. Please contact your administrator');
            }
        }
    }
}
}