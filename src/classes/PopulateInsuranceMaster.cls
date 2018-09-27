public class PopulateInsuranceMaster {
    
    List<String> coverage_attributes = new List<String> {'Coverage_State__c','Name','Bodily_injury_Individual__c','Bodily_injury_Maximum__c',
        'Property_Damage__c','Medical_Payments__c','UM_UIM_Bodily_Injury_Individual__c','UM_UIM_Bodily_Injury_Maximum__c',
        'UM_UIM_Property_Damage__c','Comprehensive__c','Collision__c','Road_Service__c','Vehicle_Expenses_Comp__c',
        'Vehicle_Expenses_Coll__c','Annual_Premium','Monthly_Premium'};
            
            public PopulateInsuranceMaster() {
                for (Coverage_Master__c coverages: [select Coverage_State__c,Name,Bodily_injury_Individual__c,Bodily_injury_Maximum__c,
                                                    Property_Damage__c,Medical_Payments__c,UM_UIM_Bodily_Injury_Individual__c,UM_UIM_Bodily_Injury_Maximum__c,
                                                    UM_UIM_Property_Damage__c,Comprehensive__c,Collision__c,Road_Service__c,Vehicle_Expenses_Comp__c,
                                                    Vehicle_Expenses_Coll__c from Coverage_Master__c]) {
                                                        System.debug('processing coverage: '+coverages.Name);
                                                        sendMessage(coverages);
                                                    }
            }
    
    public boolean sendMessage (Coverage_Master__C cvm) {
        boolean status = true;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://wasrestserver.herokuapp.com/SaveCoveragePremium');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        // Set the body as a JSON object
        //request.setBody('{"Name":"mighty moose"}');
        //System.debug('createJSONString: '+createJSONString(cvm));
        request.setBody(createJSONString(cvm));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            status = false;
        } else {
            System.debug(response.getBody());
        }
        return status;
    }    
    public String createJSONString(Coverage_Master__C cvm) {
        String retJSON = '';
        JSONGenerator jg = JSON.createGenerator(true);
        jg.writeStartObject();
        for ( integer i=0;i<coverage_attributes.size();i++ ) {
            if ( getFieldType(coverage_attributes[i]) == 'STRING' ||
                getFieldType(coverage_attributes[i]) == 'PICKLIST') {
                    jg.writeStringField(coverage_attributes[i], (String)cvm.get(coverage_attributes[i]));
                    //System.debug('field: '+coverage_attributes[i]+' value: '+cvm.get(coverage_attributes[i]));
                } else if (getFieldType(coverage_attributes[i]) == 'CURRENCY') {
                    jg.writeNumberField(coverage_attributes[i], (double)cvm.get(coverage_attributes[i]));
                    //System.debug('field: '+coverage_attributes[i]+' value: '+cvm.get(coverage_attributes[i]));
                } else if (getFieldType(coverage_attributes[i]) == 'error' && 
                           coverage_attributes[i] == 'Annual_Premium' ) {
                               jg.writeNumberField(coverage_attributes[i], (double)cvm.get(coverage_attributes[5]));
                               //System.debug('field: '+coverage_attributes[i]+' value: '+cvm.get(coverage_attributes[5]));
                           } else if (getFieldType(coverage_attributes[i]) == 'error' && 
                                      coverage_attributes[i] == 'Monthly_Premium' ) {
                                          jg.writeNumberField(coverage_attributes[i], (double)cvm.get(coverage_attributes[9]));
                                          //System.debug('field: '+coverage_attributes[i]+' value: '+cvm.get(coverage_attributes[9]));
                                      }
        }
        jg.writeEndObject();
        
        //System.debug('json: '+jg.getAsString());
        
        return jg.getAsString();
    }
    public static String getFieldType(String fieldName){
        // Assume that "sObjectName" is populated elsewhere
        String sObjectName = 'Coverage_Master__C';
        String fieldType = '';
        Schema.SObjectType tSObj1 = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult drSObj1 = tSObj1.getDescribe();
        try {
            Map<String,Schema.SObjectField> mapFields = drSObj1.fields.getMap();
            Schema.SObjectField tField1 = mapFields.get(fieldName);
            Schema.DescribeFieldResult drField1 = tField1.getDescribe();
            Schema.DisplayType dType = drField1.getType();
            fieldType = String.ValueOf(dType);
            //System.debug('field: '+fieldName+' type: '+fieldType);
        } catch (Exception e) {
            //System.debug('error: fieldName: '+fieldName+' error: '+e.getMessage());
            fieldType = 'error';
        }
        return fieldType;
    }
}