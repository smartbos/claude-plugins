---
description: "Use when debugging a complex bug that benefits from parallel investigation. Spawns multiple sub-agents to trace code paths, write reproduction tests, and check environment differences simultaneously. Triggers on phrases like 'debug with parallel agents', 'investigate bug in parallel', 'find root cause'."
---

I need you to investigate and fix this bug using parallel sub-agents:

Bug: $ARGUMENTS

Approach:
1. Read the issue and relevant code to form 3 distinct hypotheses about the root cause
2. Spawn 3 Task sub-agents IN PARALLEL, each investigating one hypothesis:
   - Sub-agent A: Trace the code path and identify where the behavior diverges from expected
   - Sub-agent B: Write a minimal reproduction test that demonstrates the failure
   - Sub-agent C: Check for environment/configuration/schema differences that could cause this
3. Collect all TaskUpdate results and synthesize findings
4. Write a failing test first (TDD), then implement the fix
5. Run the full test suite to confirm no regressions
6. Post findings as a structured GitHub issue comment with: Root Cause, Evidence, Fix Applied, Tests Added

IMPORTANT: Think and reason in English internally, but ALWAYS communicate with the user in Korean (한국어).
