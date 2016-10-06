# completion for cf cli.
# source this file from your .bashrc
# be sure to remove the old cf completion line as that one doesn't work

# scrape the cli version to handle different help options
FULLVERSION=$(cf --version|cut -d " " -f 3|cut -d + -f 1)
MAJORV=$(echo $FULLVERSION|cut -d . -f 1)
MINORV=$(echo $FULLVERSION|cut -d . -f 2)
PATCHV=$(echo $FULLVERSION|cut -d . -f 3)
# produce a math compatible version number.
VERSION=$(printf "%02d%02d%02d" $MAJORV $MINORV $PATCHV)

# set the help command depending on the cli version
if [ "$VERSION" -ge "062200" ]
then
    HELPOPT="-a "
else
    HELPOPT=""
fi

# gather the list of commands currently supported by cf cli.
COMMANDS=$(cf help $HELPOPT | sed -n -e '/GETTING STARTED:/,/ENVIRONMENT VARIABLES:/p' | grep '^   ' | awk '{print $1}')
   

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

    # first arg after "cf"
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
        create-service|enable-service-access|disable-service-access)
            COMPREPLY=( $(compgen -W "$(_cf_service)" -- $cur) )
            return 0
            ;;
    esac

    # we can now collect the word before the previous word. Woohoo!
    local prev2=${COMP_WORDS[COMP_CWORD-2]}

    # second argument after "cf"
    case "$prev2" in
        bind-service)
            COMPREPLY=( $(compgen -W "$(_cf_service_instance)" -- $cur) )
            return 0
            ;;
        unbind-service)
            COMPREPLY=( $(compgen -W "$(_cf_bound_service $prev1)" -- $cur) )
            return 0
            ;;
        create-service)
            COMPREPLY=( $(compgen -W "$(_cf_plan $prev1)" -- $cur) )
            return 0
            ;;
        set-org-role|set-space-role)
            COMPREPLY=( $(compgen -W "$(_cf_org)" -- $cur) )
            return 0
            ;;
        set-quota)
            COMPREPLY=( $(compgen -W "$(_cf_org_quota)" -- $cur) )
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
_cf_plan()
{
    cf marketplace -s "$1" | awk 'NR>4 {print $1}'
}
_cf_service_instance()
{
    cf services | awk 'NR>4 {print $1}'
}
_cf_bound_service()
{
    cf services | awk 'NR>4' | grep $1 | awk '{print $1}'
}
_cf_org()
{
    cf orgs | awk 'NR>3 {print $1}'
}
_cf_space()
{
    cf spaces | awk 'NR>3 {print $1}'
}
_cf_org_quota()
{
    cf quotas | awk 'NR>4 {print $1}'
}

complete -F _cf_complete cf
