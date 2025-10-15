import 'package:flutter/material.dart';
import '/theme/custom_colors.dart'; // ✅ Import the custom colors extension

// 🎨 TYPOGRAPHY - Modern, readable, Gen Z friendly
const TextTheme appTextTheme = TextTheme(
  // Display styles - for big headlines
  displayLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 40,
    letterSpacing: -1.5,
    height: 1.1,
  ),
  displayMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: -1.2,
    height: 1.15,
  ),
  displaySmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 32,
    letterSpacing: -1.0,
    height: 1.2,
  ),

  // Headline styles
  // - for section headers
  headlineLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 28,
    letterSpacing: -0.8,
    height: 1.25,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: -0.6,
    height: 1.3,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: -0.4,
    height: 1.35,
  ),

  // Title styles - for card titles
  titleLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    letterSpacing: -0.3,
    height: 1.4,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: -0.2,
    height: 1.4,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0,
    height: 1.4,
  ),

  // Body styles - for regular text
  bodyLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    letterSpacing: 0.15,
    height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.normal,
    fontSize: 14,
    letterSpacing: 0.25,
    height: 1.45,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.normal,
    fontSize: 12,
    letterSpacing: 0.4,
    height: 1.4,
  ),

  // Label styles - for buttons and small UI elements
  labelLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.8,
    height: 1.2,
  ),
  labelMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.5,
    height: 1.2,
  ),
  labelSmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 10,
    letterSpacing: 0.5,
    height: 1.2,
  ),
);

// 🎨 COLOR CONSTANTS - Inspired by your logo
const Color leafGreen = Color(0xFF7FD86B); // From your logo
const Color freshGreen = Color(0xFF5FC54E);
const Color vibrantTeal = Color(0xFF00D9C0);
const Color electricBlue = Color(0xFF4B7BF5);
const Color sunnyYellow = Color(0xFFFFC107);
const Color coralPink = Color(0xFFFF6B9D);

// ☀️ LIGHT THEME - Fresh, vibrant, inspired by growth
final ThemeData lightThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // ✅ ADDED: Custom theme extension for heatmap colors
  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      successGradient: [leafGreen, freshGreen],
      errorGradient: [Color(0xFFFF5449), sunnyYellow],
      heatmapExpense: Color(0xFFFF8A80), // A softer red for expenses
      heatmapIncome: vibrantTeal,         // A cool teal for income
      categoryColors: {},
    ),
  ],

  // Primary colors from your logo's green
  colorScheme: ColorScheme.light(
    primary: leafGreen,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE8F5E3),
    onPrimaryContainer: const Color(0xFF1A5010),

    secondary: vibrantTeal,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFD0F5F0),
    onSecondaryContainer: const Color(0xFF003D37),

    tertiary: electricBlue,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFDEE7FF),
    onTertiaryContainer: const Color(0xFF001A41),

    error: const Color(0xFFFF5449),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),

    surface: Colors.white,
    onSurface: const Color(0xFF1C1B1F),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF7F7F7),
    surfaceContainer: const Color(0xFFF2F2F7),
    surfaceContainerHigh: const Color(0xFFECECF1),
    surfaceContainerHighest: const Color(0xFFE6E6EB),

    outline: const Color(0xFFCACAD0),
    outlineVariant: const Color(0xFFE6E6EB),
    shadow: const Color(0xFF000000),

    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF4),
    inversePrimary: const Color(0xFFADDD9F),
  ),

  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  textTheme: appTextTheme,

  // Elevated elements - floating, modern
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 8,
      shadowColor: leafGreen.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.08),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    clipBehavior: Clip.antiAlias,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFE8F5E3),
    selectedColor: leafGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFFE6E6EB),
    thickness: 1,
    space: 1,
  ),
);

