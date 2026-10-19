## `<component>`: Flutter app

Code under `<path>` is a Flutter app. Its flavors, Architecture table, verification surfaces and
extra commands are its section of [docs/agents/project.md](docs/agents/project.md).

Shared patterns (barrel imports, theming, common widgets, dialogs, network, services, failures,
fixtures) are owned by the kit's `flutter-core-architecture` skill. Call the Skill tool with it
before creating or extending anything shared, rather than working from a restated copy of its rules.

```
lib/
├── core/       components/ constants/ error/ models/ network/
│              repositories/ router/ services/ utils/
└── features/{feature}/  <logic seam folder>/ model/ repo/ view/ widget/
```

Features live under `lib/features/` — read that directory rather than trusting a list here.

### Hard rules

- All imports through the barrel; no cross-feature imports (share via `lib/core/`).
- No hardcoded colours, strings, assets or dimensions. Font sizes stay unscaled so OS text scaling
  works; layouts differ by breakpoint rather than by scaling. No `dynamic`. No
  `var` — declare explicit types, prefer `final`/`const`.
- No navigation, snackbars, dialogs or `BuildContext` in the logic seam. Emit state; react in a
  listener.
- Break a complex `build` into private `StatelessWidget` classes rather than methods returning
  `Widget`.
- Repositories follow the Data return contract row: `<reads Future<T?>; writes
  Future<Either<Failure, T>>>`.
- Sensitive values go in `flutter_secure_storage`, never `shared_preferences`.
