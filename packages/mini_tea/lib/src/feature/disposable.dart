part of 'feature.dart';

/// Can be used with class that implements [EffectHandler].
/// If so, then feature will called dispose for this effect handler.
@experimental
abstract interface class Disposable {
  Future<void> dispose();
}
