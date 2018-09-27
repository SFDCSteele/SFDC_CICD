@isTest
public class TestCoverageCreation {
    public static TestMethod void testTestCoverageCreation_QuoteNOTFound() {
	    ApexPages.StandardController stdCoverage = new ApexPages.StandardController(new Coverage__c());
    	CoverageCreation coverage = new CoverageCreation(stdCoverage);
        
        Opportunity quote1 = coverage.quote;
        System.debug('Testing Quote Not found!: '+coverage.quoteFound());
        System.assertEquals(coverage.quoteFound(),false);
    }

    public static TestMethod void testTestCoverageCreation_QuoteFound() {
	    ApexPages.StandardController stdCoverage = new ApexPages.StandardController(new Coverage__c());
    	CoverageCreation coverage = new CoverageCreation(stdCoverage);
        
        PageReference newPage = new Pagereference('CoverageForm');
        Test.setCurrentPage(newPage);
        System.debug('testTestCoverageCreation:current page: '+newPage.getUrl());
        Opportunity quote = new Opportunity(Name='Test Quote 1',Type='New Business',
                                            StageName='Prospecting',CloseDate=System.today());
        insert quote;
        coverage.setTest(quote.Id);
        
        quote = coverage.quote;
        System.debug('Testing Quote found!: '+coverage.quoteFound());
        System.assertEquals(coverage.quoteFound(),true);
    }

    
    public static TestMethod void testTestCoverageCreation_CreateCoverage() {
	    ApexPages.StandardController stdCoverage = new ApexPages.StandardController(new Coverage__c());
    	CoverageCreation coverage = new CoverageCreation(stdCoverage);
        
        Opportunity quote = new Opportunity(Name='Test Quote 2',Type='New Business',
                                            StageName='Prospecting',CloseDate=System.today());
        insert quote;
        coverage.setTest(quote.Id);
        PageReference newPage = new Pagereference('CoverageForm');
        Test.setCurrentPage(newPage);
    	coverage.initializeCoverage();
        Contact con = new Contact(FirstName='tom',LastName='coverage');
        insert con;
        coverage.coverage.Quote__c=coverage.quoteId;
        coverage.saveCoverage();
        
        System.assertEquals(coverage.coverageFound(), true);
       
    }

    public static TestMethod void testTestCoverageCreation_BadQuote() {
	    ApexPages.StandardController stdCoverage = new ApexPages.StandardController(new Coverage__c());
    	CoverageCreation coverage = new CoverageCreation(stdCoverage);
        
        PageReference newPage = new Pagereference('CoverageForm');
        Test.setCurrentPage(newPage);
        coverage.setTest('12345');
        
        Opportunity quote = coverage.quote;
        System.debug('Testing Bad Quote: '+coverage.quoteFound());
        System.assertEquals(coverage.quoteFound(),false);
    }

}