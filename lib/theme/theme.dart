// lib/theme/theme.dart

import 'package:flutter/material.dart';
import '/theme/custom_colors.dart';

// 耳 MODERN TYPOGRAPHY SYSTEM
// Using Inter for body text (excellent readability) and SF Pro Display for headlines
const TextTheme appTextTheme = TextTheme(
  // Display styles - Bold, impactful headlines
  displayLarge: TextStyle(
    fontFamily: 'SF_Pro',
    fontWeight: FontWeight.w700,
    fontSize: 57,
    letterSpacing: -0.25,
    height: 1.12,
  ),
  displayMedium: TextStyle(
    fontFamily: 'SF_Pro',
    fontWeight: FontWeight.w700,
    fontSize: 45,
    letterSpacing: 0,
    height: 1.16,
  ),
  displaySmall: TextStyle(
    fontFamily: 'SF_Pro',
    fontWeight: FontWeight.w600,
    fontSize: 36,
    letterSpacing: 0,
    height: 1.22,
  ),

  // Headlines - Section headers
  headlineLarge: TextStyle(
    fontFamily: 'SF_Pro',
    fontWeight: FontWeight.w600,
    fontSize: 32,
    letterSpacing: 0,
    height: 1.25,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'SF_Pro',
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: 0,
    height: 1.29,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'SF_Pro',
    fontWeight: FontWeight.w600,
    fontSize: 24,
    letterSpacing: 0,
    height: 1.33,
  ),

  // Titles - Card and component titles
  titleLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 22,
    letterSpacing: 0,
    height: 1.27,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.15,
    height: 1.5,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.1,
    height: 1.43,
  ),

  // Body - Main content text
  bodyLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.5,
    height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.25,
    height: 1.43,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
    height: 1.33,
  ),

  // Labels - Buttons and UI elements
  labelLarge: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.1,
    height: 1.43,
  ),
  labelMedium: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.5,
    height: 1.33,
  ),
  labelSmall: TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 0.5,
    height: 1.45,
  ),
);

// 🌿 JAPANDI COLOR PALETTE & BOTANICAL ACCENTS
// Fusion of Japanese Wabi-Sabi organic earth tones and Scandinavian functional clarity
const Color japandiMatcha = Color(0xFF3B4D3C);      // Deep Kuro-Matsu Matcha
const Color japandiMatchaLight = Color(0xFF8FA88C); // Luminous Sage / Matcha Mist
const Color japandiTerracotta = Color(0xFFB87D56);  // Bizen Warm Clay
const Color japandiTerracottaLight = Color(0xFFD99B72); // Warm Terracotta Glow
const Color japandiAizome = Color(0xFF6B7F8E);      // Aizome Indigo Mist
const Color japandiYuzu = Color(0xFFC4823F);        // Yuzu Amber
const Color japandiAkane = Color(0xFFB84E3A);       // Akane Red Ochre

// Backward-compatible semantic constants
const Color warningAmber = japandiYuzu;
const Color errorRed = japandiAkane;
const Color primaryGreen = Color(0xFF477A56);

// 🌿 LIGHT THEME - Japandi Washi & Hinoki
final ThemeData lightThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      successGradient: [Color(0xFF477A56), Color(0xFF355E42)],
      errorGradient: [Color(0xFFB84E3A), Color(0xFFC4823F)],
      heatmapExpense: Color(0xFFB84E3A),
      heatmapIncome: Color(0xFF477A56),
      categoryColors: {},
    ),
  ],

  colorScheme: const ColorScheme.light(
    // Primary - Deep Matcha
    primary: japandiMatcha,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE2EADF),
    onPrimaryContainer: Color(0xFF1E2B1F),

    // Secondary - Warm Terracotta
    secondary: japandiTerracotta,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF5E8DE),
    onSecondaryContainer: Color(0xFF5C351B),

    // Tertiary - Indigo Mist
    tertiary: japandiAizome,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE0E8EE),
    onTertiaryContainer: Color(0xFF1F313E),

    // Error - Akane Ochre
    error: japandiAkane,
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFCEBE8),
    onErrorContainer: Color(0xFF6E1E0F),

    // Surface - Warm Washi Paper & Hinoki Neutral
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1F1E1B), // Sumi Ink Charcoal
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFBF9F5), // Alabaster
    surfaceContainer: Color(0xFFF4F1EA),    // Warm Linen
    surfaceContainerHigh: Color(0xFFEAE5DB), // Warm Stone
    surfaceContainerHighest: Color(0xFFDFD8CC),

    // Outline - Tatami & Straw Fine Dividers
    outline: Color(0xFFD8D2C4),
    outlineVariant: Color(0xFFE8E3D8),
    shadow: Color(0x0A000000),

    // Inverse
    inverseSurface: Color(0xFF1F1E1B),
    onInverseSurface: Color(0xFFF7F5F0),
    inversePrimary: japandiMatchaLight,
  ),

  scaffoldBackgroundColor: const Color(0xFFF7F5F0), // Natural Washi Paper Base
  textTheme: appTextTheme,

  // Card theme - Tactile, minimal, gentle radius
  cardTheme: const CardThemeData(
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  ),

  // Elevated button - Primary earthy button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: japandiMatcha,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
    ),
  ),

  // Filled button
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      backgroundColor: japandiTerracotta,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),

  // Chip theme - Organic Pill Style
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFFF4F1EA),
    selectedColor: Color(0xFFE2EADF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      side: BorderSide(color: Color(0xFFE8E3D8), width: 0.8),
    ),
    labelStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1F1E1B),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE8E3D8),
    thickness: 1,
    space: 1,
  ),

  // Input decoration - Washi tactile fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE8E3D8), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE8E3D8), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: japandiMatcha, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: japandiAkane, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
);

