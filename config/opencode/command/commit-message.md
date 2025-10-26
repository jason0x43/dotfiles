---
description: Generate a commit message
agent: commit-writer
---

Generate a commit message for the staged changes.

You must return ONLY the commit message. Do not show any analysis, commentary,
or the output of any intermedia commands.

Process:

1. Ensure there are staged changes. If none, stop.
2. Gather context:
   !`git diff --staged`
3. Use recent log messages as formatting style examples:
   !`git --no-pager log -n 10`
4. Generate a commit message based on the staged changes and recent log
   messages.
