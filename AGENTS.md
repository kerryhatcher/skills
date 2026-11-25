# Agent notes

Public repo of agent skills installable via skills.sh (`npx skills add`).

- One skill per directory: `skills/<name>/SKILL.md`. Frontmatter needs `name` (lowercase-hyphenated, equal to the directory name) and `description` (start with "Use when...").
- Copy `template/SKILL.md` to start a new skill. Put long reference material in `skills/<name>/references/` and helper scripts in `skills/<name>/scripts/`.
- **Never write a literal `$<digit>` in `SKILL.md`.** Claude Code substitutes slash-command arguments into it (`$1`, `$10`, …), which corrupts dollar amounts and awk fields when the skill is loaded with arguments. Put snippets that need awk fields or a `$5`-style amount in `scripts/` and call them; `scripts/validate.sh` fails on `$N`, `$(N)` and `${N}` in any `SKILL.md`.
- **Public repo: never include usernames, absolute home paths, hostnames, keys, tokens, or real secrets.** Use `$HOME` and placeholders.
- Run `scripts/validate.sh` before committing. Enable the pre-commit hook (TruffleHog + Trivy on staged files) with `git config core.hooksPath .githooks`; never bypass it with `--no-verify` to get a secret through.
