import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/currency_formatter.dart';

class AmountInput extends StatefulWidget {
  const AmountInput({
    super.key,
    required this.value,
    required this.decimalPlaces,
    required this.onChanged,
  });

  final double value;
  final int decimalPlaces;
  final ValueChanged<double> onChanged;

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: CurrencyFormatter.format(widget.value, decimalPlaces: widget.decimalPlaces),
    );
  }

  @override
  void didUpdateWidget(covariant AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = CurrencyFormatter.format(widget.value, decimalPlaces: widget.decimalPlaces);
    if (_ctrl.text != newText && !_ctrl.selection.isValid) {
      _ctrl.text = newText;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      onChanged: (raw) {
        final parsed = CurrencyFormatter.parse(raw) ?? 0;
        widget.onChanged(parsed);
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
      style: const TextStyle(fontSize: 24),
    );
  }
}
