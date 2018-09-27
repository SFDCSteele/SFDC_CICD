@isTest
public class TestInsuranceQuoteCreation {
    public static TestMethod void TestInsuranceQuoteCreation_QuoteNOTFound() {
	    ApexPages.StandardController stdquote = new ApexPages.StandardController(new Opportunity());
    	InsuranceQuoteCreation quote = new InsuranceQuoteCreation(stdquote);
        Contact con1 = quote.contact;
        System.debug('0-TestInsuranceQuoteCreation_QuoteNOTFound:reading contact: '+con1);
        Contact con = new Contact(FirstName='tom',LastName='driver'+System.now());
        insert con;
        quote.contactId = con.Id;
        System.debug('1-TestInsuranceQuoteCreation_QuoteNOTFound:set contact: '+quote.contactId);
        quote.quote=null;
        System.debug('2-TestInsuranceQuoteCreation_QuoteNOTFound:set quote: '+quote.quote);
        
        //quote.setTest(null, null);
        //quote.initializeQuote();
        quote.sCoverageId='';
        Opportunity quote1 = quote.quote;
        System.debug('3-TestInsuranceQuoteCreation_QuoteNOTFound:reading quote: '+quote1);
        con1 = quote.contact;
        System.debug('4-TestInsuranceQuoteCreation_QuoteNOTFound:reading contact: '+con1);
        System.debug('Testing Quote Not found!: '+quote.quoteFound());
        System.assertEquals(quote.quoteFound(),false);
    }

