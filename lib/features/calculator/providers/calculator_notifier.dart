import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/calculator/models.dart';
import '../logic/expression_builder.dart';

part 'calculator_notifier.g.dart';

@Riverpod(keepAlive: true)
class CalculatorNotifier extends _$CalculatorNotifier {
  @override
  CalculatorState build() => CalculatorState.initial();

  void onKey(CalculatorKey key) {
    state = applyKey(state, key);
  }

  /// Replace the expression with the formatted numeric value.
  /// Used by Tip/Tax/Discount panel "Apply" button.
  void setExpression(double value) {
    final rounded = (value * 1e10).round() / 1e10;
    final str = rounded == rounded.toInt()
        ? rounded.toInt().toString()
        : rounded.toString();
    state = CalculatorState(
      expression: _formatNumber(str),
      result: value,
      hasError: false,
      justEvaluated: true,
    );
  }
}

String _formatNumber(String raw) {
  final dotIdx = raw.indexOf('.');
  final intPart = dotIdx < 0 ? raw : raw.substring(0, dotIdx);
  final fracPart = dotIdx < 0 ? null : raw.substring(dotIdx + 1);
  final normalizedInt = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  final base = normalizedInt.isEmpty ? '0' : normalizedInt;
  final n = base.length;
  final buf = StringBuffer();
  for (var i = 0; i < n; i++) {
    if (i > 0 && (n - i) % 3 == 0) buf.write(',');
    buf.write(base[i]);
  }
  return fracPart == null ? buf.toString() : '${buf.toString()}.$fracPart';
}
