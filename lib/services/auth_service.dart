// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Вход через email и пароль
//   Future<bool> signIn({required String email, required String password}) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//       return true;
//     } catch (e) {
//       print('Sign in error: $e');
//       return false;
//     }
//   }

//   // Регистрация
//   Future<bool> register({
//     required String username,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Добавим пользователя в Firestore
//       await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
//         'name': username,
//         'email': email,
//         'authMethod': 'email',
//         'createdAt': DateTime.now(),
//       });

//       return true;
//     } catch (e) {
//       print('Register error: $e');
//       return false;
//     }
//   }

//   // Вход через Google
//   Future<bool> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return false;

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       final user = userCredential.user;

//       if (user != null) {
//         final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//         final doc = await userRef.get();

//         if (!doc.exists) {
//           await userRef.set({
//             'name': user.displayName ?? '',
//             'email': user.email,
//             'authMethod': 'google',
//             'createdAt': DateTime.now(),
//           });
//         }
//       }

//       return true;
//     } catch (e) {
//       print('Google sign in error: $e');
//       return false;
//     }
//   }

//   // Проверка, через какой метод вошли
//   Future<String?> getAuthMethod() async {
//     final user = _auth.currentUser;
//     if (user == null) return null;

//     try {
//       final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       if (doc.exists) {
//         return doc.data()?['authMethod'];
//       }
//     } catch (e) {
//       print('getAuthMethod error: $e');
//     }
//     return null;
//   }

//   // Выход
//   Future<void> signOut() async {
//     await GoogleSignIn().signOut();
//     await _auth.signOut();
//   }
// }


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
