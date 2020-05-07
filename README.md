# DEVOPS-Salesforce-DevOps 

<h1>Salesforce CI/CD Framework</h1>

<h2>Current API Version 47.0</h2>

Welcome to the GitHub repository for the Salesforce CI/CD framework.  This repository contains the following components:

* All Salesforce Metadata for the VA Salesforce instances from June 2018 to current
* Salesforce Force.com Migration tool Jar and base configuration
* Ant contributed library for specialized functions
* Custom build Ant, JavaScript, and Java components to:
    * Read and combine package.xmls for N number of deployments
    * Create a single pakcage.xml with all o the above
    * Create a dynamic build.xml for the above deployment which executes an ant zip target to create a deployment zip and then performs a Salesforce Force.com sf:deploy, running all necessary Apex test classes

All key build (retrieve, deploy, and all git work) are contained in the folder:

* Src/build

All release specific deployment artifacts are stored (release specific templates and package.xmls) are stored in the

* Src/build/Releases
* Src/build/Releases/Release_YY\.MM.#

Ant specific configuration are in the following locations/files:

* Unix scripts (shell scripts)
    * src/build/build.properties — a basic property file (no credentials)
    * src/build/build.xml — this is where the magic happens (see the Wiki for ant target definitions
    * src/build/builder.sh — this script has been constructed to perform all build related activities on a CI/CD server like Codeship or Jenkins
* Windows scripts (batch scripts)
    * src/build/build_win.properties — a basic property file (no credentials)
    * src/build/build_win.xml — this is where the magic happens (see the Wiki for ant target definitions
    * src/build/builder.bat— this script has been constructed to perform all build related activities on a CI/CD server like Codeship or Jenkins
* Helpful scripts to run locally (on your laptop) to retrieve, deploy, and git tasks.  *Note* since the credentials are not in the build.properties file, you can use these files as templates to perform deployment tasks by adding your credentials and saving them locally outside of the git monitored environment.
    * deploy_envName.sh—performs basic deploy activities from your local repository to the Salesforce environment specified in the environment variables inside the script
    * extract_envName.sh—performs basic deploy activities from your local repository to the Salesforce environment specified in the environment variables inside the script
    * retrieve_envName.sh—performs basic deploy activities from your local repository to the Salesforce environment specified in the environment variables inside the script
    * retrieve_extract_deploy.sh—performs basic deploy activities from your local repository to the Salesforce environment specified in the environment variables inside the script

