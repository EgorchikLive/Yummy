import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/home_page.dart';

class CartElevatedButton extends StatefulWidget {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final double discount;

  const CartElevatedButton({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discount,
  });

  @override
  State<CartElevatedButton> createState() => _CartElevatedButtonState();
}

class _CartElevatedButtonState extends State<CartElevatedButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addToCart() async {
    final user = _auth.currentUser;

    if (user == null) {
      _showLoginDialog();
      return;
    }

    final cartItem = {
      'id': widget.id,
      'name': widget.name,
      'imageUrl': widget.imageUrl,
      'price': widget.price,
      'discount': widget.discount,
      'finalPrice': (widget.price * (1 - widget.discount)).toStringAsFixed(2),
      'addedAt': Timestamp.now(),
    };

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(widget.id);

      await docRef.set(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар добавлен в корзину')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении в корзину: $e')),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Авторизация",
          style: TextStyle(color: Pallete.orange, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "Войдите в аккаунт, чтобы добавить товар в корзину.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage(selectedIndex: 4)));
            },
            child: const Text("Войти"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalPrice = widget.discount > 0
        ? (widget.price * (1 - widget.discount)).toStringAsFixed(2)
        : widget.price.toString();

    return ElevatedButton.icon(
      onPressed: _addToCart,
      icon: const Icon(Icons.shopping_cart),
      label: Text(
        widget.discount > 0 ? '$finalPrice руб' : '${widget.price} руб',
        style: const TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallete.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
