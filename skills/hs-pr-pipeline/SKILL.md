---
description: "Use when implementing a feature that needs a complete PR workflow: branch creation, implementation, code review, tests, and PR submission. Triggers on phrases like 'implement and create PR', 'feature to PR', 'branch and submit'."
---

Read CLAUDE.md for git workflow rules. Then implement the following feature end-to-end:

1. Create a feature branch from devel (NEVER commit to main)
2. Write a TodoWrite implementation plan BEFORE any code changes
3. Implement the changes iteratively, running tests after each logical unit
4. Use Task to spawn a sub-agent for code review against our style guidelines
5. Use Task to spawn a separate sub-agent to run the full test suite and report failures
6. Fix any issues found by review or tests
7. Create a PR to devel with a structured description referencing the issue

Feature: $ARGUMENTS

IMPORTANT:
- Think and reason in English internally, but ALWAYS communicate with the user in Korean (한국어)
- Do not amend commits—always create new ones. Do not modify .env files. Stop and ask before deleting any environment variables or changing infrastructure type declarations.
