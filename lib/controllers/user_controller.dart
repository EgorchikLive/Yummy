import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_storage_service.dart';
import '../../provider/theme_provider.dart';

class UserController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isUploading = false;
  File? selectedImage;
  BuildContext? _context;

  void init(BuildContext context) {
    _context = context;
    fetchUserData();
  }

  void disposeController() {
    _context = null;
  }

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      userData = doc.data();
    } catch (_) {
      _showError('Ошибка загрузки данных');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    isLoading = true;
    notifyListeners();
    await fetchUserData();
  }

  Future<void> showImagePickerDialog() async {
    if (_context == null) return;
    showModalBottomSheet(
      context: _context!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    final user = _auth.currentUser;
    if (user == null || selectedImage == null) return;

    isUploading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final imageUrl = 'https://via.placeholder.com/150?text=New+Avatar';

      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      userData?['avatarUrl'] = imageUrl;
      selectedImage = null;
      _showMessage('Аватарка успешно обновлена', Colors.green);
    } catch (_) {
      _showError('Ошибка загрузки аватарки');
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context, VoidCallback onLogout) async {
    try {
      await _auth.signOut();
      await AuthStorageService().clearLoginState();

      final isDark = Theme.of(context).brightness == Brightness.dark;
      await ThemeProvider.saveThemeState(isDark);
      onLogout();
    } catch (_) {
      _showError('Ошибка при выходе');
    }
  }

  void _showError(String msg) => _showMessage(msg, Colors.red);
  void _showMessage(String msg, Color color) {
    if (_context == null) return;
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}
