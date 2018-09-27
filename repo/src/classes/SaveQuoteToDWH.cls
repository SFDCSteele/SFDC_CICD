public class SaveQuoteToDWH {
                
            public SaveQuoteToDWH() {
            }
    		@future(callout=true)
            public static void execute(List<String> passedQuoteIds, boolean isTest) {
                System.debug('Inside future class: SaveQuoteToDWH: passedQuoteIds: '+passedQuoteIds);
                if ( isTest ) {
                    setTest();
                }
                for (String quoteId: passedQuoteIds){
                    System.debug('receiving quotes: '+quoteId);
                    executeEach(quoteId);
                }
            }
            public static void executeEach(String passedQuoteId) {
                String messageStatus='';
                try {
	                Opportunity quote = [select Id,Name,Type,StageName,CloseDate from Opportunity where Id=:passedQuoteId];
                    List<Driver__c> drivers = [select Id,Name,First_Name__c,Last_Name__c,Drivers_License__c,Contact__c from Driver__c where Quote__c=:passedQuoteId];
                    List<Vehicle__c> vehicles = [select Id,Name,Model_Year__c,Model_Make__c,Model__c,VIN__c from Vehicle__c where Quote__c=:passedQuoteId];
                    List<Coverage__c> coverage = [select Id,name,Coverage__c,Name__c,Status__c from Coverage__c where Quote__c=:passedQuoteId and Status__c='Active'];
                    messageStatus = sendMessage(createJSONString(quote,drivers,vehicles,coverage));
                } catch (DMLException dme) {
                    System.debug('Error extracting premiums for quote: '+passedQuoteId+' error: '+dme.getMessage());
                }
            }
    
    public static String sendMessage (String outMessage) {
        String messageStatus = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://wasrestserver.herokuapp.com/api/quotes');
        request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody(outMessage);
        System.debug('sending message: '+outMessage);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' + 
                response.getStatusCode() + ' ' + response.getStatus());
            messageStatus = 'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus();
        } else {
            System.debug(response.getBody());
        }
        return messageStatus;
    }    
    public static String createJSONString(Opportunity quote,
                                   List<Driver__c> drivers,
                                   List<Vehicle__c> vehicles,
                                   List<Coverage__c> coverages) {
        JSONGenerator jg = JSON.createGenerator(true);
        jg.writeStartObject();
        jg.writeStringField('Id', (String)quote.Id);
        jg.writeStringField('Name', (String)quote.Name);
        jg.writeStringField('Type', (String)quote.Type);
        jg.writeStringField('StageName', (String)quote.StageName);
        jg.writeStringField('CloseDate', String.valueOf(quote.CloseDate));
        
        jg.writeFieldName('drivers');
        jg.writeStartArray();
        for ( Driver__c driver: drivers) {
            jg.writeStartObject();
            jg.writeStringField('Id', (String)driver.Id);
            jg.writeStringField('FirstName', (String)driver.First_Name__c);
            jg.writeStringField('LastName', (String)driver.Last_Name__c);
            if ( driver.Drivers_License__c != null ) {
	            jg.writeStringField('DriversLicense', (String)driver.Drivers_License__c);
            }
            jg.writeStringField('ContactId', (String)driver.Contact__c);
            jg.writeEndObject();
        }
        jg.writeEndArray();

        jg.writeFieldName('vehicles');
        jg.writeStartArray();
        for ( Vehicle__c vehicle: vehicles) {
            jg.writeStartObject();
            jg.writeStringField('Id', (String)vehicle.Id);
            jg.writeStringField('Name', (String)vehicle.Name);
            jg.writeStringField('Model_Year__c', (String)vehicle.Model_Year__c);
            jg.writeStringField('Model_Make__c', (String)vehicle.Model_Make__c);
            jg.writeStringField('Model__c', (String)vehicle.Model__c);
            jg.writeStringField('VIN__c', (String)vehicle.VIN__c);
            jg.writeEndObject();
        }
        jg.writeEndArray();

        jg.writeFieldName('coverage');
        jg.writeStartArray();
        for ( Coverage__c coverage: coverages) {
            jg.writeStartObject();
            jg.writeStringField('Id', (String)coverage.Id);
            jg.writeStringField('Name', (String)coverage.Name);
            jg.writeStringField('CoverageId', (String)coverage.Coverage__c);
            jg.writeStringField('CoverageName', (String)coverage.Name__c);
            jg.writeStringField('Status__c', (String)coverage.Status__c);
            jg.writeEndObject();
        }
        jg.writeEndArray();
		jg.writeEndObject();                                       
       return jg.getAsString();
    }
    
    private static void setTest() {
        System.debug('SaveQuoteToDWH:setting test and Mock');
        Test.setMock(HttpCalloutMock.class, new SaveQuoteToDWHMock());
    }
}