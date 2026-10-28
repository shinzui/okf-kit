---
name: reconcile-okf-requests-and-bugs
description: Audit and refresh existing OKF improvement requests or bug reports against implementation evidence, correcting lifecycle status and links to implementation and source plans. Use for backlog reconciliation, not authoring new reports or implementing their fixes.
---

# Refresh improvement requests and bug reports

Make the selected reports tell the truth about delivery and planning. Read their
acceptance criteria or reproduction, find the actual implementation and plans,
and apply supported corrections. A plan's existence, implementation, verification,
and release are separate facts.

## Establish the scope and baseline

Use the requested repository, bundles, or handles. If the user names no subset,
review its improvement-request and bug-report bundles. Discover them from the
project manifest, profiles, and existing documents rather than assuming directory
names. An audit request authorizes corrections to those reports and their bundle
indexes/logs; it does not imply creating plans, implementing fixes, publishing,
committing, or changing another repository.

Read repository instructions and the bundle's actual pinned profile, including
conditional fields and local plan-link conventions. Preserve stable handles,
acceptance-criterion IDs, reproduction, provenance, and historical attribution.
These profiles use a house lifecycle; do not replace it with OKF's generic
`draft`/`stable`/`deprecated` vocabulary or upgrade a profile as part of the audit.

Inventory every selected concept with its handle, status, completion or fix
metadata, plan links, and source project. Exclude reserved `index.md` and `log.md`.
For example, adapting the displayed keys to the profile:

```bash
okf concepts BUNDLE --show requestId --show status --show targetPlan --json
okf concepts BUNDLE --show bugId --show status --show fixedVersion --json
okf validate BUNDLE --profile PROFILE --profile-enforce --log-enforce
```

Run the repository's semantic validation too, when available. Keep its baseline
diagnostics so the final report distinguishes existing failures from new ones.

## Find evidence and plans

For each report, compare its required behavior with current source, focused tests,
commits, plan Progress and Outcomes, and any recorded acceptance evidence. Search
both ExecPlans and MasterPlans by stable report URI/handle, filename, behavior,
and implementation symbols. Mentions of a prerequisite or an example are not
implementation-plan ownership. A completed MasterPlan must cover this report's
criteria through its children; its title alone proves nothing.

Use Mori to discover dependency and cross-repository sources before guessing at
APIs or paths: `mori registry list`, `mori registry search NAME`,
`mori registry show PROJECT --full`, and `mori registry docs PROJECT`.
Follow the repository's configured registry wrapper where needed
(for example, `just mori-global` when the default database is a local fixture).
Read the discovered files directly. A registry snapshot may lag the checkout.
If Mori is unavailable, audit local evidence and report the cross-project checks
that could not be performed; do not guess source locations or project identities.

Inspect test assertions and their recorded results; a proposed test is not a
passing result. Run a focused local check when it resolves a material uncertainty,
using a disposable fixture if reproduction writes data. Do not replay a damaging
reproduction against live data. Broad test suites are unnecessary for metadata
corrections when existing evidence suffices. State what was inspected and what
was actually rerun.

Record an internal audit row for every selected report: current status, supported
status, plan match and role, evidence, and unresolved gaps. This catches skipped
reports and makes a no-change conclusion reviewable.

## Reconcile lifecycle

Use the pinned profile's vocabulary. The shared profiles commonly mean:

| Report | Status decision |
| --- | --- |
| Improvement request | `proposed` until accepted by the owner; `accepted` records that decision; `in-progress` needs implementation work underway; `completed` needs evidence for all acceptance criteria. |
| Bug report | `reported` is the initial claim; `confirmed` requires reproduction by the owning project; `in-progress` needs fix work underway; `fixed` requires evidence that the reported wrong behavior is corrected. |

Creating a plan does not by itself accept a request, confirm a bug, start work,
or complete either. Partial prerequisites, fixture-only proof of a live-service
requirement, an unfinished verification milestone, and a similar feature do not
satisfy the missing criteria. A direct fix can be complete without a plan; do not
invent one to make the metadata uniform.

