import 'package:mini_tea/effect_handlers.dart';
import 'package:test/test.dart';

extension AsyncEffectHandlerTests<Effect, Msg>
    on AsyncEffectHandler<Effect, Msg> {
  Future<void> test({
    required Effect effect,
    Iterable<Msg>? expectedMessages,
  }) async {
    final actual = <Msg>[];
    await call(effect, actual.add);
    if (expectedMessages == null) {
      expect(actual, isEmpty);
    } else {
      expect(actual, containsAllInOrder(expectedMessages));
    }
  }
}
