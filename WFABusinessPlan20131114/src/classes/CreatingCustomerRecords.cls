Public with sharing class CreatingCustomerRecords {

    
    public static List<Contact> CreatePCGCustomerRecords(Opportunity[] efforts, Map<ID,Contact> FAtoMgr, List<Contact> NewHiredFAs) {
        
        //List<Contact> NewHiredFAs = new List<Contact>();
        List<Ranking__c> NewRankingRecs = new List<Ranking__c>();
        String HireType = '';
        Date IndStartDate = null;
        String FamiliarName = '';
        Map<ID, ID> ContactOwner = new Map<ID, ID>();
        
        
        for (Opportunity ef : efforts) {
            System.debug('Rec Type: ' + ef.RecordTypeid);
            System.debug('Channel: ' + ef.Channel__c);
            System.debug('Rec Type: ' + ef.RecordTypeid);                
            
            if ((ef.Preferred_Nickname__c == null || ef.Preferred_Nickname__c == '')) {
                FamiliarName = ef.First_Name__c;
            } else {
                FamiliarName = ef.Preferred_Nickname__c;
            }

            
            IndStartDate = ef.Industry_Start_Date__c;
            
            if (ef.recordtypeid == '01250000000UISS') { // fai effort rec type            
                if(ef.Special_Hire_Type__c == NULL || ef.Special_Hire_Type__c == 'Special Hire') {
                    HireType = 'FA';
                } else if (ef.Special_Hire_Type__c == 'FC') {
                    HireType = 'Financial Consultant';
                }
            } else if (ef.RecordTypeid == '01250000000UISO' || ef.RecordTypeID == '01250000000UNFe') {// PCG or WBS fai trainee rec type
                HireType = 'FA in Training';
                if (indStartDate == null) {
                    IndStartDate = ef.closedate;
                }
                
            }

                Contact con = new contact(
                RecordTypeID = '01250000000UHL7',
                LastName = ef.Last_Name__c,
                FirstName = ef.First_Name__c,
                Familiar_Name__c = FamiliarName,
                Hire_Date__c = ef.CloseDate,
                Type__c = HireType,
                A_Number__c = ef.A_Number__c,
                CRD_Number__c = ef.CRD_Number__c,
                Previous_Firm__c = ef.Employing_Firm__c,
                Pre_Hire_T12_Production__c = ef.Amount,
                Pre_Hire_AUM__c = ef.AUM__c,
                ILOS__c = IndStartDate,
                AccountID = ef.AccountID,
                IBDC__c = FAtoMgr.get(ef.id).IBDC__c,
                National_Sales_Territory__c = FAtoMgr.get(ef.id).National_Sales_Territory__c,
                Productivity_Consultant__c = FAtoMgr.get(ef.id).Productivity_Consultant__c,
                Regional_Sales_Manager__c = FAtoMgr.get(ef.id).Regional_Sales_Manager__c,
                Legacy_Firm__c = 'Wells Fargo Advisors',
                OwnerID = UtilityMethods.GetPCGContactOwner(string.valueof(ef.Region_ID__c)),
                Effort__c = ef.id,
                Date_Effort_Marked_Hired__c = system.now().date()
                );   
        
                NewHiredFAs.add(con);
                
            }                   
       
        system.debug('--------------Inserting New Hired FAs--------------');
            /*try{
                insert NewHiredFAs;
           } catch (DMLException e){
                for (Contact cons : NewHiredFAs) {
                     trigger.oldmap.get(cons.Effort__c).addError('Error Occurred: ' + e.getMessage() + ' : Contact Record Not Created');
                }
            }*/
            return NewHiredFAs;
     
    }
    
    public static List<Contact> CreateWBSCustomerRecords(Opportunity[] efforts, List<Contact> NewHiredFAs) {
        
        //List<Contact> NewHiredFAs = new List<Contact>();
        String HireType = Null;
        Date IndStartDate = NULL;
        String FamiliarName = '';
        
        for (Opportunity ef : efforts) {
            System.debug('Rec Type: ' + ef.RecordTypeid);
            System.debug('Channel: ' + ef.Channel__c);
            System.debug('Rec Type: ' + ef.RecordTypeid);                
            
            if ((ef.Preferred_Nickname__c == null || ef.Preferred_Nickname__c == '')) {
                FamiliarName = ef.First_Name__c;
            } else {
                FamiliarName = ef.Preferred_Nickname__c;
            }           
           
            IndStartDate = ef.Industry_Start_Date__c;
            
            if (ef.recordtypeid == '01250000000UISS') { // fai effort rec type            
                if(ef.Special_Hire_Type__c == NULL || ef.Special_Hire_Type__c == 'Special Hire') {
                    HireType = 'FA';
                } else if (ef.Special_Hire_Type__c == 'FC') {
                    HireType = 'Financial Consultant';
                }
            } else if (ef.RecordTypeid == '01250000000UISO') {// fai trainee rec type
                HireType = 'FA in Training';
                if (IndStartDate == null) {
                    IndStartDate = ef.closeDate;
                }
            }
                    
                Contact con = new contact(
                RecordTypeID = '01250000000UHKs',
                LastName = ef.Last_Name__c,
                FirstName = ef.First_Name__c,
                Familiar_Name__c = FamiliarName,
                Hire_Date__c = ef.CloseDate,
                Type__c = HireType,
                A_Number__c = ef.A_Number__c,
                CRD_Number__c = ef.CRD_Number__c,
                Previous_Firm__c = ef.Employing_Firm__c,
                Pre_Hire_T12_Production__c = ef.Amount,
                Pre_Hire_AUM__c = ef.AUM__c,
                ILOS__c = IndStartDate,
                AccountID = ef.AccountID,
                Legacy_Firm__c = 'Wells Fargo Advisors',
                OwnerID = '00550000000oN8o',
                Effort__c = ef.id,
                Date_Effort_Marked_Hired__c = system.now().date()
                );   
        
        //sam moran is owner
                NewHiredFAs.add(con);

            }                   
       
        system.debug('--------------Inserting New Hired FAs--------------');
            /*try{
                insert NewHiredFAs;
           } catch (DMLException e){
                for (Contact cons : NewHiredFAs) {
                     trigger.oldmap.get(cons.Effort__c).addError('Error Occurred: ' + e.getMessage() + ' : Contact Record Not Created');
                }
            }*/
            return NewHiredFAs;
     
    }
    
     public static List<Contact> CreateFiNetCustomerRecords(Opportunity[] efforts, List<Contact>NewHiredFAs) {
        
        //List<Contact> NewHiredFAs = new List<Contact>();
        String HireType = 'FA';
        String FamiliarName = '';
        
        for (Opportunity ef : efforts) {
            System.debug('Rec Type: ' + ef.RecordTypeid);
            System.debug('Channel: ' + ef.Channel__c);
            System.debug('Rec Type: ' + ef.RecordTypeid);                
            
            if ((ef.Preferred_Nickname__c == null || ef.Preferred_Nickname__c == '')) {
                FamiliarName = ef.First_Name__c;
            } else {
                FamiliarName = ef.Preferred_Nickname__c;
            }
                    
                Contact con = new contact(
                RecordTypeID = '01250000000UHLC',
                LastName = ef.Last_Name__c,
                FirstName = ef.First_Name__c,
                Familiar_Name__c = FamiliarName,
                Hire_Date__c = ef.CloseDate,
                Type__c = HireType,
                A_Number__c = ef.A_Number__c,
                CRD_Number__c = ef.CRD_Number__c,
                Previous_Firm__c = ef.Employing_Firm__c,
                Pre_Hire_T12_Production__c = ef.Amount,
                Pre_Hire_AUM__c = ef.AUM__c,
                ILOS__c = ef.Industry_Start_Date__c,
                AccountID = ef.AccountID,
                Legacy_Firm__c = 'Wells Fargo Advisors',
                OwnerID = '00550000001CSlE',
                Effort__c = ef.id,
                Date_Effort_Marked_Hired__c = system.now().date()
                );   
        
        //Kent Christian is owner
                NewHiredFAs.add(con);

            }                   
       
        system.debug('--------------Inserting New Hired FAs--------------');
            /*try{
                insert NewHiredFAs;
           } catch (DMLException e){
                for (Contact cons : NewHiredFAs) {
                     trigger.oldmap.get(cons.Effort__c).addError('Error Occurred: ' + e.getMessage() + ' : Contact Record Not Created');
                }
            }*/
            return NewHiredFAs;
     
    }
    
}