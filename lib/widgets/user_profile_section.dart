import 'dart:io';
import 'package:flutter/material.dart';
import 'avatar_section.dart';

class UserProfileSection extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isDark;
  final bool isUploading;
  final File? selectedImage;
  final VoidCallback onPickImage;

  const UserProfileSection({
    super.key,
    required this.userData,
    required this.isDark,
    required this.isUploading,
    required this.selectedImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarSection(
            avatarUrl: userData['avatarUrl'],
            isUploading: isUploading,
            selectedImage: selectedImage,
            onPickImage: onPickImage,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['username'] ?? 'Не указано',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  userData['email'] ?? 'Не указан',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
