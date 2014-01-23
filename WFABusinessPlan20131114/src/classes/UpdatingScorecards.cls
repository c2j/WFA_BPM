global class UpdatingScorecards {

    webservice static string UpdateFAIISScorecards(String[] SCIds) {
       
        Map<String, Scorecard__c> ISNamesToScorecard = new Map<String, Scorecard__c>();
        Set<String> ISWithoutPHS = new Set<String>();
        
        Set<String> ScorecardIds = new Set<String>(SCIds);   

        System.debug('+++++++++++++Scorecard IDS: ' + ScorecardIds);
        
        //query list of scorecard records selected from FAI IS score card list view        
        Map<ID, Scorecard__c> ISScorecards = new Map<ID, Scorecard__c>([SELECT Name, Total_PHS_Records__c, Composite_Score__c, Composite_Rank__c, FAI_Metrics_As_of_Date__c,
        SW_Exit_Meetings_Completed__c,  SW_Introductory_Meetings_Completed__c,SW_Pre_Departure_Calls_Completed__c,
        SW_Transitions_Completed__c, MW_Exit_Meetings_Completed__c, MW_Introductory_Meetings_Completed__c, 
        MW_Pre_Departure_Calls_Completed__c, MW_Transitions_Completed__c, SW_Transitions_Attachments__c,
        MW_Transitions_Attachments__c, SW_IC_PL_TC_Calls_Completed__c, MW_IC_PL_TC_Calls_Completed__c, 
        SW_Business_Planner_Reviews_Completed__c, MW_Business_Planner_Reviews_Completed__c, New_Accounts_Opened_In_SS__c,
        New_ACATs_Transferred_In_SS__c, Fully_Opened_Accounts_BDW__c, ACAT_Transfers__c, ACAT_Transfers_Rejected__c, FA_Satisfaction_Survey__c,
        Excellence_First__c, FA_Direct_Feedback__c
        FROM Scorecard__c WHERE ID IN: ScorecardIDs And Inactive__c = false]);

        if (ISScorecards.values().size() > 0) { //if there are active FAI IS Scorecards then proceed
            
            system.debug('queried FAI IS Scorecards ---------- ' + ISScorecards.values().size() + ' / ' + ISScorecards);
            
            for (Scorecard__c sc : ISScorecards.values()) { //create map of IS name to his/her scorecard record
                
                ISNamesToScorecard.put(sc.Name, sc);
                
            }
  
            //query a list of post hire support records where support start date in current year up till current date, and
            //IS Trainer name is in the list of score cards
            
            List<Post_Hire_Support__c> PostHireSupport = [SELECT Effort__r.Name,
                Total_New_Acct_SRs_Opened_This_Week__c, Total_ACAT_SRs_Opened_This_Week__c, ACAT_Rejects__c, ACATS_Completed_Verified__c,
                New_Accounts_Opened_Verified__c, Pre_Departure_Call_Date_Time__c, Intro_Meeting_Date_Time__c, Exit_Meeting_Date_Time__c,
                IC_PL_TC_Call_Date_Time__c, Business_Planner_Reviewed_Date_Time__c, IS_Trainer_Name__c, IS_Trainer_Status__c FROM
                Post_Hire_Support__c WHERE IS_Trainer_Name__c IN: ISNamesToScorecard.keyset() AND Support_Start_Date__c >=: 
                date.newinstance(system.Today().year(),1,1) AND Support_Start_Date__c <=: System.today() AND (Support_Type__c = 'ISS' OR
                Support_Type__c = 'IS-Remote') AND (Support_Status__c = 'Received' OR
                Support_Type__c = 'Received - Remote')
                ORDER BY IS_Trainer_Name__c DESC NULLS LAST, Effort__c DESC, Support_Start_Date__c ASC NULLS LAST]; //used to be support start date ordered DESC
                
            Set<ID> PHSIds = new Set<ID>();
            
            Map<ID, List<Post_Hire_Support__c>> EffortToPrimaryIS = new Map<ID, List<Post_Hire_Support__c>>();
            
            for (Post_Hire_Support__c phs : PostHireSupport) {
                PHSIds.add(phs.id);
            
                //map the effort id to the first post hire support record of the primary IS Trainer
                //choosing the first (earliest start date), because the credit for all the meetings/calls the Primary IS is
                //is responsible for comes from having those fields filled in on the first PHS record.
                
                if (phs.IS_Trainer_Status__c == 'Primary') {
                    if (!EffortToPrimaryIS.containsKey(phs.Effort__c)) {

                        //list to store all phs records on current Efffort of Primary IS                                    
                        List<Post_Hire_Support__c> PrimaryISPHS = new List<Post_Hire_Support__c>(); 
                        
                        PrimaryISPHS.add(phs);
                        
                        EffortToPrimaryIS.put(phs.Effort__c, PrimaryISPHS);
                    
                    } else {
                    
                        EffortToPrimaryIS.get(phs.Effort__c).add(phs);
                        
                    }

                }
                
            }
            
            //get map of PHS record ids to their attachment ids. This will be used to see if the IS are attaching their updates to
            //at least 1 phs record for each effort
            Map<ID,ID> PHSIdsToAttachmentIDs = UpdatingScorecards.MapRecordIdsToAttachmentIds(PHSIds);
                
            if (PostHireSupport.size() > 0) { //if the ISs have logged PHS records with start date in this year proceed
                
                system.debug('queried post hire support recs ---------- ' + PostHireSupport.size() + ' / ' + PostHireSupport);
                
                Map<ID, Post_Hire_Support__c> EffortToPHS = new Map<ID, Post_Hire_Support__c>();
                Map<String, Scorecard__c> IStoSC = new Map<String, Scorecard__c>();
                
                Integer PHSNumber; //counter variable for PHS record on an effort
                Integer EffortCount;
                Decimal ISSatisfactionScoreSum;
                Boolean BPReviewCounted;
                Boolean PreDepartMeetingCounted;
                Boolean IntroMeetingCounted;
                Boolean ExitMeetingCounted;
                Boolean ICPLTCCallCounted;
                Boolean BPReviewNulled;
                Boolean PreDepartMeetingNulled;
                Boolean IntroMeetingNulled;
                Boolean ExitMeetingNulled;
                Boolean HasAttachment;
                Boolean AttachmentCounted;
                Boolean ICPLTCCallNulled;
                
                for (integer i = 0; i<PostHireSupport.size();i++) { //loop through each PHS record

                    system.debug('Trainer name ' + PostHireSupport[i].IS_Trainer_Name__c);
                    
                    //create a map of IS name to a temporary scorecard record, to store the phs record counts
                    if (IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c) == null) {
                        
                        system.debug('mapping new IS to a temp scorecard');
                        
                        IStoSC.put(PostHireSupport[i].IS_Trainer_Name__c, NewScorecard('FAI IS'));
                        
                        EffortCount = 0;
                        ISSatisfactionScoreSum = 0.0;
                        
                    }
                    
                    //increment the total number of PHS records assigned to current IS
                    IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).Total_PHS_Records__c += 1;
                    
                    system.debug('Effort on PHS --------- ' + PostHireSupport[i].Effort__r.Name + ' / ' + PostHireSupport[i].Effort__c); 
                    
                    //-------------Activity Performance Numbers---------------
                    
                    if (EffortToPHS.get(PostHireSupport[i].Effort__c) == null ||
                        EffortToPHS.get(PostHireSupport[i].Effort__c).IS_Trainer_Name__c != PostHireSupport[i].IS_Trainer_Name__c) { //map doesn't already contain effort id, means code has reached a new PHS record
                        
                        //when loop gets to the first PHS of a new effort, set the PHS record counter to 1;
                        PHSNumber = 1;
                        
                        BPReviewCounted = false;
                        PreDepartMeetingCounted = false;
                        IntroMeetingCounted = false;
                        ExitMeetingCounted = false;
                        ICPLTCCallCounted = false;
                        
                        ICPLTCCallNulled = true;
                        BPReviewNulled = true;
                        PreDepartMeetingNulled = true;
                        IntroMeetingNulled = true;
                        ExitMeetingNulled = true;
                        
                        HasAttachment = false;
                        AttachmentCounted = false;
                        
                        //system.debug('-----Effort to PHS map DOES NOT contain effort on current PHS-----');
                        
                        EffortToPHS.put(PostHireSupport[i].Effort__c, PostHireSupport[i]);
                        
                        IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Completed__c += 1;
                        
                        //Business Planner Reviews completed on PHS
                        if (PostHireSupport[i].Business_Planner_Reviewed_Date_Time__c != null) { //Business Planner Review Date/time is filled in on PHS
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Business_Planner_Reviews_Completed__c += 1;
                            
                            BPReviewNulled = false;

                        }
                           
                        //IC/PL/TC call completed on PHS. For primary IS, the field must be filled in
                        //For the secondary IS, the effort's primary IS must have the field filled out
                        if (PostHireSupport[i].IC_PL_TC_Call_Date_Time__c != null || 
                            (PostHireSupport[i].IS_Trainer_Status__c == 'Secondary' &&
                             EffortToPrimaryIS.get(PostHireSupport[i].Effort__c)[0].IC_PL_TC_Call_Date_Time__c != null)) {
                        
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_IC_PL_TC_Calls_Completed__c += 1;
                            
                            ICPLTCCallNulled = false;                         
                        }
                            
                        //Pre Departure call completed on PHS. For primary IS, the field must be filled in
                        //For the secondary IS, the effort's primary IS must have the field filled out
                        if (PostHireSupport[i].Pre_Departure_Call_Date_Time__c != null || 
                            (PostHireSupport[i].IS_Trainer_Status__c == 'Secondary' &&
                             EffortToPrimaryIS.get(PostHireSupport[i].Effort__c)[0].Pre_Departure_Call_Date_Time__c != null)) {
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Pre_Departure_Calls_Completed__c += 1;
                            
                            PreDepartMeetingNulled = false;

                        }
                           
                        //Intro call completed on PHS
                        if (PostHireSupport[i].Intro_Meeting_Date_Time__c != null || 
                            (PostHireSupport[i].IS_Trainer_Status__c == 'Secondary' &&
                             EffortToPrimaryIS.get(PostHireSupport[i].Effort__c)[0].Intro_Meeting_Date_Time__c != null)) {
                        
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Introductory_Meetings_Completed__c += 1;
                            
                            IntroMeetingNulled = false;
                            
                        }

                        //Exit call completed on PHS. Required for Primary and Secondary IS
                        if (PostHireSupport[i].Exit_Meeting_Date_Time__c != null) {
                        
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Exit_Meetings_Completed__c += 1;
                            
                            ExitMeetingNulled = false;
                        }
                                                                       
                        //Support notes attached.
                        if (PHSIdsToAttachmentIDs.get(PostHireSupport[i].Id) != null) {
                            
                            //system.debug('SW Attachments ------- ' + PostHireSupport[i].Effort__r.Name);
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Attachments__c += 1;
                            
                            HasAttachment = True;
                                
                         } else if (PostHireSupport[i].IS_Trainer_Status__c == 'Secondary') {
                            //if the trainer is secondary, loop through all the PHS for the effort's primary trainer
                            //to find if any one of them has attachments. If so, then give credit to the secondary trianer
                             
                             for (Post_Hire_Support__c phs : EffortToPrimaryIS.get(PostHireSupport[i].effort__c)) {
                                 
                                 if (PHSIdsToAttachmentIDs.get(phs.id) != null) {
        
                                     IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Attachments__c += 1;
                                     
                                     break;    
                                 }
                             }
                            
                             HasAttachment = True;
                         }
                        
                    } else { //*****effort already exists in map, indicating the effort has multiple PHS support records*****//
                        

                        //system.debug('PHS Number ------ ' + PHSNumber);
                        
                        if (PHSNumber == 1) {
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Transitions_Completed__c += 1;
                            
                            if (IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Completed__c > 0) {
                                
                                //system.debug('---subtracting sw transitions ytd---');
                                IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Completed__c -= 1;
                            }
                        }
                        
                        //increment PHS record counter
                        PHSNumber = PHSNumber + 1;
                        
                        //BP review, IC/PL/TC Call, Pre Departure call, and Intro Meetings are only required on the first PHS record to get credit
                        
                        //Business Planner Review completed on PHS
                        if (PostHireSupport[i].Business_Planner_Reviewed_Date_Time__c != null && !BPReviewCounted) {  
                        
                            if (IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Business_Planner_Reviews_Completed__c > 0) {
                                IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Business_Planner_Reviews_Completed__c -= 1;
                            }
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Business_Planner_Reviews_Completed__c += 1;
                            
                            BPReviewCounted = True;
                            
                        }                        
                        
                        //IC/PL/TC call completed on PHS
                        if (!ICPLTCCallCounted && !ICPLTCCallNulled) {  //PostHireSupport[i].IC_PL_TC_Call_Date_Time__c != null &&
                        
                            if (IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_IC_PL_TC_Calls_Completed__c > 0) {
                                IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_IC_PL_TC_Calls_Completed__c -= 1;
                            }
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_IC_PL_TC_Calls_Completed__c += 1;
                            
                            ICPLTCCallCounted = True;
                            
                        }
                        
                        //Pre Departure call completed on PHS
                        //Pre Departure date/time is filled in on PHS
                        if (!PreDepartMeetingCounted && !PreDepartMeetingNulled) { //PostHireSupport[i].Pre_Departure_Call_Date_Time__c != null && 
                            
                            if (IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Pre_Departure_Calls_Completed__c > 0 ) {
                                IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Pre_Departure_Calls_Completed__c -= 1;
                            }
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Pre_Departure_Calls_Completed__c += 1;
                            
                            PreDepartMeetingCounted = True;
                            
                        } /*else if (PostHireSupport[i].Pre_Departure_Call_Date_Time__c == null && !PreDepartMeetingNulled) {
                            
                            //current PHS does not have a pre departure date/time
                            
                            //if (!PreDepartMeetingNulled) {
                                
                                //code is on the 2nd PHS and the previous PHS had a Pre departure d/t. But that count must be subtracted
                                //from the SW Pre Departure calls completed
                                if (PHSNumber == 2) { 
                                    IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Pre_Departure_Calls_Completed__c -= 1;
                                
                                //1 must be subtracted from the MW Pre Departure calls completed
                                } else {
                                
                                    system.debug('----subtracting a MW Pre Departure Call----');
                                    
                                    IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Pre_Departure_Calls_Completed__c -= 1;                        
                                    
                                }
                                
                            //}
                            
                            PreDepartMeetingNulled = True;
                            
                        }*/
                        
                        //Intro call completed on PHS
                        if (!IntroMeetingCounted && !IntroMeetingNulled) { //PostHireSupport[i].Intro_Meeting_Date_Time__c != null && 

                            if (IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Introductory_Meetings_Completed__c > 0) {
                                IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Introductory_Meetings_Completed__c -= 1;
                            }
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Introductory_Meetings_Completed__c += 1;                            
                            
                            IntroMeetingCounted = True;
                            
                        } /*else if (PostHireSupport[i].Intro_Meeting_Date_Time__c == null && !IntroMeetingNulled){
                            //current PHS does not have a Intro date/time
                            
                            //if (!IntroMeetingNulled) {
                                
                                //code is on the 2nd PHS and the previous PHS had a Intro d/t. But that count must be subtracted
                                //from the SW Intro calls completed
                                if (PHSNumber == 2) { 
                                    IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Introductory_Meetings_Completed__c -= 1;
                                
                                //1 must be subtracted from the MW Intro calls completed
                                } else {
                                    
                                    IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Introductory_Meetings_Completed__c -= 1;                        
                                    
                                }
                                
                            //}
                            
                            IntroMeetingNulled = True;
                        }*/
                        
                        //Exit call completed on PHS. This is the only date that needs to be filled out on every PHS record to get credit
                        if (PostHireSupport[i].Exit_Meeting_Date_Time__c != null && !ExitMeetingCounted && !ExitMeetingNulled) {
                        
                            if (IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Exit_Meetings_Completed__c > 0) {
                                IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Exit_Meetings_Completed__c -= 1;
                            }
                            
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Exit_Meetings_Completed__c += 1;
                            
                            ExitMeetingCounted = True;
                            
                        } else if (PostHireSupport[i].Exit_Meeting_Date_Time__c == null && !ExitMeetingNulled){
                            //current PHS does not have an Exit date/time
                            
                            //if (!ExitMeetingNulled) {
                            //system.debug('----need to remove an Exit Meeting count-----');
                                
                                //code is on the 2nd PHS and the previous PHS had a Exit d/t. But that count must be subtracted
                                //from the SW Exit calls completed
                                if (PHSNumber == 2) { 
                                    IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Exit_Meetings_Completed__c -= 1;
                                
                                //1 must be subtracted from the MW Exit calls completed
                                } else {
                                    IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Exit_Meetings_Completed__c -= 1;                        
                                    
                                }
                                
                            //}
                            
                            ExitMeetingNulled = True;
                        }      

                        //Support notes attached
                        if ((HasAttachment || PHSIdsToAttachmentIDs.get(PostHireSupport[i].Id) != null) && !AttachmentCounted) {
                            
                            if (HasAttachment && IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Attachments__c > 0) {
                            
                                IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Attachments__c -= 1;
                                
                            }
   
                            IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Transitions_Attachments__c += 1;
                            
                            AttachmentCounted = True;
                        }

                    }
                    
                    //----------Account Opening and Asset Transfer numbers-------------
                    
                    //Populate Actual # of Accounts opened in a particular week by IS
                    if (PostHireSupport[i].Total_New_Acct_SRs_Opened_This_Week__c != null) {
                        
                        IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).New_Accounts_Opened_In_SS__c += PostHireSupport[i].Total_New_Acct_SRs_Opened_This_Week__c;
                        
                    }

                    //Populate Actual # of ACATs Transferred in a particular week by IS
                    if (PostHireSupport[i].Total_ACAT_SRs_Opened_This_Week__c != null) {
                        
                        IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).New_ACATs_Transferred_In_SS__c += PostHireSupport[i].Total_ACAT_SRs_Opened_This_Week__c;
                        
                    }
                                        
                    //Populate BDW YTD Completely Opened ACATS
                    if (PostHireSupport[i].New_Accounts_Opened_Verified__c != null) {
                        
                        IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).Fully_Opened_Accounts_BDW__c += PostHireSupport[i].New_Accounts_Opened_Verified__c;
                        
                    }                      
                    
                    //Populate BDW YTD ACAT Transfers
                    if (PostHireSupport[i].ACATS_Completed_Verified__c != null) {
                        
                        IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).ACAT_Transfers__c += PostHireSupport[i].ACATS_Completed_Verified__c;
                        
                    }
                    
                    //Populate BDW YTD ACAT Rejects
                    if (PostHireSupport[i].ACAT_Rejects__c != null) {
                        
                        IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).ACAT_Transfers_Rejected__c += PostHireSupport[i].ACAT_Rejects__c;
                        
                    }
                    
                    system.debug('# of SW transitions ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Completed__c);
                    system.debug('# of MW transitions ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Transitions_Completed__c);
                    
                    system.debug('# of SW BP Reviews  ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Business_Planner_Reviews_Completed__c);
                    system.debug('# of MW BP Reviews  ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Business_Planner_Reviews_Completed__c);
                    
                    system.debug('# of SW IC/PC/TC    ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_IC_PL_TC_Calls_Completed__c);
                    system.debug('# of MW IC/PC/TC    ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_IC_PL_TC_Calls_Completed__c);
                    
                    system.debug('# of SW Pre Depart  ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Pre_Departure_Calls_Completed__c);
                    system.debug('# of MW Pre Depart  ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Pre_Departure_Calls_Completed__c);
                    
                    system.debug('# of SW Intro Call  ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Introductory_Meetings_Completed__c);
                    system.debug('# of MW Intro Call  ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Introductory_Meetings_Completed__c);
                    
                    system.debug('# of SW Exit Call   ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Exit_Meetings_Completed__c);
                    system.debug('# of MW Exit Call   ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Exit_Meetings_Completed__c);
                    
                    system.debug('# of SW attachments ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).SW_Transitions_Attachments__c);
                    system.debug('# of MW attachments ------ ' + IStoSC.get(PostHireSupport[i].IS_Trainer_Name__c).MW_Transitions_Attachments__c);
                               
                }
                
                //Create map of Scorecard IDs to Avg FA Satisfaction Scores;
                Map<String, Double> FASatisfactionScoresMap = UpdatingScorecards.MapSCToAvgFASatisfactionScores(ScorecardIds);
                
                
                //updating actual FAI IS Scorecard fields with the values from the temporary scorecard mapped to the IS's name
                for (String ISName : ISNamesToScorecard.keyset()) {
                    
                    if (ISNamesToScorecard.get(ISName) != Null && IStoSC.get(ISName) != Null) {
                    
                        ISNamesToScorecard.get(ISName).Total_PHS_Records__c = IStoSC.get(ISName).Total_PHS_Records__c;
                        
                        ISNamesToScorecard.get(ISName).SW_Transitions_Completed__c = IStoSC.get(ISName).SW_Transitions_Completed__c;
                        ISNamesToScorecard.get(ISName).SW_Pre_Departure_Calls_Completed__c = IStoSC.get(ISName).SW_Pre_Departure_Calls_Completed__c;
                        ISNamesToScorecard.get(ISName).SW_Introductory_Meetings_Completed__c = IStoSC.get(ISName).SW_Introductory_Meetings_Completed__c;
                        ISNamesToScorecard.get(ISName).SW_Exit_Meetings_Completed__c = IStoSC.get(ISName).SW_Exit_Meetings_Completed__c;
                        ISNamesToScorecard.get(ISName).SW_Transitions_Attachments__c = IStoSC.get(ISName).SW_Transitions_Attachments__c;
                        ISNamesToScorecard.get(ISName).SW_IC_PL_TC_Calls_Completed__c = IStoSC.get(ISName).SW_IC_PL_TC_Calls_Completed__c;
                        ISNamesToScorecard.get(ISName).SW_Business_Planner_Reviews_Completed__c = IStoSC.get(ISName).SW_Business_Planner_Reviews_Completed__c;
                        
                        ISNamesToScorecard.get(ISName).MW_Transitions_Completed__c = IStoSC.get(ISName).MW_Transitions_Completed__c;
                        ISNamesToScorecard.get(ISName).MW_Pre_Departure_Calls_Completed__c = IStoSC.get(ISName).MW_Pre_Departure_Calls_Completed__c;
                        ISNamesToScorecard.get(ISName).MW_Introductory_Meetings_Completed__c = IStoSC.get(ISName).MW_Introductory_Meetings_Completed__c;
                        ISNamesToScorecard.get(ISName).MW_Exit_Meetings_Completed__c = IStoSC.get(ISName).MW_Exit_Meetings_Completed__c;                  
                        ISNamesToScorecard.get(ISName).MW_Transitions_Attachments__c = IStoSC.get(ISName).MW_Transitions_Attachments__c;
                        ISNamesToScorecard.get(ISName).MW_IC_PL_TC_Calls_Completed__c = IStoSC.get(ISName).MW_IC_PL_TC_Calls_Completed__c;
                        ISNamesToScorecard.get(ISName).MW_Business_Planner_Reviews_Completed__c = IStoSC.get(ISName).MW_Business_Planner_Reviews_Completed__c;
                        
                        ISNamesToScorecard.get(ISName).New_Accounts_Opened_In_SS__c = IStoSC.get(ISName).New_Accounts_Opened_In_SS__c;                                
                        ISNamesToScorecard.get(ISName).New_ACATs_Transferred_In_SS__c = IStoSC.get(ISName).New_ACATs_Transferred_In_SS__c;  
                        ISNamesToScorecard.get(ISName).ACAT_Transfers__c = IStoSC.get(ISName).ACAT_Transfers__c;
                        ISNamesToScorecard.get(ISName).Fully_Opened_Accounts_BDW__c = IStoSC.get(ISName).Fully_Opened_Accounts_BDW__c;
                        ISNamesToScorecard.get(ISName).ACAT_Transfers_Rejected__c = IStoSC.get(ISName).ACAT_Transfers_Rejected__c;
                        
                        //if there is no satisfaction score, set the score equal to the FA Direct Feedback score
                        if (FASatisfactionScoresMap.get(ISNamesToScorecard.get(ISName).ID) != null && 
                        FASatisfactionScoresMap.get(ISNamesToScorecard.get(ISName).ID) != 0.0) {
                        
                            ISNamesToScorecard.get(ISName).FA_Satisfaction_Survey__c = FASatisfactionScoresMap.get(ISNamesToScorecard.get(ISName).ID);
                        
                        } else {
                        
                            ISNamesToScorecard.get(ISName).FA_Satisfaction_Survey__c = ISNamesToScorecard.get(ISName).FA_Direct_Feedback__c;
                            //ISNamesToScorecard.get(ISName).FA_Satisfaction_Survey__c = ISScorecards.get(ISNamesToScorecard.get(ISName).ID).FA_Direct_Feedback__c;
                            
                        }
                        
                        ISNamesToScorecard.get(ISName).FAI_Metrics_As_of_Date__c = system.today();
                        
                    } else {
                        
                        ISWithoutPHS.add(ISName);
                    }
                    
                }
   
            } else {
           
            
                return 'There Are No Post Hire Support Records Logged By Active FAI IS Salesforce Users YTD';
            
            }
         
         } else {
         
             return 'There Are No Active FAI Integration Specialist Salesforce Users';
             
         }   
         
         try {
             
            update ISNamesToScorecard.values();
            
            List<Scorecard__c> RankedISScorecards = UpdatingScorecards.RankISScorecards(ScorecardIds);
            
            try {
                update RankedISSCorecards;
                
                if (ISWithoutPHS.size() == 0) {
                
                    return 'The Selected FAI IS Scorecards Have Been Updated.';
                
                }
                 
                return 'The following ISs did not log any PHS YTD: ' + ISWithoutPHS + '\n\n The rest have been updated';
            
            } catch (exception e) {
            
                system.debug('Error occured while updating FAI IS SC ranks ------- ' + e.getCause());
                
                return 'Error Occurred While Ranking Scorecards. Contact Your Administrator.';
                
            }
            

         } catch (exception e) {
             
             system.debug('Error occurred while updating IS Scorecards: ' + e.getMessage());
             
             return 'Error occurred while updating IS Scorecards. Contact Your Administrator';
             
         }
    }
    
    public static Scorecard__c NewScorecard (String SCType) {
        
        Scorecard__c tempSC;
        
        if (SCType == 'FAI IS') {
        
            //create a temporary scorecard record
            tempSC = new Scorecard__c(Name = 'TempSC', Total_PHS_Records__c = 0, SW_Transitions_Completed__c = 0, 
            SW_Pre_Departure_Calls_Completed__c = 0, SW_Introductory_Meetings_Completed__c = 0,
            SW_Exit_Meetings_Completed__c = 0, MW_Transitions_Completed__c = 0, 
            MW_Pre_Departure_Calls_Completed__c = 0, MW_Introductory_Meetings_Completed__c = 0,
            MW_Exit_Meetings_Completed__c = 0, New_Accounts_Opened_In_SS__c = 0, New_ACATs_Transferred_In_SS__c = 0, ACAT_Transfers__c = 0,
            Fully_Opened_Accounts_BDW__c = 0, ACAT_Transfers_Rejected__c = 0, SW_Transitions_Attachments__c = 0,
            MW_Transitions_Attachments__c = 0, SW_IC_PL_TC_Calls_Completed__c = 0, MW_IC_PL_TC_Calls_Completed__c = 0, 
            SW_Business_Planner_Reviews_Completed__c = 0, MW_Business_Planner_Reviews_Completed__c = 0);
            
        }
        
        return tempSC;
    
    }
    
    public static Map<String, Double> MapSCToAvgFASatisfactionScores (Set<String> ScorecardIDs) {
    
        AggregateResult[] results = [SELECT Scorecard_Name__c, Avg(Satisfaction_Score__c) AvgScore
                                    FROM Satisfaction_Scores__c WHERE Submitter_Type__c = 'FA' AND
                                    Scorecard_Name__c IN: ScorecardIDs GROUP BY Scorecard_Name__c];
        
        system.debug('scorecard ---- ' + results[0].get('Scorecard_Name__c'));
        system.debug('avg score ---- ' + results[0].get('AvgScore'));
                 
        Map<String, Double> FASatisfactionScoresMap = new Map<String, Double>();
        
        For (AggregateResult ar: results) {

            string s = string.valueof(ar.get('Scorecard_Name__c'));
            Double i = Double.valueof(ar.get('AvgScore'));
            
            FASatisfactionScoresMap.put(s, i);

        }
        
        return FASatisfactionScoresMap;
    }
    
    
    
    
    public static Map<ID, ID> MapRecordIdsToAttachmentIds (set<ID> RecordIds) {
       
        Map<ID,ID> RecIdsToAttchIds = new Map<ID, ID>();
        
        For (Attachment a: [SELECT ParentID, Id FROM Attachment WHERE ParentId In: RecordIds]) {
            
            if (RecIdsToAttchIds.get(a.ParentID) == null) {
                RecIdsToAttchIds.put(a.ParentId, a.id);    
            }
        
        }
        
        return RecIdsToAttchIds;
    }
    
    public static List<Scorecard__C> RankISScorecards(Set<String> ScorecardIDs) {
    
        Scorecard__c[] FAIIS = [SELECT FAI_IS_Composite_Score__c, Team_Rank__c FROM Scorecard__c WHERE ID IN: ScorecardIDs ORDER BY
                                FAI_IS_Composite_Score__c DESC];

        system.debug('FAI IS SC ranked ------- ' + FAIIS);
        
        if (FAIIS.size() > 0) {
            
            FAIIS[0].Team_Rank__c = 1;
            
            for (integer i = 1; i < FAIIS.size(); i++) {
                if (FAIIS[i].FAI_IS_Composite_Score__c == FAIIS[i-1].FAI_IS_Composite_Score__c) {
                   FAIIS[i].Team_Rank__c = FAIIS[i-1].Team_Rank__c;
                } else {
                    FAIIS[i].Team_Rank__c = i + 1;
                }
            }
            
        }
            
        return FAIIS;
        
    }
       
}