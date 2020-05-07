#!/usr/bin/env bash


setup_environment_variables() {
    if [[ -z "${serverurl}" ]]
    then
        read -p "serverurl: " serverurl
        export serverurl=$serverurl
    fi

    if [[ -z "${envName}" ]]
    then
        read -p "envName: " envName
        export envName=$envName
    fi

    if [[ -z "${username}" ]]
    then
        read -p "username: " username
        export username=$username
    fi

    if [[ -z "${password}" ]]
    then
        read -p "password + token: " password
        export password=$password
    fi
    #if [[ -z "${packageXML}" ]]
    #then
        #read -p "packageXML: " packageXML
        #export packageXML=$packageXML
    #fi
    #if [[ -z "${release_branch}" ]]
    #then
        #read -p "release_branch: " release_branch
        #export release_branch=$release_branch
    #fi
    #if [[ -z "${dev_branch}" ]]
    #then
        #read -p "dev_branch: " dev_branch
        #export dev_branch=$dev_branch
    #fi
}

ask_retrieve_extract_deploy() {
    echo "To retrieve package enter 1:"
    echo "To extract files enter 2:"
    echo "To deploy files enter 3:"
}

#ask_retrieve_extract_deploy choice 1
ask_retrieve_questions() {
    echo "To only retrieve package enter 1:" 
    echo "To extract files and package.xml enter 2:"
    echo "To extract files and package.xml and copy the files to the repo directory enter 3:"
}

#ask_retrieve_extract_deploy choice 2
ask_extract_questions() {
    echo "To extract files from your sandbox enter 1:"
    echo "To extract files and copy the files to the repo directory enter 2:"
    echo "To extract files, copy the files to the repo directory, and then push to the GitHub repository enter 3:"
}

#ask_retrieve_extract_deploy choice 3
ask_deploy_questions() {
    echo "To perform a validation deploy to your sandbox (dont worry about flows and entitlements that have been previously deployed) enter 1:"
    echo "To perform a validation deploy to your sandbox (only deploy new flows and entitlements) enter 2:"
    echo "To perform a deploy to your sandbox (only deploy new flows and entitlements) enter 3:"
}

execute_command() {
    echo "Execute the following command? y/n"
} 

cancel_decision() {
    if [[ $decision == "y" ]]
    then
        echo "=========================================================="
    elif [[ $decision != "y" ]]
    then
        echo "Cancelling..."
    fi
}

instructions() {
    echo -e "You must run it as:\nsource ./retrieve_extract_deploy.sh"
}

if [[ $_ != $0 ]]
then
	setup_environment_variables
    ask_retrieve_extract_deploy
    read -p "" selection
    # Retrieve selection
    if [[ $selection -eq 1 ]]
    then
        ask_retrieve_questions
        read -p "" sel
        if [[ $sel -eq 1 ]]
        then
            execute_command
            echo "ant -DenvName=$envName retrieveNamedPackage"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -DenvName=$envName retrieveNamedPackage
            fi
        fi
        if [[ $sel -eq 2 ]]
        then
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml retrieveNamedPackage"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml retrieveNamedPackage
            fi
        fi
        if [[ $sel -eq 3 ]]
        then 
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml -Dcopy=true retrieveNamedPackage"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml -Dcopy=true retrieveNamedPackage
            fi
        fi
        cancel_decision $decision
    fi

    # Extract selection
    if [[ $selection -eq 2 ]]
    then
        ask_extract_questions 
        read -p "" sel
        if [[ $sel -eq 1 ]]
        then
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml -Dclean=true extract"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml -Dclean=true extract
            fi
        fi

        if [[ $sel -eq 2 ]]
        then
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml -Dclean=true -Dcopy=true extract"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml -Dclean=true -Dcopy=true extract
            fi
        fi

        if [[ $sel -eq 3 ]]
        then
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml -Dclean=true -Dcopy=true extract-push"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml -Dclean=true -Dcopy=true extract-push
            fi
        fi
        cancel_decision $decision
    fi
    
    # Deploy selection
    if [[ $selection -eq 3 ]]
    then
        ask_deploy_questions
        read -p "" sel
        if [[ $sel -eq 1 ]]
        then
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml -Dcheck=true -DnoFlow=true deploy"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml -Dcheck=true -DnoFlow=true deploy
            fi
        fi

        if [[ $sel -eq 2 ]]
        then
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml -Dcheck=true deploy"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml -Dcheck=true deploy
            fi
        fi

        if [[ $sel -eq 3 ]]
        then
            execute_command
            echo "ant -propertyfile build.properties -buildfile build.xml deploy"
            read -p "" decision
            if [[ $decision == "y" ]]
            then
                ant -propertyfile build.properties -buildfile build.xml deploy
            fi
        fi 
        cancel_decision $decision
    fi
else
    instructions
fi
