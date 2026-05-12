import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryTeal = Color(0xFF006D77); 
  static const Color primaryLight = Color(0xFF83C5BE); 
  static const Color accentGold = Color(0xFFD4AF37); 
  
  // Light Mode Colors
  static const Color surfaceWhite = Color(0xFFFDFDFD); 
  static const Color backgroundLight = Color(0xFFF4F9F9); 
  static const Color textDark = Color(0xFF1B4347); 

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F1415); // Deep Slate Black
  static const Color surfaceDark = Color(0xFF1A2123); // Deep Teal Slate
  static const Color textLight = Color(0xFFE0E0E0);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return _buildTheme(base, isDark: false);
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return _buildTheme(base, isDark: true);
  }

  static ThemeData _buildTheme(ThemeData base, {required bool isDark}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      secondary: accentGold,
      tertiary: primaryLight,
      surface: isDark ? surfaceDark : surfaceWhite,
      background: isDark ? backgroundDark : backgroundLight,
      error: const Color(0xFFE29578),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: isDark ? textLight : const Color(0xFF2D3132),
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? backgroundDark : backgroundLight,
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
        displayLarge: TextStyle(fontWeight: FontWeight.w900, color: isDark ? textLight : textDark),
        headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: isDark ? textLight : textDark),
        titleLarge: TextStyle(fontWeight: FontWeight.w900, color: isDark ? textLight : textDark),
        titleMedium: TextStyle(fontWeight: FontWeight.w800, color: isDark ? textLight : textDark),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: isDark ? textLight.withOpacity(0.9) : const Color(0xFF2D3132)),
        bodyMedium: TextStyle(fontWeight: FontWeight.w500, color: isDark ? textLight.withOpacity(0.8) : const Color(0xFF2D3132)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: isDark ? Colors.white : primaryTeal,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : primaryTeal),
      ),
      cardTheme: CardThemeData(
        color: isDark ? surfaceDark : surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: (isDark ? Colors.white : primaryTeal).withOpacity(0.05), width: 1),
        ),
        shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isDark ? 0 : 4,
          shadowColor: primaryTeal.withOpacity(0.3),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? primaryLight : primaryTeal,
          side: BorderSide(color: (isDark ? primaryLight : primaryTeal).withOpacity(0.2), width: 1.5),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: (isDark ? Colors.white : primaryTeal).withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        labelStyle: TextStyle(color: (isDark ? Colors.white : primaryTeal).withOpacity(0.5), fontWeight: FontWeight.w600),
        floatingLabelStyle: TextStyle(color: isDark ? primaryLight : primaryTeal, fontWeight: FontWeight.w900),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? surfaceDark : Colors.white,
        indicatorColor: primaryTeal.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.white : primaryTeal),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: isDark ? primaryLight : primaryTeal, size: 28);
          }
          return IconThemeData(color: (isDark ? Colors.white : primaryTeal).withOpacity(0.4), size: 24);
        }),
      ),
    );
  }
}
