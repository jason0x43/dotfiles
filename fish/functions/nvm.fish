function nvm
	set -x NVM_DIR $HOME/.nvm
	bass source (brew --prefix nvm)/nvm.sh ';' nvm $argv
end
