public class vfBLSGReferralFormCtrlr {

    public Lending_Referrals__c Referral {get;set;}
    public String ReferralID {get;set;}
    public String Alerts {get;set;}
    public String ClosePage;
    
    Public vfBLSGReferralFormCtrlr() {
        
        //if (ReferralID == Null) {
        
            Referral = new Lending_Referrals__c();
            
            //BLSG Production Referral Record Type ID 01250000000UNIi//BLSG Sandbox Referral Record Type ID '012P0000000Cvrx';
            Referral.RecordTypeID = '01250000000UNIi'; 
        //}
    
    }
    
    public boolean ConfirmChecklist() {
        if(!Referral.May_Receive_Financial_Or_Other_Benefit__c || !Referral.Forward_ADF_to_Client__c ||
        !Referral.Client_Gave_Permission_for_Referral__c || !Referral.Client_Gave_Permission_to_Share_Info__c) {
            return false;
        } else {
            return true;
        }
    }  
    
    
    public PageReference SubmitReferral() {
        
        if (Referral.id == NULL) {
                
            try {
                
                //Contact FA  = [SELECT ID, Account.Regional_Banking_Consultant__c, Account.Business_Lending_Consultant__c FROM Contact WHERE
                //                ID =: Referral.FA_Name__c];
                
                //system.debug('Referral FA ID --------- ' + FA.ID);               
                //system.debug('Referral FA MGDC --------- ' + FA.Account.Regional_Banking_Consultant__c); 
                //system.debug('Referral FA RBC --------- ' + FA.Account.Business_Lending_Consultant__c);   
                                             
                //User MktGrDevCons = [SELECT ID FROM User WHERE Name =: FA.Account.Business_Lending_Consultant__c];
                
                //User RBC = [SELECT ID FROM User WHERE Name =: FA.Account.Regional_Banking_Consultant__c];
                
                //system.debug('MGDC --------- ' + MktGrDevCons);               
                //system.debug('RBC --------- ' + RBC);     
                                
                //if (MktGrDevCons != null) {
                    
                //    Referral.Business_Lending_Consultant__c = MktGrDevCons.ID;
                    
                //} else {
                
                //    Referral.Business_Lending_Consultant__c = '00550000000o9hB'; //default to pat wrischnik;
                    
                //}
                      
                //if (RBC != null) {
                    
                //    Referral.Regional_Banking_Consultant__c = RBC.ID;
                    
                //}
                
                //system.debug('Referral MGDC --------- ' + Referral.Business_Lending_Consultant__c);               
                //system.debug('Referral RBC --------- ' + Referral.Regional_Banking_Consultant__c);                
                
                
                if(ConfirmChecklist()) {
                    
                    system.debug('-----------inserting blsg lending referral record--------------');
                    
                    insert Referral;
 
                } else {
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check all agreement checkboxes before submitting.'));
                    
                    return null;
                }

                
            } catch (exception e) {
                system.debug('***Error inserting Referral ------------ ' + e.getMessage());
                
                //email jerry yu if referral fails to create                
                UtilityMethods.email('BLSG Referral Creation Failed for FA: ' + Referral.FA_Name__c, e.getMessage(), null);
            }
            
        } else {
            
            try {
                update Referral;
            } catch (exception e) {
                system.debug('***Error updating Referral ------------ ' + e.getMessage());
                
                //email jerry yu if referral fails to update
                UtilityMethods.email('BLSG Referral Update Failed for FA: ' + Referral.FA_Name__c, e.getMessage(), null);                
            }
            
        }
        
        PageReference ReferralPage;
        
        String Channel = [SELECT Channel__c FROM Contact WHERE ID =: Referral.FA_Name__c].Channel__c;
        
        if (Channel == 'FiNet') {
            ClosePage = 'FiNetBLSGReferralForm';
        } else if (Channel  == 'FCCS') {
            ClosePage = 'FCCSBLSGReferralForm';
        } else {
            ClosePage = 'PCGBLSGReferralForm';
        }
        
        ReferralPage = new PageReference('/apex/vfSubmissionConfirmation?id='+ClosePage);
        
        ReferralPage.setRedirect(true);
        
        return ReferralPage;
            
    }
    
}