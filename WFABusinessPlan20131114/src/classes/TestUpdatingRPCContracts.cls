@isTest

Private Class TestUpdatingRPCContracts {

Static testMethod void TestUpdatingCheckedServices () {

List<RPC_Consulting_Contract__c> RPCContracts = new List<RPC_Consulting_Contract__c>();

for (integer i = 0; i<5; i++) {
    
    RPC_Consulting_Contract__c rpc = new RPC_Consulting_Contract__c (
    Name = 'Test RPC ' + i,Effective_Date__c = Date.newinstance(2012,10,25), Investment_Policy_Review__c = True, 
    Diversified_Review__c = False,
    Vendor_Investment_Option_Review__c = True, Vendor_Search_and_Review__c = False, Participant_Education__c = False);
    
    RPCContracts.add(rpc);
    
}

for (integer i = 5; i<10; i++) {
    
    RPC_Consulting_Contract__c rpc = new RPC_Consulting_Contract__c (
    Name = 'Test RPC ' + i, Investment_Policy_Review__c = False, Diversified_Review__c = True,
    Vendor_Investment_Option_Review__c = False, Vendor_Search_and_Review__c = True, Participant_Education__c = True);
    
    RPCContracts.add(rpc);
    
}



test.startTest();

insert RPCContracts;

RPC_Consulting_Contract__c[] rpcs = [SELECT Services_Provided_Response_String__c FROM RPC_Consulting_Contract__c
                                    WHERE Services_Provided_Response_String__c = '1||3|||'];
               
System.assertequals(rpcs.size(),5);

rpcs = [SELECT Services_Provided_Response_String__c FROM RPC_Consulting_Contract__c
                                    WHERE Services_Provided_Response_String__c = '|2||4|5|'];
                                    
System.assertequals(rpcs.size(),5);

RPC_Consulting_Contract_Members__c rpcm1 = new RPC_Consulting_Contract_Members__c(RPC_Consulting_Contract__c=RPCContracts[0].id);
RPC_Consulting_Contract_Members__c rpcm2 = new RPC_Consulting_Contract_Members__c(RPC_Consulting_Contract__c=RPCContracts[1].id);
RPC_Consulting_Contract_Members__c rpcm3 = new RPC_Consulting_Contract_Members__c(RPC_Consulting_Contract__c=RPCContracts[2].id);
RPC_Consulting_Contract_Members__c rpcm4 = new RPC_Consulting_Contract_Members__c(RPC_Consulting_Contract__c=RPCContracts[6].id, Attestation_Submitted__c = False, FA_Email__c='jerry.yu@wellsfargoadvisors.com');
RPC_Consulting_Contract_Members__c rpcm5 = new RPC_Consulting_Contract_Members__c(RPC_Consulting_Contract__c=RPCContracts[6].id, Attestation_Submitted__c = False, FA_Email__c='jerry.yu@wellsfargoadvisors.com');
RPC_Consulting_Contract_Members__c rpcm6 = new RPC_Consulting_Contract_Members__c(RPC_Consulting_Contract__c=RPCContracts[7].id);

insert rpcm1;
insert rpcm2;
insert rpcm3;
insert rpcm4;
insert rpcm5;
insert rpcm6;

for (integer i = 0; i <5; i++) {

    RPCContracts[i].Diversified_Review__c = True;
    RPCContracts[i].Vendor_Search_and_Review__c = True;
    RPCContracts[i].Participant_Education__c = True;
    RPCContracts[i].Effective_Date__c = null;
}

for (integer i = 5; i <10; i++) {

    RPCContracts[i].Diversified_Review__c = False;
    RPCContracts[i].Vendor_Search_and_Review__c = False;
    RPCContracts[i].Participant_Education__c = False;
    RPCContracts[i].Effective_Date__c = Date.Newinstance(2012,10,12);
    RPCContracts[i].Status__c = 'Active';
}

Update RPCContracts;

rpcs = [SELECT Services_Provided_Response_String__c FROM RPC_Consulting_Contract__c
                                    WHERE Services_Provided_Response_String__c = '|||||']; //all false
                                    
System.assertequals(rpcs.size(),5);


rpcs = [SELECT Services_Provided_Response_String__c FROM RPC_Consulting_Contract__c
                                    WHERE Services_Provided_Response_String__c = '1|2|3|4|5|']; //all true
                                    
System.assertequals(rpcs.size(),5);

RPC_Consulting_Contract_Members__c[] rpcm = [SELECT Schedule_Future_Attestation_Email__c FROM RPC_Consulting_Contract_Members__c
WHERE Schedule_Future_Attestation_Email__c = True];

system.assertequals(rpcm.size(),3);

rpcm = [SELECT Schedule_Future_Attestation_Email__c FROM RPC_Consulting_Contract_Members__c
WHERE Schedule_Future_Attestation_Email__c = False];

system.assertequals(rpcm.size(),3);


//One member of an active contract submits his form
rpcm4.Attestation_Submitted__c = true;

update rpcm4;

//rpcm4, rpcm5, rpcm6 should all have the "notify of attestation submission" field marked true
rpcm = [SELECT Schedule_Future_Attestation_Email__c FROM RPC_Consulting_Contract_Members__c
WHERE Notify_Of_Attestation_Submission__c = True];

system.assertequals(rpcm.size(),2);

test.StopTest();






}
}