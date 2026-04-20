import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Paleta principal (del diseño HTML)
  static const Color primary       = Color(0xFF025E9F);
  static const Color onPrimary     = Color(0xFFEDF3FF);
  static const Color primaryContainer = Color(0xFF73B2F9);

  static const Color secondary     = Color(0xFF006945);
  static const Color secondaryContainer = Color(0xFF90F7C2);

  static const Color tertiary      = Color(0xFF7C40A1);
  static const Color tertiaryContainer = Color(0xFFD896FE);

  static const Color surface       = Color(0xFFF5F7FA);
  static const Color surfaceContainerLow  = Color(0xFFEEF1F4);
  static const Color surfaceContainerHigh = Color(0xFFDFE3E7);
  static const Color surfaceContainerHighest = Color(0xFFD9DDE1);

  static const Color onSurface     = Color(0xFF2C2F32);
  static const Color onSurfaceVariant = Color(0xFF595C5E);

  static const Color outline       = Color(0xFF74777A);
  static const Color error         = Color(0xFFB31B25);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Color(0xFF003055),
        secondary: AppColors.secondary,
        onSecondary: Color(0xFFC9FFDF),
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: Color(0xFF005E3E),
        tertiary: AppColors.tertiary,
        onTertiary: Color(0xFFFDEEFF),
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: Color(0xFF4D0A72),
        error: AppColors.error,
        onError: Color(0xFFFFEFEE),
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        outline: AppColors.outline,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 17, color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15, color: AppColors.onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w700,
          letterSpacing: 1.5, color: AppColors.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary,
        ),
      ),
    );
  }
}