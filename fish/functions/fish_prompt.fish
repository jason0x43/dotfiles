function fish_prompt --description 'Write out the prompt'
	set -l caret
	set -l color_cwd
	set -l normal (set_color normal)
	set -l suffix
	set -l suffix_edit

	switch $USER
	case root toor
		if set -q fish_color_cwd_root
			set color_cwd $fish_color_cwd_root
		else
			set color_cwd $fish_color_cwd
		end
		set suffix '#'
		set suffix_edit '#'
	case '*'
		set color_cwd $fish_color_cwd
		set suffix '❯'
		set suffix_edit '❮'
	end

	switch "$fish_key_bindings"
	case '*_vi_*' '*_vi'
		set caret (
			switch $fish_bind_mode
			case default
				set_color cyan
				echo -n " $suffix_edit "
			case insert
				echo -n " $suffix "
			case visual
				set_color magenta
				echo -n " $suffix_edit "
			end
		)
	case '*'
		set caret " $suffix "

	end

	echo -n -s (set_color $color_cwd) (prompt_pwd) (set_color $fish_color_status) (__fish_git_prompt " git:%s") $normal $caret $normal
end
