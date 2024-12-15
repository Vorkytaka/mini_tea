import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../core/feature.dart';
import 'proxy_feature.dart';

/// A base class for observing feature lifecycle events and interactions.
///
/// [FeatureObserver] provides hooks to monitor a feature's lifecycle, state changes,
/// messages, and effects. This is useful for debugging, logging, or analytics.
///
/// ### Hooks:
/// - [onCreate]: Called when the feature is created. Provides the feature instance.
/// - [onInit]: Called when the feature is initialized.
/// - [onDispose]: Called when the feature is disposed.
/// - [onState]: Called when the feature's state changes.
/// - [onMsg]: Called when a message is accepted by the feature.
/// - [onEffect]: Called when an effect is emitted by the feature.
///
/// ### Usage:
/// Extend this class and override the hooks you need. Attach the observer
/// using the observe extension.
///
/// Example:
/// ```dart
/// class MyObserver extends FeatureObserver<MyState, MyMsg, MyEffect> {
///   @override
///   void onState(MyState state) {
///     print('State changed: $state');
///   }
///
///   @override
///   void onMsg(MyMsg message) {
///     print('Message received: $message');
///   }
/// }
/// ```
///
// TODO(Vorkytaka): Use functions instead of class?
@experimental
abstract class FeatureObserver<State, Msg, Effect> {
  /// Called when the feature is created.
  void onCreate() {}

  /// Called when the feature is initialized.
  void onInit() {}

  /// Called when the feature is disposed.
  void onDispose() {}

  /// Called when the feature's state changes.
  ///
  /// - [state]: The new state.
  void onState(State state) {}

  /// Called when a message is accepted by the feature.
  ///
  /// - [message]: The message being processed.
  void onMsg(Msg message) {}

  /// Called when an effect is emitted by the feature.
  ///
  /// - [effect]: The effect emitted.
  void onEffect(Effect effect) {}
}

/// A wrapper for adding observation capabilities to a [Feature].
///
/// [FeatureObserverWrapper] enhances a feature by integrating a [FeatureObserver],
/// allowing you to monitor lifecycle events, state changes, messages, and effects.
///
/// ### Key Features:
/// - Notifies the observer about lifecycle events (`onCreate`, `onInit`, `onDispose`).
/// - Observes and reports state updates, messages, and effects.
///
/// ### Example:
/// ```dart
/// final observedFeature = myFeature.observe(MyObserver());
/// ```
@experimental
final class FeatureObserverWrapper<State, Msg, Effect>
    extends ProxyFeature<State, Msg, Effect> {
  /// The observer monitoring the feature.
  final FeatureObserver<State, Msg, Effect> observer;

  final _subscription = CompositeSubscription();

  /// Creates a new [FeatureObserverWrapper].
  ///
  /// - [feature]: The feature being observed.
  /// - [observer]: The observer handling lifecycle and interaction events.
  FeatureObserverWrapper({
    required super.feature,
    required this.observer,
  }) {
    observer.onCreate();
  }

  /// Notifies the observer when a message is accepted.
  @override
  void accept(Msg message) {
    observer.onMsg(message);
    super.accept(message);
  }

  /// Initializes the feature and starts observing state and effect streams.
  @override
  FutureOr<void> init() {
    observer.onInit();
    stateStream.listen(observer.onState).addTo(_subscription);
    effects.listen(observer.onEffect).addTo(_subscription);
    return super.init();
  }

  /// Disposes the feature and cleans up subscriptions.
  @override
  Future<void> dispose() {
    observer.onDispose();
    _subscription.dispose();
    return super.dispose();
  }
}

/// Extension for attaching a [FeatureObserver] to a [Feature].
///
/// Provides a convenient method to wrap a feature with an observer.
///
/// ### Example:
/// ```dart
/// final observedFeature = myFeature.observe(MyObserver());
/// ```
@experimental
extension FeatureObserverWrapperHelper<S, M, E> on Feature<S, M, E> {
  /// Wraps the feature with the specified [observer].
  ///
  /// - [observer]: The observer to attach.
  ///
  /// Returns a [FeatureObserverWrapper] that monitors the feature's interactions.
  Feature<S, M, E> observe(FeatureObserver<S, M, E> observer) =>
      FeatureObserverWrapper(
        feature: this,
        observer: observer,
      );
}
