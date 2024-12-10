import 'package:mini_tea/feature.dart';
import 'package:test/test.dart';

extension UpdateTest<State, Msg, Effect> on Update<State, Msg, Effect> {
  void test({
    required State state,
    required Msg message,
    State? expectedState,
    List<Effect> expectedEffects = const [],
  }) {
    final (actualState, actualEffects) = this(state, message);
    expect(actualState, expectedState);
    expect(actualEffects, containsAllInOrder(expectedEffects));
  }
}

extension IUpdateTest<State, Msg, Effect> on IUpdate<State, Msg, Effect> {
  void test({
    required State state,
    required Msg message,
    State? expectedState,
    List<Effect> expectedEffects = const [],
  }) {
    final (actualState, actualEffects) = this(state, message);
    expect(actualState, expectedState);
    if (expectedEffects.isEmpty) {
      expect(actualEffects, isEmpty);
    } else {
      expect(actualEffects, containsAllInOrder(expectedEffects));
    }
  }
}
