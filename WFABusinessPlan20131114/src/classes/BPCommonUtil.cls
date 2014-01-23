/**************************************************************************************************
 * Purpose: Common Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-11-06
 * Modify History:
 * Keen    2013-11-06    Created
***************************************************************************************************/
global class BPCommonUtil {
	//Default Decimal Places
	public static final Integer NUM_PRECISION = 2;
	//HTTP prefix String
	public static final String PREFIX_STRING_HTTP = 'http:';
	
	public static final String STRING_HTTP = 'http://';
	
	//Get the year part. Return 0 in case of null input
	public static Integer getYear(Date currDate){
		if(currDate == null){
			return 0;
		}
		
		return currDate.year();
	}
	
	//Get the year part as string. Return 0 in case of null input
	public static String getYearString(Date currDate){
		return String.valueOf(getYear(currDate));
	}
	
	//format string to long with 0 decimal places
	public static long fromatString2Long(String source) {
		decimal value = getNumberFormat(source, 0);
		return value.longValue();
	}
	
	//format string to Double
	public static Double fromatString2Double(String source, Integer precision) {
		decimal value = getNumberFormat(source, precision);
		return value.doubleValue();
	}
	
	//format string to double
	public static decimal getNumberFormat(String source, Integer precision) {
		if(source == null || source == '') {
			source = '0';
		}
		decimal value = decimal.valueOf(source);
		value = getNumberFormat(value, precision);
		return value;
	}
	
	//format the number with specified decimal places
	public static decimal getNumberFormat(decimal source, Integer precision) {
		if(source == null) {
			source = 0;
		}
		decimal value = source.setScale(precision, RoundingMode.HALF_UP);
		return value;
	}
	
	//Format the input into 0 decimal places
	public static decimal getDefaultNumberFormat(decimal source) {
		return getNumberFormat(source, 0);
	}
	
	//Return 0 if null, otherwise return the input
	public static decimal defaultNull (decimal source) {
		if(source == null){
			return 0;
		}
		return source;
	}
	//Return blank if null, otherwise return the input
	public static String defaultNull (String source) {
		if(source == null){
			return '';
		}
		return source;
	}
	//Return very early date (1900) if null, otherwise return the input
	public static Date defaultNull (Date source) {
		if(source == null){
			return Date.newInstance(1900, 1, 1);
		}
		return source;
	}
	//Format the link to start with 'HTTP://'
	public static String formatLink(String link) {
    	
    	if(!link.startsWith(PREFIX_STRING_HTTP)) link = STRING_HTTP + link;
    	
    	return link;
    }
    
    //Format the currency into $ ###,### M format with default 2 decimal places
    public static String formatCurrency(Decimal currValue){
    	return formatCurrency(currValue, 2);
    }
    
    //Format the currency into $ ###,### M
    public static String formatCurrency(Decimal currValue, Integer decimalPlaces){
    	return formatCurrency(currValue, decimalPlaces, 'M');
    }
    
    //Format the currency into $ ###,### M or $ ###,### K format. symbol is either M or K
    public static String formatCurrency(Decimal currValue, Integer decimalPlaces, String symbol){
    	if(currValue == null || currValue == 0){
    		return '-';
    	}
    	
    	Decimal decValue = 0;
    	String currValueStr = '0';
    	
    	if(symbol == 'K'){
    		decValue = BPCommonUtil.getNumberFormat(currValue/1000, decimalPlaces);
	    	currValueStr = '$' + formatNumberWithComma(decValue) + ' K';
    	}
    	else{
	    	decValue = BPCommonUtil.getNumberFormat(currValue/1000000, decimalPlaces);
	    	currValueStr = '$' + formatNumberWithComma(decValue) + ' M';
    	}
    	
    	return currValueStr;
    }
    //Format the number into ###,### format
    public static String formatNumber(Decimal currValue){
    	if(currValue == null || currValue == 0){
    		return '-';
    	}
    	
    	String currValueStr = formatNumberWithComma(currValue);
    	
    	return currValueStr;
    }
    //Format the number into ###,### format. Does not support number greater than 1,000,000,000
    public static  String formatNumberWithComma(Decimal currValue){
    	if(currValue == null){
    		currValue = 0;
    	}
    	
    	String origValueStr = String.valueOf(currValue);
    	String decimalPart = '';
    	String integerPart = '';
    	if(origValueStr.indexOf('.')>0){
    		decimalPart = '.' + origValueStr.subStringAfter('.');
    		integerPart = origValueStr.subStringBefore('.');
    	}
    	else{
    		decimalPart = '';
    		integerPart = origValueStr;
    	}
    	
    	Decimal integerValue = Decimal.valueOf(integerPart);
    	
    	if(integerValue < 1000){
    		integerPart = integerPart;
    	}
    	else if(integerValue < 1000000){
    		integerPart = Math.floor(integerValue/1000) + ',' + integerPart.right(3);
    	}
    	else if(integerValue < 1000000000){
    		integerPart = Math.floor(integerValue/1000000) + ',' + integerPart.right(6).left(3) + ',' + integerPart.right(3);
    	}
    	
    	
    	return integerPart + decimalPart;
    }
    
	//****************Start Apex Related Common Method********************************************************************************************
	public static String getQueryString(String key){
		return ApexPages.currentPage().getParameters().get(key);
	}
	
	//Log the input string
	public static void log(String name){
		system.debug(logginglevel.INFO, '### ' + name);
	}
	//Log the input string as well as it's associated object
	public static void log(String name, object obj){
		system.debug(logginglevel.INFO, '### ' + name + ': ' + obj);
	}
	//Log the input string as well as it's associated object in a JSON format
	public static void logJson(String name, object obj){
		system.debug(logginglevel.INFO, '### ' + name + ': ' + Json.serialize(obj));
	}
	
	public static void logProfiling(String name){
		log(name + ' Profiling Start #############################################################');
		log('Total SOQL Used: ' + Limits.getQueries() + ' out of ' + Limits.getLimitQueries());
		log('Total Script STMT Used: ' + Limits.getScriptStatements() + ' out of ' + Limits.getLimitScriptStatements());
		log('Total DML STMT Used: ' + Limits.getDmlStatements() + ' out of ' + Limits.getLimitDmlStatements());
		log('Total DML Rows Used: ' + Limits.getDmlRows() + ' out of ' + Limits.getLimitDmlRows());
		log(name + ' Profiling End #############################################################');
	}
	//****************End Apex Related Common Method********************************************************************************************
}