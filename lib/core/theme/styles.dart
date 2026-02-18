import 'package:flutter/material.dart';

/// Used for all animations in the app
class Times {
  const Times._(); // Prevents instantiation

  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 700);
  static const Duration slower = Duration(milliseconds: 1000);
}

class Sizes {
  const Sizes._(); // Prevents instantiation

  static double hitScale = 1;
  static double get hit => 40 * hitScale; // Standard tap target size
  static double get listItem => 48 * hitScale; // Standard tap target size
}

class IconSizes {
  const IconSizes._(); // Prevents instantiation

  static const double scale = 1;
  static const double xs =
      16 * scale; // For very small icons (e.g., 14-16px range)
  static const double sm =
      20 * scale; // For compact buttons or smaller icons (e.g., 18-20px range)
  static const double med = 24 * scale; // Standard icon size
  static const double lg = 32 * scale; // Large icons
  static const double xl =
      40 * scale; // Extra large icons (used in AuthHeader example)
}

class Insets {
  const Insets._(); // Prevents instantiation

  static double scale = 1; // Base scale factor for padding and margins
  static double offsetScale = 1; // Scale factor for larger offsets

  // Absolute, semantic values based on 4pt grid (common adaptation of 8pt)
  static double get xxs => 2 * scale;
  static double get xs => 4 * scale;
  static double get sm => 8 * scale;
  static double get med => 12 * scale;
  static double get lg => 16 * scale;
  static double get xl => 24 * scale;
  static double get xxl => 32 * scale;
  static double get xxxl => 48 * scale;

  // Offset, used for the edge of the window, or to separate large sections
  static double get offset => 40 * offsetScale;

  // --- Standardized Paddings for UI Elements ---

  /// Standard padding for FilledButton and OutlinedButton.
  /// Results in ~40-48dp height depending on font size and vertical padding.
  /// M3 often uses H:24 for buttons with icons.
  static EdgeInsets get button => EdgeInsets.symmetric(
    horizontal: Insets.lg,
    vertical: Insets.lg,
  ); // H:24, V:12

  /// Compact padding for FilledButton and OutlinedButton variants.
  static EdgeInsets get buttonCompact => EdgeInsets.symmetric(
    horizontal: Insets.med,
    vertical: Insets.xs / 2,
  ); // H:12, V:8

  /// Padding for TextButton, generally more snug.
  static EdgeInsets get textButton => EdgeInsets.symmetric(
    horizontal: Insets.med,
    vertical: Insets.sm,
  ); // H:12, V:8
  // Or Insets.sm for H, Insets.xs for V if even more compact.

  /// Padding for IconButton to help achieve standard tap target sizes.
  /// M3 IconButtons are typically 40x40dp. 8dp padding around a 24dp icon makes 40dp.
  static EdgeInsets get iconButton => EdgeInsets.all(Insets.sm); // 8px
}

class Corners {
  const Corners._(); // Prevents instantiation

  static const double xs = 4;
  static const Radius xsRadius = Radius.circular(xs);
  static const BorderRadius xsBorder = BorderRadius.all(xsRadius);

  static const double sm = 8;
  static const Radius smRadius = Radius.circular(sm);
  static const BorderRadius smBorder = BorderRadius.all(smRadius);

  static const double med = 12;
  static const Radius medRadius = Radius.circular(med);
  static const BorderRadius medBorder = BorderRadius.all(medRadius);

  static const double lg = 16;
  static const Radius lgRadius = Radius.circular(lg);
  static const BorderRadius lgBorder = BorderRadius.all(lgRadius);

  static const double xl = 24;
  static const Radius xlRadius = Radius.circular(xl);
  static const BorderRadius xlBorder = BorderRadius.all(xlRadius);

  static const double xxl = 32;
  static const Radius xxlRadius = Radius.circular(xxl);
  static const BorderRadius xxlBorder = BorderRadius.all(xxlRadius);

  /// For creating perfectly circular elements or fully rounded pill shapes.
  static const Radius fullRadius = Radius.circular(9999);
  static const BorderRadius fullBorder = BorderRadius.all(fullRadius);
}

class Strokes {
  const Strokes._(); // Prevents instantiation

  static const double thin = 1.0;
  static const double medium = 1.8;
  static const double thick = 2.4;
}

class Shadows {
  const Shadows._(); // Prevents instantiation

  static const Color _defaultShadowColor = Colors.black;

  static final List<BoxShadow> universal = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Shadow pointing upward - for bottom sheets or elements above other content
  static final List<BoxShadow> universalUp = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, -1),
    ),
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, -4),
    ),
  ];

  static final List<BoxShadow> small = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.07),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  /// Small shadow pointing upward
  static final List<BoxShadow> smallUp = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.07),
      blurRadius: 3,
      offset: const Offset(0, -1),
    ),
  ];

  static final List<BoxShadow> medium = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  /// Medium shadow pointing upward
  static final List<BoxShadow> mediumUp = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, -4),
    ),
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, -2),
    ),
  ];

  static final List<BoxShadow> large = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  /// Large shadow pointing upward
  static final List<BoxShadow> largeUp = [
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, -8),
    ),
    BoxShadow(
      color: _defaultShadowColor.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, -4),
    ),
  ];
}

/// Vertical Space Widget
class VSpace extends StatelessWidget {
  final double size;
  const VSpace(this.size, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: size);

