function set_iterm_scheme --argument name
	echo $name > $CACHEDIR/termbg

	if test $name = "dark"
		set fish_color_autosuggestion $PALETTE_BASE01
		set fish_color_search_match --background=black
		set -Ux FZF_DEFAULT_OPTS --color=dark,bg+:0
	else if test $name = "light"
		set fish_color_autosuggestion $PALETTE_BASE1
		set fish_color_search_match --background=white
		set -Ux FZF_DEFAULT_OPTS --color=light,bg+:7
	end

	if test -n $TMUX
		tmux source-file $DOTFILES/tmux/$name.conf > /dev/null
	end

	if test -e $HOME/.vim/refreshColors.py
		python $HOME/.vim/refreshColors.py
	end
end
