import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:yummy/assets/theme/theme.dart'; // Подключаем вашу тему
import 'package:yummy/firebase_options.dart';
import 'package:yummy/pages/home_page.dart'; // Ваш главный экран
import 'package:yummy/provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  bool isDarkMode = await ThemeProvider.loadThemeState();
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode; // Инициализируем тему
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Yummy',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightThemeMode, // Светлая тема
      darkTheme: AppTheme.darkThemeMode, // Тёмная тема
      home: DrawerWidget(
        isDarkMode: _isDarkMode,
        onThemeChanged: (value) {
          setState(() {
            _isDarkMode =
                value; // Обновляем состояние темы в родительском виджете
          });
          ThemeProvider.saveThemeState(
              _isDarkMode); // Сохраняем выбранное состояние темы
        },
      ),
    );
  }
}
