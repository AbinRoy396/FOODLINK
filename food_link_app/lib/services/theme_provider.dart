import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Common button style
  static final ButtonStyle _elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF11D452), // Green color
    foregroundColor: Colors.black,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF11D452),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F8F6),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF111813)),
      displayMedium: TextStyle(color: Color(0xFF111813)),
      displaySmall: TextStyle(color: Color(0xFF111813)),
      headlineLarge: TextStyle(color: Color(0xFF111813)),
      headlineMedium: TextStyle(color: Color(0xFF111813)),
      headlineSmall: TextStyle(color: Color(0xFF111813)),
      titleLarge: TextStyle(color: Color(0xFF111813)),
      titleMedium: TextStyle(color: Color(0xFF111813)),
      titleSmall: TextStyle(color: Color(0xFF111813)),
      bodyLarge: TextStyle(color: Color(0xFF111813)),
      bodyMedium: TextStyle(color: Color(0xFF111813)),
      bodySmall: TextStyle(color: Color(0xFF111813)),
      labelLarge: TextStyle(color: Color(0xFF111813)),
      labelMedium: TextStyle(color: Color(0xFF111813)),
      labelSmall: TextStyle(color: Color(0xFF111813)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF11D452),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF11D452),
        side: const BorderSide(color: Color(0xFF11D452)),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF11D452),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF102216),
    cardColor: const Color(0xFF182E1F),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFE3E3E3)),
      displayMedium: TextStyle(color: Color(0xFFE3E3E3)),
      displaySmall: TextStyle(color: Color(0xFFE3E3E3)),
      headlineLarge: TextStyle(color: Color(0xFFE3E3E3)),
      headlineMedium: TextStyle(color: Color(0xFFE3E3E3)),
      headlineSmall: TextStyle(color: Color(0xFFE3E3E3)),
      titleLarge: TextStyle(color: Color(0xFFE3E3E3)),
      titleMedium: TextStyle(color: Color(0xFFE3E3E3)),
      titleSmall: TextStyle(color: Color(0xFFE3E3E3)),
      bodyLarge: TextStyle(color: Color(0xFFE3E3E3)),
      bodyMedium: TextStyle(color: Color(0xFFE3E3E3)),
      bodySmall: TextStyle(color: Color(0xFFE3E3E3)),
      labelLarge: TextStyle(color: Color(0xFFE3E3E3)),
      labelMedium: TextStyle(color: Color(0xFFE3E3E3)),
      labelSmall: TextStyle(color: Color(0xFFE3E3E3)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF11D452),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF11D452),
        side: const BorderSide(color: Color(0xFF11D452)),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
