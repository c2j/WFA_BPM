global class CreateCustomerRecFromHiredEffortButton {

    webservice static string CreateCustomerRecOnClick(String effortID) {
    
    List<Contact> newCustomers = new List<Contact>();
    String HireType = '';
    Date IndStartDate = null;
    String FamiliarName = '';
    String RecordTypeID = '';
    String IBDC = '';
    String PC = '';
    String NST = '';
    String RSM = '';
    ID MgrID = null;
    ID MainBranchMgrID = null;
    String CustOwnerID = '';

    Opportunity HiredEffort = [SELECT RecordTypeID, CRD_Number__c, Last_Name__c, First_Name__c, 
    Preferred_Nickname__c, Region__c, Channel__c,
    CloseDate, Special_Hire_Type__c, A_Number__c, Employing_Firm__c, Amount, AUM__c, Industry_Start_Date__c, 
    AccountID, Account.Manager_Branch__c FROM Opportunity WHERE ID = : effortID];
    
    Account EffortBranch = [SELECT Active__c, Main_Branch__c FROM Account WHERE ID = : HiredEffort.AccountID];
    
    Contact[] ExistingFA = [SELECT ID From Contact WHERE A_Number__c = : HiredEffort.A_Number__c OR Effort__c = : HiredEffort.ID];
    
    if (HiredEffort.Channel__c == 'PCG') {
        Main_Branch__c MainBranch = [SELECT Manager_Main_Branch__c from Main_Branch__c WHERE ID = : EffortBranch.Main_Branch__c];
    
        MainBranchMgrID = MainBranch.Manager_Main_Branch__c;
    }

    MgrID = HiredEffort.Account.Manager_Branch__c;

    Contact[] Manager = [SELECT IBDC__c, National_Sales_Territory__c, Productivity_Consultant__c, 
    Regional_Sales_Manager__c FROM Contact WHERE ID = : MgrId ];


    if (ExistingFA.size() != 0) {
        ExistingFA[0].Date_Effort_Marked_Hired__c = system.now().date();
        ExistingFA[0].Effort__c = HiredEffort.ID;
        try {
            update ExistingFA;
        } catch (Exception e) {
            return 'Error occurred: ' + e.getMessage() + ': FA\'s existing contact record not updated with new hired effort information';
        }
        return 'This FA already has a customer record. Record Id: ' + ExistingFA[0].id;
    } else if (Manager.size() == 0) {
        return 'New FA\'s branch does not have a manager. Customer record not created';
    } else if (EffortBranch.Active__c = False) {
        return 'New FA\'s branch is inactive';
    }
    
        If (HiredEffort.channel__c == 'PCG') {
            
            if (MainBranchMgrId != MgrID) {
                return 'Branch manager not the same as main branch manager';
            } else {
                RecordTypeID = '01250000000UHL7';
                IBDC = Manager[0].IBDC__c;
                PC = Manager[0].Productivity_Consultant__c;
                NST = Manager[0].National_Sales_Territory__c;
                RSM = Manager[0].Regional_Sales_Manager__c;      
                CustOwnerID = UtilityMethods.GetPCGContactOwner(string.valueof(HiredEffort.region__c));
                
                if (CustOwnerID == 'region does not exist in PCG') {
                    return CustOwnerID;
                }
            }
           
        } else if (HiredEffort.channel__c == 'WBS') {
            
            RecordTypeID = '01250000000UHKs';
            CustOwnerID = '00550000000oN8o'; //sam moran
            
        } else if (HiredEffort.Channel__c == 'FiNet') {
        
            RecordTypeID = '01250000000UHLC';
            CustOwnerID = '00550000001CSlE'; //Kent Christian
            
        }
         
        if ((HiredEffort.Preferred_Nickname__c == null || HiredEffort.Preferred_Nickname__c == '')) {
            FamiliarName = HiredEffort.First_Name__c;
        } else {
            FamiliarName = HiredEffort.Preferred_Nickname__c;
        }
        
        IndStartDate = HiredEffort.Industry_Start_Date__c;
        
        if (HiredEffort.recordtypeid == '01250000000UISS') { // fai effort rec type            
            if(HiredEffort.Special_Hire_Type__c == NULL || HiredEffort.Special_Hire_Type__c == 'Special Hire') {
                HireType = 'FA';
            } else if (HiredEffort.Special_Hire_Type__c == 'FC') {
                HireType = 'Financial Consultant';
            }
        } else if (HiredEffort.RecordTypeid == '01250000000UISQ') { //finet effort rec type
            HireType = 'FA';
        } else if (HiredEffort.RecordTypeid == '01250000000UISO'  || HiredEffort.RecordTypeID == '01250000000UNFe') {//PCG or WBS fai trainee rec type
            HireType = 'FA in Training';
            IndStartDate = HiredEffort.closedate;
        }
        
        Contact con = new contact(
            RecordTypeID = RecordTypeID,
            LastName = HiredEffort.Last_Name__c,
            FirstName = HiredEffort.First_Name__c,
            Familiar_Name__c = FamiliarName,
            Hire_Date__c = HiredEffort.CloseDate,
            Type__c = HireType,
            A_Number__c = HiredEffort.A_Number__c,
            CRD_Number__c = HiredEffort.CRD_Number__c,
            Previous_Firm__c = HiredEffort.Employing_Firm__c,
            Pre_Hire_T12_Production__c = HiredEffort.Amount,
            Pre_Hire_AUM__c = HiredEffort.AUM__c,
            ILOS__c = IndStartDate,
            AccountID = HiredEffort.AccountID,
            IBDC__c = IBDC,
            National_Sales_Territory__c = NST,
            Productivity_Consultant__c = PC,
            Regional_Sales_Manager__c = RSM,
            Legacy_Firm__c = 'Wells Fargo Advisors',
            OwnerID = CustOwnerID,
            Effort__c = HiredEffort.id,
            Date_Effort_Marked_Hired__c = system.now().date()
            );   
        
        NewCustomers.add(con); 
    
    
    if (newCustomers.size()>0) {
        try {
            insert NewCustomers;
            return 'New customer successfully created.';
        } catch (DMLException e) {
            return 'Error occurred: ' + e.getMessage() + ' : customer record not created';
        }
    } else {
        return 'No customer records were created';
    }
        
    
       
    
    }
    

}