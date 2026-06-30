---
name: triage-okf-validation
description: Triage okf validate failures and propose minimal fixes for an Open Knowledge Format bundle.
---

# Triage OKF validation

Use this skill when the user asks for help fixing `okf validate` failures in an
Open Knowledge Format (OKF) bundle. An OKF bundle is a directory tree of Markdown
concept files with YAML frontmatter. Each concept ID is its path without the
`.md` extension.

## Steps

1. Run validation unless the user has already provided fresh output:

   ```bash
   okf validate <bundle>
   ```

2. Group the failures by concept ID or file path. Handle structural failures first:
   missing required `type` frontmatter, malformed YAML, duplicate concept IDs, and
   links to missing concept files.

3. For each failure, inspect the smallest relevant set of files. Prefer minimal edits
   that preserve the user's wording and existing bundle structure.

4. Fix broken links by using Markdown links to the target concept's `.md` file. If the
   target concept does not exist and the user has not asked to create it, ask before
   inventing a new concept.

5. Re-run validation after edits:

   ```bash
   okf validate <bundle>
   ```

## Done When

`okf validate <bundle>` prints `OK: <N> concepts`, or the remaining failures are listed
with a clear explanation of why they need user input.
