import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yummy/widgets/card_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  List<Map<String, dynamic>> foodList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadLikedItems();
  }

  // Загрузка избранных товаров из Firestore для текущего пользователя
  Future<void> _loadLikedItems() async {
    final user = _auth.currentUser;

    if (user != null) {
      // Получаем все товары из коллекции "favorites" текущего пользователя
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      List<Map<String, dynamic>> likedItems = [];

      for (var doc in snapshot.docs) {
        // Получаем данные о товаре из основной коллекции
        var productDoc = await FirebaseFirestore.instance
            .collection('foods')
            .doc(doc.id)
            .get();

        if (productDoc.exists) {
          var data = productDoc.data() as Map<String, dynamic>;
          likedItems.add({
            'id': data['id'],
            'name': data['name'],
            'image': data['image'],
            'price': data['price'],
            'discount': data['discount'],
          });
        }
      }

      setState(() {
        foodList = likedItems; // Обновляем состояние с избранными товарами
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: foodList.isEmpty
          ? const Center(child: Text('Нет избранных товаров'))
          : ListView.builder(
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                return CardPage(
                  id: foodList[index]['id'] ??
                      '', // Если id равно null, используем пустую строку
                  name: foodList[index]['name'] ??
                      'Без названия', // Если name равно null, используем 'Без названия'
                  imageUrl: foodList[index]['image'] ??
                      '', // Если image равно null, используем пустую строку
                  price: foodList[index]['price'] ??
                      0, // Если price равно null, используем 0
                  discount: foodList[index]['discount'] ??
                      0.0, // Если discount равно null, используем 0.0
                  description: foodList[index]['description'] ??
                      '',
                );
              },
            ),
    );
  }
}
