import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppTheme {
  // Colori principali
  static const Color primaryColor = Color(0xFF003366);
  static const Color secondaryColor = Color(0xFFFFB300);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);

  // Testi
  static const Color textPrimaryLight = Colors.black;
  static const Color textSecondaryLight = Color(0xFF898989);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Superfici
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color.fromARGB(255, 31, 31, 31);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Elementi UI comuni
  static const double defaultPadding = 16.0;
  static const double cardRadius = 20.0;
  static const double buttonRadius = 20.0;
  static const double iconSize = 24.0;

  // Stili di testo comuni
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Roboto',
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
  );

  // Tema chiaro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceLight,
      background: Color.fromRGBO(234, 236, 238, 1),
      shadow: Colors.grey,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimaryLight,
      onBackground: textPrimaryLight,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: surfaceLight,
    cardColor: cardLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: titleStyle.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      bodySmall: captionStyle,
      titleLarge: titleStyle,
      titleMedium: titleStyle,
      titleSmall: titleStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12, horizontal: defaultPadding),
      ),
    ),
    useMaterial3: true,
  );

  // Tema scuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceDark,
      background: Color.fromARGB(255, 78, 77, 77),
      shadow: Colors.black,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
      onBackground: textPrimaryDark,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: surfaceDark,
    cardColor: cardDark,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: titleStyle.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: bodyStyle.copyWith(color: textPrimaryDark),
      bodyMedium: bodyStyle.copyWith(color: textPrimaryDark),
      bodySmall: captionStyle.copyWith(color: textSecondaryDark),
      titleLarge: titleStyle.copyWith(color: textPrimaryDark),
      titleMedium: titleStyle.copyWith(color: textPrimaryDark),
      titleSmall: titleStyle.copyWith(color: textPrimaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12, horizontal: defaultPadding),
      ),
    ),
    useMaterial3: true,
  );
}
