import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/auth/presentation/pages/login_page.dart';
import 'package:inspector_app/features/splash/presentation/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key, this.showSplash = true, this.homeOverride});

  final bool showSplash;
  final Widget? homeOverride;

  @override
  Widget build(BuildContext context) {
    final home = homeOverride ?? (showSplash ? const SplashPage() : const LoginPage());

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
      themeMode: ThemeMode.system,
      home: home,
    );
  }
}
