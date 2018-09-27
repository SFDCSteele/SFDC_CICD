@isTest
public class Test_USPS_Address_Comp_Controller {
	static testMethod void TestUSPS_Address_Comp_Controller() {
		
		Contact TestContact = new Contact();

		// I am using the standard USPS test request #1 here because
		// it will match the results but any address you pass in
		// during testing will return this test data.
		TestContact.MailingStreet = '6406 IVY LN';
		TestContact.MailingCity = 'GREENBELT';
		TestContact.MailingState = 'MD';
		TestContact.MailingPostalCode = '20770';
		
		Test.StartTest();
		
		USPS_Address_Comp_Controller MyController = new USPS_Address_Comp_Controller();
		
		MyController.CurrentContact = TestContact;
		
		// setting the id makes the call out to validate the address
		// the USPS class has a mock HTML Call out class for use with testing
		// so you can set your USPS ID to any non blank value and get a result		
		MyController.USPS_USERID = 'TEST';
		
		MyController.AddressFromUSPS.getZip();
		
		MyController.UseCorrectedAddress();
		
		TestContact.MailingPostalCode = '';
		// setting the id makes the call out to validate the address
		MyController.USPS_USERID = 'TEST';
		MyController.Dismiss();
		
		// testing for AddressesAreDifferent
		MyController.AddressFromUSPS.Address1 = 'test';
		MyController.AddressesAreDifferent(false);
		
		MyController.AddressFromUSPS.Address1 = MyController.Address2Check.Address1;
		MyController.AddressFromUSPS.Address2 = 'test';
		MyController.AddressesAreDifferent(false);

		MyController.AddressFromUSPS.Address2 = MyController.Address2Check.Address2;
		MyController.AddressFromUSPS.City = 'test';
		MyController.AddressesAreDifferent(false);

		MyController.AddressFromUSPS.City = MyController.Address2Check.City;
		MyController.AddressFromUSPS.State = 'AL';
		MyController.AddressesAreDifferent(false);		

		MyController.AddressFromUSPS.State = MyController.Address2Check.State;
		MyController.AddressFromUSPS.Zip5 = '90210';
		MyController.AddressesAreDifferent(false);		

		MyController.AddressFromUSPS.Zip5 = MyController.Address2Check.Zip5;
		MyController.AddressFromUSPS.Zip4 = '1234';
		MyController.AddressesAreDifferent(false);		
		MyController.AddressesAreDifferent(true);
		// end testing for AddressesAreDifferent
		
		// testing for DidTheAddressChange
		MyController.PreviousAddress.Address2 = 'Test';
		MyController.DidTheAddressChange();

		MyController.PreviousAddress.Address2 = MyController.Address2Check.Address2;
		MyController.PreviousAddress.City = 'Test';
		MyController.DidTheAddressChange();

		MyController.PreviousAddress.City = MyController.Address2Check.City;
		MyController.PreviousAddress.State = 'AL';
		MyController.DidTheAddressChange();
		// end testing for DidTheAddressChange
		
		Test.StopTest();
		
	} // TestUSPS_Address_Comp_Controller

}