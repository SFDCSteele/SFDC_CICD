public with sharing class ContactSearchController {

  	// the soql without the order and limit
  	private String soql {get;set;}
    public string sContactId{get;set;}
    public String sAccountId{get;set;}
    private boolean isTest=false;
    private boolean duplicateContact = false;
    private boolean foundContact = false;
    private boolean savedContact = false;
    private boolean createdQuote = false;
    private boolean ssnSearch    = false;
    private String ssnSearchValue    = '';
    private boolean birthDateSearch = false;
    private String birthDateSearchValue = '';
    
    public boolean contactDuplicate () {
        return duplicateContact;
    }
    public boolean contactFound () {
        return foundContact;
    }
    public boolean contactSaved() {
        return savedContact;
    }
    public boolean quoteCreated() {
        return createdQuote;
    }

  	// the collection of contacts to display
  	public List<Contact> contacts {get;set;}
    public Contact contact {
        get { 
            	System.debug('inside contact:get-1: sContactId: '+sContactId);
                if ( sContactId != null ) {
                    return [select firstname, lastname, MobilePhone, Email, MailingStreet, MailingCity, MailingState,
                            MailingPostalCode, MailingCountry, PII_SSN__c, PII_Birthdate__c,Drivers_License__c,
                            Account.Id,Id,Name,Phone from contact where Id=:sContactId];
                } else {
	            	System.debug('inside contact:get-2: sContactId: '+sContactId);
                    return this.contact;
                }
            }
        set;
    }
    public Opportunity quote {
        get;set;
    }
    public Driver__c driver {
        get; 
        set;
    }

  // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }

  // the current field to sort by. defaults to last name
  public String sortField {
    get  { if (sortField == null) {sortField = 'lastName'; } return sortField;  }
    set;
  }

  // format the soql for display on the visualforce page
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20'; }
    set;
  }

  // init the controller and display some sample data when the page loads
  public ContactSearchController() {
    contact = new Contact();
    soql = 	'select firstname, lastname, MobilePhone, Email, MailingStreet, MailingCity, MailingState, '+
        	'MailingPostalCode, MailingCountry, PII_SSN__c, PII_Birthdate__c,Drivers_License__c, '+
        	'Account.Id,Id '+
        	'from contact where account.name != null';
    System.debug('inside controller');
    runQuery();
  }

  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // simply toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    // run the query again
    runQuery();
  }

  // runs the actual query
    public void runQuery() {
        
        System.debug('runQuery:running query: '+soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20');
        foundContact = false;
        List<Contact> srchContact = new List<Contact>();
        try {
            contacts = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20');
            System.debug('contacts: '+contacts.size());
            if ( ssnSearch || birthDateSearch) {
                for (Contact c : contacts ) {
                    if ( (ssnSearch && c.PII_SSN__c != null && 
                          c.PII_SSN__c.SubString(0,ssnSearchValue.length()-1) == 
                          ssnSearchValue.substring(0,ssnSearchValue.length()-1)) ||
                         (birthDateSearch && c.PII_Birthdate__c != null && 
                          c.PII_Birthdate__c.substring(0,birthDateSearchValue.length()-1) == 
                          birthDateSearchValue.substring(0,birthDateSearchValue.length()-1))) {
                        srchContact.add(c);
                    }
                }
                contacts = srchContact;
            }
            if ( contacts.size() > 0 ) {
                foundContact = true;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Query Exception: '+
                                                       e.getMessage()));
            System.debug('query exception: '+e.getMessage());
        }
        
    }
  
    public void performAddressValidation() {
        if ( Contact.MailingStreet != null &&
             Contact.MailingCity != null &&
             Contact.MailingState != null &&
             Contact.MailingPostalCode != null  &&
             Contact.MailingCountry != null ) {
                
                System.debug('Attempting validation on Street: '+Contact.MailingStreet+
                             ' City: '+Contact.MailingCity+' State: '+Contact.MailingState+
                             ' Postal Code: '+Contact.MailingPostalCode);
        
            }
    }

  // performs the save and forwards the user to the insurance quote screen
  public PageReference save() {
      savedContact = false;
      createdQuote  = false;
      Account acct = new Account();
      try {
          acct = new Account(
              Name = contact.LastName + ' Administrative Account',
              Type = 'Prospect',
              Phone = contact.Phone,
              BillingStreet = contact.MailingStreet,
              BillingCity = contact.MailingCity,
              BillingState = contact.MailingState,
              BillingPostalCode = contact.MailingPostalCode,
              BillingCountry = contact.MailingCountry
          );
          insert acct;
          contact.AccountId = acct.Id;
          contact.Id=null;
          System.debug('inside contactSearchControlloer:trying to insert contact for accountId: '+acct.Id);
          insert contact;
          savedContact = true;
          
          sContactId = contact.Id;
          sAccountId = contact.AccountId;
          
          executeQuoteCreation();
          
          String refresh = '/apex/InsuranceQuoteCreation?Id='+quote.Id+'&contactId='+sContactId;
          PageReference thisPage = new PageReference(refresh);
          thisPage.setRedirect(true);
          return thisPage;
      } catch (DmlException e) {
            if ( e.getMessage().contains('DUPLICATES_DETECTED')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           'Customer already exists-Unable to create a duplicate: '+
                                                          contact.FirstName+' '+contact.LastName));
                duplicateContact=true;
            } else {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                         'Unable to add contact: '+e.getMessage()));
              savedContact = false;
            }
          if ( acct.Id != null ) {
              delete acct;
          }
      }  
      return null;
  }
    
    public void testRunSearch() {
        isTest = true;
        contact.firstname='test';
        contact.lastname='contact';
        contact.MailingStreet='123 main';
        contact.MailingCity='New York';
        contact.MailingState='New York';
        contact.MailingPostalCode='20001';
        contact.MailingCountry='United States';
        contact.SSN__c='123121234';
        contact.BirthDate=System.Date.today();
        contact.Phone='123-123-1234';
        runSearch();
    }
      
  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {

    String firstName = Apexpages.currentPage().getParameters().get('firstname');
    String lastName = Apexpages.currentPage().getParameters().get('lastname');
    String postalCode = Apexpages.currentPage().getParameters().get('postalCode');
    String state = Apexpages.currentPage().getParameters().get('state');
    String birthDate = null;
      try {
          birthDate = Apexpages.currentPage().getParameters().get('birthDate');
              //Date.parse(Apexpages.currentPage().getParameters().get('birthDate'));
      } catch (Exception e) {
          birthDate = null;
      }
    String ssn = Apexpages.currentPage().getParameters().get('ssn');
      if ( isTest ) {
        firstName = contact.FirstName;
        lastName = contact.LastName;
        postalCode = contact.MailingPostalCode;
        state = contact.MailingState;
        birthDate = BirthDate;
        ssn = contact.SSN__c;
      }
    ssnSearch    = false;
    ssnSearchValue  = '';
    birthDateSearch = false;
    birthDateSearchValue = '';
    soql = 	'select firstname, lastname, MobilePhone, Email, MailingStreet, MailingCity, MailingState, '+
        	'MailingPostalCode, MailingCountry, PII_SSN__c, PII_Birthdate__c,Drivers_License__c, '+
        	'Account.Id,Id '+
        	'from contact where account.name != null';
    if (!firstName.equals(''))
      soql += ' and firstname LIKE \''+String.escapeSingleQuotes(firstName)+'%\'';
    if (!lastName.equals(''))
      soql += ' and lastname LIKE \''+String.escapeSingleQuotes(lastName)+'%\'';
    if (!postalCode.equals(''))
      soql += ' and MailingPostalCode LIKE \''+String.escapeSingleQuotes(postalCode)+'%\'';  
    if (!state.equals(''))
      soql += ' and MailingState LIKE \''+String.escapeSingleQuotes(state)+'%\'';  
      if (birthDate.length()>0) {
	      //soql += ' and Birthdate >= '+birthDate;  
          birthDateSearch = true;
          birthDateSearchValue = birthDate;
      }
      if (ssn.length()>0) {
	      //soql += ' and SSN__c LIKE \''+String.escapeSingleQuotes(ssn)+'%\'';  
          ssnSearch = true;
          ssnSearchValue = ssn;
      }

    System.debug('Attempting to run query: '+soql);
    // run the query again
    runQuery();

    return null;
  }
    
    public void executeQuoteCreation () {
        quote = new Opportunity (
            RecordTypeId = '012390000001lOuAAI',
            AccountId = sAccountId,
            Name      = contact.Name + ' Quote',
            Type      = 'New Business',
            StageName = 'Prospecting',
            OwnerId   = Userinfo.getUserId(),
            CloseDate = system.today()
        );
        try {
            insert quote;
            driver = new Driver__c (
                Quote__c 	= quote.Id,
                Contact__c  = sContactId                
            );
            insert driver;
            createdQuote = true;
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Unable to locate customer: '+contact.Id));
        } 
        
    }
    
  public PageReference createQuote() {
      System.debug('######## createQuote:contactId: '+sContactId+
                   ' accountId: '+sAccountId);
      
      executeQuoteCreation();
      
      String refresh = '/apex/InsuranceQuoteCreation?Id='+quote.Id+'&contactId='+sContactId;
      PageReference thisPage = new PageReference(refresh);
      thisPage.setRedirect(true);
      return thisPage;
  }


}