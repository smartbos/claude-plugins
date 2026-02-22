# Create Pull Request

## Steps
1. Confirm current branch is NOT main or devel. If on main/devel, create a feature branch first.
2. Base branch is always `devel` unless user specifies otherwise.
3. Run tests before committing: `python -m pytest`
4. Create NEW commits (never amend existing ones).
5. Push the feature branch and create PR into `devel`.
6. Never commit design docs, plans, or analysis files unless explicitly asked.
