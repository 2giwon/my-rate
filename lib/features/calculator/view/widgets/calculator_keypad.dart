import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/calculator/models.dart';
import '../../providers/calculator_notifier.dart';
import 'key_button.dart';

class CalculatorKeypad extends ConsumerWidget {
  const CalculatorKeypad({super.key});

  static const List<List<_KeySpec>> _layout = [
    [
      _KeySpec('C', KeyKind.edit, ClearKey()),
      _KeySpec('⌫', KeyKind.edit, BackspaceKey()),
      _KeySpec('(', KeyKind.edit, ParenOpenKey()),
      _KeySpec(')', KeyKind.edit, ParenCloseKey()),
    ],
    [
      _KeySpec('7', KeyKind.digit, DigitKey(7)),
      _KeySpec('8', KeyKind.digit, DigitKey(8)),
      _KeySpec('9', KeyKind.digit, DigitKey(9)),
      _KeySpec('÷', KeyKind.operator, OpKey(Operator.div)),
    ],
    [
      _KeySpec('4', KeyKind.digit, DigitKey(4)),
      _KeySpec('5', KeyKind.digit, DigitKey(5)),
      _KeySpec('6', KeyKind.digit, DigitKey(6)),
      _KeySpec('×', KeyKind.operator, OpKey(Operator.mul)),
    ],
    [
      _KeySpec('1', KeyKind.digit, DigitKey(1)),
      _KeySpec('2', KeyKind.digit, DigitKey(2)),
      _KeySpec('3', KeyKind.digit, DigitKey(3)),
      _KeySpec('−', KeyKind.operator, OpKey(Operator.sub)),
    ],
    [
      _KeySpec('%', KeyKind.operator, PercentKey()),
      _KeySpec('0', KeyKind.digit, DigitKey(0)),
      _KeySpec('.', KeyKind.digit, DotKey()),
      _KeySpec('+', KeyKind.operator, OpKey(Operator.add)),
    ],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorNotifierProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._layout.map(
            (row) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: row
                      .map(
                        (k) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: KeyButton(
                              label: k.label,
                              kind: k.kind,
                              onTap: () => notifier.onKey(k.key),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          // Full-width `=` so it's easy to reach by either thumb.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: KeyButton(
                label: '=',
                kind: KeyKind.equals,
                onTap: () => notifier.onKey(const EqualsKey()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeySpec {
  final String label;
  final KeyKind kind;
  final CalculatorKey key;
  const _KeySpec(this.label, this.kind, this.key);
}
