#!/bin/bash
which ant
ls -al ~/.ant
cp ./src/build/ant-salesforce.jar ~/.ant/ant/lib/
cp ./src/build/ant-contrib-1.0b3.jar ~/.ant/ant/lib/
env
echo "builder.sh: branch is $CI_BRANCH---version 000.013"
#the type of branch will setup type of deployment to perform
if [ "$CI_BRANCH" = "Staging" ]
then
    echo "deploying to staging"
    export envName=$STAGINGEnvName
    export serverURL=$STAGINGServerURL
    export username=$STAGINGUsername
    export password=$STAGINGPassword
    export packageXML=Package_ALL.xml
    export release_branch=$releaseBranch
    export dev_branch=$releaseBranch
    export deploy_type="FULL"
    export perform_merge="false"
elif [[ "$CI_BRANCH" =~ .UAT_.* ]]
then
    echo "deploying to UAT"
    export envName=$UATEnvName
    export serverURL=$UATServerURL
    export username=$UATUsername
    export password=$UATPassword
    export packageXML=Package_ALL.xml
    export release_branch=$releaseBranch
    export dev_branch=$releaseBranch
    export deploy_type="FULL"
    export perform_merge="false"
elif [[ "$CI_BRANCH" =~ .ISITDTC_.* ]]
then
    echo "deploying to ISITDTC"
    export envName=$ISITDTCEnvName
    export serverURL=$ISITDTCServerURL
    export username=$ISITDTCUsername
    export password=$ISITDTCPassword
    export packageXML=Package_ALL.xml
    export release_branch=$releaseBranch
    export dev_branch=$releaseBranch
    export deploy_type="FULL"
    export perform_merge="false"
elif [[ ( "$CI_BRANCH" = "Accenture" ) || ( "$CI_BRANCH" = "Acumen" ) || ( "$CI_BRANCH" = "DTCMerge" ) || ( "$CI_BRANCH" = "OBPI" ) ]]
then
    echo "deploying to ENTSD"
    export envName=$ENTSDEnvName
    export serverURL=$ENTSDServerURL
    export username=$ENTSDUsername
    export password=$ENTSDPassword
    export packageXML=Package_ALL.xml
    export release_branch=$releaseBranch
    export dev_branch=$releaseBranch
    export deploy_type="FULL"
    export perform_merge="false"
    #
elif [[ ( "$CI_BRANCH" =~ .*-ENH-.* ) ]]
then
    echo "deploying to ENTSD"
    export envName=$ENTSDEnvName
    export serverURL=$ENTSDServerURL
    export username=$ENTSDUsername
    export password=$ENTSDPassword
    export packageXML="Package_$CI_BRANCH.xml"
    export release_branch=$releaseBranch
    export dev_branch=$CI_BRANCH
    export deploy_type="PACKAGE"
    export perform_merge="true"
    #
fi
#
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
#
echo "EnvName   $envName---"
echo "serverURL $serverURL---"
echo "username $username---"
echo "release_branch $release_branch---"
echo "dev_branch $dev_branch---"
echo "packageXML $packageXML---"
echo "Deploy type: $deploy_type----"
echo "Perform merge: $perform_merge----"
#
export deployLocation=$REPO_LOCATION/deploy
export repoLocation=$REPO_LOCATION
export deployFullLocation=$REPO_LOCATION/deploy
export repoFullLocation=$REPO_LOCATION
#
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
#
if [ "$deploy_type" = "FULL" ]
then
    echo "Deploying the FULL package...."
    #ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  deploy-full
    ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  git-config
else
    echo "Deploying a single package...."
    #ant -propertyfile src/build/build.properties -buildfile src/build/build.xml deploy
    ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  git-config
fi
