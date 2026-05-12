import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/auth/presentation/pages/login_page.dart';
import 'package:inspector_app/features/splash/presentation/pages/splash_page.dart';
import 'package:inspector_app/features/settings/presentation/controller/settings_controller.dart';

class App extends StatefulWidget {
  const App({super.key, this.showSplash = true, this.homeOverride});

  final bool showSplash;
  final Widget? homeOverride;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = createSettingsController();
    _settingsController.load();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, child) {
        final isDarkMode = _settingsController.settings?.isDarkMode ?? false;
        final home = widget.homeOverride ?? (widget.showSplash ? const SplashPage() : const LoginPage());

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: home,
        );
      },
    );
  }
}
