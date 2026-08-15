import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors sampled from assets/images/logo.png
  static const Color primaryNavy = Color(0xFF202D45);
  static const Color navyLight = Color(0xFF4E6288);
  static const Color accentGold = Color(0xFFAF9748);
  static const Color accentGoldLight = Color(0xFFC3A54F);

  // Light Mode
  static const Color surfaceWhite = Color(0xFFFDFCFA);
  static const Color backgroundLight = Color(0xFFF6F4EE);
  static const Color textDark = Color(0xFF202D45);

  // Dark Mode (logo black + navy)
  static const Color backgroundDark = Color(0xFF0A0C10);
  static const Color surfaceDark = Color(0xFF161B26);
  static const Color textLight = Color(0xFFE8E4D8);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return _buildTheme(base, isDark: false);
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return _buildTheme(base, isDark: true);
  }

  static ThemeData _buildTheme(ThemeData base, {required bool isDark}) {
    // في الوضع الليلي نستخدم أزرق أفتح كـ primary حتى لا ينهار ColorScheme
    // ولا تختفي الأزرار/المفاتيح على خلفية داكنة.
    final primary = isDark ? navyLight : primaryNavy;
    final onSurface = isDark ? textLight : textDark;
    final surface = isDark ? surfaceDark : surfaceWhite;
    final background = isDark ? backgroundDark : backgroundLight;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: accentGold,
      onSecondary: primaryNavy,
      tertiary: isDark ? accentGoldLight : navyLight,
      onTertiary: primaryNavy,
      error: const Color(0xFFB85C4A),
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: isDark ? const Color(0xFF1E2533) : const Color(0xFFF0EDE4),
      onSurfaceVariant: onSurface.withValues(alpha: 0.7),
      outline: (isDark ? accentGold : primaryNavy).withValues(alpha: 0.25),
      outlineVariant: (isDark ? accentGold : primaryNavy).withValues(alpha: 0.12),
    );

    final cairo = GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: cairo.copyWith(
        displayLarge: cairo.displayLarge?.copyWith(fontWeight: FontWeight.w900, color: onSurface),
        headlineMedium: cairo.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: onSurface),
        titleLarge: cairo.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: onSurface),
        titleMedium: cairo.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: onSurface),
        bodyLarge: cairo.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: onSurface.withValues(alpha: 0.92)),
        bodyMedium: cairo.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: onSurface.withValues(alpha: 0.85)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: isDark ? textLight : primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(color: isDark ? textLight : primaryNavy),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: (isDark ? accentGold : primaryNavy).withValues(alpha: 0.1), width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
        clipBehavior: Clip.antiAlias,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentGold;
          return isDark ? const Color(0xFF9AA3B2) : const Color(0xFFB0B8C4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGold.withValues(alpha: 0.45);
          }
          return (isDark ? textLight : primaryNavy).withValues(alpha: 0.18);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? accentGold : primaryNavy,
          foregroundColor: isDark ? primaryNavy : Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isDark ? 0 : 4,
          shadowColor: primaryNavy.withValues(alpha: 0.3),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? accentGoldLight : primaryNavy,
          side: BorderSide(color: (isDark ? accentGold : primaryNavy).withValues(alpha: 0.3), width: 1.5),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E2533) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: (isDark ? accentGold : primaryNavy).withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
        floatingLabelStyle: TextStyle(color: isDark ? accentGoldLight : primaryNavy, fontWeight: FontWeight.w900),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary.withValues(alpha: 0.85),
        textColor: onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accentGold.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: onSurface),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: isDark ? accentGoldLight : primaryNavy, size: 28);
          }
          return IconThemeData(color: onSurface.withValues(alpha: 0.4), size: 24);
        }),
      ),
    );
  }
}
