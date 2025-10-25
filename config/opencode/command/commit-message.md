---
description: Generate a commit message
agent: commit-writer
---

Generate a commit message for the staged changes.

Only return the commit message, no analysis, commentary, or other explanation.

Process:

1. Ensure there are staged changes. If none, stop.
2. Gather context:
   !`git diff --staged`
3. Use recent log messages as formatting style examples:
   !`git --no-pager log -n 10`
4. Generate a commit message based on the staged changes and recent log
   messages.
