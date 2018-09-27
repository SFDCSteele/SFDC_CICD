public with sharing class USPSTest {

	// When this is set, it will trigger the lookup on the address to the USPS
	public string USPSUserIDCode {get; set;}

	public final Contact CurrentContact {get; set;}
	
	public USPSTest(ApexPages.StandardController stdController) {
		
		USPSUserIDCode = '185SALES5966';
		this.CurrentContact = (Contact)stdController.getRecord();
		
		CurrentContact.MailingStreet = '6406 Ivy Lane';
		CurrentContact.MailingCity = 'Greenbelt';
		CurrentContact.MailingState = 'Md';
		CurrentContact.MailingPostalCode = '20770';		
		
	} // constructor
	public USPSTest(ContactSearchController stdController) {
		
		USPSUserIDCode = '185SALES5966';
		this.CurrentContact = (Contact)stdController.Contact;
		
		/*CurrentContact.MailingStreet = '6406 Ivy Lane';
		CurrentContact.MailingCity = 'Greenbelt';
		CurrentContact.MailingState = 'Md';
		CurrentContact.MailingPostalCode = '20770';	*/	
		
	} // constructor
	
	public pagereference validate() {
        
        // if the address validation hasn't been triggered, trigger it here
        if (USPSUserIDCode == '') {

			// Confirm you have an address before setting the code
			// without an address, the component won't actually do anything
			if (CurrentContact.MailingStreet != '' && CurrentContact.MailingStreet != null) {				
				if ((CurrentContact.MailingPostalCode != '') || ((CurrentContact.MailingCity != '') && (CurrentContact.MailingState != '')))  {
			        
			        USPSUserIDCode  = '185SALES5966';
			        
			        return null;			
				} // have city and state OR Zip
								
			} // Address1 != ''
        	
        } // USPSUserIDCode == ''

		// Add any other form validation or save code here
		return null;
		         		
	} // validate
	
} // end class USPSTest