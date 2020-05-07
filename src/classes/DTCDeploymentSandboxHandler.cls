@RestResource(urlMapping='/getSandbox/*')
global with sharing class DTCDeploymentSandboxHandler {
     	
    @HttpGet
    global static String getSandoxName() 
    {
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String returnMessage = '{"status":"Error", "message":"Branch/Environment Not Found!"}';
        String branchName = '';
        Application_Request__c mer = new Application_Request__c();
        try {
            branchName = req.params.get('branchName');
            if ( branchName != '') {
                try { 
                    mer = [select Id,Deploy_To_SIT_Sandbox_CB__c,Deploy_To_SIT_Sandbox_Id__r.Name from Application_Request__c where Deploy_Branch__c = :branchName LIMIT 1];
                } catch (Exception dme) {
                    System.debug('DTCDeploymentSandboxHandler:getSandoxName: unable to find existing Module Enhancement Request for branch: '+branchName+
                                '\n'+dme.getMessage());
                }
	        	returnMessage = '{"deployToSIT":"'+mer.Deploy_To_SIT_Sandbox_CB__c+'", "sitEnvName":"'+mer.Deploy_To_SIT_Sandbox_Id__r.Name+'"}';
            } 
        }
        catch (Exception e) {
            returnMessage = 'ERROR';
        }
        return returnMessage;
    } 

}