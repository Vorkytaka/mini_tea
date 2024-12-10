import 'package:mini_tea/effect_handlers.dart';
import 'package:test/test.dart';

extension SyncEffectHandlerTests<Effect, Msg>
    on SyncEffectHandler<Effect, Msg> {
  void test({
    required Effect effect,
    Iterable<Msg>? expectedMessages,
  }) {
    final actual = <Msg>[];
    call(effect, actual.add);
    if (expectedMessages == null) {
      expect(actual, isEmpty);
    } else {
      expect(actual, containsAllInOrder(expectedMessages));
    }
  }
}
