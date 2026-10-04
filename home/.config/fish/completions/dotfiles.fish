set -l commands sync import forget status ignore update

complete -c dotfiles -f
complete -c dotfiles -n "not __fish_seen_subcommand_from $commands" -a sync -d 'Link repo files into ~'
complete -c dotfiles -n "not __fish_seen_subcommand_from $commands" -a import -d 'Move files from ~ into the repo and link them'
complete -c dotfiles -n "not __fish_seen_subcommand_from $commands" -a forget -d 'Move files from the repo back into ~'
complete -c dotfiles -n "not __fish_seen_subcommand_from $commands" -a status -d 'Show link problems and untracked files'
complete -c dotfiles -n "not __fish_seen_subcommand_from $commands" -a ignore -d 'Hide local files from status'
complete -c dotfiles -n "not __fish_seen_subcommand_from $commands" -a update -d 'Install and update tools'

complete -c dotfiles -n "__fish_seen_subcommand_from sync import forget" -s n -l dry-run -d 'Show what would change'
complete -c dotfiles -n "__fish_seen_subcommand_from sync" -s f -l force -d 'Back up and replace local files in the way'
complete -c dotfiles -n "__fish_seen_subcommand_from import" -s f -l force -d "Replace the repo's copy with the local file"
complete -c dotfiles -n "__fish_seen_subcommand_from import forget status ignore" -F
complete -c dotfiles -n "__fish_seen_subcommand_from update" -s i -l install -d 'Install missing things'
complete -c dotfiles -n "__fish_seen_subcommand_from update" -s l -l list -d 'List available modules'
complete -c dotfiles -n "__fish_seen_subcommand_from update" -a "(dotfiles update --list 2>/dev/null)"
