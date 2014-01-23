/**************************************************************************************************
 * Purpose: Query Utility
 * Author: PwC (Keen)
 * Create Date (yyyy-MM-dd): 2013-10-28
 * Modify History:
 * Keen    2013-10-28    Created
***************************************************************************************************/

global class BPQueryUtil {
    //Query by a single Id which will return only 1 record
    public static sObject query(Id sObjectId, String sObjectName){      
        List<sObject> objs=query(new List<String>{sObjectId},sObjectName,null,null);
        return objs.size()>0?objs[0]:null;      
    }
    //Query by list of Ids as well as filters
    public static List<sObject> query(List<Id> sObjectIds, String sObjectName, String filters, String orderBy){
        String sql = buildQueryString(sObjectIds,sObjectName,filters,orderBy);      
        return Database.query(sql);         
    }

    //Query by list of Ids as well as filters
    public static Map<Id, sObject> queryMap(List<Id> sObjectIds, String sObjectName, String filters, String orderBy){
        String sql = buildQueryString(sObjectIds,sObjectName,filters,orderBy);
        Map<Id, sObject> sObjMap = new Map<Id, sObject>(Database.query(sql));  
        system.debug('*** sObjectMap: ' + sObjMap);
        return sObjMap;
    }
    
    //Build the SOQL according to the input
    public static String buildQueryString(List<Id> sObjectIds, String sObjectName, String filters, String orderBy){
        Map<String,schema.sObjectField> fieldTypeMap=Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        
        String sql='select id';
        for(String fn:fieldTypeMap.keyset()){               
            if(fn.toLowerCase()!='id' && fn.toLowerCase() != 'geolocation__c'){//to deal with geolocation fields later, exclude it for now
                sql=sql + ',' + fn;
            }                           
        }
        
        sql=sql + ' from ' + sObjectName;
        
        String ids = '';
        if(sObjectIds !=null && sObjectIds.size() > 0){         
            for(String id : sobjectIds){
                if(ids == ''){
                    ids = '(' + '\'' + id + '\'';
                }else{
                    ids = ids + ',' + '\'' + id + '\'';
                }
            }
            if(ids != '') ids = ids + ')';              
        }
        
        if(ids != ''){
            sql = sql + ' where Id IN' + ids;
            if(filters != null){
                sql = sql + ' and (' + filters + ')';   
            }
        }else{
            if(filters != null){
                sql = sql + ' where (' + filters + ')';
            }
        }
        
        if(orderBy != null){
            sql = sql + ' order by ' + orderBy;
        }
        
        //system.debug('*** soql: ' + sql);
        
        return sql;
    }
}