public class vfSubmissionConfirmationCtrlr {

    public String MainPageName {get {if (MainPageName == '' || MainPageName == null) {MainPageName = 'NoMainPage'; } return MainPageName; } set;}
    public String ConfirmationText {get;set;}
    public PageReference RedirectPage {get {if (RedirectPage == null) {RedirectPage = null; } return RedirectPage; } set;}
    
    public vfSubmissionConfirmationCtrlr () {
        
        if (ApexPages.currentPage().getParameters().get('id') != Null || ApexPages.currentPage().getParameters().get('id') != '') {
           MainPageName = ApexPages.currentPage().getParameters().get('id');
        
            if (MainPageName.contains('FASeminarFeedback')) {
                ConfirmationText = 'You will now be directed to the Seminar Express Page on InfoMax.';
            } else if (MainPageName.contains('NSCAR')) {
                ConfirmationText = 'You will now be directed to the NSCAR Page on Infomax.';
            } else if (MainPageName.contains('BLSGReferral')) {
                integer i = MainPageName.indexof('BLSG');
                string channel = MainPageName.substring(0,i);
                ConfirmationText = 'You will now be directed to the ' + channel + ' Business Financing Services Page on Infomax.';
            }
            
            Redirect();
            
        }
    }
    
    
    public PageReference Redirect () {
    
        //PageReference RedirectPage;
        
        if (MainPageName == 'FiNetFASeminarFeedback') {
             RedirectPage = new PageReference('https://my.advisor-connection.com/infomax/finet/marketing/personal_marketing/seminar_express/seminar_express.aspx?srcApp=search');

        } else if (MainPageName == 'PCGFASeminarFeedback') {
             RedirectPage = new PageReference('https://my.advisor-connection.com/infomax/pcg/marketing/personal_marketing/seminar_express/seminar_express.aspx?srcApp=search');
        
        } else if (MainPageName == 'NSCARForm') {
            
            RedirectPage = new PageReference('https://my.advisor-connection.com/infomax/pcg/home.aspx');
            
        } else if (MainPageName == 'PCGBLSGReferralForm') {
        
            RedirectPage = new PageReference('https://my.advisor-connection.com/infomax/PCG/products/banking_services/affluent_banking_products/business/business_financing_services.aspx');
        
        } else if (MainPageName == 'FiNetBLSGReferralForm') {
        
            RedirectPage = new PageReference('https://my.advisor-connection.com/infomax/FiNet/products/banking_services/affluent_banking_products/business/business_financing_services.aspx');
        
        } else if (MainPageName == 'FCCSBLSGReferralForm') {
        
            RedirectPage = new PageReference('https://my.advisor-connection.com/infomax/ccg/products/banking_services/affluent_banking_products/business/business_financing_services.aspx');
        
        }
        
        if (RedirectPage != Null) {
            RedirectPage.setRedirect(true);
            
            system.debug('Redirect Page ----------- ' + RedirectPage);
        }
        
        return RedirectPage;
        
    }
    
    

}