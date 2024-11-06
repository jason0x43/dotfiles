# file commands
alias ls="eza -F"
alias fda="fd -I"
alias rgl="rg -l"
alias rgla="rg -l -u"

# reload the shell
alias reload="exec $SHELL"

# moving around
alias b="cd -"

# docker
alias dps="docker ps --format '{{.Names}}'"
alias dc="docker compose"

# git
alias ga="git a"
alias gbd="git branch -D"
alias gbm="git branch -m"
alias gc="git commit"
alias gca="git commit --all"
alias gcb="git cb"
alias gco="git co"
alias gcp="git cp"
alias gd="git diff"
alias gds="git ds"
alias gg="git g"
alias ggl="git gl"
alias gid="git id"
alias gl="git lg -n 20"
alias gla="git lg"
alias glb="git lgb -n 20"
alias glba="git lgb"
alias gri="git ri"
alias gs="git -c status.color=always status --short"
alias ts='tig status'
