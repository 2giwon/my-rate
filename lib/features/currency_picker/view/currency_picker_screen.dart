import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../providers/currency_picker_notifier.dart';
import 'widgets/alphabet_index.dart';
import 'widgets/currency_row.dart';
import 'widgets/picker_search_bar.dart';

class CurrencyPickerArgs {
  const CurrencyPickerArgs({required this.availableCodes});
  const CurrencyPickerArgs.empty() : availableCodes = const [];
  final List<String> availableCodes;
}

class CurrencyPickerScreen extends ConsumerStatefulWidget {
  const CurrencyPickerScreen({super.key, required this.args});
  final CurrencyPickerArgs args;

  @override
  ConsumerState<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends ConsumerState<CurrencyPickerScreen> {
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _letterKeys = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final family = currencyPickerNotifierProvider(
      availableCodes: widget.args.availableCodes,
      languageCode: lang,
    );
    final state = ref.watch(family);
    final notifier = ref.read(family.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.currencyPickerTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          if (s.query.isNotEmpty) {
            return Column(
              children: [
                PickerSearchBar(onChanged: notifier.search),
                Expanded(
                  child: ListView(
                    children: s.searched
                        .map(
                          (c) => CurrencyRow(
                            currency: c,
                            isFavorite: s.favorites.contains(c.code),
                            onTap: () => Navigator.of(context).pop(c.code),
                            onFavoriteToggle: () => notifier.toggleFavorite(c.code),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    PickerSearchBar(onChanged: notifier.search),
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        children: _buildSections(context, s, notifier),
                      ),
                    ),
                  ],
                ),
              ),
              AlphabetIndex(
                onLetter: (l) {
                  final key = _letterKeys[l];
                  final ctx = key?.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    CurrencyPickerState s,
    CurrencyPickerNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final widgets = <Widget>[];
    if (s.favorites.isNotEmpty) {
      widgets.add(_header(l10n.favoritesSection));
      widgets.addAll(
        s.favoriteCurrencies.map(
          (c) => CurrencyRow(
            currency: c,
            isFavorite: true,
            onTap: () => Navigator.of(context).pop(c.code),
            onFavoriteToggle: () => notifier.toggleFavorite(c.code),
          ),
        ),
      );
    }
    widgets.add(_header(l10n.popularSection));
    widgets.addAll(
      s.popular.map(
        (c) => CurrencyRow(
          currency: c,
          isFavorite: s.favorites.contains(c.code),
          onTap: () => Navigator.of(context).pop(c.code),
          onFavoriteToggle: () => notifier.toggleFavorite(c.code),
        ),
      ),
    );

    String? lastLetter;
    for (final c in s.all) {
      final letter = c.code.substring(0, 1).toUpperCase();
      if (letter != lastLetter) {
        final key = _letterKeys.putIfAbsent(letter, () => GlobalKey());
        widgets.add(
          Container(
            key: key,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(letter, style: Theme.of(context).textTheme.titleMedium),
          ),
        );
        lastLetter = letter;
      }
      widgets.add(
        CurrencyRow(
          currency: c,
          isFavorite: s.favorites.contains(c.code),
          onTap: () => Navigator.of(context).pop(c.code),
          onFavoriteToggle: () => notifier.toggleFavorite(c.code),
        ),
      );
    }
    return widgets;
  }

  Widget _header(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}
