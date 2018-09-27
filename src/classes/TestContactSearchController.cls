@isTest
public class TestContactSearchController {
    
    public static TestMethod void testContactSearchTestDuplicate() {
        ContactSearchController conSc = new ContactSearchController();
        PageReference newPage = new Pagereference('ContactSearch');
        Test.setCurrentPage(newPage);
        System.debug('testContactSearchTestDuplicate:current page: '+newPage.getUrl());
        conSc.sContactId='';
        conSc.sAccountId='';
        Account act = new Account(name='test account');
        insert act;
        Contact con = new Contact(firstname='test',lastname='contact',AccountId=act.Id,
 									MailingStreet='123 main',MailingCity='New York',MailingState='New York',
                                  	MailingPostalCode='20001',MailingCountry='United States',
	                                SSN__c='123121234',BirthDate=System.Date.today(),
                                 	Phone='123-123-1234');
        insert con;
        conSc.sContactId=con.Id;
        conSc.sAccountId=con.AccountId;
        System.debug('sContactId: '+conSc.sContactId+' sAccountId: '+conSc.sAccountId+' debugSoql: '+conSc.debugSoql);
        conSc.quote=null;
        conSc.driver=null;
        conSc.toggleSort();
        conSc.performAddressValidation();
        conSc.sContactId=null;
        conSc.sAccountId=null;
        conSc.contact.firstname='test';
        conSc.contact.lastname='contact';
        conSc.contact.MailingStreet='123 main';
        conSc.contact.MailingCity='New York';
        conSc.contact.MailingState='New York';
        conSc.contact.MailingPostalCode='20001';
        conSc.contact.MailingCountry='United States';
        conSc.contact.SSN__c='123121234';
        conSc.contact.BirthDate=System.Date.today();
        conSc.contact.Phone='123-123-1234';

        String nextPage = conSc.save().getUrl();
        System.debug('1-Testing duplicate: '+conSc.contactDuplicate()+' Next page: '+nextPage);
        System.assertEquals(conSc.contactDuplicate(), true);
        
    }


    public static TestMethod void testContactSearchRunSearch() {
        ContactSearchController conSc = new ContactSearchController();
        PageReference newPage = new Pagereference('ContactSearch');
        Test.setCurrentPage(newPage);
        System.debug('testContactSearchRunSearch:current page: '+newPage.getUrl());
        conSc.quote=null;
        conSc.driver=null;
        conSc.sContactId=null;
        conSc.sAccountId=null;
        conSc.contact.firstname='test';
        conSc.contact.lastname='contact';
        conSc.contact.MailingStreet='123 main';
        conSc.contact.MailingCity='New York';
        conSc.contact.MailingState='New York';
        conSc.contact.MailingPostalCode='20001';
        conSc.contact.MailingCountry='United States';
        conSc.contact.SSN__c='123121234';
        conSc.contact.BirthDate=System.Date.today();
        conSc.contact.Phone='123-123-1234';
		
        conSc.testRunSearch();
        System.assertEquals(conSc.contactFound(), true);
        
    }
    
    public static TestMethod void testContactSearchTestNoDuplicate() {
        ContactSearchController conSc = new ContactSearchController();
        PageReference newPage = new Pagereference('ContactSearch');
        Test.setCurrentPage(newPage);
        System.debug('testContactSearchTestNoDuplicate:current page: '+newPage.getUrl());
        conSc.quote=null;
        conSc.driver=null;
        conSc.sContactId=null;
        conSc.sAccountId=null;
        conSc.contact.firstname='test';
        conSc.contact.lastname='contact_'+System.now();
        conSc.contact.MailingStreet='123 main';
        conSc.contact.MailingCity='New York';
        conSc.contact.MailingState='New York';
        conSc.contact.MailingPostalCode='20001';
        conSc.contact.MailingCountry='United States';
        conSc.contact.SSN__c='123121234';
        conSc.contact.BirthDate=System.Date.today();
        conSc.contact.Phone='123-123-1234';

        String nextPage = conSc.save().getUrl();
        System.debug('2-Next page: '+nextPage);
        System.assertEquals(conSc.contactSaved(), true);
        System.assertEquals(conSc.quoteCreated(), true);
        
    }

    public static TestMethod void testContactSearchTestFailQuote() {
        ContactSearchController conSc = new ContactSearchController();
        PageReference newPage = new Pagereference('ContactSearch');
        Test.setCurrentPage(newPage);
        System.debug('testContactSearchTestFailQuote:current page: '+newPage.getUrl());
        conSc.createQuote();
        System.assertEquals(conSc.quoteCreated(), false);
        
    }
    
}