import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';

class MenuPage extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MenuPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.menu,
      body: Column(
        children: [
          const SizedBox(height: 64),
          SwitchListTile(
            title: const Text('Темная тема'),
            value: isDarkMode,
            onChanged: onThemeChanged,
          ),
        ],
      ),
    );
  }
}
