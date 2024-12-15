# Mini TEA

> :warning: This package is under active development and may (and probably will) change in the future.

Mini TEA is a reactive and functional state management library for Dart and Flutter, inspired by The Elm Architecture (TEA) and tailored specifically for the Flutter framework. It emphasizes the separation of pure business logic from side effects, promoting clean, testable, and maintainable code.

## Main Features

- __Unidirectional Data Flow__: Ensures data flows in a single direction, simplifying state management and reducing potential bugs.
- __Pure Business Logic__: Keeps the core business logic pure and free from side effects, enhancing predictability and ease of testing.
- __Explicit Side Effects__: Manages side effects explicitly through dedicated constructs called Effect Handlers.
- __Everything is Data__: Treats all intentions and actions within the architecture as data, leading to a consistent and transparent codebase.

You can read more about this ideas [here](https://github.com/Vorkytaka/mini_tea/blob/master/README.md).

## Getting Started

### Create an update function

This is your business logic. It must be __pure__ function.

```dart
Next<State, Effect> update(State state, Msg message) {
  switch(message) {
    case OnLoginTap():
      return next(
        state: state.copyWith(status: Status.loading),
        effects: [LoginEffect(message.email, message.password)],
      );
  }
}
```

### Create an Effect Handler

This is your side effects. 
Here you can do API calls, getting data from database, etc.

```dart
final class LoginEffectHandler implements EffectHandler<LoginEffect, Msg> {
  final ApiService _apiService;
  
  const LoginEffectHandler(this._apiService);
  
  Future<void> call(LoginEffect effect, MsgEmitter<Msg> emit) async {
      try {
        final response = await _apiService.login(effect.email, effect.password);
        emit(OnLoginSuccess(response));
      } on Exception catch (e) {
        emit(OnLoginFailure(e));
      }
  }
}
```

As you can see in the example above, your effect handler just handle your dirty logic and emits messages back to the Feature.

Also, you can create some `EffectHandler` with what you can manipulate how your effect will be handled.
For example we already have `DebounceEffectHandler` and `SequenceEffectHandler`. All you have to do it's just wrap your handler with it.

```dart
// This effect handler will debounce each effect by 300ms
final handler = DebounceEffectHandler(
  duration: const Duration(milliseconds: 300),
  handler: InputEffectHandler(),
);
```

Also, you can implement `Disposable` interface to dispose your effect handler when you don't need it anymore.
With that feature will call `dispose` of your handler automatically.
It can be useful for cases like `StreamSubscription` or `Timer`.

### Create a Feature

Now, let's combine everything together.

```dart
final feature = Feature<State, Msg, Effect>(
  initialState: const State.init(),
  update: update,
  effectHandlers: [LoginEffectHandler()],
);

feature.init(); // Don't forget to init your feature

// ...

feature.accept(const OnLoginTap(email, password));
```

That's it! Now you can use this feature as any other state manager.

### Initialization

You must initialize your feature before using it.
All you have to do is call `init` method.

Also, there is a bunch of case, when you need to do something when feature is initialized.
For example, you need to load some data from the API when you just entered the screen.

For this cases Feature have `initialEffects` field.
All you have to do is add some `Effect` to it and they will be executed with your `EffectHandler`.

```dart
final feature = Feature<State, Msg, Effect>(
  initialState: const State.init(),
  update: update,
  effectHandlers: [DataEffectHandler()],
  initialEffects: [LoadDataEffect()],
);

feature.init();
```

In the example above, `LoadDataEffect` will be executed when feature is initialized, so you don't have to do it manually.

The great aspect of this field is that you can see what will be executed when feature is initialized, just by looking at your Feature.

### Dispose

You must call `dispose` method when you don't need your feature anymore.
With that feature will free all resources.

And unlike initialization, with dispose we have two options for `EffectHandler`.

First, you can implement `Disposable` interface to dispose your handler. In this method you can free your resources, like `StreamSubscription` or `Timer`.
With that feature will call `dispose` of your handler automatically.

Second, you can add disposable effects to `disposableEffects` field.
All you have to do is add some `Effect` to it and they will be executed with your `EffectHandler`.

Both options are equivalent, but the second one is more obvious, because you can see what will be executed when feature is disposed, just by looking at your Feature.

### Handle specific effects

In case when you add `EffectHandler` to `effectHandlers` of your Feature – this handlers will be executed for all effects.
That's fine for most cases, but sometimes you need to handle specific effects in particular way.

For this cases we have things called `FeatureEffectWrapper`. This is just a wrapper around your feature, that can listen a specific type of effects and process them with your handler.

To create a wrapper, you need to call `wrapEffects` extension method on your feature.

```dart
final feature = Feature<State, Msg, Effect>(
      initialState: State.init,
      update: update,
    )
        .wrapEffects<IsolateEffect>(const IsolateEffectHandler())
        .wrapEffects<SyncEffect>(const SyncEffectHandler());
```

In this example we create a feature that can handle two types of effects with two different handlers.

One will be handled by `IsolateEffectHandler` and the other one will be handled by `SyncEffectHandler`.
As you can guess – first one will be execute all effects on another isolate and second one will be synchronously execute all effects.

## Life-hacks

One of the worst part of this library is that we have to write a lot of generics. State, messages, effects, feature itself.

To make it easier, we have some life-hacks. All we have to do it's just to create some typedefs and factory functions.

```dart
typedef ExampleFeature = Feature<State, Msg, Effect>;

ExampleFeature exampleFeatureFactory() => ExampleFeature(
  initialState: State.init,
  update: update,
  effectHandlers: [ExampleEffectHandler()],
);
```
