import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummy/assets/theme/pallete.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _calculateTotal(List<QueryDocumentSnapshot> docs) {
    double total = 0.0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = double.tryParse(data['finalPrice'].toString()) ?? 0.0;
      final quantity = (data['quantity'] ?? 1).toDouble();
      total += price * quantity;
    }
    return total;
  }

  Future<void> _removeFromCart(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(id)
        .delete();
  }

  Future<void> _updateQuantity(String id, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (quantity <= 0) {
      await _removeFromCart(id);
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(id)
          .update({'quantity': quantity});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Корзина"),
        ),
        body: const Center(
          child: Text("Пожалуйста, войдите в аккаунт, чтобы просмотреть корзину."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Корзина"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Ваша корзина пуста."),
            );
          }

          final docs = snapshot.data!.docs;
          final total = _calculateTotal(docs);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final quantity = (data['quantity'] ?? 1) as int;
                    final price = double.tryParse(data['finalPrice'].toString()) ?? 0.0;
                    final id = data['id'] ?? doc.id;

                    return Dismissible(
                      key: Key(id),
                      direction: DismissDirection.endToStart, // свайп влево
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.redAccent,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        // подтверждение удаления
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Удалить товар?', style: TextStyle(color: Pallete.orange),),
                            content: const Text('Вы уверены, что хотите удалить этот товар из корзины?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        return confirm ?? false;
                      },
                      onDismissed: (_) async {
                        await _removeFromCart(id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Товар удалён из корзины"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  data['imageUrl'] ?? '',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'Без названия',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Цена: ${(price * quantity).toStringAsFixed(2)} ₽",
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              // 🧮 Счётчик количества
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: Pallete.orange,
                                    onPressed: () =>
                                        _updateQuantity(doc.id, quantity - 1),
                                  ),
                                  Text(
                                    "$quantity",
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Pallete.orange,
                                    onPressed: () =>
                                        _updateQuantity(doc.id, quantity + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Pallete.darkGray : Pallete.lightGray,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Итого:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Pallete.orange,
                      ),
                    ),
                    Text(
                      "${total.toStringAsFixed(2)} ₽",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Оформление заказа пока не реализовано 🙂")),
                    );
                  },
                  child: const Text(
                    "Оформить заказ",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}


