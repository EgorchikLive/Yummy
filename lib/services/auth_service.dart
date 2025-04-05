import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Пытаемся создать пользователя с email и паролем
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Проверка на null перед использованием user
      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'Failed to create user, user data is null',
        );
      }

      // Получаем uid нового пользователя
      String uid = userCredential.user!.uid;

      // Добавляем пользователя в Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Если все прошло успешно, возвращаем true
        return true;
      } catch (e) {
        // Ошибка при добавлении в Firestore
        print('Firestore Error: $e');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      // Обработка ошибок регистрации
      print('Registration Error: ${e.message}');
      return false;
    } catch (e) {
      // Обработка прочих ошибок
      print('Error: $e');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Пытаемся войти пользователя с email и паролем
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Если все прошло успешно, возвращаем true
      return true;
    } on FirebaseAuthException catch (e) {
      // Ошибка при входе
      print('Sign In Error: ${e.message}');
      return false;
    } catch (e) {
      // Прочие ошибки
      print('Error: $e');
      return false;
    }
  }
}
