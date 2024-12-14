import 'dart:math';

import 'package:mini_tea/feature.dart';

typedef ExampleFeature = Feature<State, Msg, Effect>;

Future<void> main() async {
  final feature = ExampleFeature(
    initialState: const State(count: 0),
    update: update,
    effectHandlers: [ExampleEffectHandler()],
    // initialEffects: [const GetRandom()], // We can set this initial effect, so our feature will get random number at init
  );

  await feature.init();

  feature.accept(const Increment());
  feature.accept(const Decrement());
  feature.accept(const AskRandom());
  feature.accept(const Increment());
}

// Messages

sealed class Msg {}

final class Increment implements Msg {
  const Increment();
}

final class Decrement implements Msg {
  const Decrement();
}

final class AskRandom implements Msg {
  const AskRandom();
}

final class SetCounter implements Msg {
  final int value;

  const SetCounter({required this.value});
}

// State

final class State {
  final int count;

  const State({required this.count});

  State copyWith({
    int? count,
  }) =>
      State(count: count ?? this.count);
}

// Effects

sealed class Effect {}

final class GetRandom implements Effect {
  final int min;
  final int max;

  const GetRandom({
    this.min = 0,
    this.max = 100,
  });
}

// Update

Next<State, Effect> update(State state, Msg message) {
  switch (message) {
    case Increment():
      // When increment just add one and nothing more
      return next(state: state.copyWith(count: state.count + 1));
    case Decrement():
      // Same with decrement but subtract one
      return next(state: state.copyWith(count: state.count - 1));
    case AskRandom():
      // When ask for random we do not update state
      // But send effect to really get random from handler
      return next(effects: const [GetRandom()]);
    case SetCounter():
      // When we get a specific number just set it
      return next(state: state.copyWith(count: message.value));
  }
}

// Effect Handler

// In this class we handle side effects, so our logic is pure
final class ExampleEffectHandler implements EffectHandler<Effect, Msg> {
  final _random = Random();

  @override
  void call(Effect effect, MsgEmitter<Msg> emit) {
    switch (effect) {
      case GetRandom():
        return _getRandom(effect, emit);
    }
  }

  void _getRandom(GetRandom effect, MsgEmitter<Msg> emit) {
    final num = _random.nextInt(effect.max - effect.min) + effect.min;
    final msg = SetCounter(value: num);
    emit(msg);
  }
}
