#!/bin/sh
current_pid=$1
while [ -n "$current_pid" ] && [ "$current_pid" -gt 1 ] 2>/dev/null; do
	env_output=$(ps eww -p "$current_pid" -o command= 2>/dev/null)
	window_id=$(printf "%s\n" "$env_output" | grep -o "KITTY_WINDOW_ID=[^[:space:]]*" | head -n1 | cut -d= -f2)
	if [ -n "$window_id" ]; then
		echo  "$window_id"
		exit 0
	fi
	current_pid=$(ps -p "$current_pid" -o ppid= 2>/dev/null | tr -d "[:space:]")
done

exit 1
