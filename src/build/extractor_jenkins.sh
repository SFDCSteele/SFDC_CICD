#!/bin/bash
#Potential passed in parameters:
# 1 - a specific environment name (otherwise we'll use the branch name to determine where)
# 2 - the branch that is to be used
# 3 - if a specific package.xml is to be used
# 4 - is the name of the changeset to be deployed
# 5 - is the commit message for the git push
#env
echo "==========================================================================="
echo "1-values passed in:"
echo "Environment: $1"
echo "Requested Branch: $2"
echo "Package: $3"
echo "ChangeSet: $4"
echo "CommitMessage: $5"
echo "CurrentRelease: $6"
echo "==========================================================================="
export GITBRANCH="$(cut -d/ -f2 <<<$GIT_BRANCH)"
export CI_BRANCH=$GITBRANCH
source /var/lib/jenkins/workspace/SFDC/setEnv.sh
echo "#####extractor_jenkins.sh: branch is $GITBRANCH---version 000.026...($ANT_HOME)..."
echo "==========================================================================="
whoami
ls -al
pwd
echo "==========================================================================="
echo "2-values passed in:"
echo "Environment: $1"
echo "Requested Branch: $2"
echo "Package: $3"
echo "ChangeSet: $4"
echo "CommitMessage: $5"
echo "CurrentRelease: $6"
echo "==========================================================================="


envIn=$1
IFS=',' read -ra envs <<< "$envIn"
export execute_extract=FALSE
export commit_message=$5
echo "Processing: $envIn"
#
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "============================================"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

export deployLocation=$WORKSPACE/deploy
export repoLocation=$WORKSPACE
export deployFullLocation=$WORKSPACE/deploy
export repoFullLocation=$WORKSPACE
export release_branch=$6
/var/lib/jenkins/workspace/SFDC/build/updateBuild.sh

./src/build/getEnv.sh getEnvironmentDetails $envName
ls -al setSystem
cat setSystem
source setSystem
rm setSystem
echo "Setting variables for $envIn"
export packageXML=$3
export dev_branch=$2
export changeset=$4
export xType=EXTRACT
export execute_extract=TRUE
echo $changeset

if [ "$execute_extract" = "TRUE" ]
then
    #
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    #
    echo "EnvName   $envName---"
    echo "serverURL $serverURL---"
    echo "username $username---"
    echo "release_branch  $release_branch---"
    echo "dev_branch $dev_branch---"
    echo "packageXML $packageXML---"
    echo "Changeset $changeset---"
    echo "Executing extract: $execute_extract----"
    #
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    #

    echo "============================================"
    echo "Performing extract from environment $envName"
    if [ "$changeset" != "NONE" ]
    then
        $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -Dpackage=$packageXML -Dchangeset=$changeset retrieveNamedPackage
    fi
    $ANT_HOME/ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -Dclean=true -Dcopy=true extract

    rm -rf deploy
    git status
    git branch
    echo "============================================"

    git add .
    git commit -m "$commit_message"

    #./src/build/git_in "$commit_message" $dev_branch
fi
