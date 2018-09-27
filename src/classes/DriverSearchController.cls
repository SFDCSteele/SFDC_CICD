public with sharing class DriverSearchController {

    //Id id = ApexPages.currentPage().getParameters().get('id');
  	// the soql without the order and limit
  	private String soql {get;set;}
    public string sContactId{get;set;}
    public String sAccountId{get;set;}

  	// the collection of contacts to display
  	public List<Contact> contacts {get;set;}
    public Contact contact {
        get { if ( sContactId != null ) {return [select firstname, lastname, MobilePhone, Email, MailingStreet, MailingCity, MailingState,
        	MailingPostalCode, MailingCountry, PII_SSN__c, PII_Birthdate__c,Drivers_License__c,
        	Account.Id,Id,Name
                                                 from contact where Id=:sContactId]; } else {
                                                     return this.contact;
                                                 }
            }
        set;
    }
    public Opportunity quote {
        get;set;
    }
    /*public Quote quote {
        get;set;
    }*/
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
  public DriverSearchController() {
    contact = new Contact();
    soql = 	'select firstname, lastname, MobilePhone, Email, MailingStreet, MailingCity, MailingState, '+
        	'MailingPostalCode, MailingCountry, PII_SSN__c, PII_Birthdate__c,Drivers_License__c, '+
        	'Account.Id,Id '+
        	'from contact where account.name != null';
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

    try {
      contacts = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    }

  }

  // runs the search with parameters passed via Javascript
  public PageReference save() {
          /*      contact.FirstName
                contact.LastName
                contact.Phone
                contact.MobilePhone
                contact.Email
                contact.MailingStreet
                contact.MailingCity
                contact.MailingState
                contact.MailingPostalCode
                contact.MailingCountry
                contact.SSN__c
                contact.Birthdate
                contact.Drivers_License__c  */
        //System.debug('Contact name: '+contact.FirstName);
        //Contact newCont = contact;
        try {
            Account acct = new Account(
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
           insert contact;
        } catch (DmlException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                     'Unable to add contact: '+contact.Name));
        }  
        return null;
      }
      
  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {

    String firstName = Apexpages.currentPage().getParameters().get('firstname');
    String lastName = Apexpages.currentPage().getParameters().get('lastname');
    String postalCode = Apexpages.currentPage().getParameters().get('postalCode');
    String state = Apexpages.currentPage().getParameters().get('state');
    String birthDate = Apexpages.currentPage().getParameters().get('birthDate');
    String ssn = Apexpages.currentPage().getParameters().get('ssn');

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
    if (!birthDate.equals(''))
      soql += ' and Birthdate LIKE \''+String.escapeSingleQuotes(birthDate)+'%\'';  
    if (!ssn.equals(''))
      soql += ' and SSN__c LIKE \''+String.escapeSingleQuotes(ssn)+'%\'';  

    // run the query again
    runQuery();

    return null;
  }
    
  public PageReference createDriver() {
      System.debug('Inside createDriver');
		//sContactId = ApexPages.CurrentPage().getParameters().get('contactId');
		//sAccountId = ApexPages.CurrentPage().getParameters().get('accountId');
		System.debug('######## createQuote:contactId: '+sContactId+
                    ' accountId: '+sAccountId);
	      quote = new Opportunity (
          AccountId = sAccountId,
          //Contact   = sContactId,
          Name      = contact.Name + ' Quote',
          //ExpirationDate = system.today()
          Type      = 'New Business',
          StageName = 'Prospecting',
          OwnerId   = Userinfo.getUserId(),
          CloseDate = system.today()
      );
      System.debug('User Id: '+quote.OwnerId);
      insert quote;
      System.debug('Trying to insert driver: quoteId: '+quote.Id+' contactId: '+sContactId);
      driver = new Driver__c (
          Quote__c 	= quote.Id,
          Contact__c  = sContactId                
      );
      insert driver;
      System.debug('quote Id: '+quote.Id);
      
      String refresh = '/apex/InsuranceQuoteCreation?Id='+quote.Id+'&contactId='+sContactId;
      //refresh = '/'+quote.id;
      System.debug('Trying refresh: page: '+refresh);
      PageReference thisPage = new PageReference(refresh);
      thisPage.setRedirect(true);
      //String nextPage = '/apex/InsuranceQuoteCreation?contactId={!contact.Id}&accountId={!contact.Account.Id}';
      return thisPage;
  }
}