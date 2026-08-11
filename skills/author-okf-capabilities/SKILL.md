---
name: author-okf-capabilities
description: Author a profile-governed OKF capability catalog at docs/capabilities for a project - what it provides to a consumer today, one concept per capability with a stable CAP-N handle and evidence a reader can open, with the record set shaped by the project's type.
---

# Author a capability catalog

Use this skill when the user asks for a capability catalog, a "what does this
project provide" bundle, or `docs/capabilities/` for a repository.

A capability catalog is an OKF v0.2 bundle governed by the shared
`coordination.capabilities` profile from `mori://shinzui/okf-profiles`. It answers
one question for someone deciding whether to depend on this repository: **what
does its code do today, and what proves it?**

You are deriving claims from source, tests, and release history, usually with no
prior catalog to adapt. **Fabrication is the central risk.** Everything below
exists to prevent it.

## The three rules that decide what becomes a record

**1. Evidence or it does not exist.** Every capability names at least one artifact
a reader can open — a test, a conformance fixture, an example, a benchmark, a
module, or a guide. Confirm the path exists before writing it. A capability you
cannot evidence is an improvement request, not a capability. There is deliberately
no `planned` status.

**2. Provision, not composition.** A capability is something *this repository's
code* does. A claim that is only true when several repositories cooperate cannot
be asserted or proven by any one of them; it belongs to the consuming repository
as a use-case feature. Test: the record must read correctly to someone who has
never heard of the other repositories in the portfolio. A claim that cannot be
phrased without naming a sibling service is usually a composition claim in
disguise.

**3. One capability is one thing a consumer adopts *and* verifies
independently.** Where two candidates always ship together and are proven by the
same evidence, they are one capability. A catalog with one record per exported
module or per subcommand is a worse copy of the API reference, and is the main way
this format fails. Group by shared *mechanism*, not shared theme.

## Step 1: Classify the project, because the type decides the record set

Read `mori.dhall` for the project's declared `type`, or infer it. The three rules
are constant; what counts as a package, an interface, and evidence is not.

| Project type | `packages` | `interface` | Strongest evidence | The granularity trap |
|---|---|---|---|---|
| **library** | What a consumer adds to `build-depends` / their manifest | Exported module names and the top-level functions actually called | Test modules, then runnable examples, then the module implementing the guarantee | One record per exported module |
| **framework** | Same as library | What a consumer *writes against*: effects, typeclasses, generated code, config surfaces | Guides and runnable examples carry more weight — a framework capability is only real if a consumer can wire it | One record per API surface, when the guarantee is the capability |
| **tool / CLI** | The package shipping the binary | Command and subcommand families (`mori deps`, `mori registry dependents`) | Tests, then user guides, then embedded help topics | One record per subcommand. Thirty command families may honestly be a dozen capabilities |
| **application / service** | The deployable | Endpoints, consumed queues, scheduled jobs | Integration tests, runbooks | Most claims here are composition claims under rule 2. Expect few records, or none |
| **documentation / schema-only / internal scaffold** | — | — | — | Usually has no consumer-facing surface at all — see below |

**Library is the reference case.** `mori://shinzui/shibuya` at `docs/capabilities/`
is the worked example: ten records for a queue-processing library, `packages:
[shibuya-core]`, `interface` naming modules like `Shibuya.Policy`, evidence
pointing at spec files that prove each guarantee, and one record (`CAP-5`) split
out from another because the behavior arrived in a later release.

**If the repository has no consumer-facing surface** — a schema-only package, a
pinned artifact, an internal scaffold nothing else adopts — report that capability
adoption is not applicable and stop. Do **not** create an empty bundle, profile,
log, or Mori entry.

**If `docs/capabilities/` already uses this profile**, treat the run as an
idempotent reconciliation: preserve every valid `CAP-N` handle, repair only what is
missing, and do not rewrite conforming records.

## Step 2: Inventory the real surface

Gather in this order, because later sources correct earlier ones:

1. **Packages and their descriptions** — what units a consumer can depend on.
2. **Exported modules, public API, or CLI command tree** — the surface touched.
3. **Tests** — the strongest evidence, and the honest bound on what is proven.
4. **User documentation and README** — often already a feature list, but written
   to persuade.
5. **Release history / changelog** — the only reliable source for `since`.

Read module headers rather than trusting names. They frequently say the quiet part
directly: that a path is a stub, an in-memory default, or proven only against a
fixture.

## Step 3: Install the profile verbatim

Write `docs/capabilities/profile.dhall` as a pinned import. **Do not reconstruct
the profile from memory and do not inline its rules.**

```dhall
https://raw.githubusercontent.com/shinzui/okf-profiles/v0.9.0/profiles/coordination/capabilities.dhall
  sha256:e0ff6ca5f909d9bcdc0ec0e04c987ed8a84f927be6f62fdf871911c069f46161
```

Prefer copying the file from a sibling repository that already has one, or from
`blueprints/adopt-capabilities/files/capabilities-profile.dhall` in
`mori://shinzui/okf-profiles`, so the pin matches what the rest of the portfolio
validates against. If you must bump the version, take the Dhall hash from the
repository — never guess one.

## Step 4: Decide the capability set

Group the inventory by rule 3, then assign a stable `CAP-N` handle numbered from 1
in a stable order. Two judgments recur:

