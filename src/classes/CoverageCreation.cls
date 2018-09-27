public with sharing class CoverageCreation {
    
    private boolean isTest=false;
    private boolean foundQuote = false;
    private boolean foundCoverage = false;
    
    public boolean quoteFound () {
        return foundQuote;
    }
    public boolean coverageFound () {
        return foundCoverage;
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
    public String quoteId {
        get;
        set;
    }
    public String retURL {
        get;
        set;
    }
    public Coverage__c coverage {
        get { 
                if ( this.coverage == null ) {
                    return new Coverage__c(Quote__c=quote.Id);
                } else {
                    return this.coverage;
                }
	        }
        set;
    }

    // init the controller and get passed in values
	public CoverageCreation(ApexPages.StandardController stdController) {
        if ( ApexPages.currentPage().getParameters().get('quoteId') != null ) {
            initializeCoverage();
        }
	}
    
    public void initializeCoverage() {
        if (!isTest) {
            quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            retURL  = ApexPages.currentPage().getParameters().get('retURL');
        }
        quote = [select Id,Name,OwnerId,Type,StageName,CloseDate,AccountId
                 from Opportunity where Id=:quoteId];
        coverage = new Coverage__c(Quote__c=quote.Id);
	}
    
    public PageReference saveCoverage() {
        try {
	      insert coverage;            
		  foundCoverage = true;            
          String refresh = retURL;
          PageReference thisPage = new PageReference(refresh);
          thisPage.setRedirect(true);
          return thisPage;
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot save Coverage!'));
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