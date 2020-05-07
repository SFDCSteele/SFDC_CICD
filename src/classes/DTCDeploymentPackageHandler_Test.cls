/*
* Tests the DTCDeploymentPackageHandler by creating a simple package.xml and attaches it to the Module Enhancement Request
*/

@IsTest
public class DTCDeploymentPackageHandler_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'                \"packageName\" : \"Package_VAHD-ENH-000602.xml\",'+
		'                \"packageTypes\" : ['+
		'                    {\"packageType\" : \"ApexClass\", \"packageMembers\" : [\"FOMFDRAcronymUtilityTest\",\"FOMFDRAcronymUtility\",\"FOMFDRAuthorityJunctionUtilityTest\"] },'+
		'                    {\"packageType\" : \"CustomField\", \"packageMembers\" : [\"Case.VHA_Suspense_Category__c\",\"ViewsAppeals__mdt.AppealsSecretKey__c\",\"BAMM_VIPR__c.BRM_Mapping_Status__c\"] },'+
		'                    {\"packageType\" : \"CustomObject\", \"packageMembers\" : [\"OFM_POC__c\",\"SaaS_Access_Request__c\",\"User_Creation_Setting__c\"] }'+
		'				]'+
		'            }';
        
        Test.startTest();
		DTCDeploymentPackageHandler obj = DTCDeploymentPackageHandler.parse(json);
        Test.stopTest();
		System.assert(obj != null);
	}
	
	static testMethod void testSavePackageXML() {
        
           
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        
           
        req.requestURI = '/services/apexrest/buildUpdate/saveBuildDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
		String json = '{'+
		'                \"packageName\" : \"Package_LHCAMP-ENH-000555.xml\",'+
		'                \"packageTypes\" : ['+
		'                    {\"packageType\" : \"ApexClass\", \"packageMembers\" : [\"FOMFDRAcronymUtilityTest\",\"FOMFDRAcronymUtility\",\"FOMFDRAuthorityJunctionUtilityTest\"] },'+
		'                    {\"packageType\" : \"CustomField\", \"packageMembers\" : [\"Case.VHA_Suspense_Category__c\",\"ViewsAppeals__mdt.AppealsSecretKey__c\",\"BAMM_VIPR__c.BRM_Mapping_Status__c\"] },'+
		'                    {\"packageType\" : \"CustomObject\", \"packageMembers\" : [\"OFM_POC__c\",\"SaaS_Access_Request__c\",\"User_Creation_Setting__c\"] }'+
		'				]'+
		'            }';
        req.requestBody = Blob.valueof(json);
        RestContext.request = req;
        RestContext.response= res;
        
        DTCDeploymentHandler_TEST.createModuleEnhancement();
	    
        Test.startTest();
		String returnMessage = DTCDeploymentPackageHandler.savePackageXML();
        Test.stopTest();
		System.assertEquals('Success', returnMessage);
	}
}