trigger ScheduleRPCAttestation on RPC_Consulting_Contract__c (after insert, after update) {

/* this trigger populates the Schedule Future Attestation Email field on the related 
RPC Contract Members record if effective date is filled in or cleared on the contract record. This will
fire a workflow to schedule attestation email to go out or cancel queued attestation emails*/

List<ID> UpdatedRPCContractIDs = new List<ID>();
String ResponseString = '';

for (RPC_Consulting_Contract__c rpc : trigger.new) {
    
    if (trigger.isUpdate) {
        RPC_Consulting_Contract__c oldRPC = trigger.oldmap.get(rpc.id);
        
        if ((oldRPC.Effective_Date__c == null && rpc.Effective_Date__c != null) ||  
        (oldRPC.Effective_Date__c != null && rpc.Effective_Date__c == null) ||
        (oldRPC.Status__c != 'Active' && rpc.Status__c == 'Active') ||
        (oldRPC.Status__c == 'Active' && rpc.Status__c != 'Active')) { //if the effective date changes between a value and null or if the status changes between active and another value
         
            system.debug('------RPC Contract effective date changed-----------');
            UpdatedRPCContractIDs.add(rpc.id);
            
        }
        
    } else if (trigger.isInsert) {
        
        if (rpc.Effective_Date__c != null && rpc.status__c == 'Active') {
        
            UpdatedRPCContractIDs.add(rpc.id);
        }
            
    }
        
}

if (UpdatedRPCContractIDs.size() > 0) {
    
    List<String> FAEmails = new List<String>();
    
    RPC_Consulting_Contract_Members__c[] RPCMembers = [SELECT Schedule_Future_Attestation_Email__c, 
    Email_Attestation_Immediately__c, RPC_Consulting_Contract__c FROM 
    RPC_Consulting_Contract_Members__c WHERE RPC_Consulting_Contract__c IN : UpdatedRPCContractIDs];
    
    system.debug('RPC Members -------- ' + RPCMembers);
    
    Map<ID, RPC_Consulting_Contract__c> RPCContracts = new Map<ID, RPC_Consulting_Contract__c>(
    [SELECT Effective_Date__c, Status__c FROM RPC_Consulting_Contract__c WHERE
    ID IN : UpdatedRPCContractIDs]);
    
    for (RPC_Consulting_Contract_Members__c rpcmem : RPCMembers) {
    
        system.debug('rpc contract effective date -------- ' + RPCContracts.get(rpcmem.RPC_Consulting_Contract__c).Effective_Date__c);
        
        if (RPCContracts.get(rpcmem.RPC_Consulting_Contract__c).Effective_Date__c != null &&
            RPCContracts.get(rpcmem.RPC_Consulting_Contract__c).Status__c == 'Active') { //schedule attestation emails only for active contracts with effective dates
            system.debug('--------RPC Contract Effective Date not null---------');
            rpcmem.Schedule_Future_Attestation_Email__c = True;
        } else {
            rpcmem.Schedule_Future_Attestation_Email__c = False;
            rpcmem.Email_Attestation_Immediately__c = False;
        }
    }
    
    try {
        update RPCMembers;
        
        system.debug('-----RPC Members updated-------');
    } catch (Exception e) {
        for (RPC_Consulting_Contract__c rpc : RPCContracts.Values()) {
            trigger.newmap.get(rpc.id).adderror('Error Occurred: ' + e.getMessage() + ' : Contact your administrator');
        }
    }
    

}
        
        



}