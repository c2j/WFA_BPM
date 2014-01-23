global class MarkFAProfileCompletedButton {

    webservice static string MarkFAProfileCompletedOnClick(String ProfileInfoID) {
    
    
    Hobbies_Charities__c FAProfile = [SELECT Status__c, Date_Time_Profile_Completed__c FROM Hobbies_Charities__c WHERE ID =: ProfileInfoID];
    
    FAProfile.Status__c = 'Completed';
    FAProfile.Date_Time_Profile_Completed__c = system.now();
    
    try {
        update FAProfile;
  
    } catch (DMLException e) {
        return 'Error occurred. Please contact your salesforce administrator';
        system.debug('Marking FA Profile Completed Error: ------------- ' + e.getMessage());
    }    
    
    return 'Profile Completed';  
    
    }
    
}