**A capability that grew** never moves an older record's `since` forward, and never
claims an early `since` for behavior that arrived later. Apply one test:

> Could a consumer pinned to the older release still do the thing this record
> describes?
>
> - **No — impossible for them.** Split. The grown form takes its own record with
>   the later release as `since`, and `requires` the older one.
> - **Yes, just less well** — fewer checks, weaker guarantees, more manual work.
>   Same record, original `since`, describe the evolution in the body.

When genuinely ambiguous, prefer the same record with a body note. An over-split
catalog reads as a changelog with handles.

**`stability` is not `status`.** Availability and compatibility are different
questions: a shipped capability in a pre-1.0 project is usable *and* unstable. In a
project with a uniform compatibility promise the field is uniform — that is
correct, not a defect.

## Step 5: Write the records

One file per capability at the bundle root, flat, plus the reserved `index.md` and
`log.md` (which are not concepts).

```yaml
---
title: "Human-readable capability name"
type: Capability
description: "One sentence a consumer can evaluate without reading the body."
generated:
  by: <producer>/<version>          # your actor identity; NOT human:<id>
  at: "2026-08-11T00:00:00Z"        # RFC3339 UTC
capabilityId: CAP-1                 # bundle-scoped, stable, matches CAP-<number>
provider: mori://<namespace>/<project>
status: shipped                     # shipped | deprecated | withdrawn
stability: experimental             # experimental | stable
since: "0.8.0.0"                    # see the vocabulary below
packages:
  - example-core
interface:                          # recommended; shape depends on project type
  - Example.Module
requires:                           # optional: CAP-N handles or mori:// URIs
  - CAP-2
evidence:                           # required, at least one entry
  - kind: test                      # test | conformance | example | benchmark | module | guide
    resource: test/ExampleSpec.hs
    proves: What a reader learns by opening it.
---
```

Field notes that catch people:

- `replacedBy` is **required** once `status` is `deprecated` or `withdrawn`. A
  retirement with no forward path is the failure mode the profile catches.
- `evidence[].resource` is **not checked by okf** — a path rule resolves only
  within the bundle's concept tree, and capability evidence is repository-wide.
  Verify every path yourself.
- `requires` must be **mirrored as a Markdown body link**. okf derives graph edges
  from body links only, so a frontmatter-only requirement validates cleanly and is
  invisible to `okf graph`.
- `reviews` is profile-recommended and machine-authored records will not have it.
  Do not fabricate review provenance to silence the diagnostic.
- Set `generated.by` to your own `<producer>/<version>` identity. **Never write a
  `human:` actor for content you authored** — that prefix is what separates the
  `human-reviewed` trust tier from `machine-confirmed`, and claiming it misreports
  the tier.

`since` uses exactly one of three spellings; do not invent a fourth, and never
append commentary to a version:

| Value | Use when |
|---|---|
| `"1.2.0"` | It arrived in an identifiable release. Bare version, no commentary. |
| `unreleased` | It exists only on the default branch. |
| `unknown` | Release history does not record it. **Explain in the body why** — that sentence is the point of the value. |

For each record body: state what it does in the consumer's terms, give the
shortest real usage that shows the shape, and **write a truthful `Limits`
section**. An in-memory default, a fixture-only proof, a stub live path, an
operational footgun — record it. That section is what makes the catalog worth
trusting, and the temptation to soften it is exactly why it is required.

Write `index.md` with `okf_version: "0.2"`, a short statement of what the
repository provides, an explicit note of anything deliberately excluded, and a
table of the records. Write `log.md` with one dated entry describing the adoption.

## Step 6: Register and validate

Add the bundle to `mori.dhall` so the catalog is queryable across every registered
repository:

```dhall
, okfBundles =
  [ Schema.OkfBundle::{
    , name = "capabilities"
    , path = "docs/capabilities"
    , profile = Some "docs/capabilities/profile.dhall"
    , okfVersion = "0.2"
    , description = Some "What <project> provides today, one concept per capability, with evidence"
    }
  ]
```

If `dhall type` reports `Missing record field: OkfBundle`, the pinned
`mori-schema` predates the field — run `mori schema upgrade` first.

Then:

```bash
mori validate
okf validate docs/capabilities --profile docs/capabilities/profile.dhall \
  --profile-enforce --log-enforce
okf graph docs/capabilities
```

Validation must pass. Inspect the graph and confirm there is an edge for every
`requires` entry — a missing edge means a requirement was not mirrored as a body
link. `--strict` additionally reports the recommended `reviews` family; for a
machine-authored catalog that is expected output, not a failure.

## Step 7: Report

The gaps matter more than the catalog. Report:

- The capability set and why the grouping is what it is.
- What you excluded, and under which of the three rules.
- **Every gap the evidence requirement exposed** — untested packages, stub live
  paths, surfaces that turned out to be documentation-only. These are the most
  valuable output, because they are things the repository did not know it was
  claiming.
- Any `since` you could not establish from release history.

## Done When

`okf validate docs/capabilities --profile docs/capabilities/profile.dhall
--profile-enforce --log-enforce` exits 0, `okf graph` shows an edge for every
declared `requires`, `mori validate` passes with the bundle registered, and every
`evidence[].resource` names a file that exists.
