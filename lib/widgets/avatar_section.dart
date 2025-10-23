import 'dart:io';
import 'package:flutter/material.dart';

class AvatarSection extends StatelessWidget {
  final String? avatarUrl;
  final bool isUploading;
  final File? selectedImage;
  final VoidCallback onPickImage;

  const AvatarSection({
    super.key,
    required this.avatarUrl,
    required this.isUploading,
    required this.selectedImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: ClipOval(
            child: isUploading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : _buildImage(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isUploading ? null : onPickImage,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.person, size: 40, color: Colors.grey),
      );
}
