import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:inspector_app/core/di/injection.dart';
import 'package:inspector_app/core/localization/app_localizations.dart';
import 'package:inspector_app/core/navigation/notification_navigation.dart';
import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/auth/presentation/pages/login_page.dart';
import 'package:inspector_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:inspector_app/features/splash/presentation/pages/splash_page.dart';

class App extends StatefulWidget {
  const App({super.key, this.showSplash = true, this.homeOverride});

  final bool showSplash;
  final Widget? homeOverride;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SettingsController _settingsController;
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  static const Locale _arabic = Locale('ar');

  @override
  void initState() {
    super.initState();
    _settingsController = createSettingsController();
    _settingsController.load();
    NotificationNavigation.bind(_navKey);
  }

  @override
  void dispose() {
    // الـ SettingsController مشترك على مستوى التطبيق — لا يُتلف هنا.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, child) {
        final settings = _settingsController.settings;
        final isDarkMode = settings?.isDarkMode ?? false;
        final fieldNight = settings?.fieldNightMode ?? false;
        final home = widget.homeOverride ?? (widget.showSplash ? const SplashPage() : const LoginPage());

        return MaterialApp(
          navigatorKey: _navKey,
          debugShowCheckedModeBanner: false,
          locale: _arabic,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (deviceLocale, supported) => _arabic,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          darkTheme: fieldNight ? AppTheme.fieldNight : AppTheme.dark,
          themeMode: (isDarkMode || fieldNight) ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            final theme = Theme.of(context);
            final navColor = theme.navigationBarTheme.backgroundColor ?? theme.colorScheme.surface;
            final media = MediaQuery.of(context);
            final clampedScaler = media.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.25);
            return MediaQuery(
              data: media.copyWith(textScaler: clampedScaler),
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                  statusBarBrightness:
                      theme.brightness == Brightness.dark ? Brightness.dark : Brightness.light,
                  systemNavigationBarColor: navColor,
                  systemNavigationBarIconBrightness:
                      theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                  systemNavigationBarContrastEnforced: true,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
          home: home,
        );
      },
    );
  }
}
