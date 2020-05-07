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
echo "Performing deployment to environment $envName"
#
#use this one to perform a validation deploy to your sandbox (dont worry about flows and entitlements that have been previously deployed)
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -Dcheck=true -DnoFlow=true deploy
#
#use this one to perform a validation deploy to your sandbox (only deploy new flows and entitlements)
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml -Dcheck=true deploy
#
#use this one to perform a deploy to your sandbox (only deploy new flows and entitlements)
#ant -propertyfile src/build/build.properties -buildfile src/build/build.xml deploy

