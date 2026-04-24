---
name: code-reviewer
description: General-purpose code review skill for agent-driven development; use after making updates to code.
---

# Code Reviewer

Use this skill to review code during agent-driven development. This skill is for internal agent feedback loops, not user-facing review reports.

## Purpose

Produce a fast, high-signal review of proposed or completed changes before handoff. Focus on catching issues early, tightening the implementation, and preventing unnecessary or unfinished changes from being left behind.

## Required Execution Model

- Always perform the review in a subagent, not inline in the main agent.
- Use the latest Claude Sonnet model available to the environment for the review subagent.
- Give the subagent the exact scope to review: changed files, diff, relevant constraints, and any intended behavior.
- Ask the subagent for findings only. Do not ask it to edit code.

## Review Priorities

Evaluate the changes for:

- General code quality
- Security issues and misuse of trust boundaries, secrets, permissions, shell execution, file access, and input handling
- Use of modern language and framework idioms that match the surrounding codebase
- In-progress, accidental, or unnecessary changes left in the updated code

## What To Look For

### Code Quality

- Correctness issues, edge cases, broken control flow, and missing error handling
- Overly complex changes that could be smaller or clearer
- Confusing naming, dead code, commented-out code, debug prints, and TODOs without justification
- Missing or insufficient tests when the repo already expects them
- Regressions against existing patterns or repository conventions

### Security

- Injection risks, unsafe shell usage, unsanitized inputs, path traversal, insecure temp file handling
- Leaked secrets, tokens, credentials, internal URLs, or machine-specific values
- Overly broad permissions, insecure defaults, missing validation, and unsafe deserialization
- Logging of sensitive data or persistence of sensitive material in repo files

### Modern Idioms

- Deprecated APIs, outdated framework patterns, or unnecessary legacy compatibility code
- Code that fights the language or framework instead of using the current idiomatic approach
- New abstractions that are heavier than the surrounding code style requires

### In-Progress Or Unnecessary Changes

- Temporary flags, placeholders, stubs, scaffolding, or incomplete branches
- Formatting-only churn unrelated to the task
- Drive-by refactors not needed for the requested change
- Leftover imports, unreachable code, disabled tests, or partial migrations

## Review Procedure

1. Gather the exact review scope.
2. Launch a review subagent on the latest Claude Sonnet model.
3. Provide:
   - the user goal
   - the implementation intent
   - the files or diff to review
   - repo-specific constraints or conventions
4. Ask for prioritized findings with file references.
5. Apply only findings that are real, actionable, and in scope.
6. If no meaningful findings exist, report that clearly and note any residual testing gaps.

## Expected Output From The Subagent

The subagent should return:

- A short list of findings ordered by severity
- File paths and line references when possible
- Why each issue matters
- A brief note when no findings are present
- Any residual risk or testing gap that still deserves attention

## Reporting Style

- Keep feedback direct and implementation-oriented.
- Prefer concrete defects and risks over stylistic commentary.
- Do not optimize for politeness or explanation to an end user.
- Avoid speculative complaints unless they identify a real risk.
- If a change is acceptable, say so briefly and move on.

## Default Review Prompt

Use this as the baseline prompt for the review subagent and adapt it to the task:

```text
Review these changes for agent-driven development feedback. Focus on actionable findings only.

Evaluate:
- code quality and correctness
- security
- modern language/framework idioms
- unfinished, accidental, or unnecessary changes left in the code

Return:
- prioritized findings only
- file/line references when available
- why each finding matters
- a short statement if no findings are present
- residual risks or testing gaps if relevant
```
