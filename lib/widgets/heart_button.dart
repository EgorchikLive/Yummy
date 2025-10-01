import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/home_page.dart';
import 'package:yummy/services/auth_storage_service.dart'; // Импортируем сервис для авторизации
import 'package:firebase_auth/firebase_auth.dart';

class HeartButton extends StatefulWidget {
  final String id; // Уникальный идентификатор товара

  const HeartButton({super.key, required this.id});

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool isLiked = false;
  bool isLoggedIn = false;

  final AuthStorageService _authStorage = AuthStorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // Загрузка состояния "лайкнут" из Firestore
  _loadHeartState() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Проверяем наличие товара в избранном
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.id)
          .get();

      setState(() {
        isLiked = doc.exists;
      });
    }
  }

  // Сохранение состояния "лайкнут" в Firestore
  _saveHeartState(bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.id);

      if (value) {
        // Добавляем товар в избранное
        await userRef.set({
          'id': widget.id,
        });
      } else {
        // Удаляем товар из избранного
        await userRef.delete();
      }
    }
  }

  // Обработка нажатия на кнопку "Лайк"
  _onLikePressed() async {
    if (!isLoggedIn) {
      // Если пользователь не авторизован, показываем диалог
      _showLoginDialog();
    } else {
      // Если авторизован, сохраняем состояние лайка в Firestore
      setState(() {
        isLiked = !isLiked;
        _saveHeartState(isLiked);
      });
    }
  }

  // Диалог для авторизации
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
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage(selectedIndex: 4)), (_)=>false);
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
