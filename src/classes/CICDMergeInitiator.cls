global with sharing class CICDMergeInitiator {

    global static String GitHub_Access_Token = '';
    global static String Jenkins_Access_Token = '';
    global static String Jenkins_Password = '';
    global static String Jenkins_User = '';
    global static String Jenkins_URL = '';
    
    global static String submitMergeRequest(String fromBranch,String toBranch ) {
        
        String returnMessage = 'Deploy Requested';
        String body = 'buildPrefix=1000&fromBranch='+fromBranch+'&toBranch='+toBranch;
        
        System.debug('1-submitMergeRequest: deploying with these parameters: '+body+' Jenkins_Access_Token: '+Jenkins_Access_Token);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        try {
            String authStr = Jenkins_User +':'+Jenkins_Access_Token;
            request.setMethod('POST');
            request.setEndpoint('http://'+authStr+'@'+Jenkins_URL+'/buildWithParameters?'+body);
	        System.debug('2-submitMergeRequest:Endpoint: '+'http://'+authStr+'@'+Jenkins_URL+'/buildWithParameters?'+
                         'body: '+body);
    
            HttpResponse response = http.send(request);
            System.debug('3-submitMergeRequest:response: '+response.getStatus()+' code: '+response.getStatusCode());
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                System.debug('4-submitMergeRequest:There was an error with the request: '+body+' error: '+response.getStatus());
                returnMessage = response.getStatus();
            }        
        } catch (Exception e) {
	        System.debug('5-submitMergeRequest:exception: '+e.getMessage());
            returnMessage = e.getMessage();
        }
        return returnMessage;
    }
    
    @InvocableMethod(label='Submit Jenkins Merge' description='Submits a parameterized merge request to Jenkins')
    global static void executeMerge(List<Id> erIds) {
        System.debug('Inside executeMerge: erIds: '+erIds);
        List<Application_Request__c> ers = new List<Application_Request__c>();
        List<String> fromBranches = new List<String>();
        List<String> toBranches = new List<String>();
        try {
	        System.debug('executeMerge: executing query');
            ers = [select Id,Deploy_Status__c,Deploy_Branch__c,Merge_Branch_Name__c,Deploy_Release_Branch__c from Application_Request__c
                   where Id IN: erIds AND Deploy_Status__c LIKE 'Merge to %'];
	        System.debug('executeMerge: query found: '+ers.size()+' => '+ers);
            for ( Application_Request__c er: ers ) {
                System.debug('executeMerge: envName: '+er.Deploy_Status__c.split(' ')[2]+
                             ' requestedBranch: '+er.Deploy_Branch__c+' Merge_Branch_Name__c: '+er.Merge_Branch_Name__c+
                             ' Deploy_Release_Branch__c: '+er.Deploy_Release_Branch__c);
                if ( er.Deploy_Status__c == 'Merge to Merge Branch') {
                    fromBranches.add(er.Deploy_Branch__c);
                    toBranches.add(er.Merge_Branch_Name__c);
                } else if ( er.Deploy_Status__c == 'Merge to Release Branch') {
                    fromBranches.add(er.Merge_Branch_Name__c);
                    toBranches.add(er.Deploy_Release_Branch__c);
                }
            }
            if ( ers.size() > 0 ) {
		        processMerge(fromBranches,toBranches);
            }
        }
        Catch(Exception e) {
            system.debug('Error While requesting a deploy in Jenkins: '+e.getMessage());
        }                
    }
    
    @future(callout=true)
    global static void processMerge(List<String> fromBranches,List<String> toBranches) {
        String fromBranch = '';
        String toBranch = ''; 
        String returnMessage = '';
        System.debug('Inside processMerge: fromBranches: '+fromBranches+' toBranches: '+toBranches);
                
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
            Jenkins_URL = ddp[0].Jenkins_Merge_URL__c;
        }  catch (Exception e) {
            System.debug('CICDMergeInitiator:processMerge: error seting gitHub parameters: '+e.getMessage());
        }
        if(Test.isRunningTest()){
	        GitHub_Access_Token = '1231231231234';
	        Jenkins_Access_Token = '1231231231234';
            Jenkins_Password = 'password';
            Jenkins_User = 'autoBuild';
            Jenkins_URL = 'http://localhost:8080';
        } 
        for (integer i=0;i<fromBranches.size();i++ ) {
            fromBranch = fromBranches[i];
            toBranch = toBranches[i];
            System.debug('Calling submitMergeRequest: fromBranches: '+fromBranches);
            returnMessage = submitMergeRequest(fromBranch,toBranch);
            System.debug('returning from submitMergeRequest: returnMessage: '+returnMessage);
        }

        System.debug('0-processMerge:returnMessage: '+returnMessage);
    }

}