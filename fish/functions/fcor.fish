function fcor --description 'Checkout a git ref'
	set -l refs
	git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}' | while read line
		set refs "$refs""$line"\n
	end

	git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}' | while read line
		set refs "$refs""$line"\n
	end

	set -l tmpfile (mktemp -t fgco)
	# echo -n "$refs" | fzf-tmux -r30 -- --no-hscroll --ansi +m -d "\t" -n 2 > $tmpfile
	echo -n "$refs" | fzf --ansi +m -d "\t" -n 2 > $tmpfile
	set -l ref (cat $tmpfile | awk '{print $2}')
	rm -f $tmpfile

	if test -n "$ref"
		git checkout $ref
	end
end
