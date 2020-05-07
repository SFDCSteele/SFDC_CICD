@isTest
public class DTCDeploymentHandler_TEST {
    //this boolean is flipped on after the master branch creation, so all the createBranch calls, are good!
    /*private class Mock implements HttpCalloutMock {
        boolean fullReponse = false;
        public HTTPResponse respond(HTTPRequest req) {
        	if (req.getMethod() == 'POST') {
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"build": {'+
                    '"build_url":"https://www.codeship.com/projects/10213/builds/973711",'+
                    '"commit_url":"https://github.com/codeship/docs/commit/96943dc5269634c211b6fbb18896ecdcbd40a047",'+
                    '"project_id":10213,'+
                    '"build_id":973712,'+
                    '"status":"Initiated",'+
                    '"project_name":"codeship/docs",'+
                    '"commit_id":"96943dc5269634c211b6fbb18896ecdcbd40a047",'+
                    '"short_commit_id":"96943",'+
                    '"message":"Merge pull request #34 from codeship/feature/shallow-clone",'+
                    '"committer":"beanieboi",'+
                    '"branch":"LHCAMP-ENH-000555"}');
                res.setStatus('OK');
                res.setStatusCode(201);
                return res;
            } else if (req.getMethod() == 'GET') {
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/json');
	        	res.setBody('{"environment":"PROD", "serverURL":"https://login.salesforce.com", "username":"deployuser@salesforce.com",'+
                            ' "password":"password", "securityToken":"12323r4345;lkjasdf"}');
                res.setStatus('OK');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatus('OK');
                res.setStatusCode(500);
                return res;
            }
        }
    }*/
    
    @isTest static void testSaveBuildDetails_single_initiate() {
        
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        
           
        req.requestURI = '/services/apexrest/buildUpdate/saveBuildDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
		String JsonMsg = '{\"build\": '+
		'			{\"envName\":\"ENTSD\",\"releaseNumber\":\"Release_19.6.1\",\"build_url\":\"http://18.188.255.76:8080/job/VA_SFDC_Parameterized_Build/173/\",'+
		'					\"build_id\":173,\"status\":\"Initiated\",\"project_name\":\"git@github.com:department-of-veterans-affairs/va-salesforce-master.git\",'+
		'					\"commit_id\":\"b79e49e2315f1b0eabc3c7cdf5c5f5e3a7172c7c\",'+
		'					\"message\":\"Revert  Removal of required field in permission set   This reverts commit 665810c2c1db1eb0ad9ab6b87a80741c449f0931.\",'+
		'					\"committer\":\"WSteele\",\"branch\":\"Acumen\",'+
		'					\"buildPackages\": [\"Package_GCMTRS-ENH-000633.xm\",\"Package_GCMTRS-ENH-000633.xm\",\"Package_LHCAMP-ENH-000555.xm\"]}}';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        createModuleEnhancement();
	    
        Test.startTest();
        String returnMessage_insert = DTCDeploymentHandler.saveBuildDetails();
        String returnMessage_update = DTCDeploymentHandler.saveBuildDetails();
        Test.stopTest();
	System.debug('testSaveBuildDetails_single_initiate:returnMessage_insert: '+returnMessage_insert);
	System.debug('testSaveBuildDetails_single_initiate:returnMessage_update: '+returnMessage_update);
        System.assert(returnMessage_insert.contains('Success'));
        System.assert(returnMessage_update.contains('Success'));
    }
    
    @isTest static void testSaveBuildDetails_single_success() {
        
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        
           
        req.requestURI = '/services/apexrest/buildUpdate/saveBuildDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
		String JsonMsg = '{\"build\": '+
		'			{\"envName\":\"ENTSD\",\"releaseNumber\":\"Release_19.6.1\",\"build_url\":\"http://18.188.255.76:8080/job/VA_SFDC_Parameterized_Build/173/\",'+
		'					\"build_id\":173,\"status\":\"Success\",\"project_name\":\"git@github.com:department-of-veterans-affairs/va-salesforce-master.git\",'+
		'					\"commit_id\":\"b79e49e2315f1b0eabc3c7cdf5c5f5e3a7172c7c\",'+
		'					\"message\":\"Revert  Removal of required field in permission set   This reverts commit 665810c2c1db1eb0ad9ab6b87a80741c449f0931.\",'+
		'					\"committer\":\"WSteele\",\"branch\":\"Acumen\",'+
		'					\"buildPackages\": [\"Package_GCMTRS-ENH-000633.xm\",\"Package_GCMTRS-ENH-000633.xm\",\"Package_LHCAMP-ENH-000555.xm\"]}}';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        createModuleEnhancement();
	    
        Test.startTest();
        String returnMessage_insert = DTCDeploymentHandler.saveBuildDetails();
        String returnMessage_update = DTCDeploymentHandler.saveBuildDetails();
        Test.stopTest();
	System.debug('testSaveBuildDetails_single_success:returnMessage_insert: '+returnMessage_insert);
	System.debug('testSaveBuildDetails_single_success:returnMessage_update: '+returnMessage_update);
        System.assert(returnMessage_insert.contains('Success'));
        System.assert(returnMessage_update.contains('Success'));
    }
    
