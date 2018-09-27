@isTest
private class USPSHTTPCallOutTest {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(HttpCalloutMock.class, new USPSHttpCalloutMock());
        // Call the method that invokes a callout
		Test.StartTest();
		
		USPSAddress MyAddress = new USPSAddress();
		
		// will return the default address		
        MyAddress.Address1 = '6406 IVY LN';
        MyAddress.Address2 = 'Apartment 211';
        MyAddress.City = 'Greenbelt';
        MyAddress.State = 'MD';
        MyAddress.Zip5 = '20770';
        MyAddress.Zip4 = '1441';
		USPS.CheckAddress(MyAddress,'Test');
		
		// This should return an error message
		MyAddress = new USPSAddress();
		MyAddress.City = 'ERROR';
		USPS.CheckAddress(MyAddress,'Test');

		// and this shoudl return a blank address 
		// so we can test the generic error message
		MyAddress = new USPSAddress();
		MyAddress.City = 'NULL';
		USPS.CheckAddress(MyAddress,'Test');
		
		Test.StopTest();
	} // TestUSPS
}