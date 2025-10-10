import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider {
  static const String _themeKey = 'isDarkMode';

  static Future<bool> loadThemeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ??
        false;
  }

  static Future<void> saveThemeState(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, isDarkMode);
  }
}