    @isTest static void testSaveBuildDetails_single_failed() {
        
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        
           
        req.requestURI = '/services/apexrest/buildUpdate/saveBuildDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
		String JsonMsg = '{\"build\": '+
		'			{\"envName\":\"ENTSD\",\"releaseNumber\":\"Release_19.6.1\",\"build_url\":\"http://18.188.255.76:8080/job/VA_SFDC_Parameterized_Build/173/\",'+
		'					\"build_id\":173,\"status\":\"Failed\",\"project_name\":\"git@github.com:department-of-veterans-affairs/va-salesforce-master.git\",'+
		'					\"commit_id\":\"b79e49e2315f1b0eabc3c7cdf5c5f5e3a7172c7c\",'+
		'					\"message\":\"Revert  Removal of required field in permission set   This reverts commit 665810c2c1db1eb0ad9ab6b87a80741c449f0931.\",'+
		'					\"committer\":\"WSteele\",\"branch\":\"Acumen\",'+
		'					\"buildPackages\": [\"Package_GCMTRS-ENH-000633.xml\",\"Package_GCMTRS-ENH-000633.xml\",\"Package_LHCAMP-ENH-000555.xml\"]}}';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        createModuleEnhancement();
	    
        Test.startTest();
        String returnMessage_insert = DTCDeploymentHandler.saveBuildDetails();
        String returnMessage_update = DTCDeploymentHandler.saveBuildDetails();
        Test.stopTest();
	System.debug('testSaveBuildDetails_single_failed:returnMessage_insert: '+returnMessage_insert);
	System.debug('testSaveBuildDetails_single_failed:returnMessage_update: '+returnMessage_update);
        System.assert(returnMessage_insert.contains('Success'));
        System.assert(returnMessage_update.contains('Success'));
    }
    
    @isTest static void testSaveBuildDetails_multiple() {

        CICD_Build_Details__c build = new CICD_Build_Details__c();
        build.Environment_Name__c	= 'ENTSD';
        build.Branch__c             = 'LHCAMP-ENH-000555';
        build.Build_Id__c           = 973713;
        build.Build_URL__c          = 'https://www.codeship.com';
        build.commit_Id__c          = '96943dc52';
        build.Commit_URL__c         = 'https://github.com';
        build.Committer__c          = 'codeship/docs';
        build.Inbound_IP_Address__c = '96943dc52';
        build.Message__c            = 'Merge pull request';
        build.Project_Id__c         = 10213;
        build.Project_Name__c       = 'codeship/docs';
        build.Short_Commit_Id__c    = '96943';
        build.Status__c             = 'Initiated';
        insert build;
            
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
                
        createModuleEnhancement();
           
        req.requestURI = '/services/apexrest/buildUpdate/saveBuildDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
		String JsonMsg = '{\"build\": '+
		'			{\"envName\":\"ENTSD\",\"releaseNumber\":\"Release_19.6.1\",\"build_url\":\"http://18.188.255.76:8080/job/VA_SFDC_Parameterized_Build/173/\",'+
		'					\"build_id\":173,\"status\":\"Initiated\",\"project_name\":\"git@github.com:department-of-veterans-affairs/va-salesforce-master.git\",'+
		'					\"commit_id\":\"b79e49e2315f1b0eabc3c7cdf5c5f5e3a7172c7c\",'+
		'					\"message\":\"Revert  Removal of required field in permission set   This reverts commit 665810c2c1db1eb0ad9ab6b87a80741c449f0931.\",'+
		'					\"committer\":\"WSteele\",\"branch\":\"Acumen\",'+
		'					\"buildPackages\": [\"Package_GCMTRS-ENH-000633.xm\",\"Package_GCMTRS-ENH-000633.xm\",\"Package_LHCAMP-ENH-000555.xm\"]}}';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
	    
        Test.startTest();
        String returnMessage_insert = DTCDeploymentHandler.saveBuildDetails();
        String returnMessage_update = DTCDeploymentHandler.saveBuildDetails();
        Test.stopTest();
	System.debug('testSaveBuildDetails_multiple:returnMessage_insert: '+returnMessage_insert);
	System.debug('testSaveBuildDetails_multiple:returnMessage_update: '+returnMessage_update);
        System.assert(returnMessage_insert.contains('Success'));
        System.assert(returnMessage_update.contains('Success'));
    }

