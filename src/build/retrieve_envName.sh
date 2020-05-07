#!/bin/bash
clear
export envName=<env Name>
export serverURL=<server URL>
export username=<user name>
export password=<password and security token>
export packageXML=<name of your package.xml>
export release_branch=<release branch>
export dev_branch=<your development branch>
echo "=========================================================="
echo "Performing retrieveNamedPackage from environment $envName"
#
#use this one just to extract files and package.xml
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml retrieveNamedPackage
#
#use this one to extract files and package.xml and copy the files to the repo directory
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml  -Dcopy=true retrieveNamedPackage
