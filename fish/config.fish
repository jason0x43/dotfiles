set -x CACHEDIR $HOME/.cache
set -x DOTFILES $HOME/.dotfiles
set -x EDITOR vim
set -x GOPATH $HOME/Documents/Programming/go
set -x JAVA_HOME /Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home
set -x LESS '-F -g -i -M -R -w -X -z-4'

set -U fish_user_paths ./node_modules/.bin $HOME/Applications $GOPATH/bin
set -U fish_color_status green 
set -U fish_color_cwd cyan 

if test -e $HOME/.terminfo
	set -x TERMINFO_DIRS $HOME/.terminfo:/usr/share/terminfo
end

if test $TERM_PROGRAM = "iTerm.app"
	set_iterm_palette
end

if type -q fzf ^ /dev/null
	set -x FZF_PATH (brew --prefix fzf)
end

fish_vi_mode
