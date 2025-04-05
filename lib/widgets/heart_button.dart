import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/home_page.dart';
import 'package:yummy/services/auth_storage_service.dart'; // Импортируем сервис для авторизации

class HeartButton extends StatefulWidget {
  final String id; // Уникальный идентификатор товара

  const HeartButton({super.key, required this.id});

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool isLiked = false;
  bool isLoggedIn = false; // Добавим флаг авторизации

  final AuthStorageService _authStorage = AuthStorageService();

  @override
  void initState() {
    super.initState();
    _loadHeartState();
    _checkLoginState();
  }

  // Проверка состояния авторизации при инициализации
  _checkLoginState() async {
    final savedState = await _authStorage.getLoginState();
    setState(() {
      isLoggedIn = savedState;
    });
  }

  // Загрузка состояния "лайкнут" из SharedPreferences
  _loadHeartState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLiked = prefs.getBool('isLiked_${widget.id}') ?? false;
    });
  }

  // Сохранение состояния "лайкнут" в SharedPreferences
  _saveHeartState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLiked_${widget.id}', value);
  }

  // Функция для обработки нажатия на кнопку "Лайк"
  _onLikePressed() async {
    if (!isLoggedIn) {
      // Если пользователь не авторизован, показываем диалог
      _showLoginDialog();
    } else {
      // Если авторизован, сохраняем состояние лайка
      setState(() {
        isLiked = !isLiked;
        _saveHeartState(isLiked);
      });
    }
  }

  // Диалог для предложения авторизации
  _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Авторизация",
            style:
                TextStyle(color: Pallete.orange, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            "Вы должны войти в свой аккаунт, чтобы добавить товар в избранное.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrawerWidget(
                      isDarkMode: Theme.of(context).brightness == Brightness.dark,
                      onThemeChanged: (val) {}, // заглушка для смены темы
                      selectedIndex: 4, // 👉 переход к "Аккаунт"
                    ),
                  ),
                  (_) => false,
                );
              },
              child: const Text("Войти"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isLiked ? Pallete.orange : (isDarkMode ? Colors.white : Colors.black);

    return IconButton(
      onPressed: _onLikePressed, // Вызываем метод для обработки нажатия
      icon: Icon(
        isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        color: iconColor,
      ),
    );
  }
}
