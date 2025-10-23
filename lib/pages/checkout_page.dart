import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/home_page.dart';
import 'package:yummy/services/card_payment_service.dart';
import 'package:yummy/widgets/payment_dialog.dart';
import 'package:yummy/widgets/transfer_dialog.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool get isSafe => mounted && !_isDisposed;

  void _showTransferDialog() async {
    final savedCards = await CardPaymentService().getSavedCards();

    if (savedCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавьте карту МИР для осуществления переводов'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => TransferDialog(savedCards: savedCards),
    );
  }

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

    await _firestore
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
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(id)
          .update({'quantity': quantity});
    }
  }

  Future<String> _createOrder(
      double total, List<QueryDocumentSnapshot> cartItems) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    try {
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId)
          .set({
        'orderId': orderId,
        'userId': user.uid,
        'userEmail': user.email,
        'total': total,
        'status': 'completed',
        'items': cartItems.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': data['id'],
            'name': data['name'],
            'price': data['finalPrice'],
            'quantity': data['quantity'],
            'imageUrl': data['imageUrl'],
          };
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'paymentStatus': 'succeeded',
      });

      return orderId;
    } catch (e) {
      throw Exception('Ошибка создания заказа: $e');
    }
  }

  Future<void> _clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    final batch = _firestore.batch();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void _onPaymentSuccess(String orderId) {
    if (!isSafe) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Оплата прошла успешно! Заказ создан.'),
        backgroundColor: Colors.green,
      ),
    );

    // Очищаем корзину после успешной оплаты
    _clearCart();

    // Возвращаемся на главную страницу
    _returnToMainPage();
  }

  void _onPaymentFailure() {
    if (!isSafe) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Оплата отменена или не завершена'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _returnToMainPage() {
    if (!isSafe) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  void _showPaymentDialog(double total, List<QueryDocumentSnapshot> docs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        amount: total,
        description: 'Оплата заказа из Yummy App',
        onSuccess: () async {
          try {
            final orderId = await _createOrder(total, docs);
            _onPaymentSuccess(orderId);
          } catch (e) {
            _onPaymentFailure();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка создания заказа: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        onFailure: _onPaymentFailure,
      ),
    );
  }

  // Метод для обновления данных при свайпе
  Future<void> _refreshData() async {
    // Принудительно обновляем состояние, чтобы перезагрузить StreamBuilder
    setState(() {});
    // Небольшая задержка для визуального эффекта
    await Future.delayed(const Duration(milliseconds: 500));
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(
              heightFactor: 12,
              child: Text("Пожалуйста, войдите в аккаунт, чтобы просмотреть корзину."),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Корзина"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
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
              return const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Center(
                  heightFactor: 12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Ваша корзина пуста",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Потяните вниз для обновления",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final total = _calculateTotal(docs);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final quantity = (data['quantity'] ?? 1) as int;
                      final price =
                          double.tryParse(data['finalPrice'].toString()) ?? 0.0;
                      final id = data['id'] ?? doc.id;

                      return Dismissible(
                        key: Key(id),
                        direction: DismissDirection.endToStart,
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
                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Удалить товар?',
                                style: TextStyle(color: Pallete.orange),
                              ),
                              content: const Text(
                                  'Вы уверены, что хотите удалить этот товар из корзины?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Удалить',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          return confirm ?? false;
                        },
                        onDismissed: (_) async {
                          await _removeFromCart(id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Товар удалён из корзины"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon:
                                          const Icon(Icons.remove_circle_outline),
                                      color: Pallete.orange,
                                      onPressed: () =>
                                          _updateQuantity(doc.id, quantity - 1),
                                    ),
                                    Text(
                                      "$quantity",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Pallete.darkGray : Pallete.lightGray,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
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
                    onPressed: () => _showPaymentDialog(total, docs),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.orange,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Оплатить",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}