  static VSpace get xxs => VSpace(Insets.xxs);
  static VSpace get xs => VSpace(Insets.xs);
  static VSpace get sm => VSpace(Insets.sm);
  static VSpace get med => VSpace(Insets.med);
  static VSpace get lg => VSpace(Insets.lg);
  static VSpace get xl => VSpace(Insets.xl);
  static VSpace get xxl => VSpace(Insets.xxl);
  static VSpace get xxxl => VSpace(Insets.xxxl);
  static VSpace get offset => VSpace(Insets.offset);
}

/// Horizontal Space Widget
class HSpace extends StatelessWidget {
  final double size;
  const HSpace(this.size, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(width: size);

  static HSpace get xxs => HSpace(Insets.xxs);
  static HSpace get xs => HSpace(Insets.xs);
  static HSpace get sm => HSpace(Insets.sm);
  static HSpace get med => HSpace(Insets.med);
  static HSpace get lg => HSpace(Insets.lg);
  static HSpace get xl => HSpace(Insets.xl);
  static HSpace get xxl => HSpace(Insets.xxl);
  static HSpace get xxxl => HSpace(Insets.xxxl);
  static HSpace get offset => HSpace(Insets.offset);
}

class FontSizes {
  const FontSizes._();

  static double get scale => 1.0;

  static double get s8 => 8.0 * scale;
  static double get s10 => 10.0 * scale;
  static double get s11 => 11.0 * scale;
  static double get s12 => 12.0 * scale;
  static double get s13 => 13.0 * scale;
  static double get s14 => 14.0 * scale;
  static double get s15 => 15.0 * scale;
  static double get s16 => 16.0 * scale;
  static double get s18 => 18.0 * scale;
  static double get s20 => 20.0 * scale;
  static double get s24 => 24.0 * scale;
  static double get s28 => 28.0 * scale;
  static double get s32 => 32.0 * scale;
  static double get s36 => 36.0 * scale;
  static double get s45 => 45.0 * scale;
  static double get s57 => 57.0 * scale;
}

class Fonts {
  const Fonts._();
  static const String raleway = "Raleway";
  // static const String otherFont = "OtherFontFamily";
}

/// TextStyles - All the core text styles for the app.
/// Mapped to ThemeData.textTheme for consistent usage.
/// Follows Material 3 type scale roles for naming.
/// Assumes "Raleway" font is used.
class TextStyles {
  const TextStyles._();

  static const TextStyle _ralewayBase = TextStyle(
    fontFamily: Fonts.raleway,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Display Styles
  static final TextStyle displayLarge = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s57,
    height: 1.12,
    letterSpacing: -0.25,
  );
  static final TextStyle displayMedium = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s45,
    height: 1.15,
    letterSpacing: 0,
  );
  static final TextStyle displaySmall = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s36,
    height: 1.22,
    letterSpacing: 0,
  );

  // Headline Styles
  static final TextStyle headlineLarge = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s32,
    height: 1.25,
    letterSpacing: 0,
  );
  static final TextStyle headlineMedium = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s28,
    height: 1.28,
    letterSpacing: 0,
  );
  static final TextStyle headlineSmall = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s24,
    height: 1.33,
    letterSpacing: 0,
  );

  // Title Styles
  static final TextStyle titleLarge = _ralewayBase.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: FontSizes.s20, // M3 is 22px, Raleway 500 (Medium)
    height: 1.27,
    letterSpacing: 0,
  );
  static final TextStyle titleMedium = _ralewayBase.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: FontSizes.s16, // M3 is 16px, Raleway 500 (Medium)
    height: 1.5,
    letterSpacing: 0.15,
  );
  static final TextStyle titleSmall = _ralewayBase.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: FontSizes.s14, // M3 is 14px, Raleway 500 (Medium)
    height: 1.42,
    letterSpacing: 0.1,
  );

  // Body Text Styles
  static final TextStyle bodyLarge = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s16, // M3 is 16px, Raleway 400 (Regular)
    height: 1.5,
    letterSpacing: 0.15,
  );
  static final TextStyle bodyMedium = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s14, // M3 is 14px, Raleway 400 (Regular)
    height: 1.42,
    letterSpacing: 0.25,
  );
  static final TextStyle bodySmall = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s12, // M3 is 12px, Raleway 400 (Regular)
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label Styles (Often used for buttons)
  static final TextStyle labelLarge = _ralewayBase.copyWith(
    fontWeight: FontWeight.w500, // M3 is 14px, Raleway 500 (Medium)
    fontSize: FontSizes.s14,
    height: 1.42,
    letterSpacing: 0.1,
  );
  static final TextStyle labelMedium = _ralewayBase.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: FontSizes.s12, // M3 is 12px, Raleway 500 (Medium)
    height: 1.33,
    letterSpacing: 0.5,
  );
  static final TextStyle labelSmall = _ralewayBase.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: FontSizes.s11, // M3 is 11px, Raleway 500 (Medium)
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Custom styles (if needed, not directly in M3 TextTheme slots)
  static final TextStyle caption = _ralewayBase.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: FontSizes.s10,
    height: 1.3,
    letterSpacing: 0.4,
  );

  static final TextStyle overline = _ralewayBase.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: FontSizes.s10,
    height: 1.2,
    letterSpacing: 0.5,
  );
}
