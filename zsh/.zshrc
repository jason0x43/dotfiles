# Enable profiling
# zmodload zsh/zprof

# Setup fpath
# ------------------------------------------------------------------------
# The fpath should be initialized before trying to load plugins (with zfetch)
# or trying to initialize completions
fpath=(
    $ZFUNCDIR
    $DOTFILES/zsh/functions
    $fpath
)

# Autoload all user shell functions, following symlinks
# ------------------------------------------------------------------------
if [[ -d $DOTFILES/zsh/functions ]]; then
    for func in $DOTFILES/zsh/functions/*(:t); autoload -U $func
fi

# Prompt
# --------------------------------------------------------------------------
if [[ -f $ZDOTDIR/p10k.zsh ]]; then
    zfetch $ZPLUGDIR romkatv/powerlevel10k
    source $ZPLUGDIR/romkatv/powerlevel10k/powerlevel10k.zsh-theme
    source $ZDOTDIR/p10k.zsh
fi

# Declare some key global variables
# ------------------------------------------------------------------------
typeset -gU cdpath
typeset -gU fpath
typeset -gU manpath

# manpath
# ----------------------------------------------------------------------------
# Set the list of directories that man searches for manuals.
if [ -e /etc/manpaths ]; then
	while read line; do 
		manpath+=$line
	done < /etc/manpaths
fi

# Editors
# ----------------------------------------------------------------------------
if (( $+commands[nvim] )); then
    export SUDO_EDITOR=nvim
elif (( $+commands[vim] )); then
    export SUDO_EDITOR=vim
else
    export SUDO_EDITOR=vi
fi

export EDITOR=$SUDO_EDITOR
export VISUAL=$SUDO_VISUAL

# Turn on color for everything
# ------------------------------------------------------------------------
autoload -Uz colors && colors

# Terminal colors
TC='\e['
Rst="${TC}0m"
Blk="${TC}30m";
Red="${TC}31m";
Grn="${TC}32m";
Yel="${TC}33m";
Blu="${TC}34m";
Prp="${TC}35m";
Cyn="${TC}36m";
Wht="${TC}37m";

# zsh-autocomplete
# --------------------------------------------------------------------------
# Should be loaded before completions
# zstyle ':autocomplete:list-choices:*' max-lines 5
# zstyle ':autocomplete:space:*' magic expand-history
# zstyle ':autocomplete:tab:*' completion select
# zfetch $ZPLUGDIR marlonrichert/zsh-autocomplete
# source $ZPLUGDIR/marlonrichert/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Completions
# ------------------------------------------------------------------------
# The completion system should be configured and enabled before sourcing
# completion plugins

export ZCOMPDIR=$ZCACHEDIR/completions
if [[ ! -d "$ZCOMPDIR" ]]; then
    mkdir -p "$ZCOMPDIR"
fi
export ZCOMPFILE=$ZCACHEDIR/zcompdump

# Install community completions
zfetch $ZPLUGDIR zsh-users/zsh-completions

# Completion directories should be added to the fpath before compinit is called
fpath=(
    $fpath
    $ZPLUGDIR/zsh-users/zsh-completions/src
    $ZCOMPDIR
    $HOMEBREW_BASE/share/zsh-completions
)

# Load and initialize the completion system, ignoring insecure directories.
# Note that fpath should be configured before calling compinit.
# (https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh)
autoload -Uz compinit
if [[ $HOME =~ "/Users" ]] then
    # Only try to rebuild the comp dump once a day
    if [[ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' $ZCOMPFILE) ]] then
        compinit -i -d $ZCOMPFILE
    else
        compinit -C -i -d $ZCOMPFILE
    fi
else
    compinit -i -d $ZCOMPFILE
fi

# Add AWS completions
if (( $+commands[aws_completer] )); then
    autoload bashcompinit && bashcompinit
    complete -C aws_completer aws
fi

# Compile the zcompfile in the background
{
    # Compile zcompdump, if modified, to increase startup speed.
    if [[ -s "$ZCOMPFILE" && (! -s "${ZCOMPFILE}.zwc" || "$ZCOMPFILE" -nt "${ZCOMPFILE}.zwc") ]] then
        zcompile "$ZCOMPFILE"
    fi
} &!

# Kitty completions
if [[ $TERM == "kitty" ]]; then
    kitty + complete setup zsh | source /dev/stdin
fi

# Docker completions
if [[ -d /Applications/Docker.app/Contents/Resources/etc ]]; then
    for f in /Applications/Docker.app/Contents/Resources/etc/*.zsh-completion; do
        dest=$ZCOMPDIR/_$(basename -s .zsh-completion $f)
        if [[ ! -f $dest || $f -nt $dest ]]; then
            cp $f $dest
            chmod a-x $dest
        fi
    done
    unset dest
fi

# Use caching to make completion for commands with many options usable
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZCACHEDIR}"

# Case-insensitive (all), partial-word, and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=*' '+l:|=* r:|=*'

# Group matches and describe
zstyle ':completion:*'              menu select
zstyle ':completion:*:matches'      group 'yes'
zstyle ':completion:*:options'      description 'yes'
zstyle ':completion:*:options'      auto-description '%d'
zstyle ':completion:*:corrections'  format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages'     format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings'     format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default'      list-prompt '%S%M matches%s'
zstyle ':completion:*'              format ' %F{yellow}-- %d --%f'
zstyle ':completion:*'              group-name ''
zstyle ':completion:*'              verbose yes

# Fuzzy match mistyped completions
zstyle ':completion:*'               completer _complete _match _approximate
zstyle ':completion:*:match:*'       original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:default'                list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*'                 tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*'              group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*'                        squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Populate hostname completion
zstyle -e ':completion:*:hosts' hosts 'reply=(
    ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
    ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
    ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
    adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
    dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
    hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
    mailman mailnull mldonkey mysql nagios \
    named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
    operator pcap postfix postgres privoxy pulse pvm quagga radvd \
    rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# ... unless we really want to
zstyle '*' single-ignored show

# Ignore multiple entries
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# kill
zstyle ':completion:*:*:*:*:processes'    command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*'           menu yes select
zstyle ':completion:*:*:kill:*'           force-list always
zstyle ':completion:*:*:kill:*'           insert-ids single

# man
zstyle ':completion:*:manuals'       separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*'                  tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*'                  group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*'                          tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*'                          group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host'   ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# VI keybindings
bindkey -v

# Aliases
# ------------------------------------------------------------------------
source $ZDOTDIR/alias.zsh

# Theme
# ------------------------------------------------------------------------
if [[ -e $HOME/.theme ]]; then
    theme=$(cat $HOME/.theme)
    if [[ $theme == 'light' ]]; then
        export THEME_VARIANT=$theme
    elif [[ $theme == 'black' ]]; then
        export THEME_VARIANT=$theme
    fi
    unset theme
fi

export LSCOLORS='ExFxCxDxBxfxdxacagafad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

export CLICOLOR=1

# Shell options
# ------------------------------------------------------------------------
# Navigation
setopt   AUTO_CD                # Change to a directory without typing cd
setopt   AUTO_NAME_DIRS         # Auto add variable-stored paths to ~ list
setopt   AUTO_PUSHD             # Push the old directory onto the stack on cd
setopt   CDABLE_VARS            # Change directory to a path stored in a variable
setopt   EXTENDED_GLOB          # Use extended globbing syntax
setopt   MULTIOS                # Write to multiple descriptors
setopt   PUSHD_IGNORE_DUPS      # Do not store duplicates in the stack
setopt   PUSHD_SILENT           # Do not print the directory stack after pushd or popd
setopt   PUSHD_TO_HOME          # Push to home directory when no argument is given
unsetopt CLOBBER                # Don't overwrite existing files with > and >>

# Files and commands
setopt   BRACE_CCL              # Allow brace character class list expansion
setopt   COMBINING_CHARS        # Combine zero-length punctuation characters (accents) with the base character
setopt   CORRECT                # Correct mis-typed commands
setopt   RC_QUOTES              # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'

# Jobs
setopt   AUTO_RESUME            # Attempt to resume existing job before creating a new process
setopt   LONG_LIST_JOBS         # List jobs in the long format by default
setopt   NOTIFY                 # Report status of background jobs immediately
unsetopt BG_NICE                # Don't run all background jobs at a lower priority
unsetopt CHECK_JOBS             # Don't report on jobs when shell exit
unsetopt HUP                    # Don't kill jobs on shell exit

# History
setopt   BANG_HIST              # Treat the '!' character specially during expansion
setopt   HIST_BEEP              # Beep when accessing non-existent history
setopt   HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history
setopt   HIST_FIND_NO_DUPS      # Do not display a previously found event
setopt   HIST_IGNORE_ALL_DUPS   # Delete an old recorded event if a new event is a duplicate
setopt   HIST_IGNORE_DUPS       # Do not record an event that was just recorded again
setopt   HIST_IGNORE_SPACE      # Do not record an event starting with a space
setopt   HIST_SAVE_NO_DUPS      # Do not write a duplicate event to the history file
setopt   HIST_VERIFY            # Do not execute immediately upon history expansion
setopt   SHARE_HISTORY          # Share history between all sessions

# Completion
setopt   ALWAYS_TO_END          # Move cursor to the end of a completed word
setopt   AUTO_LIST              # Automatically list choices on ambiguous completion
setopt   AUTO_PARAM_SLASH       # If completed parameter is a directory, add a trailing slash
setopt   COMPLETE_IN_WORD       # Complete from both ends of a word
setopt   PATH_DIRS              # Perform path search even on command names with slashes
unsetopt CASE_GLOB              # Make globbing case insensitive
unsetopt FLOW_CONTROL           # Disable start/stop characters in shell editor

# Don't show a % for partial lines
export PROMPT_EOL_MARK=''

# Get into vim command mode faster when hitting ESC
export KEYTIMEOUT=1

# Don't exit on EOF (ctrl+d)
setopt IGNORE_EOF

# History
# ------------------------------------------------------------------------
HISTFILE="$ZCACHEDIR/zhistory"  # The path to the history file
HISTSIZE=10000                # The maximum number of events to save in the internal history
SAVEHIST=10000                # The maximum number of events to save in the history file

# Lists the ten most used commands
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

# Less
# ----------------------------------------------------------------------------
export LESS='-F -g -i -M -R -w -X -z-4'
export PAGER='less'

# bat
# ------------------------------------------------------------------------
if (( $+commands[bat] )); then
    alias cat=bat

    # BAT_THEME is also used by delta, so set it here rather than in the bat
    # config file
    export BAT_THEME=wezterm
fi

# fzf (https://github.com/junegunn/fzf)
# ------------------------------------------------------------------------
if (( $+commands[fzf] )); then
    export FZF_PATH=`echo $(which fzf)(:A:h:h)`

    # Make FZF respond more quickly when hitting escape
    # https://github.com/junegunn/fzf.vim/issues/248
    export ESCDELAY=10

    # Use -1 for the bg color to specify 'none'
    export FZF_DEFAULT_OPTS='--color=bg:-1,fg:-1,bg+:0,fg+:-1,hl:5,hl+:5,marker:18,gutter:-1,spinner:14,info:14'

    if [[ -d $FZF_PATH/shell ]]; then
        source $FZF_PATH/shell/completion.zsh
        source $FZF_PATH/shell/key-bindings.zsh
    fi

    source $ZDOTDIR/fzf.zsh
fi

# History key bindings
# ------------------------------------------------------------------------
# Up and down arrow keys step through local history
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
bindkey '^[[A' up-line-or-local-history
bindkey '^[[B' down-line-or-local-history

# Setup a precmd to let Terminal.app know the CWD
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    update_cwd () {
        local SEARCH=' '
        local REPLACE='%20'
        local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
        printf '\e]7;%s\a' "$PWD_URL"
    }
    [[ -z $precmd_functions ]] && precmd_functions=()
    precmd_functions=($precmd_functions update_cwd)

    # if [[ "$TERM" == "xterm-256color" ]]; then
    #     export TERM=xterm-256color-italic
    # fi
fi

# Node
# ----------------------------------------------------------------------------
# Load NPM completion
if (( $+commands[npm] )); then
    zfetch $ZPLUGDIR lukechilds/zsh-better-npm-completion
    source $ZPLUGDIR/lukechilds/zsh-better-npm-completion/zsh-better-npm-completion.plugin.zsh
fi

# TPM
# ------------------------------------------------------------------------
if [[ ! -d $XDG_DATA_HOME/tmux ]]; then
    mkdir $XDG_DATA_HOME/tmux
fi

zfetch $XDG_DATA_HOME/tmux tmux-plugins/tpm

if [[ ! -d $XDG_CACHE_HOME/tmux ]]; then
    mkdir $XDG_CACHE_HOME/tmux
fi

# mise
# ------------------------------------------------------------------------
if (( $+commands[mise] )); then
    eval "$(mise activate zsh)"
fi

# Line editor
# ------------------------------------------------------------------------

# Let vi keys jump through the suggestion
bindkey '^f' vi-forward-word
bindkey '^b' vi-forward-blank-word
bindkey '^e' vi-end-of-line

# Bun
# --------------------------------------------------------------------------
if [[ -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# 1Password
# --------------------------------------------------------------------------
if [[ -f $HOME/.config/op/plugins.sh ]]; then
    . $HOME/.config/op/plugins.sh
fi

# Google Cloud
# --------------------------------------------------------------------------
if [[ -d $HOMEBREW_BASE/share/google-cloud-sdk ]]; then
    . $HOMEBREW_BASE/share/google-cloud-sdk/path.zsh.inc
    . $HOMEBREW_BASE/share/google-cloud-sdk/completion.zsh.inc
fi

# zsh-syntax-highlighting
# --------------------------------------------------------------------------
# This should be near the end (preferably at the end) of the zshrc
# https://github.com/zsh-users/zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
zfetch $ZPLUGDIR zsh-users/zsh-syntax-highlighting
source $ZPLUGDIR/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

# zsh-history-substring-search
# --------------------------------------------------------------------------
# Load this after zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-history-substring-search
zfetch $ZPLUGDIR zsh-users/zsh-history-substring-search
source $ZPLUGDIR/zsh-users/zsh-history-substring-search/zsh-history-substring-search.zsh

# Color for found substrings
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=14,fg=0,bold'

# Color for not-found substrings
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=1,fg=0,bold'

# Default globbing flags
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

# Make history keybindings search
bindkey -M vicmd "k" history-substring-search-up
bindkey -M vicmd "j" history-substring-search-down

# zsh-autosuggestions
# --------------------------------------------------------------------------
# Load this after zsh-syntax-highlighting and zsh-history-substring-search
# (https://github.com/tarruda/zsh-autosuggestions)
zfetch $ZPLUGDIR zsh-users/zsh-autosuggestions
source $ZPLUGDIR/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh

# Use a solarized-friendly background color
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=14'

# Make autosuggest faster
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Configure autosuggest to work properly with history substring search;
# without this, trying to history-substring-search with an empty line will
# hang zsh
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)

if (( $+commands[git] )); then
    export GIT_COMMITTER_NAME=${GIT_COMMITTER_NAME:-$(git config --get user.name)}
    export GIT_COMMITTER_EMAIL=${GIT_COMMITTER_EMAIL:-$(git config --get user.email)}
    export GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-$(git config --get user.name)}
    export GIT_AUTHOR_EMAIL=${GIT_AUTHOR_EMAIL:-$(git config --get user.email)}
fi

# zoxide
# --------------------------------------------------------------------------
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --cmd cd)"
fi

# Local config
# --------------------------------------------------------------------------
[[ -f $ZCONFDIR/zshrc ]] && source $ZCONFDIR/zshrc
