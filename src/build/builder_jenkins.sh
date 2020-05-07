#!/bin/bash
#Potential passed in parameters:
# 1 - build Id prefix, which is AUTO for automated build or PARM for parameterized build
# 2 - a specific environment name (otherwise we'll use the branch name to determine where)
# 3 = the branch that is to be used
# 4 - if a specific package.xml is to be used
# 5 - if this is a paramterized build from Jenkins itself or a manual deploy, this can be the user that kicked it off
# 6 - if there are extract deployment parameters like -Dcheck=true, they would be in this parameter
# 7 - current release that can be altered based on input
#env
echo "==========================================================================="
export GITBRANCH="$(cut -d/ -f2 <<<$GIT_BRANCH)"
export CI_BRANCH=$GITBRANCH
export CHECK=FALSE
export CLEAN=FALSE
export QUIET=FALSE
export DEBUG=FALSE
export SECOND=FALSE
export PERFORMDEPLOY=TRUE
export BUILD_INITIATED="Initiated"
export BUILD_SUCCESS="Success"
export BUILD_FAILED="Failed"
export addtl_deploy_parms=""
export build_increment=""

if [ "$1" = "CLEAN"]
then
    export CLEAN=TRUE
fi

if [[ ("$JOB_BASE_NAME" =~ .*_Auto_.* )]]
then
    export buildType="AUTO"
else
    export buildType="PARAMETERIZED"
fi
if [[ (  "$6" =~ .*-Dquiet=true.* ) ]]
then
    export QUIET=TRUE
    export addtl_deploy_parms="-DnoFlow=true"
fi
if [[ (  "$6" =~ .*-Ddebug=true.* ) ]]
then
    export DEBUG=TRUE
fi
if [[ (  "$6" =~ .*-Dsecond=true.* ) ]]
then
    export SECOND=TRUE
fi
if [[ (  "$6" =~ .*-Ddeploy=false.* ) ]]
then
    export PERFORMDEPLOY=FALSE
fi
source /var/lib/jenkins/workspace/SFDC/setEnv.sh
GIT_NAME=$(git --no-pager show -s --format='%an' $GIT_COMMIT)
GIT_EMAIL=$(git --no-pager show -s --format='%ae' $GIT_COMMIT)
export CI_COMMITTER_NAME="${GIT_NAME//[[:space:]]/}"
echo "@@@@@@@     CI_COMMITTER_NAME: $CI_COMMITTER_NAME  GIT_EMAIL: $GIT_EMAIL @@@@@@@@@@@@@@@ "
echo "#####builder_jenkins.sh: branch is $GITBRANCH---version 000.130...($ANT_HOME)...(GIT COMMITTER: $CI_COMMITTER_NAME)..."
echo "==========================================================================="
whoami
#ls -al
#pwd
if [ -z "$7" ]
then
    export release_branch=$releaseBranch
    export releaseBranch2="${release_branch:0:${#release_branch}-1}2"
else
    export release_branch=$7
fi
export CI_BUILD_ID_START="$CI_BUILD_ID"
export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
echo "==========================================================================="
echo "values passed in:"
echo "Build Type: $1 - $CI_BUILD_ID originial: $BUILD_ID start: $CI_BUILD_ID_START"
echo "Environment: $2"
echo "Requested Branch: $3"
echo "Package: $4"
echo "Committer: $5 (GIT COMMITTER: $CI_COMMITTER_NAME)"
echo "Build Parameters: $6"
echo "CurrentRelease: $release_branch"
echo "QUIET: $QUIET"
echo "==========================================================================="
#the type of branch will setup type of deployment to perform
export multiDeploy=FALSE

#if $2 is empty, we use the branch to determine how to build (non-parameterized build)
#if $2 is not empty, we are assuming an environment was passed in
if [ -z "$2" ]
then
    envIn=$GITBRANCH
    IFS=',' read -ra envs <<< "$envIn"
    export multiDeploy=FALSE
else 
    envIn=$2
    IFS=',' read -ra envs <<< "$envIn"
    export multiDeploy=TRUE
fi
if [[ (-z "$CI_COMMITTER_NAME") && ( ! -z "$5") ]]
then
    export CI_COMMITTER_NAME=$5
    echo "setting from input:Committer: $5 (GIT COMMITTER: $CI_COMMITTER_NAME)"
