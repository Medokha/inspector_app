import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  /// التطبيق عربي فقط.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  static const Map<String, String> _ar = <String, String>{
    'appTitle': 'المفتش',
    'counterTitle': 'العداد',
    'counterHint': 'لقد ضغطت على الزر هذا العدد من المرات:',
    'increment': 'زيادة',
    'splashLoading': 'جارٍ التحميل…',
    'loginTitle': 'تسجيل الدخول',
    'loginSubtitle': 'سجّل الدخول للمتابعة',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'loginButton': 'دخول',
    'loginFailed': 'فشل تسجيل الدخول',
    'loginFillAllFields': 'من فضلك أدخل جميع البيانات',
    'resetPasswordTitle': 'إعادة تعيين كلمة المرور',
    'resetPasswordHint': 'أدخل كلمة المرور الحالية ثم اختر كلمة مرور جديدة.',
    'currentPassword': 'كلمة المرور الحالية',
    'newPassword': 'كلمة المرور الجديدة',
    'confirmPassword': 'تأكيد كلمة المرور الجديدة',
    'resetPasswordButton': 'إعادة التعيين',
    'resetPasswordSuccess': 'تم تحديث كلمة المرور بنجاح',
    'resetPasswordFailed': 'تعذر إعادة تعيين كلمة المرور',
    'resetPasswordMismatch': 'كلمتا المرور الجديدتان غير متطابقتين',
    'resetPasswordSameAsCurrent': 'يجب أن تختلف كلمة المرور الجديدة عن الحالية',
    'resetPasswordTooShort': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل',
  };

  String _t(String key) => _ar[key] ?? key;

  String get appTitle => _t('appTitle');
  String get counterTitle => _t('counterTitle');
  String get counterHint => _t('counterHint');
  String get increment => _t('increment');
  String get splashLoading => _t('splashLoading');

  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get email => _t('email');
  String get password => _t('password');
  String get loginButton => _t('loginButton');
  String get loginFailed => _t('loginFailed');
  String get loginFillAllFields => _t('loginFillAllFields');
  String get resetPasswordTitle => _t('resetPasswordTitle');
  String get resetPasswordHint => _t('resetPasswordHint');
  String get currentPassword => _t('currentPassword');
  String get newPassword => _t('newPassword');
  String get confirmPassword => _t('confirmPassword');
  String get resetPasswordButton => _t('resetPasswordButton');
  String get resetPasswordSuccess => _t('resetPasswordSuccess');
  String get resetPasswordFailed => _t('resetPasswordFailed');
  String get resetPasswordMismatch => _t('resetPasswordMismatch');
  String get resetPasswordSameAsCurrent => _t('resetPasswordSameAsCurrent');
  String get resetPasswordTooShort => _t('resetPasswordTooShort');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(const Locale('ar')));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