// 🌿 DARK THEME - Japandi Sumi Charcoal & Night Cedar
final ThemeData darkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      successGradient: [Color(0xFF6E9C7B), Color(0xFF477A56)],
      errorGradient: [Color(0xFFE06D53), Color(0xFFC4823F)],
      heatmapExpense: Color(0xFFE06D53),
      heatmapIncome: Color(0xFF6E9C7B),
      categoryColors: {},
    ),
  ],

  colorScheme: const ColorScheme.dark(
    // Primary - Luminous Sage Matcha
    primary: japandiMatchaLight,
    onPrimary: Color(0xFF182419),
    primaryContainer: Color(0xFF2C3A2D),
    onPrimaryContainer: Color(0xFFDDE8DB),

    // Secondary - Terracotta Glow
    secondary: japandiTerracottaLight,
    onSecondary: Color(0xFF3D200E),
    secondaryContainer: Color(0xFF4A2F1B),
    onSecondaryContainer: Color(0xFFF8E3D5),

    // Tertiary - Soft Indigo
    tertiary: Color(0xFF93A8B8),
    onTertiary: Color(0xFF1B2A34),
    tertiaryContainer: Color(0xFF2E404D),
    onTertiaryContainer: Color(0xFFD8E4EC),

    // Error - Terracotta Red
    error: Color(0xFFE06D53),
    onError: Color(0xFF451006),
    errorContainer: Color(0xFF5C1C11),
    onErrorContainer: Color(0xFFFBDAD5),

    // Surface - Sumi Slate & Kuroshio Cedar
    surface: Color(0xFF1C1C19),
    onSurface: Color(0xFFEDEAE2), // Warm Washi White
    surfaceContainerLowest: Color(0xFF121210),
    surfaceContainerLow: Color(0xFF181815),
    surfaceContainer: Color(0xFF22221E),
    surfaceContainerHigh: Color(0xFF2C2C27),
    surfaceContainerHighest: Color(0xFF383832),

    // Outline - Charcoal Bamboo
    outline: Color(0xFF3D3D36),
    outlineVariant: Color(0xFF2B2B26),
    shadow: Color(0xFF000000),

    // Inverse
    inverseSurface: Color(0xFFEDEAE2),
    onInverseSurface: Color(0xFF181815),
    inversePrimary: japandiMatcha,
  ),

  scaffoldBackgroundColor: const Color(0xFF141412), // Deep Charcoal Ink Base
  textTheme: appTextTheme,

  cardTheme: const CardThemeData(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: japandiMatchaLight,
      foregroundColor: const Color(0xFF182419),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      backgroundColor: japandiTerracottaLight,
      foregroundColor: const Color(0xFF3D200E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),

  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFF22221E),
    selectedColor: Color(0xFF2C3A2D),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      side: BorderSide(color: Color(0xFF2B2B26), width: 0.8),
    ),
    labelStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Color(0xFFEDEAE2),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF2B2B26),
    thickness: 1,
    space: 1,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1C1C19),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2B2B26), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2B2B26), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: japandiMatchaLight, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE06D53), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
);

// 猪 BARBIE THEME - Refined and sophisticated
final ThemeData barbieThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      successGradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
      errorGradient: [Color(0xFFEF4444), Color(0xFFF59E0B)],
      heatmapExpense: Color(0xFFF472B6), // Pink-400
      heatmapIncome: Color(0xFFFBBF24), // Amber-400
      categoryColors: {},
    ),
  ],

  colorScheme: const ColorScheme.light(
    primary: Color(0xFFEC4899), // Pink-500
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFCE7F3), // Pink-100
    onPrimaryContainer: Color(0xFF831843), // Pink-900

    secondary: Color(0xFFF472B6), // Pink-400
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFDF2F8), // Pink-50
    onSecondaryContainer: Color(0xFF9F1239), // Pink-800

    tertiary: Color(0xFFFBBF24), // Amber-400
    onTertiary: Color(0xFF78350F), // Amber-900
    tertiaryContainer: Color(0xFFFEF3C7), // Amber-100
    onTertiaryContainer: Color(0xFF78350F),

    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),

    // Surface - Using Rose family for a more subtle thematic background
    surface: Color(0xFFFFFBFE), // Custom near-white
    onSurface: Color(0xFF500724), // Rose-950
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFF1F2), // Rose-50
    surfaceContainer: Color(0xFFFFE4E6), // Rose-100
    surfaceContainerHigh: Color(0xFFFECDD3), // Rose-200
    surfaceContainerHighest: Color(0xFFFDA4AF), // Rose-300

    // Outline - Borders and dividers from Rose family
    outline: Color(0xFFFDA4AF), // Rose-300
    outlineVariant: Color(0xFFFECDD3), // Rose-200
    shadow: Color(0xFF000000),

    inverseSurface: Color(0xFF831843),
    onInverseSurface: Color(0xFFFDF2F8),
    inversePrimary: Color(0xFFF9A8D4),
  ),

  scaffoldBackgroundColor: const Color(0xFFFFFBFE), // Custom near-white base
  textTheme: appTextTheme,

  cardTheme: const CardThemeData(
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),

  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFFFFE4E6), // Rose-100
    selectedColor: Color(0xFFFECDD3), // Rose-200
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    labelStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFFFFE4E6), // Rose-100
    thickness: 1,
    space: 1,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFFE4E6), // Rose-100
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
);