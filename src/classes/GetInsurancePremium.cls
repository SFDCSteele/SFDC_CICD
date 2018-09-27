public class GetInsurancePremium {
                
            public GetInsurancePremium() {
            }
            public Map<String,Decimal> GetInsurancePremium(String passedQuoteId) {
                Map<String,Decimal> premiums = new Map<String,Decimal>();
                try {
	                Opportunity quote = [select Id,Name,Type,StageName,CloseDate from Opportunity where Id=:passedQuoteId];
                    List<Driver__c> drivers = [select Id,Name,First_Name__c,Last_Name__c,Drivers_License__c,Contact__c from Driver__c where Quote__c=:passedQuoteId];
                    List<Vehicle__c> vehicles = [select Id,Name,Model_Year__c,Model_Make__c,Model__c,VIN__c from Vehicle__c where Quote__c=:passedQuoteId];
                    List<Coverage__c> coverage = [select Id,name,Coverage__c,Name__c,Status__c from Coverage__c where Quote__c=:passedQuoteId and Status__c='Active'];
                    premiums = sendMessage(coverage[0].Name__c,createJSONString(quote,drivers,vehicles,coverage));
                } catch (DMLException dme) {
                    System.debug('Error extracting premiums for quote: '+passedQuoteId+' error: '+dme.getMessage());
                }
                return premiums;
            }
    
    public Map<String,Decimal> sendMessage (String coverageName, String outMessage) {
        Map<String,Decimal> premiums = new Map<String,Decimal>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://wasrestserver.herokuapp.com/GetCoveragePremium/'+coverageName);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug('GetInsurancePremium:sendMessage:response: '+response.toString());
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Parse JSON response to get all the totalPrice field values.
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                    if(parser.getCurrentName() == 'annual_premium') {
                        parser.nextToken();                        
                        premiums.put('annual_premium',Double.valueOf(parser.getText()));
                    } else if(parser.getCurrentName() == 'monthly_premium') {
                        parser.nextToken();
                        premiums.put('monthly_premium',Double.valueOf(parser.getText()));
                    }
                }
            }
        } else {
            System.debug(response.getBody());
        }
        return premiums;
    }    
    public String createJSONString(Opportunity quote,
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
    
    public void setTest() {
        System.debug('GetInsurancePremium:setting test and Mock');
        Test.setMock(HttpCalloutMock.class, new GetInsurancePremiumMock());
    }
}