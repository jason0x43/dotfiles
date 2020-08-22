function fgd --description 'Diff with a git commit'
	set -l tmpfile (mktemp -t fgco)
	git log --graph --abbrev-commit --decorate --date-order --date=relative \
		--format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %s - %an%C(bold yellow)%d%C(reset)' \
		$argv | fzf --ansi +s +m -e > $tmpfile
	set -l commit (cat $tmpfile | sed -E "s/[^[:xdigit:]]+([[:xdigit:]])/\1/" | sed "s/ .*//")
	rm -f $tmpfile

	if test -n "$commit"
		git diff $commit
	end
end
