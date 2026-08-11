---
name: author-okf-computation
description: Author an OKF v0.2 Attested Computation concept - the five contract keys, the exactly-one-computation rule, bundle-absolute reference paths, and the strict-mode checks that catch each mistake.
---

# Author an OKF Attested Computation

Use this skill when the user asks to record a sanctioned computation in an Open
Knowledge Format bundle — a metric, a total, a rate — so a consumer can confirm a
number came from running the blessed computation rather than from an agent
improvising its own query. This is OKF v0.2 §10.

For an ordinary concept, use the `author-okf-concept` skill instead.

## What okf does and does not do here

**okf never executes a computation and never attests one.** §10 says OKF "records
the computation and the means to check it; it does not execute anything itself",
and puts the receipt and the verdict outside the bundle entirely. Nothing in this
skill runs, fetches, or judges anything. If the user expects `okf` to produce a
number, correct that expectation first.

The type string is matched **exactly and case-sensitively**: `Attested
Computation`. It is the only thing that selects a concept into `okf computations`
and the §10 checks. A typo silently produces an ordinary concept that no check
applies to.

## The five contract keys

- **`runtime`** — REQUIRED for this type. What would run the computation, and
  therefore what a parameter *means*: a SQL bind variable, a dbt var, a Python
  argument. `postgres`, `duckdb`, `python`.
- **`parameters`** — the typed named holes an agent may fill. Each entry has a
  `name` and optionally a `type` and `required`. `required` must be a YAML
  **boolean**; the string `"true"` is read as no declaration at all. An entry with
  no textual `name` is skipped entirely.
- **`computation`** — a path to a file holding the computation, used *instead of*
  an inline block.
- **`executor`** — run instructions plus the receipt fields a run must return:
  `resource` naming the instructions, and `receipt` listing the fields.
- **`attester`** — deterministic, no-LLM code that inspects a receipt and returns
  a verdict: `resource` naming the script.

## Steps

1. **Confirm the runtime and the parameters with the user.** A parameter is a hole
   an agent is permitted to fill; everything else about the computation is fixed.
   Get the boundary right before writing — it is the whole point of the concept.

2. **Choose one of the two computation forms.** §10.3 permits exactly one:

   - **Inline**: one fenced or indented code block in the body under a
     `# Computation` heading, and **no** `computation` key.
   - **By path**: a `computation` key naming a file, and **no** `# Computation`
     block.

   Both, or neither, or more than one block under the heading, are authoring
   errors `okf validate --strict` reports. Prefer inline for a short statement the
   reader should see in the document; prefer a path when the computation is long,
   is shared, or is already under version control as a real file.

3. **Write the concept**, conventionally under a `computations/` directory:

   ```yaml
   ---
   type: Attested Computation
   title: Order total for a placed order
   description: Sanctioned computation of an order's total from its lines.
   tags: [ordering, attested-computation]
   status: stable
   runtime: postgres
   parameters:
     - name: order_id
       type: uuid
       required: true
   executor:
     resource: /references/skills/run-on-postgres.md
     receipt: [statement_id, executed_sql, result]
   attester:
     resource: /references/attesters/order-total.py
   generated:
     by: human:nadeem
     at: 2026-08-01T00:00:00Z
   ---

   # Computation

       SELECT SUM(quantity * unit_amount_minor) AS total_minor
       FROM order_lines
       WHERE order_id = :order_id

   # Notes

   The total of an [Order](/aggregates/order.md) is the sum over its
   [Order Line](/entities/order-line.md) entities.

   An agent may supply a value for `order_id` and nothing else. It may not author
   or edit the statement.
   ```

4. **Write every path-valued field bundle-absolute, with a leading slash.**
   `computation`, `executor.resource`, and `attester.resource` are §6.2 paths, so
   a bare `references/x.py` on a concept in `computations/` resolves against *that
   concept's own directory* and names `computations/references/x.py`.
   `okf validate --strict` reports it as dangling and tells you the leading-slash
   spelling it would have accepted.

5. **Put the executor and attester files under `references/`.** This is a naming
   convention, not a requirement, and the directory is not special to okf: a `.md`
   file under it is an ordinary concept and needs a `type`, while a `.py` or `.sql`
   file under it is not a concept at all and is only ever the target of a path.
   `okf index` lists those non-Markdown files rather than generating an empty
   index for the directory.

6. **Link the consumers to the computation.** A concept that needs the value — a
   Metric, a table — links to it with an ordinary Markdown link, so each attests on
   its own run rather than trusting a cached number:

   ```markdown
   Computed by [Order total](/computations/order-total.md).
   ```

7. **Validate and inspect.**

   ```bash
   okf validate <bundle> --strict
   okf computations <bundle>
   okf show <bundle> computations/order-total --computation
   ```

   `--computation` prints just the computation, in whichever of the two forms the
   producer chose.

## The strict-mode checks and what each means

Every one of these is `--strict` only, for this type alone. §11's conformance list
reaches none of them and separately forbids rejecting a bundle over an
unrecognized `type` — marking `runtime` REQUIRED binds the *producer*, it does not
license a consumer to refuse the bundle.

- `Attested Computation concepts must declare runtime` — add `runtime`.
- No computation at all — add the `# Computation` block or the `computation` key.
- A computation both inline and by path — remove one.
- More than one code block under `# Computation` — merge into one block, or move
  the computation to a file and delete the heading.
- A dangling `computation`, `executor.resource`, or `attester.resource` — usually
  a missing leading slash; see step 4.

A team that wants these enforced by default writes a house profile and runs
`okf validate --profile P --profile-enforce`.

## Done When

`okf validate <bundle> --strict` passes, the concept appears in
`okf computations <bundle>`, `okf show <bundle> <concept-id> --computation` prints
exactly the computation the user sanctioned, and every consumer that needs the
value links to it.
