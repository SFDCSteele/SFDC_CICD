global with sharing class CICDExtractInitiator {

    global static String GitHub_Access_Token = '';
    global static String Jenkins_Access_Token = '';
    global static String Jenkins_Password = '';
    global static String Jenkins_User = '';
    global static String Jenkins_URL = '';
    
    global static String submitExtractRequest(String envName,String requestedBranch, String packageXML, 
                                              String changeSet, String committerName, String currentRelease) {
        
        String returnMessage = 'Deploy Requested';
        //./src/build/extractor_jenkins.sh $envName $requestedBranch $packageXML $ChangeSet $CommitMessage $CurrentRelease
        String body = 'requestedBranch='+requestedBranch+'&envName='+envName+'&packageXML='+packageXML+
            '&ChangeSet='+changeSet+'&CommitterName='+UserInfo.getName()+'&CurrentRelease='+currentRelease;
        
        System.debug('1-submitExtractRequest: deploying with these parameters: '+body+' Jenkins_Access_Token: '+Jenkins_Access_Token);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        try {
            String authStr = Jenkins_User +':'+Jenkins_Access_Token;
            request.setMethod('POST');
            request.setEndpoint('http://'+authStr+'@'+Jenkins_URL+'/buildWithParameters?'+body);
	        System.debug('2-submitExtractRequest:Endpoint: '+'http://'+authStr+'@'+Jenkins_URL+'/buildWithParameters?'+
                         'body: '+body);
    
            HttpResponse response = http.send(request);
            System.debug('3-submitExtractRequest:response: '+response.getStatus()+' code: '+response.getStatusCode());
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                System.debug('4-submitExtractRequest:There was an error with the request: '+body+' error: '+response.getStatus());
                returnMessage = response.getStatus();
            }        
        } catch (Exception e) {
	        System.debug('5-submitExtractRequest:exception: '+e.getMessage() );
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }
    
    @InvocableMethod(label='Submit Jenkins Extract' description='Submits a parameterized extract request to Jenkins')
    global static void executeExtract(List<Id> erIds) {
        System.debug('Inside executeExtract: erIds: '+erIds);
        List<Application_Request__c> ers = new List<Application_Request__c>();
        List<String> envNames = new List<String>();
        List<String> requestedBranches = new List<String>();
        List<String> packageXMLs = new List<String>();
        List<String> changeSets = new List<String>();
        List<String> committerNames = new List<String>();
        List<String> currentReleases = new List<String>();
        try {
	        System.debug('executeExtract: executing query');
            ers = [select Id,Deploy_Status__c,From_Sandbox_Id__r.Name,Deploy_Branch__c,Deploy_Package_Name__c,Deploy_Changeset__c, 
                   LastModifiedBy.Name,Deploy_Release_Branch__c from Application_Request__c
                   where Id IN: erIds AND Deploy_Status__c = 'Extract Package'];
	        System.debug('executeExtract: query found: '+ers.size()+' => '+ers);
            for ( Application_Request__c er: ers ) {
                System.debug('executeExtract: envName: '+er.From_Sandbox_Id__r.Name+
                             ' requestedBranch: '+er.Deploy_Branch__c+' packageXML: '+er.Deploy_Package_Name__c+
                             ' changeset: '+er.Deploy_Changeset__c+
                             ' committerName: '+er.LastModifiedBy.Name+
                             ' currentRelease: '+er.Deploy_Release_Branch__c);
                envNames.add(er.From_Sandbox_Id__r.Name);
                requestedBranches.add(er.Deploy_Branch__c);
                packageXMLs.add(er.Deploy_Package_Name__c);
                changeSets.add(er.Deploy_Changeset__c);
                committerNames.add(((String)er.LastModifiedBy.Name).replace(' ','_'));
                currentReleases.add(er.Deploy_Release_Branch__c);
            }
            if ( ers.size() > 0 ) {
		        processExtract(envNames,requestedBranches,packageXMLs,changeSets,committerNames,currentReleases);
            }
        }
        Catch(Exception e) {
            system.debug('Error While requesting a deploy in Jenkins: '+e.getMessage());
        }                
    }
    
    @future(callout=true)
    global static void processExtract(List<String> envNames,List<String> requestedBranches,List<String> packageXMLs,
                                      List<String> changeSets, List<String> committerNames, List<String> currentReleases) {
        String envName = '';
        String requestedBranch = ''; 
        String packageXML = '';
        String changeSet = '';
        String committerName = '';
        String currentRelease = '';
        String returnMessage = '';
        System.debug('Inside processExtract: envNames: '+envNames+' requestedBranches: '+requestedBranches+
                     ' packageXMLs: '+packageXMLs+'changeSet: '+changeSets+' committerNames: '+committerNames+' currentReleases: '+currentReleases);
                
        GitHub_Access_Token = '';
        Jenkins_Access_Token = '';
    	Jenkins_Password = '';
		Jenkins_User = '';
		Jenkins_URL = '';
        if(Test.isRunningTest()){
	        GitHub_Access_Token = '1231231231234';
	        Jenkins_Access_Token = '1231231231234';
            Jenkins_Password = 'password';
            Jenkins_User = 'autoExtract';
            Jenkins_URL = 'http://localhost:8080';
        } else {
            List<DTC_Deployment_Parameters__c> ddp = DTC_Deployment_Parameters__c.getall().values();
            
            try {
                GitHub_Access_Token = ddp[0].GitHub_Access_Token__c;
                Jenkins_Access_Token = ddp[0].Jenkins_Access_Token__c;
                Jenkins_Password = ddp[0].Jenkins_Password__c;
                Jenkins_User = ddp[0].Jenkins_User__c;
                Jenkins_URL = ddp[0].Jenkins_Extract_URL__c;
            }
            catch (Exception e) {
                GitHub_Access_Token = null;
                Jenkins_Access_Token = null;
                Jenkins_Password = null;
                Jenkins_User = null;
                Jenkins_URL = null;
            }
        }
        for (integer i=0;i<envNames.size();i++ ) {
            envName = envNames[i];
            requestedBranch = requestedBranches[i];
            packageXML = packageXMLs[i];
            changeSet = changeSets[i];
            committerName = committerNames[i];
            currentRelease = currentReleases[i];
            System.debug('Calling submitExtractRequest: envNames: '+envNames);
            returnMessage = submitExtractRequest(envName,requestedBranch,packageXML,changeSet,committerName,currentRelease);
            System.debug('returning from submitExtractRequest: returnMessage: '+returnMessage);
        }

        System.debug('0-processExtract:returnMessage: '+returnMessage);
    }
}