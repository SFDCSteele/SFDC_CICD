@isTest
public class TestDriverCreation {
    public static TestMethod void testTestDriverCreation_QuoteNOTFound() {
	    ApexPages.StandardController stdDriver = new ApexPages.StandardController(new Driver__c());
    	DriverCreation driver = new DriverCreation(stdDriver);
        
        Opportunity quote1 = driver.quote;
        System.debug('Testing Quote Not found!: '+driver.quoteFound());
        System.assertEquals(driver.quoteFound(),false);
    }

    public static TestMethod void testTestDriverCreation_QuoteFound() {
	    ApexPages.StandardController stdDriver = new ApexPages.StandardController(new Driver__c());
    	DriverCreation driver = new DriverCreation(stdDriver);
        
        PageReference newPage = new Pagereference('DriverForm');
        Test.setCurrentPage(newPage);
        System.debug('testTestDriverCreation:current page: '+newPage.getUrl());
        Opportunity quote = new Opportunity(Name='Test Quote 1',Type='New Business',
                                            StageName='Prospecting',CloseDate=System.today());
        insert quote;
        driver.setTest(quote.Id);
        
        quote = driver.quote;
        System.debug('Testing Quote found!: '+driver.quoteFound());
        System.assertEquals(driver.quoteFound(),true);
    }

    
    public static TestMethod void testTestDriverCreation_CreateDriver() {
	    ApexPages.StandardController stdDriver = new ApexPages.StandardController(new Driver__c());
    	DriverCreation driver = new DriverCreation(stdDriver);
        
        Opportunity quote = new Opportunity(Name='Test Quote 2',Type='New Business',
                                            StageName='Prospecting',CloseDate=System.today());
        insert quote;
        driver.setTest(quote.Id);
        PageReference newPage = new Pagereference('DriverForm');
        Test.setCurrentPage(newPage);
    	driver.initializeDriver();
        Contact con = new Contact(FirstName='tom',LastName='driver');
        insert con;
        driver.driver.Quote__c=driver.quoteId;
        driver.driver.Contact__c=con.Id;
        driver.saveDriver();
        
        System.assertEquals(driver.driverFound(), true);
       
    }

    public static TestMethod void testTestDriverCreation_BadQuote() {
	    ApexPages.StandardController stdDriver = new ApexPages.StandardController(new Driver__c());
    	DriverCreation driver = new DriverCreation(stdDriver);
        
        PageReference newPage = new Pagereference('DriverForm');
        Test.setCurrentPage(newPage);
        driver.setTest('12345');
        
        Opportunity quote = driver.quote;
        System.debug('Testing Bad Quote: '+driver.quoteFound());
        System.assertEquals(driver.quoteFound(),false);
    }

}