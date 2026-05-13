import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/color_schemes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/exchange_rate/models.dart';
import 'amount_input.dart' show ThousandsSeparatorInputFormatter;

/// Apple Wallet 카드 스택 영감의 환율 변환 카드 묶음.
/// - 위 카드: From 통화 (편집 가능한 금액 입력)
/// - 아래 카드: To 통화 (변환 결과 표시)
/// - 사이에 floating swap 버튼
class CurrencyCardStack extends StatelessWidget {
  const CurrencyCardStack({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.onAmountChanged,
    required this.onSwap,
    required this.onTapFrom,
    required this.onTapTo,
  });

  final Currency fromCurrency;
  final Currency toCurrency;
  final double amount;
  final double? convertedAmount;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onSwap;
  final VoidCallback onTapFrom;
  final VoidCallback onTapTo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            _CurrencyCard(
              currency: fromCurrency,
              tint: isDark ? IosPalette.cardTintFromDark : IosPalette.cardTintFromLight,
              isEditable: true,
              amount: amount,
              onAmountChanged: onAmountChanged,
              onTap: onTapFrom,
            ),
            const SizedBox(height: 12),
            _CurrencyCard(
              currency: toCurrency,
              tint: isDark ? IosPalette.cardTintToDark : IosPalette.cardTintToLight,
              isEditable: false,
              amount: convertedAmount ?? 0,
              onAmountChanged: (_) {},
              onTap: onTapTo,
            ),
          ],
        ),
        // Floating swap button — 두 카드 사이에 위치
        Positioned(top: 0, bottom: 0, child: _SwapFab(onPressed: onSwap)),
      ],
    );
  }
}

class _CurrencyCard extends StatefulWidget {
  const _CurrencyCard({
    required this.currency,
    required this.tint,
    required this.isEditable,
    required this.amount,
    required this.onAmountChanged,
    required this.onTap,
  });

  final Currency currency;
  final Color tint;
  final bool isEditable;
  final double amount;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onTap;

  @override
  State<_CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<_CurrencyCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: CurrencyFormatter.format(widget.amount, decimalPlaces: widget.currency.decimalPlaces),
    );
  }

  @override
  void didUpdateWidget(covariant _CurrencyCard old) {
    super.didUpdateWidget(old);
    final newText = CurrencyFormatter.format(
      widget.amount,
      decimalPlaces: widget.currency.decimalPlaces,
    );
    if (_ctrl.text != newText && (!widget.isEditable || !_ctrl.selection.isValid)) {
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
    final scheme = Theme.of(context).colorScheme;
    final unit = widget.currency.shortName ?? widget.currency.code;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.tint, scheme.surfaceContainerHighest],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(widget.currency.flagEmoji ?? '💱', style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      widget.currency.code,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.currency.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: scheme.onSurface.withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: widget.isEditable
                      ? TextField(
                          controller: _ctrl,
                          textAlign: TextAlign.right,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                            ThousandsSeparatorInputFormatter(
                              maxDecimals: widget.currency.decimalPlaces,
                            ),
                          ],
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                          ),
                          onChanged: (raw) {
                            final parsed = CurrencyFormatter.parse(raw) ?? 0;
                            widget.onAmountChanged(parsed);
                          },
                        )
                      : Text(
                          CurrencyFormatter.format(
                            widget.amount,
                            decimalPlaces: widget.currency.decimalPlaces,
                          ),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapFab extends StatelessWidget {
  const _SwapFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(Icons.swap_vert, color: scheme.onPrimary, size: 28),
        ),
      ),
    );
  }
}
