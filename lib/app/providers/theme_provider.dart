import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NomAi/app/constants/colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadTheme();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTheme() async {
    setDarkMode(!isDarkMode);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  void _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? isDarkMode = prefs.getBool('isDarkMode');

    setDarkMode(isDarkMode ?? false);
  }

  ThemeData get currentTheme {
    return isDarkMode ? darkTheme : lightTheme;
  }

  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    textTheme: textTheme,
    colorScheme: const ColorScheme.light(
      primary: NomAIColors.lightPrimary,
      secondary: NomAIColors.lightSecondary,
      onPrimary: NomAIColors.lightOnPrimary,
      surface: NomAIColors.lightSurface,
      onSurface: NomAIColors.lightOnSurface,
      outline: NomAIColors.lightSecondaryVariant,
    ),
    scaffoldBackgroundColor: NomAIColors.lightSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: NomAIColors.lightSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: textTheme.bodyLarge,
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return NomAIColors
                  .lightSecondaryVariant; // Custom background color for disabled state
            }
            return NomAIColors.lightPrimary;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return NomAIColors
                  .lightSurface; // Custom text color for disabled state
            }
            return NomAIColors.lightSurface;
          },
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.bodyLarge!.copyWith(
          color: NomAIColors.lightOnPrimary,
        ),
        iconColor: NomAIColors.lightOnPrimary),
  );

  ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      primary: NomAIColors.darkPrimary,
      secondary: NomAIColors.darkSecondary,
      onPrimary: NomAIColors.darkOnPrimary,
      surface: NomAIColors.darkSurface,
      onSurface: NomAIColors.darkOnSurface,
      outline: NomAIColors.darkSecondaryVariant,
    ),
    scaffoldBackgroundColor: NomAIColors.darkSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: NomAIColors.darkSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: textTheme.bodyLarge,
      border: OutlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return NomAIColors
                  .darkSecondaryVariant; // Custom background color for disabled state
            }
            return NomAIColors.darkPrimary;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return NomAIColors
                  .darkSurface; // Custom text color for disabled state
            }
            return NomAIColors.darkSurface;
          },
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.bodyLarge!.copyWith(
          color: NomAIColors.darkOnPrimary,
        ),
        iconColor: NomAIColors.darkOnPrimary),
  );
}

final TextTheme textTheme = TextTheme(
  displayLarge: GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.25,
  ),
  displayMedium: GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  displaySmall: GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  headlineLarge: GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  headlineMedium: GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  headlineSmall: GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  ),
  titleLarge: GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  ),
  titleMedium: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  labelLarge: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  labelMedium: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  labelSmall: GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  ),
  bodyLarge: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  ),
  bodyMedium: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  ),
  bodySmall: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  ),
);
