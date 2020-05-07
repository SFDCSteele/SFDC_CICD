@echo off
mkdir c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation\10.1\bin\..\lib
copy .\src\build\ant-salesforce.jar c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation\10.1\bin\..\lib
copy .\src\build\ant-contrib-1.0b3.jar c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation\10.1\bin\..\lib
mkdir c:\Users\Administrator\.ant\lib
copy .\src\build\ant-salesforce.jar c:\Users\Administrator\.ant\lib
copy .\src\build\ant-contrib-1.0b3.jar c:\Users\Administrator\.ant\lib
rem set 
rem dir c:\Users
rem dir c:\Users\Administrator
rem dir c:\Users\Administrator\.jenkins
rem dir c:\Users\Administrator\.jenkins\tools
rem dir c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation
rem dir c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation\10.1
dir c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation\10.1\bin
dir c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation\10.1\bin\lib
dir c:\Users\Administrator\.ant\lib

set releaseBranch=Release_19.4.1
set GITBRANCH=%GIT_BRANCH:~7%

echo "builder.bat: branch is %GITBRANCH%---version 000.014"
rem the type of branch will setup type of deployment to perform
if "%GITBRANCH%" == "Staging" GOTO setupStaging
if "%GITBRANCH%" == "UAT" GOTO setupUAT
if "%GITBRANCH%" == "Accenture" GOTO setupENTFULL
if "%GITBRANCH%" == "Acumen" GOTO setupENTFULL
if "%GITBRANCH%" == "DTCMerge" GOTO setupENTFULL
if "%GITBRANCH%" == "OBPI" GOTO setupENTFULL
if "%GITBRANCH%" == "VALERI" GOTO setupENTFULL
GOTO setupENTSD

:setupStaging
    echo "deploying to staging"
    set envName=STAGING
    set serverURL=%STAGINGServerURL
    set username=%STAGINGUsername
    set password=%STAGINGPassword
    set packageXML=Package_ALL.xml
    set release_branch=%releaseBranch%
    set dev_branch=%releaseBranch%
    set deploy_type="FULL"
    set perform_merge="false"
    goto deploy

:setupUAT
   echo "deploying to UAT"
    set envName=UAT
    set serverURL=%UATServerURL
    set username=%UATUsername
    set password=%UATPassword
    set packageXML=Package_ALL.xml
    set release_branch=%releaseBranch%
    set dev_branch=%releaseBranch%
    set deploy_type="FULL"
    set perform_merge="false"
    goto deploy

:setupENTFULL
    echo "deploying to ENTSDFull"
    set envName=ENTSD
    set serverURL=https://va--ENTSD.my.salesforce.com
    set username=william.steele6@va.gov.entsd
    set password=Cathy!022019HH2xSVwnSdCkk50QwvkWvf6Tp
    set packageXML=Package_ALL.xml
    set release_branch=%releaseBranch%
    set dev_branch=%GITBRANCH%
    set deploy_type="FULL"
    set perform_merge="false"
    goto deploy

:setupENTSD
    echo "deploying to ENTSD"
    set envName=ENTSD
    set serverURL=https://va--ENTSD.my.salesforce.com
    set username=william.steele6@va.gov.entsd
    set password=Cathy!022019HH2xSVwnSdCkk50QwvkWvf6Tp
    set packageXML=Package_%GITBRANCH%.xml
    set release_branch=%releaseBranch%
    set dev_branch=%GITBRANCH%
    set deploy_type="PACKAGE"
    set perform_merge="true"
    goto deploy

:deploy
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

echo "EnvName           %envName%---"
echo "serverURL         %serverURL%---"
echo "username          %username%---"
echo "release_branch    %release_branch%---"
echo "dev_branch        %dev_branch%---"
echo "packageXML        %packageXML%---"
echo "Deploy type:      %deploy_type%----"
echo "Perform merge:    %perform_merge%----"

set deployLocation=%WORKSPACE%\deploy
set repoLocation=%WORKSPACE%
set deployFullLocation=%WORKSPACE%\deploy
set repoFullLocation=%WORKSPACE%

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

if  "%deploy_type%" == "FULL" GOTO deployFullLocation
GOTO deployPackage

:deployFullLocation
    echo "Deploying the FULL package.... "
    rem ant -propertyfile src\build\build.properties -buildfile src\build\build.xml  %1 %2  %3 deploy-full
    goto END
:deployPackage
    echo "Deploying a single package....  %username%"
    set
    c:\Users\Administrator\.jenkins\tools\hudson.tasks.Ant_AntInstallation\10.1\bin\ant.bat -propertyfile .\src\build\build_win.properties -file .\src\build\build_win.xml deploy
:END