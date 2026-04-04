# Bash completion for conduit
# Install to /etc/bash_completion.d/ or ~/.local/share/bash-completion/completions/

_conduit() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Stealth options
    local stealth_opts="-Mk -Ms -MS -Mn -Md -Mr -Mc"

    # Standard SOCAT options
    local standard_opts="-V -h -? -hh -hhh -d -dd -ddd -dddd -D -ly -lf -ls -lm -lp -lu -lh -v -x -b -s -t -T -u -U -g -L -W -4 -6"

    # Address types
    local address_types="TCP TCP-LISTEN TCP4 TCP4-LISTEN TCP6 TCP6-LISTEN UDP UDP-LISTEN UDP4 UDP4-LISTEN UDP6 UDP6-LISTEN UNIX-CONNECT UNIX-LISTEN UNIX-CLIENT UNIX-SENDTO UNIX-RECVFROM UNIX-RECV EXEC SYSTEM PIPE STDIO FILE GOPEN CREATE OPEN INTERFACE IP4-SENDTO IP4-RECVFROM IP4-RECV IP6-SENDTO IP6-RECVFROM IP6-RECV OPENSSL OPENSSL-LISTEN PROXY PTY READLINE SCTP-CONNECT SCTP-LISTEN SOCKS4 SOCKS4A TUN"

    # Complete options
    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${stealth_opts} ${standard_opts}" -- ${cur}) )
        return 0
    fi

    # Complete -Mc argument (custom masquerade name)
    if [[ ${prev} == "-Mc" ]] ; then
        local masq_suggestions="[kworker/0:1] [ksoftirqd/0] [rcu_gp] systemd-logind systemd-resolved systemd-journald /usr/sbin/sshd /usr/bin/NetworkManager dbus-daemon"
        COMPREPLY=( $(compgen -W "${masq_suggestions}" -- ${cur}) )
        return 0
    fi

    # Complete file arguments for certain options
    case "${prev}" in
        -lf|-L|-W)
            COMPREPLY=( $(compgen -f -- ${cur}) )
            return 0
            ;;
    esac

    # Complete address types
    COMPREPLY=( $(compgen -W "${address_types}" -- ${cur}) )
}

complete -F _conduit conduit
