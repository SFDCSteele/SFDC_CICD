public with sharing class USPS_Address_Comp_Controller {

	// address coming in from component attrs
	public USPSAddress Address2Check {get; set;}

	// address coming back from USPS API call
	public USPSAddress AddressFromUSPS {get; set;}		
	
	// this is used to determine when an address changes
	public USPSAddress PreviousAddress {get; set;}

	// this is the object we are going to update
	public Contact CurrentContact {get; set;}	
	
	// should the panel be rendered?
	public boolean DisplayPopUp {get; set;}
	
	// did the user dismiss the panel?
	public boolean Dismissed {get; set;}
		
	//when deciding if the address is bad (and needs review), should we
	// compare just the first 5 digits (set 2 false) of the zip or all 9 (set to true)?
	public boolean CompareFullZip {get; set;}
		
	public string USPS_USERID {
		get { return USPS_USERID; }
		set {
						
			if (value != '') {
				// only run this once a non blank ID is set . . . 
				
				USPS_USERID = value;
				
				// 09/17/2012 - Salesforce doesn't have an action method for componenets
				// that gets called after the constructor and assign 2 like on pages
				// so we use this setter to call our validation method instead.

				ValidateAddress();
				
			} // value != ''
		} // end setter
	} // USPS_USERID 
	
	public USPS_Address_Comp_Controller() {
		
		Address2Check = new USPSAddress();
		AddressFromUSPS = new USPSAddress();
		PreviousAddress = new USPSAddress();
		
		DisplayPopUp = false;
		CompareFullZip = false;
		Dismissed = false;
		
	} // constructor
	
	public boolean DidTheAddressChange() {
		// this method will look at Address2Check and compare it to AddressFromUSPS
		// to see if the user changed the address and if so tell the caller we need
		// to re-verify.
		
		// this ONLY works if called before any attempt to re-verify the address
				
		boolean ReturnValue = false;

		// this is very similar to AddressesAreDifferent except that the  full zip check is not optional

		// on the first run this will be empty so don't count that run . . . 
		if (PreviousAddress.hasData() == true) {
						
			if (Address2Check.Address2 != PreviousAddress.Address2) {			
				ReturnValue = true;
			} else if (Address2Check.City != PreviousAddress.City) {
				ReturnValue = true;
			} else if (Address2Check.State != PreviousAddress.State) {
				ReturnValue = true;
			} else if (Address2Check.getZip() != PreviousAddress.getZip()) {
				ReturnValue = true;
			} // Address2Check.Address1 != PreviousAddress.Address1
		} else {
			// if the previous address is blank, we are on the first call and need to validate
			ReturnValue = true;
		} // PreviousAddress.hasData() == true;
								
		return ReturnValue;

	} //DidTheAddressChange
	
	public boolean AddressesAreDifferent(boolean CheckZipPlus4) {
		
		// this method compares the addresses to see if USPS made any corrections
		
		// since this method is also called by the DidTheAddressChange() wrapper method
		// becareful when updating this method . . . .
			
		boolean ReturnValue = false;
		
		if (Address2Check.Address1 != AddressFromUSPS.Address1) {
			ReturnValue = true;
		} else if (Address2Check.Address2 != AddressFromUSPS.Address2) {
			ReturnValue = true;
		} else if (Address2Check.City != AddressFromUSPS.City) {
			ReturnValue = true;
		} else if (Address2Check.State != AddressFromUSPS.State) {
			ReturnValue = true;
		} else if (CheckZipPlus4 == true) {
			if (Address2Check.getZip() != AddressFromUSPS.getZip()) {
				ReturnValue = true;
			} // full zip compare
		} else if (CheckZipPlus4 == false) {
			if (Address2Check.Zip5 != AddressFromUSPS.Zip5) {
				ReturnValue = true;		
			} // compare zip 5's
		} // Address2Check.Address1 != AddressFromUSPS.Address1
		
		return ReturnValue;
		
	} // AddressesAreDifferent
	
	public void UpdateAddress2Check() {
		Address2Check.Address2 = CurrentContact.MailingStreet;
		Address2Check.City = CurrentContact.MailingCity;
		Address2Check.State = CurrentContact.MailingState;
		Address2Check.Zip5 = CurrentContact.MailingPostalCode;		
	} // UpdateAddress2Check
	
	public void UpdatePreviousAddress() {		
		PreviousAddress.Address2 = Address2Check.Address2;
		PreviousAddress.City = Address2Check.City;
		PreviousAddress.State = Address2Check.State; 
		PreviousAddress.Zip5 = Address2Check.Zip5; 
	} // UpdatePreviousAddress
	
	public void ValidateAddress() {

        if ( Address2Check != null && CurrentContact != null ) {
            // set the var to catch any changes for future runs
            UpdatePreviousAddress();
            
            // update the object from the main controller's data
            UpdateAddress2Check();
                                    
            if (Address2Check.CanCheckAddress() == true) {	
            
                if (DidTheAddressChange()==true) {
                    
                    // use the USPS API class do validate the address				
                    AddressFromUSPS = USPS.CheckAddress(Address2Check, USPS_USERID);
                
                    DisplayPopUp = AddressesAreDifferent(CompareFullZip);
                                    
                } else {
                    system.debug('Address Didn\'t Change!');
                } // DidTheAddressChange()==true || FirstRun == true
                            
            } // Address2Check.HasData() == true	 
        }
	} // validate address
	
	public void UseCorrectedAddress() {
		// cross the addresses going out to the caller - due to USPS address2 being the 'main' street address
		// this is why we must copy field by field - instead of just doing a one line copy
 		
		CurrentContact.MailingStreet = AddressFromUSPS.Address2;
		CurrentContact.MailingCity = AddressFromUSPS.City;
		CurrentContact.MailingState = AddressFromUSPS.State;
		CurrentContact.MailingPostalCode = AddressFromUSPS.getZip();
		
		DisplayPopUp = false;		
	} // UseCorrectedAddress
	
	public void Dismiss() {
		DisplayPopUp = false;
	} // Dismiss
	
	
} // end USPS_Address_Comp_Controller class