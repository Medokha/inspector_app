import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/counter/presentation/pages/counter_page.dart';
import 'package:inspector_app/features/splash/presentation/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key, this.showSplash = true});

  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: showSplash ? const SplashPage() : const CounterPage(),
    );
  }
}
