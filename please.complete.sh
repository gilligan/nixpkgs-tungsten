set completion-display-width 0

_get_attrs()
{
    nix-instantiate --strict --eval --expr "import ./get-attrs.nix {}" | tr -d "[]\""
}

_please_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ "${#COMP_WORDS[@]}" = "2" ]; then
        COMPREPLY=($(compgen -W "build install shell init doctor" "${COMP_WORDS[1]}"))
        return
    fi

    case "$prev" in
        install|build|shell)
            COMPREPLY=($(compgen -W "$(_get_attrs)" "$cur"))
            ;;

    esac
}

complete -F _please_completions please
