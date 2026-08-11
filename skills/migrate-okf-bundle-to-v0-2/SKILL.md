---
name: migrate-okf-bundle-to-v0-2
description: Migrate an OKF v0.1 bundle to the v0.2 dialect - replace timestamp with generated, add the provenance and lifecycle families, and declare okf_version so the ratchet reports what is left.
---

# Migrate an OKF bundle to v0.2

Use this skill when the user wants an existing OKF bundle to target **OKF v0.2**:
its `timestamp` keys replaced with `generated`, the v0.2 provenance and lifecycle
families available, and `okf_version: "0.2"` declared in the root `index.md`.

## What the migration actually is

**Nothing forces this migration and nothing breaks without it.** okf reads
`timestamp` whenever `generated` is absent, silently, with no removal horizon. A
v0.1 bundle stays valid forever. Say this to the user before starting so the work
is a deliberate choice rather than a perceived obligation.

One rename matters:

```text
v0.1                              v0.2
timestamp: 2026-06-16T00:00:00Z   generated:
                                    by: human:nadeem
                                    at: 2026-06-16T00:00:00Z
```

The rename is not mechanical: `timestamp` records only *when*, and `generated`
requires a `by` actor saying *who*. That value is not in the v0.1 document, so
every rename needs an answer from the user or from the bundle's history.

`# Citations` is the other v0.1 supersession, replaced by the `sources` family.
okf never implemented `# Citations`, so there is usually nothing to do there.

## Steps

1. **Establish the starting point.**

   ```bash
   okf validate <bundle> --strict
   okf concepts <bundle> --has timestamp --show timestamp
   okf concepts <bundle> --missing generated
   ```

   The success line names any version the bundle already declares. The two
   listings are the work queue: what still carries the old key, and what has no
   provenance at all.

2. **Decide the `generated.by` actor** before editing anything. Ask the user.
   Actors are written `human:<id>`, `process:<id>`, or `<producer>/<version>`.
   Common answers:

   - The bundle is hand-written by one person → `human:<id>`.
   - The bundle is emitted by a generator → `<producer>/<version>`, and the
     generator should be changed to write it rather than the documents patched.
   - Provenance genuinely differs per concept → migrate in batches, one actor per
     batch, rather than stamping a plausible-looking uniform value.

   Do not invent an actor to make the diagnostic go away. An honest
   `process:<generator-name>` is better than a fabricated human.

3. **Rewrite each concept's `timestamp` into `generated`.** Carry the existing
   value across as `generated.at` unchanged; do not re-stamp it with today's date,
   which would destroy the only real provenance the document had.

   ```yaml
   generated:
     by: human:nadeem
     at: 2026-06-16T00:00:00Z
   ```

   Remove the `timestamp` key in the same edit. If both keys are present,
   `generated.at` wins and `timestamp` is preserved rather than dropped — which is
   correct behavior for a bundle in flight, but a finished migration should not
   leave both.

4. **Adopt the other v0.2 families only where there is something true to record.**
   All of them are optional, and a migration is not a reason to invent data.

   - `verified` — add only where a real confirmation happened. It is what the
     derived trust tier reads: any `by` with the `human:` prefix makes a concept
     `human-reviewed` rather than `machine-confirmed`.
   - `status` — `draft`, `stable`, or `deprecated`. Absent means `stable`, so
     leave it off unless the concept is genuinely a draft or deprecated.
   - `stale_after` — a `YYYY-MM-DD` re-confirmation deadline, for facts that decay
     on a schedule whether or not anyone edits the document.
   - `sources` / `usage_window` — what the content was derived from. If the body
     has an ad-hoc citations list or a `# Citations` heading, this is where it
     goes; give each entry an `id` and footnote the claims that depend on it.

5. **Declare the version — this is the ratchet, so do it once the bulk is done.**

   ```bash
   okf index <bundle> --write --okf-version 0.2
   ```

   Or write `okf_version: "0.2"` in the root `index.md` frontmatter by hand.
   Regenerating indexes afterwards preserves the declaration.

   Declaring turns on one strict-mode diagnostic per concept still carrying
   `timestamp`, naming the file to fix. An undeclared bundle never gets those,
   which is why declaring is deliberate: it is how the team makes the remainder of
   the migration visible instead of forgotten.

6. **Work the ratchet to zero.**

   ```bash
   okf validate <bundle> --strict
   ```

   Repeat until no superseded-field diagnostics remain. Declaring the version
   early and burning the list down is a legitimate strategy — the diagnostics are
   strict-mode only, so a normal `okf validate` still exits 0 throughout.

7. **Verify the result reads the way the user expects.**

   ```bash
   okf validate <bundle> --strict       # expect: OK: <N> concepts (okf_version 0.2)
   okf trust <bundle>                   # derived tiers, status, staleness
   okf sources <bundle>                 # recorded provenance
   okf concepts <bundle> --has timestamp   # expect: nothing
   ```

8. **Consider ratcheting further with a profile.** The format keeps every v0.2
   family optional. A team that wants `generated` or `sources` *required* writes a
   house profile, which can also require the declaration itself with
   `requireBundleVersion = Some "0.2"`, reported by
   `okf validate --profile P` and made fatal with `--profile-enforce`. Offer this;
   do not do it unasked.

## Done When

`okf validate <bundle> --strict` prints `OK: <N> concepts (okf_version 0.2)`,
`okf concepts <bundle> --has timestamp` lists nothing, and every `generated.by`
value names an actor the user actually stands behind.
