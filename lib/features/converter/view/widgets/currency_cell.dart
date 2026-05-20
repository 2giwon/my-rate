import 'package:flutter/material.dart';
import '../../../../domain/exchange_rate/models.dart';

class CurrencyCell extends StatelessWidget {
  const CurrencyCell({super.key, required this.currency, required this.onTap});
  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              currency.flagEmoji ?? '💱',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(currency.code, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                currency.name,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
