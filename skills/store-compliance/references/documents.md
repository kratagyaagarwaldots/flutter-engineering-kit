# The document pack

One spec per document. `store-doc-writer` reads the one it was assigned; the orchestrator uses the
table to decide which documents exist for this app.

| Document | Written when |
|---|---|
| `APP_STORE_MetaData.md` | Always |
| `Privacy_Policy.md` | Always |
| `Permissions_Audit.md` | Any permission is declared |
| `ThirdParty_SDK_Audit.md` | Any third-party service is present |
| `Terms_Conditions.md` | Always |
| `Subscription_Compliance.md` | In-app purchases or subscriptions detected |
| `Production_Release_Checklist.md` | Always |

Front matter on every file:

```yaml
---
app: { app_display_name }
client: { client_name }
framework: { detected }
generated: { ask the host for the date }
platforms: { platforms }
policy_sources_fetched: { date }
status: DRAFT — verify TODOs before submission
---
```

---

## `APP_STORE_MetaData.md`

Scannable, table-led, read top to bottom. Character limits go in a tidy **Limit / Fits?** column,
never as inline annotations in the prose.

1. **Listing at a glance.** One table per store: Field | Value | Limit | Fits?

   | Field | Value | Limit | Fits? |
   |---|---|---|---|
   | App name | Example Name – Short Tag | 30 | 24/30 |
   | Subtitle | What it does, in five words | 30 | 28/30 |
   | Promotional text | … | 170 | 140/170 |
   | Keywords | comma,separated,terms | 100 | 94/100 |

   Google Play: Title 30, Short description 80, Full description 4000. App Store: name 30,
   subtitle 30, promotional text 170, keywords 100, description 4000.

2. **Descriptions.** The full App Store and Play descriptions as readable blocks with short headed
   sub-sections. The character count goes once under each block.
3. **Categories, rating and links.** Field | Value | Notes, covering primary and secondary category,
   age-rating status, copyright, and the support, marketing, privacy and terms URLs.
4. **Keywords and ASO.** Primary keywords as Keyword | Type | Why it fits, then a secondary list and
   a localisation plan as Locale | Priority | Notes. Add a line or two on keyword placement in the
   title and subtitle, and on why stuffing them is counterproductive.
5. **Screenshots and preview.** # | Screen, named as the user sees it | Suggested caption, plus the
   required device classes. Do not commit to a count before the assets exist.
6. **What's new.** A short release-notes block.
7. **Reviewer notes.** Test accounts, one row per role. How to reach each key flow, named by the
   on-screen journey. A one-line justification for every sensitive permission and any review point,
   such as why an external payment method is used.
8. **Still needed before submission.** One TODO table: # | Item | Owner (client, dev or legal).

Keywords must describe features the app actually has (App Review 2.3, and Play's metadata policy).

---

## `Privacy_Policy.md`

What the client publishes at the store-required Privacy Policy URL, so it is self-contained prose
rather than an internal analysis.

A section **only** for data the app actually handles, each traced to a signal: personal
information, device information, analytics, crash reporting, location, camera, photos,
notifications, contacts, microphone, Bluetooth, health, payment information, authentication,
third-party services, storage, retention, sharing or sale, user rights, account deletion, data
export, GDPR, CCPA, app tracking, children's privacy, security, and contact.

Omit any section with no signal behind it. State the tracking position explicitly either way.

---

## `Permissions_Audit.md`

Titled for a non-technical reader: what the app can access, and why. One row per capability.

| Permission | What it lets the app do | Why it is needed | The message shown when asked |
|---|---|---|---|

Plain names: "Location", "Notifications", "Photos". No manifest keys and no code locations. The
fourth column is the exact prompt wording to use, which is what the reviewer checks against.

A permission that is declared but never used does **not** get justified here. Note it in
`_GENERATION_REPORT.md` for the team to remove, because an unused permission is a rejection risk.

---

## `ThirdParty_SDK_Audit.md`

Titled as the outside services the app relies on. One row per service, by public brand name.

| Service | What it is used for | What information it may receive | Used to track you across other apps | Privacy policy |
|---|---|---|---|---|

"Google Sign-In", not the package name. Close with a short note on how these rows map to the
store's privacy questionnaire, since that is what the client fills in next.

---

## `Terms_Conditions.md`

Published at the store-required Terms URL. Acceptance, eligibility, user responsibilities,
acceptable use, intellectual property, payments, subscriptions, refunds, cancellation, suspension,
limitation of liability, disclaimer, a reference to the privacy policy, governing law from the
intake, and contact.

Fold in any regulated-domain terms the intake surfaced. An unknown entity, jurisdiction or contact
becomes `TODO (client input needed)`.

---

## `Subscription_Compliance.md`

Only when in-app purchases or subscriptions are detected. Verify auto-renewable compliance, a
Restore Purchases path, and disclosure of pricing, billing period, free trial and auto-renewal,
plus cancellation instructions and links to privacy and terms. Cover Apple's requirements (App
Review 3.1.x) and Google Play Billing's.

List what is missing, each with the concrete rejection risk it carries.

Where no purchase signal exists, the file is one line: no in-app purchases or subscriptions
detected, not applicable.

---

## `Production_Release_Checklist.md`

A launch-readiness checklist a project manager or client can tick off, not an engineering runbook.
Group into milestones and phrase each item as an outcome:

- **App identity and versioning.** Version number set for this release. Name, icon and splash
  screen finalised.
- **Quality and stability.** Release build tested on real iPhones and Android phones. Crash
  reporting confirmed working. Notifications tested end to end.
- **Links and journeys.** Notification taps and shared links open the right screen.
- **Privacy and compliance.** Privacy policy and terms published and linked in both stores. Store
  privacy questionnaire completed and consistent with the app.
- **Store listings.** Screenshots and descriptions uploaded. Age rating set.
- **Pre-release testing.** Build shared to internal testers and signed off.
- **Submission.** Submitted to App Store review. Submitted to Google Play review.

No build commands, tool names, file paths, signing internals or environment variables. Those are
engineering steps and go in `_GENERATION_REPORT.md`.

Where a release checklist already exists under `docs/`, extend and reconcile it rather than
creating a competitor, and note the reconciliation in the report.
