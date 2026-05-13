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
  late ThousandsSeparatorInputFormatter _formatter;

  @override
  void initState() {
    super.initState();
    _formatter = ThousandsSeparatorInputFormatter(maxDecimals: widget.decimalPlaces);
    _ctrl = TextEditingController(
      text: CurrencyFormatter.format(widget.value, decimalPlaces: widget.decimalPlaces),
    );
  }

  @override
  void didUpdateWidget(covariant AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.decimalPlaces != widget.decimalPlaces) {
      _formatter = ThousandsSeparatorInputFormatter(maxDecimals: widget.decimalPlaces);
    }
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
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')), _formatter],
      onChanged: (raw) {
        final parsed = CurrencyFormatter.parse(raw) ?? 0;
        widget.onChanged(parsed);
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
      style: const TextStyle(fontSize: 24),
    );
  }
}

/// 입력 도중에 천 단위 구분 쉼표를 자동으로 삽입하고, 커서 위치를
/// 사용자가 의도한 자리(쉼표 추가/제거를 보정)로 유지한다.
///
/// 동작 요약:
/// - 쉼표를 제거한 숫자만 추출하여 다시 천 단위 쉼표를 붙인다.
/// - 소수점은 1개만 허용한다. `maxDecimals == 0`이면 소수점 입력은 무시.
/// - 빈 문자열은 그대로 통과.
@visibleForTesting
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({this.maxDecimals = 2});

  final int maxDecimals;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    if (raw.isEmpty) {
      return newValue;
    }

    // 1) 입력 textValue에서 쉼표 제거
    final stripped = raw.replaceAll(',', '');

    // 2) 소수점 1개만 허용 + maxDecimals==0이면 소수점 제거
    final dotIndex = stripped.indexOf('.');
    String intPart;
    String? fracPart;
    if (dotIndex < 0) {
      intPart = stripped;
    } else if (maxDecimals == 0) {
      // 소수점 미허용 통화는 점 입력 자체를 무시
      intPart = stripped.replaceAll('.', '');
      fracPart = null;
    } else {
      intPart = stripped.substring(0, dotIndex);
      // 소수점 이후의 점은 제거하고, maxDecimals만큼만 유지
      final afterDot = stripped.substring(dotIndex + 1).replaceAll('.', '');
      fracPart = afterDot.length > maxDecimals ? afterDot.substring(0, maxDecimals) : afterDot;
    }

    // 3) 정수부에 천 단위 쉼표
    final intDigitsOnly = intPart.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedInt = _withThousandsSeparator(intDigitsOnly);

    // 4) 결과 텍스트 조합
    final formatted = fracPart == null ? formattedInt : '$formattedInt.$fracPart';

    // 5) 커서 위치 보정: oldValue 커서 위치에서 우측에 있는 digit 개수를 기준으로
    //    formatted 문자열에서 같은 digit 개수만큼 우측에서 떨어진 위치로 이동.
    final oldCursor = oldValue.selection.baseOffset.clamp(0, oldValue.text.length);
    final newCursor = newValue.selection.baseOffset.clamp(0, raw.length);

    // newValue.text의 newCursor 위치 이후의 digit 개수
    final tail = raw.substring(newCursor);
    final digitsAfterCursor = tail.replaceAll(RegExp(r'[^0-9.]'), '').length;

    // formatted에서 우측에서 digitsAfterCursor만큼의 digit/. 자리 찾기
    var remaining = digitsAfterCursor;
    var cursorPos = formatted.length;
    for (var i = formatted.length - 1; i >= 0 && remaining > 0; i--) {
      final ch = formatted[i];
      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        remaining--;
      }
      cursorPos = i;
    }

    // ignore: unused_local_variable
    final _ = oldCursor; // placeholder to keep oldCursor consideration for future refinement

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPos.clamp(0, formatted.length)),
    );
  }

  String _withThousandsSeparator(String digits) {
    if (digits.isEmpty) return '';
    final buf = StringBuffer();
    final n = digits.length;
    for (var i = 0; i < n; i++) {
      if (i > 0 && (n - i) % 3 == 0) {
        buf.write(',');
      }
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
