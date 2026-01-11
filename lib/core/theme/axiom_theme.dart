import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Axiom App Color Palette
class AxiomColors {
  // Primary colors
  static const Color cyan = Color(0xFF00B8B5);  // More contrasting teal
  static const Color darkNavy = Color(0xFF252A34);
  static const Color pink = Color(0xFFFF2E63);
  static const Color lightGray = Color(0xFFEAEAEA);

  // Additional shades
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF1A1D24);

  // Error/warning colors (softer than red)
  static const Color warning = Color(0xFFE67E22);  // Orange for errors/warnings
  static const Color warningLight = Color(0xFFF39C12);  // Lighter orange

  // Game accent colors
  static const Color almanacAccent = cyan;
  static const Color cryptixAccent = Color(0xFF3498DB);
  static const Color doubletAccent = Colors.indigo;
  static const Color triverseAccent = Color(0xFF9B59B6);  // Purple

  // Cryptix-specific colors
  static const Color accent = Color(0xFF3498DB);      // Light blue accent
  static const Color accentDark = Color(0xFF2980B9);  // Darker blue
  static const Color success = Color(0xFF2ECC71);      // Green
  static const Color successDark = Color(0xFF27AE60);  // Darker green
  static const Color hintHighlight = Color(0xFFFFD700); // Gold/yellow for hints
}

/// Build text theme using Roboto Slab
TextTheme _buildTextTheme(TextTheme base, Color color) {
  return GoogleFonts.robotoSlabTextTheme(base).copyWith(
    headlineLarge: GoogleFonts.robotoSlab(color: color, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.robotoSlab(color: color, fontWeight: FontWeight.bold),
    headlineSmall: GoogleFonts.robotoSlab(color: color, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.robotoSlab(color: color, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.robotoSlab(color: color, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.robotoSlab(color: color, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.robotoSlab(color: color),
    bodyMedium: GoogleFonts.robotoSlab(color: color),
    bodySmall: GoogleFonts.robotoSlab(color: color),
    labelLarge: GoogleFonts.robotoSlab(color: color, fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.robotoSlab(color: color),
    labelSmall: GoogleFonts.robotoSlab(color: color),
  );
}

/// Light Theme
final ThemeData axiomLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: const ColorScheme.light(
    primary: AxiomColors.cyan,
    onPrimary: AxiomColors.darkNavy,
    secondary: AxiomColors.pink,
    onSecondary: AxiomColors.white,
    surface: AxiomColors.white,
    onSurface: AxiomColors.darkNavy,
    error: AxiomColors.warning,
    onError: AxiomColors.white,
  ),

  scaffoldBackgroundColor: AxiomColors.lightGray,

  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: AxiomColors.darkNavy,
    foregroundColor: AxiomColors.white,
    iconTheme: IconThemeData(color: AxiomColors.white),
  ),

  cardTheme: CardThemeData(
    elevation: 2,
    color: AxiomColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AxiomColors.cyan,
      foregroundColor: AxiomColors.darkNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AxiomColors.cyan,
      side: const BorderSide(color: AxiomColors.cyan, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AxiomColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AxiomColors.lightGray, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AxiomColors.cyan, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),

  iconTheme: const IconThemeData(color: AxiomColors.darkNavy),

  textTheme: _buildTextTheme(ThemeData.light().textTheme, AxiomColors.darkNavy),

  chipTheme: ChipThemeData(
    backgroundColor: AxiomColors.cyan.withValues(alpha: 0.2),
    labelStyle: const TextStyle(color: AxiomColors.darkNavy),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);

/// Dark Theme
final ThemeData axiomDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: const ColorScheme.dark(
    primary: AxiomColors.cyan,
    onPrimary: AxiomColors.darkNavy,
    secondary: AxiomColors.pink,
    onSecondary: AxiomColors.white,
    surface: AxiomColors.darkNavy,
    onSurface: AxiomColors.lightGray,
    error: AxiomColors.warningLight,
    onError: AxiomColors.darkNavy,
  ),

  scaffoldBackgroundColor: AxiomColors.darkGray,

  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: AxiomColors.darkNavy,
    foregroundColor: AxiomColors.lightGray,
    iconTheme: IconThemeData(color: AxiomColors.lightGray),
  ),

  cardTheme: CardThemeData(
    elevation: 2,
    color: AxiomColors.darkNavy,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AxiomColors.cyan,
      foregroundColor: AxiomColors.darkNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AxiomColors.cyan,
      side: const BorderSide(color: AxiomColors.cyan, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AxiomColors.darkNavy,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AxiomColors.lightGray.withValues(alpha: 0.3), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AxiomColors.cyan, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(color: AxiomColors.lightGray),
    hintStyle: TextStyle(color: AxiomColors.lightGray.withValues(alpha: 0.6)),
  ),

  iconTheme: const IconThemeData(color: AxiomColors.lightGray),

  textTheme: _buildTextTheme(ThemeData.dark().textTheme, AxiomColors.lightGray),

  chipTheme: ChipThemeData(
    backgroundColor: AxiomColors.cyan.withValues(alpha: 0.2),
    labelStyle: const TextStyle(color: AxiomColors.lightGray),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