    public static TestMethod void TestInsuranceQuoteCreation_QuoteFound() {
	    ApexPages.StandardController stdquote = new ApexPages.StandardController(new Opportunity());
    	InsuranceQuoteCreation quote = new InsuranceQuoteCreation(stdquote);
        
          Account acct = new Account();
          Opportunity quote1 = new Opportunity();
          Contact con = new Contact(firstname='test',lastname='contact'+System.now(),
 									MailingStreet='123 main',MailingCity='New York',MailingState='New York',
                                  	MailingPostalCode='20001',MailingCountry='United States',
	                                SSN__c='123121234',BirthDate=System.Date.today(),
                                 	Phone='123-123-1234');
          try {
              acct = new Account(
                  Name = con.LastName + ' Administrative Account',
                  Type = 'Prospect',
                  Phone = con.Phone,
                  BillingStreet = con.MailingStreet,
                  BillingCity = con.MailingCity,
                  BillingState = con.MailingState,
                  BillingPostalCode = con.MailingPostalCode,
                  BillingCountry = con.MailingCountry
              );
              insert acct;
              //con = new Contact(FirstName='tom',LastName='driver'+System.now(),AccountId=acct.Id);
              con.AccountId=acct.Id;
              insert con;
    
              quote1 = new Opportunity (
                  RecordTypeId = '012390000001lOuAAI',
                  AccountId = con.AccountId,
                  Name      = con.Name + ' Quote '+System.now(),
                  Type      = 'New Business',
                  StageName = 'Prospecting',
                  OwnerId   = Userinfo.getUserId(),
                  CloseDate = system.today()
              );
              insert quote1;
              Driver__c driver = new Driver__c (
                  Quote__c 	= quote1.Id,
                  Contact__c  = con.Id                
              );
              insert driver;
          } catch (DmlException e) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                         'Unable to contact/quote: '+e.getMessage()));
          } 
        quote.setTest(quote1.Id, con.Id);
              
        quote.initializeQuote();
        
        Opportunity quote2 = quote.quote;
        System.debug('10-TestInsuranceQuoteCreation_QuoteFound:reading quote: '+quote2);
        Contact con1 = quote.contact;
        System.debug('11-TestInsuranceQuoteCreation_QuoteNOTFound:reading contact: '+con1);
        System.debug('12-Testing Quote found!: '+quote.quoteFound());
        quote.save();

        System.assertEquals(quote.quoteFound(),true);
    }
    
    public static TestMethod void TestInsuranceQuoteCreation_CoverageMaster() {
	    ApexPages.StandardController stdquote = new ApexPages.StandardController(new Opportunity());
    	InsuranceQuoteCreation quote = new InsuranceQuoteCreation(stdquote);
        Contact con = new Contact(FirstName='tom',LastName='driver'+System.now(),
                                  MailingCountry='United States',MailingState='South Carolina');
        insert con;
        quote.contact=con;
        System.debug('20-TestInsuranceQuoteCreation_CoverageMaster:reading contact: '+con);
              Coverage_Master__c cm = new Coverage_Master__c(Name='South Carolina 1',
                                                             Bodily_injury_Individual__c=100,
                                                             Bodily_injury_Maximum__c=100,
                                                             Collision__c=100,
                                                             Comprehensive__c=100,
                                                             Coverage_State__c='South Carolina',
                                                             Individual_Limit__c=100,
                                                             Maximum_Limit__c=100,
                                                             Medical_Payments__c=100,
                                                             Property_Damage__c=100,
                                                             Road_Service__c=100,
                                                             UM_UIM_Bodily_Injury_Individual__c=100,
                                                             UM_UIM_Bodily_Injury_Maximum__c=100,
                                                             UM_UIM_Property_Damage__c=100,
                                                             Vehicle_Expenses_Coll__c=100,
                                                             Vehicle_Expenses_Comp__c=100);
              insert cm;
        
        List<Coverage_Master__c> cms = quote.coverageMaster;
        System.debug('21-TestInsuranceQuoteCreation_CoverageMaster:coverageMaster: '+cms);
        System.debug('22-TestInsuranceQuoteCreation_CoverageMaster:coverageMaster size: '+cms.size());
        
        System.assert(cms.size()>0,'Coverage master records found!');
    }

    public static TestMethod void TestInsuranceQuoteCreation_GetPremiums() {
	    ApexPages.StandardController stdquote = new ApexPages.StandardController(new Opportunity());
    	InsuranceQuoteCreation quote = new InsuranceQuoteCreation(stdquote);
        
		//Setup data for the quote to be passed
          Account acct = new Account();
          Opportunity quote1 = new Opportunity();
          Coverage__c cov = new Coverage__c ();
          Driver__c driver = new Driver__c ();
          Vehicle__c veh = new Vehicle__c ();
          Contact con = new Contact(firstname='test',lastname='contact'+System.now(),
 									MailingStreet='123 main',MailingCity='New York',MailingState='New York',
                                  	MailingPostalCode='20001',MailingCountry='United States',
	                                SSN__c='123121234',BirthDate=System.Date.today(),
                                 	Phone='123-123-1234');
          try {
              acct = new Account(
                  Name = con.LastName + ' Administrative Account',
                  Type = 'Prospect',
                  Phone = con.Phone,
                  BillingStreet = con.MailingStreet,
                  BillingCity = con.MailingCity,
                  BillingState = con.MailingState,
                  BillingPostalCode = con.MailingPostalCode,
                  BillingCountry = con.MailingCountry
              );
              insert acct;
              con = new Contact(FirstName='tom',LastName='driver'+System.now(),AccountId=acct.Id,
                               Drivers_License__c='12345');
              insert con;
    
              quote1 = new Opportunity (
                  RecordTypeId = '012390000001lOuAAI',
                  AccountId = con.AccountId,
                  Name      = con.Name + ' Quote '+System.now(),
                  Type      = 'New Business',
                  StageName = 'Prospecting',
                  OwnerId   = Userinfo.getUserId(),
                  CloseDate = system.today()
              );
              insert quote1;
              driver = new Driver__c (
                  Quote__c 	= quote1.Id,
                  Contact__c  = con.Id                
              );
              insert driver;
              veh = new Vehicle__c (Quote__c=quote1.Id, 
                                               Model_Make__c='modelMake',
                                               Model_Year__c='2017',
                                               Model__c='testModel',
                                               VIN__c='testVIN');
              insert veh;
              Coverage_Master__c cm = new Coverage_Master__c(Name='South Carolina 1',
                                                             Bodily_injury_Individual__c=100,
                                                             Bodily_injury_Maximum__c=100,
                                                             Collision__c=100,
                                                             Comprehensive__c=100,
                                                             Coverage_State__c='South Carolina',
                                                             Individual_Limit__c=100,
                                                             Maximum_Limit__c=100,
                                                             Medical_Payments__c=100,
                                                             Property_Damage__c=100,
                                                             Road_Service__c=100,
                                                             UM_UIM_Bodily_Injury_Individual__c=100,
                                                             UM_UIM_Bodily_Injury_Maximum__c=100,
                                                             UM_UIM_Property_Damage__c=100,
                                                             Vehicle_Expenses_Coll__c=100,
                                                             Vehicle_Expenses_Comp__c=100);
              insert cm;
              cov = new Coverage__c (Coverage__c=cm.Id,
                                                 Quote__c=quote1.Id,
                                                 Status__c='Active');
              insert cov;
          } catch (DmlException e) {
              System.debug('TestGetInsurancePremium: Unable to contact/quote: '+e.getMessage());
          } 
        Test.startTest();
        quote.setTest(quote1.Id, con.Id);
              
        quote.initializeQuote();
        
        Opportunity quote2 = quote.quote;
        System.debug('30-TestInsuranceQuoteCreation_GetPremiums:reading quote: '+quote2);
        Contact con1 = quote.contact;
        System.debug('31-TestInsuranceQuoteCreation_GetPremiums:reading contact: '+con1);
        System.debug('32-Testing Quote found!: '+quote.quoteFound());
        quote.getPremiums();
        Test.stopTest();

        System.assertEquals(quote.premiumFound(),true);
        delete cov;
        driver.Status__c = 'Inactive';
        update driver;
        delete driver;
        veh.VIN__c='9999';
        update veh;
        delete veh;
    }

    public static TestMethod void TestInsuranceQuoteCreation_AddCoverage() {
	    ApexPages.StandardController stdquote = new ApexPages.StandardController(new Opportunity());
    	InsuranceQuoteCreation quote = new InsuranceQuoteCreation(stdquote);
        
		//Setup data for the quote to be passed
        Account acct = new Account();
        Opportunity quote1 = new Opportunity();
        Coverage_Master__c cm = new Coverage_Master__c();
        Contact con = new Contact(firstname='test',lastname='contact'+System.now(),
                                  MailingStreet='123 main',MailingCity='New York',MailingState='New York',
                                  MailingPostalCode='20001',MailingCountry='United States',
                                  SSN__c='123121234',BirthDate=System.Date.today(),
                                  Phone='123-123-1234');
          try {
              acct = new Account(
                  Name = con.LastName + ' Administrative Account',
                  Type = 'Prospect',
                  Phone = con.Phone,
                  BillingStreet = con.MailingStreet,
                  BillingCity = con.MailingCity,
                  BillingState = con.MailingState,
                  BillingPostalCode = con.MailingPostalCode,
                  BillingCountry = con.MailingCountry
              );
              insert acct;
              con = new Contact(FirstName='tom',LastName='driver'+System.now(),AccountId=acct.Id,
                               Drivers_License__c='12345');
              insert con;
    
              quote1 = new Opportunity (
                  RecordTypeId = '012390000001lOuAAI',
                  AccountId = con.AccountId,
                  Name      = con.Name + ' Quote '+System.now(),
                  Type      = 'New Business',
                  StageName = 'Prospecting',
                  OwnerId   = Userinfo.getUserId(),
                  CloseDate = system.today()
              );
              insert quote1;
              Driver__c driver = new Driver__c (
                  Quote__c 	= quote1.Id,
                  Contact__c  = con.Id                
              );
              insert driver;
              Vehicle__c veh = new Vehicle__c (Quote__c=quote1.Id, 
                                               Model_Make__c='modelMake',
                                               Model_Year__c='2017',
                                               Model__c='testModel',
                                               VIN__c='testVIN');
              insert veh;
              cm = new Coverage_Master__c(Name='South_Carolina_1',
                                                             Bodily_injury_Individual__c=100,
                                                             Bodily_injury_Maximum__c=100,
                                                             Collision__c=100,
                                                             Comprehensive__c=100,
                                                             Coverage_State__c='South Carolina',
                                                             Individual_Limit__c=100,
                                                             Maximum_Limit__c=100,
                                                             Medical_Payments__c=100,
                                                             Property_Damage__c=100,
                                                             Road_Service__c=100,
                                                             UM_UIM_Bodily_Injury_Individual__c=100,
                                                             UM_UIM_Bodily_Injury_Maximum__c=100,
                                                             UM_UIM_Property_Damage__c=100,
                                                             Vehicle_Expenses_Coll__c=100,
                                                             Vehicle_Expenses_Comp__c=100);
              insert cm;
              Coverage__c cov = new Coverage__c (Coverage__c=cm.Id,
                                                 Quote__c=quote1.Id,
                                                 Status__c='Active');
              insert cov;
              cm = new Coverage_Master__c(Name='South_Carolina_2',
                                                             Bodily_injury_Individual__c=100,
                                                             Bodily_injury_Maximum__c=100,
                                                             Collision__c=100,
                                                             Comprehensive__c=100,
                                                             Coverage_State__c='South Carolina',
                                                             Individual_Limit__c=100,
                                                             Maximum_Limit__c=100,
                                                             Medical_Payments__c=100,
                                                             Property_Damage__c=100,
                                                             Road_Service__c=100,
                                                             UM_UIM_Bodily_Injury_Individual__c=100,
                                                             UM_UIM_Bodily_Injury_Maximum__c=100,
                                                             UM_UIM_Property_Damage__c=100,
                                                             Vehicle_Expenses_Coll__c=100,
                                                             Vehicle_Expenses_Comp__c=100);
              insert cm;
              cov = new Coverage__c (Coverage__c=cm.Id,
                                                 Quote__c=quote1.Id,
                                                 Status__c='Active');
              insert cov;
          } catch (DmlException e) {
              System.debug('TestInsuranceQuoteCreation_AddCoverage: Unable to contact/quote: '+e.getMessage());
          } 
        Test.startTest();
        quote.setTest(quote1.Id, con.Id);
              
        quote.initializeQuote();
        quote.sCoverageId=cm.Id;
        quote.sQuoteId=quote1.Id;
        
        System.debug('42-Testing Quote found!: '+quote.quoteFound());
        quote.addCoverage();
        Test.stopTest();

        List<Coverage__c> cov = [select Id from Coverage__c where Coverage__c=:cm.Id AND
                                                            Quote__c=:quote1.Id AND
                          									Status__c='Active'];
        System.assert(cov.size()>0,'Coverage records found!');
    }

    public static TestMethod void TestInsuranceQuoteCreation_SaveToDWH() {
	    ApexPages.StandardController stdquote = new ApexPages.StandardController(new Opportunity());
    	InsuranceQuoteCreation quote = new InsuranceQuoteCreation(stdquote);
        
		//Setup data for the quote to be passed
          Account acct = new Account();
          Opportunity quote1 = new Opportunity();
          Contact con = new Contact(firstname='test',lastname='contact'+System.now(),
 									MailingStreet='123 main',MailingCity='New York',MailingState='New York',
                                  	MailingPostalCode='20001',MailingCountry='United States',
	                                SSN__c='123121234',BirthDate=System.Date.today(),
                                 	Phone='123-123-1234');
          try {
              acct = new Account(
                  Name = con.LastName + ' Administrative Account',
                  Type = 'Prospect',
                  Phone = con.Phone,
                  BillingStreet = con.MailingStreet,
                  BillingCity = con.MailingCity,
                  BillingState = con.MailingState,
                  BillingPostalCode = con.MailingPostalCode,
                  BillingCountry = con.MailingCountry
              );
              insert acct;
              con = new Contact(FirstName='tom',LastName='driver'+System.now(),AccountId=acct.Id,
                               Drivers_License__c='12345');
              insert con;
    
              quote1 = new Opportunity (
                  RecordTypeId = '012390000001lOuAAI',
                  AccountId = con.AccountId,
                  Name      = 'TEST: ' + con.Name + ' Quote '+System.now(),
                  Type      = 'New Business',
                  StageName = 'Prospecting',
                  OwnerId   = Userinfo.getUserId(),
                  CloseDate = system.today()
              );
              insert quote1;
              Driver__c driver = new Driver__c (
                  Quote__c 	= quote1.Id,
                  Contact__c  = con.Id                
              );
              insert driver;
              Vehicle__c veh = new Vehicle__c (Quote__c=quote1.Id, 
                                               Model_Make__c='modelMake',
                                               Model_Year__c='2017',
                                               Model__c='testModel',
                                               VIN__c='testVIN');
              insert veh;
              Coverage_Master__c cm = new Coverage_Master__c(Name='South_Carolina_1',
                                                             Bodily_injury_Individual__c=100,
                                                             Bodily_injury_Maximum__c=100,
                                                             Collision__c=100,
                                                             Comprehensive__c=100,
                                                             Coverage_State__c='South Carolina',
                                                             Individual_Limit__c=100,
                                                             Maximum_Limit__c=100,
                                                             Medical_Payments__c=100,
                                                             Property_Damage__c=100,
                                                             Road_Service__c=100,
                                                             UM_UIM_Bodily_Injury_Individual__c=100,
                                                             UM_UIM_Bodily_Injury_Maximum__c=100,
                                                             UM_UIM_Property_Damage__c=100,
                                                             Vehicle_Expenses_Coll__c=100,
                                                             Vehicle_Expenses_Comp__c=100);
              insert cm;
              Coverage__c cov = new Coverage__c (Coverage__c=cm.Id,
                                                 Quote__c=quote1.Id,
                                                 Status__c='Active');
              insert cov;
          } catch (DmlException e) {
              System.debug('TestInsuranceQuoteCreation_SaveToDWH: Unable to contact/quote: '+e.getMessage());
          } 
        Test.startTest();
        quote.setTest(quote1.Id, con.Id);
              
        quote.initializeQuote();
        
        System.debug('52-Testing Quote found!: '+quote.quoteFound());
        quote.quote.StageName='Closed Won';
        update quote.quote;
        Test.stopTest();

        List<Opportunity> quotes = [select Id from Opportunity where Id=:quote.sQuoteId and StageName='Closed Won'];
        System.assert(quotes.size()>0,'Quote found!');
    }
    
}