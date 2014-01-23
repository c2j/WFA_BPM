@isTest
private class BPCommonUtilTest {
	private static testmethod void testCommonUtil(){
		BPCommonUtil.getYear(Date.today());
		BPCommonUtil.getYear(null);
		
		BPCommonUtil.getYearString(Date.today());
		BPCommonUtil.getYearString(null);
		
		BPCommonUtil.fromatString2Long('1243');
		
		BPCommonUtil.fromatString2Double('1243', 2);
		
		BPCommonUtil.getNumberFormat('1243', 2);
		BPCommonUtil.getNumberFormat(1243.123, 2);
		
		BPCommonUtil.getDefaultNumberFormat(1243);
		BPCommonUtil.getDefaultNumberFormat(null);
		BPCommonUtil.defaultNull(12.34);
		
		BPCommonUtil.defaultNull(Date.today());
		
		BPCommonUtil.formatCurrency(1111111.11);
		BPCommonUtil.formatCurrency(111111.11);
		BPCommonUtil.formatCurrency(11.11);
		BPCommonUtil.formatCurrency(0);
		
		BPCommonUtil.formatNumber(1111111.11);
		BPCommonUtil.formatNumber(111111.11);
		BPCommonUtil.formatNumber(11.11);
		BPCommonUtil.formatNumber(0);
		
		BPCommonUtil.log('test');
		BPCommonUtil.log('test', new contact());
		BPCommonUtil.logJson('test', new contact());
		
		BPCommonUtil.defaultNull('aaa');
		BPCommonUtil.defaultNull('');
		BPCommonUtil.formatLink('www.google.com');
	}
}