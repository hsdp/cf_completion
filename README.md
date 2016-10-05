# Cloud Foundry CLI Completion for bash
Recent versions of cf cli seem to have broken the old completion provided by pivotal. 

## Instructions
source cf_complete.sh from your .bashrc

    source ~/src/cf_completion/cf_complete.sh


## TODO
second level and deeper completion like completing the SERVICENAME in

    cf bind-service APPNAME SERVICENAME
    