    @isTest static void testGetEnvironment() {
        
        CICD_Environment__c env = new CICD_Environment__c();
        env.Name = 'PROD';
        env.Environment_URL__c = 'https://login.salesforce.com';
        env.Username__c = 'deployUser';
        env.Password__c = 'password';
        env.Security_Token__c = '123123123';
        insert env;
          
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/buildUpdate/getEnvironmentDetails';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('envName', 'PROD');
        RestContext.request = req;
        RestContext.response= res;
	    
        Test.startTest();
        String returnMessage = DTCDeploymentHandler.getEnvironmentDetails();
        Test.stopTest();
        try {
            System.JSONParser parser = System.JSON.createParser(returnMessage);
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'environment') {
                            System.assertEquals('PROD', parser.getText());
                        } else if (text == 'serverURL') {
                            System.assertEquals('https://login.salesforce.com', parser.getText());
                        } else if (text == 'username') {
                            System.assertEquals('deployUser', parser.getText());
                        } else if (text == 'password') {
                            System.assertEquals('password', parser.getText());
                        } else if (text == 'securityToken') {
                            System.assertEquals('123123123', parser.getText());
                        } else {
                            System.debug(LoggingLevel.WARN, 'DTCDeploymentHandler.getEnvironmentDetails: consuming unrecognized property: '+text);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error trying to deserialize return object: '+e.getStackTraceString());
        	System.assert(False);
        }
        
    }

    @isTest static void testGetSandbox() {
        
        CICD_Environment__c env = new CICD_Environment__c();
        env.Name = 'ENTSDVAPM';
        env.Environment_URL__c = 'https://login.salesforce.com';
        env.Username__c = 'deployUser';
        env.Password__c = 'password';
        env.Security_Token__c = '123123123';
        insert env;
          
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/buildUpdate/getSandbox';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('branchName', 'LHCAMP-ENH-000555');
        RestContext.request = req;
        RestContext.response= res;
	    
        Test.startTest();
        String returnMessage = DTCDeploymentSandboxHandler.getSandoxName();
        Test.stopTest();
        try {
            System.JSONParser parser = System.JSON.createParser(returnMessage);
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'deployToSIT') {
                            System.assertEquals(true, parser.getBooleanValue());
                        } else if (text == 'envName') {
                            System.assertEquals('ENTSDVAPM', parser.getText());
                        } else {
                            System.debug(LoggingLevel.WARN, 'DTCDeploymentHandler.getSandbox: consuming unrecognized property: '+text);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error trying to deserialize return object: '+e.getStackTraceString());
        	//System.assert(False,'Error trying to deserialize return object: '+e.getMessage());
        }
        
    }

