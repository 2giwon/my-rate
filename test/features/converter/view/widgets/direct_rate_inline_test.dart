import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/l10n/generated/app_localizations.dart';
import 'package:myrate/features/converter/view/widgets/direct_rate_inline.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(appBar: AppBar(title: child)),
);

void main() {
  testWidgets('shows rate and timestamp', (tester) async {
    final t = DateTime.utc(2026, 5, 14, 5, 32);
    await tester.pumpWidget(
      _wrap(
        DirectRateInline(
          fromCode: 'USD',
          toCode: 'KRW',
          directRate: 1362.5,
          basedOn: t,
          toDecimals: 2,
        ),
      ),
    );
    expect(find.textContaining('USD'), findsWidgets);
    expect(find.textContaining('KRW'), findsWidgets);
    expect(find.textContaining('1,362.50'), findsWidgets);
  });

  testWidgets('shows placeholder when rate is null', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const DirectRateInline(
          fromCode: 'USD',
          toCode: 'KRW',
          directRate: null,
          basedOn: null,
          toDecimals: 2,
        ),
      ),
    );
    expect(find.text('MyRate'), findsOneWidget);
  });
}
