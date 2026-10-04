# Completions
# ------------------------------------------------------------------------
# The completion system should be configured and enabled before sourcing
# completion plugins

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
)

# Load and initialize the completion system, ignoring insecure directories.
# Note that fpath should be configured before calling compinit.
# (https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh)
autoload -Uz compinit
# Only check for new completions (slow) if the dump is missing or more than a
# day old. compinit doesn't rewrite an up-to-date dump, so touch it to reset
# the clock.
() {
    if (( $# )); then
        compinit -C -i -d $ZCOMPFILE
    else
        compinit -i -d $ZCOMPFILE && touch $ZCOMPFILE
    fi
} $ZCOMPFILE(N.mh-24)

# Add AWS completions
if (( $+commands[aws_completer] )); then
    autoload bashcompinit && bashcompinit
    complete -C aws_completer aws
fi

# Compile the zcompfile in the background
{
    # Compile zcompdump, if modified, to increase startup speed.
    if [[ -s "$ZCOMPFILE" && (! -s "${ZCOMPFILE}.zwc" || "$ZCOMPFILE" -nt "${ZCOMPFILE}.zwc") ]]; then
        zcompile "$ZCOMPFILE"
    fi
} &!

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
    ${=${(f)"$(cat /etc/hosts(N) 2>/dev/null)"}%%\#*}
    ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns daemon nobody '_*'

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

# npm
# ------------------------------------------------------------------------
if (( $+commands[npm] )); then
    zfetch $ZPLUGDIR lukechilds/zsh-better-npm-completion
    source $ZPLUGDIR/lukechilds/zsh-better-npm-completion/zsh-better-npm-completion.plugin.zsh
fi
