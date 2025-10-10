import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/home_page.dart';
import 'package:yummy/services/auth_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HeartButton extends StatefulWidget {
  final String id;

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

  _checkLoginState() async {
    final savedState = await _authStorage.getLoginState();
    setState(() {
      isLoggedIn = savedState;
    });
  }

  // _loadHeartState() async {
  // final user = _auth.currentUser;
  //   if (user != null && widget.id.isNotEmpty) {
  //     try {
  //       final doc = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .collection('favorites')
  //           .doc(widget.id)
  //           .get();

  //       if (!mounted) return;
  //       setState(() {
  //         isLiked = doc.exists;
  //       });
  //     } catch (e) {
  //       debugPrint('Error loading heart state: $e');
  //     }
  //   } else {
  //     debugPrint('⚠️ Invalid state: user is null or widget.id is empty');
  //   }
  // }
  _loadHeartState() async {
    final user = _auth.currentUser;
    if (user != null) {
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

  // _saveHeartState(bool value) async {
  //   final user = _auth.currentUser;
  //   if (user == null) {
  //     debugPrint('⚠️ No logged-in user — cannot save favorite');
  //     return;
  //   }

  //   if (widget.id.isEmpty) {
  //     debugPrint('⚠️ widget.id is empty — skipping save');
  //     return;
  //   }

  //   try {
  //     final userRef = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .collection('favorites')
  //         .doc(widget.id);

  //     if (value) {
  //       await userRef.set({
  //         'id': widget.id,
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });
  //       debugPrint('✅ Added ${widget.id} to favorites');
  //     } else {
  //       await userRef.delete();
  //       debugPrint('❌ Removed ${widget.id} from favorites');
  //     }
  //   } catch (e, stack) {
  //     debugPrint('🔥 Firestore error: $e');
  //     debugPrint('$stack');
  //   }
  // }
  _saveHeartState(bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.id);

      if (value) {
        await userRef.set({
          'id': widget.id,
        });
      } else {
        await userRef.delete();
      }
    }
  }

  _onLikePressed() async {
    if (!isLoggedIn) {
      _showLoginDialog();
    } else {
      setState(() {
        isLiked = !isLiked;
        _saveHeartState(isLiked);
      });
    }
  }

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
      onPressed: _onLikePressed,
      icon: Icon(
        isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        color: iconColor,
      ),
    );
  }
}
