public with sharing class VehicleCreation {
    
    
    private boolean isTest=false;
    private boolean foundQuote = false;
    private boolean foundVehicle = false;
    
    public boolean quoteFound () {
        return foundQuote;
    }
    public boolean vehicleFound () {
        return foundVehicle;
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
    public Vehicle__c vehicle {
        get { 
                if ( this.vehicle == null ) {
                    return new Vehicle__c(Quote__c=quote.Id);
                } else {
                    return this.vehicle;
                }
	        }
        set;
    }

    // init the controller and get passed in values
	public VehicleCreation(ApexPages.StandardController stdController) {
        if ( ApexPages.currentPage().getParameters().get('quoteId') != null ) {
            initializeVehicle();
        }
	}
    
    public void initializeVehicle() {
        if (!isTest) {
            quoteId = ApexPages.currentPage().getParameters().get('quoteId');
            retURL  = ApexPages.currentPage().getParameters().get('retURL');
        }
        quote = [select Id,Name,OwnerId,Type,StageName,CloseDate,AccountId
                 from Opportunity where Id=:quoteId];
        vehicle = new Vehicle__c(Quote__c=quoteId);
	}
    
    public PageReference saveVehicle() {
        try {
	      insert vehicle;
		  foundVehicle = true;            
          String refresh = retURL;
          PageReference thisPage = new PageReference(refresh);
          thisPage.setRedirect(true);
          return thisPage;
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot save Vehicle!'));
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