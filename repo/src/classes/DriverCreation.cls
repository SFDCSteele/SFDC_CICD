public with sharing class DriverCreation {

    
    private boolean isTest=false;
    private boolean foundQuote = false;
    private boolean foundDriver = false;
    
    public boolean quoteFound () {
        return foundQuote;
    }
    public boolean driverFound () {
        return foundDriver;
    }
    public Opportunity quote {
        get {
                if(quoteId != null) {
                    try { 
                        Opportunity retQuote =  [select Id,Name,OwnerId,Type,StageName,CloseDate,AccountId
                                from Opportunity where Id=:quoteId];
                        foundQuote = true;
                        return retQuote;
                    } catch (QueryException q) {
	                    System.debug('Quote--error finding quote: '+quoteId+' error: '+q.getMessage());
                        foundQuote=false;
                    }
                }
            return new Opportunity();
        } 
        set;
    }
    public Driver__c driver {
        get { 
                if ( this.driver == null ) {
                    return new Driver__c(Quote__c=quote.Id);
                } else {
                    return this.driver;
                }
	        }
        set;
    }
    public String quoteId {
        get;
        set;
    }
    public String retURL {
        get;
        set;
    }

    // init the controller and get passed in values
	public DriverCreation(ApexPages.StandardController stdController) {
        if ( ApexPages.currentPage().getParameters().get('quoteId') != null ) {
            initializeDriver();
        }
	}
    
    public void initializeDriver() {
        if (!isTest) {
            quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            retURL  = ApexPages.currentPage().getParameters().get('retURL');
        }
        quote = [select Id,Name,OwnerId,Type,StageName,CloseDate,AccountId
                 from Opportunity where Id=:quoteId];
        driver = new Driver__c(Quote__c=quoteId);
    }
    
    public PageReference saveDriver() {        
        try {
	      insert driver;   
          foundDriver = true;
          String refresh = retURL;
          PageReference thisPage = new PageReference(refresh);
          thisPage.setRedirect(true);
          return thisPage;
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot save Driver!'));
        }
        return null;
    }
    
    public void setTest (String pQuoteId) {
        isTest = true;
        quoteId = pQuoteId;
        retURL  = '/apex/InsuranceQuoteCreation?Id='+quoteId;
        System.debug('setTest:isTest: '+isTest+' quoteId: '+quoteId);
    }

}