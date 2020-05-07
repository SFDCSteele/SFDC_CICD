echo "Inside updateBuild.sh....copying files..."
cp /var/lib/jenkins/workspace/SFDC/build/Package_ALL_template.xml $repoLocation/src/build/Releases
cp /var/lib/jenkins/workspace/SFDC/build/build.xml $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/build.properties $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/builder.sh $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/builder_jenkins.sh $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/extractor_jenkins.sh $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/builder.bat $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/updateBuild.sh  $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/storeBuild.sh  $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/git_in $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/*.jar $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/*.zip $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/buildMessage.sh $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/get*.sh $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/destructiveChanges_Package.xml $repoLocation/src/build
cp /var/lib/jenkins/workspace/SFDC/build/deploy_template*.xml $repoLocation/src/build
cp -R /var/lib/jenkins/workspace/SFDC/build/java/lib $repoLocation/src/build/java
mkdir $repoLocation/src/build/java/salesforce_rest
cp -R /var/lib/jenkins/workspace/SFDC/build/java/salesforce_rest/*.class $repoLocation/src/build/java/salesforce_rest

