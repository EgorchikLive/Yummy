import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummy/widgets/card_page.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  List<Map<String, dynamic>> likedFoodList = [];

  @override
  void initState() {
    super.initState();
    _loadLikedItems();
  }

  // Загрузка всех товаров из Firestore и фильтрация избранных
  Future<void> _loadLikedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('foods').get();

    List<Map<String, dynamic>> likedItems = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      bool? isLiked = prefs.getBool('isLiked_${data['id']}') ?? false;

      if (isLiked) {
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
      likedFoodList = likedItems; // Обновляем состояние с избранными товарами
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: likedFoodList.isEmpty
          ? const Center(child: Text('Нет избранных товаров'))
          : ListView.builder(
              itemCount: likedFoodList.length,
              itemBuilder: (context, index) {
                return CardPage(
                  id: likedFoodList[index]['id']!,
                  name: likedFoodList[index]['name']!,
                  imageUrl: likedFoodList[index]['image']!,
                  price: likedFoodList[index]['price']!,
                  discount: likedFoodList[index]['discount']!,
                );
              },
            ),
    );
  }
}
