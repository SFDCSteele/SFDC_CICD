#!/bin/bash
cp ./src/build/ant-salesforce.jar ~/.ant/ant/lib/
cp ./src/build/ant-contrib-1.0b3.jar ~/.ant/ant/lib/
#env
echo "builder.sh: branch is $CI_BRANCH---version 000.020---exit_code: $exit_code"
#the type of branch will setup type of deployment to perform
export multiDeploy=FALSE

if [ -z "$1" ]
then
    envIn=$CI_BRANCH
    IFS=',' read -ra envs <<< "$envIn"
    export multiDeploy=FALSE
else 
    envIn=$1
    IFS=',' read -ra envs <<< "$envIn"
    export multiDeploy=TRUE
fi

echo "Processing: $envIn"
for env in "${envs[@]}"; do
    export execute_deploy=FALSE
    if [ "$env" = "PROD" ]
    then
        echo "deploying to PROD"
        export envName=$PRODEnvName
        export serverURL=$PRODServerURL
        export username=$PRODUsername
        export password=$PRODPassword
        export check_deploy="-Dcheck=true"
        export packageXML=Package_ALL.xml
        export release_branch=$releaseBranch
        export dev_branch=$releaseBranch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [ "$env" = "Staging" ]
    then
        echo "deploying to staging"
        export envName=$STAGINGEnvName
        export serverURL=$STAGINGServerURL
        export username=$STAGINGUsername
        export password=$STAGINGPassword
        export check_deploy=""
        export packageXML=Package_ALL.xml
        export release_branch=$releaseBranch
        export dev_branch=$releaseBranch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ "$env" =~ .*UAT_.* ]]
    then
        echo "deploying to UAT"
        export envName=$UATEnvName
        export serverURL=$UATServerURL
        export username=$UATUsername
        export password=$UATPassword
        export check_deploy=""
        export packageXML=Package_ALL.xml
        export release_branch=$releaseBranch
        export dev_branch=$releaseBranch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ "$env" =~ .*ISITDTC_.* ]]
    then
        echo "deploying to ISITDTC"
        export envName=$ISITDTCEnvName
        export serverURL=$ISITDTCServerURL
        export username=$ISITDTCUsername
        export password=$ISITDTCPassword
        export check_deploy=""
        export packageXML=Package_ALL.xml
        export release_branch=$releaseBranch
        export dev_branch=$releaseBranch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ "$env" = "PRODMIRROR" ]]
    then
        echo "deploying to PRODMIRROR"
        export envName=$PRODMIRROREnvName
        export serverURL=$PRODMIRRORServerURL
        export username=$PRODMIRRORUsername
        export password=$PRODMIRRORPassword
        export check_deploy=""
        export packageXML=Package_ALL.xml
        export release_branch=$releaseBranch
        export dev_branch=$releaseBranch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ "$env" = "TUAT" ]]
    then
        echo "deploying to TUAT"
        export envName=$TUATEnvName
        export serverURL=$TUATServerURL
        export username=$TUATUsername
        export password=$TUATPassword
        export check_deploy=""
        export packageXML=Package_ALL.xml
        export release_branch=$releaseBranch
        export dev_branch=$releaseBranch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ ( "$env" = "Accenture" ) || ( "$env" = "Acumen" ) || ( "$env" = "DTCMerge" ) || ( "$env" = "OBPI" ) || ( "$env" = "VALERI" ) ]]
    then
        echo "deploying to ENTSD"
        export envName=$ENTSDEnvName
        export serverURL=$ENTSDServerURL
        export username=$ENTSDUsername
        export password=$ENTSDPassword
        export check_deploy=""
        export packageXML=Package_ALL.xml
        export release_branch=$releaseBranch
        export dev_branch=$releaseBranch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
        #
    elif [[ ( "$env" =~ .*-ENH-.* ) ]]
    then
        echo "deploying to ENTSD"
        export envName=$ENTSDEnvName
        export serverURL=$ENTSDServerURL
        export username=$ENTSDUsername
        export password=$ENTSDPassword
        export check_deploy=""
        export packageXML="Package_$env.xml"
        export release_branch=$releaseBranch
        export dev_branch=$env
        export deploy_type="PACKAGE"
        export perform_merge="true"
        export execute_deploy=TRUE
        #
    fi
    #
    export deployLocation=$REPO_LOCATION/deploy
    export repoLocation=$REPO_LOCATION
    export deployFullLocation=$REPO_LOCATION/deploy
    export repoFullLocation=$REPO_LOCATION
    ls -al "$repoLocation/src/build/Releases/$release_branch/$packageXML"
    if [ ! -f "$repoLocation/src/build/Releases/$release_branch/$packageXML" ]
    then
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "Package.xml $packageXML does not exists---no deployment will be attempted!"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        export execute_deploy=FALSE
    fi
    if [ "$execute_deploy" = "TRUE" ]
    then
        #
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        #
        echo "EnvName   $envName---"
        echo "serverURL $serverURL---"
        echo "username $username---"
        echo "release_branch  $release_branch---"
        echo "release_branch2 $releaseBranch2---"
        echo "dev_branch $dev_branch---"
        echo "packageXML $packageXML---"
        echo "Deploy type: $deploy_type----"
        echo "Perform merge: $perform_merge----"
        echo "Executing deploys: $execute_deploy----"
        #
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        #
        export CI_STATUS=Initiated
        ./src/build/buildMessage.sh buildStatus
        RESULT=$?
        echo "##############---before the deployment and RESULT = $RESULT"
        if [ "$deploy_type" = "FULL" ]
        then
            echo "Deploying the FULL package.... $1 $2 $3"
            ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DoneDeploy=true $check_deploy deploy-full
            RESULT=$?
            echo "##############-$deploy_type-Result is $RESULT..."
            if [ $RESULT -eq 0 ]; then
                export CI_STATUS=Success
            else
                export CI_STATUS=Failed
            fi
            export release_branch=$releaseBranch2
            #ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DflowsExtracted=true -DoneDeploy=true $1 $2  $3 deploy-full
        else
            echo "Deploying a single package.... $1 $2 $3"
            ./src/build/buildMessage.sh submitPackage $repoLocation/src/build/Releases/$release_branch/$packageXML
            ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DnoFlow=true -DoneDeploy=true deploy
            RESULT=$?
            echo "##############-$deploy_type-Result is $RESULT..."
            if [ $RESULT -eq 0 ]; then
                export CI_STATUS=Success
            else
                export CI_STATUS=Failed
            fi
            export release_branch=$releaseBranch2
            #mkdir $REPO_LOCATION/src/build/Releases/$releaseBranch2
            #ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DflowsExtracted=true -DoneDeploy=true $1 $2  $3 deploy
        fi
        ./src/build/buildMessage.sh buildStatus
        export release_branch=$releaseBranch
        if [ -f "$repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml" ]
        then
            echo "##############There is a destructive changes xml---deploying first#################"
            cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
            ant -propertyfile src/build/build.properties -buildfile src/build/build.xml undeployCode
        fi
    else
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "@@@@@@@ NO DEPLOY TO BE EXECUTED @@@@@@@@@@@"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    fi

done