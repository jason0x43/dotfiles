# Select commits using fgl
fzf-git-log-widget() {
    LBUFFER="${LBUFFER}$(fgl)"
    local ret=$?
    zle reset-prompt
    return $ret
}
zle -N fzf-git-log-widget
# Use alt-g to bring up the git log
bindkey 'g' fzf-git-log-widget

# Select git files 
__gfsel() {
  setopt localoptions pipefail 2> /dev/null
  eval git ls-files | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@"
  return $?
}
fzf-git-file-widget() {
  local selection=$(__gfsel)
  LBUFFER="${LBUFFER}$selection"
  local ret=$?
  if [[ -n $selection ]]; then
      # Execute the command buffer immediately
      zle accept-line
  else
      zle reset-prompt
  fi
  return $ret
}
zle -N   fzf-git-file-widget
bindkey '^G' fzf-git-file-widget

# Bind the file widget to ^P since we use ^T for tmux
bindkey '^P' fzf-file-widget

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# # command for listing path candidates.
_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}
