import 'package:flutter/widgets.dart';
import 'package:mini_tea/feature.dart';

import '../mini_tea_flutter.dart';

typedef FeatureWidgetSelector<S, T> = T Function(S state);

final class FeatureSelector<F extends Feature<S, dynamic, dynamic>, S, T>
    extends StatefulWidget {
  final FeatureWidgetSelector<S, T> selector;
  final FeatureWidgetBuilder<T> builder;
  final F? feature;

  const FeatureSelector({
    required this.selector,
    required this.builder,
    this.feature,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _FeatureSelectorState();
}

final class _FeatureSelectorState<F extends Feature<S, dynamic, dynamic>, S, T>
    extends State<FeatureSelector<F, S, T>> {
  late F _feature;
  late T _value;

  @override
  void initState() {
    super.initState();

    _feature = widget.feature ?? FeatureProvider.of<F>(context);
    _value = widget.selector(_feature.state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final feature = widget.feature ?? FeatureProvider.of<F>(context);
    if (feature != _feature) {
      _feature = feature;
      _value = widget.selector(_feature.state);
    }
  }

  @override
  void didUpdateWidget(covariant FeatureSelector<F, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldFeature = oldWidget.feature ?? FeatureProvider.of<F>(context);
    final feature = widget.feature ?? oldFeature;

    if (feature != oldFeature) {
      _feature = feature;
      _value = widget.selector(_feature.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureListener<F, S>(
      listener: _onListen,
      child: widget.builder(context, _value),
    );
  }

  void _onListen(BuildContext context, S state) {
    final value = widget.selector(state);
    if (value != _value) {
      setState(() => _value = value);
    }
  }
}
