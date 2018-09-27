@isTest
global class GetInsurancePremiumMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        System.debug('GetInsurancePremiumMock:received request: '+request.toString());
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"annual_premium": 1200,"monthly_premium":100}');
        response.setStatusCode(200);
        return response; 
    }
}