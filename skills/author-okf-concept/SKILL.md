---
name: author-okf-concept
description: Author a new OKF v0.2 concept document with valid frontmatter, provenance, correct file path, links, and a validation check using the okf CLI.
---

# Author an OKF concept

Use this skill when the user asks to add a new concept to an Open Knowledge Format
(OKF) bundle. An OKF bundle is a directory tree of Markdown files with YAML
frontmatter; each non-reserved file is one concept whose ID is its bundle-relative
path without the `.md` extension, for example `tables/orders`. `index.md` and
`log.md` are reserved at every level and are never concepts.

For an `Attested Computation` concept, use the `author-okf-computation` skill
instead — it has its own contract keys and its own strict-mode rules.

## Steps

1. **Determine the concept's ID and type.** The ID is a slash-separated path such
   as `tables/orders` or `services/billing`; each segment starts with an ASCII
   letter, digit, or underscore. The `type` is a short noun phrase such as
   `PostgreSQL Table`, `Metric`, or `Policy`. Ask the user if either is unclear.

   If the bundle has a house profile, check the vocabulary it declares before
   inventing a type:

   ```bash
   okf profile show <export> --registry <registry>   # or --profile <path> via okf validate
   okf concepts <bundle> --show type                 # what the bundle already uses
   ```

2. **Check what dialect the bundle targets.** Look at the root `index.md`
   frontmatter for `okf_version: "0.2"`, or run `okf validate <bundle>` and read
   the success line — it names a declared version. Match the surrounding
   documents: write `generated` in a v0.2 bundle, and do not introduce
   `timestamp` into one.

3. **Create the file at `<bundle>/<concept-id>.md`**, creating parent directories
   as needed. Write YAML frontmatter delimited by `---` lines. Only `type` is
   required; `title`, `description`, and `generated` are what
   `okf validate --strict` asks for:

   ```yaml
   ---
   type: PostgreSQL Table
   title: Orders
   description: One row per completed customer order.
   resource: postgresql://app/public/orders
   tags: [sales, core]
   status: draft
   generated:
     by: human:nadeem
     at: 2026-08-11T00:00:00Z
   ---
   ```

   Add the optional OKF v0.2 families when the user has something true to record.
   Never invent provenance, a verification, or a usage count:

   - `generated` — who produced this content. A mapping with a required `by`
     actor and an optional `at` timestamp. Write the actor as `human:<id>`,
     `process:<id>`, or `<producer>/<version>`.
   - `verified` — independent confirmation, a mapping or a list of them, each
     with `by` and optional `at`. Distinct from `generated`: who wrote a concept
     need not be who confirmed it. Prefer the list form even for one entry.
   - `status` — `draft`, `stable`, or `deprecated`. **An absent `status` means
     `stable`**, so most concepts omit it.
   - `stale_after` — a `YYYY-MM-DD` date after which the content should be
     re-confirmed. Advisory; okf reports it but never refuses a stale concept.
   - `sources` — what the content was derived from, one entry per source, with an
     optional `id`, a `resource`, and credibility signals such as `author`,
     `usage_count` (a YAML number, not a string), and `last_modified`.
   - `usage_window` — a `from`/`to` mapping covering the period those sources were
     observed over. An entry may carry its own `usage_window`, which wins.

   Do not write a trust tier or a staleness verdict. Both are **derived on every
   read** from `verified` and `stale_after`; a `trust:` key is just an ignored
   extension field.

4. **Write the concept body** as Markdown after the frontmatter. Keep it readable
   by a human with no tooling.

   Link to another concept with a Markdown link to its `.md` file, preferring the
   bundle-absolute form so it resolves from anywhere:

   ```markdown
   Orders join to [Customers](/tables/customers.md).
   ```

   A path held in a **frontmatter** value follows the same grammar: a leading
   slash is bundle-relative, and anything else resolves against the concept's own
   directory. Write the leading slash whenever the target sits at the bundle root.

   To attribute one specific claim rather than the whole document, footnote it
   with a label that is a `sources[].id`:

   ```markdown
   The column set mirrors the upstream schema verbatim[^ddd-schema].

   [^ddd-schema]: The aggregate record in Mori's DDD schema.
   ```

   The label is the join key — `--strict` checks it in both directions. The
   footnote's prose is free to say whatever helps a human reader.

   `# Schema` and `# Examples` carry conventional meaning when applicable.
   `# Citations` is the superseded v0.1 heading; record external sources in the
   `sources` frontmatter family instead.

5. **Validate the bundle** and fix what it reports:

   ```bash
   okf validate <bundle> --strict
   ```

   A successful run prints `OK: <N> concepts`, with `(okf_version 0.2)` appended
   when the bundle declares a version. Resolve `missing required field`, `link to
   missing concept`, and `duplicate concept ID` errors before finishing. Stale-log
   findings are advisory and prefixed `log:` — they do not fail the command
   without `--log-enforce`.

   If the bundle has a house profile, check against it too. Profile deviations are
   advisory unless enforced:

   ```bash
   okf validate <bundle> --profile <profile.dhall> --profile-enforce
   ```

6. **Regenerate the indexes** if the bundle keeps generated `index.md` files, and
   append a log entry if it keeps `log.md` update logs:

   ```bash
   okf index <bundle> --write
   okf log add <bundle> <concept-id> -m "Added <concept-id>"
   ```

   `okf index --write` preserves an existing `okf_version` declaration.

## Done When

`okf validate <bundle> --strict` passes, the new concept appears in
`okf show <bundle> <concept-id>`, and `okf trust <bundle>` shows the tier and
status you intended for it.
