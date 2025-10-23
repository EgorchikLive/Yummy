import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key});

  String _getOrderCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'заказ';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'заказа';
    }
    return 'заказов';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag, color: Colors.orange),
          const SizedBox(width: 8),
          const Text(
            'Мои заказы',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('orders')
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Text(
                '$count ${_getOrderCountText(count)}',
                style: TextStyle(color: Colors.grey[600]),
              );
            },
          ),
        ],
      ),
    );
  }
}
