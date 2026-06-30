---
name: author-okf-concept
description: Author a new OKF concept document with valid frontmatter, correct file path, OKF links, and a validation check using the okf CLI.
---

# Author an OKF concept

Use this skill when the user asks to add a new concept to an Open Knowledge Format
(OKF) bundle. An OKF bundle is a directory tree of Markdown files with YAML
frontmatter; each file is one concept whose ID is its path without the `.md`
extension, for example `tables/orders`.

## Steps

1. Determine the concept's ID and type. The ID is a slash-separated path such as
   `tables/orders` or `services/billing`. The `type` is a short noun such as
   `Table`, `Service`, or `Policy`. Ask the user if either is unclear.

2. Create the file at `<bundle>/<concept-id>.md`, creating parent directories as
   needed. Write YAML frontmatter delimited by `---` lines:

   ```yaml
   ---
   type: Table
   title: Orders
   description: One row per customer order.
   tags: [sales, core]
   ---
   ```

   `type` is required. `title`, `description`, and `tags` are recommended. Include a
   `resource` field, such as `resource: postgresql://app/public/orders`, when the
   concept maps to a concrete system object.

3. Write the concept body as Markdown after the frontmatter. To link to another
   concept, use a Markdown link to that concept's `.md` file so okf can resolve it.
   Keep the body readable by a human with no tooling.

4. Validate the bundle and fix any reported errors:

   ```bash
   okf validate <bundle>
   ```

   A successful run prints `OK: <N> concepts`. Resolve any `missing required field`,
   `link to missing concept`, or `duplicate concept ID` errors before finishing.

5. If the bundle uses `log.md` update logs, append an entry recording the addition:

   ```bash
   okf log add <bundle> <concept-id> -m "Added <concept-id>"
   ```

## Done When

`okf validate <bundle>` passes and the new concept appears in
`okf show <bundle> <concept-id>`.
