@isTest
private class TestGetInsurancePremium {
     @isTest static void testCallout() {
        // Set mock callout class 
        //Test.setMock(HttpCalloutMock.class, new GetInsurancePremiumMock());
        
		//Setup data for the quote to be passed
          Account acct = new Account();
          Opportunity quote = new Opportunity();
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
    
              quote = new Opportunity (
                  RecordTypeId = '012390000001lOuAAI',
                  AccountId = con.AccountId,
                  Name      = con.Name + ' Quote '+System.now(),
                  Type      = 'New Business',
                  StageName = 'Prospecting',
                  OwnerId   = Userinfo.getUserId(),
                  CloseDate = system.today()
              );
              insert quote;
              Driver__c driver = new Driver__c (
                  Quote__c 	= quote.Id,
                  Contact__c  = con.Id                
              );
              insert driver;
              Vehicle__c veh = new Vehicle__c (Quote__c=quote.Id, 
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
              Coverage__c cov = new Coverage__c (Coverage__c=cm.Id,
                                                 Quote__c=quote.Id,
                                                 Status__c='Active');
              insert cov;
          } catch (DmlException e) {
              System.debug('TestGetInsurancePremium: Unable to contact/quote: '+e.getMessage());
          } 

         // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
         Map<String,Decimal> premiums = new Map<String,Decimal>();
         Test.startTest();
         GetInsurancePremium gip = new GetInsurancePremium();
         gip.setTest();
         premiums = gip.GetInsurancePremium(quote.Id);
         System.debug('returned premiums: '+premiums);
         Test.stopTest();
        
        // Verify response received contains fake values
        Decimal expectedAnnualValue = 1200;
        Decimal expectedMonthlyValue = 100;
        System.assertEquals(premiums.get('annual_premium'), expectedAnnualValue);
        System.assertEquals(premiums.get('monthly_premium'), expectedMonthlyValue);
    }
}