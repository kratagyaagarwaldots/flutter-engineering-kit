---
name: flutter-localization
description: Add or extend localization: ARB files, plurals, RTL layouts and locale-aware formatting, including migrating off a static strings class. Use when adding a language, localizing an app, handling RTL, or asked about i18n, l10n, translations or AppStrings.
---

# Flutter localization

Localizing is mostly mechanical. The part that is not, and the part this skill exists for, is that
**the kit's `AppStrings` convention and `gen_l10n` are two answers to the same question**, and a
codebase running both has no single source for its copy.

Decide which one owns user-facing strings before writing anything.

## 1. Resolve the conflict first

`flutter-core-architecture` §3 makes every user-facing string a `static const` on `AppStrings`. That
is a good convention for a single-language app: one file, compile-time constants, no lookup.

It cannot localize, because a `const String` cannot vary by locale.

| Situation | Do this |
|---|---|
| One language, no plans | Keep `AppStrings`. Localizing costs more than it returns |
| One language now, more later | Keep `AppStrings`, and keep it disciplined. The migration below is mechanical only because every string is already in one place |
| Localizing now | Migrate to ARB, and `AppStrings` keeps only what is genuinely not user-facing |

Record the choice in `docs/agents/project.md`, because every skill that writes a widget needs to know
which one to reach for. A half-migrated app is the worst outcome: a translator cannot find the
strings, and a developer cannot tell which file is current.

## 2. Set up

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

Then wire `localizationsDelegates` and `supportedLocales` into the app root, and export the generated
class from the barrel so the single-import rule still holds.

## 3. Migrate, key by key

```json
{
  "@@locale": "en",
  "orderStatusPending": "Pending",
  "@orderStatusPending": {
    "description": "Shown on the order card while awaiting confirmation"
  }
}
```

Two rules that decide whether the translation is any good:

**Write a `description` for every key.** A translator sees the string and nothing else. "Open" is a
verb or an adjective, and only the description says which.

**Never concatenate.** `'You have ' + count + ' items'` cannot be translated: word order differs by
language. Use a placeholder, and let ICU handle the grammar.

## 4. Plurals and gender

English has two plural forms. Arabic has six, Polish has four, Japanese has one. Hard-coding
`count == 1 ? 'item' : 'items'` is correct in English and wrong nearly everywhere else.

```json
{
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Count of items in the cart",
    "placeholders": { "count": { "type": "int" } }
  }
}
```

ICU picks the right form per locale, including forms English does not have.

## 5. RTL

Arabic, Hebrew, Farsi and Urdu mirror the layout. Flutter does most of this if you let it:

| Use | Instead of |
|---|---|
| `EdgeInsetsDirectional.only(start:, end:)` | `EdgeInsets.only(left:, right:)` |
| `AlignmentDirectional.centerStart` | `Alignment.centerLeft` |
| `TextAlign.start` | `TextAlign.left` |
| `PositionedDirectional` | `Positioned` |

Directional icons need flipping too: a back chevron points the other way in RTL, while a play button
does not. Test by forcing the locale rather than reasoning about it.

## 6. Formatting is locale-aware too

Dates, numbers and currency are part of localization and are usually forgotten:

```dart
DateFormat.yMMMd(locale).format(date);
NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
```

Never format a date with string interpolation. Day-month order, separators and numerals all differ,
and a hard-coded format silently shows the wrong date rather than an obviously wrong one.

## 7. Test it

- A widget test per locale for one screen, asserting the translated string appears.
- A test in an RTL locale asserting no overflow. Translated text is frequently longer than English,
  German especially, and this is where fixed-width containers break.
- A test that every key in the template ARB exists in every other ARB. A missing key falls back
  silently, so nothing else catches it.

Call the Skill tool with `flutter-write-tests` for where these live.

## Completion criteria

Every user-facing string resolves through the chosen mechanism, every key has a description, plurals
use ICU rather than a conditional, and the choice is recorded in `docs/agents/project.md`.

Name every string you left un-migrated and why. A partial migration is the failure mode here, so an
explicit list is what makes it finishable.
