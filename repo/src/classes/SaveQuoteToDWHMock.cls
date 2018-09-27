@isTest
global class SaveQuoteToDWHMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        System.debug('SaveQuoteToDWHMock:received request: '+request.toString());
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{"annual_premium": 1200,"monthly_premium":100}');
        response.setStatusCode(201);
        return response; 
    }
}