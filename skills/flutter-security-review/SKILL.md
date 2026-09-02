---
name: flutter-security-review
description: Security and quality audit for the codebase covering secrets, storage, network, state, webview, and code quality. Use before releases, for security audits, code reviews, or quality assessments.
---

# Flutter security review

An audit across six pillars, run before a release or over a feature that touches credentials,
storage, the network, or a WebView.

This skill reads and reports. Fixes land only once the user has approved them, because a security
edit made silently is one nobody reviewed.

For the conventions a finding is judged against, call the Skill tool with
`flutter-core-architecture`. For whether a branch does what the spec asked, call the Skill tool with
`flutter-code-review`; that is a different question from this one and the two do not substitute.

## Required context

- **Scope**: a feature path (`lib/features/X`) or `all`
- **Recent changes** (optional): a file list to prioritise

## Severity

- Critical – must fix immediately
- High – fix before release
- Medium – should fix soon
- Info – consider improving

## Pillar 1 – secrets and keys

| Pattern | Severity |
|---------|----------|
| Hard-coded API keys / tokens / credentials | Critical |
| JWT-shaped strings in source | Critical |
| `sk_` / `pk_` (Stripe-style) prefixes | Critical |
| Base64 blobs that look like secrets | Critical |
| Secrets committed to git history | Critical |

```dart
// BAD
const apiKey = 'sk_live_abc123';

// GOOD
const apiKey = String.fromEnvironment('API_KEY');
```

## Pillar 2 – local storage

| Pattern | Severity |
|---------|----------|
| Passwords in `SharedPreferences` | Critical |
| Raw tokens in `SharedPreferences` | High |
| Payment data in unencrypted storage | Critical |
| Sensitive data persisted without encryption | High |

```dart
final secureStorage = const FlutterSecureStorage();
await secureStorage.write(key: 'token', value: token);
```

## Pillar 3 – network security

| Pattern | Severity |
|---------|----------|
| `badCertificateCallback: (_, __, ___) => true` | Critical |
| `android:usesCleartextTraffic="true"` in release | Critical |
| Dev / UAT URLs in release builds | Critical |
| No certificate pinning for sensitive APIs | High |

## Pillar 4 – BLoC state

| Pattern | Severity |
|---------|----------|
| Passwords listed in state `props` | High |
| Tokens listed in state `props` | High |
| Payment secrets in state | Critical |
| Sensitive data not cleared after use | High |

```dart
emit(state.copyWith(password: '', token: null));
```

## Pillar 5 – WebView

| Pattern | Severity |
|---------|----------|
| WebView loading arbitrary URLs | High |
| No URL validation before loading | High |
| JavaScript enabled unnecessarily | Medium |

```dart
const allowedHosts = ['api.example.com', 'secure.example.com'];
final uri = Uri.parse(url);
if (!allowedHosts.contains(uri.host)) {
  showError('Invalid URL');
  return;
}
```

## Pillar 6 – code quality

| Pattern | Severity |
|---------|----------|
| Empty `catch` blocks | High |
| Self-recursive repository methods | Critical |
| `loading` emitted without subsequent `success` / `failure` | High |
| Cross-feature imports (`lib/features/A` → `lib/features/B`) | Medium |
| Hardcoded colors / strings / sizes | Medium |
| `BuildContext` used after async without `context.mounted` guard | High |
| File under `lib/` importing something other than the project barrel | Medium |
| New project file missing from the barrel | Medium |
| Bespoke widget where the project's shared component set already has one | Info |
| Redundant doc comments restating the signature | Info |
| Commented-out code or `TODO` markers left behind | Medium |

Pillar 6 judges against `flutter-core-architecture` and whatever the project documents. Read
`lib/core/` for the components and helpers that actually exist before reporting a reuse finding; a
recommendation to use something the repo does not have costs more than the finding is worth.

## Findings table

Every finding cites a real `file:line` you have read. A pattern you expect to exist but did not find
is not a finding.

| # | Pillar | File | Line | Severity | Description | Fix |
|---|--------|------|------|----------|-------------|-----|
| 1 | Secrets | lib/core/network/api_client.dart | 42 | Critical | Hard-coded API key | Move to `--dart-define` |
| 2 | Storage | lib/features/auth/repo/auth_repository.dart | 78 | High | Token in SharedPreferences | Migrate to `FlutterSecureStorage` |

Redact as you go. This skill has you quote source that holds live keys: write `<REDACTED>` in place
of any real credential value, including in the description column.

## Workflow

1. Run all six pillars over the scope, in order.
2. Present the findings table, worst severity first.
3. Apply the fixes the user approves, Critical first.
4. Re-run `flutter analyze` and the test suite, and compare against the baseline in
   `docs/agents/project.md`.

## Completion criteria

The audit is done when all six pillars have been run over the whole scope and each has an explicit
result, including the ones that found nothing. Report:

- The findings table, or "no findings" per pillar.
- Which pillars you could not complete, and what blocked them.
- For every applied fix, the before and after, and the re-run output.

A pillar skipped in silence reads as a pillar that passed, which is the failure this criterion
prevents.

## Dependencies a fix may need

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  flutter_dotenv: ^5.0.0  # optional
```
