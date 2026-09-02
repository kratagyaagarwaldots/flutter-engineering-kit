# State layer: Provider / ChangeNotifier

One controller holding both the state fields and the actions, in
`lib/features/{feature_name}/controller/`:

```
{feature_name}_controller.dart
```

`ChangeNotifier` keeps state as fields rather than as a separate immutable value, so there is no
state class and no `copyWith`. That is the tradeoff of this stack: less ceremony per change, and
equality that the framework cannot check for you.

## `{feature}_controller.dart`

```dart
import '../../../core/router/exports.dart';

enum {Feature}Status { initial, loading, success, failure }

class {Feature}Controller extends ChangeNotifier {
  {Feature}Controller({{Feature}Repository? repository})
      : _repository = repository ?? {Feature}Repository();

  final {Feature}Repository _repository;

  {Feature}Status _status = {Feature}Status.initial;
  String? _errorMessage;
  {Feature}Data? _data;

  {Feature}Status get status => _status;
  String? get errorMessage => _errorMessage;
  {Feature}Data? get data => _data;

  Future<void> started() async {
    _status = {Feature}Status.loading;
    notifyListeners();
    try {
      final data = await _repository.fetchData();
      if (data == null) {
        _status = {Feature}Status.failure;
        _errorMessage = 'Failed to load';
        notifyListeners();
        return;
      }
      _data = data;
      _status = {Feature}Status.success;
    } catch (e) {
      debugPrint('{Feature}Controller.started error: $e');
      _status = {Feature}Status.failure;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
```

## Shape rules

- Fields are private with public getters, so the view reads and only the controller writes.
- One public method per action, named as a verb.
- Constructor-inject the repository with a fallback, exactly as the skill's rules say.
- **Every path out of an action ends in `notifyListeners()`.** An early return that skips it leaves
  the UI on the previous state, and this is the defect this stack invites. The shape above calls it
  once at the end plus once at each early return, rather than relying on one call at the bottom.
- Call `notifyListeners()` after the fields are consistent, never between two writes that belong to
  the same change.
- Override `dispose()` to cancel any subscription or controller the feature owns.

## Dependencies

`provider`. `ChangeNotifier` itself comes from `flutter/foundation`, so a project using
`ListenableBuilder` directly needs no package at all.
