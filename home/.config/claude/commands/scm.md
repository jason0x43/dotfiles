---
description: Generate a squash merge commit message body for the current branch
argument-hint: "[base-branch]"
allowed-tools: Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git symbolic-ref:*), Bash(git show:*)
---

Write the body of a squash merge commit message for the current branch.

## Context

- Current branch: !`git branch --show-current`
- Remote default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo "(unknown)"`
- Working tree status: !`git status --short`

## Base branch

Use `$ARGUMENTS` as the base branch if given. Otherwise use the remote
default branch above (e.g. `origin/main`), falling back to `main`, then
`master`. Compare from the merge base, never against the base branch's tip.

## Gather the changes

1. `git log --reverse --format='%h %s%n%n%b' <base>..HEAD` for the
   branch's commit history.
2. `git diff --stat <base>...HEAD` for the shape of the change.
3. `git diff <base>...HEAD` for the change itself. Read it: the message
   describes what the branch actually changes, not just what the commit
   subjects claim. Intermediate fixups, reverts and review churn that
   cancel out in the final diff do not belong in the message.

If the branch has no commits ahead of the base, say so and stop. If the
working tree has uncommitted changes, mention that they are not included.

## Message rules

- Body only: no subject/summary line. The output starts directly with the
  first paragraph of the body.
- Wrap every line at 72 characters. Never break a URL, path or code token
  across lines.
- Separate paragraphs and lists with a single blank line. No trailing
  whitespace, no blank line at the start or end.
- Use the imperative mood ("Add", "Fix", "Remove"), as if completing
  "This change will ...".
- Explain what changed and why, not how: the diff already shows how.
  Lead with the motivation or problem, then the change.
- Use plain-text bullets (`- `) for lists of distinct changes, with
  continuation lines indented two spaces to align under the text.
- Keep it proportional: a small branch gets a sentence or two, a large
  one gets short paragraphs and/or a bulleted list.
- No Markdown headings, bold, or other formatting a plain `git log` would
  show literally. Backticks around identifiers are fine.
- Preserve any `Fixes #123`, `Closes #123`, `Co-authored-by:` or other
  trailers found in the branch's commits, placed at the end after a blank
  line. Do not add any other trailers or attribution lines.

## Output

Print the message inside a single fenced code block (```text) so it can be
copied as-is, with nothing else inside the block. Do not commit, merge or
modify anything.
