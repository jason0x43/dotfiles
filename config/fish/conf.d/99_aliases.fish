# file commands
alias fda="fd -I"
alias rgl="rg -l"
alias rgla="rg -l -u"
alias rga="rg -u"
alias ldl="recent-downloads"

# better ls
if command -q eza
    alias ls="eza -F"
else
    alias ls="ls -CF"
end

# reload the shell
alias reload="exec $SHELL"

# moving around
alias b="prevd"
alias back="prevd"
alias f="nextd"

# docker
alias dps="docker ps --format '{{.Names}}'"
alias dc="docker compose"

# git
alias ga="git a"
alias gb="git branch"
alias gba="git branch --all"
alias gbd="git branch -D"
alias gbm="git branch -m"
alias gc="git commit"
alias gca="git commit --all"
alias gcb="git cb"
alias gco="git co"
alias gcp="git cp"
alias gd="git diff"
alias gdt="git difftool"
alias gds="git ds"
alias gf="git fetch"
alias gfp="git fetch --prune"
alias gg="git g"
alias ggl="git gl"
alias gid="git id"
alias gl="git lg -n 20"
alias gla="git lg"
alias glb="git lgb -n 20"
alias glba="git lgb"
alias gp="git pull"
alias grc="git rebase --continue"
alias gri="git ri"
alias grv="git remote -v"
alias gs="git -c status.color=always status --short"
alias ts='tig status'

# vim
alias view='vi -R'
alias vim='vi'
alias vimdiff='vi -d'

# kitty
alias kt='kitten @ set-tab-title'
alias icat='kitten icat'
