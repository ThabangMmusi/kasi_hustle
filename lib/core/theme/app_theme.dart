import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'styles.dart';

// ==================== COLORS ====================

class AppColors {
  // Brand Colors
  // Primary: Vibrant Orange-Red — symbolizes hustle, energy, and movement
  static const Color kasiRed = Color(0xFFE44A27);
  static const Color kasiRedDark = Color(0xFFCC3515);
  static const Color kasiGold = kasiRed; // Alias for backward compatibility
  static const Color kasiGoldDark =
      kasiRedDark; // Alias for backward compatibility

  // Secondary Colors
  // Deep Charcoal-Brown — adds contrast, stability, and local warmth
  static const Color kasiCharcoal = Color(0xFF2E1C13);

  // Background Colors
  // Soft Off-White — gives a natural, textured feel like township murals
  static const Color kasiOffWhite = Color(0xFFF4EDE3);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = kasiCharcoal;
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF3A3A3A);

  // Light Mode Colors
  static const Color lightBackground = kasiOffWhite;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFAF6F0);
  static const Color lightBorder = Color(0xFFE5DED4);

  // Status Colors
  static const Color success = Color(0xFF00D26A);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Text Colors (Dark Mode)
  static const Color darkTextPrimary = kasiOffWhite;
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF666666);

  // Text Colors (Light Mode)
  static const Color lightTextPrimary = kasiCharcoal;
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextTertiary = Color(0xFF999999);
}

// ==================== DARK THEME ====================

class KasiTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kasiRed,
        secondary: AppColors.kasiRedDark,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        // M3 style filled button
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.kasiGold,
          foregroundColor: Colors.white,
          padding: Insets.button,
          shape: RoundedRectangleBorder(borderRadius: Corners.smBorder),

          textStyle: TextStyles.labelLarge,
          elevation: 1,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kasiGold,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyles.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kasiGold,
          side: const BorderSide(color: AppColors.kasiGold, width: 2),
          padding: Insets.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.med),
          ),
          textStyle: TextStyles.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.kasiGold,
          padding: Insets.textButton,
          textStyle: TextStyles.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        hintStyle: TextStyle(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: const BorderSide(color: AppColors.kasiGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        prefixIconColor: AppColors.kasiGold,
        suffixIconColor: AppColors.darkTextSecondary,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),

      // Text Theme
      textTheme:
          TextTheme(
            displayLarge: TextStyles.displayLarge,
            displayMedium: TextStyles.displayMedium,
            displaySmall: TextStyles.displaySmall,
            headlineLarge: TextStyles.headlineLarge,
            headlineMedium: TextStyles.headlineMedium,
            headlineSmall: TextStyles.headlineSmall,
            titleLarge: TextStyles.titleLarge,
            titleMedium: TextStyles.titleMedium,
            titleSmall: TextStyles.titleSmall,
            bodyLarge: TextStyles.bodyLarge,
            bodyMedium: TextStyles.bodyMedium,
            bodySmall: TextStyles.bodySmall,
            labelLarge: TextStyles.labelLarge,
            labelMedium: TextStyles.labelMedium,
            labelSmall: TextStyles.labelSmall,
          ).apply(
            bodyColor: AppColors.darkTextPrimary,
            displayColor: AppColors.darkTextPrimary,
          ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.kasiGold,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder,
        thickness: Strokes.thin,
        space: Strokes.thin,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.kasiGold,
        labelStyle: TextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        side: BorderSide(color: AppColors.darkBorder, width: Strokes.thin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xxl),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xl),
        ),
        titleTextStyle: TextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: TextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.med),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.kasiGold,
      ),
    );
  }

  // ==================== LIGHT THEME ====================

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.kasiGold,
        secondary: AppColors.kasiGoldDark,
        surface: AppColors.lightBackground,
        surfaceContainer: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.lightBackground,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyles.titleLarge.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.med),
          side: BorderSide(color: AppColors.lightBorder, width: Strokes.thin),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kasiGold,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: Insets.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.med),
          ),
          textStyle: TextStyles.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kasiGoldDark,
          side: BorderSide(
            color: AppColors.kasiGoldDark,
            width: Strokes.medium,
          ),
          padding: Insets.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.med),
          ),
          textStyle: TextStyles.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.kasiGoldDark,
          padding: Insets.textButton,
          textStyle: TextStyles.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        hintStyle: TextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: BorderSide(
            color: AppColors.lightBorder,
            width: Strokes.thin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: BorderSide(
            color: AppColors.lightBorder,
            width: Strokes.thin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: BorderSide(
            color: AppColors.kasiGoldDark,
            width: Strokes.medium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: BorderSide(color: AppColors.error, width: Strokes.thin),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: BorderSide(color: AppColors.error, width: Strokes.medium),
        ),
        prefixIconColor: AppColors.kasiGoldDark,
        suffixIconColor: AppColors.lightTextSecondary,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.lightTextPrimary,
        size: IconSizes.med,
      ),

      // Text Theme
      textTheme:
          TextTheme(
            displayLarge: TextStyles.displayLarge,
            displayMedium: TextStyles.displayMedium,
            displaySmall: TextStyles.displaySmall,
            headlineLarge: TextStyles.headlineLarge,
            headlineMedium: TextStyles.headlineMedium,
            headlineSmall: TextStyles.headlineSmall,
            titleLarge: TextStyles.titleLarge,
            titleMedium: TextStyles.titleMedium,
            titleSmall: TextStyles.titleSmall,
            bodyLarge: TextStyles.bodyLarge,
            bodyMedium: TextStyles.bodyMedium,
            bodySmall: TextStyles.bodySmall,
            labelLarge: TextStyles.labelLarge,
            labelMedium: TextStyles.labelMedium,
            labelSmall: TextStyles.labelSmall,
          ).apply(
            bodyColor: AppColors.lightTextPrimary,
            displayColor: AppColors.lightTextPrimary,
          ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.kasiGoldDark,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.lightBorder,
        thickness: Strokes.thin,
        space: Strokes.thin,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCard,
        selectedColor: AppColors.kasiGold,
        labelStyle: TextStyles.labelMedium.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        side: BorderSide(color: AppColors.lightBorder, width: Strokes.thin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xxl),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xl),
        ),
        titleTextStyle: TextStyles.headlineSmall.copyWith(
          color: AppColors.lightTextPrimary,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: TextStyles.bodyMedium.copyWith(
          color: AppColors.lightBackground,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.med),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.kasiGoldDark,
      ),
    );
  }
}

// ==================== THEME EXTENSIONS ====================

/// Custom colors extension for easy access to theme colors and modes
extension ThemeExtension on BuildContext {
  // Quick access to colors from ColorScheme
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get backgroundColor => Theme.of(this).colorScheme.surface;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get textPrimary => Theme.of(this).colorScheme.onSurface;

  // Theme mode check
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Conditional colors based on theme
  Color get cardColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
  Color get borderColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
}
