import 'package:go_router/go_router.dart';

import '../../features/converter/view/converter_screen.dart';
import '../../features/currency_picker/view/currency_picker_screen.dart';
import '../../features/settings/view/settings_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const String converter = '/';
  static const String picker = '/picker';
  static const String settings = '/settings';
}

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.converter,
    routes: [
      GoRoute(path: AppRoutes.converter, builder: (_, __) => const ConverterScreen()),
      GoRoute(
        path: AppRoutes.picker,
        builder: (context, state) {
          final extra = state.extra as CurrencyPickerArgs?;
          return CurrencyPickerScreen(args: extra ?? const CurrencyPickerArgs.empty());
        },
      ),
      GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
    ],
  );
}
