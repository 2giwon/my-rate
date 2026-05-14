import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/l10n/generated/app_localizations.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/view/widgets/tip_tax_menu_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(appBar: AppBar(actions: [child])),
  );

  testWidgets('tap shows menu with tip/tax/discount', (tester) async {
    TipTaxMode? selected;
    await tester.pumpWidget(
      wrap(TipTaxMenuButton(onSelected: (m) => selected = m)),
    );
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Tip'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Discount'), findsOneWidget);

    await tester.tap(find.text('Tip'));
    await tester.pumpAndSettle();
    expect(selected, TipTaxMode.tip);
  });
}
