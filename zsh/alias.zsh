# Clear existing aliases
unalias -m '*'

# Simpler back
alias b='back'

# Reload zshrc. Undefine DIRENV_WATCHES (if it exists) so that direnv will
# reload the environment
alias refresh='source ~/.zshenv && source ~/.zshrc'
alias reload='exec env -u DIRENV_WATCHES $SHELL'
alias reloadx86='ARCHPREFERENCE=x86_64 exec arch -x86_64 env -u DIRENV_WATCHES $SHELL'

# Default command options
alias cp='cp -i'
alias ln='ln -i'
alias mkdir='mkdir -p'
alias mv='mv -i'
alias rm='rm -i'
alias type='type -a'
alias fda='fd -I'

# Let node use local readline setup (vi mode)
if (( $+commands[rlwrap] )); then
    alias node='env NODE_NO_READLINE=1 rlwrap node'
fi

# Shortcuts
alias agl='ag -l'
alias rgl='rg -l'
alias rgla='rg -l -u'
alias back='popd'
alias help='run-help'
alias se='sudo -e'

# Disable certificate check for wget
alias wget='wget --no-check-certificate'

# Docker shortcuts
alias dk='docker kill'
alias dl='docker logs'
alias dlf='docker logs -f'
alias dps='docker ps --format "{{.Names}}"'

# Git shortcuts
alias ga='git a'
alias gb='git b'
alias gba='git ba'
alias gbd='git branch -D'
alias gbk='git killbranch'
alias gbdo='git push -d origin' 
alias gbm='git mybranches' 
alias gbf='git bf'
alias gc='git c'
alias gca='git ca'
alias gcb='git cb'
alias gco='git co'
alias gcp='git cp'
alias gcpe='git cp -e'
alias gcpn='git cpn'
alias gcpr='git checkout-pr'

# Cleanup
alias gcln='git clean -nxd'
alias gclf='git clean -fxd'

alias gd='git diff'
alias gds='git ds'
alias gdv='git dv'
alias gf='git f'
alias gfp='git fp'
alias gfr='git fr'
alias gg='git g'
alias ggi='git gi'
alias ggil='git gil'
alias ggl='git gl'
alias gid='git rev-parse HEAD'

# Display graph logs
local lg="git log --graph --abbrev-commit --date-order --format=format:'%Cblue%h%Creset%C(bold red)%d%Creset %s <%an> %Cgreen(%ar)%Creset'"
local lga="$lg --all"
alias gl="$lga -n 20"
alias gla="$lga"
alias glb="$lg -n 20"
alias glba="$lg"

# Show descendents from a particular commit
alias glf="$lga --ancestry-path"
alias glfm="$lg --ancestry-path"

alias gls='git ls'
alias gmb='git mb'
alias gp='git p'
alias gr='git r'
alias gri='git ri'
alias grc='git rc'
alias grm='git rm'
alias gro='git ro'
alias grv='git rv'
alias gs='git -c status.color=always status --short'
alias gsh='git show'
alias gshs='git show --stat'
alias gsu='gs | grep UU'
alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwr='git worktree remove'

alias tiga='tig --all'
alias fgl='fzf-git-log'
alias ts='tig status'

# ssh in interactive shells
# alias ssh=themed_ssh

# vim
if (( $+commands[nvim] )); then
    if [[ -n $WEZTERM_PANE ]]; then
        alias vi="nvim --listen /tmp/nvim-wt$WEZTERM_PANE"
    else
        alias vi=nvim
    fi
elif (( $+commands[vim] )); then
    alias vi=vim
fi

# tmux
alias tls='tmux list-sessions'
alias tas='tmux attach -t'
alias tks='tmux kill-session -t'

# xcode
alias xcr='xcrun'

# Pretty print json
alias json='python -m json.tool'

# Tree
alias t1='tree -L 1'

# Disable correction for some commands
alias cd="nocorrect ${aliases[cd]:-cd}"
alias cp="nocorrect ${aliases[cp]:-cp}"
alias gcc="nocorrect ${aliases[gcc]:-gcc}"
alias grep="nocorrect ${aliases[grep]:-grep}"
alias gulp="nocorrect ${aliases[gulp]:-gulp}"
alias ln="nocorrect ${aliases[ln]:-ln}"
alias man="nocorrect ${aliases[man]:-man}"
alias mkdir="nocorrect ${aliases[mkdir]:-mkdir}"
alias mv="nocorrect ${aliases[mv]:-mv}"
alias rm="nocorrect ${aliases[rm]:-rm}"
alias vim="nocorrect ${aliases[vim]:-vim}"
alias nvim="nocorrect ${aliases[nvim]:-nvim}"
alias tsd="nocorrect ${aliases[tsd]:-tsd}"
alias jake="nocorrect ${aliases[jake]:-jake}"

# Disable globbing for some commands
alias bower="noglob ${aliases[bower]:-bower}"
alias find="noglob ${aliases[find]:-find}"
alias ftp="noglob ${aliases[ftp]:-ftp}"
alias history="noglob ${aliases[history]:-history}"
alias rsync="noglob ${aliases[rsync]:-rsync}"
alias scp="noglob ${aliases[scp]:-scp}"
alias sftp="noglob ${aliases[sftp]:-sftp}"

# Default swift compilation options
alias swiftc="xcrun -sdk macosx swiftc"

alias npmv="npm --loglevel error"
alias npmr="npm --registry=https://registry.npmjs.org"
alias px="pnpm exec"

alias ha='TERM=xterm-256color ssh root@homeassistant.local'
alias halog='TERM=xterm-256color ssh root@homeassistant.local tail -F /config/home-assistant.log | bat --paging=never -l halog'
alias adlog='TERM=xterm-256color ssh root@homeassistant.local tail -F /config/appdaemon/logs/main.log | bat --paging=never -l adlog'
alias aderrlog='TERM=xterm-256color ssh root@homeassistant.local tail -F /config/appdaemon/logs/error.log'

alias ls='ls --color -F'
alias l='ls -1A'         # Lists in one column, hidden files
alias ll='ls -lh'        # Lists human readable sizes
alias lld='ll -d'        # List directories
alias llt='ls -lh -t'    # Lists human readable ordered by time
alias lls='ls -lh -S'    # Lists human readable ordered by size
alias la='ll -A'         # Lists human readable sizes, hidden files

alias di='direnv-info'   # Show info about direnv

alias dfh='df -h'
alias duh='du -h *(D) | sort -h'

# Better top
if (( $+commands[htop] )); then
    alias top=htop
fi

# Better cat
if (( $+commands[bat] )); then
    alias cat=bat
fi
