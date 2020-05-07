global with sharing class CICDBuildInitiator {

    global static String GitHub_Access_Token = '';
    global static String Jenkins_Access_Token = '';
    global static String Jenkins_Password = '';
    global static String Jenkins_User = '';
    global static String Jenkins_URL = '';
    
    global static String submitBuildRequest(String envName,String requestedBranch, String packageXML, String committerName, 
                                            String buildParameters, String currentRelease, String buildPrefix ) {
        
        String returnMessage = 'Deploy Requested';
        String body = 'buildPrefix=1000&requestedBranch='+requestedBranch+'&envName='+envName+'&packageXML='+packageXML+
            '&CommitterName='+UserInfo.getName()+'&BuildParameters='+buildParameters+
            '&buildPrefix='+buildPrefix +'&CurrentRelease='+currentRelease;
        
        System.debug('1-submitBuildRequest: deploying with these parameters: '+body+' Jenkins_Access_Token: '+Jenkins_Access_Token);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        try {
            String authStr = Jenkins_User +':'+Jenkins_Access_Token;
            request.setMethod('POST');
            request.setEndpoint('http://'+authStr+'@'+Jenkins_URL+'/buildWithParameters?'+body);
	        System.debug('2-submitBuildRequest:Endpoint: '+'http://'+authStr+'@'+Jenkins_URL+'/buildWithParameters?'+
                         'body: '+body);
    
            HttpResponse response = http.send(request);
            System.debug('3-submitBuildRequest:response: '+response.getStatus()+' code: '+response.getStatusCode());
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                System.debug('4-submitBuildRequest:There was an error with the request: '+body+' error: '+response.getStatus());
                returnMessage = response.getStatus();
            }        
        } catch (Exception e) {
	        System.debug('5-submitBuildRequest:exception: '+e.getMessage());
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }
    
    @InvocableMethod(label='Submit Jenkins Build' description='Submits a parameterized build request to Jenkins')
    global static void executeBuild(List<Id> erIds) {
        System.debug('Inside executeBuild: erIds: '+erIds);
        List<Application_Request__c> ers = new List<Application_Request__c>();
        List<String> envNames = new List<String>();
        List<String> requestedBranches = new List<String>();
        List<String> packageXMLs = new List<String>();
        List<String> committerNames = new List<String>();
        List<String> currentReleases = new List<String>();
        try {
	        System.debug('executeBuild: executing query');
            ers = [select Id,Deploy_Status__c,Deploy_Branch__c,Deploy_Package_Name__c,LastModifiedBy.Name,Deploy_Release_Branch__c from Application_Request__c
                   where Id IN: erIds AND Deploy_Status__c LIKE 'Deploy to %'];
	        System.debug('executeBuild: query found: '+ers.size()+' => '+ers);
            for ( Application_Request__c er: ers ) {
                System.debug('executeBuild: envName: '+er.Deploy_Status__c.split(' ')[2]+
                             ' requestedBranch: '+er.Deploy_Branch__c+' packageXML: '+er.Deploy_Package_Name__c+
                             ' committerName: '+er.LastModifiedBy.Name+
                             ' currentRelease: '+er.Deploy_Release_Branch__c);
                envNames.add((er.Deploy_Status__c.split(' '))[2]);
                requestedBranches.add(er.Deploy_Branch__c);
                packageXMLs.add(er.Deploy_Package_Name__c);
                committerNames.add(((String)er.LastModifiedBy.Name).replace(' ','_'));
                currentReleases.add(er.Deploy_Release_Branch__c);
            }
            if ( ers.size() > 0 ) {
		        processBuild(envNames,requestedBranches,packageXMLs,committerNames,currentReleases);
            }
        }
        Catch(Exception e) {
            system.debug('Error While requesting a deploy in Jenkins: '+e.getMessage());
        }                
    }
    
    @future(callout=true)
    global static void processBuild(List<String> envNames,List<String> requestedBranches,List<String> packageXMLs,
                                    List<String> committerNames, List<String> currentReleases) {
        String envName = '';
        String requestedBranch = ''; 
        String packageXML = '';
        String committerName = '';
        String buildParameters = '';
        String currentRelease = '';
        String buildPrefix = '';
        String returnMessage = '';
        System.debug('Inside processBuild: envNames: '+envNames+' requestedBranches: '+requestedBranches+
                     ' packageXMLs: '+packageXMLs+' committerNames: '+committerNames+' currentReleases: '+currentReleases);
                
        GitHub_Access_Token = '';
        Jenkins_Access_Token = '';
    	Jenkins_Password = '';
		Jenkins_User = '';
		Jenkins_URL = '';
        List<DTC_Deployment_Parameters__c> ddp = DTC_Deployment_Parameters__c.getall().values();
        DTC_Release_Parameters__c drp = DTC_Release_Parameters__c.getInstance();
        
        try {
            GitHub_Access_Token = ddp[0].GitHub_Access_Token__c;
            Jenkins_Access_Token = ddp[0].Jenkins_Access_Token__c;
            Jenkins_Password = ddp[0].Jenkins_Password__c;
            Jenkins_User = ddp[0].Jenkins_User__c;
            Jenkins_URL = ddp[0].Jenkins_Build_URL__c;
            buildParameters = drp.Build_Parameters__c;
            buildPrefix = drp.Build_Prefix__c;
        }  catch (Exception e) {
            System.debug('CICDBuildInitiator:processBuild: error seting gitHub parameters: '+e.getMessage());
        }
        if(Test.isRunningTest()){
	        GitHub_Access_Token = '1231231231234';
	        Jenkins_Access_Token = '1231231231234';
            Jenkins_Password = 'password';
            Jenkins_User = 'autoBuild';
            Jenkins_URL = 'http://localhost:8080';
        } 
        for (integer i=0;i<envNames.size();i++ ) {
            envName = envNames[i];
            requestedBranch = requestedBranches[i];
            packageXML = packageXMLs[i];
            committerName = committerNames[i];
            currentRelease = currentReleases[i];
            System.debug('Calling submitBuildRequest: envNames: '+envNames);
            returnMessage = submitBuildRequest(envName,requestedBranch,packageXML,committerName,buildParameters,
                                               currentRelease,buildPrefix);
            System.debug('returning from submitBuildRequest: returnMessage: '+returnMessage);
        }

        System.debug('0-processBuild:returnMessage: '+returnMessage);
    }

}