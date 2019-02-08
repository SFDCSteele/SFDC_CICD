#!/bin/bash
cp ./src/build/ant-salesforce.jar ~/.ant/ant/lib/
cp ./src/build/ant-contrib-1.0b3.jar ~/.ant/ant/lib/
env
echo "builder.sh: branch is $CI_BRANCH"
#add a while look here to take a list of environments to loop through
if [ "$CI_BRANCH" = "Staging" ]
then
    echo "deploying to staging"
    export envName=$STAGINGEnvName
    export serverURL=$STAGINGServerURL
    export username=$STAGINGUsername
    export password=$STAGINGPassword
    export packageXML=Package_ALL.xml
elif [[ "$CI_BRANCH" = .UAT-.* ]]
then
    echo "deploying to UAT"
    export envName=$UATEnvName
    export serverURL=$UATServerURL
    export username=$UATUsername
    export password=$UATPassword
    export packageXML=Package_ALL.xml
elif [[ "$CI_BRANCH" = .ISITDTC-.* ]]
then
    echo "deploying to ISITDTC"
    export envName=$ISITDTCEnvName
    export serverURL=$ISITDTCServerURL
    export username=$ISITDTCUsername
    export password=$ISITDTCPassword
    export packageXML=Package_ALL.xml
else
    echo "deploying to ENTSD"
    export envName=$ENTSDEnvName
    export serverURL=$ENTSDServerURL
    export username=$ENTSDUsername
    export password=$ENTSDPassword
    export release_branch=$releaseBranch
    #
    if [[ "$CI_BRANCH" =~ .*-ENH-.* ]]
    then
        export packageXML="Package_$CI_BRANCH.xml"
    else
        export packageXML=Package_ALL.xml
    fi
    export dev_branch=$CI_BRANCH
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
#
export deployLocation=$REPO_LOCATION/deploy
export repoLocation=$REPO_LOCATION
export deployFullLocation=$REPO_LOCATION/deploy
export repoFullLocation=$REPO_LOCATION
#
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
#
if [ "$1" = "FULL" ]
then
    echo "Deploying the FULL package...."
    ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  deploy-full
else
    echo "Deploying a single package...."
    ant -propertyfile src/build/build.properties -buildfile src/build/build.xml deploy
fi
