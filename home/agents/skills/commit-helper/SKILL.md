---
name: commit-helper
description: Instructions for writing commit messages; use when the user asks you to create a commit message.
---

# Commit Message Format

Write clear, concise commit messages following the project standards. You're writing messages for other developers.

A standard commit message follows git standards -- a short message (72 characters or less), optionally followed by concise details, like:

```
Add 'create account' functionality

- add POST /account endpoint and `createAccount` method to Db class
- add 'Create' button to accounts page
```

# Other Requirements

- ONLY consider staged changes.
- Do NOT stage or unstage any changes.
- Do not mention housekeeping tasks such as updating tests in the details tests unless the commit was specifically focused on such a task.
- Do not edit any files.
