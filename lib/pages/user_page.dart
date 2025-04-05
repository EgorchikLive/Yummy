import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/home_page.dart';
import '../services/auth_storage_service.dart';
import 'account_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;

    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    }
  }

  Future<void> logout() async {
  await _auth.signOut();

  if (!mounted) return;

  final authStorage = AuthStorageService();
  await authStorage.clearLoginState();

  // Навигация на DrawerWidget с HomePage(selectedIndex: 4)
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => DrawerWidget(
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        onThemeChanged: (val) {}, // если не требуется изменить тему — передаём заглушку
        selectedIndex: 4, // 👈 переход к "Аккаунт"
      ),
    ),
    (route) => false,
  );
}



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Pallete.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text('Данные не найдены'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: userData!['avatarUrl'] != null &&
                                  userData!['avatarUrl'].isNotEmpty
                              ? NetworkImage(userData!['avatarUrl'])
                                  as ImageProvider
                              : const AssetImage('assets/images/default_avatar.png'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      InfoField(label: 'Имя', value: userData!['name'] ?? ''),
                      InfoField(label: 'Email', value: userData!['email'] ?? ''),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Выйти из аккаунта'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}

class InfoField extends StatelessWidget {
  final String label;
  final String value;

  const InfoField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
