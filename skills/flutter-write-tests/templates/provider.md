# Logic tests: ChangeNotifier

The controller is a plain object, so it needs no test framework beyond `flutter_test`. Attach a
listener, snapshot the fields it should have changed, and assert the sequence.

```dart
import 'package:<package_name>/core/router/exports.dart'; // name from pubspec.yaml
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserController controller;
  late _MockUserRepository mockRepository;
  late List<UserStatus> emitted;

  setUp(() {
    mockRepository = _MockUserRepository();
    controller = UserController(repository: mockRepository);
    emitted = <UserStatus>[];
    controller.addListener(() => emitted.add(controller.status));
  });

  tearDown(() => controller.dispose());

  group('started', () {
    const UserData mockUser =
        UserData(id: '1', name: 'Test', email: 't@example.com');

    test('notifies [loading, success] when the repository returns data', () async {
      when(() => mockRepository.fetchUser()).thenAnswer((_) async => mockUser);

      await controller.started();

      expect(emitted, <UserStatus>[UserStatus.loading, UserStatus.success]);
      expect(controller.data, mockUser);
    });

    test('notifies [loading, failure] when the repository returns null', () async {
      when(() => mockRepository.fetchUser()).thenAnswer((_) async => null);

      await controller.started();

      expect(emitted.last, UserStatus.failure);
    });

    test('notifies [loading, failure] when the repository throws', () async {
      when(() => mockRepository.fetchUser())
          .thenThrow(Exception('Network error'));

      await controller.started();

      expect(emitted.last, UserStatus.failure);
      expect(controller.errorMessage, contains('Network error'));
    });
  });
}
```

## What this stack makes easy to get wrong

**Snapshot the value inside the listener, not after.** The listener fires with no arguments, so
reading `controller.status` later gives the final value for every entry. The shape above reads it at
notification time, which is why the sequence is meaningful.

**Count the notifications.** A missing `notifyListeners()` on an early-return path is the defect
this stack invites, and it shows up here as a sequence one shorter than expected. Assert the whole
list rather than only `emitted.last`, or the bug passes.

**A test asserting no notification** is worth writing where an action should be a no-op:

```dart
test('does not notify when already loading', () async {
  await controller.started();
  emitted.clear();
  await controller.started();
  expect(emitted, isEmpty);
});
```
