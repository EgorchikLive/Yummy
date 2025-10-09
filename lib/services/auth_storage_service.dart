import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const _isLoggedInKey = 'isLoggedIn';

  Future<void> saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<bool> getLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false; // Возвращаем безопасное значение по умолчанию
    }
  }
  // Future<bool> getLoginState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool(_isLoggedInKey) ?? false;
  // }

  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthStorageService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   static const _isLoggedInKey = 'isLoggedIn';

//   // Метод для получения текущего пользователя
//   Future<User?> getCurrentUser() async {
//     return _auth.currentUser;
//   }

//   // Метод для получения состояния авторизации
//   Future<bool> getLoginState() async {
//     final user = await getCurrentUser();
//     return user != null;
//   }

//   // Сохранение состояния авторизации
//   Future<void> saveLoginState(bool isLoggedIn) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isLoggedInKey, isLoggedIn);
//   }

//   // Очистка состояния авторизации
//   Future<void> clearLoginState() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_isLoggedInKey);
//   }
// }
