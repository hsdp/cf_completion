# completion for cf cli.
# source this from your .bashrc

# TODO:
# implement a second level of search, for instance;
#   cf bind-service APPNAME SERVICENAME
# where we search for the service name after having input the appname.
# We can go deeper than a second level, but not a lot of common commands require
# it aside from create-service

# gather the list of commands currently supported by cf cli.
COMMANDS=$(cf help -a | sed -n -e '/GETTING STARTED:/,/ENVIRONMENT VARIABLES:/p' | grep '^   ' | awk '{print $1}')

# peel out all of the carriage returns ungracefully
COMMANDS=$(echo $COMMANDS)

_cf_complete()
{
    # Collect the current word and previous word.
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev1=${COMP_WORDS[COMP_CWORD-1]}

    # base case. After this case, we can assume we have a word before
    # the previous word. That's why this base case is broken out.
    case "$prev1" in
        cf|help)
            COMPREPLY=( $(compgen -W "$COMMANDS" -- $cur) )
            return 0
            ;;
    esac

    # we can now collect the word before the previous word. Woohoo!
    local prev2=${COMP_WORDS[COMP_CWORD-2]}

    
    case "$prev1" in
        # org related commands or options
        -o|delete-org|rename-org|set-quota)
            COMPREPLY=( $(compgen -W "$(_cf_org)" -- $cur) )
            return 0
            ;;
        # space related commands
        set-space-quota)
            COMPREPLY=( $(compgen -W "$(_cf_space)" -- $cur) )
            return 0
            ;;
        # app related commands
        app|bind-service|unbind-service|copy-source|create-app-manifest|delete|env|events|files|logs|rename|restage|restart|restart-app-instance|scale|set-env|start|stop|unset-env|get-health-check|set-health-check|enable-ssh|disable-ssh|ssh-enabled|ssh)
            COMPREPLY=( $(compgen -W "$(_cf_app)" -- $cur) )
            return 0
            ;;
        # service instance related commands
        delete-service|purge-service-instance|rename-service|service|update-service|service-key|service-keys)
            COMPREPLY=( $(compgen -W "$(_cf_service_instance)" -- $cur) )
            return 0
            ;;
        # service commands
        enable-service-access|disable-service-access)
            COMPREPLY=( $(compgen -W "$(_cf_service)" -- $cur) )
            return 0
            ;;
    esac
}

_cf_app()
{
    cf apps | awk 'NR>4 {print $1}'
}

_cf_service()
{
    cf marketplace | awk 'NR>4 {print $1}'|sed -n -e '1,/^$/p'
}
_cf_service_instance()
{
    cf services | awk 'NR>4 {print $1}'
}
_cf_org()
{
    cf orgs | awk 'NR>3 {print $1}'
}
_cf_space()
{
    cf spaces | awk 'NR>3 {print $1}'
}

complete -F _cf_complete cf
