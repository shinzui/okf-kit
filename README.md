# okf-kit

Reusable AI-agent skills and subagents for [okf](https://github.com/shinzui/okf),
installable with `okf kit install <name>`.

## Layout

- `kit.json` is the manifest the `okf kit` command reads.
- `skills/<name>/` is a skill directory with at least a `SKILL.md`.
- `agents/<name>.md` is a subagent persona file.

## Included Items

- `author-okf-concept`: a skill for authoring a new OKF concept document with valid
  frontmatter, paths, links, and validation.
- `triage-okf-validation`: a skill for diagnosing `okf validate` failures and making
  minimal bundle fixes.
- `okf-guide`: a subagent persona for OKF authoring and validation.

## Add A Skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter containing `name` and
   `description`.
2. Add an entry to `kit.json` under `skills` with `name`, `description`, `path`
   such as `skills/<name>`, and `files` such as `["SKILL.md"]`.
3. Commit and push. Users get it with `okf kit update` or
   `okf kit install <name>`.
