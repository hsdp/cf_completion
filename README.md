# Cloud Foundry CLI Completion for bash
Recent versions of cf cli seem to have broken the old completion provided by pivotal. 

### Instructions
source cf_complete.sh from your .bashrc

    source ~/src/cf_completion/cf_complete.sh


### TODO
  - Add completion handling for more subcommands
    

### BUGS
  - Won't gracefully handle orgs and spaces which have whitespace in the name.
