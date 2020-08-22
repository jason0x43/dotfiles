function set_iterm_color -a index value
	if test -n "$TMUX"
		# The escape codes must be prefixed when running in tmux
		echo -ne "\033Ptmux;\033\033]P$index$value\033\\"
	else
		echo -ne "\033]P$index$value\033\\"
	end
end
