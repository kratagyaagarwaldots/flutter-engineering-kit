# Logic tests: ProviderContainer

There is no `blocTest` equivalent, so the sequence of states is collected by hand. A
`ProviderContainer` per test keeps them isolated, and the `addTearDown` disposes it.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:<package_name>/core/router/exports.dart'; // name from pubspec.yaml
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  late _MockUserRepository mockRepository;

  ProviderContainer makeContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => mockRepository = _MockUserRepository());

  group('started', () {
    const UserData mockUser =
        UserData(id: '1', name: 'Test', email: 't@example.com');

    test('emits [loading, success] when the repository returns data', () async {
      when(() => mockRepository.fetchUser()).thenAnswer((_) async => mockUser);

      final ProviderContainer container = makeContainer();
      final List<UserState> emitted = <UserState>[];
      container.listen(
        userNotifierProvider,
        (_, next) => emitted.add(next),
        fireImmediately: false,
      );

      await container.read(userNotifierProvider.notifier).started();

      expect(
        emitted.map((UserState s) => s.status),
        <UserStatus>[UserStatus.loading, UserStatus.success],
      );
      expect(emitted.last.data, mockUser);
    });

    test('emits [loading, failure] when the repository returns null', () async {
      when(() => mockRepository.fetchUser()).thenAnswer((_) async => null);

      final ProviderContainer container = makeContainer();
      final List<UserState> emitted = <UserState>[];
      container.listen(userNotifierProvider, (_, next) => emitted.add(next));

      await container.read(userNotifierProvider.notifier).started();

      expect(emitted.last.status, UserStatus.failure);
    });

    test('emits [loading, failure] when the repository throws', () async {
      when(() => mockRepository.fetchUser())
          .thenThrow(Exception('Network error'));

      final ProviderContainer container = makeContainer();
      final List<UserState> emitted = <UserState>[];
      container.listen(userNotifierProvider, (_, next) => emitted.add(next));

      await container.read(userNotifierProvider.notifier).started();

      expect(emitted.last.status, UserStatus.failure);
      expect(emitted.last.errorMessage, contains('Network error'));
    });
  });
}
```

## Three things that catch people

**The provider must be listened to before it will keep state.** Without a `container.listen` or a
`container.read`, the notifier is disposed as soon as it has no listeners, and the emissions vanish.

**`fireImmediately`** decides whether the initial state counts as an emission. Left at its default
it does not, which is why the expected lists above start at `loading`. Set it true where the initial
state is what the assertion is about.

**Overrides replace constructor injection.** The repository reaches the notifier through a provider,
so the test substitutes it with `overrideWithValue` rather than a constructor argument. A notifier
reading a repository directly, without a provider, cannot be tested this way, which is the reason
the state-layer template routes it through one.

## For an AsyncNotifier

```dart
final AsyncValue<User> value =
    await container.read(userNotifierProvider.future).then(AsyncData.new);
expect(value.requireValue.name, 'Test');
```

Assert on `AsyncValue` rather than collecting a sequence: the loading and error states are the
value's own cases, so there is nothing to accumulate.