// 🌙 DARK THEME - Sleek, modern, with vibrant accents
final ThemeData darkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // ✅ ADDED: Custom theme extension for heatmap colors
  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      successGradient: [leafGreen, freshGreen],
      errorGradient: [Color(0xFFFFB4AB), sunnyYellow],
      heatmapExpense: Color(0xFFCF6679), // A muted, elegant red for expenses
      heatmapIncome: vibrantTeal,         // Vibrant teal pops nicely in dark mode
      categoryColors: {},
    ),
  ],

  colorScheme: ColorScheme.dark(
    primary: leafGreen,
    onPrimary: const Color(0xFF1B885E),
    primaryContainer: const Color(0xFF2D5026),
    onPrimaryContainer: const Color(0xFFCBEFBC),

    secondary: vibrantTeal,
    onSecondary: const Color(0xFF34D5C4),
    secondaryContainer: const Color(0xFF005048),
    onSecondaryContainer: const Color(0xFFA6F2E8),

    tertiary: electricBlue,
    onTertiary: const Color(0xFF002C6D),
    tertiaryContainer: const Color(0xFF1E4791),
    onTertiaryContainer: const Color(0xFFDEE7FF),

    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),

    surface: const Color(0xFF121212),
    onSurface: const Color(0xFFE6E1E5),
    surfaceContainerLowest: const Color(0xFF0D0D0D),
    surfaceContainerLow: const Color(0xFF1A1A1A),
    surfaceContainer: const Color(0xFF1E1E1E),
    surfaceContainerHigh: const Color(0xFF282828),
    surfaceContainerHighest: const Color(0xFF333333),

    outline: const Color(0xFF54565A),
    outlineVariant: const Color(0xFF44464A),
    shadow: const Color(0xFF000000),

    inverseSurface: const Color(0xFFE6E1E5),
    onInverseSurface: const Color(0xFF313033),
    inversePrimary: leafGreen,
  ),

  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  textTheme: appTextTheme,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 12,
      shadowColor: leafGreen.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  cardTheme: CardTheme(
    elevation: 12,
    shadowColor: Colors.black.withOpacity(0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    clipBehavior: Clip.antiAlias,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF2D5026),
    selectedColor: leafGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF44464A),
    thickness: 1,
    space: 1,
  ),
);

// 💖 BARBIE THEME - Playful, pink, premium
final ThemeData barbieThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // ✅ ADDED: Custom theme extension for heatmap colors
  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      successGradient: [coralPink, Color(0xFFFF9EC5)],
      errorGradient: [Color(0xFFFF5252), sunnyYellow],
      heatmapExpense: Color(0xFFF48FB1), // A softer, complementary pink
      heatmapIncome: sunnyYellow,         // Sunny yellow for a cheerful income color
      categoryColors: {},
    ),
  ],

  colorScheme: ColorScheme.light(
    primary: coralPink,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFFFE8F0),
    onPrimaryContainer: const Color(0xFF5C0020),

    secondary: const Color(0xFFFF9EC5),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFFFD6E9),
    onSecondaryContainer: const Color(0xFF3D0018),

    tertiary: const Color(0xFFFFB74D),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFFFE5B4),
    onTertiaryContainer: const Color(0xFF3D2800),

    error: const Color(0xFFFF5252),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),

    surface: const Color(0xFFFFF8F7),
    onSurface: const Color(0xFF5C3645),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFFFF0F5),
    surfaceContainer: const Color(0xFFFFE8F0),
    surfaceContainerHigh: const Color(0xFFFFD9E7),
    surfaceContainerHighest: const Color(0xFFFFCBDD),

    outline: const Color(0xFFFFB3D9),
    outlineVariant: const Color(0xFFFFD9E7),
    shadow: coralPink.withOpacity(0.3),

    inverseSurface: const Color(0xFF614A54),
    onInverseSurface: const Color(0xFFFFF0F5),
    inversePrimary: const Color(0xFFFFB3D9),
  ),

  scaffoldBackgroundColor: const Color(0xFFFFF8F7),
  textTheme: appTextTheme.apply(
    bodyColor: const Color(0xFF5C3645),
    displayColor: const Color(0xFF4A2D3A),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 10,
      shadowColor: coralPink.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    ),
  ),

  cardTheme: CardTheme(
    elevation: 10,
    shadowColor: coralPink.withOpacity(0.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    clipBehavior: Clip.antiAlias,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFFFE8F0),
    selectedColor: coralPink,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  ),

  dividerTheme: DividerThemeData(
    color: coralPink.withOpacity(0.2),
    thickness: 1,
    space: 1,
  ),
);