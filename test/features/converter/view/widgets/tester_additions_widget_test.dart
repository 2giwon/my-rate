// Tester additions — widget-level assertions for spec §3 (ConverterScreen),
// §4.6 (display behavior), §9 (i18n keys), §10 (error label rendering).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/l10n/generated/app_localizations.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/view/widgets/converted_display.dart';
import 'package:myrate/features/converter/view/widgets/direct_rate_inline.dart';
import 'package:myrate/features/converter/view/widgets/expression_display.dart';
import 'package:myrate/features/converter/view/widgets/tip_tax_menu_button.dart';

void main() {
  const krw = Currency(
    code: 'KRW',
    name: '대한민국 원',
    flagEmoji: '🇰🇷',
    decimalPlaces: 0,
  );
  const usd = Currency(
    code: 'USD',
    name: 'US Dollar',
    flagEmoji: '🇺🇸',
    decimalPlaces: 2,
  );

  Widget wrap(Widget child, {Locale? locale}) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  group('ExpressionDisplay — edge cases', () {
    testWidgets('empty expression shows "0" placeholder', (tester) async {
      await tester.pumpWidget(
        wrap(
          ExpressionDisplay(
            currency: krw,
            expression: '',
            result: 0.0,
            hasError: false,
            onTapHeader: () {},
            onBackspace: () {},
          ),
        ),
      );
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('result null but no error → shows formatted 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          ExpressionDisplay(
            currency: krw,
            expression: '5 +',
            result: null,
            hasError: false,
            onTapHeader: () {},
            onBackspace: () {},
          ),
        ),
      );
      // Display fallback for null result is "0".
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('custom errorLabel is rendered when hasError true', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ExpressionDisplay(
            currency: krw,
            expression: '5 ÷ 0',
            result: null,
            hasError: true,
            errorLabel: '오류',
            onTapHeader: () {},
            onBackspace: () {},
          ),
        ),
      );
      expect(find.text('오류'), findsOneWidget);
    });

    testWidgets('long expression triggers FittedBox scale-down (no overflow)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 320,
            child: ExpressionDisplay(
              currency: krw,
              expression: '1,234,567 × 8,901 + 2,345 − 678 ÷ 90 + 100% × 50',
              result: 12345678.0,
              hasError: false,
              onTapHeader: () {},
              onBackspace: () {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('backspace icon is tappable separately from header', (
      tester,
    ) async {
      var headerTaps = 0;
      var bsTaps = 0;
      await tester.pumpWidget(
        wrap(
          ExpressionDisplay(
            currency: krw,
            expression: '5',
            result: 5.0,
            hasError: false,
            onTapHeader: () => headerTaps++,
            onBackspace: () => bsTaps++,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      expect(bsTaps, 1);
      expect(headerTaps, 0);

      await tester.tap(find.text('KRW'));
      expect(headerTaps, 1);
      expect(bsTaps, 1);
    });
  });

  group('ConvertedDisplay — edge cases', () {
    testWidgets('zero (not null) value shows "0", not "—"', (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedDisplay(
            currency: usd,
            convertedValue: 0.0,
            onTapHeader: () {},
          ),
        ),
      );
      // Spec: only null value uses placeholder. 0 should format as "0.00".
      expect(find.text('—'), findsNothing);
      expect(find.text('0.00'), findsOneWidget);
    });

    testWidgets('very small value rendered with correct decimal places', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          ConvertedDisplay(
            currency: usd,
            convertedValue: 0.01,
            onTapHeader: () {},
          ),
        ),
      );
      expect(find.text('0.01'), findsOneWidget);
    });

    testWidgets('large value rendered with thousand separator', (tester) async {
      await tester.pumpWidget(
        wrap(
          ConvertedDisplay(
            currency: krw,
            convertedValue: 1234567.0,
            onTapHeader: () {},
          ),
        ),
      );
      expect(find.text('1,234,567'), findsOneWidget);
    });
  });

  group('DirectRateInline — locale and edge cases', () {
    testWidgets('Korean locale renders 기준 suffix (l10n) when basedOn given', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          DirectRateInline(
            fromCode: 'USD',
            toCode: 'KRW',
            directRate: 1362.5,
            basedOn: DateTime.utc(2026, 5, 14, 5, 32),
            toDecimals: 2,
          ),
          locale: const Locale('ko'),
        ),
      );
      // ko ARB: appBarTimestamp = "{ts} 기준" — but l10n key used here is
      // lastUpdatedPrefix = "기준". Verify it's part of the rendered text.
      expect(find.textContaining('기준'), findsOneWidget);
    });

    testWidgets('rate=0 renders without crash (defensive)', (tester) async {
      await tester.pumpWidget(
        wrap(
          DirectRateInline(
            fromCode: 'USD',
            toCode: 'KRW',
            directRate: 0,
            basedOn: DateTime.utc(2026, 5, 14, 5, 32),
            toDecimals: 2,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('basedOn null but rate present: only rate row rendered', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const DirectRateInline(
            fromCode: 'USD',
            toCode: 'KRW',
            directRate: 1362.5,
            basedOn: null,
            toDecimals: 2,
          ),
        ),
      );
      expect(find.textContaining('1,362.50'), findsWidgets);
      expect(find.textContaining('기준'), findsNothing);
      expect(find.textContaining('As of'), findsNothing);
    });
  });

  group('TipTaxMenuButton — dismiss and locale', () {
    testWidgets(
      'dismiss by tapping outside (barrier) → onSelected NOT called',
      (tester) async {
        TipTaxMode? selected;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: AppBar(
                actions: [TipTaxMenuButton(onSelected: (m) => selected = m)],
              ),
            ),
          ),
        );
        await tester.tap(find.byIcon(Icons.calculate_outlined));
        await tester.pumpAndSettle();
        expect(find.text('Tip'), findsOneWidget);
        // Tap on the modal barrier (top-left corner is outside the sheet).
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(selected, isNull);
      },
    );

    testWidgets('Korean locale: 팁 계산 / 세금 계산 / 할인 계산 menu labels', (
      tester,
    ) async {
      TipTaxMode? selected;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ko'),
          home: Scaffold(
            appBar: AppBar(
              actions: [TipTaxMenuButton(onSelected: (m) => selected = m)],
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.calculate_outlined));
      await tester.pumpAndSettle();
      expect(find.text('팁 계산'), findsOneWidget);
      expect(find.text('세금 계산'), findsOneWidget);
      expect(find.text('할인 계산'), findsOneWidget);

      await tester.tap(find.text('세금 계산'));
      await tester.pumpAndSettle();
      expect(selected, TipTaxMode.tax);
    });
  });
}
