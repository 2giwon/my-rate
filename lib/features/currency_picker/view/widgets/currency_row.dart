import 'package:flutter/material.dart';
import '../../../../domain/exchange_rate/models.dart';

class CurrencyRow extends StatelessWidget {
  const CurrencyRow({
    super.key,
    required this.currency,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Currency currency;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(currency.flagEmoji ?? '💱', style: const TextStyle(fontSize: 22)),
      title: Text('${currency.code} · ${currency.name}'),
      trailing: IconButton(
        icon: Icon(isFavorite ? Icons.star : Icons.star_border),
        onPressed: onFavoriteToggle,
      ),
    );
  }
}
