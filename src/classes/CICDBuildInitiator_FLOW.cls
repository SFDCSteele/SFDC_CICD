global with sharing class CICDBuildInitiator_FLOW {
    
    @InvocableMethod(label='Submit Jenkins Build from FLOW' description='Submits a parameterized build request to Jenkins from a User flow')
    global static void executeBuild_FLOW(List<List<String>> passedParms) {
        System.debug('Inside executeBuild_FLOW: envName: '+passedParms);
        List<String> envNames = new List<String>();
        List<String> requestedBranches = new List<String>();
        List<String> packageXMLs = new List<String>();
        List<String> committerNames = new List<String>();
        List<String> buildParameters = new List<String>();
        List<String> currentReleases = new List<String>();
        envNames.add(passedParms[0][0]);
        requestedBranches.add(passedParms[0][1]);
        packageXMLs.add(passedParms[0][2]);
        committerNames.add(passedParms[0][3]);
        currentReleases.add(passedParms[0][4]);
        try {
            System.debug('executeBuild_FLOW: submitting build request');
            if ( envNames.size() >= 1 ) {
                CICDBuildInitiator.processBuild(envNames,requestedBranches,packageXMLs,committerNames,currentReleases);
            }
        }
        Catch(Exception e) {
            system.debug('Error While requesting a deploy in Jenkins: '+e.getMessage());
        }                
    }

}