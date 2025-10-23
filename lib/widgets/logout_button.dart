import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Выйти из аккаунта'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
