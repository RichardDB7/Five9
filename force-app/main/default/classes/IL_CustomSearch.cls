/**
 * @description : Clase para la central Five9.
 * @author Bluetech
 * @group InLearning
 * @last modified on  : 23-02-2025
 * @last modified by  : Ricardo
 * Modifications Log:
 * Ver   Date         Author          Modification
 * 1.0   23-02-2025   Ricardo Diaz    Creación de la clase 
 */
global with sharing class IL_CustomSearch {
    private static Map<String,String> prefixTypes = new Map<String,String>{'003' => 'Contact', '001' => 'Account', '00Q' => 'Lead', '701' => 'Campaign', '500' => 'Case', '006' => 'Opportunity', '00T' => 'Task', '005' => 'User', '00U' => 'Event'};
        
        private static Map<String, String> nameMap = new Map<String, String>{
            'Account' => 'Name',
                'Case' => 'CaseNumber',
                'Contact' => 'Name',
                'Lead' =>  'Name',
                'Campaign' => 'Name',
                'Opportunity' => 'Name',
                'Task' => 'Subject',
                'User' => 'Name',
                'Event' => 'Subject'
                };
                    
                    private class SearchData {
                        SearchData(String type, String field, String value) {
                            this.type = type;
                            this.field = field;
                            this.value = value;
                        }
                        String type;
                        String field;
                        String value;
                    }
    
    // used for search (for voice interactions) in classic SalesForce  
    webService static String search(String callInfo, String crm, String cav, String softphoneLayout, String c2dObjectIdJSON) {
        ClassicActions actions = new ClassicActions();
        return searchImpl(callInfo, crm, cav, softphoneLayout, c2dObjectIdJSON, actions);
    }
    
    // used for search (for voice interactions) in SalesForce Lightning
    webService static String searchLightning(String callInfo, String crm, String cav, String softphoneLayout, String c2dObjectIdJSON) {
        ClassicActions actions = new LightningActions();
        return searchImpl(callInfo, crm, cav, softphoneLayout, c2dObjectIdJSON, actions);
    }
    
    // used for search (for text interactions, emails, chats) in SalesForce Lightning, based on email field
    webService static String searchConfig(String params, String softphoneLayout) {
        softphoneLayout = EncodingUtil.urlDecode(softphoneLayout, 'UTF-8');
        params = EncodingUtil.urlDecode(params, 'UTF-8');
        
        Map<String, Object> layoutMap = (Map<String, Object>)JSON.deserializeUntyped(softphoneLayout);
        Map<String, Object> paramsMap = (Map<String, Object>)JSON.deserializeUntyped(params);
        
        if('textInteractions'.equals((String)paramsMap.get('searchType'))) {
            ClassicActions actions;
            if ('Classic'.equals((String)paramsMap.get('salesforceCompatibilityMode'))) {
                actions = new ClassicActions();
            } else {
                actions = new LightningActions();
            }
            return searchTextInteractions(paramsMap, layoutMap, actions);
        }
        
        return null;
    }
    
    private static String searchTextInteractions(Map<String, Object> paramsMap, Map<String, Object> layoutMap, ClassicActions actions) {
        List<sObject> queryResult = new List<sObject>();
        
        String email = (String)paramsMap.get('email');
        Map<String, Object> inboundLayout = (Map<String, Object>)layoutMap.get('Inbound');
        Map<String, Object> layoutObjects = (Map<String, Object>)inboundLayout.get('objects');
        String query = generateEmailQuery(email, layoutObjects);
        if (query != null) {
            List<List<sObject>> objectLists = search.query(query);
            for(List<sObject> objectList: objectLists) {
                queryResult.addAll(objectList);
            }
        }
        
        Map<String,Object> resultObject = new Map<String,Object>();
        resultObject.put('objects', generateOutput(layoutObjects, queryResult));
        
        //Gen visual force page params:
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('email', email);
        System.PageReference pageReference = new System.PageReference('');
        pageReference.getParameters().putAll(parameters);
        
        Object url = actions.getScreenpopURL(queryResult, (Map<String, Object>)inboundLayout.get('screenPopSettings'), email, pageReference);
        resultObject.put('url', url);
        
        return JSON.serialize(resultObject);
    }
    
    private static String searchImpl(String callInfo, String crm, String cav, String softphoneLayout, String c2dObjectIdJSON, ClassicActions actions) {
        callInfo = EncodingUtil.urlDecode(callInfo, 'UTF-8');
        crm = EncodingUtil.urlDecode(crm, 'UTF-8');
        cav = EncodingUtil.urlDecode(cav, 'UTF-8');

        System.debug('---------------- callInfo ----------------');
        System.debug(callInfo);        
        System.debug('---------------- callInfo ----------------');
        System.debug('---------------- crm ----------------');
        System.debug(crm);        
        System.debug('---------------- crm ----------------');
        System.debug('---------------- cav ----------------');
        System.debug(cav);        
        System.debug('---------------- cav ----------------');
        System.debug('---------------- softphoneLayout ----------------');
        System.debug(softphoneLayout);        
        System.debug('---------------- softphoneLayout ----------------');
        System.debug('---------------- c2dObjectIdJSON ----------------');
        System.debug(c2dObjectIdJSON);       
        System.debug('---------------- c2dObjectIdJSON ----------------');


        softphoneLayout = EncodingUtil.urlDecode(softphoneLayout, 'UTF-8');
        c2dObjectIdJSON = EncodingUtil.urlDecode(c2dObjectIdJSON, 'UTF-8');
        List<SearchData> searchData = getJsonSearchData(cav);
        if(searchData.isEmpty()) {
            searchData = getJsonSearchData(crm);
        }
                        
        Map<String, Object> callInfoMap = (Map<String, Object>)JSON.deserializeUntyped(callInfo);
        Map<String, Object> cavMap = (Map<String, Object>)JSON.deserializeUntyped(cav);
        System.debug(cavMap);
        Map<String, Object> crmMap = (Map<String, Object>)JSON.deserializeUntyped(crm);
        Map<String, Object> layoutMap = (Map<String, Object>)JSON.deserializeUntyped(softphoneLayout);
        String layoutName = getLayout(callInfoMap);
        Map<String, Object> layout = (Map<String, Object>)layoutMap.get(layoutName);
        Map<String, Object> layoutObjects = (Map<String, Object>)layout.get('objects');
        
        
        System.debug('---------------- callInfoMap ----------------');
        System.debug(callInfoMap);        
        System.debug('---------------- callInfoMap ----------------');        
        System.debug('---------------- crmMap ----------------');
        System.debug(crmMap);        
        System.debug('---------------- crmMap ----------------');       
        System.debug('---------------- cavMap ----------------');
        System.debug(cavMap);       
        System.debug('---------------- cavMap ----------------');
       
        
        
        String Dni = '';
        //List<String> objectQueries = generateObjectQueries(searchData, layoutObjects);
        List<String> objectQueries = new List<String>();
        
        if(String.isNotBlank(Dni)){
            objectQueries.add('SELECT'+ getFieldsForObject(layoutObjects, 'Account') + 'FROM Account WHERE DniTest__c = \''+ Dni+'\'');
        }
        
                
        List<sObject> queryResult = new List<sObject>();
        for(String query: objectQueries) {     try {    queryResult.addAll(Database.query(query));   System.debug(query);   } catch (Exception e) {    System.debug(e.getMessage());   }   }
        
        Map<String,Object> resultObject = new Map<String,Object>();
        resultObject.put('objects', generateOutput(layoutObjects, queryResult));
        
        Map<String, Object> inboundLayout = (Map<String, Object>)layoutMap.get('Inbound');
        Map<String, Object> inboundScreenPopSettings = (Map<String, Object>)inboundLayout.get('screenPopSettings');
        
        Object url = actions.getScreenpopURL(queryResult, inboundScreenPopSettings, (String)callInfoMap.get('number'), generatePayload(callInfoMap, crmMap, cavMap, queryResult));
        resultObject.put('url', url);
        System.debug(resultObject);
        return JSON.serialize(resultObject);
    }
    
    
    private static List<SearchData> getSfIdSearchData(String sfId) {
        List<SearchData> result = new List<SearchData>();
        for (String objectPrefix: prefixTypes .keySet()){
            if(sfId.startsWith(objectPrefix)) {
                SearchData data = new SearchData(prefixTypes.get(objectPrefix), 'Id', sfId);
                result.add(data);
                return result;    }   }   for (String objectPrefix: prefixTypes.keySet()){    SearchData data = new SearchData(prefixTypes.get(objectPrefix), 'Id', sfId);   result.add(data);   }    return result;   }
    
    private static List<SearchData> getJsonSearchData(String jsonMap) {
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(jsonMap);
        List<SearchData> searchData = new List<SearchData>();
        String sfId = (String)fieldMap.get('salesforce_id');
        if(String.isNotBlank(sfId)) {
            searchData.addAll(getSfIdSearchData(sfId));
        }
        return searchData;
    }
    
    private static List<String> generateObjectQueries(List<SearchData> searchData, Map<String, Object> layoutObjects) {
        List<String> result = new List<String>();
        Map<String, Map<String,String>> mapObjectQueries = new Map<String, Map<String,String>>();
        for(SearchData data: searchData) {
            String objType = data.type;
            if(layoutObjects.containsKey(objType)) {
                if(mapObjectQueries.containsKey(objType)) {
                    mapObjectQueries.get(objType).put(data.field, data.value);
                }
                else {
                    mapObjectQueries.put(objType, new Map<String, String>{data.field => data.value});
                }
            }
        }
        
        for(String objType: mapObjectQueries.keySet()) {
            String query = 'Select ' + getFieldsForObject(layoutObjects, objType) + ' From ' + objType + ' Where ';
            Boolean first = true;
            Map<String, String> mapFields = mapObjectQueries.get(objType);
            for(String fieldName: mapFields.keySet()) {
                if(first) {
                    first = false;
                }
                else {
                    query += ' and ';
                }
                query += fieldName + '=\'' + mapFields.get(fieldName) + '\'';
            }
            result.add(query);
        }
        return result;
    }
    
    private static String getLayout(Map<String, Object>  mapCallInfo) {
        String callType = (String)mapCallInfo.get('callType');
        if('Inbound'.equals(callType)) {
            return callType;
        }
        else if('Internal'.equals(callType)) {
            return callType;  }   else {    return 'Outbound';   }  }
    
    private static String getFieldsForObject(Map<String, Object> layoutObjects, String objType) {
        List<Object> fieldList = (List<Object>)layoutObjects.get(objType);
        String fields = '';
        String nameField = nameMap.get(objType);
        for(Object field: fieldList) {
            Map<String, Object> mapField = (Map<String, Object>)field;
            String fieldApiName = (String)mapField.get('apiName');
            if(!fieldApiName.equals('Id') && !fieldApiName.equals(nameField)) {
                fields += fieldApiName + ',';
            }
        }
        fields += 'Id';
        if(String.isNotBlank(nameField)) {
            fields += ',' + nameField;
        }
        return fields;
    }
    
    private static void populateResult(Map<String, Object> layoutObjects, sObject obj, Map<String,Object> result) {  String objType = obj.getSObjectType().getDescribe().getName();   List<Object> fieldList = (List<Object>)layoutObjects.get(objType);   List<Map<String,Object>> resultFields = new List<Map<String,Object>>();   String nameField = nameMap.get(objType);   for(Object field: fieldList) {    Map<String, Object> mapField = (Map<String, Object>)field;   String fieldApiName = (String)mapField.get('apiName');    if(!fieldApiName.equals(nameField)) {   String fieldDisplayName = (String)mapField.get('displayName');  Object fieldValue = obj.get(fieldApiName);  resultFields.add(new Map<String,Object>{fieldDisplayName => fieldValue == null? '' : fieldValue});   }   }  resultFields.add(new Map<String,Object>{'object' => objType});   if(String.isNotBlank(nameField)) {   Object fieldValue = obj.get(nameField);   resultFields.add(new Map<String,Object>{'f9ObjectDisplayName' => fieldValue == null? '' : fieldValue});   }    String Id = (String)obj.get('Id');  result.put(Id, resultFields);   }  public virtual with sharing class ClassicActions {  public Object getScreenpopURL(List<sObject> objectList, Map<String, Object> screenpopSettings, String searchString, System.PageReference additionalParams)
     {
            String result = null;
            Map<String, Object> matchSettings = getMatchSettings(objectList, screenpopSettings);
            String screenPopType = (String)matchSettings.get('screenPopType');
            if (additionalParams.getParameters().containsKey('flowDevName')){
                return getFlowScreenPop(additionalParams.getParameters().get('flowDevName'), additionalParams);
            } else if('PopToEntity'.equals(screenPopType)) {
                String screenPopData = (String)matchSettings.get('screenPopData');
                if(objectList.size() == 0 && screenPopData != null) {
                    return getNewEntityScreenPop(screenPopData);   }   else if(objectList.size() == 1) {    return getEntityScreenPop((String)objectList.get(0).get('Id'));    }   }   else if('PopToSearch'.equals(screenPopType)) {   return getSearchPageScreenPop(searchString);  }    else if('PopToVisualforce'.equals(screenPopType)) {    return getVfScreenPop((String)matchSettings.get('screenPopData'), additionalParams);   }   else if('PopToFlow'.equals(screenPopType)) {   return getFlowScreenPop((String)matchSettings.get('screenPopData'), additionalParams);   }    return result;   }
        
        protected Schema.DescribeSObjectResult getEntityToCreate(String screenPopData) {
            String[] typeToFind = new String[1];
            typeToFind[0] = screenPopData;
            Schema.DescribeSobjectResult[] results = null;
            try {
                results = Schema.describeSObjects(typeToFind);   } catch (Exception e) {
                System.debug(e.getMessage());
            }
            if (results == null || results.isEmpty()) {    typeToFind[0] = screenPopData + '__c';   try {    results = Schema.describeSObjects(typeToFind);    } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
            if (results == null || results.isEmpty()) {   List<PackageLicense> packages = [SELECT NamespacePrefix FROM PackageLicense];   for (PackageLicense packageLicense: packages) {   typeToFind[0] = packageLicense.NamespacePrefix + '__' + screenPopData + '__c';   try {   results = Schema.describeSObjects(typeToFind);   if (results != null && !results.isEmpty()) {    break;    }    } catch (Exception e) {   System.debug(e.getMessage());
                    }
                }
            }
            if (results == null || results.isEmpty()) {    return null;
            } else {
                return results[0];
            }
        }
        
        protected Map<String, Object> getMatchSettings(List<sObject> objectList, Map<String, Object> screenpopSettings) {
            String matchType;
            if(objectList.size() == 0) {
                matchType = 'NoMatch';    }   else if(objectList.size() == 1) {    matchType = 'SingleMatch';   }   else {    matchType = 'MultipleMatches';   }
            
            return (Map<String, Object>)screenpopSettings.get(matchType);   }   protected virtual Object getEntityScreenPop(String recordId) {    return recordId;   }
        
        protected virtual Object getNewEntityScreenPop(String screenPopData) {
            Schema.DescribeSObjectResult describe = getEntityToCreate(screenPopData);
            if (describe != null) {
                String prefix = describe.getKeyPrefix();
                if(prefix != null) {
                    return prefix + '/e';     }    }    return null;   }
        
        protected virtual Object getSearchPageScreenPop(String searchString) {   return 'search/SearchResults?searchType=2&str=' + searchString;    }   protected virtual Object getVfScreenPop(String vfPage, System.PageReference additionalParams) {     return 'apex/' + vfPage + additionalParams.getUrl();    }    protected virtual Object getFlowScreenPop(String flowName, System.PageReference additionalParams) {    return 'flow/' + flowName + additionalParams.getUrl();    }   }   public with sharing class LightningActions extends ClassicActions {   protected override Object getEntityScreenPop(String recordId) {   return new Map<String, Object> {   'type' => 'sobject',   'params' => new Map<String, Object> { 'recordId' => recordId}   };    }
        
        protected override Object getNewEntityScreenPop(String screenPopData) {
            Schema.DescribeSObjectResult describe = getEntityToCreate(screenPopData);
            if (describe != null) {
                return new Map<String, Object> {
                    'type' => 'newRecord',
                        'params' => new Map<String, Object> { 'entityName' => describe.getName()}     };      }      return null;   }   protected override Object getSearchPageScreenPop(String searchString) {    return new Map<String, Object> {   'type' => 'search',   'params' => new Map<String, Object> { 'searchString' => searchString}   };   }
        
        protected override Object getVfScreenPop(String vfPage, System.PageReference additionalParams) {
            String url = '/apex/' + vfPage + additionalParams.getUrl();
            return new Map<String, Object> {
                'type' => 'url',
                    'params' => new Map<String, Object> { 'url' => url}
            };
                }
        
        protected override Object getFlowScreenPop(String flowName, System.PageReference additionalParams) {
            return new Map<String, Object> {
                'type' => 'flow',
                    'params' => new Map<String, Object> { 'flowDevName' => flowName, 'flowArgs' => getFlowPayload(additionalParams)}
            };
                }
        
        private List<Map<String, Object>> getFlowPayload(System.PageReference additionalParams) {
            List<Map<String, Object>> result = new List<Map<String, Object>>();
            Map<String, String> params = additionalParams.getParameters();
            for (String fieldName: params.keySet()) {
                result.add(new Map<String, String> {'name' => fieldName,
                    'type' => 'String',
                    'value' => params.get(fieldName)});
            }
            return result;
        }
    }
    
    private static String generateOutput(Map<String, Object> layoutObjects, List<sObject> queryResult) {
        List<Map<String,Object>> outputList = new List<Map<String,Object>>();
        for(sObject sObj: queryResult) {     Map<String,Object> resultObject = new Map<String,Object>();    Schema.DescribeSObjectResult sObjectDescribe = sObj.getSObjectType().getDescribe();    String objType = sObjectDescribe.getName();    resultObject.put('id', (String)sObj.get('Id'));   resultObject.put('type', objType);    String objLabel = sObj.getSObjectType().getDescribe().getLabel();   resultObject.put('label', objLabel);   String nameField = getNameField(objType, sObjectDescribe);    if(String.isNotBlank(nameField)) {   Object fieldValue = sObj.get(nameField);  resultObject.put('name', fieldValue == null? '' : fieldValue);   }
            
            List<Object> layoutFieldList = (List<Object>)layoutObjects.get(objType);   List<Map<String,Object>> fields = new List<Map<String,Object>>();   for(Object layoutField: layoutFieldList) {   Map<String, Object> mapLayoutField = (Map<String, Object>)layoutField;   String fieldApiName = (String)mapLayoutField.get('apiName');    if(!fieldApiName.equals(nameField)) {    String fieldDisplayName = (String)mapLayoutField.get('displayName');   Object fieldValue = sObj.get(fieldApiName);    fields.add(new Map<String,Object>{'displayName' => fieldDisplayName, 'value' => fieldValue == null? '' : fieldValue});     }    }    resultObject.put('fields', fields);    outputList.add(resultObject);    }    return JSON.serialize(outputList);    }    private static String generateEmailQuery(String email, Map<String, Object> layoutObjects) {
        if (layoutObjects.size() == 0) {    return null;
        }
        
        return 'FIND \'' + email + '\' IN EMAIL FIELDS RETURNING ' + generateReturningQuery(layoutObjects);
    }
    
    private static System.PageReference generatePayload(Map<String, Object> callInfo, Map<String, Object> crm, Map<String, Object> cav, List<sObject> objectList) {
        Map<String, String> parameters = new Map<String, String>();
        String ani = (String)callInfo.get('ani');
        if(ani != null) {    parameters.put('ANI', ani);
        }
        
        String dnis = (String)callInfo.get('dnis');
        if(dnis != null) {    parameters.put('DNIS', dnis);
        }
        
        for(String key: crm.keySet()) {    parameters.put(key, (String)crm.get(key));
        }
        
        for(String key: cav.keySet()) {
            parameters.put(key, (String)cav.get(key));
        }
        
        for(sObject obj: objectList) {    parameters.put((String)obj.get('Id'), obj.getSObjectType().getDescribe().getName());
        }
        
        System.PageReference pageReference = new System.PageReference('');
        pageReference.getParameters().putAll(parameters);
        return pageReference;   }   private static String getNameField(String objType, Schema.DescribeSObjectResult sObjectDescribe) {   String nameField = nameMap.get(objType);  if (nameField == null) {   Schema.DescribeSObjectResult describe = null;   if (sObjectDescribe == null) {   Schema.DescribeSobjectResult[] results = null;   results = Schema.describeSObjects(new String[] {objType});   describe = results[0];   } else {   describe = sObjectDescribe;   }   Map<String, SObjectField> fields = describe.fields.getMap();  if (fields.get('Name') != null &&   fields.get('Name').getDescribe().isNameField()) {    nameField = 'Name';   } else {   for (String field: fields.keySet()) {   Schema.DescribeFieldResult fieldDescribe = fields.get(field).getDescribe();    if (fieldDescribe.isNameField()) {   nameField = fieldDescribe.getName();    break;    }   }   }   }       return nameField;    }
    
    private static String generateReturningQuery(Map<String, Object> layoutObjects) {
        List<String> objList = new List<String>();
        
        for(String objType: layoutObjects.keySet()) {
            String request = objType + '(' + getFieldsForObject(layoutObjects, objType);
            if (objType.equalsIgnoreCase('lead')) {     request += ' Where IsConverted = FALSE';   }
            request += ')';
            objList.add(request);
        }
        
        return String.join(objList, ', ');
    }
}