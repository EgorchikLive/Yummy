import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/home_page.dart';

class CartButton extends StatefulWidget {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final double discount;

  const CartButton({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discount,
  });

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addToCart() async {
    final user = _auth.currentUser;

    if (user == null) {
      _showLoginDialog();
      return;
    }

    final finalPrice = (widget.price * (1 - widget.discount)).toStringAsFixed(2);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(widget.id);

      // Проверяем, существует ли уже товар в корзине
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Если товар уже есть в корзине, увеличиваем количество на 1
        final currentData = docSnapshot.data() as Map<String, dynamic>;
        final currentQuantity = (currentData['quantity'] ?? 1) as int;
        
        await docRef.update({
          'quantity': currentQuantity + 1,
          'addedAt': Timestamp.now(),
        });
      } else {
        // Если товара нет в корзине, создаем новый документ с quantity = 1
        final cartItem = {
          'id': widget.id,
          'name': widget.name,
          'imageUrl': widget.imageUrl,
          'price': widget.price,
          'discount': widget.discount,
          'finalPrice': finalPrice,
          'quantity': 1, // Начальное количество
          'addedAt': Timestamp.now(),
        };

        await docRef.set(cartItem);
      }

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
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const HomePage(selectedIndex: 4)), 
                (_)=>false
              );
            },
            child: const Text("Войти"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _addToCart,
      icon: const Icon(Icons.shopping_cart),
    );
  }
}