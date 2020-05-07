@isTest
public class CICDBuildInitiator_TEST {
    //this boolean is flipped on after the master branch creation, so all the createBranch calls, are good!
    private class Mock implements HttpCalloutMock {
        boolean fullReponse = false;
        public HTTPResponse respond(HTTPRequest req) {
        	if (req.getEndpoint().contains('autoBuild')) {
                System.debug('this is the autoBuild MOCK');
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setBody('{"node_d":"MDM6UmVmMTM2NTI1MzI0Om1hc3Rlcg==", "object":{"sha":"3338770927db369f447cd4110bd9002fc63ff78c", "type":"commit", "url":"https://api.github.com/repos/department-of-veterans-affairs/va-salesforce-master/git/commits/3338770927db369f447cd4110bd9002fc63ff78c"}, "ref":"refs/heads/master", "url":"https://api.github.com/repos/department-of-veterans-affairs/va-salesforce-master/git/refs/heads/master"}');
                res.setStatus('OK');
                res.setStatusCode(200);
                System.debug('Mock-1-CICDBuildInitiator_TEST:Endpoint: '+req.getEndpoint()+
                             ' body: '+req.getBody()+' '+req.getMethod());
                return res;
            } else if (req.getEndpoint().contains('autoExtract')) {
                System.debug('this is the autoExtract MOCK');
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setBody('{"node_d":"MDM6UmVmMTM2NTI1MzI0Om1hc3Rlcg==", "object":{"sha":"3338770927db369f447cd4110bd9002fc63ff78c", "type":"commit", "url":"https://api.github.com/repos/department-of-veterans-affairs/va-salesforce-master/git/commits/3338770927db369f447cd4110bd9002fc63ff78c"}, "ref":"refs/heads/master", "url":"https://api.github.com/repos/department-of-veterans-affairs/va-salesforce-master/git/refs/heads/master"}');
                res.setStatus('OK');
                res.setStatusCode(200);
                System.debug('Mock-1-CICDBuildInitiator_TEST:Endpoint: '+req.getEndpoint()+
                             ' body: '+req.getBody()+' '+req.getMethod());
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
    }
    
    @isTest static void testBuildInitiator() {
        
        System.debug('1-inside testBuildInitiator...');
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        DTCDeploymentHandler_TEST.createModuleEnhancement();

        List<Id> erIds = new List<Id>();
        for (Application_Request__c er: [select Id from Application_Request__c where Deploy_Status__c = 'Deploy to ENTSD']) {
            erIds.add(er.Id);
        }
        System.debug('2-inside CICDBuildInitiator_TEST:testBuildInitiator:preparing to call Initiate a build with: '+erIds);
        
        Test.startTest();
        CICDBuildInitiator.executeBuild(erIds);
        System.debug('5-CICDBuildInitiator_TEST:testBuildInitiator---build request submitted');
        Test.stopTest();
    }
    
    @isTest static void testFlowBuildInitiator() {
        
        System.debug('10-inside testFlowBuildInitiator...');
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        DTCDeploymentHandler_TEST.createModuleEnhancement();

        List<String> erData = new List<String>();
        erData.add('ENTSD');
        erData.add('LHCAMP-ENH-000555');
        erData.add('Package_LHCAMP-ENH-000555.xml');
        erData.add('AutoBuild');
        erData.add('Release_19.9.1');
        List<List<String>> passedParms = new List<List<String>>();
        passedParms.add(erData);
        System.debug('12-inside CICDBuildInitiator_TEST:testBuildInitiator:preparing to call Initiate a build with: '+erData);
        
        Test.startTest();
        CICDBuildInitiator_FLOW.executeBuild_FLOW(passedParms);
        System.debug('15-CICDBuildInitiator_TEST:testBuildInitiator---build request submitted');
        Test.stopTest();
    }
    
    @isTest static void testExtractInitiator() {
        
        System.debug('1-inside testExtractInitiator...');
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        DTCDeploymentHandler_TEST.createModuleEnhancement();

        List<Id> erIds = new List<Id>();
        for (Application_Request__c er: [select Id from Application_Request__c where Deploy_Status__c = 'Extract Package']) {
            erIds.add(er.Id);
        }
        System.debug('2-inside CICDBuildInitiator_TEST:testExtractInitiator:preparing to call Initiate a build with: '+erIds);
        
        Test.startTest();
        CICDExtractInitiator.executeExtract(erIds);
        System.debug('5-CICDBuildInitiator_TEST:testExtractInitiator---build request submitted');
        Test.stopTest();
    }
    
    @isTest static void testCICDMergeInitiator() {
        
        System.debug('1-inside testMergeInitiator...');
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new Mock());
        
        DTCDeploymentHandler_TEST.createModuleEnhancement();

        List<Id> erIds = new List<Id>();
        for (Application_Request__c er: [select Id from Application_Request__c where Deploy_Status__c = 'Merge to Merge Branch']) {
            erIds.add(er.Id);
        }
        System.debug('2-inside CICDMergeInitiator:CICDMergeInitiator:preparing to call Initiate a merge with: '+erIds);
        
        Test.startTest();
        CICDMergeInitiator.executeMerge(erIds);
        System.debug('5-CICDMergeInitiator:testExtractInitiator---merge request submitted');
        Test.stopTest();
    }

}