/**************************************************************************************************
 * Name: ClsPerformanceSummaryEntity
 * Author: Keen Xu
 * Create Date: 2013-05-31
 * Modify History: 
 * 2013-05-31    Keen	Created
***************************************************************************************************/
//Entity of the Performance Summary which will be displayed as a inline visualforce page
public class ClsPerformanceSummaryEntity implements Comparable {
	
	public ClsPerformanceSummaryEntity(){
		year = 1900;
		janProduction = 0;
		febProduction = 0;
		marProduction = 0;
		aprProduction = 0;
		mayProduction = 0;
		junProduction = 0;
		julProduction = 0;
		augProduction = 0;
		sepProduction = 0;
		octProduction = 0;
		novProduction = 0;
		decProduction = 0;
		totalProduction = 0;
	}
	public ID id{get;set;}
	public Integer year{get;set;}
	public Decimal janProduction{get;set;}
	public Decimal febProduction{get;set;}
	public Decimal marProduction{get;set;}
	public Decimal aprProduction{get;set;}
	public Decimal mayProduction{get;set;}
	public Decimal junProduction{get;set;}
	public Decimal julProduction{get;set;}
	public Decimal augProduction{get;set;}
	public Decimal sepProduction{get;set;}
	public Decimal octProduction{get;set;}
	public Decimal novProduction{get;set;}
	public Decimal decProduction{get;set;}
	public Decimal totalProduction{get;set;}
	
	public Integer compareTo(Object compareTo) {
        ClsPerformanceSummaryEntity entity = (ClsPerformanceSummaryEntity)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (this.year > entity.year) {
            // Set return value to a positive value.
            returnValue = -1;
        } else if (this.year < entity.year) {
            // Set return value to a negative value.
            returnValue = 1;
        }
        
        return returnValue;       
    }
}