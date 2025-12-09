# Fish Shell Completions for opencode
# Completions work for both 'opencode' and 'oc' alias

# Helper functions

function __opencode_using_command
  set -l cmd (commandline -opc)
  if test (count $cmd) -gt 1
    if test $argv[1] = $cmd[2]
      return 0
    end
  end
  return 1
end

function __opencode_no_subcommand
  set -l cmd (commandline -opc)
  if test (count $cmd) -eq 1
    return 0
  end
  set -l subcommands acp attach run auth agent upgrade uninstall serve web models stats export import github pr session
  for subcommand in $subcommands
    if test $subcommand = $cmd[2]
      return 1
    end
  end
  return 0
end

# Global options (available for all commands)
complete -c opencode -s h -l help -d "Show help"
complete -c opencode -s v -l version -d "Show version number"
complete -c opencode -l print-logs -d "Print logs to stderr"
complete -c opencode -l log-level -x -a "DEBUG INFO WARN ERROR" -d "Log level"
complete -c opencode -s m -l model -x -d "Model to use (provider/model)"
complete -c opencode -s c -l continue -d "Continue the last session"
complete -c opencode -s s -l session -x -d "Session ID to continue"
complete -c opencode -s p -l prompt -x -d "Prompt to use"
complete -c opencode -l agent -x -d "Agent to use"
complete -c opencode -l port -x -d "Port to listen on (default: 0)"
complete -c opencode -l hostname -x -d "Hostname to listen on (default: 127.0.0.1)"

# Subcommands
complete -c opencode -n __opencode_no_subcommand -a acp -d "Start ACP (Agent Client Protocol) server"
complete -c opencode -n __opencode_no_subcommand -a attach -d "Attach to a running opencode server"
complete -c opencode -n __opencode_no_subcommand -a run -d "Run opencode with a message"
complete -c opencode -n __opencode_no_subcommand -a auth -d "Manage credentials"
complete -c opencode -n __opencode_no_subcommand -a agent -d "Manage agents"
complete -c opencode -n __opencode_no_subcommand -a upgrade -d "Upgrade opencode to latest or specific version"
complete -c opencode -n __opencode_no_subcommand -a uninstall -d "Uninstall opencode and remove all files"
complete -c opencode -n __opencode_no_subcommand -a serve -d "Start a headless opencode server"
complete -c opencode -n __opencode_no_subcommand -a web -d "Start a headless opencode server"
complete -c opencode -n __opencode_no_subcommand -a models -d "List all available models"
complete -c opencode -n __opencode_no_subcommand -a stats -d "Show token usage and cost statistics"
complete -c opencode -n __opencode_no_subcommand -a export -d "Export session data as JSON"
complete -c opencode -n __opencode_no_subcommand -a import -d "Import session data from JSON file or URL"
complete -c opencode -n __opencode_no_subcommand -a github -d "Manage GitHub agent"
complete -c opencode -n __opencode_no_subcommand -a pr -d "Fetch and checkout a GitHub PR branch, then run opencode"
complete -c opencode -n __opencode_no_subcommand -a session -d "Manage sessions"

# Disable file completions for all commands except import
complete -c opencode -f

# Subcommand-specific completions

# attach <url>
complete -c opencode -n "__opencode_using_command attach" -x -d "URL of running opencode server"

# run [message..]
complete -c opencode -n "__opencode_using_command run" -x -d "Message to run"

# upgrade [target]
complete -c opencode -n "__opencode_using_command upgrade" -x -d "Specific version to upgrade to"

# models [provider]
complete -c opencode -n "__opencode_using_command models" -x -d "Provider to list models for"

# export [sessionID]
complete -c opencode -n "__opencode_using_command export" -x -d "Session ID to export"

# import <file> - Only this command gets file completions
complete -c opencode -n "__opencode_using_command import" -F -d "JSON file to import"

# pr <number>
complete -c opencode -n "__opencode_using_command pr" -x -d "PR number to fetch and checkout"

# Copy all completions for the 'oc' alias
complete -c oc -w opencode

# vim:ft=fish
