import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/popular_currencies.dart';
import '../../../data/exchange_rate/providers.dart';
import '../../../domain/exchange_rate/models.dart';

part 'currency_picker_notifier.g.dart';

class CurrencyPickerState {
  CurrencyPickerState({
    required this.all,
    required this.favorites,
    required this.popular,
    this.query = '',
  });

  final List<Currency> all;
  final List<String> favorites;
  final List<Currency> popular;
  final String query;

  List<Currency> get favoriteCurrencies =>
      all.where((c) => favorites.contains(c.code)).toList();

  List<Currency> get searched {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all
        .where((c) =>
            c.code.toLowerCase().contains(q) || c.name.toLowerCase().contains(q))
        .toList();
  }

  CurrencyPickerState copyWith({
    List<Currency>? all,
    List<String>? favorites,
    List<Currency>? popular,
    String? query,
  }) =>
      CurrencyPickerState(
        all: all ?? this.all,
        favorites: favorites ?? this.favorites,
        popular: popular ?? this.popular,
        query: query ?? this.query,
      );
}

@riverpod
class CurrencyPickerNotifier extends _$CurrencyPickerNotifier {
  @override
  Future<CurrencyPickerState> build({required List<String> availableCodes, required String languageCode}) async {
    final catalog = await ref.watch(currencyCatalogProvider.future);
    final repo = await ref.watch(exchangeRateRepositoryProvider.future);

    final all = catalog
        .resolveAll(availableCodes, languageCode: languageCode)
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    final fav = await repo.getFavoriteCodes();
    final popular = catalog.resolveAll(kPopularCurrencyCodes, languageCode: languageCode);
    return CurrencyPickerState(all: all, favorites: fav, popular: popular);
  }

  void search(String q) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(query: q));
  }

  Future<void> toggleFavorite(String code) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final repo = await ref.read(exchangeRateRepositoryProvider.future);
    final isFav = s.favorites.contains(code);
    if (isFav) {
      await repo.removeFavorite(code);
    } else {
      await repo.addFavorite(code);
    }
    final updated = await repo.getFavoriteCodes();
    state = AsyncData(s.copyWith(favorites: updated));
  }
}
