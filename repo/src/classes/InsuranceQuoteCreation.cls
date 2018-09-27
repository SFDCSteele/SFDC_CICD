public with sharing class InsuranceQuoteCreation {

    private boolean isTest=false;
    private boolean foundQuote = false;
    private boolean foundDriver = false;
    private boolean foundPremium = false;
    
    public boolean quoteFound () {
        return foundQuote;
    }
    /*public boolean driverFound () {
        return foundDriver;
    }*/
    public boolean premiumFound () {
        return foundPremium;
    }
  	// the soql without the order and limit
  	private String soql {get;set;}
    //public string sContactId{get;set;}
    public String sQuoteId{get;set;}
    public String sCoverageId{get;set;}
    public Id contactId {get;set;}
    public Id accountId {get;set;}
    //public Contact   newDriverx {get;set;}
    //public Driver__c newDriver {get { return newDriver;}
    //                            set {System.debug('newDriver setter called');}
    //                            }
    
    public Opportunity quote {
        get { 
                if ( quote != null ) {
                      System.debug('Inside quote creation:Contact Id: '+contactId+' Quote Id: '+quote.Id);
                      foundQuote = true;
                      return quote;                
                } else {
                    foundQuote = false;
                    return new Opportunity();
                }
            } 
        set;
    }
    public Contact contact {
        get { 
            if ( contactId != null ) {
                System.debug('processing contact:get--1:contactId: '+contactId);
                return [select firstname, lastname, Name, MobilePhone, Email, MailingStreet, MailingCity, MailingState,
                        MailingPostalCode, MailingCountry, PII_SSN__c, PII_Birthdate__c,Drivers_License__c,
                        Account.Id,Id
                        from contact where Id=:contactId]; 
            } else if ( contact == null && accountId != null ) {
                System.debug('processing contact:get--2:accountId: '+accountId);
                return [select firstname, lastname, Name, MobilePhone, Email, MailingStreet, MailingCity, MailingState,
                        MailingPostalCode, MailingCountry, PII_SSN__c, PII_Birthdate__c,Drivers_License__c,
                        Account.Id,Id
                        from contact where Account.Id=:accountId]; 
            } else {
                return this.contact;
            }
            }
        set;
    }

    /*public Driver__c driver {
        get {
            System.debug('inside Driver getter');
            return new Driver__c();} 
        set { System.debug('inside Driver setter');}
    }*/
    /*public String retURL {
        get;
        set;
    }*/
    /*public Vehicle__c vehicle {
        get { return new Vehicle__c();} 
        set;
    }*/

    /*public List<Driver__c> drivers {
        get { return [select Id,Contact__c,First_Name__c,Last_Name__c,Drivers_License__c FROM Driver__c where Quote__c=:quote.ID ];}
        set;
    }*/
    
    public String retUrl {
        get { 
            String newUrl = '/apex/InsuranceQuoteCreation?Id='+quote.Id+'&contactId='+contactId;
            System.debug('newUrl: '+newUrl);
            return newUrl;
        }
        set;
    }
    public List<Coverage_Master__c> coverageMaster {
        get { 
            System.debug('99-inside coverageMaster:MailingState: '+contact.MailingState+'*');
            List<Coverage_Master__c> cm = [select id,Coverage_State__c,Name,Bodily_injury_Individual__c,
                                           Bodily_injury_Maximum__c,Property_Damage__c,Medical_Payments__c,
                                           UM_UIM_Bodily_Injury_Individual__c,UM_UIM_Bodily_Injury_Maximum__c,
                                           UM_UIM_Property_Damage__c,Comprehensive__c,Collision__c,
                                           Road_Service__c,Vehicle_Expenses_Comp__c,Vehicle_Expenses_Coll__c
                                           from Coverage_Master__c];
            System.debug('coverageMaster rows: '+cm);
            return cm;
            }
        set;
    }
                                           //where Coverage_State__c=:contact.MailingState];

    // init the controller and display some sample data when the page loads
	public InsuranceQuoteCreation(ApexPages.StandardController stdController) {
        if(ApexPages.currentPage().getParameters().get('Id') != null ) {
            initializeQuote();
        }
	}
    
    public void initializeQuote() {
        if (!isTest) {
            System.debug('initializeQuote:Id: '+ApexPages.currentPage().getParameters().get('Id')+
                        ' retURL: '+ApexPages.currentPage().getParameters().get('retURL')+
                        ' contactId: '+ApexPages.currentPage().getParameters().get('contactId')+
                        ' contact: '+contact);
            sQuoteId = ApexPages.currentPage().getParameters().get('Id');
            retUrl  = ApexPages.currentPage().getParameters().get('retURL');
            if ( ApexPages.currentPage().getParameters().get('contactId') != null ) {
                contactId = ApexPages.currentPage().getParameters().get('contactId');
            } else if (contact != null ) {
                contactId = contact.Id;
            }
        }
        foundQuote = false;
        quote = [select Id,Name,OwnerId,Type,StageName,CloseDate,AccountId,Annual_Premium__c,Monthly_Premium__c 
                 from Opportunity where Id=:sQuoteId];
        foundQuote = true;

        accountId = quote.AccountId;
        contactId = contact.Id;


        System.debug('Inside InsuranceQuoteCreation:initializeQuote-2:quoteid: '+quote.Id+
                     ' accountId: '+accountId+
                     ' contactId: '+contactId);
                             
        /*if ( contactId == null || accountId == null ) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                     'Please select a customer in the CustomerSearch screen'));
        }
        try {
            contact = [SELECT Name, FirstName, LastName, Phone, Email FROM Contact WHERE Id = :contactId];
    	} catch (QueryException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                     'Unable to locate customer: '+contact.Id));
        }*/  
    }
    
    public PageReference getPremiums() {
        foundPremium = false;
        System.debug('Inside getPremiums:quoteId: '+quote.Id+' contactId: '+contact.Id);
        try {
            Map<String,Decimal> premiums = new Map<String,Decimal>();
            GetInsurancePremium gip = new GetInsurancePremium();
            premiums = gip.GetInsurancePremium(quote.Id);
            System.debug('returned premiums: '+premiums);
            quote.Annual_Premium__c=premiums.get('annual_premium');
            quote.Monthly_Premium__c = premiums.get('monthly_premium');
            update quote;
            Quote_Audit_History__c qHist = new Quote_Audit_History__c(
                Quote__c=quote.Id,
                Entity__c='Premium',
                Action__c='Premium Requested',
                Details__c='State: ' +contact.MailingState+
                ' Annual Premium: '+quote.Annual_Premium__c+
                ' Monthly Premium: '+quote.Monthly_Premium__c);
            insert qHist;
            foundPremium = true;
        } catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                     'Unable to add coverage to quote'));

        }
        String refresh = '/apex/InsuranceQuoteCreation?Id='+quote.Id+'&contactId='+contact.Id;
        PageReference thisPage = new PageReference(refresh);
        thisPage.setRedirect(true);
        return thisPage;
    }
    
    public PageReference addCoverage() {
        System.debug('Inside addCoverage:quoteId: '+sQuoteId+' coverageId: '+sCoverageId);
        try {
            List<Coverage__c> coveragesIn = [select Id,Status__c from Coverage__c 
                                           where Quote__c=:sQuoteId and Status__c='Active'];
            List<Coverage__c> coveragesOut = new List<Coverage__c>(); 
            for (Coverage__c cov: coveragesIn) {
                cov.Status__c='Inactive';
                coveragesOut.add(cov);
            }
            update coveragesOut;
            Coverage__c coverage = new Coverage__c(Coverage__c = sCoverageId,
                                                  Quote__c = sQuoteId,
                                                  Status__c = 'Active');
            insert coverage;
        } catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                     'Unable to add coverage to quote'));

        }
        String refresh = '/apex/InsuranceQuoteCreation?Id='+quote.Id+'&contactId='+contact.Id;
        PageReference thisPage = new PageReference(refresh);
        thisPage.setRedirect(true);
        return thisPage;
    }

  // runs the search with parameters passed via Javascript
  public PageReference save() {
        try {
            update quote;
        } catch (DmlException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                     'Unable to add quote: '+quote.Name));
        }  
        return null;
      }
    

  // saves the new driver
  /*public PageReference saveDriver() {
        try {
            Driver__c newDriver = new Driver__c(
                Contact__c=driver.Contact__c,
                Quote__c=quote.Id);
            insert newDriver;
            
        } catch (DmlException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                     'Unable to add driver: '+driver.First_Name__c));
        }  
        return null;
      }*/
    
    public void setTest (String pQuoteId, String pContactId) {
        isTest = true;
        sQuoteId = pQuoteId;
        contactId = pContactId;
        soql='';
        retURL = '/apex/InsuranceQuoteCreation?Id='+quote.Id+'&contactId='+contact.Id;
        System.debug('setTest:isTest: '+isTest+' quoteId: '+sQuoteId+'&contactId='+contact.Id);
        Test.setMock(HttpCalloutMock.class, new GetInsurancePremiumMock());
    }

}