// lib/theme/theme.dart

import 'package:flutter/material.dart';
import '/theme/custom_colors.dart';

// 耳 MODERN TYPOGRAPHY SYSTEM
// Using Inter for body text (excellent readability) and SF Pro Display for headlines
const TextTheme appTextTheme = TextTheme(
  // Display styles - Bold, impactful headlines
  displayLarge: TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w700,
    fontSize: 57,
    letterSpacing: -0.25,
    height: 1.12,
  ),
  displayMedium: TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w700,
    fontSize: 45,
    letterSpacing: 0,
    height: 1.16,
  ),
  displaySmall: TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w600,
    fontSize: 36,
    letterSpacing: 0,
    height: 1.22,
  ),

  // Headlines - Section headers
  headlineLarge: TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w600,
    fontSize: 32,
    letterSpacing: 0,
    height: 1.25,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: 0,
    height: 1.29,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w600,
    fontSize: 24,
    letterSpacing: 0,
    height: 1.33,
  ),

  // Titles - Card and component titles
  titleLarge: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 22,
    letterSpacing: 0,
    height: 1.27,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.15,
    height: 1.5,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.1,
    height: 1.43,
  ),

  // Body - Main content text
  bodyLarge: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.5,
    height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.25,
    height: 1.43,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
    height: 1.33,
  ),

  // Labels - Buttons and UI elements
  labelLarge: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.1,
    height: 1.43,
  ),
  labelMedium: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.5,
    height: 1.33,
  ),
  labelSmall: TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 0.5,
    height: 1.45,
  ),
);

// 耳 MODERN COLOR PALETTE
// Based on contemporary design systems (Radix, Tailwind, Shadcn)
const Color primaryGreen = Color(0xFF10B981); // Emerald-500
const Color primaryGreenDark = Color(0xFF059669); // Emerald-600
const Color secondaryTeal = Color(0xFF06B6D4); // Cyan-500
const Color accentBlue = Color(0xFF3B82F6); // Blue-500
const Color warningAmber = Color(0xFFF59E0B); // Amber-500
const Color errorRed = Color(0xFFEF4444); // Red-500

// ✅ NEW: Purple-ish colors for the light theme
const Color primaryPurple = Color(0xFF6366F1); // Indigo-500
const Color secondaryViolet = Color(0xFF8B5CF6); // Violet-500

// 笘 ｸLIGHT THEME - Clean, modern, accessible (NOW PURPLE)
final ThemeData lightThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      // Semantic colors remain the same
      successGradient: [Color(0xFF10B981), Color(0xFF059669)],
      errorGradient: [Color(0xFFEF4444), Color(0xFFF59E0B)],
      heatmapExpense: Color(0xFFF87171), // Red-400
      heatmapIncome: Color(0xFF34D399), // Emerald-400
      categoryColors: {},
    ),
  ],

  colorScheme: const ColorScheme.light(
    // ✅ Primary - Indigo
    primary: primaryPurple,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0E7FF), // Indigo-100
    onPrimaryContainer: Color(0xFF3730A3), // Indigo-900

    // ✅ Secondary - Violet
    secondary: secondaryViolet,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEDE9FE), // Violet-100
    onSecondaryContainer: Color(0xFF4C1D95), // Violet-900

    // ✅ Tertiary - Blue (complements purple well)
    tertiary: accentBlue,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFDBEAFE), // Blue-100
    onTertiaryContainer: Color(0xFF1E3A8A), // Blue-900

    // Error - Red
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2), // Red-100
    onErrorContainer: Color(0xFF7F1D1D), // Red-900

    // ✅ Surface - Neutral grays from Indigo family for a purple-ish tint
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1E1B4B), // Indigo-950
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEEF2FF), // Indigo-50
    surfaceContainer: Color(0xFFE0E7FF), // Indigo-100
    surfaceContainerHigh: Color(0xFFC7D2FE), // Indigo-200
    surfaceContainerHighest: Color(0xFFA5B4FC), // Indigo-300

    // ✅ Outline - Borders and dividers from Indigo family
    outline: Color(0xFFC7D2FE), // Indigo-200
    outlineVariant: Color(0xFFE0E7FF), // Indigo-100
    shadow: Color(0xFF000000), // Note: We override this in the card

    // Inverse
    inverseSurface: Color(0xFF1E1B4B), // Indigo-950
    onInverseSurface: Color(0xFFEEF2FF), // Indigo-50
    inversePrimary: Color(0xFF818CF8), // Indigo-400
  ),

  scaffoldBackgroundColor: const Color(0xFFEEF2FF), // ✅ Indigo-50
  textTheme: appTextTheme,

  // Card theme - Elevated, modern
  cardTheme: const CardTheme(
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  ),

  // Elevated button - Primary actions
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
    ),
  ),

  // Filled button (alternative style)
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),

  // Chip theme
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFFE0E7FF), // ✅ Indigo-100
    selectedColor: Color(0xFFC7D2FE), // ✅ Indigo-200
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    labelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE0E7FF), // ✅ Indigo-100
    thickness: 1,
    space: 1,
  ),

  // Input decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFE0E7FF), // ✅ Indigo-100
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
      borderSide: const BorderSide(color: primaryPurple, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
);

