# Model the domain in types

Where a rule lives in a type, code that breaks it does not compile. Where it lives in a runtime
check, a comment, or the reader's memory, it is broken eventually and found in production.

Dart has the pieces for this: sealed classes, exhaustive `switch`, non-nullable by default, and
extension types. This is about using them for the domain rather than only for the plumbing.

## Make invalid states unrepresentable

The most common Flutter version of this is a state class where the status and the data disagree:

```dart
// Every combination is expressible, including the wrong ones
final class OrderState {
  final OrderStatus status;   // initial | loading | success | failure
  final Order? order;         // null when successful?
  final String? errorMessage; // set when successful?
}
```

Three fields, twenty-plus combinations, a handful of them meaningful. Every reader of `order!` is
trusting a rule nothing enforces, and one of them will be wrong.

Tie the data to the state that carries it:

```dart
sealed class OrderState {
  const OrderState();
}

final class OrderInitial extends OrderState { const OrderInitial(); }
final class OrderLoading extends OrderState { const OrderLoading(); }

final class OrderLoaded extends OrderState {
  final Order order;              // never null here
  const OrderLoaded(this.order);
}

final class OrderFailed extends OrderState {
  final Failure failure;          // never null here
  const OrderFailed(this.failure);
}
```

Now `order` exists exactly where it is meaningful, no `!` is needed, and an exhaustive `switch`
makes a fifth state a compile error in every consumer rather than a silent fallthrough.

**The tradeoff is real.** A status enum plus `copyWith` is less code and easier to extend one field
at a time, which is why the kit's default templates use it. Reach for the sealed version when the
states genuinely carry different data, or when you find yourself writing `!` to get at a field.

## Parse at the boundary, then trust

Validate once where data enters, convert to a type that cannot be wrong, and stop checking:

```dart
// Checked in eleven places, guaranteed nowhere
void sendReceipt(String email) {
  if (!email.contains('@')) return;
}

// Checked once, guaranteed everywhere
extension type const Email(String value) {
  static Email? tryParse(String raw) =>
      raw.contains('@') ? Email(raw) : null;
}

void sendReceipt(Email email) { /* no check needed */ }
```

An `Email` parameter cannot receive an unvalidated string, so the eleven checks collapse to one and
the compiler enforces the rest.

## Give a primitive its meaning

`String userId, String orderId` accepts them in the wrong order and compiles. Two extension types
over `String` do not. This is worth doing for ids that get passed together, money, and anything
where a unit is implied but unstated, such as a `Duration` versus an `int` of unknown units.

## Do not over-apply it

A wrapper type per field makes reading worse for no safety gain. Reach for this where **a wrong
value is actually possible and would be costly**: identifiers that get transposed, money, states
carrying conditional data, values arriving from a network or a user. A local variable in a
twelve-line function needs none of it.

Beyond this, `template/CLAUDE.md` already bans `dynamic` and `var`, and `flutter-code-review`
already flags an unchecked cast off JSON. Those are the floor, not this principle.