Correct unsupported completion claims when the evidence establishes they are
false, explaining the remaining criteria. Missing evidence alone is uncertainty:
report it without guessing a new lifecycle decision. Preserve a historical fix
when a distinct later regression is what failed. Use terminal decisions such as
`rejected`, `withdrawn`, `superseded`, `wont-fix`, `duplicate`, `not-a-bug`, or
`cannot-reproduce` only with the corresponding evidence or recorded owner decision.
An unsuccessful attempt to reproduce in a different environment is not enough.

Maintain the associated metadata:

- Completed requests need `completedAt` and the profile's required resolution
  evidence. Use the time completion was demonstrated, not the audit time. Preserve
  a correct existing date. If the time cannot be established, report the gap.
- Fixed bugs need `fixedVersion`. Establish the first release containing the fix
  from authoritative release/tag evidence; use `unreleased` for a default-branch
  fix not yet released. Follow the profile's `unknown` convention if necessary and
  explain why. Do not infer a fix version from today's version or tag date alone.
- Record terminal resolutions and valid replacement/duplicate references under
  the profile's rules. Retain original affected-version and reproduction history.
- Keep frontmatter and current Status/Planning prose consistent. Preserve clearly
  dated historical statements. An audit is not an independent approval: do not
  invent `verified` or approving review entries, or overwrite original generation
  provenance to silence validation.

## Repair plan links

Distinguish the implementation plan in the receiving project from the source plan
that raised the report in another project.

- For improvement requests, use `targetPlan` for the actual owning implementation
  plan in the report bundle's project. Use `originPlan` for an evidenced source
  plan in the origin project where the consumer contract supports it. Preserve an
  `origin` that already names the source artifact.
- For bugs, inspect the house profile and nearby reports. Reuse an established
  structured plan field if one exists; otherwise add a clear Plan/Resolution body
  link. The shared bug-report profile does not declare `targetPlan` or
  `originPlan`; do not present those fields as a standard requirement.
- A verification plan can be linked, but describe it as verification of the
  original fix and preserve the original commit attribution. A prerequisite or
  source plan must not masquerade as the report's implementation plan.
- Follow recorded cancellation/supersession to the successor that now owns the
  work. Do not replace a historically correct completed plan with a newer related
  plan. If several plans deliver the work, use their governing MasterPlan when
  appropriate and describe the contributing plans in the body. Surface ambiguous
  ownership rather than choosing a title match.

Write cross-repository references as canonical artifact URIs:

```text
mori://NAMESPACE/PROJECT/plans/ID-slug
mori://NAMESPACE/PROJECT/masterplans/ID-slug
mori://NAMESPACE/PROJECT/okf/BUNDLE/concepts/HANDLE
```

Check owning project, kind, numeric ID, exact slug, and the actual plan file's
frontmatter. Check Markdown link labels against the target's stable handle too.
Repository-local Markdown links may remain relative.

Try `mori path MORI_URI` when available. For a registered improvement-request
target, prefer `mori improvement-requests link-plan --path REPO --id IR-N --plan
MORI_URI`; inspect its help before replacing an existing link. This editor changes
only the planning link, not lifecycle.

A missing registry row is different from a typo, deleted file, or wrong owner.
If the canonical artifact exists but registration or CLI coverage prevents
resolution, retain the accurate URI, make a narrow authored edit if the safe editor
cannot accept it, and report the exact validation failure. Do not strip links,
invent substitute plans, mark a request unplanned, or rewrite coordination
catalogs merely to silence the validator. Do not store derived planning/gate state
in frontmatter or claim that file existence proves registry resolution.

## Validate and deliver

Make only evidence-backed corrections. Log changed statuses with old/new values,
plan-link changes, and evidence references using `okf log add`. Record the audit
date separately from historical completion dates. If the bundle maintains generated
indexes, run `okf index BUNDLE --write`, preserving its declared OKF version.

Rerun the same profile/log and repository semantic checks as the baseline. Add
`--strict` when the bundle requires it. For Mori improvement requests the semantic
check is `mori improvement-requests validate --path REPO` using the appropriate
registry context; do not assume an equivalent bug-report subcommand exists.
Check every changed URI against its file/identity and inspect the final diff.

Summarize how many reports were reviewed, the resulting status counts, changed
statuses and links, and unresolved evidence or plan-registration gaps. Separate
passed checks from failed or unavailable checks, including any diagnostics added
by newly authored links. If all statuses were already accurate, say so. Deliver
the corrections without requiring another approval for ordinary report edits.
