#compdef hass-cli

_hass_cli_completion() {
    local -a completions
    local -a completions_with_descriptions
    local -a response
    (( ! $+commands[hass-cli] )) && return 1

    response=("${(@f)$( env COMP_WORDS="${words[*]}" \
                        COMP_CWORD=$((CURRENT-1)) \
                        _HASS_CLI_COMPLETE="complete_zsh" \
                        hass-cli )}")

    for key descr in ${(kv)response}; do
      if [[ "$descr" == "_" ]]; then
          completions+=("$key")
      else
          completions_with_descriptions+=("$key":"$descr")
      fi
    done

    if [ -n "$completions_with_descriptions" ]; then
        _describe -V unsorted completions_with_descriptions -U
    fi

    if [ -n "$completions" ]; then
        compadd -U -V unsorted -a completions
    fi
    compstate[insert]="automenu"
}

compdef _hass_cli_completion hass-cli;
