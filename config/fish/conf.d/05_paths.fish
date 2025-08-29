set -l homebrew /opt/homebrew

if test -d /home/linuxbrew
    set homebrew /home/linuxbrew/.linuxbrew
end

fish_add_path --move --path $homebrew/sbin
fish_add_path --move --path $homebrew/bin
fish_add_path --move --path $homebrew/opt/ruby/bin
fish_add_path --move --path $homebrew/opt/php@8.1/bin
fish_add_path --move --path $homebrew/opt/node@22/bin
fish_add_path --move --path /usr/local/bin
fish_add_path --move --path ~/.cargo/bin
fish_add_path --move --path ~/.dotnet
fish_add_path --move --path ~/.dotnet/tools
fish_add_path --move --path ~/.deno/bin
fish_add_path --move --path ~/.local/bin
fish_add_path --move --path ~/.dotfiles/bin