// 嫌 DARK THEME - Rich, comfortable, OLED-friendly
final ThemeData darkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  extensions: const <ThemeExtension<dynamic>>[
    CustomColors(
      successGradient: [Color(0xFF34D399), Color(0xFF10B981)],
      errorGradient: [Color(0xFFF87171), Color(0xFFFBBF24)],
      heatmapExpense: Color(0xFFF87171), // Red-400 (often looks good on dark too)
      heatmapIncome: Color(0xFF34D399), // Emerald-400
      categoryColors: {},
    ),
  ],

  colorScheme: const ColorScheme.dark(
    // Primary - Emerald green (lighter for dark mode)
    primary: Color(0xFF34D399),
    onPrimary: Color(0xFF064E3B),
    primaryContainer: Color(0xFF065F46), // Emerald-800
    onPrimaryContainer: Color(0xFFD1FAE5),

    // Secondary - Cyan
    secondary: Color(0xFF22D3EE),
    onSecondary: Color(0xFF164E63),
    secondaryContainer: Color(0xFF155E75), // Cyan-800
    onSecondaryContainer: Color(0xFFCFFAFE),

    // Tertiary - Blue
    tertiary: Color(0xFF60A5FA),
    onTertiary: Color(0xFF1E3A8A),
    tertiaryContainer: Color(0xFF1E40AF), // Blue-800
    onTertiaryContainer: Color(0xFFDBEAFE),

    // Error - Red
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFF991B1B), // Red-800
    onErrorContainer: Color(0xFFFEE2E2),

    // Surface - Rich dark surfaces
    surface: Color(0xFF0F172A), // Slate-900
    onSurface: Color(0xFFF1F5F9), // Slate-100
    surfaceContainerLowest: Color(0xFF020617), // Slate-950
    surfaceContainerLow: Color(0xFF1E293B), // Slate-800
    surfaceContainer: Color(0xFF334155), // Slate-700
    surfaceContainerHigh: Color(0xFF475569), // Slate-600
    surfaceContainerHighest: Color(0xFF64748B), // Slate-500

    // Outline
    outline: Color(0xFF475569), // Slate-600
    outlineVariant: Color(0xFF334155), // Slate-700
    shadow: Color(0xFF000000),

    // Inverse
    inverseSurface: Color(0xFFF1F5F9), // Slate-100
    onInverseSurface: Color(0xFF1E293B), // Slate-800
    inversePrimary: Color(0xFF10B981),
  ),

  scaffoldBackgroundColor: const Color(0xFF020617),
  textTheme: appTextTheme,

  cardTheme: const CardTheme(
    elevation: 0,
    shadowColor: Colors.transparent,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
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
    backgroundColor: Color(0xFF1E293B),
    selectedColor: Color(0xFF065F46),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    labelStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF334155),
    thickness: 1,
    space: 1,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E293B),
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
      borderSide: const BorderSide(color: Color(0xFF34D399), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
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

  cardTheme: const CardTheme(
    elevation: 0,
    shadowColor: Colors.transparent,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
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
      fontFamily: 'Inter',
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