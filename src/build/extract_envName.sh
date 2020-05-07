#!/bin/bash
clear
export envName=<env Name>
export serverURL=<server URL>
export username=<user name>
export password=<password and security token>
export packageXML=<name of your package.xml>
export release_branch=<release branch>
export dev_branch=<your development branch>
echo "============================================"
echo "Performing extract from environment $envName"
#
#use this one just to extract files from your sandbox
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -Dclean=true extract
#
#use this one to extract files and copy the files to the repo directory
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -Dclean=true -Dcopy=true extract
#
#use this one to extract files, copy the files to the repo directory, and then push to the GitHub repository
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -Dclean=true -Dcopy=true extract-push
