@isTest
public class TestVehicleCreation {
    public static TestMethod void testTestVehicleCreation_QuoteNOTFound() {
	    ApexPages.StandardController stdVehicle = new ApexPages.StandardController(new Vehicle__c());
    	VehicleCreation vehicle = new VehicleCreation(stdVehicle);
        
        Opportunity quote1 = vehicle.quote;
        System.debug('Testing Quote Not found!: '+vehicle.quoteFound());
        System.assertEquals(vehicle.quoteFound(),false);
    }

    public static TestMethod void testTestVehicleCreation_QuoteFound() {
	    ApexPages.StandardController stdVehicle = new ApexPages.StandardController(new Vehicle__c());
    	VehicleCreation vehicle = new VehicleCreation(stdVehicle);
        
        PageReference newPage = new Pagereference('VehicleForm');
        Test.setCurrentPage(newPage);
        System.debug('testTestVehicleCreation:current page: '+newPage.getUrl());
        Opportunity quote = new Opportunity(Name='Test Quote 1',Type='New Business',
                                            StageName='Prospecting',CloseDate=System.today());
        insert quote;
        vehicle.setTest(quote.Id);
        
        quote = vehicle.quote;
        System.debug('Testing Quote found!: '+vehicle.quoteFound());
        System.assertEquals(vehicle.quoteFound(),true);
    }

    
    public static TestMethod void testTestVehicleCreation_CreateVehicle() {
	    ApexPages.StandardController stdVehicle = new ApexPages.StandardController(new Vehicle__c());
    	VehicleCreation vehicle = new VehicleCreation(stdVehicle);
        
        Opportunity quote = new Opportunity(Name='Test Quote 2',Type='New Business',
                                            StageName='Prospecting',CloseDate=System.today());
        insert quote;
        vehicle.setTest(quote.Id);
        PageReference newPage = new Pagereference('VehicleForm');
        Test.setCurrentPage(newPage);
    	vehicle.initializeVehicle();
        Contact con = new Contact(FirstName='tom',LastName='vehicle');
        insert con;
        vehicle.vehicle.Quote__c=vehicle.quoteId;
        vehicle.saveVehicle();
        
        System.assertEquals(vehicle.vehicleFound(), true);
       
    }

    public static TestMethod void testTestVehicleCreation_BadQuote() {
	    ApexPages.StandardController stdVehicle = new ApexPages.StandardController(new Vehicle__c());
    	VehicleCreation vehicle = new VehicleCreation(stdVehicle);
        
        PageReference newPage = new Pagereference('VehicleForm');
        Test.setCurrentPage(newPage);
        vehicle.setTest('12345');
        
        Opportunity quote = vehicle.quote;
        System.debug('Testing Bad Quote: '+vehicle.quoteFound());
        System.assertEquals(vehicle.quoteFound(),false);
    }

}