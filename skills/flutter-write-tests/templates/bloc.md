# Logic tests: bloc_test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:<package_name>/core/router/exports.dart'; // name from pubspec.yaml
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserBloc bloc;
  late _MockUserRepository mockRepository;

  setUp(() {
    mockRepository = _MockUserRepository();
    bloc = UserBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('UserStarted', () {
    const UserData mockUser =
        UserData(id: '1', name: 'Test', email: 't@example.com');

    blocTest<UserBloc, UserState>(
      'emits [loading, success] when repository returns data',
      build: () {
        when(() => mockRepository.fetchUser())
            .thenAnswer((_) async => mockUser);
        return bloc;
      },
      act: (UserBloc bloc) => bloc.add(const UserStarted()),
      expect: () => <UserState>[
        const UserState(status: UserStatus.loading),
        const UserState(status: UserStatus.success, data: mockUser),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [loading, failure] when repository returns null',
      build: () {
        when(() => mockRepository.fetchUser()).thenAnswer((_) async => null);
        return bloc;
      },
      act: (UserBloc bloc) => bloc.add(const UserStarted()),
      expect: () => <UserState>[
        const UserState(status: UserStatus.loading),
        const UserState(
          status: UserStatus.failure,
          errorMessage: 'Failed to load',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [loading, failure] when repository throws',
      build: () {
        when(() => mockRepository.fetchUser())
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (UserBloc bloc) => bloc.add(const UserStarted()),
      expect: () => <UserState>[
        const UserState(status: UserStatus.loading),
        const UserState(
          status: UserStatus.failure,
          errorMessage: 'Exception: Network error',
        ),
      ],
    );
  });
}
```

## Parameters

| Parameter | Purpose |
|-----------|---------|
| `build` | Create the bloc and set up mocks |
| `seed` | Set the initial state |
| `act` | Dispatch events |
| `expect` | The expected state sequence |
| `verify` | Assert mock interactions |
| `wait` | Wait for async completion |

## Seeding

```dart
blocTest<UserBloc, UserState>(
  'updates existing user',
  seed: () => const UserState(status: UserStatus.success, data: existingUser),
  build: () => bloc,
  act: (bloc) => bloc.add(const UserRefreshed()),
  expect: () => [...],
);
```

## Capturing what was sent

```dart
blocTest<UserBloc, UserState>(
  'calls repository with the typed payload',
  build: () {
    when(() => mockRepository.createUser(any(named: 'request')))
        .thenAnswer((_) async => const Right<Failure, UserData>(user));
    return bloc;
  },
  act: (UserBloc bloc) => bloc.add(const UserSubmitted(name: 'Test')),
  verify: (_) {
    final CreateUserRequest captured = verify(
      () => mockRepository.createUser(
        request: captureAny(named: 'request'),
      ),
    ).captured.single as CreateUserRequest;
    expect(captured.name, 'Test');
  },
);
```

`registerFallbackValue` in a `setUpAll` for any custom type used in an `any(named: ...)` matcher,
e.g. `registerFallbackValue(const CreateUserRequest(name: ''))`. Without it the matcher throws at
runtime rather than failing the assertion.

## Naming

Group by event, `group('EventName', ...)`, and name each test for the transition it asserts:
`'emits [X, Y] when Z'`.
