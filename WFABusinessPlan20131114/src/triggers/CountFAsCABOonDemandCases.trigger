trigger CountFAsCABOonDemandCases on Case (after insert) {

Set<ID> ConIds = new Set<ID>();
Set<ID> CABOCaseFAIDs = new Set<ID>();
Map<ID,Integer> YesterdaysCABOODCases = new Map<ID,Integer>();
Map<ID,Integer> MTDCABOODCases = new Map<ID,Integer>();
Map<ID,Integer> YTDCABOODCases = new Map<ID,Integer>();
Boolean QueryAllCases = False;

for (case c: trigger.new) {

    if (c.RecordTypeId == '01250000000UKbR' && c.ContactID != null) {
        
        CABOCaseFAIDs.add(c.ContactId);
        
    }
    
    if (c.Description == 'Backfill FA CABO On Demand Case Count' && c.RecordTypeId == '01250000000UKbR') {
        QueryAllCases = True;
        
        break;
    }   

}

if (CABOCaseFAIDs.size() > 0) {
    
    system.debug('newly created cabo OD cases ----------- ' + CABOCaseFAIDs.size() + ' / ' + CABOCaseFAIDs);
    
    Date YearStart = date.newinstance(system.today().year(), 1,1);
    Date MonthStart = date.newinstance(system.today().year(), system.today().month(),2);
    
    Date Yesterday = system.today(); //system.today().adddays(-1);
    
    Case[] CABOODCases;
    
    if (QueryAllCases == False) {
        CABOODCases = [SELECT ContactID, Case_Created_Date__c, CreatedDate FROM Case WHERE RecordTypeID = '01250000000UKbR' AND 
                        ContactID IN : CABOCaseFAIDs AND 
                        (Case_Created_Date__c >= : YearStart OR CreatedDate >=: YearStart) ORDER BY ContactID ASC];
    } else {
        CABOODCases = [SELECT ContactID, Case_Created_Date__c, CreatedDate FROM Case WHERE RecordTypeID = '01250000000UKbR' AND ContactID != Null AND
                            (Case_Created_Date__c >= : YearStart OR CreatedDate >=: YearStart) ORDER BY ContactID ASC];
    
        for (Case c: CABOODCases) {
            ConIds.add(c.ContactID);
        }
            
    }
    
    system.debug('CABO On Demand Cases created in current year--------- ' + CABOODCases.size() + ' / ' + CABOODCases);
    
    if (CABOODCases.size() > 0) {//if the FAs who have submitted the current batch of CABO OD cases have submitted CABO OD cases before, proceed
        for (case c: CABOODCases) {
            
            if (c.Case_Created_Date__c >= YearStart || c.CreatedDate >= YearStart) {
                if (!YTDCABOODCases.keyset().contains(c.ContactID)) {
                    
                    YTDCABOODCases.put(c.ContactID,1);
                } else {
                    YTDCABOODCases.put(c.ContactID, YTDCABOODCases.get(c.ContactID)+1);
                }
            }
            
            if (c.Case_Created_Date__c >= MonthStart || c.CreatedDate >= MonthStart) {
                if (!MTDCABOODCases.keyset().contains(c.ContactID)) {

                    MTDCABOODCases.put(c.ContactID,1);
                } else {
                    MTDCABOODCases.put(c.ContactID, MTDCABOODCases.get(c.ContactID)+1);
                }
            }
            
            
            if (c.Case_Created_Date__c >= Yesterday || c.CreatedDate >= Yesterday) {
                if (!YesterdaysCABOODCases.keyset().contains(c.ContactID)) {

                    YesterdaysCABOODCases.put(c.ContactID,1);
                    
                } else {
                    YesterdaysCABOODCases.put(c.ContactID, YesterdaysCABOODCases.get(c.ContactID)+1);
                }
            }            
        }
    }
    
    
    system.debug('YTD CABO Cases ----------- ' + YTDCABOODCases);
    system.debug('MTD CABO Cases ----------- ' + MTDCABOODCases);
    system.debug('Yesterdays CABO Cases ----------- ' + YesterdaysCABOODCases);        
    
    Contact[] FAsWithCABOODCases;

    if (QueryAllCases == False) {
        FAsWithCABOODCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c, Yesterday_s_CABO_on_Demand_Cases__c FROM
                                    Contact WHERE ID IN: YesterdaysCABOODCases.keyset()];
                                    
    system.debug('FAs with new CABO cases before case count update NOT QUERY ALL--------- ' + FAsWithCABOODCases.size() + ' / ' + FAsWithCABOODCases);
    
    } else {
    
        FAsWithCABOODCases = [SELECT YTD_CABO_on_Demand_Cases__c, MTD_CABO_on_Demand_Cases__c, Yesterday_s_CABO_on_Demand_Cases__c FROM
                                    Contact WHERE ID IN: ConIds];
    
    system.debug('FAs with new CABO cases before case count update QUERY ALL--------- ' + FAsWithCABOODCases.size() + ' / ' + FAsWithCABOODCases);
    }
    
    
                                    
    for (contact fa: FAsWithCABOODCases) {
        if (YTDCABOODCases.get(fa.id) != null) {

            fa.YTD_CABO_on_Demand_Cases__c = YTDCABOODCases.get(fa.id);
        }
        if (MTDCABOODCases.get(fa.id) != null) {

            fa.MTD_CABO_on_Demand_Cases__c = MTDCABOODCases.get(fa.id);
        }
        if (YesterdaysCABOODCases.get(fa.id) != null) {
    
            fa.Yesterday_s_CABO_on_Demand_Cases__c = YesterdaysCABOODCases.get(fa.id);
        }        

    }
    
    
    try {
        system.debug('FAs with new CABO cases after case count update--------- ' + FAsWithCABOODCases.size() + ' / ' + FAsWithCABOODCases);
        
        update FAsWithCABOODCases;
        
    } catch (Exception e) {
        system.debug('Error occurred updating Cabo OD cases count on contact records --------------- ' + e.getMessage());
        throw new SFException('Error occurred updating CABO on Demand cases count on customer records. Please contact your system administrator.');
    }
    
}

}