# Mini TEA

![Mini TEA](../../assets/logo.png)

> ⚠️ __Under active development__: Things may change as we continue improving!

Mini TEA is a reactive and functional state management library for Dart and Flutter, inspired by The Elm Architecture (TEA) and tailored specifically for the Flutter framework. It emphasizes the separation of pure business logic from side effects, promoting clean, testable, and maintainable code.

## Why Mini TEA?

- __Unidirectional Data Flow__: Ensures data flows in a single direction, simplifying state management and reducing potential bugs.
- __Pure Business Logic__: Keeps the core business logic pure and free from side effects, enhancing predictability and ease of testing.
- __Explicit Side Effects__: Manages side effects explicitly through dedicated constructs called Effect Handlers.
- __Everything is Data__: Treats all intentions and actions within the architecture as data, leading to a consistent and transparent codebase.

You can read more about this ideas [here](https://github.com/Vorkytaka/mini_tea/blob/master/README.md).

## Other packages

- [mini_tea_flutter](https://pub.dev/packages/mini_tea_flutter) – build Flutter applications with Mini TEA.
- [mini_tea_test](https://pub.dev/packages/mini_tea_test) – test Mini TEA features with ease.

## Simple Example

Let's create a simple Counter feature using Mini TEA.

### 1. Define the Models

Messages is some intention around the feature.
It can be a user action like button click, a system event, or any other kind of intention.

In our example we have two messages: `Increment` and `Decrement`.

```dart
sealed abstract class CounterMsg {}

class Increment extends CounterMsg {}

class Decrement extends CounterMsg {}
```

Our state will be an integer, for simplicity.

```dart
typedef CounterState = int;
```

### 2. Define the Update Function

The update function is the heart of your business logic.

It must be a [pure](https://en.wikipedia.org/wiki/Pure_function) function that takes the current state and processes incoming message.

```dart
Next<CounterState, CounterEffect> update(CounterState state, CounterMsg message) {
  switch (message) {
    case Increment():
      return next(state: state + 1);
    case Decrement():
      return next(state: state - 1);
  }
}
```

As you can see the update function is a simple switch case that increments or decrements the state based on the incoming message.

> Don't think about `CounterEffect` for now, we will talk about it later.

### 3. Create a Feature

Now we can combine our models and update function to create a feature.

```dart
// It's a good practice to define a type alias for your feature.
typedef CounterFeature = Feature<CounterState, CounterMsg, Never>;

final counterFeature = CounterFeature(
  initialState: 0,
  update: update,
);
```

And from now on you can use this feature in your app.

```dart
await counterFeature.init(); // Always initialize your feature before using it!

counterFeature.accept(Increment()); // State becomes `1`
counterFeature.accept(Decrement()); // State becomes `0`
```

Congratulations! You have created your first feature using Mini TEA.

> ℹ️ Note: If you use `mini_tea_flutter` and `FeatureProvider.create`, then you don't need to call `init` manually!

Our `update` function is pure, but in the real world you will need to interact with all the dirty around, like saving data to a database, making an HTTP request, or even navigating to another screen.
To handle these side effects Mini TEA has the concept of `Effect Handlers`.

Let's make our example a little more complex by adding ability to save and load the counter state from the storage.

### 4. Define the Effect Handler

Think of an Effect Handler as a class that takes an incoming Effects and (optionally) emits new messages to the Feature.

First, let's define our Effects.

```dart
sealed abstract class CounterEffect {}

class SaveCounter extends CounterEffect {
  final int counter;

  SaveCounter(this.counter);
}

class LoadCounter extends CounterEffect {}
```

Now we can define our Effect Handler.

```dart
final class CounterEffectHandler implements EffectHandler<CounterEffect, CounterMsg> {
  final CounterStorage _storage;
  
  CounterEffectHandler(this._storage);
  
  @override
  Future<void> call(CounterEffect effect, MsgEmitter<CounterMsg> emit) async {
    switch (effect) {
      case SaveCounter(counter):
        return _save(effect, emit);
      case LoadCounter():
        return _load(effect, emit);
    }
  }
  
  Future<void> _save(SaveCounter effect, MsgEmitter<CounterMsg> emit) async {
    await _storage.saveCounter(effect.counter);
  }
  
  Future<void> _load(LoadEffect effect, MsgEmitter<CounterMsg> emit) async {
    final counter = await _storage.loadCounter();
    // TODO
  }
}
```

As you can see our `CounterEffectHandler` can and must interact with the outside world.
It can save and load the counter state from the storage.

Ok, we save and load the value from the storage, but how we can use it in our feature?

Handler gets a `MsgEmitter` as a parameter, this is a function that can emit new messages to the feature.
Why this and not just return a message? Because handler can emit any number of messages or even none.

Let's add new message to our feature.

```dart
sealed abstract class CounterMsg {}

class Increment extends CounterMsg {}

class Decrement extends CounterMsg {}

// New message with the loaded counter value
class CounterLoaded extends CounterMsg {
  final int counter;

  CounterLoaded(this.counter);
}
```

And now we can emit this message from the handler.

```dart
Future<void> _load(LoadEffect effect, MsgEmitter<CounterMsg> emit) async {
  final counter = await _storage.loadCounter();
  emit(CounterLoaded(counter)); // < This is it!
}
```

### 5. Update the Update Function

Now we need to handle the new message in the update function.

```dart
Next<CounterState, CounterEffect> update(CounterState state, CounterMsg message) {
  switch (message) {
    case Increment():
      final newState = state + 1;
      return next(state: newState, effects: [SaveCounter(newState)]);
    case Decrement():
      final newState = state - 1;
      return next(state: newState, effects: [SaveCounter(newState)]);
    case CounterLoaded():
      return next(state: message.counter);
  }
}
```

What's new here:
1. We added a new message `CounterLoaded` that sets the state to the loaded value. This is pretty straightforward.
2. We added `SaveCounter` effect to the `Increment` and `Decrement` messages. This mean, that every time we increment or decrement the counter we will save the new value to the storage.

The great thing about this approach is that you can test, read and think about your business logic without thinking about the implementation details.
It's became a simple state machine.

### 6. Create a Feature with Effect Handler

Now we can combine our feature with the effect handler.

```dart
final counterFeature = CounterFeature(
  initialState: 0,
  update: update,
  effectHandlers: [CounterEffectHandler(CounterStorage())],
);

await counterFeature.init(); // Always initialize your feature before using it!

counterFeature.accept(Increment()); // State becomes `1` and save to the storage
counterFeature.accept(Decrement()); // State becomes `0` and save to the storage
```

And that's it! You have created a feature with side effects using Mini TEA. Congratulations! 🎉

### Initial Effects

Sometimes you need to perform some actions when the feature is initialized.

For example, you may want to load the counter value from the storage when the feature is initialized.

To do this you can pass `initialEffects` to the feature.

```dart
final counterFeature = CounterFeature(
  initialState: 0,
  update: update,
  effectHandlers: [CounterEffectHandler(CounterStorage())],
  initialEffects: [LoadCounter()],
);
```

Now when you call `counterFeature.init()` it will load the counter value from the storage.

What's great about this is that you can see all the side effects in one place and you can easily test them.

### Disposable Effects

Sometimes you need to perform some actions when the feature is disposed.

For example, you may want to close the database connection when the feature is disposed or stop some stream.

To do this you have two options:
1. `disposableEffects` argument in the `Feature` constructor. Same as `initialEffects` but will be called when the feature is disposed.
2. Implement `Disposable` interface in your `EffectHandler` class. In this case, `dispose` method will be called when the feature is disposed.
