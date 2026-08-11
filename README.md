# okf-kit

Reusable AI-agent skills and subagents for [okf](https://github.com/shinzui/okf),
installable with `okf kit install <name>`.

The items here track **OKF v0.2**, the dialect okf implements. They keep v0.1
bundles working: `timestamp` is still read wherever `generated` is absent, and no
skill removes it outside a deliberate migration.

## Layout

- `kit.json` is the manifest the `okf kit` command reads.
- `skills/<name>/` is a skill directory with at least a `SKILL.md`.
- `agents/<name>.md` is a subagent persona file.

## Included Items

Skills:

- `author-okf-concept`: authoring a new concept with valid frontmatter, the
  optional v0.2 provenance, trust, and lifecycle families, footnote attribution,
  links, and a validation check.
- `author-okf-computation`: authoring an `Attested Computation` (v0.2 §10) — the
  five contract keys, the exactly-one-computation rule, and bundle-absolute
  reference paths.
- `migrate-okf-bundle-to-v0-2`: moving a v0.1 bundle onto v0.2 — `timestamp` into
  `generated`, adopting the new families, and declaring `okf_version` so the
  strict-mode ratchet reports what is left.
- `triage-okf-validation`: diagnosing `okf validate` output and making minimal
  bundle fixes, including which findings are fatal and which are advisory.

Subagents:

- `okf-guide`: a persona for OKF authoring, validation, and inspection.

## Add A Skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter containing `name` and
   `description`.
2. Add an entry to `kit.json` under `skills` with `name`, `description`, `path`
   such as `skills/<name>`, and `files` such as `["SKILL.md"]`.
3. Commit and push. Users get it with `okf kit update` or
   `okf kit install <name>`.
