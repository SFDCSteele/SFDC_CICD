@RestResource(urlMapping='/packageUpdate/*')
global with sharing class DTCDeploymentPackageHandler {
    /*
     * Receives package.xml's as they are deployed to feature branches and attaches them to module enhancement requests for validation
     */

    public class PackageTypes {
		public String packageType;
		public List<String> packageMembers;
	}

	public String packageName;
	public List<PackageTypes> packageTypes;

	
	public static DTCDeploymentPackageHandler parse(String json) {
		return (DTCDeploymentPackageHandler) System.JSON.deserialize(json, DTCDeploymentPackageHandler.class);
	}

    @HttpPost
    global static String savePackageXML() 
    {
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

		String returnMessase = 'Success';
        String requestBody = req.requestBody.toString();
        requestBody = requestBody;
        
        try {
            DTCDeploymentPackageHandler packageXML = DTCDeploymentPackageHandler.parse(req.requestBody.toString());
            Application_Request__c mer = new Application_Request__c();
            mer = [select Id,Name from Application_Request__c where Deploy_Package_Name__c = :packageXML.packageName];
        
	        //Before adding the current package, ensure it doesn't already exist
	        List<CICD_Package_Content__c> pcks = new List<CICD_Package_Content__c>();
            try { 
                pcks = [select Id,Name from CICD_Package_Content__c where Module_Enhancement_Request__c = :mer.Id];
                delete pcks;
            } catch (Exception dme) {
                System.debug('savePackageXML: there wasnt package.xml already on this exception request: '+dme.getMessage());
            }

            List<CICD_Package_Content__c> contents = new List<CICD_Package_Content__c>();
            CICD_Package_Content__c content = new CICD_Package_Content__c();

            for (PackageTypes pck: packageXML.packageTypes) {

                for (String pckMember: pck.packageMembers) {
                    content = new CICD_Package_Content__c();
                    content.Package_xml_Name__c = packageXML.packageName;
                    content.MetaData_Type__c = pck.packageType;
                    content.MetaData_Element__c = pckMember;
                    if ( mer != null ) {
                        content.Name = mer.Name+':'+packageXML.packageName;//+':'+pck.packageType+':'+pckMember;
                        content.Module_Enhancement_Request__c = mer.Id;
                    }
                    System.debug('savePackageXML: package: '+content.Package_xml_Name__c+
                                 ' enhancement request: '+mer.Name+
                                 ' package type: '+content.MetaData_Type__c+
                                 ' metadata element: '+content.MetaData_Element__c);
                    contents.add(content);
                }
            }
            insert contents;
        } catch (Exception dme) {
			returnMessase = 'Failure: '+dme.getMessage();
        }
        return returnMessase;
    }
 
}