import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummy/assets/theme/pallete.dart';

class HeartButton extends StatefulWidget {
  final String id; // Уникальный идентификатор товара

  const HeartButton({super.key, required this.id});

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadHeartState(); // Загрузка состояния при инициализации
  }

  // Функция для загрузки состояния из SharedPreferences
  _loadHeartState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Загрузка состояния для этого товара по его id
      isLiked = prefs.getBool('isLiked_${widget.id}') ?? false;
    });
  }

  // Функция для сохранения состояния в SharedPreferences
  _saveHeartState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Сохраняем состояние с уникальным ключом для каждого товара по его id
    prefs.setBool('isLiked_${widget.id}', value);
  }

  @override
  Widget build(BuildContext context) {
    // Получаем текущую тему
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Цвет для иконки в зависимости от темы
    final iconColor = isLiked
        ? Pallete.orange // Включенная иконка будет оранжевой
        : (isDarkMode
            ? Colors.white
            : Colors
                .black); // Черная иконка для светлой темы и белая для темной

    return IconButton(
      onPressed: () {
        setState(() {
          isLiked = !isLiked; // Переключаем состояние
          _saveHeartState(
              isLiked); // Сохраняем новое состояние для этого товара
        });
      },
      icon: Icon(
        isLiked
            ? CupertinoIcons.heart_fill // Заполненная иконка если "лайк"
            : CupertinoIcons.heart, // Пустая иконка если не "лайк"
        color: iconColor, // Цвет зависит от состояния и темы
      ),
    );
  }
}
