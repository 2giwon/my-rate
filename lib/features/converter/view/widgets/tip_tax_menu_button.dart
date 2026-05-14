import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../domain/exchange_rate/models.dart';

class TipTaxMenuButton extends StatelessWidget {
  const TipTaxMenuButton({super.key, required this.onSelected});

  final ValueChanged<TipTaxMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calculate_outlined),
      tooltip: AppLocalizations.of(context)!.calcMenuTitle,
      onPressed: () => _openMenu(context),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showModalBottomSheet<TipTaxMode>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                l10n.calcMenuTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Text('💰', style: TextStyle(fontSize: 22)),
              title: Text(l10n.calcMenuTip),
              onTap: () => Navigator.of(ctx).pop(TipTaxMode.tip),
            ),
            ListTile(
              leading: const Text('🧾', style: TextStyle(fontSize: 22)),
              title: Text(l10n.calcMenuTax),
              onTap: () => Navigator.of(ctx).pop(TipTaxMode.tax),
            ),
            ListTile(
              leading: const Text('🏷', style: TextStyle(fontSize: 22)),
              title: Text(l10n.calcMenuDiscount),
              onTap: () => Navigator.of(ctx).pop(TipTaxMode.discount),
            ),
          ],
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }
}
