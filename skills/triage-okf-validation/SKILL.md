---
name: triage-okf-validation
description: Triage okf validate failures, strict-mode authoring diagnostics, profile deviations, and log advisories, then propose minimal fixes for an OKF v0.2 bundle.
---

# Triage OKF validation

Use this skill when the user asks for help fixing `okf validate` output for an
Open Knowledge Format (OKF) bundle. An OKF bundle is a directory tree of Markdown
concept files with YAML frontmatter; each concept ID is its bundle-relative path
without the `.md` extension.

## Know what is actually a failure

`okf validate` reports four kinds of finding, and they do not all fail the
command. Establish which kind you are looking at before proposing a fix.

- **Conformance errors** (default mode, always fatal): unparseable frontmatter, a
  missing or empty `type`, a value of the wrong shape, a link to a `.md` concept
  the bundle does not hold, a duplicate concept ID, a malformed `log.md`.
- **Strict authoring diagnostics** (`--strict` only, fatal in that mode): the
  recommended fields and every check on an optional v0.2 family. These are
  authoring aids, not a conformance bar — OKF conformance forbids rejecting a
  bundle for a missing optional field or an unrecognized `type`.
- **Profile deviations** (`--profile`, prefixed `profile:`): advisory unless
  `--profile-enforce` is passed.
- **Log advisories** (prefixed `log:`): advisory unless `--log-enforce` is passed.

If the user is worried about `log:` lines on a command that exited 0, say so
plainly rather than editing anything.

## Steps

1. **Reproduce**, unless the user has already provided fresh output. Run the
   permissive check first so real errors are not buried in strict diagnostics:

   ```bash
   okf validate <bundle>
   okf validate <bundle> --strict
   ```

   Add `--profile <profile.dhall>` when the bundle has a house profile.

2. **Group the failures** by concept ID or file path, and fix the conformance
   errors first. A missing `type` or a parse failure can cascade into link
   findings that disappear on their own.

3. **Match each finding to its cause.** The ones that need more than a re-read:

   - `link to missing concept: X` — the body links to `X.md`, which the bundle
     does not hold. Fix the link target, or ask before creating `X`. Prefer the
     bundle-absolute spelling `/tables/customers.md`.
   - A **dangling frontmatter path** (`resource`, `computation`,
     `executor.resource`, `attester.resource`) — checked only under `--strict`. A
     relative path resolves against the *concept's own directory*, so a bare
     `references/x.py` on a concept in `computations/` names
     `computations/references/x.py`. okf names the leading-slash spelling that
     would have resolved; write that. `sources[].resource` is deliberately never
     path-checked — it may name a scope descriptor rather than a file.
   - `missing generated field (or legacy timestamp)` — the concept has neither.
     Add `generated:` with a `by` actor rather than reaching for `timestamp`.
   - `generated` without a `by` actor — `by` is the one required member.
   - A `sources` entry missing its `resource`, or two entries sharing an `id`.
   - A **footnote label naming no `sources` entry, or a `sources` id no footnote
     cites**. The label is the join key. Each direction is checked only when the
     other side opted in, so a document with no `sources` may use footnotes as
     ordinary prose.
   - A **superseded v0.1 field in a bundle declaring `okf_version: "0.2"`** —
     this diagnostic only appears because the bundle declared a version. It is the
     migration ratchet; see the `migrate-okf-bundle-to-v0-2` skill.
   - **`Attested Computation` findings** (no `runtime`; no computation at all;
     one both inline and by path; more than one code block under `# Computation`)
     — see the `author-okf-computation` skill.
   - `log:` advisories — a concept's `generated` date is newer than the newest
     entry in its nearest enclosing `log.md`. Fix with `okf log add`, not by
     editing the concept.

4. **Inspect the smallest relevant set of files** per failure. Prefer minimal
   edits that preserve the user's wording and the bundle's existing structure.
   Never invent provenance, a verification, or a source to silence a diagnostic —
   an empty `generated.by` is worse than a reported missing one.

5. **Do not create a concept to satisfy a dangling link** unless the user has
   asked for it. Ask first.

6. **Re-run validation** in the same mode the user cares about:

   ```bash
   okf validate <bundle> --strict
   ```

## When a diagnostic should not be silenced

If the finding is telling the truth about the bundle — a genuinely unverified
concept, a source with no followable resource, a type the house profile does not
know — say so and propose the alternative rather than editing the document:

- The team wants this **enforced** on every concept: that is a house profile
  (`okf validate --profile P --profile-enforce`), not a frontmatter edit.
- The team wants this **not reported**: drop `--strict`, or stop declaring
  `okf_version` if the finding is version-gated. Both are deliberate choices to
  surface, not to make silently.

## Done When

`okf validate <bundle>` (with the flags the user runs in CI) exits 0, or the
remaining findings are listed with a clear explanation of which kind each is,
whether it is fatal, and why it needs user input.