    @isTest static void testGetBranches() {
        
        CICD_Environment__c env = new CICD_Environment__c();
        env.Name = 'ENTSDVAPM';
        env.Environment_URL__c = 'https://login.salesforce.com';
        env.Username__c = 'deployUser';
        env.Password__c = 'password';
        env.Security_Token__c = '123123123';
        insert env;
          
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/buildUpdate/getBranches';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
        req.addParameter('branchName', 'LHCAMP-ENH-000555');
        RestContext.request = req;
        RestContext.response= res;
	    
        Test.startTest();
        String returnMessage = DTCDeploymentBranchHandler.getBranches();
        Test.stopTest();
        try {
            System.JSONParser parser = System.JSON.createParser(returnMessage);
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    /*if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'releaseBranch') {
                            System.assertEquals(true, parser.getText());
                        } else if (text == 'mergeBranch') {
                            System.assertEquals('ENTSDVAPM', parser.getText());
                        } else {
                            System.debug(LoggingLevel.WARN, 'DTCDeploymentBranchHandler.getBranches: consuming unrecognized property: '+text);
                        }
                    }*/
                }
            }
        } catch (Exception e) {
            System.debug('Error trying to deserialize return object: '+e.getStackTraceString());
        	//System.assert(False,'Error trying to deserialize return object: '+e.getMessage());
        }
        
    }

    public static void createModuleEnhancement() {
        
        Application_Request__c mer 			= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_LHCAMP-ENH-000555.xml';
        mer.Deploy_Branch__c 				= 'LHCAMP-ENH-000555';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing build status 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Deploy to ENTSD';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing build status description';
        mer.Business_Objective__c 			= 'testing build status objective';
        mer.Business_Sponsor__c 			= 'testing build status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('10-DTCDeploymentHandler_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('11-DTCDeploymentHandler_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_GCMTRS-ENH-000633.xml';
        mer.Deploy_Branch__c 				= 'GCMTRS-ENH-000633';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing build status 2';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Deploy to ENTSD';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing build status description';
        mer.Business_Objective__c 			= 'testing build status objective';
        mer.Business_Sponsor__c 			= 'testing build status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('20-DTCDeploymentHandler_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('21-DTCDeploymentHandler_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_VAHD-ENH-000699.xml';
        mer.Deploy_Branch__c 				= 'VAHD-ENH-000699';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing extract process 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Extract Package';
        mer.From_Sandbox__c					= 'CTALBOTVA';
        mer.Deploy_Changeset__c				= 'deploy_changeset';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing build status description';
        mer.Business_Objective__c 			= 'testing build status objective';
        mer.Business_Sponsor__c 			= 'testing build status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('30-DTCDeploymentHandler_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('31-DTCDeploymentHandler_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_VAHD-ENH-000700.xml';
        mer.Deploy_Branch__c 				= 'VAHD-ENH-000700';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing merge process 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'Merge to Merge Branch';
        mer.From_Sandbox__c					= 'CTALBOTVA';
        mer.Deploy_Changeset__c				= 'deploy_changeset';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing merge status description';
        mer.Business_Objective__c 			= 'testing merge status objective';
        mer.Business_Sponsor__c 			= 'testing merge status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('32-DTCDeploymentHandler_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('33-DTCDeploymentHandler_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        mer 	= new Application_Request__c();
        mer.Deploy_Package_Name__c 			= 'Package_VAHD-ENH-000701.xml';
        mer.Deploy_Branch__c 				= 'VAHD-ENH-000701';
        //mer.Deploy_Release_Branch__c 		= 'Release_19.99.1';
        mer.Release_Date__c					= 'On Hold';
        mer.Name_of_Dev_Sandbox__c 			= 'test';
        mer.New_Application_Name__c 		= 'testing merge process 1';
        //mer.RecordTypeId 					= [select Id FROM RecordType where Name='Application Enhancement' limit 1].Id;
        mer.Technology__c 					= 'Salesforce';
        mer.Status__c 						= 'New';
        mer.Deploy_Status__c				= 'New';
        mer.From_Sandbox__c					= 'CTALBOTVA';
        mer.Deploy_Changeset__c				= 'deploy_changeset';
        mer.Org__c 							= 'VA';
        mer.Contract__c 					= 'Other';
        mer.App_Enhancement_Description__c 	= 'testing create branch';
        mer.Business_Objective__c 			= 'testing merge status objective';
        mer.Business_Sponsor__c 			= 'testing merge status sponsor';
        mer.Is_there_a_change_in_PII_PHI__c = 'No';
        mer.New_Application__c = TRUE;
        mer.Urgency_to_Move_Migrate_App__c  = 'Low';
        mer.Number_of_Anticipated_Users__c  = '0-50';
        System.debug('34-DTCDeploymentHandler_TEST:createModuleEnhancement:preparing to save: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
        insert mer;
        System.debug('35-DTCDeploymentHandler_TEST:createModuleEnhancement:SAVED: '+mer.New_Application_Name__c+' with record type: '+mer.RecordTypeId);
    }
}