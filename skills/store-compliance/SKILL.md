---
name: store-compliance
description: Generate the App Store / Google Play metadata, privacy, terms, permissions, SDK-audit and release-checklist pack for this app.
disable-model-invocation: true
---

# Store compliance

Produce submission-ready, review-defensible store documentation. Framework-agnostic: Flutter, bare
React Native, or Expo.

**Accurate over comprehensive.** An unknown becomes a `TODO` with an owner, never a plausible
guess, because these documents are published to users and read by a reviewer.

The document specs live in [references/documents.md](references/documents.md). The prose conventions
live in `rules/store-compliance-docs.md`. This file owns the order and the cross-checks.

## Inputs

Ask for blanks in Phase 0; a blank becomes a `TODO`.

```yaml
client_name:            app_display_name:       framework:   # auto-detect, then confirm
platforms:              # ios | android | both
primary_market:         governing_law:
support_url:  marketing_url:  privacy_policy_url:  terms_url:
contact_name/email/phone:  data_controller_contact:
output_dir:             # DEFAULT: docs/store/
```

## Phase 0. Intake

Dispatch `flutter-explore` to read the business context: `README*`, `docs/**`, `CHANGELOG`, brand
files, and any existing store configuration or release checklist.

Then ask the user one grouped batch of questions, skipping anything the inputs or the repo already
answered:

- **Positioning.** Value proposition, target audience, markets and languages, three to five
  competitors, the keywords that matter, brand voice and any banned claims.
- **Monetisation and accounts.** Business model. Whether sign-in is required or guests are allowed.
  Reviewer test credentials, and how to reach each gated flow.
- **Legal and data.** Legal entity and governing law. Whether the domain is regulated, such as
  health, finance or children. Data residency and sub-processors. The deletion and export
  mechanism. Any age gate. Existing published policy URLs.

A declined answer becomes `TODO (client input needed)`. Never invent a business fact.

## Phase 1. Signal Inventory

Dispatch `flutter-explore` again for the technical signals: manifests, plists, `*.xcprivacy`,
entitlements, dependencies, and permission declarations.

Write the result to `{output_dir}/_signals.md` as a table mapping **source file → signal →
documents affected**. No data practice, permission or third-party service is claimed in any
deliverable without a row here pointing at a file.

This file is the writer's input, and passing it as a path rather than as inlined context is what
keeps the parent's window clear.

## Phase 2. Write

Read [references/documents.md](references/documents.md) and decide which documents this app needs;
the table there gives the condition for each.

Then delegate to `store-doc-writer`, **once per document**, naming the document and passing the path
to `_signals.md`. One writer produces every file, which is what keeps the governing law, the
contacts and the URLs consistent without a reconciliation pass.

Write in this order, because each informs the next: privacy pack, then terms and subscription, then
the ASO metadata whose reviewer notes depend on both, then the release checklist.

Review each returned document before requesting the next. A contradiction caught at document three
is cheaper than one caught in Phase 3.

## Phase 3. Cross-check

One writer removes the internal-consistency problem. What remains is agreement between the
documents and the **repository**, which no writer can verify alone:

- [ ] Every `*.xcprivacy` data type appears in the privacy policy and the store labels.
- [ ] Every data-collecting service appears in the privacy policy and the labels.
- [ ] No permission is documented that is not declared, and none declared that is undocumented.
- [ ] The tracking position is identical in the privacy policy, the SDK audit and the reviewer
      notes.
- [ ] Character-limited fields are within their limits, with counts shown.
- [ ] Keywords describe features the app actually has.
- [ ] No deliverable contains a file path, manifest key, package name, version, build command or
      code identifier.

The last one is worth checking mechanically rather than by eye; a single leaked package name is the
usual failure, and it is what makes a client document read as an internal one.

## Phase 4. Report

Write `{output_dir}/_GENERATION_REPORT.md`, the internal engineering appendix and the only file
where technical detail belongs:

- The Signal Inventory, and which source backs each claim
- The Phase 0 answers used
- The Phase 3 results
- Any permission declared but never used, for removal
- The consolidated **TODO list**, each with an owner: client, dev or legal
- The **review-risk list**, each tied to a guideline section

## Completion criteria

Every document the table calls for exists, every Phase 3 box is checked or explicitly failed with
the mismatch named, and every unknown is a `TODO` with an owner.

Say plainly that the pack is a draft and which TODOs block submission. A pack handed over as
finished, with unresolved TODOs inside it, is how a rejection happens on the client's time.
