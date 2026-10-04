#
# Executed for login shells, after .zshenv
#

# On macOS, /etc/zprofile runs path_helper, which moves the system directories
# to the front of the path (ahead of Homebrew, etc.). Restore the order set in
# .zshenv, keeping any new entries path_helper added at the end.
if (( ${#_zshenv_path} )); then
    path=($_zshenv_path $path)
fi
unset _zshenv_path
