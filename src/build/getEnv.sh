#!/bin/bash
if [ "$1" = "getEnvironmentDetails" ]
then
    echo "#######################################################################################"
    echo "######### executing $1 for $2 environment version 1.02 ##########################"
    echo "#######################################################################################"
    #echo "#######-------backuping up parms: CICD_LOGINURL: $CICD_LOGINURL..."
    #export backup_CICD_LOGINURL=$CICD_LOGINURL
    #export backup_CICD_USERNAME=$CICD_USERNAME
    #export backup_CICD_PASSWORD=$CICD_PASSWORD
    #export CICD_LOGINURL=$ARCHDServerURL
    #export CICD_USERNAME=$ARCHDUsername
    #export CICD_PASSWORD=$ARCHDPassword
    echo "#######-------executing $1 with CICD_LOGINURL: $CICD_LOGINURL..."
    java -cp ./src/build/java/lib/\*:./src/build/java:. salesforce_rest.CICDRestClientV2 $1 $2
    source setSystem
    echo "envName=$envName"
    echo "serverURL=$serverURL"
    echo "username=$username"
    #echo "password=$password"
    #export CICD_LOGINURL=$backup_CICD_LOGINURL
    #export CICD_USERNAME=$backup_CICD_USERNAME
    #export CICD_PASSWORD=$backup_CICD_PASSWORD
    #echo "#######-------reset CICD_LOGINURL: $CICD_LOGINURL..."
fi