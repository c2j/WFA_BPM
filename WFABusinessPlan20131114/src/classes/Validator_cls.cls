global class Validator_cls{ 

    private static boolean blnAlreadyDone = false; 
    
    public static boolean hasAlreadyDone(){ 
        return blnAlreadyDone; 
    }
        
    public static void setAlreadyDone() {
    
    blnAlreadyDone = true;
    }
    
    public static void resetAlreadyDone() {
    
        blnAlreadyDone = false;
        
    }
 
}