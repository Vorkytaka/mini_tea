part of 'feature.dart';

/// A function type for emitting messages.
///
/// This type is used to trigger messages, typically in effect handlers.
@experimental
typedef MsgEmitter<Msg> = void Function(Msg message);

@experimental
abstract interface class IMsgEmitter<Msg> {
  void call(Msg message);
}

@experimental
abstract interface class EffectHandler<Effect, Msg> {
  FutureOr<void> call(Effect effect, MsgEmitter<Msg> emit);
}

@experimental
typedef FunEffectHandler<Effect, Msg> = FutureOr<void> Function(
  Effect effect,
  MsgEmitter<Msg> emit,
);
