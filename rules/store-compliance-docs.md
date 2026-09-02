---
description: Conventions for generated store/compliance Markdown documents — no fabrication, provenance, character budgets, policy citations, readability, and PDF-friendly formatting.
paths:
  - "docs/store/**/*.md"
---

# Store & Compliance Doc Conventions

When creating or editing any file under `docs/store/`:

- **No fabrication.** Bundle IDs, URLs, contacts, company names, prices, dates, and business
  facts must come from the repo, inputs, or user intake — otherwise write `TODO` (with an
  owner: client / dev / legal). Never a plausible guess.
- **Provenance goes in the report, not the client docs.** Keep source traceability (which
  file/intake answer backs each claim) in `_GENERATION_REPORT.md`. Do **not** litter
  client-facing documents (Privacy Policy, Terms, metadata copy) with inline
  `source: <file>` notes — see "Readability & audience" below.
- **Never print secrets.** Report presence + handling posture only.
- **Character budgets.** iOS name/subtitle 30, promo 170, keywords 100; Play title 30, short
  80, full 4000. Show counts where a field is tight.
- **Policy citations.** Compliance assertions cite an Apple App Review or Google Play policy
  section, or `TODO (policy unfetched)`.
- **Consistency.** Governing law, contacts, and URLs must match across every document.
- **Conditional content.** Omit sections for capabilities the app does not have.

## Readability & audience (write for humans + PDF, not for agents)

These documents are read by clients, lawyers, and store reviewers, and are often exported to
PDF for sign-off. Write them as finished, human-friendly deliverables:

- **Plain professional prose.** No internal jargon — never use "Signal Inventory", "signal",
  "fixture", raw file paths, or SDK package names as nouns in client-facing copy. Expand every
  acronym on first use (e.g. "App Tracking Transparency (ATT)"). Full sentences, short
  paragraphs.
- **Self-explaining.** A reader with no access to the codebase must fully understand every
  document. Define terms; never point at a repo artefact in the text.
- **No code in ANY deliverable.** Every generated document — including the Permissions,
  Third-Party Services, and Launch Readiness documents — is written for a non-technical reader.
  Do **not** put file paths, manifest keys (`NSCameraUsageDescription`, `uses-permission`…),
  `Info.plist`/`AndroidManifest`/`Podfile` references, dependency or package names as they
  appear in `pubspec.yaml`/`package.json`, version strings, class/function names, build
  commands (`flutter build`, `gradle`, `eas`), or "where used in code" columns into any file
  under `docs/store/`. Refer to features by what the user experiences ("signing in with
  Google", "getting trip notifications"), and to services by their public brand name
  ("Google Sign-In", "Sentry crash reporting") — never by their code identifier.
- **The only home for technical detail is `_GENERATION_REPORT.md`.** Source files, manifest
  keys, package/version specifics, unused-permission flags, and build tooling belong there —
  it is the internal engineering appendix, kept separate from the client deliverables.
- **Structure for reading.** Clear `#`/`##` headings; **number legal sections** (1, 1.1, 2 …)
  so clauses are referenceable; dates written in full ("7 July 2026"); a short intro sentence
  under each major heading.
- **Lead with tables — make it scannable.** For reference-style content (listing fields,
  permissions, third-party services, keywords, screenshots, checklists, TODOs), use tidy tables
  with short cells and a clear header row, not long paragraphs or values buried in prose. Reserve
  prose for legal clauses and descriptions that genuinely need sentences. Keep counts/limits/
  status in a column (e.g. `Limit | Fits?`), never as inline annotations like "30/30 used".
- **Never dump internals or quotes.** No "Signal Inventory" / evidence / source-mapping section
  in any deliverable, and no long verbatim App Store / Play guideline quotes — summarise the rule
  in one plain sentence and cite only its section number. Evidence and full policy text belong in
  `_GENERATION_REPORT.md`.
- **End with a single "Still needed / TODO" table** (columns: Item | Owner) so open items are in
  one obvious place, not scattered through the document.
- **Clean Markdown that converts well to PDF.** Standard headings/lists/tables only (no exotic
  inline HTML), so `pandoc`/print produces a tidy document. Keep table columns narrow enough to
  fit an A4/Letter page. Privacy Policy and Terms are the pages the client publishes at the
  store-required URLs — a reader exports them to PDF via "Open the `.md` → Print → Save as PDF",
  or the client's team hosts them, so keep them self-contained and free of internal references.
