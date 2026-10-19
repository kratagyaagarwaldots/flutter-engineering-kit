---
name: flutter-supabase-release
description: Produce what a Flutter app or Supabase backend component ships: signed release builds per flavor and platform, the store submission pack, and the steps only a person can take. Use when asked for the release slot of a component this kit serves, or when building a Flutter release or refreshing its store pack.
---

# Flutter + Supabase release

The `release` slot for every component whose Kit is `flutter-supabase`. It is called once the
release is known to be safe and gated; its job is what ships, and the honest list of what a person
still has to do.

Read `docs/agents/project.md` first: the component's row (its Build command), and its section's
Identity, Flavors, Platforms and Commands.

## 1. Flavor and version

Name the flavor this target ships: the live flavor for a store, the flavor the tester group runs
otherwise. Read the `version:` in `pubspec.yaml`: the build number after the `+` has to be above
the last one uploaded to each store, which rejects a reused one.

Done when the flavor and the version are named, and the build number is confirmed new.

## 2. Build each platform

For every platform in the Platforms row, build the flavor with the component's Build command. Where
flavors are native product flavors, that is:

| Platform | Command | Produces |
|---|---|---|
| Android | `flutter build appbundle --release --flavor <flavor>` | an `.aab` under `build/app/outputs/bundle/` |
| iOS | `flutter build ipa --release --flavor <flavor>` | an `.ipa` under `build/ios/ipa/` |

Where the flavor is selected by a gitignored `.env` or a script instead, run the Switch flavor
command first and build without `--flavor`.

Done when each artifact exists and its path is named.

## 3. Signing

Check each artifact is signed for release, never printing a secret:

- **Android.** The upload keystore the release `signingConfig` in `android/app/build.gradle.kts`
  reads, usually through a gitignored `android/key.properties`. An `.aab` signed with the debug key
  is rejected on upload; `keytool -printcert -jarfile <aab>` shows which key signed it.
- **iOS.** A distribution certificate and an App Store provisioning profile for the bundle id in
  the Identity table. `flutter build ipa` fails without them, and the error names which is missing.

A credential that does not exist yet is not something to work around. Report it as a step only a
person can take, with what is missing.

Done when every artifact is confirmed release-signed, or its missing credential is named.

## 4. The store pack

Call the Skill tool with `store-compliance` when this is the app's first store submission, or when
the release adds a permission, an SDK, a data type collected, a subscription, or a new market. For
any other release, check that the existing pack under `docs/store/` still matches the app, and name
anything that drifted.

Done when the pack is written, refreshed, or confirmed unchanged.

## A Supabase backend

What ships is the migrations under `supabase/migrations/` added since the last release, and any
changed edge function under `supabase/functions/`. List them. Applying them to the target project
(`supabase db push`, `supabase functions deploy`) changes a live database, so it is a step a person
confirms, never one run here. Fuller Supabase release steps arrive with the Supabase skills.

## Completion criterion

Hand back, per component:

- Each artifact by flavor and platform, with its path, its version and how it is signed.
- The store pack: written, refreshed, or confirmed unchanged, with every `TODO (client input
  needed)` item and who owns it.
- What only a person can do: the upload to Google Play Console and App Store Connect, TestFlight or
  internal-testing distribution, submitting for review, applying backend migrations, and any
  credential that is missing.

An artifact not built, or a signing state not checked, is reported as such, never as done.
