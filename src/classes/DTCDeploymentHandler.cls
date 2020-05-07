@RestResource(urlMapping='/buildUpdate/*')
global with sharing class DTCDeploymentHandler {
        
	public Build build {get;set;} 

	public DTCDeploymentHandler(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'build') {
						build = new Build(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'DTCDeploymentHandler consuming unrecognized property: '+text);
						//consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Build {
		public String envName {get;set;} 
		public String releaseNumber {get;set;} 
		public String build_url {get;set;} 
		public Decimal build_id {get;set;} 
		public String status {get;set;} 
		public String project_name {get;set;} 
		public String commit_id {get;set;} 
		public String message {get;set;} 
		public String committer {get;set;} 
		public String branch {get;set;} 
		public List<String> buildPackages {get;set;} 

		public Build(JSONParser parser) {
            System.debug('100.01-Build:JSONParser:parser: '+parser);
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
		            System.debug('100.02-Build:JSONParser:token:text: '+text);
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'envName') {
							envName = parser.getText();
						} else if (text == 'releaseNumber') {
							releaseNumber = parser.getText();
						} else if (text == 'build_url') {
							build_url = parser.getText();
						} else if (text == 'build_id') {
							build_id = parser.getDecimalValue();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'project_name') {
							project_name = parser.getText();
						} else if (text == 'commit_id') {
							commit_id = parser.getText();
						} else if (text == 'message') {
							message = parser.getText();
						} else if (text == 'committer') {
							committer = parser.getText();
						} else if (text == 'branch') {
							branch = parser.getText();
						} else if (text == 'buildPackages') {
							buildPackages = arrayOfString(parser);
				            System.debug('100.03-Build:JSONParser:token:text: '+text+' buildPackages: '+buildPackages);
						} else {
							System.debug(LoggingLevel.WARN, 'Build consuming unrecognized property: '+text);
							//consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static DTCDeploymentHandler parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new DTCDeploymentHandler(parser);
	}
	
    /*
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	*/


    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }

    @HttpPost
    global static String saveBuildDetails() 
    {
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String returnMessage = '{"status":"Error", "message":"Environment Not Found!"}';
        String buildStatus = '';
        String environment = '';
        String requestBody = req.requestBody.toString();
        //requestBody = requestBody;
        System.debug('100-saveBuildDetails: requestBody: '+requestBody);
        try {
			DTCDeploymentHandler firstBuild = DTCDeploymentHandler.parse(requestBody);
			DTCDeploymentHandler.Build build = firstBuild.build;
            
            List<CICD_Build_Details__c> buildDataRecsIn  = new List<CICD_Build_Details__c>();
            List<CICD_Build_Details__c> buildDataRecsOut = new List<CICD_Build_Details__c>();
            CICD_Build_Details__c buildData = new CICD_Build_Details__c();
            List<String> packageNames = new List<String>();
            List<Build_Status_Linkage__c> links = new List<Build_Status_Linkage__c>();
            
            System.debug('101-saveBuildDetails: Build_Id: '+build.build_id);
            buildDataRecsIn = [select Id from CICD_Build_Details__c where Build_Id__c = :build.build_id];

            if ( buildDataRecsIn.size() > 0 ) {
                for ( CICD_Build_Details__c bd: buildDataRecsIn ) {
                    bd.Message__c = build.message;
                    bd.Status__c  = build.status;
                    buildStatus = build.status;
	                environment = build.envName;
                    packageNames = build.buildPackages;
	                buildDataRecsOut.add(bd);
                    System.debug('101.3-saveBuildDetails: adding to buildDataRecsOut: '+bd);
                }
            } else {
                buildData.Environment_Name__c	= build.envName;
                buildData.Release_Number__c		= build.releaseNumber;
                buildData.Branch__c             = build.branch;
                buildData.Build_Id__c           = build.build_id;
                buildData.Build_URL__c          = build.build_url;
                buildData.commit_Id__c          = build.commit_id;
                buildData.Committer__c          = build.committer;
                buildData.Inbound_IP_Address__c = req.remoteAddress;
                buildData.Message__c            = build.message;
                buildData.Project_Name__c       = build.project_name;
                buildData.Status__c             = build.status;
                buildStatus = build.status;
                environment = build.envName;
                packageNames = build.buildPackages;
                
                buildDataRecsOut.add(buildData);
                System.debug('101.5-saveBuildDetails: adding to buildDataRecsOut: '+buildData);
            }
            
            upsert buildDataRecsOut;

            List<Application_Request__c> merUpdate = new List<Application_Request__c>();
            Integer ptr = 0;
            System.debug('102-saveBuildDetails: packageNames: '+packageNames+' buildDataRecsOut size: '+buildDataRecsOut.size());
            for ( CICD_Build_Details__c bd: buildDataRecsOut ) {
                for (Application_Request__c mer : [select Id,Deploy_Status__c,Deploy_Package_Name__c from Application_Request__c where Deploy_Package_Name__c IN :packageNames]) {                   
		            System.debug('103-saveBuildDetails: ER Id: '+mer.Id+' Deploy Status: '+mer.Deploy_Status__c+' package: '+mer.Deploy_Package_Name__c);
	                links.add(new Build_Status_Linkage__c(CICD_Build_Details__c=bd.Id,Module_Enhancement_Request__c=mer.Id));
                    mer.Deploy_Status__c = determineStatus(mer.Deploy_Status__c,buildStatus,environment);
		            System.debug('104-saveBuildDetails: new Status: '+mer.Deploy_Status__c);
                    merUpdate.add(mer);
                }
            }
            //only save the links between builds and module enhancements when the build is initiated
            System.debug('105-saveBuildDetails: buildStatus: '+buildStatus);
            if ( buildStatus.contains('Initiated')) {
                System.debug('106-saveBuildDetails: records inserted: '+links);
	            insert links;
            } else if ( buildStatus.contains('Success') ||  buildStatus.contains('Failed') ) {
                System.debug('107-saveBuildDetails: records updated: '+merUpdate);
	            upsert merUpdate;
            }
            returnMessage = 'Success('+buildDataRecsOut[0].Id+')';
            
        }
        catch (Exception e) {
            res.statusCode = 500;
            System.debug('Exception: '+e.getStackTraceString()+' message: '+e.getMessage());
            return e.getStackTraceString();
        }
        return returnMessage;
    }
    
    private static String determineStatus (String currentStatus, String buildStatus,String environment) {
        String returnStatus = currentStatus;
        if ( buildStatus.equals('Success')) {
            returnStatus = 'Deployed to '+environment;
        } else if ( buildStatus.equals('Failed')) {
            returnStatus = environment+' Deploy Failed';
        }
        return returnStatus;
    }
     	
    @HttpGet
    global static String getEnvironmentDetails() 
    {
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('100-inside getEnvironmentDetails...');
        
        String returnMessage = '{"status":"Error", "message":"Environment Not Found!"}';
        String envName = '';
        CICD_Environment__c env = new CICD_Environment__c();
        try {
            envName = req.params.get('envName');
	        System.debug('102-getEnvironmentDetails:env: '+envName);
            if ( envName != '') {
                env = [select Id,Name,Environment_URL__c,Username__c,Password__c,Security_Token__c from CICD_Environment__c where Name = :envName LIMIT 1 ];
		        System.debug('103-getEnvironmentDetails:environment: '+env);
	        	returnMessage = '{"environment":"'+env.Name+'", "serverURL":"'+env.Environment_URL__c+
                    '", "username":"'+env.Username__c+'", "password":"'+env.Password__c+
                    '", "securityToken":"'+env.Security_Token__c+'"}';
            } 
        }
        catch (Exception e) {
            returnMessage = '{"status":"Error", "message":"'+e.getMessage()+'"}';
        }
        System.debug('104-getEnvironmentDetails:returnMessage: '+returnMessage);
        return returnMessage;
    } 


}