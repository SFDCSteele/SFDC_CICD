@RestResource(urlMapping='/getBranches/*')
global with sharing class DTCDeploymentBranchHandler {
     	
    @HttpGet
    global static String getBranches() 
    {
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String returnMessage = '{"status":"Error", "message":"Branch Not Found!"}';
        String branchName = '';
        Application_Request__c mer = new Application_Request__c();
        try {
            branchName = req.params.get('branchName');
            if ( branchName != '') {
                try { 
                    mer = [select Id,Deploy_Release_Branch__c,Merge_Branch_Name__c from Application_Request__c where Deploy_Branch__c = :branchName LIMIT 1];
                } catch (Exception dme) {
                    System.debug('DTCDeploymentBranchHandler:getBranches: unable to find existing Module Enhancement Request for branch: '+branchName+
                                '\n'+dme.getMessage());
                }
	        	returnMessage = '{"releaseBranch":"'+mer.Deploy_Release_Branch__c+'", "mergeBranch":"'+mer.Merge_Branch_Name__c+'"}';
            } 
        }
        catch (Exception e) {
            returnMessage = 'ERROR';
        }
        return returnMessage;
    } 

}