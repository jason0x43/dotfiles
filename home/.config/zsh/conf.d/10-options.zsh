# Shell options
# ------------------------------------------------------------------------
# Navigation
setopt   AUTO_CD                # Change to a directory without typing cd
setopt   AUTO_PUSHD             # Push the old directory onto the stack on cd
setopt   CDABLE_VARS            # Change directory to a path stored in a variable
setopt   EXTENDED_GLOB          # Use extended globbing syntax
setopt   MULTIOS                # Write to multiple descriptors
setopt   PUSHD_IGNORE_DUPS      # Do not store duplicates in the stack
setopt   PUSHD_SILENT           # Do not print the directory stack after pushd or popd
setopt   PUSHD_TO_HOME          # Push to home directory when no argument is given
unsetopt CLOBBER                # Don't overwrite existing files with > and >>

# Files and commands
setopt   BRACE_CCL              # Allow brace character class list expansion
setopt   COMBINING_CHARS        # Combine zero-length punctuation characters (accents) with the base character
setopt   CORRECT                # Correct mis-typed commands
setopt   RC_QUOTES              # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'

# Jobs
setopt   AUTO_RESUME            # Attempt to resume existing job before creating a new process
setopt   LONG_LIST_JOBS         # List jobs in the long format by default
unsetopt BG_NICE                # Don't run all background jobs at a lower priority
unsetopt CHECK_JOBS             # Don't report on jobs when shell exit
unsetopt HUP                    # Don't kill jobs on shell exit

# History
setopt   HIST_IGNORE_ALL_DUPS   # Delete an old recorded event if a new event is a duplicate
setopt   HIST_IGNORE_SPACE      # Do not record an event starting with a space
setopt   HIST_SAVE_NO_DUPS      # Do not write a duplicate event to the history file
setopt   HIST_VERIFY            # Do not execute immediately upon history expansion
setopt   SHARE_HISTORY          # Share history between all sessions
setopt   EXTENDED_HISTORY       # Timestamp history entries

# Completion
setopt   ALWAYS_TO_END          # Move cursor to the end of a completed word
setopt   COMPLETE_IN_WORD       # Complete from both ends of a word
setopt   PATH_DIRS              # Perform path search even on command names with slashes
unsetopt CASE_GLOB              # Make globbing case insensitive
unsetopt FLOW_CONTROL           # Disable start/stop characters in shell editor
unsetopt LIST_BEEP              # Don't beep when completion is ambiguous

# Don't show a % for partial lines
export PROMPT_EOL_MARK=''

# Don't exit on EOF (ctrl+d)
setopt IGNORE_EOF

# History
# ------------------------------------------------------------------------
HISTFILE="$ZCACHEDIR/zhistory"  # The path to the history file
HISTSIZE=10000                # The maximum number of events to save in the internal history
SAVEHIST=10000                # The maximum number of events to save in the history file

# Colors
# ------------------------------------------------------------------------
export LSCOLORS='ExFxCxDxBxfxdxacagafad'
export CLICOLOR=1
