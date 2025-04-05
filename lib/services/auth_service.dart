import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

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

// class AuthService {
//   Future<void> register({
//     required String email,
//     required String password,
//     required String username, // Добавим, например, имя пользователя
//   }) async {
//     try {
//       // Пытаемся создать пользователя с email и паролем
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Получаем uid нового пользователя
//       String uid = userCredential.user!.uid;

//       // Проверяем, существует ли пользователь с таким email в Firestore
//       var userDoc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();

//       if (userDoc.exists) {
//         // Если пользователь с таким uid уже существует, показываем ошибку
//         Get.snackbar('Error', 'User already exists in the database.',
//             colorText: Colors.red);
//       } else {
//         // Если пользователя нет в базе данных, добавляем его в Firestore
//         await FirebaseFirestore.instance.collection('users').doc(uid).set({
//           'email': email,
//           'username': username,
//           'createdAt': FieldValue.serverTimestamp(), // Дата создания
//         });

//         // При успешной регистрации и добавлении в базу данных показываем сообщение
//         Get.snackbar('Success', 'User registered and data saved successfully!',
//             colorText: Colors.green);
//       }
//     } on FirebaseAuthException catch (e) {
//       // Обработка ошибок регистрации
//       String message = '';
//       switch (e.code) {
//         case 'weak-password':
//           message = 'The password provided is too weak.';
//           break;
//         case 'email-already-in-use':
//           message = 'An account already exists with that email.';
//           break;
//         case 'invalid-email':
//           message = 'The email address is not valid.';
//           break;
//         case 'operation-not-allowed':
//           message =
//               'Email/password accounts are not enabled. Please enable them in the Firebase Console.';
//           break;
//         default:
//           message = e.message ?? 'An unknown error occurred.';
//       }

//       // Показываем ошибку через Snackbar
//       Get.snackbar('Error', message, colorText: Colors.red);
//     }
//   }
// }
