function fkill --description 'Kill a process' --argument signal
	set -l tmpfile (mktemp -t fkill.XXXX)
	ps -ef | sed 1d | fzf -e -m | awk '{print $2}' > $tmpfile
	set -l pid (cat $tmpfile)
	rm -f $tmpfile

	if test -n "$pid"
		set -l cmd 'kill'
		if test -n "$signal"
			set cmd "$cmd -$signal"
		end
		eval "$cmd $pid"
	end
end
