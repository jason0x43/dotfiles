function fvi --description 'Edit a file with vi'
	set -l tmpfile (mktemp -t fkill.XXXX)
	fzf --tiebreak=length > $tmpfile
	set -l file (cat $tmpfile)
	rm -f $tmpfile

	if test -n "$file"
		vi $file
	end
end
