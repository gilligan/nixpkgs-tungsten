_please_completions()
{
  COMPREPLY=($(compgen -W "build install shell init doctor" "${COMP_WORDS[1]}"))
}

complete -F _please_completions dothis