fi
echo "Processing: $envIn"
for env in "${envs[@]}"; do
    export execute_deploy=FALSE
    if [ "$env" = "PROD" ]
    then
        if [ -z "$2" ]
        then
            export envName="PROD"
        fi
        export deploy_parms="-Dcheck=true"
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [ "$env" = "STAGING" ]
    then
        if [ -z "$2" ]
        then
            export envName="STAGING"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ ("$env" =~ .*UAT_.* ) || ( "$env" = "UAT" ) ]]
    then
        if [ -z "$2" ]
        then
            export envName="UAT"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ "$env" =~ .*ISITDTC_.* ]]
    then
        if [ -z "$2" ]
        then
            export envName="ISITDTC"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ "$env" = "PRODMIRROR" ]]
    then
        if [ -z "$2" ]
        then
            export envName="PRODMIRROR"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ "$env" = "DEPLOYTEMP" ]]
    then
        if [ -z "$2" ]
        then
            export envName="DEPLOYTEMP"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ ("$env" = "TUAT") ]]
    then
        if [ -z "$2" ]
        then
            export envName="TUAT"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ ("$env" = "TRAINING") ]]
    then
        if [ -z "$2" ]
        then
            export envName="TRAINING"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ ( "$env" = "TEAMDEV1" ) || ( "$env" = "TEAMDEV2" ) || ( "$env" = "TEAMDEV3" ) || ( "$env" = "ENTSDVAPM" )  ]]
    then
        echo "setting up to deploy to $env..."
        if [ -z "$2" ]
        then
            export envName="$env"
        fi
        export deploy_parms=" -DnoFlow=true "
        export packageXML="Package_$CI_BRANCH.xml"
        export release_branch=$release_branch
        export dev_branch=$CI_BRANCH
        export deploy_type="PACKAGE"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ ("$env" = "SFDCTEST") ]]
    then
        #echo "deploying to SFDCTEST"
        if [ -z "$2" ]
        then
            export envName="SFDCTEST"
        fi
        export deploy_parms=""
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
    elif [[ ( "$env" = "Accenture" ) || ( "$env" = "Acumen" ) || ( "$env" = "DTCMerge" ) || ( "$env" = "OBPI" ) || ( "$env" = "VALERI" )  || ( "$env" = "CARMAQA" )]]
    then
        #echo "deploying to ENTSD.full"
        if [ -z "$2" ]
        then
            export envName="ENTSD"
        fi
        #export envName=$ENTSDEnvName
        #export serverURL=$ENTSDServerURL
        #export username=$ENTSDUsername
        #export password=$ENTSDPassword
        export deploy_parms="-DnoFlow=true"
        export packageXML=Package_ALL.xml
        export release_branch=$release_branch
        export dev_branch=$release_branch
        export deploy_type="FULL"
        export perform_merge="false"
        export execute_deploy=TRUE
        #
    elif [[ ( "$env" = "UATVAPM" ) || ( "$env" = "VAPM" ) || ( "$env" = "STAGEVAPM" ) || ( "$env" = "CTALBOTVA" ) || ( "$env" = "CARMA2PKG" ) || ( "$env" = "SSOeSQA" ) || ( "$env" = "1118backup" ) ]]
    then
        echo "deploying to $env"
        #export envName=$ENTSDEnvName
        export deploy_parms=" -DnoFlow=true "
        export packageXML="Package_$env.xml"
        export release_branch=$release_branch
        export dev_branch=$env
        export deploy_type="PACKAGE"
        export perform_merge="true"
        export execute_deploy=TRUE
        #
    elif [[ ( "$env" = "CARMA2PKG" ) || ( "$env" = "CARMA-ENH-000690_2" ) || ( "$env" = "CARMAPAYMNT" ) ]]
    then
        export envName="$env"
        echo "deploying to $env"
        export deploy_parms=" -DnoFlow=true "
        export packageXML="$4"
        export release_branch=$release_branch
        export dev_branch="$3"
        export deploy_type="PACKAGE"
        export perform_merge="true"
        export execute_deploy=TRUE
        #
    elif [[ ( "$env" =~ .*-ENH-.* ) || ( "$env" = "ENTSD" ) ]]
    then
        echo "deploying to ENTSD.single"
        if [ -z "$2" ]
        then
            export envName="ENTSD"
        fi
        java -cp ./src/build/java/lib/\*:./src/build/java:. salesforce_rest.CICDRestClientV2 getSandboxName $env
        #cat setSystem
        source setSystem
        echo "deployToSIT=$deployToSIT"
        echo "sitEnvName=$sitEnvName"
        echo "============================================"
        if [ "$deployToSIT" = "true" ]
        then
            export envName=$sitEnvName
        else
            export envName="ENTSD"
        fi
        rm -rf setSystem
        export deploy_parms=" -DnoFlow=true "
        export packageXML="Package_$env.xml"
        export release_branch=$release_branch
        export dev_branch=$env
        export deploy_type="PACKAGE"
        export perform_merge="true"
        export execute_deploy=TRUE
        #
    fi
    #branch was passed in, so use it for the dev branch
    if [ ! -z "$3" ]
    then
        export dev_branch=$3
    fi
    #package.xml was specified, so set the name and the fact it is a package deploy
    #also, if its ENTSD, we don't need to check flows, so set it to noFlow
    if [ ! -z "$4" ]
    then
        export packageXML=$4
        export deploy_type="PACKAGE"
        if [[ ( "$env" = "ENTSD" ) ]]
        then 
            export deploy_parms=" -DnoFlow=true "
        else
            export deploy_parms=""
        fi
    fi
    #if deploy parms were passed in, add them to anything we've set already
    if [ ! -z "$6" ]
    then
        parmIn=$6
        
        IFS=',' read -ra parms <<< "$parmIn"
        echo "Processing: $parmIn"
        for parm in "${parms[@]}"; do
        export deploy_parms="$deploy_parms $6"
        done
    fi
    #if the package.xml is ALL, this is a full deploy
    if [ "$packageXML" = "Package_ALL.xml" ]
    then
        export deploy_type="FULL"
    fi
    #if deploy parms were passed in as check=true--setup for a validation deploy
    if [[ ( "$deploy_parms" =~ .*-Dcheck=true.* ) ]]
    then
        export addtl_deploy_parms="-DnoFlow=true"
        export BUILD_INITIATED="Validation Initiated"
        export BUILD_SUCCESS="Validation Success"
        export BUILD_FAILED="Validation Failed"
        export CHECK=TRUE
    #if deploy parms were passed in as destroy=true--setup for a destructiveChanges deploy
    elif [[ ( "$deploy_parms" =~ .*-Ddestroy=true.* ) ]]
    then
        export deploy_type="DESTROY"
        export BUILD_INITIATED="DESTROY Initiated"
        export BUILD_SUCCESS="DESTROY Success"
        export BUILD_FAILED="DESTROY Failed"
    #if the deploy is only to create the deployment files, set the appropriate parameters
    elif [[ ( "$PERFORMDEPLOY" = "FALSE" ) ]]
    then
        export deploy_parms=" -DnoFlow=true "
        export addtl_deploy_parms="-DperformDeploy=false"
        export BUILD_INITIATED="Test Deploy Initiated"
        export BUILD_SUCCESS="Test Deploy Success"
        export BUILD_FAILED="Test Deploy Failed"
    fi
    export deployLocation=$WORKSPACE/deploy
    export repoLocation=$WORKSPACE
    export deployFullLocation=$WORKSPACE/deploy
    export repoFullLocation=$WORKSPACE
    export CI_MESSAGE=$GIT_TAG_MESSAGE
    /var/lib/jenkins/workspace/SFDC/build/updateBuild.sh

    echo "%%%%%%%%%%%%%%%%%%%execute_deploy: $execute_deploy QUIET: $QUIET..."
    echo "&&&&Repo location: $repoLocation"

    if [[ ("$DEBUG" = "TRUE") ]]
    then
        export addtl_deploy_parms="-DskipApex=true"
    fi
    #if [[ ("$CLEAN" = "TRUE") || ( -f "$repoLocation/src/package.xml" ) ]]
    if [[ ("$CLEAN" = "TRUE") ]]
    then
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "This ia a CLEAN and MERGE JOB -- branch $2 will be merged into branch $3"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        export execute_deploy=FALSE
        rm -rf $repoLocation/src/package.xml
        rm -rf $repoLocation/build.properties
        rm -rf $repoLocation/build.xml
        rm -rf deploy
        git status
        git branch
        echo "============================================"

        #git add .
        #git commit -m "Cleaning up branch to prepare for automerge"
        #git push origin $GIT_BRANCH
    else
        ./src/build/getEnv.sh getEnvironmentDetails $envName
        source setSystem
        rm setSystem
    fi
    
    if [ -f "$repoLocation/src/build/Releases/$releaseBranch2/$packageXML" ]
    then
        export build_increment=".1"
    fi

    #ls -al $repoLocation/src/build
    #ls -al $repoLocation/src/build/Releases
    #ls -al $repoLocation/src/build/Releases/$release_branch
    #ls -al "$repoLocation/src/build/Releases/$release_branch/$packageXML"
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
        echo "QUIET: $QUIET----"
        echo "DEBUG: $DEBUG----"
        echo "SECOND: $SECOND----"
        echo "PERFORMDEPLOY: $PERFORMDEPLOY----"
        echo "Perform merge: $perform_merge----"
        echo "Executing deploys: $execute_deploy----"
        echo "Deploy Parameters: $deploy_parms----"
        echo "Additional deploy Parameters: $addtl_deploy_parms----"
        echo "GIT commit message: $CI_MESSAGE-----"
        echo "CI_COMMITTER_NAME: $CI_COMMITTER_NAME  GIT_EMAIL: $GIT_EMAIL @@@@@@@@@@@@@@@ "
        #
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        #
        export CI_STATUS=$BUILD_INITIATED
        RESULT=$?
        echo "##############---before the deployment and RESULT = $RESULT"
        if [ "$deploy_type" = "FULL" ]
        then
            if [ "$SECOND" = "FALSE" ]
            then
                if [ "$QUIET" = "FALSE" ]
                then
                    export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                    ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch
                else
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                fi
                echo "############## Looking for PRE destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml") ]]
                then
                    echo "##############There is a PRE destructive changes xml---deploying first#################"
                    cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                    export destroyPackage="destructiveChangesPre.xml"
                    $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -DdestructPre=true undeployCode
                else
                    echo "############## No PRE destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                fi
                echo "Deploying (SECOND==$SECOND) the FULL package ####1.... $1 $2 $4"
                $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DoneDeploy=true $deploy_parms $addtl_deploy_parms deploy-full
                RESULT=$?
                echo "##############-Main deploy: $deploy_type-Result is $RESULT..."
                if [ $RESULT -eq 0 ]; then
                    export CI_STATUS=$BUILD_SUCCESS
                else
                    export CI_STATUS=$BUILD_FAILED
                fi
                if [[ ("$DEBUG" = "TRUE") ]]
                then
                    ls -al $repoLocation/src/build/Releases/$release_branch
                    ls -al $repoLocation/src/build/Releases
                    ls -al $repoLocation/src/build
                    ls -al $repoLocation/src
                    cat $repoLocation/src/package.xml
                    ls -al $repoLocation
                    cat $repoLocation/full_build.xml
                fi
                if [ "$QUIET" = "FALSE" ]
                then
                    export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                    ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch
                else
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                fi
                export CI_STATUS=$BUILD_INITIATED
                echo "############## Looking for POST destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
                if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml") ]]
                then
                    echo "##############There is a POST destructive changes xml---deploying first#################"
                    cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                    export destroyPackage="destructiveChanges.xml"
                    $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml undeployCode
                else
                    echo "############## No POST destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
                fi
            else
                echo "MESSAGING: SECOND: $SECOND skipped the primary deploy..."
            fi
            echo "############## LOOKING FOR SECONDARY DEPLOY: $repoLocation/src/build/Releases/$releaseBranch2/Package_*-ENH-*.xml  #######################"
            ls -al $repoLocation/src/build/Releases/$releaseBranch2/Package_*-ENH-*.xml
            #if [ -f "$repoLocation/src/build/Releases/$releaseBranch2/$packageXML" ]
            #if [[ ( "$SECOND" = "TRUE" ) ]]
            #if [[ ( ( -f $repoLocation/src/build/Releases/$releaseBranch2/Package_*-ENH-*.xml ) || ( "$SECOND" = "TRUE" ) ) && ( "$CHECK" = "FALSE" ) ]]
            if [[ ("$CHECK" = "FALSE") || ( "$SECOND" = "TRUE" ) ]]
            then
                if ls $repoLocation/src/build/Releases/$releaseBranch2/Package_*-ENH-*.xml 1> /dev/null 2>&1;
                then
                    export build_increment=".2"
                    export release_branch=$releaseBranch2
                    echo "############## Looking for PRE destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                    if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml") && ( "$CHECK" = "FALSE" ) ]]
                    then
                        echo "##############There is a PRE destructive changes xml---deploying first#################"
                        cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                        export destroyPackage="destructiveChangesPre.xml"
                        $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -DdestructPre=true undeployCode
                    else
                        echo "############## No PRE destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                    fi
                    if [ "$QUIET" = "FALSE" ]
                    then
                        export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                        echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                        ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch
                    else
                        echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                    fi
                    echo "Deploying the FULL package ####2.... $1 $2 $4"
                    ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DflowsExtracted=true -DoneDeploy=true $deploy_parms $addtl_deploy_parms deploy-full
                    RESULT=$?
                    echo "##############-Second deploy: $deploy_type-Result is $RESULT..."
                    if [ $RESULT -eq 0 ]; then
                        export CI_STATUS=$BUILD_SUCCESS
                    else
                        export CI_STATUS=$BUILD_FAILED
                    fi
                    if [ "$QUIET" = "FALSE" ]
                    then
                        export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                        echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                        ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch
                    else
                        echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                    fi
                    export CI_STATUS=$BUILD_INITIATED
                    echo "############## Looking for POST destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
                    if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml") && ( "$CHECK" = "FALSE" ) ]]
                    then
                        echo "##############There is a destructive changes xml---deploying first#################"
                        export destroyPackage="destructiveChanges.xml"
                        cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                        $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml undeployCode
                    else
                        echo "############## No POST destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
                    fi
                    export release_branch=$releaseBranch
                else
                    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                    echo "@@@ NO SECONDARY Package.xml $releaseBranch2/Package_*-ENH-*.xml --no deployment will be attempted!"
                    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                fi
            fi
        elif [ "$deploy_type" = "DESTROY" ]
        then
            if [ "$QUIET" = "FALSE" ]
            then
                export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch
            fi
            echo "############## Looking for PRE destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
            if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml") && ($deploy_parms != "-Dcheck=true")]]
            then
                echo "##############There is a PRE destructive changes xml---deploying first#################"
                cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                export destroyPackage="destructiveChangesPre.xml"
                $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -DdestructPre=true -DdestructPre=true undeployCode
            else
                echo "############## No PRE destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
            fi
            echo "############## Looking for POST destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
            if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml") && ($deploy_parms != "-Dcheck=true")]]
            then
                echo "##############There is a POST destructive changes xml---deploying first#################"
                cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                export destroyPackage="destructiveChanges.xml"
                $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml undeployCode
                RESULT=$?
                echo "##############-Main deploy: $deploy_type-Result is $RESULT..."
            else
                echo "############## No POST destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
            fi
            echo "############## Looking for POST destructive changes xml--- $repoLocation/src/build/Releases/$releaseBranch2/destructiveChanges.xml #################"
            if [[ (-f "$repoLocation/src/build/Releases/$releaseBranch2/destructiveChanges.xml") && ($deploy_parms != "-Dcheck=true")]]
            then
                export release_branch=$releaseBranch2
                echo "############## Looking for PRE destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml") && ($deploy_parms != "-Dcheck=true")]]
                then
                    echo "##############There is a PRE destructive changes xml---deploying first#################"
                    cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                    export destroyPackage="destructiveChangesPre.xml"
                    $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -DdestructPre=true undeployCode
                else
                    echo "############## No PRE destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                fi
                echo "##############There is a POST destructive changes xml---deploying first#################"
                cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                export destroyPackage="destructiveChanges.xml"
                $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml undeployCode
                export release_branch=$releaseBranch
            else
                echo "############## No POST destructive changes xml at $repoLocation/src/build/Releases/$releaseBranch2/destructiveChanges.xml #################"
            fi
            export CI_STATUS=$BUILD_INITIATED
        else
            echo "Deploying a single package.... $1 $2 $3"
            if [ "$QUIET" = "FALSE" ]
            then
                export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch/$packageXML
            fi
            ./src/build/buildMessage.sh submitPackage $repoLocation/src/build/Releases/$release_branch/$packageXML
            echo "############## Looking for PRE destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
            if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml") && ($deploy_parms != "-Dcheck=true")]]
            then
                echo "##############There is a PRE destructive changes xml---deploying first#################"
                cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                export destroyPackage="destructiveChangesPre.xml"
                $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -DdestructPre=true undeployCode
            else
                echo "############## No PRE destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
            fi
            if [ "$SECOND" = "FALSE" ]
            then
                echo "Deploying (SECOND==$SECOND) the PACKAGE ####1.... $1 $2 $4"
                $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DoneDeploy=true $deploy_parms $addtl_deploy_parms deploy
                RESULT=$?
                echo "##############-$deploy_type-Result is $RESULT..."
                if [ $RESULT -eq 0 ]; then
                    export CI_STATUS=$BUILD_SUCCESS
                else
                    export CI_STATUS=$BUILD_FAILED
                fi
                if [[ ("$DEBUG" = "TRUE") ]]
                then
                    ls -al $repoLocation/src/build/Releases/$release_branch
                    ls -al $repoLocation/src/build/Releases
                    ls -al $repoLocation/src/build
                    ls -al $repoLocation/src
                    cat $repoLocation/src/package.xml
                    ls -al $repoLocation
                    cat $repoLocation/full_build.xml
                fi
                if [ "$QUIET" = "FALSE" ]
                then
                    export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                    ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch/$packageXML
                else
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                fi
            else
                echo "MESSAGING: SECOND: $SECOND skipped the primary deploy..."
            fi
            export CI_STATUS=$BUILD_INITIATED
            echo "############## Looking for POST destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
            if [ -f "$repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml" ]
            then
                echo "##############There is a POST destructive changes xml---deploying first#################"
                cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                export destroyPackage="destructiveChanges.xml"
                $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml undeployCode
            else
                echo "############## No POST destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
            fi
            if [ -f "$repoLocation/src/build/Releases/$releaseBranch2/$packageXML" ]
            then
                export build_increment=".2"
                export release_branch=$releaseBranch2
                echo "############## Looking for PRE destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                if [[ (-f "$repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml") && ($deploy_parms != "-Dcheck=true")]]
                then
                    echo "##############There is a PRE destructive changes xml---deploying first#################"
                    cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                    export destroyPackage="destructiveChangesPre.xml"
                    $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -DdestructPre=true undeployCode
                else
                    echo "############## No PRE destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChangesPre.xml #################"
                fi
                if [ "$QUIET" = "FALSE" ]
                then
                    export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                    ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch
                else
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                fi
                ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -DflowsExtracted=true -DoneDeploy=true $deploy_parms $addtl_deploy_parms deploy
                RESULT=$?
                echo "##############-Main deploy: $deploy_type-Result is $RESULT..."
                if [ $RESULT -eq 0 ]; then
                    export CI_STATUS=$BUILD_SUCCESS
                else
                    export CI_STATUS=$BUILD_FAILED
                fi
                if [ "$QUIET" = "FALSE" ]
                then
                    export CI_BUILD_ID="$1$CI_BUILD_ID_START$build_increment"
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                    ./src/build/buildMessage.sh buildStatus $deploy_type $repoLocation/src/build/Releases/$release_branch/$packageXML
                else
                    echo "MESSAGING: DEPLOY_TYPE: $deploy_type CI_STATUS: $CI_STATUS QUIET: $QUIET..."
                fi
                export CI_STATUS=$BUILD_INITIATED
                echo "############## Looking for POST destructive changes xml--- $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
                if [ -f "$repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml" ]
                then
                    echo "##############There is a POST destructive changes xml---deploying first#################"
                    cp -v $repoLocation/src/build/destructiveChanges_Package.xml $repoLocation/src/build
                    export destroyPackage="destructiveChanges.xml"
                    $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml undeployCode
                else
                    echo "############## No POST destructive changes xml at $repoLocation/src/build/Releases/$release_branch/destructiveChanges.xml #################"
                fi
                export release_branch=$releaseBranch
            else
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
                echo "@@@ NO SECONDARY Package.xml $releaseBranch2/$packageXML --no deployment will be attempted!"
                echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
            fi
        fi
    else
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "@@@@@@@ NO DEPLOY TO BE EXECUTED: Execute Deploy: $execute_deploy @@@@@@@@@@@"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    fi

done
