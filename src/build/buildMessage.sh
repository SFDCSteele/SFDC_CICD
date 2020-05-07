#!/bin/bash
java -cp ./src/build/java/lib/\*:./src/build/java:. salesforce_rest.CICDRestClientV2 $1 $2 $3
if [ "$1" = "buildStatus" ]
then
    echo "{\"text\":\"*$buildType Build $CI_STATUS*\n*Build Id:*\t$CI_BUILD_ID\n*Deploy To*\t$envName\n*Branch:*\t$CI_BRANCH\n*Committer:*\t$CI_COMMITTER_NAME\"}" > msg.json
    cat msg.json
    curl -i -H 'Content-type: application/json' -X POST https://hooks.slack.com/services/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 --data-binary "@msg.json"
    curl -i -H 'Content-type: application/json' -X POST https://hooks.slack.com/services/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 --data-binary "@msg.json"
    #echo "#######Performing the second send of $1 ......"
    #echo "#######-------backuping up parms: CICD_LOGINURL: $CICD_LOGINURL..."
    export backup_CICD_LOGINURL=$CICD_LOGINURL
    export backup_CICD_USERNAME=$CICD_USERNAME
    export backup_CICD_PASSWORD=$CICD_PASSWORD
    #export CICD_LOGINURL=$ARCHDServerURL
    #export CICD_USERNAME=$ARCHDUsername
    #export CICD_PASSWORD=$ARCHDPassword
    echo "#######-------executing $1 with CICD_LOGINURL: $CICD_LOGINURL..."
    java -cp ./src/build/java/lib/\*:./src/build/java:. salesforce_rest.CICDRestClientV2 $1 $2 $3
    export CICD_LOGINURL=$backup_CICD_LOGINURL
    export CICD_USERNAME=$backup_CICD_USERNAME
    export CICD_PASSWORD=$backup_CICD_PASSWORD
    echo "#######-------reset CICD_LOGINURL: $CICD_LOGINURL..."
fi