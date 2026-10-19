# Greenfield packages

What `flutter-supabase-setup` adds to `pubspec.yaml` when it scaffolds a greenfield app on the kit's
defaults. Where the Architecture table names a different row, add that row's package instead.

| Row | `dependencies` | `dev_dependencies` |
|---|---|---|
| Logic seam `Bloc<Event, State>` | `flutter_bloc`, `equatable` | `bloc_test` |
| Data return contract | `dartz` | |
| Network | `dio` | |
| Sensitive storage | `flutter_secure_storage` | |
| Mocks | | `mocktail` |

Then run `flutter pub get`.
