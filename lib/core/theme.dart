import 'package:flutter/material.dart';

/// Centralised design tokens for the whole app.
/// A calm, premium dark palette built around a mint/teal vitality accent.
class AppColors {
  // Backgrounds
  static const bg = Color(0xFF0E1116); // deep ink
  static const surface = Color(0xFF171B22); // cards
  static const surfaceAlt = Color(0xFF1F2530); // elevated / inputs
  static const surfaceHigh = Color(0xFF272E3B);

  // Accents
  static const primary = Color(0xFF3DDC97); // mint — success / vitality
  static const primaryDim = Color(0xFF1B3A2D);
  static const blue = Color(0xFF4EA8FF);
  static const blueDim = Color(0xFF15263B);
  static const orange = Color(0xFFFFB454);
  static const danger = Color(0xFFFF6B6B);
  static const dangerDim = Color(0xFF2A1718);
  static const purple = Color(0xFFA98BFF);

  // Text
  static const textHi = Color(0xFFF2F5F8);
  static const textMid = Color(0xFF9AA5B1);
  static const textLo = Color(0xFF5E6B7A);

  // Lines
  static const hairline = Color(0x14FFFFFF); // white @ 8%
  static const hairlineSoft = Color(0x0AFFFFFF);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF3DDC97), Color(0xFF24B6C9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const blueGradient = LinearGradient(
    colors: [Color(0xFF4EA8FF), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF1A2A3F), Color(0xFF14202E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Spacing scale.
class Gap {
  static const xs = SizedBox(height: 4, width: 4);
  static const s = SizedBox(height: 8, width: 8);
  static const m = SizedBox(height: 12, width: 12);
  static const l = SizedBox(height: 16, width: 16);
  static const xl = SizedBox(height: 24, width: 24);
  static const xxl = SizedBox(height: 32, width: 32);
}

class AppRadius {
  static const card = 18.0;
  static const chip = 12.0;
  static const pill = 999.0;
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.primary,
        secondary: AppColors.blue,
        error: AppColors.danger,
        onPrimary: Color(0xFF06251A),
        onSurface: AppColors.textHi,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textHi,
        displayColor: AppColors.textHi,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceHigh,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.15),
        trackHeight: 4,
        valueIndicatorColor: AppColors.surfaceHigh,
        valueIndicatorTextStyle: const TextStyle(color: AppColors.textHi),
      ),
      dividerColor: AppColors.hairline,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF12161D),
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textLo,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textLo,
            size: 24,
          );
        }),
        height: 68,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: TextStyle(color: AppColors.textHi),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
