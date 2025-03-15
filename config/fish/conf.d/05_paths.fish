set -l homebrew /opt/homebrew

if test -d /home/linuxbrew
    set homebrew /home/linuxbrew/.linuxbrew
end

fish_add_path --path $homebrew/sbin
fish_add_path --path $homebrew/bin
fish_add_path --path $homebrew/opt/ruby/bin
fish_add_path --path $homebrew/opt/php@8.1/bin
fish_add_path --path $homebrew/opt/node@22/bin
fish_add_path --path /usr/local/bin
fish_add_path --path ~/.cargo/bin
fish_add_path --path ~/.deno/bin
fish_add_path --path ~/.dotfiles/bin
