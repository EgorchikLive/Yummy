import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  // Тёмная тема
  static final darkThemeMode = ThemeData.dark().copyWith(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(18),
      enabledBorder: _border(Pallete.gray),
      focusedBorder: _border(Pallete.orange),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Pallete.white), // Цвет текста для RichText
      bodyMedium: TextStyle(color: Pallete.white),
      displayLarge: TextStyle(color: Pallete.white),
      displayMedium: TextStyle(color: Pallete.white),
      displaySmall: TextStyle(color: Pallete.white),
    ),
  );

  // Светлая тема
  static final lightThemeMode = ThemeData.light().copyWith(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(18),
      enabledBorder: _border(Pallete.grayLight),
      focusedBorder: _border(Pallete.orange),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Pallete.black), // Цвет текста для RichText
      bodyMedium: TextStyle(color: Pallete.black),
      displayLarge: TextStyle(color: Pallete.black),
      displayMedium: TextStyle(color: Pallete.black),
      displaySmall: TextStyle(color: Pallete.black),
    ),
  );
}
