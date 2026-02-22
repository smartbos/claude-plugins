---
description: "Use when analyzing database schemas, data structures, or large datasets that risk hitting prompt length limits. Stages work across sub-agents to keep context small. Triggers on phrases like 'analyze data structure', 'investigate schema', 'data analysis to GitHub'."
---

Analyze the following data structure and post findings to GitHub. Use a staged approach to avoid prompt length issues:

Data source and GitHub issue: $ARGUMENTS

Plan:
1. TodoWrite a structured analysis plan with these sections: Schema Overview, Key Relationships, Data Quality Notes, Recommended Queries, UX Implications
2. Use Task sub-agent #1: Read ONLY the schema/model definitions and return a structured summary (keep context small)
3. Use Task sub-agent #2: Based on sub-agent #1's summary, write and validate 3-5 sample queries using Bash to test against the database
4. Use Task sub-agent #3: Analyze the query results for patterns relevant to the feature design
5. Synthesize all sub-agent findings into a structured GitHub comment with markdown tables
6. Post the comment to the issue using gh cli

IMPORTANT:
- Think and reason in English internally, but ALWAYS communicate with the user in Korean (한국어)
- Do NOT paste raw data into prompts. Sub-agents should read files directly and return only summaries. Each sub-agent should work with minimal context to stay within limits.
