public with sharing class vfSFPortalCtrlr {
    
    public string FormType {get {if (FormType== null) {FormType = null; } return FormType; } set;}
    public string ID {get {if (ID== null) {ID= null; } return ID; } set;}
    public PageReference RedirectPage {get {if (RedirectPage == null) {RedirectPage = null; } return RedirectPage; } set;}
    
    public vfSFPortalCtrlr () {
        
        FormType = Apexpages.currentPage().getParameters().get('FormType').toUpperCase();
        ID = Apexpages.currentPage().getParameters().get('ID');
        
        Redirect();
    }
    
     public PageReference Redirect() {
   
        if (FormType == 'BLSG') {
            
            
            if (ID != null) {
                system.debug('Referral ID ------- ' +  ID);
                RedirectPage= new PageReference('/apex/vfBLSGReferralStatusUpdate?ID='+ID);
            } else {
                RedirectPage= new PageReference('/apex/vfBLSGLendingReferralForm');
            }
            
            RedirectPage.setRedirect(true);
            
        }
        
        return RedirectPage;
    }
}