import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  static const Map<String, Map<String, String>> _values = <String, Map<String, String>>{
    'en': <String, String>{
      'appTitle': 'Inspector App',
      'counterTitle': 'Counter',
      'counterHint': 'You have pushed the button this many times:',
      'increment': 'Increment',
      'splashLoading': 'Loading…',
    },
    'ar': <String, String>{
      'appTitle': 'تطبيق المفتش',
      'counterTitle': 'العداد',
      'counterHint': 'لقد ضغطت على الزر هذا العدد من المرات:',
      'increment': 'زيادة',
      'splashLoading': 'جارٍ التحميل…',
    },
  };

  String _t(String key) {
    final lang = _values[locale.languageCode];
    if (lang == null) return _values['en']![key] ?? key;
    return lang[key] ?? _values['en']![key] ?? key;
  }

  String get appTitle => _t('appTitle');
  String get counterTitle => _t('counterTitle');
  String get counterHint => _t('counterHint');
  String get increment => _t('increment');
  String get splashLoading => _t('splashLoading');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
